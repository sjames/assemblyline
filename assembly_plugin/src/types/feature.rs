use super::core::ElementCore;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Parameter schema for a feature
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ParameterSchema {
    #[serde(rename = "type")]
    pub param_type: String,  // "Integer", "Boolean", "Enum"
    #[serde(skip_serializing_if = "Option::is_none")]
    pub range: Option<(i64, i64)>,  // For Integer type
    #[serde(skip_serializing_if = "Option::is_none")]
    pub values: Option<Vec<String>>,  // For Enum type
    #[serde(skip_serializing_if = "Option::is_none")]
    pub unit: Option<String>,
    pub default: serde_json::Value,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
}

/// Feature element - product-line variability point
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FeatureElement {
    pub id: String,
    #[serde(default)]
    pub title: String,
    #[serde(default)]
    pub tags: HashMap<String, serde_json::Value>,
    /// Parent feature ID (hierarchical structure)
    pub parent: Option<String>,
    /// Whether feature is concrete (can be selected in configs)
    #[serde(default = "default_concrete")]
    pub concrete: Option<bool>,
    /// Variability group type: "XOR", "OR", or none
    pub group: Option<String>,
    #[serde(default)]
    pub body: serde_json::Value,
    /// Parameter schemas (Phase 1 feature parameters)
    #[serde(skip_serializing_if = "Option::is_none")]
    pub parameters: Option<HashMap<String, ParameterSchema>>,
    /// Constraint expressions
    #[serde(skip_serializing_if = "Option::is_none")]
    pub constraints: Option<Vec<String>>,
    /// Required feature IDs
    #[serde(skip_serializing_if = "Option::is_none")]
    pub requires: Option<serde_json::Value>,  // Can be string or array
}

fn default_concrete() -> Option<bool> {
    Some(true) // Default from Typst: concrete: true
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum VariabilityGroup {
    Xor, // Exactly one child must be selected
    Or,  // At least one child must be selected
}

impl FeatureElement {
    /// Check if this is an abstract feature (cannot be selected)
    pub fn is_abstract(&self) -> bool {
        self.concrete == Some(false)
    }

    /// Check if this is a variability group
    pub fn is_variability_group(&self) -> bool {
        self.group.is_some()
    }

    /// Get variability group type
    pub fn group_type(&self) -> Option<VariabilityGroup> {
        self.group.as_deref().and_then(|g| match g {
            "XOR" => Some(VariabilityGroup::Xor),
            "OR" => Some(VariabilityGroup::Or),
            _ => None,
        })
    }
}

impl ElementCore for FeatureElement {
    fn id(&self) -> &str {
        &self.id
    }
    fn title(&self) -> &str {
        &self.title
    }
    fn tags(&self) -> &HashMap<String, serde_json::Value> {
        &self.tags
    }
    fn body(&self) -> &serde_json::Value {
        &self.body
    }
}
