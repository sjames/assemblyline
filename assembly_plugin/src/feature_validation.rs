/// Feature Model SAT-based Validation
///
/// This module validates feature models for consistency using a SAT solver.
/// It encodes the feature model constraints (hierarchy, variability groups,
/// cross-tree constraints) as CNF and checks if there exists at least one
/// valid configuration.

use crate::sat_solver::{is_sat, Clause, CNF};
use crate::types::{Element, FeatureElement, VariabilityGroup};
use std::collections::HashMap;

/// Result of feature model validation
#[derive(Debug, Clone)]
pub struct FeatureModelValidation {
    pub is_consistent: bool,
    pub message: String,
    pub num_features: usize,
    pub num_clauses: usize,
}

/// CNF Encoder for feature models
struct CnfEncoder {
    /// Map from feature ID to SAT variable number
    var_map: HashMap<String, i32>,
    /// Next available variable number
    next_var: i32,
    /// Accumulated CNF clauses
    clauses: CNF,
}

impl CnfEncoder {
    fn new() -> Self {
        CnfEncoder {
            var_map: HashMap::new(),
            next_var: 1,
            clauses: Vec::new(),
        }
    }

    /// Get or create a SAT variable for a feature ID
    fn get_or_create_var(&mut self, feature_id: &str) -> i32 {
        if let Some(&var) = self.var_map.get(feature_id) {
            var
        } else {
            let var = self.next_var;
            self.var_map.insert(feature_id.to_string(), var);
            self.next_var += 1;
            var
        }
    }

    /// Add a clause to the CNF
    fn add_clause(&mut self, clause: Clause) {
        if !clause.is_empty() {
            self.clauses.push(clause);
        }
    }

    /// Encode a single feature and its constraints
    fn encode_feature(
        &mut self,
        feature: &FeatureElement,
        parent_var: Option<i32>,
        all_features: &HashMap<String, &FeatureElement>,
    ) {
        let feature_var = self.get_or_create_var(&feature.id);

        // Root feature is always selected
        if parent_var.is_none() {
            self.add_clause(vec![feature_var]);
        }

        // Handle parent-child relationship
        if let Some(parent) = parent_var {
            // Check if this feature is mandatory
            // A feature is mandatory if it's the only child or explicitly marked
            let is_mandatory = feature.is_mandatory(all_features);

            if is_mandatory {
                // Mandatory: C <=> P (child if and only if parent)
                // (-C | P) AND (-P | C)
                self.add_clause(vec![-feature_var, parent]);
                self.add_clause(vec![-parent, feature_var]);
            } else {
                // Optional: C => P (child implies parent)
                // -C | P
                self.add_clause(vec![-feature_var, parent]);
            }
        }

        // Handle requires constraints from tags
        if let Some(requires_val) = feature.tags.get("requires") {
            let required_ids = self.parse_string_or_array(requires_val);
            for required_id in required_ids {
                let required_var = self.get_or_create_var(&required_id);
                // A requires B: -A | B
                self.add_clause(vec![-feature_var, required_var]);
            }
        }

        // Handle excludes constraints from tags
        if let Some(excludes_val) = feature.tags.get("excludes") {
            let excluded_ids = self.parse_string_or_array(excludes_val);
            for excluded_id in excluded_ids {
                let excluded_var = self.get_or_create_var(&excluded_id);
                // A excludes B: -A | -B
                self.add_clause(vec![-feature_var, -excluded_var]);
            }
        }

        // Find all children of this feature
        let children: Vec<&FeatureElement> = all_features
            .values()
            .filter(|f| f.parent.as_deref() == Some(&feature.id))
            .copied()
            .collect();

        // Handle variability group constraints
        if !children.is_empty() {
            match feature.group_type() {
                Some(VariabilityGroup::Or) => {
                    // OR group: if parent selected, at least one child must be selected
                    // P => (C1 | C2 | ... | Cn)
                    // -P | C1 | C2 | ... | Cn
                    let mut or_clause = vec![-feature_var];
                    for child in &children {
                        let child_var = self.get_or_create_var(&child.id);
                        or_clause.push(child_var);
                    }
                    self.add_clause(or_clause);
                }
                Some(VariabilityGroup::Xor) => {
                    // XOR group: if parent selected, exactly one child must be selected

                    // At least one: -P | C1 | C2 | ... | Cn
                    let mut at_least_one = vec![-feature_var];
                    let child_vars: Vec<i32> = children
                        .iter()
                        .map(|c| self.get_or_create_var(&c.id))
                        .collect();

                    for &child_var in &child_vars {
                        at_least_one.push(child_var);
                    }
                    self.add_clause(at_least_one);

                    // At most one: pairwise exclusions
                    // For each pair (Ci, Cj), add: -Ci | -Cj
                    for i in 0..child_vars.len() {
                        for j in (i + 1)..child_vars.len() {
                            self.add_clause(vec![-child_vars[i], -child_vars[j]]);
                        }
                    }
                }
                None => {
                    // No group constraint - children are independent
                }
            }
        }
    }

    /// Parse a JSON value as either a string or array of strings
    fn parse_string_or_array(&self, value: &serde_json::Value) -> Vec<String> {
        match value {
            serde_json::Value::String(s) => vec![s.clone()],
            serde_json::Value::Array(arr) => arr
                .iter()
                .filter_map(|v| v.as_str().map(|s| s.to_string()))
                .collect(),
            _ => Vec::new(),
        }
    }

    /// Encode the entire feature model
    fn encode(
        &mut self,
        features: &HashMap<String, &FeatureElement>,
        root_id: &str,
    ) {
        // Find root feature
        if let Some(&root) = features.get(root_id) {
            // Encode root and recursively encode children
            self.encode_feature(root, None, features);

            // Encode all other features in a second pass (to handle cross-tree constraints)
            for feature in features.values() {
                if feature.id != root_id {
                    let parent_var = feature
                        .parent
                        .as_ref()
                        .map(|pid| self.get_or_create_var(pid));
                    self.encode_feature(feature, parent_var, features);
                }
            }
        }
    }

    /// Get the final CNF and number of variables
    fn finalize(self) -> (CNF, usize) {
        let num_vars = (self.next_var - 1) as usize;
        (self.clauses, num_vars)
    }
}

/// Helper trait to determine if a feature is mandatory
trait FeatureMandatory {
    fn is_mandatory(&self, all_features: &HashMap<String, &FeatureElement>) -> bool;
}

impl FeatureMandatory for FeatureElement {
    fn is_mandatory(&self, all_features: &HashMap<String, &FeatureElement>) -> bool {
        // Check if feature has "mandatory: true" in tags
        if let Some(mandatory_val) = self.tags.get("mandatory") {
            if let Some(b) = mandatory_val.as_bool() {
                return b;
            }
        }

        // Check if parent has a variability group
        if let Some(parent_id) = &self.parent {
            if let Some(&parent) = all_features.get(parent_id) {
                // If parent has a group, children are not mandatory by default
                if parent.is_variability_group() {
                    return false;
                }
                // Otherwise, check if this is the only child (implicit mandatory)
                let sibling_count = all_features
                    .values()
                    .filter(|f| f.parent.as_deref() == Some(parent_id.as_str()))
                    .count();
                return sibling_count == 1;
            }
        }

        false
    }
}

/// Validate a feature model for consistency
///
/// Returns true if the feature model is consistent (has at least one valid configuration)
pub fn validate_feature_model(
    registry: &HashMap<String, Element>,
    root_id: &str,
) -> FeatureModelValidation {
    // Extract all features from registry
    let mut features: HashMap<String, &FeatureElement> = HashMap::new();
    for element in registry.values() {
        if let Element::Feature(feature) = element {
            features.insert(feature.id.clone(), feature);
        }
    }

    if features.is_empty() {
        return FeatureModelValidation {
            is_consistent: true,
            message: "No features to validate".to_string(),
            num_features: 0,
            num_clauses: 0,
        };
    }

    // Check if root exists
    if !features.contains_key(root_id) {
        return FeatureModelValidation {
            is_consistent: false,
            message: format!("Root feature '{}' not found in registry", root_id),
            num_features: features.len(),
            num_clauses: 0,
        };
    }

    // Encode feature model as CNF
    let mut encoder = CnfEncoder::new();
    encoder.encode(&features, root_id);
    let (cnf, num_vars) = encoder.finalize();

    // Solve using SAT solver
    let is_consistent = if cnf.is_empty() {
        true
    } else {
        is_sat(&cnf, num_vars)
    };

    FeatureModelValidation {
        is_consistent,
        message: if is_consistent {
            format!(
                "Feature model is CONSISTENT ({} features, {} variables, {} clauses)",
                features.len(),
                num_vars,
                cnf.len()
            )
        } else {
            format!(
                "Feature model is INCONSISTENT - no valid configuration exists ({} features, {} variables, {} clauses)",
                features.len(),
                num_vars,
                cnf.len()
            )
        },
        num_features: features.len(),
        num_clauses: cnf.len(),
    }
}

/// Validate a specific configuration against the feature model
///
/// Returns true if the configuration is valid (respects all constraints)
pub fn validate_configuration(
    registry: &HashMap<String, Element>,
    root_id: &str,
    selected_features: &[String],
) -> (bool, String) {
    // Extract all features
    let mut features: HashMap<String, &FeatureElement> = HashMap::new();
    for element in registry.values() {
        if let Element::Feature(feature) = element {
            features.insert(feature.id.clone(), feature);
        }
    }

    // Create encoder and encode feature model
    let mut encoder = CnfEncoder::new();
    encoder.encode(&features, root_id);

    // Add constraints for selected features
    for feature_id in selected_features {
        let var = encoder.get_or_create_var(feature_id);
        encoder.add_clause(vec![var]);
    }

    // Get final CNF and num_vars
    let (cnf, num_vars) = encoder.finalize();

    // Check if configuration is valid
    let is_valid = is_sat(&cnf, num_vars);

    let message = if is_valid {
        format!(
            "Configuration is VALID ({} features selected)",
            selected_features.len()
        )
    } else {
        format!(
            "Configuration is INVALID - violates feature model constraints ({} features selected)",
            selected_features.len()
        )
    };

    (is_valid, message)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::types::Element;

    fn create_test_feature(
        id: &str,
        parent: Option<&str>,
        group: Option<&str>,
        concrete: Option<bool>,
    ) -> FeatureElement {
        FeatureElement {
            id: id.to_string(),
            title: id.to_string(),
            tags: HashMap::new(),
            parent: parent.map(|s| s.to_string()),
            concrete,
            group: group.map(|s| s.to_string()),
            body: serde_json::Value::Null,
            parameters: None,
            constraints: None,
            requires: None,
        }
    }

    #[test]
    fn test_simple_valid_model() {
        let mut registry = HashMap::new();
        registry.insert(
            "ROOT".to_string(),
            Element::Feature(create_test_feature("ROOT", None, None, Some(true))),
        );
        registry.insert(
            "F1".to_string(),
            Element::Feature(create_test_feature("F1", Some("ROOT"), None, Some(true))),
        );

        let result = validate_feature_model(&registry, "ROOT");
        assert!(result.is_consistent);
    }

    #[test]
    fn test_xor_group() {
        let mut registry = HashMap::new();
        registry.insert(
            "ROOT".to_string(),
            Element::Feature(create_test_feature("ROOT", None, Some("XOR"), Some(true))),
        );
        registry.insert(
            "F1".to_string(),
            Element::Feature(create_test_feature("F1", Some("ROOT"), None, Some(true))),
        );
        registry.insert(
            "F2".to_string(),
            Element::Feature(create_test_feature("F2", Some("ROOT"), None, Some(true))),
        );

        let result = validate_feature_model(&registry, "ROOT");
        assert!(result.is_consistent);
        assert!(result.num_clauses > 0);
    }

    #[test]
    fn test_or_group() {
        let mut registry = HashMap::new();
        registry.insert(
            "ROOT".to_string(),
            Element::Feature(create_test_feature("ROOT", None, Some("OR"), Some(true))),
        );
        registry.insert(
            "F1".to_string(),
            Element::Feature(create_test_feature("F1", Some("ROOT"), None, Some(true))),
        );
        registry.insert(
            "F2".to_string(),
            Element::Feature(create_test_feature("F2", Some("ROOT"), None, Some(true))),
        );

        let result = validate_feature_model(&registry, "ROOT");
        assert!(result.is_consistent);
    }

    #[test]
    fn test_conflicting_requires_excludes() {
        let mut registry = HashMap::new();

        let root = create_test_feature("ROOT", None, None, Some(true));
        registry.insert("ROOT".to_string(), Element::Feature(root.clone()));

        // F1 requires F2
        let mut f1 = create_test_feature("F1", Some("ROOT"), None, Some(true));
        f1.tags.insert(
            "requires".to_string(),
            serde_json::Value::String("F2".to_string()),
        );
        f1.tags.insert(
            "mandatory".to_string(),
            serde_json::Value::Bool(true),
        );
        registry.insert("F1".to_string(), Element::Feature(f1));

        // F2 excludes F1
        let mut f2 = create_test_feature("F2", Some("ROOT"), None, Some(true));
        f2.tags.insert(
            "excludes".to_string(),
            serde_json::Value::String("F1".to_string()),
        );
        registry.insert("F2".to_string(), Element::Feature(f2));

        let result = validate_feature_model(&registry, "ROOT");
        // This should be inconsistent: F1 is mandatory (selected with ROOT),
        // F1 requires F2, but F2 excludes F1
        assert!(!result.is_consistent);
    }
}
