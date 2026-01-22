use super::core::ElementCore;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Requirement element
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReqElement {
    pub id: String,
    #[serde(default)]
    pub title: String,
    #[serde(default)]
    pub tags: HashMap<String, serde_json::Value>,
    /// Optional parent (manual specification, overrides feature nesting)
    pub parent: Option<String>,
    /// Requirement this derives from (refinement relationship)
    #[serde(default)]
    pub derives_from: Option<String>,
    #[serde(default)]
    pub body: serde_json::Value,
}

impl ReqElement {
    /// Get requirement type from tags (functional, non-functional, etc.)
    pub fn req_type(&self) -> Option<String> {
        self.tag("type")
    }

    /// Get safety level from tags (QM, ASIL-A, etc.)
    pub fn safety_level(&self) -> Option<String> {
        self.tag("safety")
    }

    /// Get security properties from tags
    pub fn security_properties(&self) -> Option<Vec<String>> {
        self.tag("security")
    }
}

impl ElementCore for ReqElement {
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
