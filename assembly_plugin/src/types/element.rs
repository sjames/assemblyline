use super::block::BlockDefinitionElement;
use super::config::ConfigElement;
use super::core::ElementCore;
use super::diagram::{
    ImplementationElement, InternalBlockDiagramElement, SequenceDiagramElement, TestCaseElement,
};
use super::feature::FeatureElement;
use super::requirement::ReqElement;
use super::use_case::UseCaseElement;
use serde::{Deserialize, Serialize};

/// Top-level element enum - represents all AssemblyLine element types
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum Element {
    Feature(FeatureElement),
    Req(ReqElement),
    UseCase(UseCaseElement),
    Config(ConfigElement),
    BlockDefinition(BlockDefinitionElement),
    InternalBlockDiagram(InternalBlockDiagramElement),
    SequenceDiagram(SequenceDiagramElement),
    Implementation(ImplementationElement),
    TestCase(TestCaseElement),
}

impl Element {
    /// Get element ID (convenience)
    pub fn id(&self) -> &str {
        match self {
            Element::Feature(e) => e.id(),
            Element::Req(e) => e.id(),
            Element::UseCase(e) => e.id(),
            Element::Config(e) => e.id(),
            Element::BlockDefinition(e) => e.id(),
            Element::InternalBlockDiagram(e) => e.id(),
            Element::SequenceDiagram(e) => e.id(),
            Element::Implementation(e) => e.id(),
            Element::TestCase(e) => e.id(),
        }
    }

    /// Get element title (convenience)
    pub fn title(&self) -> &str {
        match self {
            Element::Feature(e) => e.title(),
            Element::Req(e) => e.title(),
            Element::UseCase(e) => e.title(),
            Element::Config(e) => e.title(),
            Element::BlockDefinition(e) => e.title(),
            Element::InternalBlockDiagram(e) => e.title(),
            Element::SequenceDiagram(e) => e.title(),
            Element::Implementation(e) => e.title(),
            Element::TestCase(e) => e.title(),
        }
    }

    /// Get element type as string
    pub fn type_name(&self) -> &'static str {
        match self {
            Element::Feature(_) => "feature",
            Element::Req(_) => "req",
            Element::UseCase(_) => "use_case",
            Element::Config(_) => "config",
            Element::BlockDefinition(_) => "block_definition",
            Element::InternalBlockDiagram(_) => "internal_block_diagram",
            Element::SequenceDiagram(_) => "sequence_diagram",
            Element::Implementation(_) => "implementation",
            Element::TestCase(_) => "test_case",
        }
    }

    /// Try to get as feature
    pub fn as_feature(&self) -> Option<&FeatureElement> {
        if let Element::Feature(f) = self {
            Some(f)
        } else {
            None
        }
    }

    /// Try to get as requirement
    pub fn as_req(&self) -> Option<&ReqElement> {
        if let Element::Req(r) = self {
            Some(r)
        } else {
            None
        }
    }

    /// Try to get as use case
    pub fn as_use_case(&self) -> Option<&UseCaseElement> {
        if let Element::UseCase(u) = self {
            Some(u)
        } else {
            None
        }
    }

    /// Try to get as configuration
    pub fn as_config(&self) -> Option<&ConfigElement> {
        if let Element::Config(c) = self {
            Some(c)
        } else {
            None
        }
    }

    /// Try to get as block definition
    pub fn as_block_definition(&self) -> Option<&BlockDefinitionElement> {
        if let Element::BlockDefinition(b) = self {
            Some(b)
        } else {
            None
        }
    }

    /// Try to get as internal block diagram
    pub fn as_internal_block_diagram(&self) -> Option<&InternalBlockDiagramElement> {
        if let Element::InternalBlockDiagram(i) = self {
            Some(i)
        } else {
            None
        }
    }

    /// Try to get as sequence diagram
    pub fn as_sequence_diagram(&self) -> Option<&SequenceDiagramElement> {
        if let Element::SequenceDiagram(s) = self {
            Some(s)
        } else {
            None
        }
    }

    /// Try to get as implementation
    pub fn as_implementation(&self) -> Option<&ImplementationElement> {
        if let Element::Implementation(i) = self {
            Some(i)
        } else {
            None
        }
    }

    /// Try to get as test case
    pub fn as_test_case(&self) -> Option<&TestCaseElement> {
        if let Element::TestCase(t) = self {
            Some(t)
        } else {
            None
        }
    }
}
