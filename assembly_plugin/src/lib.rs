use wasm_minimal_protocol::*;
use serde::{Deserialize, Serialize};
use std::collections::{HashMap, HashSet};
use petgraph::prelude::*;

initiate_protocol!();

// Import our typed element system
mod types;
use types::{Element, FeatureElement};

// Import SAT solver and feature model validation
mod sat_solver;
mod feature_validation;
use feature_validation::{validate_feature_model, validate_configuration};

/// Registry - maps element ID to Element
pub type Registry = HashMap<String, Element>;

/// Individual link record
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Link {
    pub source: String,  // Source element ID
    #[serde(rename = "type")]
    pub link_type: String,  // Link type (trace, satisfy, child_of, etc.)
    pub target: String,  // Target element ID
}

pub type Links = Vec<Link>;

/// Active configuration ID
pub type ActiveConfig = Option<String>;

/// Input structure passed from Typst
#[derive(Debug, Serialize, Deserialize)]
pub struct ValidationInput {
    pub registry: Registry,
    pub links: Links,
    pub active_config: ActiveConfig,
}

/// Validation result returned to Typst
#[derive(Debug, Serialize, Deserialize)]
pub struct ValidationResult {
    pub passed: bool,
    pub total_elements: usize,
    pub message: String,
}

// ============================================================================
// Main Validation Function (WASM Export)
// ============================================================================

#[wasm_func]
pub fn validate_rules(input_bytes: &[u8]) -> Vec<u8> {
    // Parse input JSON
    let input: ValidationInput = match serde_json::from_slice(input_bytes) {
        Ok(data) => data,
        Err(e) => {
            let error_result = ValidationResult {
                passed: false,
                total_elements: 0,
                message: format!("Failed to parse input: {}", e),
            };
            return serde_json::to_vec(&error_result).unwrap_or_default();
        }
    };

    let mut violations = Vec::new();

    // Lets convert our data to a graph
    let mut graph = petgraph::Graph::new();

    // Add nodes to the graph
    let mut node_indices = HashMap::new();
    for (id, element) in &input.registry {
        let node = graph.add_node((id.clone(), element.clone()));
        node_indices.insert(id.clone(), node);
    }

    // Add edges to the graph
    for link in &input.links {
        if let (Some(&source), Some(&target)) = (node_indices.get(&link.source), node_indices.get(&link.target)) {
            graph.add_edge(source, target, link.link_type.clone());
        } else {
            violations.push(format!(
                "Link references non-existent element: {} -> {}",
                link.source, link.target
            ));
        }
    }

    // All usecase must be traced to one or more requirements. Iterate over all use cases 
    // and check for trace links to requirements.
    // TODO: Iterate over the graph, find the Use-cases, make sure that each has at least one
    // outgoing trace link to a requirement.
    for node_idx in graph.node_indices() {
        if let Some(node_weight) = graph.node_weight(node_idx) {
            let (_node_id, element) = node_weight;
            if let Element::UseCase(ref use_case) = *element {
                let mut traced = false;
                for edge in graph.edges_directed(node_idx, petgraph::Direction::Outgoing) {
                    if let Some(target_weight) = graph.node_weight(edge.target()) {
                        let (_t_id, t_element) = target_weight;
                        if let Element::Req(_) = *t_element {
                            traced = true;
                            break;
                        }
                    }
                }
                if !traced {
                    violations.push(format!(
                        "Use case {} is not traced to any requirement",
                        use_case.id
                    ));
                }
            }
        }
    }

    // Rule 1: Check ID uniqueness
    let mut seen_ids = HashSet::new();
    for (key, element) in &input.registry {
        if !seen_ids.insert(element.id()) {
            violations.push(format!("Duplicate ID: {}", element.id()));
        }
        // Check that key matches element ID (configs use "CONFIG:" prefix)
        let expected_key = if matches!(element, Element::Config(_)) {
            format!("CONFIG:{}", element.id())
        } else {
            element.id().to_string()
        };
        if key != &expected_key {
            violations.push(format!(
                "Registry key mismatch: key='{}' but expected '{}'",
                key, expected_key
            ));
        }
    }

    // Rule 2: Check feature tree consistency
    for element in input.registry.values() {
        // Pattern match on Element enum - type-safe!
        if let Element::Feature(feature) = element {
            // Type-safe access to feature-specific fields
            if let Some(parent_id) = &feature.parent {
                if parent_id != "ROOT" && !input.registry.contains_key(parent_id) {
                    violations.push(format!(
                        "Feature {} references non-existent parent: {}",
                        feature.id, parent_id
                    ));
                }
            }

            // Check XOR/OR group constraints
            if feature.is_variability_group() {
                let children: Vec<&FeatureElement> = input
                    .registry
                    .values()
                    .filter_map(|e| e.as_feature())
                    .filter(|f| f.parent.as_deref() == Some(&feature.id))
                    .collect();

                if children.len() < 2 {
                    violations.push(format!(
                        "Feature {} has {:?} group but only {} children (need >= 2)",
                        feature.id,
                        feature.group.as_ref().unwrap(),
                        children.len()
                    ));
                }
            }
        }
    }

    // Rule 3: Validate block definition references
    for element in input.registry.values() {
        if let Element::BlockDefinition(block) = element {
            // Type-safe access to SysML data via typed accessors
            for part in block.parts() {
                if !input.registry.contains_key(&part.part_type) {
                    violations.push(format!(
                        "Block {} references non-existent part type: {}",
                        block.id, part.part_type
                    ));
                }
            }
        }
    }

    // Rule 4: Validate configurations
    for element in input.registry.values() {
        if let Element::Config(config) = element {
            for feature_id in &config.selected {
                match input.registry.get(feature_id) {
                    Some(Element::Feature(feature)) => {
                        // Check if feature is concrete
                        if feature.is_abstract() {
                            violations.push(format!(
                                "Config {} selects abstract feature: {}",
                                config.id, feature_id
                            ));
                        }
                    }
                    Some(other) => {
                        violations.push(format!(
                            "Config {} selects non-feature element: {} (type: {})",
                            config.id,
                            feature_id,
                            other.type_name()
                        ));
                    }
                    None => {
                        violations.push(format!(
                            "Config {} selects non-existent feature: {}",
                            config.id, feature_id
                        ));
                    }
                }
            }
        }
    }

    // Rule 5: Validate feature model consistency using SAT solver
    // Find root feature (feature with no parent or parent = "ROOT")
    let root_features: Vec<_> = input
        .registry
        .values()
        .filter_map(|e| e.as_feature())
        .filter(|f| f.parent.is_none() || f.parent.as_deref() == Some("ROOT"))
        .collect();

    if !root_features.is_empty() {
        // Use first root feature found (typically there should be only one)
        let root_id = root_features[0].id.clone();
        let fm_validation = validate_feature_model(&input.registry, &root_id);

        if !fm_validation.is_consistent {
            violations.push(format!(
                "Feature model is INCONSISTENT (SAT check failed): {}",
                fm_validation.message
            ));
        }
    }

    let result = ValidationResult {
        passed: violations.is_empty(),
        total_elements: input.registry.len(),
        message: if violations.is_empty() {
            format!(
                "✓ All validation rules passed! Validated {} elements, {} links",
                input.registry.len(),
                input.links.len()
            )
        } else {
            format!(
                "✗ Validation failed with {} violations:\n{}",
                violations.len(),
                violations.join("\n  - ")
            )
        },
    };

    // Serialize result to JSON
    serde_json::to_vec(&result).unwrap_or_default()
}

#[wasm_func]
pub fn hello() -> Vec<u8> {
    b"Hello from AssemblyLine WASM validator!".to_vec()
}

// ============================================================================
// Feature Model SAT Validation (WASM Export)
// ============================================================================

/// Result structure for feature model validation
#[derive(Debug, Serialize, Deserialize)]
pub struct FeatureModelValidationResult {
    pub is_consistent: bool,
    pub message: String,
    pub num_features: usize,
    pub num_clauses: usize,
    pub details: String,
}

/// Validate feature model consistency using SAT solver
///
/// This checks if the feature model has at least one valid configuration
/// by encoding all constraints (hierarchy, variability groups, requires/excludes)
/// as a SAT problem.
///
/// # Input JSON Format
/// ```json
/// {
///   "registry": { ... },
///   "root_feature_id": "ROOT"
/// }
/// ```
///
/// # Output JSON Format
/// ```json
/// {
///   "is_consistent": true,
///   "message": "Feature model is CONSISTENT",
///   "num_features": 10,
///   "num_clauses": 25,
///   "details": "..."
/// }
/// ```
#[wasm_func]
pub fn validate_feature_model_sat(input_bytes: &[u8]) -> Vec<u8> {
    #[derive(Deserialize)]
    struct Input {
        registry: Registry,
        #[serde(default = "default_root")]
        root_feature_id: String,
    }

    fn default_root() -> String {
        "ROOT".to_string()
    }

    // Parse input
    let input: Input = match serde_json::from_slice(input_bytes) {
        Ok(data) => data,
        Err(e) => {
            let error_result = FeatureModelValidationResult {
                is_consistent: false,
                message: format!("Failed to parse input: {}", e),
                num_features: 0,
                num_clauses: 0,
                details: String::new(),
            };
            return serde_json::to_vec(&error_result).unwrap_or_default();
        }
    };

    // Run feature model validation
    let validation = validate_feature_model(&input.registry, &input.root_feature_id);

    let result = FeatureModelValidationResult {
        is_consistent: validation.is_consistent,
        message: validation.message.clone(),
        num_features: validation.num_features,
        num_clauses: validation.num_clauses,
        details: if validation.is_consistent {
            format!(
                "✓ Feature model is consistent - at least one valid configuration exists\n\
                 Features: {}\n\
                 SAT variables: {}\n\
                 CNF clauses: {}",
                validation.num_features,
                validation.num_features, // approximate
                validation.num_clauses
            )
        } else {
            format!(
                "✗ Feature model is INCONSISTENT - contradictory constraints detected\n\
                 No valid configuration exists that satisfies all:\n\
                 - Hierarchy constraints (parent-child relationships)\n\
                 - Variability groups (XOR/OR groups)\n\
                 - Cross-tree constraints (requires/excludes)\n\n\
                 Features: {}\n\
                 CNF clauses: {}\n\n\
                 Recommendation: Review feature constraints for conflicts",
                validation.num_features,
                validation.num_clauses
            )
        },
    };

    serde_json::to_vec(&result).unwrap_or_default()
}

/// Validate a specific configuration against the feature model
///
/// # Input JSON Format
/// ```json
/// {
///   "registry": { ... },
///   "root_feature_id": "ROOT",
///   "selected_features": ["F1", "F2", "F3"]
/// }
/// ```
#[wasm_func]
pub fn validate_configuration_sat(input_bytes: &[u8]) -> Vec<u8> {
    #[derive(Deserialize)]
    struct Input {
        registry: Registry,
        #[serde(default = "default_root")]
        root_feature_id: String,
        selected_features: Vec<String>,
    }

    fn default_root() -> String {
        "ROOT".to_string()
    }

    // Parse input
    let input: Input = match serde_json::from_slice(input_bytes) {
        Ok(data) => data,
        Err(e) => {
            let error_result = FeatureModelValidationResult {
                is_consistent: false,
                message: format!("Failed to parse input: {}", e),
                num_features: 0,
                num_clauses: 0,
                details: String::new(),
            };
            return serde_json::to_vec(&error_result).unwrap_or_default();
        }
    };

    // Validate configuration
    let (is_valid, message) = validate_configuration(
        &input.registry,
        &input.root_feature_id,
        &input.selected_features,
    );

    let result = FeatureModelValidationResult {
        is_consistent: is_valid,
        message,
        num_features: input.selected_features.len(),
        num_clauses: 0,
        details: if is_valid {
            format!(
                "✓ Configuration is valid\n\
                 Selected features: {:?}",
                input.selected_features
            )
        } else {
            format!(
                "✗ Configuration violates feature model constraints\n\
                 Selected features: {:?}\n\n\
                 Possible issues:\n\
                 - Missing required features\n\
                 - Conflicting features (excludes constraint)\n\
                 - Violates XOR/OR group rules\n\
                 - Selected feature without parent",
                input.selected_features
            )
        },
    };

    serde_json::to_vec(&result).unwrap_or_default()
}
