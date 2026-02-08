/// Constraint Evaluator Module
/// Evaluates parsed constraint expressions against actual parameter values

use crate::constraint_parser::{ArithOp, CompOp, Expr};
use crate::types::{ConfigElement, Element, FeatureElement};
use std::collections::HashMap;

/// Value type for evaluation
#[derive(Debug, Clone, PartialEq)]
pub enum Value {
    Int(i64),
    Bool(bool),
    String(String),
}

impl Value {
    fn as_int(&self) -> Result<i64, String> {
        match self {
            Value::Int(n) => Ok(*n),
            _ => Err(format!("Expected integer, got {:?}", self)),
        }
    }

    fn as_bool(&self) -> Result<bool, String> {
        match self {
            Value::Bool(b) => Ok(*b),
            _ => Err(format!("Expected boolean, got {:?}", self)),
        }
    }

    fn as_string(&self) -> Result<String, String> {
        match self {
            Value::String(s) => Ok(s.clone()),
            _ => Err(format!("Expected string, got {:?}", self)),
        }
    }
}

/// Evaluate a constraint expression
pub fn evaluate_constraint(
    expr: &Expr,
    config: &ConfigElement,
    registry: &HashMap<String, Element>,
) -> Result<bool, String> {
    let value = evaluate_expr(expr, config, registry)?;
    value.as_bool()
}

/// Evaluate an expression to a value
fn evaluate_expr(
    expr: &Expr,
    config: &ConfigElement,
    registry: &HashMap<String, Element>,
) -> Result<Value, String> {
    match expr {
        Expr::IntLiteral(n) => Ok(Value::Int(*n)),
        Expr::BoolLiteral(b) => Ok(Value::Bool(*b)),
        Expr::StringLiteral(s) => Ok(Value::String(s.clone())),

        Expr::ParamRef {
            feature_id,
            param_name,
        } => {
            // Get the parameter value from config bindings or default
            let feature = match registry.get(feature_id) {
                Some(Element::Feature(f)) => f,
                _ => return Err(format!("Feature '{}' not found", feature_id)),
            };

            let param_schema = feature
                .parameters
                .as_ref()
                .and_then(|params| params.get(param_name))
                .ok_or_else(|| {
                    format!(
                        "Parameter '{}' not found in feature '{}'",
                        param_name, feature_id
                    )
                })?;

            // Get bound value or default
            let json_value = config
                .bindings
                .as_ref()
                .and_then(|bindings| bindings.get(feature_id))
                .and_then(|feature_bindings| feature_bindings.get(param_name))
                .unwrap_or(&param_schema.default);

            // Convert JSON value to our Value type
            if let Some(n) = json_value.as_i64() {
                Ok(Value::Int(n))
            } else if let Some(b) = json_value.as_bool() {
                Ok(Value::Bool(b))
            } else if let Some(s) = json_value.as_str() {
                Ok(Value::String(s.to_string()))
            } else {
                Err(format!("Cannot convert parameter value: {:?}", json_value))
            }
        }

        Expr::FeatureSelected(feature_id) => {
            let is_selected = config.selected.contains(feature_id);
            Ok(Value::Bool(is_selected))
        }

        Expr::Comparison { op, left, right } => {
            let left_val = evaluate_expr(left, config, registry)?;
            let right_val = evaluate_expr(right, config, registry)?;

            let result = match (left_val, right_val) {
                (Value::Int(l), Value::Int(r)) => match op {
                    CompOp::Lt => l < r,
                    CompOp::Gt => l > r,
                    CompOp::Le => l <= r,
                    CompOp::Ge => l >= r,
                    CompOp::Eq => l == r,
                    CompOp::Ne => l != r,
                },
                (Value::Bool(l), Value::Bool(r)) => match op {
                    CompOp::Eq => l == r,
                    CompOp::Ne => l != r,
                    _ => return Err("Comparison operator not supported for booleans".to_string()),
                },
                (Value::String(l), Value::String(r)) => match op {
                    CompOp::Eq => l == r,
                    CompOp::Ne => l != r,
                    _ => return Err("Comparison operator not supported for strings".to_string()),
                },
                _ => return Err("Type mismatch in comparison".to_string()),
            };

            Ok(Value::Bool(result))
        }

        Expr::Implication { left, right } => {
            let left_val = evaluate_expr(left, config, registry)?.as_bool()?;
            if !left_val {
                // Implication is true if antecedent is false
                Ok(Value::Bool(true))
            } else {
                // Evaluate consequent
                let right_val = evaluate_expr(right, config, registry)?.as_bool()?;
                Ok(Value::Bool(right_val))
            }
        }

        Expr::And { left, right } => {
            let left_val = evaluate_expr(left, config, registry)?.as_bool()?;
            let right_val = evaluate_expr(right, config, registry)?.as_bool()?;
            Ok(Value::Bool(left_val && right_val))
        }

        Expr::Or { left, right } => {
            let left_val = evaluate_expr(left, config, registry)?.as_bool()?;
            let right_val = evaluate_expr(right, config, registry)?.as_bool()?;
            Ok(Value::Bool(left_val || right_val))
        }

        Expr::Not(inner) => {
            let val = evaluate_expr(inner, config, registry)?.as_bool()?;
            Ok(Value::Bool(!val))
        }

        Expr::Arithmetic { op, left, right } => {
            let left_val = evaluate_expr(left, config, registry)?.as_int()?;
            let right_val = evaluate_expr(right, config, registry)?.as_int()?;

            let result = match op {
                ArithOp::Add => left_val + right_val,
                ArithOp::Sub => left_val - right_val,
                ArithOp::Mul => left_val * right_val,
                ArithOp::Div => {
                    if right_val == 0 {
                        return Err("Division by zero".to_string());
                    }
                    left_val / right_val
                }
            };

            Ok(Value::Int(result))
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::constraint_parser::parse_constraint;
    use crate::types::ParameterSchema;
    use serde_json::json;

    fn create_test_config(
        selected: Vec<String>,
        bindings: HashMap<String, HashMap<String, serde_json::Value>>,
    ) -> ConfigElement {
        ConfigElement {
            id: "TEST-CFG".to_string(),
            title: "Test Config".to_string(),
            tags: HashMap::new(),
            root_feature_id: "ROOT".to_string(),
            selected,
            body: json!({}),
            bindings: Some(bindings),
        }
    }

    fn create_test_feature(
        id: &str,
        params: HashMap<String, ParameterSchema>,
    ) -> (String, Element) {
        (
            id.to_string(),
            Element::Feature(FeatureElement {
                id: id.to_string(),
                title: "Test".to_string(),
                tags: HashMap::new(),
                parent: None,
                concrete: Some(true),
                group: None,
                body: json!({}),
                parameters: Some(params),
                constraints: None,
                requires: None,
            }),
        )
    }

    #[test]
    fn test_evaluate_simple_comparison() {
        let mut registry = HashMap::new();
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
        registry.insert("F-TEST".to_string(), Element::Feature(FeatureElement {
            id: "F-TEST".to_string(),
            title: "Test".to_string(),
            tags: HashMap::new(),
            parent: None,
            concrete: Some(true),
            group: None,
            body: json!({}),
            parameters: Some(params),
            constraints: None,
            requires: None,
        }));

        let mut bindings = HashMap::new();
        let mut feature_bindings = HashMap::new();
        feature_bindings.insert("size".to_string(), json!(75));
        bindings.insert("F-TEST".to_string(), feature_bindings);

        let config = create_test_config(vec!["F-TEST".to_string()], bindings);

        // Test: F-TEST.size >= 50
        let expr = parse_constraint("F-TEST.size >= 50").unwrap();
        let result = evaluate_constraint(&expr, &config, &registry).unwrap();
        assert!(result, "Expected 75 >= 50 to be true");

        // Test: F-TEST.size < 50
        let expr = parse_constraint("F-TEST.size < 50").unwrap();
        let result = evaluate_constraint(&expr, &config, &registry).unwrap();
        assert!(!result, "Expected 75 < 50 to be false");
    }

    #[test]
    fn test_evaluate_implication() {
        let mut registry = HashMap::new();
        let mut params = HashMap::new();
        params.insert(
            "enabled".to_string(),
            ParameterSchema {
                param_type: "Boolean".to_string(),
                range: None,
                values: None,
                unit: None,
                default: json!(false),
                description: None,
            },
        );
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
        registry.insert("F-TEST".to_string(), Element::Feature(FeatureElement {
            id: "F-TEST".to_string(),
            title: "Test".to_string(),
            tags: HashMap::new(),
            parent: None,
            concrete: Some(true),
            group: None,
            body: json!({}),
            parameters: Some(params),
            constraints: None,
            requires: None,
        }));

        // Test: enabled => size >= 50 (enabled=true, size=75)
        let mut bindings = HashMap::new();
        let mut feature_bindings = HashMap::new();
        feature_bindings.insert("enabled".to_string(), json!(true));
        feature_bindings.insert("size".to_string(), json!(75));
        bindings.insert("F-TEST".to_string(), feature_bindings);
        let config = create_test_config(vec!["F-TEST".to_string()], bindings);

        let expr = parse_constraint("F-TEST.enabled => F-TEST.size >= 50").unwrap();
        let result = evaluate_constraint(&expr, &config, &registry).unwrap();
        assert!(result, "Expected implication to be true");
    }

    #[test]
    fn test_evaluate_feature_selected() {
        let registry = HashMap::new();
        let config = create_test_config(vec!["F-CACHE".to_string()], HashMap::new());

        let expr = parse_constraint("F-CACHE is selected").unwrap();
        let result = evaluate_constraint(&expr, &config, &registry).unwrap();
        assert!(result, "Expected F-CACHE to be selected");

        let expr = parse_constraint("F-OTHER is selected").unwrap();
        let result = evaluate_constraint(&expr, &config, &registry).unwrap();
        assert!(!result, "Expected F-OTHER to not be selected");
    }

    #[test]
    fn test_evaluate_arithmetic() {
        let mut registry = HashMap::new();
        let mut params = HashMap::new();
        params.insert(
            "size".to_string(),
            ParameterSchema {
                param_type: "Integer".to_string(),
                range: Some((1, 1000)),
                values: None,
                unit: None,
                default: json!(100),
                description: None,
            },
        );
        registry.insert("F-TEST".to_string(), Element::Feature(FeatureElement {
            id: "F-TEST".to_string(),
            title: "Test".to_string(),
            tags: HashMap::new(),
            parent: None,
            concrete: Some(true),
            group: None,
            body: json!({}),
            parameters: Some(params),
            constraints: None,
            requires: None,
        }));

        let mut bindings = HashMap::new();
        let mut feature_bindings = HashMap::new();
        feature_bindings.insert("size".to_string(), json!(100));
        bindings.insert("F-TEST".to_string(), feature_bindings);
        let config = create_test_config(vec!["F-TEST".to_string()], bindings);

        // Test: F-TEST.size + 50 >= 140
        let expr = parse_constraint("F-TEST.size + 50 >= 140").unwrap();
        let result = evaluate_constraint(&expr, &config, &registry).unwrap();
        assert!(result, "Expected 100 + 50 >= 140 to be true");
    }
}
