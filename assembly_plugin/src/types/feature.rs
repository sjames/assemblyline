use super::core::ElementCore;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

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
