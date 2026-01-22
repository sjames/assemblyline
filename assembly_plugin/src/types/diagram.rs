use super::core::ElementCore;
use super::sysml::{SysmlConnector, SysmlPart, SysmlPort};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Internal Block Diagram - standalone architectural view
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InternalBlockDiagramElement {
    pub id: String,
    #[serde(default)]
    pub title: String,
    #[serde(default)]
    pub tags: HashMap<String, serde_json::Value>,
    #[serde(default)]
    pub body: serde_json::Value,
}

impl InternalBlockDiagramElement {
    /// Get IBD parts (uses ibd-parts prefix instead of sysml-parts)
    pub fn parts(&self) -> Vec<SysmlPart> {
        self.tag("ibd-parts").unwrap_or_default()
    }

    /// Get IBD ports
    pub fn ports(&self) -> Vec<SysmlPort> {
        self.tag("ibd-ports").unwrap_or_default()
    }

    /// Get IBD connectors
    pub fn connectors(&self) -> Vec<SysmlConnector> {
        self.tag("ibd-connectors").unwrap_or_default()
    }

    /// Get IBD references
    pub fn references(&self) -> Vec<String> {
        self.tag("ibd-references").unwrap_or_default()
    }
}

impl ElementCore for InternalBlockDiagramElement {
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

/// Sequence diagram element
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SequenceDiagramElement {
    pub id: String,
    #[serde(default)]
    pub title: String,
    #[serde(default)]
    pub tags: HashMap<String, serde_json::Value>,
    #[serde(default)]
    pub body: serde_json::Value,
}

impl ElementCore for SequenceDiagramElement {
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

/// Implementation element
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ImplementationElement {
    pub id: String,
    #[serde(default)]
    pub title: String,
    #[serde(default)]
    pub tags: HashMap<String, serde_json::Value>,
    #[serde(default)]
    pub body: serde_json::Value,
}

impl ElementCore for ImplementationElement {
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

/// Test case element
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TestCaseElement {
    pub id: String,
    #[serde(default)]
    pub title: String,
    #[serde(default)]
    pub tags: HashMap<String, serde_json::Value>,
    #[serde(default)]
    pub body: serde_json::Value,
}

impl ElementCore for TestCaseElement {
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
