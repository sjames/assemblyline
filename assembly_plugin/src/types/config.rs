use super::core::ElementCore;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Configuration element - product configuration (feature selection)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ConfigElement {
    pub id: String,
    #[serde(default)]
    pub title: String,
    #[serde(default)]
    pub tags: HashMap<String, serde_json::Value>,
    /// Root feature ID for this configuration
    #[serde(rename = "root")]
    pub root_feature_id: String,
    /// Array of selected feature IDs
    pub selected: Vec<String>,
    #[serde(default)]
    pub body: serde_json::Value,
}

impl ConfigElement {
    /// Check if a feature is selected in this configuration
    pub fn is_feature_selected(&self, feature_id: &str) -> bool {
        self.selected.iter().any(|id| id == feature_id)
    }

    /// Get market from tags
    pub fn market(&self) -> Option<String> {
        self.tag("market")
    }

    /// Get regulations from tags
    pub fn regulations(&self) -> Option<Vec<String>> {
        self.tag("regulations")
    }
}

impl ElementCore for ConfigElement {
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
