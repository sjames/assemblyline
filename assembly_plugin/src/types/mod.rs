// Module declarations
pub mod block;
pub mod config;
pub mod core;
pub mod diagram;
pub mod element;
pub mod feature;
pub mod requirement;
pub mod sysml;
pub mod use_case;

// Re-exports for convenient access
pub use block::BlockDefinitionElement;
pub use config::ConfigElement;
pub use core::ElementCore;
pub use diagram::{
    ImplementationElement, InternalBlockDiagramElement, SequenceDiagramElement, TestCaseElement,
};
pub use element::Element;
pub use feature::{FeatureElement, ParameterSchema, VariabilityGroup};
pub use requirement::ReqElement;
pub use sysml::{SysmlConnector, SysmlOperation, SysmlPart, SysmlPort, SysmlProperty};
pub use use_case::UseCaseElement;
