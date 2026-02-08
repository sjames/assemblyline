/// Parameter Validation Module
/// Validates parameter bindings for configurations against feature parameter schemas

use crate::constraint_evaluator::evaluate_constraint;
use crate::constraint_parser::parse_constraint;
use crate::types::{ConfigElement, Element, FeatureElement, ParameterSchema};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Parameter validation result
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ParameterValidationResult {
    pub is_valid: bool,
    pub message: String,
    pub errors: Vec<String>,
    pub num_features_checked: usize,
    pub num_parameters_checked: usize,
}

/// Validate parameter bindings for a configuration
pub fn validate_parameter_bindings(
    registry: &HashMap<String, Element>,
    config_id: &str,
) -> ParameterValidationResult {
    let mut errors = Vec::new();
    let mut num_features_checked = 0;
    let mut num_parameters_checked = 0;

    // Find the configuration
    let config_key = format!("CONFIG:{}", config_id);
    let config = match registry.get(&config_key) {
        Some(Element::Config(cfg)) => cfg,
        _ => {
            return ParameterValidationResult {
                is_valid: false,
                message: format!("Configuration '{}' not found", config_id),
                errors: vec![format!("Configuration '{}' does not exist", config_id)],
                num_features_checked: 0,
                num_parameters_checked: 0,
            };
        }
    };

    let empty_bindings = HashMap::new();
    let bindings = config.bindings.as_ref().unwrap_or(&empty_bindings);

    // Check each selected feature
    for feature_id in &config.selected {
        // Get the feature
        let feature = match registry.get(feature_id) {
            Some(Element::Feature(f)) => f,
            _ => {
                errors.push(format!(
                    "Configuration '{}' selects non-existent feature '{}'",
                    config_id, feature_id
                ));
                continue;
            }
        };

        // Skip if feature has no parameters
        let parameters = match &feature.parameters {
            Some(params) if !params.is_empty() => params,
            _ => continue,
        };

        num_features_checked += 1;

        // Get bindings for this feature
        let empty_feature_bindings = HashMap::new();
        let feature_bindings = bindings.get(feature_id).unwrap_or(&empty_feature_bindings);

        // Check each parameter in the schema
        for (param_name, param_schema) in parameters {
            num_parameters_checked += 1;

            // Get bound value or use default
            let value = match feature_bindings.get(param_name) {
                Some(v) => v.clone(),
                None => {
                    // No binding - check if there's a default
                    if param_schema.default.is_null() {
                        errors.push(format!(
                            "Feature '{}', parameter '{}': No binding provided and no default value defined",
                            feature_id, param_name
                        ));
                        continue;
                    }
                    param_schema.default.clone()
                }
            };

            // Validate based on type
            match param_schema.param_type.as_str() {
                "Integer" => validate_integer(feature_id, param_name, &value, param_schema, &mut errors),
                "Boolean" => validate_boolean(feature_id, param_name, &value, &mut errors),
                "Enum" => validate_enum(feature_id, param_name, &value, param_schema, &mut errors),
                unknown_type => {
                    errors.push(format!(
                        "Feature '{}', parameter '{}': Unknown parameter type '{}'",
                        feature_id, param_name, unknown_type
                    ));
                }
            }
        }
    }

    // Check constraints for each selected feature
    for feature_id in &config.selected {
        let feature = match registry.get(feature_id) {
            Some(Element::Feature(f)) => f,
            _ => continue,
        };

        // Check constraints if any
        if let Some(constraints) = &feature.constraints {
            for constraint_str in constraints {
                // Parse constraint
                let expr = match parse_constraint(constraint_str) {
                    Ok(e) => e,
                    Err(e) => {
                        errors.push(format!(
                            "Feature '{}': Failed to parse constraint '{}': {}",
                            feature_id, constraint_str, e
                        ));
                        continue;
                    }
                };

                // Evaluate constraint
                match evaluate_constraint(&expr, config, registry) {
                    Ok(true) => {
                        // Constraint satisfied
                    }
                    Ok(false) => {
                        errors.push(format!(
                            "Feature '{}': Constraint '{}' violated",
                            feature_id, constraint_str
                        ));
                    }
                    Err(e) => {
                        errors.push(format!(
                            "Feature '{}': Failed to evaluate constraint '{}': {}",
                            feature_id, constraint_str, e
                        ));
                    }
                }
            }
        }
    }

    // Generate result
    let is_valid = errors.is_empty();
    let message = if is_valid {
        format!(
            "All parameter bindings and constraints are valid ({} features, {} parameters checked)",
            num_features_checked, num_parameters_checked
        )
    } else {
        format!(
            "Parameter validation failed with {} error(s)",
            errors.len()
        )
    };

    ParameterValidationResult {
        is_valid,
        message,
        errors,
        num_features_checked,
        num_parameters_checked,
    }
}

/// Validate integer parameter
fn validate_integer(
    feature_id: &str,
    param_name: &str,
    value: &serde_json::Value,
    schema: &ParameterSchema,
    errors: &mut Vec<String>,
) {
    // Check type
    let int_value = match value.as_i64() {
        Some(v) => v,
        None => {
            errors.push(format!(
                "Feature '{}', parameter '{}': Expected type Integer, got {:?}",
                feature_id, param_name, value
            ));
            return;
        }
    };

    // Check range if specified
    if let Some((min, max)) = schema.range {
        if int_value < min || int_value > max {
            errors.push(format!(
                "Feature '{}', parameter '{}': Value {} out of range [{}, {}]",
                feature_id, param_name, int_value, min, max
            ));
        }
    }
}

/// Validate boolean parameter
fn validate_boolean(
    feature_id: &str,
    param_name: &str,
    value: &serde_json::Value,
    errors: &mut Vec<String>,
) {
    if !value.is_boolean() {
        errors.push(format!(
            "Feature '{}', parameter '{}': Expected type Boolean, got {:?}",
            feature_id, param_name, value
        ));
    }
}

/// Validate enum parameter
fn validate_enum(
    feature_id: &str,
    param_name: &str,
    value: &serde_json::Value,
    schema: &ParameterSchema,
    errors: &mut Vec<String>,
) {
    // Check type (must be string)
    let str_value = match value.as_str() {
        Some(s) => s,
        None => {
            errors.push(format!(
                "Feature '{}', parameter '{}': Expected type String (for Enum), got {:?}",
                feature_id, param_name, value
            ));
            return;
        }
    };

    // Check if value is in allowed values
    if let Some(values) = &schema.values {
        let str_value_owned = str_value.to_string();
        if !values.contains(&str_value_owned) {
            errors.push(format!(
                "Feature '{}', parameter '{}': Value '{}' not in enum {:?}",
                feature_id, param_name, str_value, values
            ));
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    fn create_test_feature(id: &str, params: HashMap<String, ParameterSchema>) -> Element {
        Element::Feature(FeatureElement {
            id: id.to_string(),
            title: "Test Feature".to_string(),
            tags: HashMap::new(),
            parent: Some("ROOT".to_string()),
            concrete: Some(true),
            group: None,
            body: json!({}),
            parameters: Some(params),
            constraints: None,
            requires: None,
        })
    }

    fn create_test_config(
        id: &str,
        selected: Vec<String>,
        bindings: HashMap<String, HashMap<String, serde_json::Value>>,
    ) -> Element {
        Element::Config(ConfigElement {
            id: id.to_string(),
            title: "Test Config".to_string(),
            tags: HashMap::new(),
            root_feature_id: "ROOT".to_string(),
            selected,
            body: json!({}),
            bindings: Some(bindings),
        })
    }

    #[test]
    fn test_valid_integer_parameter() {
        let mut registry = HashMap::new();

        // Create feature with integer parameter
        let mut params = HashMap::new();
        params.insert(
            "size".to_string(),
            ParameterSchema {
                param_type: "Integer".to_string(),
                range: Some((1, 100)),
                values: None,
                unit: None,
                default: json!(50),
                description: None,
            },
        );
        registry.insert("F-TEST".to_string(), create_test_feature("F-TEST", params));

        // Create config with valid binding
        let mut bindings = HashMap::new();
        let mut feature_bindings = HashMap::new();
        feature_bindings.insert("size".to_string(), json!(75));
        bindings.insert("F-TEST".to_string(), feature_bindings);

        registry.insert(
            "CONFIG:CFG-TEST".to_string(),
            create_test_config("CFG-TEST", vec!["F-TEST".to_string()], bindings),
        );

        // Validate
        let result = validate_parameter_bindings(&registry, "CFG-TEST");

        assert!(result.is_valid, "Expected valid result, got errors: {:?}", result.errors);
        assert_eq!(result.num_features_checked, 1);
        assert_eq!(result.num_parameters_checked, 1);
    }

    #[test]
    fn test_integer_out_of_range() {
        let mut registry = HashMap::new();

        // Create feature
        let mut params = HashMap::new();
        params.insert(
            "size".to_string(),
            ParameterSchema {
                param_type: "Integer".to_string(),
                range: Some((1, 100)),
                values: None,
                unit: None,
                default: json!(50),
                description: None,
            },
        );
        registry.insert("F-TEST".to_string(), create_test_feature("F-TEST", params));

        // Create config with out-of-range value
        let mut bindings = HashMap::new();
        let mut feature_bindings = HashMap::new();
        feature_bindings.insert("size".to_string(), json!(500)); // Out of range!
        bindings.insert("F-TEST".to_string(), feature_bindings);

        registry.insert(
            "CONFIG:CFG-TEST".to_string(),
            create_test_config("CFG-TEST", vec!["F-TEST".to_string()], bindings),
        );

        // Validate
        let result = validate_parameter_bindings(&registry, "CFG-TEST");

        assert!(!result.is_valid, "Expected invalid result");
        assert_eq!(result.errors.len(), 1);
        assert!(result.errors[0].contains("out of range"));
    }

    #[test]
    fn test_valid_enum_parameter() {
        let mut registry = HashMap::new();

        // Create feature with enum parameter
        let mut params = HashMap::new();
        params.insert(
            "mode".to_string(),
            ParameterSchema {
                param_type: "Enum".to_string(),
                range: None,
                values: Some(vec!["debug".to_string(), "info".to_string(), "error".to_string()]),
                unit: None,
                default: json!("info"),
                description: None,
            },
        );
        registry.insert("F-TEST".to_string(), create_test_feature("F-TEST", params));

        // Create config with valid enum value
        let mut bindings = HashMap::new();
        let mut feature_bindings = HashMap::new();
        feature_bindings.insert("mode".to_string(), json!("debug"));
        bindings.insert("F-TEST".to_string(), feature_bindings);

        registry.insert(
            "CONFIG:CFG-TEST".to_string(),
            create_test_config("CFG-TEST", vec!["F-TEST".to_string()], bindings),
        );

        // Validate
        let result = validate_parameter_bindings(&registry, "CFG-TEST");

        assert!(result.is_valid, "Expected valid result, got errors: {:?}", result.errors);
    }

    #[test]
    fn test_invalid_enum_value() {
        let mut registry = HashMap::new();

        // Create feature
        let mut params = HashMap::new();
        params.insert(
            "mode".to_string(),
            ParameterSchema {
                param_type: "Enum".to_string(),
                range: None,
                values: Some(vec!["debug".to_string(), "info".to_string()]),
                unit: None,
                default: json!("info"),
                description: None,
            },
        );
        registry.insert("F-TEST".to_string(), create_test_feature("F-TEST", params));

        // Create config with invalid enum value
        let mut bindings = HashMap::new();
        let mut feature_bindings = HashMap::new();
        feature_bindings.insert("mode".to_string(), json!("INVALID")); // Not in enum!
        bindings.insert("F-TEST".to_string(), feature_bindings);

        registry.insert(
            "CONFIG:CFG-TEST".to_string(),
            create_test_config("CFG-TEST", vec!["F-TEST".to_string()], bindings),
        );

        // Validate
        let result = validate_parameter_bindings(&registry, "CFG-TEST");

        assert!(!result.is_valid);
        assert_eq!(result.errors.len(), 1);
        assert!(result.errors[0].contains("not in enum"));
    }

    #[test]
    fn test_default_value_used() {
        let mut registry = HashMap::new();

        // Create feature
        let mut params = HashMap::new();
        params.insert(
            "size".to_string(),
            ParameterSchema {
                param_type: "Integer".to_string(),
                range: Some((1, 100)),
                values: None,
                unit: None,
                default: json!(50),
                description: None,
            },
        );
        registry.insert("F-TEST".to_string(), create_test_feature("F-TEST", params));

        // Create config with NO bindings (should use default)
        registry.insert(
            "CONFIG:CFG-TEST".to_string(),
            create_test_config("CFG-TEST", vec!["F-TEST".to_string()], HashMap::new()),
        );

        // Validate
        let result = validate_parameter_bindings(&registry, "CFG-TEST");

        assert!(result.is_valid, "Expected valid result when using defaults");
    }
}
