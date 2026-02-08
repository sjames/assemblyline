// AssemblyLine Validation Module
// Handles WASM plugin loading and provides wrapper functions for traceability validation

// Load the WASM validation plugin
// The plugin is located at the root level (../plugin/)
#let __load-plugin() = {
  let plugin-path = "../plugin/assembly_plugin.wasm"

  // Load the plugin directly - will fail at compile time if not found
  plugin(plugin-path)
}

// Cache the loaded plugin
#let __validation-plugin = __load-plugin()

// Check if plugin is available
#let plugin-available() = {
  true
}

/// Validate traceability rules using the WASM plugin
///
/// Runs RULE 1-7 validation on the entire specification:
/// - RULE 1: All requirements have belongs_to or derives_from
/// - RULE 2: Exactly one root feature
/// - RULE 3: All features have valid parents
/// - RULE 4: Use cases trace to requirements
/// - RULE 5: Requirements allocated to blocks
/// - RULE 6: Requirement allocation constraints
/// - RULE 7: Requirement satisfaction constraints
///
/// Returns a validation result with status and details
#let validate-traceability(registry, links, active-config: none) = {
  // Prepare the input structure for the plugin
  let input = (
    registry: registry,
    links: links,
    active_config: active-config,
  )

  // Serialize to JSON and convert to bytes
  let input-json = json.encode(input)
  let input-bytes = bytes(input-json)

  // Call the validate_rules function in the WASM plugin
  let result-bytes = __validation-plugin.validate_rules(input-bytes)

  // Decode the result
  let result = json(result-bytes)

  result
}

/// Validate the entire specification
///
/// This is a convenience function for validating the specification.
/// Pass in registry and links from your context block.
///
/// Example:
/// #context {
///   let result = validate-specification(
///     registry: __registry.get(),
///     links: __links.get(),
///     active-config: __active-config.get()
///   )
/// }
///
/// Returns validation result dictionary with fields: passed, total_elements, message
#let validate-specification(registry: (:), links: (), active-config: none) = {
  validate-traceability(registry, links, active-config: active-config)
}

/// Get validation status as a display string
#let validation-status(result) = context {
  let passed = result.at("passed", default: false)
  if passed [✓ PASSED] else [✗ FAILED]
}

/// Format validation error details
#let format-validation-errors(result) = context {
  let passed = result.at("passed", default: false)

  if passed {
    []
  } else {
    let message = result.at("message", default: "Unknown error")
    block(
      inset: 0.5em,
      fill: rgb("#ffe6e6"),
      radius: 0.25em,
      [
        *Validation Error:*

        #message
      ]
    )
  }
}

/// Validate parameter bindings using the WASM plugin
///
/// Validates that all parameter bindings in a configuration match their schemas
/// (type checking, range validation, enum membership, defaults)
///
/// Returns a validation result with fields: is_valid, message, errors, num_features_checked, num_parameters_checked
#let validate-parameters-wasm(registry: (:), config-id: "") = {
  let input = (
    registry: registry,
    config_id: config-id,
  )

  // Serialize to JSON and convert to bytes
  let input-json = json.encode(input)
  let input-bytes = bytes(input-json)

  // Call the validate_parameters function in the WASM plugin
  let result-bytes = __validation-plugin.validate_parameters(input-bytes)

  // Decode the result
  let result = json.decode(str(result-bytes))

  result
}
