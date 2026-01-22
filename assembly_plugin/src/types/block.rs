use super::core::ElementCore;
use super::sysml::{SysmlConnector, SysmlOperation, SysmlPart, SysmlPort, SysmlProperty};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// SysML Block Definition - system component with full SysML semantics
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BlockDefinitionElement {
    pub id: String,
    #[serde(default)]
    pub title: String,
    #[serde(default)]
    pub tags: HashMap<String, serde_json::Value>,
    #[serde(default)]
    pub body: serde_json::Value,
}

impl BlockDefinitionElement {
    /// Get typed SysML properties
    pub fn properties(&self) -> Vec<SysmlProperty> {
        self.tag("sysml-properties").unwrap_or_default()
    }

    /// Get typed SysML operations
    pub fn operations(&self) -> Vec<SysmlOperation> {
        self.tag("sysml-operations").unwrap_or_default()
    }

    /// Get typed SysML ports
    pub fn ports(&self) -> Vec<SysmlPort> {
        self.tag("sysml-ports").unwrap_or_default()
    }

    /// Get typed SysML parts (composition)
    pub fn parts(&self) -> Vec<SysmlPart> {
        self.tag("sysml-parts").unwrap_or_default()
    }

    /// Get typed SysML connectors
    pub fn connectors(&self) -> Vec<SysmlConnector> {
        self.tag("sysml-connectors").unwrap_or_default()
    }

    /// Get SysML references (associations)
    pub fn references(&self) -> Vec<String> {
        self.tag("sysml-references").unwrap_or_default()
    }

    /// Get SysML constraints
    pub fn constraints(&self) -> Vec<String> {
        self.tag("sysml-constraints").unwrap_or_default()
    }

    /// Get stereotype from tags
    pub fn stereotype(&self) -> Option<String> {
        self.tag("stereotype")
    }

    /// Find a port by name
    pub fn find_port(&self, name: &str) -> Option<SysmlPort> {
        self.ports().into_iter().find(|p| p.name == name)
    }

    /// Find a part by name
    pub fn find_part(&self, name: &str) -> Option<SysmlPart> {
        self.parts().into_iter().find(|p| p.name == name)
    }
}

impl ElementCore for BlockDefinitionElement {
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
