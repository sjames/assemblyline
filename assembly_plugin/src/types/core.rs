use serde::de::DeserializeOwned;
use std::collections::HashMap;

/// Common operations for all element types
pub trait ElementCore {
    fn id(&self) -> &str;
    fn title(&self) -> &str;
    fn tags(&self) -> &HashMap<String, serde_json::Value>;
    fn body(&self) -> &serde_json::Value;

    /// Get a typed tag value by deserializing from the tags HashMap
    fn tag<T: DeserializeOwned>(&self, key: &str) -> Option<T> {
        self.tags()
            .get(key)
            .and_then(|v| serde_json::from_value(v.clone()).ok())
    }

    /// Check if tag exists
    fn has_tag(&self, key: &str) -> bool {
        self.tags().contains_key(key)
    }
}
