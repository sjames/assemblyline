use super::core::ElementCore;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Use case element - behavioral scenario
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UseCaseElement {
    pub id: String,
    #[serde(default)]
    pub title: String,
    #[serde(default)]
    pub tags: HashMap<String, serde_json::Value>,
    #[serde(default)]
    pub body: serde_json::Value,
}

impl UseCaseElement {
    /// Get actor from tags
    pub fn actor(&self) -> Option<String> {
        self.tag("actor")
    }

    /// Get preconditions from tags
    pub fn precondition(&self) -> Option<String> {
        self.tag("pre-condition")
    }
}

impl ElementCore for UseCaseElement {
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
