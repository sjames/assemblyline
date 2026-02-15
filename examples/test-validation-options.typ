#import "../packages/preview/assemblyline/main/lib/lib.typ": *

// Example demonstrating validation options control
// Shows how to disable SAT validation for large models

#set page(width: 8.5in, height: 11in, margin: 1in)
#set text(size: 11pt)

// Define a simple feature model
#feature("Root", id: "ROOT", parent: none, concrete: false)[ Root feature. ]
#feature("Feature A", id: "F-A", parent: "ROOT", concrete: true)[ First feature. ]
#feature("Feature B", id: "F-B", parent: "ROOT", concrete: true)[ Second feature. ]

// Define requirements
#req("REQ-001", belongs_to: "F-A")[ System shall provide feature A. ]
#req("REQ-002", belongs_to: "F-B")[ System shall provide feature B. ]

// Define a configuration
#config("CFG-TEST", title: "Test Configuration", root_feature_id: "ROOT",
  selected: ("ROOT", "F-A", "F-B"))

= Validation Options Demo

This example demonstrates how to control validation options.

== Example 1: Full Validation (Default)

By default, all validations are enabled including SAT-based traceability validation.

#context {
  let registry = __registry.get()
  let links = __links.get()
  let active = __active-config.get()

  [
    *Running full validation (SAT enabled)...*
  ]

  let result = validate-specification(
    registry: registry,
    links: links,
    active-config: active
  )

  [
    *Status:* #validation-status(result)\
    *Total Elements:* #result.at("total_elements", default: 0)\
    *Message:* #result.at("message", default: "No message")\
    *Validation Mode:* #result.at("validation_mode", default: "full")
  ]
}

#pagebreak()

== Example 2: Basic Validation (SAT Disabled)

For large models, you can disable SAT validation to speed up compilation.
Basic validations (links, parameters, interfaces) still run.

#set-validation-options(sat: false)

#context {
  let registry = __registry.get()
  let links = __links.get()
  let active = __active-config.get()

  [
    *Running basic validation (SAT disabled)...*
  ]

  let result = validate-specification(
    registry: registry,
    links: links,
    active-config: active
  )

  [
    *Status:* #validation-status(result)\
    *Total Elements:* #result.at("total_elements", default: 0)\
    *Message:* #result.at("message", default: "No message")\
    *Validation Mode:* #result.at("validation_mode", default: "full")
  ]
}

#pagebreak()

== Example 3: Command-Line Override

You can also control validation via command-line flags:

```bash
# Disable SAT validation
typst compile --input enable-sat=false test-validation-options.typ

# Disable all validations
typst compile --input enable-sat=false --input enable-links=false test-validation-options.typ
```

Use this pattern in your document:

```typst
#set-validation-options(
  sat: sys.inputs.at("enable-sat", default: "true") == "true",
  links: sys.inputs.at("enable-links", default: "true") == "true",
  parameters: sys.inputs.at("enable-parameters", default: "true") == "true",
  interfaces: sys.inputs.at("enable-interfaces", default: "true") == "true"
)
```

#pagebreak()

== Example 4: Selective Validation

Re-enable SAT validation for specific sections:

#set-validation-options(sat: true, links: true, parameters: true, interfaces: true)

#context {
  let registry = __registry.get()
  let links = __links.get()
  let active = __active-config.get()

  [
    *Running full validation again (SAT re-enabled)...*
  ]

  let result = validate-specification(
    registry: registry,
    links: links,
    active-config: active
  )

  [
    *Status:* #validation-status(result)\
    *Total Elements:* #result.at("total_elements", default: 0)\
    *Message:* #result.at("message", default: "No message")\
    *Validation Mode:* #result.at("validation_mode", default: "full")
  ]
}

#pagebreak()

== Validation Option Reference

=== Available Options

- *sat* (default: true) - SAT-based traceability validation
  - Most comprehensive validation
  - Can be slow for large models (100+ features)
  - Validates RULE 1-7 from traceability spec

- *links* (default: true) - Link target existence validation
  - Fast, always recommended
  - Ensures all link targets exist

- *parameters* (default: true) - Parameter binding validation
  - Fast, always recommended
  - Type checking, range validation

- *interfaces* (default: true) - Interface reference validation
  - Fast, always recommended
  - Version compatibility checking

=== Recommendation

For large models (100+ features):
1. Use `sat: false` during iterative development
2. Enable `sat: true` for final validation before release
3. Always keep `links`, `parameters`, and `interfaces` enabled

For small-medium models (< 100 features):
1. Keep all validations enabled
2. SAT validation runs quickly
