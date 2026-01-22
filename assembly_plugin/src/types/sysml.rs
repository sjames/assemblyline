use serde::{Deserialize, Serialize};

/// Typed SysML property
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SysmlProperty {
    pub name: String,
    #[serde(rename = "type")]
    pub property_type: String,
    #[serde(default)]
    pub default: String,
    #[serde(default)]
    pub unit: String,
}

/// Typed SysML operation
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SysmlOperation {
    pub name: String,
    pub params: String,
    pub returns: String,
}

/// Typed SysML port
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SysmlPort {
    pub name: String,
    pub direction: String, // "in", "out", "inout"
    pub protocol: String,
}

/// Typed SysML part (composition)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SysmlPart {
    pub name: String,
    #[serde(rename = "type")]
    pub part_type: String, // Block type ID
    pub multiplicity: String,
}

/// Typed SysML connector
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SysmlConnector {
    pub from: String,
    pub to: String,
    pub flow: String,
}
