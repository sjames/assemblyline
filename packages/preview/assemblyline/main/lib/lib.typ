// assemblyline/lib.typ
// AssemblyLine – FINAL, BULLETPROOF, WORKING (December 2025)
// No errors. No locate/state issues. #links works anywhere.

// Import Fletcher for automatic diagram generation
#import "@preview/fletcher:0.5.8": diagram, node, edge

#let __registry      = state("asln-registry", (:))
#let __links         = state("asln-links", ())        // Individual link records
#let __active-config = state("asln-active-config", none)
#let __tree-counter = state("asln-tree-counter", 0)
#let __validation-options = state("asln-validation-options", (
  sat: true,          // SAT-based traceability validation (can be slow for large models)
  links: true,        // Link target existence validation
  parameters: true,   // Parameter binding validation
  interfaces: true,   // Interface version/reference validation
))

// Extract trailing content block safely
#let __body(args) = {
  let pos = args.pos()
  if pos.len() > 0 { pos.last() } else { [] }
}


// Allowed outgoing link types for each element type
#let __allowed-link-types = (
  feature: ("child_of",),
  req: ("belongs_to", "derives_from"),
  use_case: ("trace",),
  interface: (),  // Interfaces don't have outgoing links (they are referenced by blocks)
  block_definition: ("allocate", "satisfy"),
  internal_block_diagram: ("satisfy", "belongs_to"),
  sequence_diagram: ("satisfy", "belongs_to"),
  implementation: ("satisfy",),
  test_case: ("verify",),
)

// Helper functions for link management (defined before __element)
// Add a single link record with validation
#let __add-link(source, source-type, link-type, target) = {
  // Validate link type is allowed for this element type
  let allowed = __allowed-link-types.at(source-type, default: ())
  if link-type not in allowed {
    let allowed-str = if allowed.len() > 0 { allowed.join(", ") } else { "none" }
    panic(
      "Invalid link type '" + link-type + "' for element '" + source +
      "' (type: " + source-type + ").\n" +
      "Allowed link types for " + source-type + ": " + allowed-str
    )
  }

  context {
    __links.update(links => links + (
      (source: source, type: link-type, target: target),
    ))
  }
}

// Add multiple links from a dictionary (convenience function)
#let __add-links(source, source-type, link-dict) = {
  for (link-type, targets) in link-dict {
    if targets != none {
      let target-array = if type(targets) == array { targets } else { (targets,) }
      for target in target-array {
        __add-link(source, source-type, link-type, target)
      }
    }
  }
}

/// Configure validation options for the specification
///
/// Allows selective enabling/disabling of validation types. Useful for large models
/// where SAT validation may be time-consuming.
///
/// Parameters:
/// - sat: Enable SAT-based traceability validation (default: true)
/// - links: Enable link target existence validation (default: true)
/// - parameters: Enable parameter binding validation (default: true)
/// - interfaces: Enable interface version/reference validation (default: true)
///
/// Command-line override:
/// - Use `--input enable-sat=false` to disable SAT validation from command line
/// - Use `--input enable-links=false` to disable link validation
/// - Use `--input enable-parameters=false` to disable parameter validation
/// - Use `--input enable-interfaces=false` to disable interface validation
///
/// Example:
/// ```typst
/// // Disable SAT validation for large models
/// #set-validation-options(sat: false)
///
/// // Support command-line override
/// #set-validation-options(
///   sat: sys.inputs.at("enable-sat", default: "true") == "true",
///   links: true,
///   parameters: true,
///   interfaces: true
/// )
/// ```
#let set-validation-options(
  sat: true,
  links: true,
  parameters: true,
  interfaces: true
) = {
  __validation-options.update(opts => (
    sat: sat,
    links: links,
    parameters: parameters,
    interfaces: interfaces,
  ))
}

// Validate all links at document end
// Call this function after all elements are registered to check link integrity
// Respects validation options set by #set-validation-options()
#let validate-links() = context {
  // Check if link validation is enabled
  let opts = __validation-options.get()
  if not opts.links {
    return
  }

  let registry = __registry.get()
  let all-links = __links.get()
  let violations = ()

  // Check each link
  for link in all-links {
    let source = link.source
    let target = link.target
    let link-type = link.at("type")

    // Check if source exists (should always be true, but verify)
    if source not in registry {
      violations.push("Link source '" + source + "' does not exist")
    }

    // Check if target exists
    if target not in registry {
      violations.push(
        "Link from '" + source + "' to '" + target + "' (type: '" +
        link-type + "') references non-existent element '" + target + "'"
      )
    }
  }

  // Report violations
  if violations.len() > 0 {
    let msg = "Link validation failed with " + str(violations.len()) + " error(s):\n" + violations.join("\n")
    panic(msg)
  }
}

// Validate parameter bindings for a configuration
// Call this function after all elements are registered to check parameter integrity
// Respects validation options set by #set-validation-options()
#let validate-parameter-bindings(config-id) = context {
  // Check if parameter validation is enabled
  let opts = __validation-options.get()
  if not opts.parameters {
    return
  }

  let registry = __registry.get()
  let config-key = "CONFIG:" + config-id
  let violations = ()

  // Check if config exists
  if config-key not in registry {
    panic("Configuration '" + config-id + "' does not exist")
  }

  let config = registry.at(config-key)
  let bindings = config.at("bindings", default: (:))
  let selected = config.at("selected", default: ())

  // Check each selected feature
  for feature-id in selected {
    // Check if feature exists
    if feature-id not in registry {
      violations.push("Configuration '" + config-id + "' selects non-existent feature '" + feature-id + "'")
      continue
    }

    let feature = registry.at(feature-id)
    let parameters = feature.at("parameters", default: none)

    // Skip if feature has no parameters
    if parameters == none or parameters == (:) {
      continue
    }

    // Get bindings for this feature
    let feature-bindings = bindings.at(feature-id, default: (:))

    // Check each parameter in the schema
    for (param-name, param-schema) in parameters {
      let bound-value = feature-bindings.at(param-name, default: none)
      let default-value = param-schema.at("default", default: none)

      // If no binding and no default, that's an error
      if bound-value == none and default-value == none {
        violations.push(
          "Feature '" + feature-id + "', parameter '" + param-name + "': " +
          "No binding provided and no default value defined"
        )
        continue
      }

      // Use binding if provided, otherwise use default
      let value = if bound-value != none { bound-value } else { default-value }

      // Validate type
      let param-type = param-schema.at("type")

      if param-type == "Integer" {
        if type(value) != int {
          violations.push(
            "Feature '" + feature-id + "', parameter '" + param-name + "': " +
            "Expected type Integer, got " + str(type(value))
          )
          continue
        }

        // Validate range if specified
        let range = param-schema.at("range", default: none)
        if range != none {
          let (min-val, max-val) = range
          if value < min-val or value > max-val {
            violations.push(
              "Feature '" + feature-id + "', parameter '" + param-name + "': " +
              "Value " + str(value) + " out of range [" + str(min-val) + ", " + str(max-val) + "]"
            )
          }
        }
      } else if param-type == "Boolean" {
        if type(value) != bool {
          violations.push(
            "Feature '" + feature-id + "', parameter '" + param-name + "': " +
            "Expected type Boolean, got " + str(type(value))
          )
        }
      } else if param-type == "Enum" {
        // Check if value is string
        if type(value) != str {
          violations.push(
            "Feature '" + feature-id + "', parameter '" + param-name + "': " +
            "Expected type String (for Enum), got " + str(type(value))
          )
          continue
        }

        // Check if value is in allowed values
        let values = param-schema.at("values", default: ())
        if value not in values {
          violations.push(
            "Feature '" + feature-id + "', parameter '" + param-name + "': " +
            "Value '" + value + "' not in enum " + repr(values)
          )
        }
      }
    }
  }

  // Report violations
  if violations.len() > 0 {
    let msg = "Parameter validation failed with " + str(violations.len()) + " error(s):\n" + violations.join("\n")
    panic(msg)
  }
}

// Validate interface references in blocks
// Call this function after all elements are registered to check interface integrity
// Respects validation options set by #set-validation-options()
#let validate-interface-references() = context {
  // Check if interface validation is enabled
  let opts = __validation-options.get()
  if not opts.interfaces {
    return
  }

  let registry = __registry.get()
  let violations = ()

  // Get all interfaces
  let interfaces = registry.pairs()
    .filter(p => p.last().type == "interface")
    .map(p => p.first())

  // Check all blocks
  let blocks = registry.pairs()
    .filter(p => p.last().type == "block_definition")
    .map(p => p.last())

  for block in blocks {
    let provides = block.tags.at("sysml-provides", default: ())
    let requires = block.tags.at("sysml-requires", default: ())
    let ports = block.tags.at("sysml-ports", default: ())

    // Check provides references
    for if-id in provides {
      if if-id not in registry {
        violations.push(
          "Block '" + block.id + "' provides interface '" + if-id + "' which does not exist"
        )
      } else if registry.at(if-id).type != "interface" {
        violations.push(
          "Block '" + block.id + "' provides '" + if-id + "' which is not an interface (type: " + registry.at(if-id).type + ")"
        )
      }
    }

    // Check requires references
    for if-id in requires {
      if if-id not in registry {
        violations.push(
          "Block '" + block.id + "' requires interface '" + if-id + "' which does not exist"
        )
      } else if registry.at(if-id).type != "interface" {
        violations.push(
          "Block '" + block.id + "' requires '" + if-id + "' which is not an interface (type: " + registry.at(if-id).type + ")"
        )
      }
    }

    // Check port interface references
    for port in ports {
      let port-if = port.at("interface", default: none)
      if port-if != none {
        if port-if not in registry {
          violations.push(
            "Block '" + block.id + "', port '" + port.name + "' references interface '" + port-if + "' which does not exist"
          )
        } else if registry.at(port-if).type != "interface" {
          violations.push(
            "Block '" + block.id + "', port '" + port.name + "' references '" + port-if + "' which is not an interface (type: " + registry.at(port-if).type + ")"
          )
        }

        // Check consistency: port interface should match provides/requires
        let direction = port.at("direction", default: "in")
        if direction == "provided" or direction == "bidirectional" {
          if port-if not in provides {
            violations.push(
              "Block '" + block.id + "', port '" + port.name + "' (direction: " + direction + ") references interface '" + port-if + "' but block does not provide this interface"
            )
          }
        }
        if direction == "required" or direction == "bidirectional" {
          if port-if not in requires {
            violations.push(
              "Block '" + block.id + "', port '" + port.name + "' (direction: " + direction + ") references interface '" + port-if + "' but block does not require this interface"
            )
          }
        }
      }
    }
  }

  // Report violations
  if violations.len() > 0 {
    let msg = "Interface validation failed with " + str(violations.len()) + " error(s):\n" + violations.join("\n")
    panic(msg)
  }
}

// Parse semantic version string (e.g., "2.1.3" -> (major: 2, minor: 1, patch: 3))
#let __parse-semver(version-str) = {
  let parts = version-str.split(".")
  if parts.len() < 2 {
    return (major: 0, minor: 0, patch: 0)
  }
  let major = int(parts.at(0, default: "0"))
  let minor = int(parts.at(1, default: "0"))
  let patch = int(parts.at(2, default: "0"))
  (major: major, minor: minor, patch: patch)
}

// Check if two interface versions are compatible (semantic versioning)
// Rule: Major version must match, minor/patch can differ
#let __versions-compatible(required-ver, provided-ver) = {
  let req = __parse-semver(required-ver)
  let prov = __parse-semver(provided-ver)

  // Major versions must match
  if req.major != prov.major {
    return false
  }

  // Provided minor version must be >= required minor version
  if prov.minor < req.minor {
    return false
  }

  // If minor versions match, provided patch must be >= required patch
  if prov.minor == req.minor and prov.patch < req.patch {
    return false
  }

  return true
}

// Validate interface version compatibility
// Call this function after all elements are registered
// Respects validation options set by #set-validation-options()
#let validate-interface-versions() = context {
  // Check if interface validation is enabled
  let opts = __validation-options.get()
  if not opts.interfaces {
    return
  }

  let registry = __registry.get()
  let violations = ()

  // For each block that requires/provides interfaces, check version compatibility
  // Note: This is a basic check - for now we just verify that versions are parseable
  // Full compatibility checking would require storing version requirements in blocks

  let interfaces = registry.pairs()
    .filter(p => p.last().type == "interface")
    .map(p => p.last())

  for interface in interfaces {
    let version = interface.tags.at("interface-version", default: "1.0.0")
    let parsed = __parse-semver(version)

    // Just verify it parsed correctly (basic validation)
    if parsed.major == 0 and parsed.minor == 0 and parsed.patch == 0 and version != "0.0.0" {
      violations.push(
        "Interface '" + interface.id + "' has invalid version format: '" + version + "' (expected X.Y.Z)"
      )
    }
  }

  // Report violations
  if violations.len() > 0 {
    let msg = "Interface version validation failed with " + str(violations.len()) + " error(s):\n" + violations.join("\n")
    panic(msg)
  }
}

// Get all links for a specific element (by source)
// NOTE: This function must be called from within a context block
#let __get-links(element-id) = {
  let all-links = __links.get()
  let elem-links = (:)  // Dictionary: link-type → (targets,)

  // Find all links where source == element-id
  for link in all-links {
    if link.source == element-id {
      let link-type = link.at("type")
      let target = link.target

      if link-type in elem-links {
        elem-links.at(link-type) += (target,)
      } else {
        elem-links.insert(link-type, (target,))
      }
    }
  }

  elem-links
}

// Register element silently
#let __element(
  type, id, title: "", tags: (:), links: (:),
  parent: none, concrete: none, group: none, body: none,
  parameters: none, constraints: none, requires: none
) = {
  context {
    let registry = __registry.get()

    // Check for ID uniqueness - O(1) dictionary lookup
    if id in registry {
      panic("Duplicate element ID: '" + id + "' is already registered (type: " + registry.at(id).type + ")")
    }

    // Register element WITHOUT links field
    __registry.update(r => {
      r.insert(id, (
        type: type,
        id: id,
        title: title,
        tags: tags,
        // NO links field here
        parent: parent,
        concrete: concrete,
        group: group,
        body: body,
        parameters: parameters,
        constraints: constraints,
        requires: requires
      ))
      r
    })

    // Add links to separate storage with validation
    __add-links(id, type, links)
  }
}

// #feature
#let feature(title, ..args) = {
  let named = args.named()
  let body  = __body(args)
  let id         = named.at("id")
  let tags       = named.at("tags", default: (:))
  let parent     = named.at("parent", default: none)
  let concrete   = named.at("concrete", default: true)
  let group      = named.at("group", default: none)
  let parameters = named.at("parameters", default: none)
  let constraints = named.at("constraints", default: none)
  let requires   = named.at("requires", default: none)

  __element("feature", id,
    title: title,
    tags: tags,
    links: (child_of: parent),
    parent: parent,
    concrete: concrete,
    group: group,
    body: body,
    parameters: parameters,
    constraints: constraints,
    requires: requires
  )
}

// #req
// ──────────────────────────────────────────────────────────────────────────────
// Purpose:      Requirements specification with explicit traceability
// Mandatory:    id: "UNIQUE"
//               EITHER belongs_to: "FEATURE-ID" (top-level requirement)
//               OR derives_from: "REQ-ID" (derived/decomposed requirement)
// Optional:     tags: (type: "functional", safety: "QM", ...) → metadata
// Content:      The requirement text
// Validation:   Exactly one of belongs_to or derives_from must be specified
#let req(id, belongs_to: none, derives_from: none, ..args) = {
  // Validation: EITHER belongs_to OR derives_from must be present (XOR)
  let has_belongs_to = belongs_to != none
  let has_derives_from = derives_from != none

  assert(
    has_belongs_to or has_derives_from,
    message: "Requirement '" + id + "' must have either 'belongs_to' (linking to a feature) or 'derives_from' (linking to a parent requirement)"
  )

  assert(
    not (has_belongs_to and has_derives_from),
    message: "Requirement '" + id + "' cannot have both 'belongs_to' and 'derives_from'. Use 'belongs_to' for top-level requirements or 'derives_from' for derived requirements."
  )

  let named = args.named()
  let body  = __body(args)
  let tags  = named.at("tags", default: (:))

  // Build links based on which parameter was provided
  let links = (:)
  if has_belongs_to   { links.belongs_to = (belongs_to,) }
  if has_derives_from { links.derives_from = (derives_from,) }

  metadata((type: "req", id: id))

  __element("req", id, tags: tags, links: links, body: body)
}

// Generic elements
#let use_case(title, ..args) = {
  let named = args.named()
  let body = __body(args)
  let id = named.at("id")
  let tags = named.at("tags", default: (:))
  let links-param = named.at("links", default: (:))
  __element("use_case", id, title: title, tags: tags, links: links-param, body: body)
}

// #block_definition – Full SysML Block Definition
// ──────────────────────────────────────────────────────────────────────────────
// Purpose:      Define system components with full SysML block semantics
// Required:     id, title
// SysML Features:
//   provides:     ("IF-ID1", "IF-ID2", ...) – interfaces this block implements/provides
//   requires:     ("IF-ID3", "IF-ID4", ...) – interfaces this block depends on/requires
//   properties:   ((name: "prop1", type: "Integer", default: 0, unit: "ms"), ...)
//   operations:   ((name: "start", params: "void", returns: "bool"), ...)
//   ports:        ((name: "httpPort", direction: "in|out|bidirectional|provided|required", protocol: "HTTP", interface: "IF-ID"), ...)
//                 - direction: "in" (input), "out" (output), "bidirectional" (both), "provided" (implements interface), "required" (uses interface)
//                 - interface: optional reference to interface definition
//   parts:        ((name: "authService", type: "BLK-AUTH", multiplicity: "1"), ...) – composition with role names
//   connectors:   ((from: "httpPort", to: "authService.authAPI", flow: "HTTPRequest"), ...) – internal wiring & delegation
//                 - No dot = block's own port (delegation)
//                 - With dot = part.port (internal wiring)
//   references:   ("BLK-EXT1", "BLK-EXT2") – associations (external block IDs)
//   constraints:  ("weight < 500g", "power < 10W") – OCL-like constraints
//   tags:         (stereotype: "subsystem", complexity: "high", ...)
//   body:         Free-form description
#let block_definition(
  id,
  title: "",
  provides: (),
  requires: (),
  properties: (),
  operations: (),
  ports: (),
  parts: (),
  connectors: (),
  references: (),
  constraints: (),
  ..args
) = {
  let named = args.named()
  let body  = __body(args)
  let tags  = named.at("tags", default: (:))
  let links-param = named.at("links", default: (:))

  // Store SysML-specific data in tags for easy access
  let full-tags = tags + (
    sysml-provides: provides,
    sysml-requires: requires,
    sysml-properties: properties,
    sysml-operations: operations,
    sysml-ports: ports,
    sysml-parts: parts,
    sysml-connectors: connectors,
    sysml-references: references,
    sysml-constraints: constraints
  )

  __element("block_definition", id, title: title, tags: full-tags, links: links-param, body: body)
}

// #internal_block_diagram – Standalone SysML Internal Block Diagram
// ──────────────────────────────────────────────────────────────────────────────
// Purpose:      Define internal structure independently from block definitions
// Required:     id, title
// SysML Features:
//   parts:        ((name: "part1", type: "BLK-TYPE", multiplicity: "1"), ...)
//   ports:        ((name: "port1", direction: "in", protocol: "HTTP"), ...)
//   connectors:   ((from: "port", to: "part.port", flow: "Data"), ...)
//   references:   ("BLK-EXT1", "BLK-EXT2") – external block references
//   tags:         (tool: "PlantUML", author: "...", ...)
//   body:         Free-form description
#let internal_block_diagram(
  id,
  title: "",
  parts: (),
  ports: (),
  connectors: (),
  references: (),
  ..args
) = {
  let named = args.named()
  let body  = __body(args)
  let tags  = named.at("tags", default: (:))
  let links-param = named.at("links", default: (:))

  // Store IBD-specific data in tags for easy access
  let full-tags = tags + (
    ibd-parts: parts,
    ibd-ports: ports,
    ibd-connectors: connectors,
    ibd-references: references
  )

  __element("internal_block_diagram", id, title: title, tags: full-tags, links: links-param, body: body)
}

#let sequence_diagram(id, title: "", ..args) = {
  let named = args.named()
  let tags = named.at("tags", default: (:))
  let links-param = named.at("links", default: (:))
  __element("sequence_diagram", id, title: title, tags: tags, links: links-param, body: __body(args))
}

#let implementation(id, title: "", ..args) = {
  let named = args.named()
  let tags = named.at("tags", default: (:))
  let links-param = named.at("links", default: (:))
  __element("implementation", id, title: title, tags: tags, links: links-param, body: __body(args))
}

#let test_case(id, title: "", ..args) = {
  let named = args.named()
  let tags = named.at("tags", default: (:))
  let links-param = named.at("links", default: (:))
  __element("test_case", id, title: title, tags: tags, links: links-param, body: __body(args))
}

// #interface – Interface Definition (Software & Hardware)
// ──────────────────────────────────────────────────────────────────────────────
// Purpose:      Define reusable interface specifications for both software and hardware
// Required:     id, title
// Parameters:
//   type:         "software" | "hardware" | "mixed" – interface category
//   version:      Semantic version string (e.g., "2.1.0") – default "1.0.0"
//   protocol:     Protocol name (e.g., "HTTP/REST", "I2C", "CAN", "DBus")
//   operations:   Array of operation definitions for software interfaces
//                 ((name: "op", params: ((name, type, validation), ...), returns: "Type", errors: ("Err1", ...)), ...)
//   signals:      Array of signal/event definitions for async notification
//                 ((name: "signal", data: "field1: Type, field2: Type"), ...)
//   registers:    Array of hardware register definitions
//                 ((address: "0xNN", name: "REG_NAME", access: "R|W|RW", size: "N bytes", default: "0x00"), ...)
//   messages:     Array of message definitions for message-based protocols (CAN, etc.)
//                 ((id: "0xNN", name: "MSG_NAME", dlc: N, period: "Nms", signals: (...)), ...)
//   electrical:   Dictionary of electrical characteristics (voltage, frequency, current, etc.)
//   timing:       Dictionary of timing requirements (startup_time, sample_rate, latency, etc.)
//   data_types:   Array of custom data type definitions
//                 ((name: "TypeName", fields: ("field1: Type1", "field2: Type2", ...)), ...)
//   constraints:  Array of constraint strings (e.g., "response_time < 100ms")
//   tags:         Additional metadata
//   body:         Free-form description
#let interface(
  title,
  id: "",
  type: "software",
  version: "1.0.0",
  protocol: "",
  operations: (),
  signals: (),
  registers: (),
  messages: (),
  electrical: (:),
  timing: (:),
  data_types: (),
  constraints: (),
  ..args
) = {
  let named = args.named()
  let body = __body(args)
  let tags = named.at("tags", default: (:))
  let links-param = named.at("links", default: (:))

  // Validate required fields
  assert(id != "", message: "Interface must have an id")
  assert(title != "", message: "Interface must have a title")
  assert(type in ("software", "hardware", "mixed"),
    message: "Interface type must be 'software', 'hardware', or 'mixed'")

  // Store interface-specific data in tags for easy access
  let full-tags = tags + (
    interface-type: type,
    interface-version: version,
    interface-protocol: protocol,
    interface-operations: operations,
    interface-signals: signals,
    interface-registers: registers,
    interface-messages: messages,
    interface-electrical: electrical,
    interface-timing: timing,
    interface-data-types: data_types,
    interface-constraints: constraints
  )

  __element("interface", id, title: title, tags: full-tags, links: links-param, body: body)
}

// NOTE: #links() function removed - links are now passed as parameters to elements

// #config
#let config(id, title: "", root_feature_id: "ROOT", selected: (), bindings: (:), tags: (:)) = {
  context {
    let registry = __registry.get()
    let config-key = "CONFIG:" + id

    // Check for ID uniqueness - O(1) dictionary lookup
    if config-key in registry {
      panic("Duplicate configuration ID: '" + id + "' is already registered")
    }

    __registry.update(r => {
      r.insert(config-key, (
        type: "config",
        id: id,
        title: title,
        root: root_feature_id,
        selected: selected,
        bindings: bindings,
        tags: tags
      ))
      r
    })
  }
}

#let set-active-config(id) = __active-config.update(id)

// Reporting

// Helper function to format feature constraints for display with clickable links
// tree-prefix: unique identifier for this tree instance to avoid duplicate labels
#let __format-constraints(feature, tree-prefix) = {
  let constraint-parts = ()

  // Check for 'requires' constraint in tags (implies relationship)
  if "requires" in feature.tags {
    let req = feature.tags.requires
    let req-list = if type(req) == array { req } else { (req,) }
    for req-id in req-list {
      // Create clickable link with tree-specific prefix
      let target-label = tree-prefix + req-id
      constraint-parts.push([implies #link(label(target-label))[#req-id]])
    }
  }

  // Check for 'excludes' constraint in tags
  if "excludes" in feature.tags {
    let excl = feature.tags.excludes
    let excl-list = if type(excl) == array { excl } else { (excl,) }
    for excl-id in excl-list {
      // Create clickable link with tree-specific prefix
      let target-label = tree-prefix + excl-id
      constraint-parts.push([excludes #link(label(target-label))[#excl-id]])
    }
  }

  // Return formatted constraint string
  if constraint-parts.len() > 0 {
    text(size: 0.7em, fill: luma(100))[ (#constraint-parts.join(", "))]
  } else {
    []
  }
}

// Render a feature tree node recursively
// tree-prefix: unique identifier for this tree instance to create unique labels
// bindings: configuration bindings for parameter values
// show-parameters: whether to display parameter bindings
#let __render-tree-node(feature, registry, selected, depth, tree-prefix, bindings: (:), show-parameters: true) = {
  let indent = "  " * depth
  let is-selected = selected.contains(feature.id)
  let no-config = selected.len() == 0  // No configuration active

  // Determine node symbols and styling
  let group-symbol = if feature.group == "XOR" {
    "⊕"
  } else if feature.group == "OR" {
    "⊙"
  } else {
    "●"
  }

  // Show group type instead of abstract marker
  let group-marker = if feature.group == "OR" {
    text(size: 0.75em)[ (select any)]
  } else if feature.group == "XOR" {
    text(size: 0.75em)[ (select only one)]
  } else {
    ""
  }

  // Color palette for depth-based visualization
  // Colors chosen for good contrast and visual comfort
  let depth-colors = (
    rgb("#1e3a8a"),  // Level 0: Deep blue
    rgb("#0891b2"),  // Level 1: Cyan
    rgb("#059669"),  // Level 2: Emerald green
    rgb("#d97706"),  // Level 3: Amber
    rgb("#7c3aed"),  // Level 4: Violet
    rgb("#db2777"),  // Level 5: Pink
  )

  // Get color for current depth (cycle if deeper than palette)
  let depth-color = depth-colors.at(calc.rem(depth, depth-colors.len()))

  // Format constraints with tree-specific prefix for unique labels
  let constraint-display = __format-constraints(feature, tree-prefix)

  // Style based on selection with depth-based colors
  // If no configuration, all features get depth colors
  // If configuration active, only selected features get depth colors
  let node-content = if no-config or is-selected {
    text(fill: depth-color, weight: "bold")[
      #group-symbol #feature.id#if feature.title != "" [ – #feature.title]#group-marker
    ]
  } else {
    text(fill: gray)[
      #group-symbol #feature.id#if feature.title != "" [ – #feature.title]#group-marker
    ]
  }

  // Create unique label for this feature in this tree instance
  let feature-label = tree-prefix + feature.id

  // Render this node with constraints and label
  [#indent#node-content#constraint-display#label(feature-label)\ ]

  // Render parameter bindings as bullet list if they exist and should be shown
  if show-parameters and is-selected and feature.id in bindings {
    let feature-bindings = bindings.at(feature.id)
    let feature-params = feature.at("parameters", default: none)

    if feature-bindings != (:) and feature-params != none {
      let param-indent = "  " * depth + "  "

      for (param-name, param-value) in feature-bindings {
        // Get parameter schema to extract metadata
        let param-schema = feature-params.at(param-name, default: none)
        let unit = if param-schema != none {
          param-schema.at("unit", default: none)
        } else {
          none
        }

        let param-type = if param-schema != none {
          param-schema.at("type", default: none)
        } else {
          none
        }

        let default-value = if param-schema != none {
          param-schema.at("default", default: none)
        } else {
          none
        }

        // Format the binding value
        let value-str = if type(param-value) == bool {
          if param-value { "true" } else { "false" }
        } else {
          str(param-value)
        }

        let value-display = if unit != none {
          value-str + " " + unit
        } else {
          value-str
        }

        // Build metadata string (range/values and default)
        let metadata-parts = ()

        // Add range or values depending on type
        if param-type == "Integer" and param-schema != none {
          let range = param-schema.at("range", default: none)
          if range != none {
            let (min-val, max-val) = range
            metadata-parts.push("range: " + str(min-val) + "-" + str(max-val))
          }
        } else if param-type == "Enum" and param-schema != none {
          let values = param-schema.at("values", default: none)
          if values != none {
            metadata-parts.push("values: " + values.join(", "))
          }
        }

        // Add default value
        if default-value != none {
          let default-str = if type(default-value) == bool {
            if default-value { "true" } else { "false" }
          } else {
            str(default-value)
          }
          metadata-parts.push("default: " + default-str)
        }

        // Use black color for parameter name and value, light grey for metadata
        if metadata-parts.len() > 0 {
          let metadata-display = " (" + metadata-parts.join(", ") + ")"
          [#param-indent#text(size: 0.75em, fill: black)[├ #param-name: #value-display]#text(size: 0.75em, fill: luma(130))[#metadata-display]\ ]
        } else {
          [#param-indent#text(size: 0.75em, fill: black)[├ #param-name: #value-display]\ ]
        }
      }
    }
  }

  // Find and render children
  let children = registry.pairs()
    .filter(p => p.last().type == "feature" and p.last().parent == feature.id)
    .map(p => p.last())

  for child in children {
    __render-tree-node(child, registry, selected, depth + 1, tree-prefix, bindings: bindings, show-parameters: show-parameters)
  }
}

// Detailed tree node renderer that includes feature body/description
// tree-prefix: unique identifier for this tree instance to create unique labels
// bindings: configuration bindings for parameter values
// show-parameters: whether to display parameter bindings
#let __render-tree-node-detailed(feature, registry, selected, depth, show-descriptions: true, max-depth: none, tree-prefix, bindings: (:), show-parameters: true) = {
  let indent = "  " * depth
  let is-selected = selected.contains(feature.id)
  let no-config = selected.len() == 0  // No configuration active

  // Determine node symbols and styling
  let group-symbol = if feature.group == "XOR" {
    "⊕"
  } else if feature.group == "OR" {
    "⊙"
  } else {
    "●"
  }

  // Show group type instead of abstract marker
  let group-marker = if feature.group == "OR" {
    text(size: 0.75em)[ (select any)]
  } else if feature.group == "XOR" {
    text(size: 0.75em)[ (select only one)]
  } else {
    ""
  }

  // Color palette for depth-based visualization
  // Colors chosen for good contrast and visual comfort
  let depth-colors = (
    rgb("#1e3a8a"),  // Level 0: Deep blue
    rgb("#0891b2"),  // Level 1: Cyan
    rgb("#059669"),  // Level 2: Emerald green
    rgb("#d97706"),  // Level 3: Amber
    rgb("#7c3aed"),  // Level 4: Violet
    rgb("#db2777"),  // Level 5: Pink
  )

  // Get color for current depth (cycle if deeper than palette)
  let depth-color = depth-colors.at(calc.rem(depth, depth-colors.len()))

  // Format constraints with tree-specific prefix for unique labels
  let constraint-display = __format-constraints(feature, tree-prefix)

  // Style based on selection with depth-based colors
  // If no configuration, all features get depth colors
  // If configuration active, only selected features get depth colors
  let node-content = if no-config or is-selected {
    text(fill: depth-color, weight: "bold")[
      #group-symbol #feature.id#if feature.title != "" [ – #feature.title]#group-marker
    ]
  } else {
    text(fill: gray)[
      #group-symbol #feature.id#if feature.title != "" [ – #feature.title]#group-marker
    ]
  }

  // Create unique label for this feature in this tree instance
  let feature-label = tree-prefix + feature.id

  // Render this node with constraints and label
  [#indent#node-content#constraint-display#label(feature-label)\ ]

  // Render description if enabled and body exists
  if show-descriptions and feature.body != none and feature.body != [] {
    let desc-indent = "  " * depth + "│ "
    // Use same depth color for descriptions but slightly lighter
    // If no configuration, all descriptions get depth colors
    let desc-color = if no-config or is-selected { depth-color.lighten(20%) } else { luma(100) }

    // Render description with continuation marker
    [#desc-indent#text(size: 0.85em, fill: desc-color, style: "italic")[#feature.body]\ ]

    // Add spacing line after description
    [#desc-indent\ ]
  }

  // Render parameter bindings as bullet list if they exist and should be shown
  if show-parameters and is-selected and feature.id in bindings {
    let feature-bindings = bindings.at(feature.id)
    let feature-params = feature.at("parameters", default: none)

    if feature-bindings != (:) and feature-params != none {
      let param-indent = "  " * depth + "│ "

      // Parameter header
      [#param-indent#text(size: 0.8em, fill: black, weight: "bold")[Parameters:]\ ]

      for (param-name, param-value) in feature-bindings {
        // Get parameter schema to extract metadata
        let param-schema = feature-params.at(param-name, default: none)
        let unit = if param-schema != none {
          param-schema.at("unit", default: none)
        } else {
          none
        }

        let param-type = if param-schema != none {
          param-schema.at("type", default: none)
        } else {
          none
        }

        let default-value = if param-schema != none {
          param-schema.at("default", default: none)
        } else {
          none
        }

        // Format the binding value
        let value-str = if type(param-value) == bool {
          if param-value { "true" } else { "false" }
        } else {
          str(param-value)
        }

        let value-display = if unit != none {
          value-str + " " + unit
        } else {
          value-str
        }

        // Build metadata string (range/values and default)
        let metadata-parts = ()

        // Add range or values depending on type
        if param-type == "Integer" and param-schema != none {
          let range = param-schema.at("range", default: none)
          if range != none {
            let (min-val, max-val) = range
            metadata-parts.push("range: " + str(min-val) + "-" + str(max-val))
          }
        } else if param-type == "Enum" and param-schema != none {
          let values = param-schema.at("values", default: none)
          if values != none {
            metadata-parts.push("values: " + values.join(", "))
          }
        }

        // Add default value
        if default-value != none {
          let default-str = if type(default-value) == bool {
            if default-value { "true" } else { "false" }
          } else {
            str(default-value)
          }
          metadata-parts.push("default: " + default-str)
        }

        // Use black color for parameter name and value, light grey for metadata
        if metadata-parts.len() > 0 {
          let metadata-display = " (" + metadata-parts.join(", ") + ")"
          [#param-indent#text(size: 0.75em, fill: black)[  • #param-name: #value-display]#text(size: 0.75em, fill: luma(130))[#metadata-display]\ ]
        } else {
          [#param-indent#text(size: 0.75em, fill: black)[  • #param-name: #value-display]\ ]
        }
      }

      // Add spacing line after parameters
      [#param-indent\ ]
    }
  }

  // Check if we should render children (depth limit)
  let should-render-children = if max-depth == none {
    true
  } else {
    depth < max-depth
  }

  if should-render-children {
    // Find and render children
    let children = registry.pairs()
      .filter(p => p.last().type == "feature" and p.last().parent == feature.id)
      .map(p => p.last())

    for child in children {
      __render-tree-node-detailed(child, registry, selected, depth + 1, show-descriptions: show-descriptions, max-depth: max-depth, tree-prefix, bindings: bindings, show-parameters: show-parameters)
    }
  } else if max-depth != none {
    // Indicate that there are hidden children
    let children-count = registry.pairs()
      .filter(p => p.last().type == "feature" and p.last().parent == feature.id)
      .len()

    if children-count > 0 {
      let child-indent = "  " * (depth + 1)
      [#child-indent#text(fill: luma(150), size: 0.85em, style: "italic")[... (#children-count) more features ...]\ ]
    }
  }
}

// Helper function to build feature path from a feature to root
#let __build-feature-path(feature-id, registry) = {
  let path = ()
  let current-id = feature-id

  // Traverse up to root
  while current-id != none {
    let feat = registry.at(current-id, default: none)
    if feat == none { break }

    // Add to path (will reverse later)
    path.push((id: feat.id, title: feat.title))
    current-id = feat.parent
  }

  // Reverse to get root-to-leaf order
  path.rev()
}

// Render requirements as cards with feature hierarchy headers
#let __render-requirements-as-cards(feature, registry, all-links, selected, depth) = {
  let is-selected = selected.contains(feature.id)
  let show-requirements = is-selected or selected.len() == 0

  if show-requirements {
    let feature-reqs = all-links
      .filter(link => link.type == "belongs_to" and link.target == feature.id)
      .map(link => link.source)

    for req-id in feature-reqs {
      let req = registry.at(req-id, default: none)
      if req != none and req.type == "req" {
        // Build feature path for this requirement
        let feature-path = __build-feature-path(feature.id, registry)

        // Create requirement card with feature hierarchy header
        v(0.5em)
        [#figure(
          kind: "requirement",
          supplement: [],
          numbering: _ => [],
          gap: 0pt,
          block(
            width: 100%,
            fill: rgb("#f8f9fa"),
            stroke: (left: 3pt + rgb("#4a90e2"), rest: 0.5pt + rgb("#dee2e6")),
            radius: 4pt,
            inset: 0pt,
            breakable: false
          )[
            // Feature path header
            #block(
              width: 100%,
              fill: rgb("#e8f4f8"),
              inset: (left: 0.8em, right: 0.8em, top: 0.4em, bottom: 0.4em),
              radius: (top: 4pt, bottom: 0pt)
            )[
              #align(left)[
                #text(size: 0.75em, fill: rgb("#6c757d"), weight: "regular")[
                  #feature-path.map(f => {
                    if f.title != "" { f.title } else { f.id }
                  }).join(" » ")
                ]
              ]
            ]

            // Requirement content
            #block(
              width: 100%,
              inset: (left: 0.8em, right: 0.8em, top: 0.2em, bottom: 0.5em)
            )[
              #align(left)[
                // Requirement ID badge (top left)
                #box(
                  fill: rgb("#ffffff"),
                  stroke: 1pt + rgb("#4a90e2"),
                  inset: (left: 0.4em, right: 0.4em, top: 0.2em, bottom: 0.2em),
                  radius: 3pt
                )[
                  #text(fill: rgb("#2c5aa0"), size: 0.75em, weight: "bold")[#req-id]
                ]

                // Requirement text (new line below)
                #v(0.35em)
                #text(fill: black, size: 0.9em)[#req.body]
              ]
            ]
          ]
        ) #label(req-id)]
      }
    }
  }

  // Recurse to children
  let children = registry.pairs()
    .filter(p => p.last().type == "feature" and p.last().parent == feature.id)
    .map(p => p.last())

  for child in children {
    __render-requirements-as-cards(child, registry, all-links, selected, depth + 1)
  }
}

// Setup show rule for requirement references (call this at document start)
#let setup-requirement-references(body) = {
  show ref: it => {
    if it.element != none and it.element.func() == figure and it.element.kind == "requirement" {
      // Extract the label from the reference and display it
      let label-str = str(it.target)
      link(it.target)[#label-str]
    } else {
      it
    }
  }

  body
}

// #feature-tree-with-requirements: Render hierarchical feature model with requirements
#let feature-tree-with-requirements(root: "ROOT", config: none, level: 2) = context {
    // Get registry and links from state
    let registry = __registry.get()
    let all-links = __links.get()

    // Determine which configuration to use
    let cfg-id = if config != none {
      config
    } else {
      __active-config.get()
    }

  // Get selected features from configuration
  let selected = if cfg-id != none and ("CONFIG:" + cfg-id) in registry {
    registry.at("CONFIG:" + cfg-id).selected
  } else {
    ()
  }

  // Get root feature
  let root-feature = registry.at(root, default: none)

  if root-feature == none {
    block(fill: red.lighten(80%), inset: 1em)[
      *Error:* Feature "#root" not found in registry. \
      *Registry keys:* #registry.keys().join(", ") \
      *Registry has #registry.len() items*
    ]
    return
  }

  // Count total requirements linked to features
  let total-reqs = all-links
    .filter(link => link.type == "belongs_to")
    .map(link => link.source)
    .len()

  // Render header (non-breakable)
  block(
    width: 100%,
    fill: rgb("#e8f4f8"),
    inset: 1.2em,
    radius: 4pt,
    stroke: 2pt + rgb("#4a90e2")
  )[
    #heading(level: level)[Feature Tree with Requirements]
    #v(0.3em)
    #grid(
      columns: (auto, 1fr),
      gutter: 1em,
      [
        #if cfg-id != none [
          #text(size: 0.9em)[
            *Configuration:* #text(fill: rgb("#2c5aa0"), weight: "bold")[#cfg-id] \
            *Selected features:* #text(fill: green.darken(30%), weight: "bold")[#selected.len()] of #registry.pairs().filter(p => p.last().type == "feature").len() \
            *Top-level requirements:* #text(fill: rgb("#2c5aa0"), weight: "bold")[#total-reqs]
          ]
        ]
        #if cfg-id == none [
          #text(size: 0.9em)[
            _(No active configuration – showing all features)_ \
            *Top-level requirements:* #text(fill: rgb("#2c5aa0"), weight: "bold")[#total-reqs]
          ]
        ]
      ],
      []
    )
  ]

  v(0.7em)

  // Render requirements as cards with feature hierarchy
  __render-requirements-as-cards(root-feature, registry, all-links, selected, 0)

  v(0.7em)

  // Render legend (non-breakable)
  block(
    width: 100%,
    fill: rgb("#f8f9fa"),
    inset: 0.8em,
    radius: 3pt,
    stroke: 0.5pt + rgb("#dee2e6")
  )[
    #text(size: 0.85em)[
      *Layout:* Requirements are displayed as cards with their feature hierarchy shown in the header.
      The path shows the full context: #text(style: "italic", fill: rgb("#6c757d"))[Root » Parent » Feature].
      #if selected.len() > 0 [
        Only requirements from #text(fill: green.darken(30%), weight: "bold")[selected features] are shown.
      ]
    ]
  ]
}

// #feature-tree: Render hierarchical feature model with configuration
// Parameters:
//   root: Starting feature ID (default: "ROOT")
//   config: Configuration ID to use (default: uses active config)
//   show-parameters: Whether to display parameter bindings (default: true)
#let feature-tree(root: "ROOT", config: none, show-parameters: true) = context {
  // Get registry from state
  let registry = __registry.get()

  // Determine which configuration to use
  let cfg-id = if config != none {
    config
  } else {
    __active-config.get()
  }

  // Get selected features and bindings from configuration
  let selected = if cfg-id != none and ("CONFIG:" + cfg-id) in registry {
    registry.at("CONFIG:" + cfg-id).selected
  } else {
    ()
  }

  let bindings = if cfg-id != none and ("CONFIG:" + cfg-id) in registry {
    registry.at("CONFIG:" + cfg-id).at("bindings", default: (:))
  } else {
    (:)
  }

  // Get root feature
  let root-feature = registry.at(root, default: none)

  if root-feature == none {
    block(fill: red.lighten(80%), inset: 1em)[
      *Error:* Feature "#root" not found in registry. \
      *Registry keys:* #registry.keys().join(", ") \
      *Registry has #registry.len() items*
    ]
    return
  }

  // Render header (non-breakable)
  block(
    width: 100%,
    fill: luma(245),
    inset: 1em,
    radius: 4pt,
    stroke: 1pt + luma(200)
  )[
    === Feature Tree
    #if cfg-id != none [
      *Configuration:* #cfg-id \
      *Selected features:* #selected.len() of #registry.pairs().filter(p => p.last().type == "feature").len()
    ]
    #if cfg-id == none [
      _(No active configuration – showing all features)_
    ]
  ]

  v(0.5em)

  // Generate unique tree prefix for labels
  let tree-id = __tree-counter.get()
  __tree-counter.update(n => n + 1)
  let tree-prefix = "tree" + str(tree-id) + "-"

  // Render tree content (breakable across pages)
  text(font: "Courier New", size: 0.9em)[
    #__render-tree-node(root-feature, registry, selected, 0, tree-prefix, bindings: bindings, show-parameters: show-parameters)
  ]

  v(0.5em)

  // Render legend (non-breakable)
  block(
    width: 100%,
    fill: luma(250),
    inset: 0.5em,
    radius: 3pt
  )[
    #text(size: 0.85em, fill: gray)[
      *Legend:* ● Feature | ⊕ XOR Group (select only one) | ⊙ OR Group (select any) | #text(fill: gray)[Not Selected] \
      *Selected features by level:* #text(fill: rgb("#1e3a8a"), weight: "bold")[L0] | #text(fill: rgb("#0891b2"), weight: "bold")[L1] | #text(fill: rgb("#059669"), weight: "bold")[L2] | #text(fill: rgb("#d97706"), weight: "bold")[L3] | #text(fill: rgb("#7c3aed"), weight: "bold")[L4] | #text(fill: rgb("#db2777"), weight: "bold")[L5]
    ]
  ]
}

// #feature-tree-detailed: Render hierarchical feature model with descriptions
// Similar to #feature-tree but includes feature body/description text under each node
// Parameters:
//   root: Starting feature ID (default: "ROOT")
//   config: Configuration ID to highlight selected features (default: uses active config)
//   show-descriptions: Whether to show feature descriptions (default: true)
//   show-parameters: Whether to display parameter bindings (default: true)
//   max-depth: Maximum depth to render (none = unlimited, 0 = root only, 1 = root + children, etc.)
#let feature-tree-detailed(root: "ROOT", config: none, show-descriptions: true, show-parameters: true, max-depth: none) = context {
  // Get registry from state
  let registry = __registry.get()

  // Determine which configuration to use
  let cfg-id = if config != none {
    config
  } else {
    __active-config.get()
  }

  // Get selected features and bindings from configuration
  let selected = if cfg-id != none and ("CONFIG:" + cfg-id) in registry {
    registry.at("CONFIG:" + cfg-id).selected
  } else {
    ()
  }

  let bindings = if cfg-id != none and ("CONFIG:" + cfg-id) in registry {
    registry.at("CONFIG:" + cfg-id).at("bindings", default: (:))
  } else {
    (:)
  }

  // Get root feature
  let root-feature = registry.at(root, default: none)

  if root-feature == none {
    block(fill: red.lighten(80%), inset: 1em)[
      *Error:* Feature "#root" not found in registry. \
      *Registry keys:* #registry.keys().join(", ") \
      *Registry has #registry.len() items*
    ]
    return
  }

  // Render header (non-breakable)
  block(
    width: 100%,
    fill: luma(245),
    inset: 1em,
    radius: 4pt,
    stroke: 1pt + luma(200)
  )[
    === Feature Tree (Detailed)
    #grid(
      columns: (auto, auto),
      column-gutter: 2em,
      row-gutter: 0.3em,
      [*Starting Feature:*], [#root],
      [*Max Depth:*], [#if max-depth == none [Unlimited] else [#max-depth]],
      [*Descriptions:*], [#if show-descriptions [Shown] else [Hidden]],
      [*Parameters:*], [#if show-parameters [Shown] else [Hidden]],
      ..if cfg-id != none {
        (
          [*Configuration:*], [#cfg-id],
          [*Selected Features:*], [#text(fill: green.darken(30%), weight: "bold")[#selected.len()] of #registry.pairs().filter(p => p.last().type == "feature").len()]
        )
      } else {
        (
          [*Configuration:*], [_(None – showing all features)_]
        )
      }
    )
  ]

  v(0.5em)

  // Generate unique tree prefix for labels
  let tree-id = __tree-counter.get()
  __tree-counter.update(n => n + 1)
  let tree-prefix = "tree" + str(tree-id) + "-"

  // Render tree content (breakable across pages)
  text(font: "Courier New", size: 0.9em)[
    #__render-tree-node-detailed(root-feature, registry, selected, 0, show-descriptions: show-descriptions, max-depth: max-depth, tree-prefix, bindings: bindings, show-parameters: show-parameters)
  ]

  v(0.5em)

  // Render legend (non-breakable)
  block(
    width: 100%,
    fill: luma(250),
    inset: 0.5em,
    radius: 3pt
  )[
    #text(size: 0.85em, fill: gray)[
      *Legend:* ● Feature | ⊕ XOR Group (select only one) | ⊙ OR Group (select any) | #text(fill: gray)[Not Selected] \
      *Selected features by level:* #text(fill: rgb("#1e3a8a"), weight: "bold")[L0] | #text(fill: rgb("#0891b2"), weight: "bold")[L1] | #text(fill: rgb("#059669"), weight: "bold")[L2] | #text(fill: rgb("#d97706"), weight: "bold")[L3] | #text(fill: rgb("#7c3aed"), weight: "bold")[L4] | #text(fill: rgb("#db2777"), weight: "bold")[L5] \
      #if show-descriptions [
        *│* marks feature description text (indented below feature name)
      ]
    ]
  ]
}

#let coverage-table() = block(fill: luma(240))[Traceability matrix – rendered here]

// #render-use-case: Render a single use case with all details
#let render-use-case(uc) = {
  block(
    width: 100%,
    fill: luma(248),
    inset: 1em,
    radius: 4pt,
    stroke: 1pt + luma(220),
    breakable: true
  )[
    === #uc.title

    #text(size: 0.9em, fill: blue.darken(20%), weight: "bold")[
      ID: #uc.id
    ]

    #if uc.tags.len() > 0 [
      #v(0.3em)
      #text(size: 0.85em)[
        #for (key, value) in uc.tags [
          #text(weight: "bold")[#key:] #value #h(1em)
        ]
      ]
    ]

    #v(0.5em)
    #block(inset: (left: 0.5em))[
      #uc.body
    ]

    #context {
      let links = __get-links(uc.id)
      if links.len() > 0 [
        #v(0.5em)
        #block(
          fill: luma(255),
          inset: 0.5em,
          radius: 3pt,
          stroke: 1pt + blue.lighten(70%)
        )[
          #text(size: 0.85em, fill: blue.darken(30%))[
            *Traceability Links:* \
            #for (link-type, targets) in links [
              #text(weight: "bold")[#link-type:] #targets.join(", ") \
            ]
          ]
        ]
      ]
    }
  ]

  v(0.5em)
}

// #use-case-section: Render all use cases in the registry
#let use-case-section(title: "Use Cases", level: 2) = context {
  let registry = __registry.get()

  let use-cases = registry.pairs()
    .filter(p => p.last().type == "use_case")
    .map(p => p.last())
    .sorted(key: uc => uc.id)

  if use-cases.len() == 0 {
    block(fill: yellow.lighten(80%), inset: 1em)[
      *Note:* No use cases found in registry.
    ]
    return
  }

  block(
    width: 100%,
    fill: blue.lighten(90%),
    inset: 1em,
    radius: 4pt,
    stroke: 2pt + blue.lighten(50%)
  )[
    #heading(level: level)[#title]
    #text(size: 0.9em)[
      This section documents all behavioral scenarios showing how actors interact with the system to achieve their goals.

      *Total use cases:* #use-cases.len()
    ]
  ]

  v(1em)

  for uc in use-cases {
    render-use-case(uc)
  }
}

// #render-block: Render a single SysML block definition with all features
#let render-block(blk) = {
  block(
    width: 100%,
    fill: rgb("#f5f9ff"),
    inset: 1.2em,
    radius: 4pt,
    stroke: 2pt + rgb("#4a90e2"),
    breakable: true
  )[
    === #blk.title

    #text(size: 0.9em, fill: rgb("#2c5aa0"), weight: "bold")[
      «block» #blk.id
    ]

    // General tags (excluding sysml-specific ones)
    #let general-tags = blk.tags.pairs().filter(p => not str(p.first()).starts-with("sysml-"))
    #if general-tags.len() > 0 [
      #v(0.3em)
      #text(size: 0.85em)[
        #for (key, value) in general-tags [
          #text(weight: "bold")[#key:] #value #h(1em)
        ]
      ]
    ]

    // Description
    #if blk.body != none and blk.body != [] [
      #v(0.5em)
      #block(inset: (left: 0.5em))[
        #blk.body
      ]
    ]

    // Properties
    #let properties = blk.tags.at("sysml-properties", default: ())
    #if type(properties) == array and properties.len() > 0 [
      #v(0.7em)
      #block(
        fill: white,
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + luma(220)
      )[
        *Properties* \
        #table(
          columns: (auto, auto, auto, auto),
          stroke: 0.5pt + luma(200),
          inset: 5pt,
          [*Name*], [*Type*], [*Default*], [*Unit*],
          ..properties.map(p => (
            text(font: "Courier New")[#p.name],
            text(fill: blue.darken(20%))[#p.at("type", default: "")],
            text(font: "Courier New", size: 0.85em)[#p.at("default", default: "")],
            text(style: "italic")[#p.at("unit", default: "")]
          )).flatten()
        )
      ]
    ]

    // Operations
    #let operations = blk.tags.at("sysml-operations", default: ())
    #if type(operations) == array and operations.len() > 0 [
      #v(0.7em)
      #block(
        fill: white,
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + luma(220)
      )[
        *Operations* \
        #for op in operations {
          let params = op.at("params", default: "")
          let ret = op.at("returns", default: "void")
          let sig = op.name + "(" + params + "): " + ret
          [+ #text(font: "Courier New", size: 0.9em)[#sig] \ ]
        }
      ]
    ]

    // Ports
    #let ports = blk.tags.at("sysml-ports", default: ())
    #if type(ports) == array and ports.len() > 0 [
      #v(0.7em)
      #block(
        fill: white,
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + luma(220)
      )[
        *Ports* \
        #table(
          columns: (auto, auto, auto),
          stroke: 0.5pt + luma(200),
          inset: 5pt,
          [*Name*], [*Direction*], [*Protocol*],
          ..ports.map(p => (
            text(font: "Courier New")[#p.name],
            text(fill: green.darken(20%))[#p.at("direction", default: "in/out")],
            [#p.at("protocol", default: "")]
          )).flatten()
        )
      ]
    ]

    // Parts (Composition)
    #let parts = blk.tags.at("sysml-parts", default: ())
    #if type(parts) == array and parts.len() > 0 [
      #v(0.7em)
      #block(
        fill: rgb("#fff9e6"),
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + rgb("#ffd966")
      )[
        *Parts (Composition)* \
        #table(
          columns: (auto, auto, auto),
          stroke: 0.5pt + rgb("#e6c200"),
          inset: 5pt,
          [*Part Name*], [*Type*], [*Multiplicity*],
          ..parts.map(p => (
            text(font: "Courier New", fill: rgb("#b8860b"))[#p.name],
            text(font: "Courier New", fill: rgb("#8b4513"))[#p.type],
            text(fill: rgb("#b8860b"))[#p.at("multiplicity", default: "1")]
          )).flatten()
        )
      ]
    ]

    // Connectors (Internal Wiring & Delegation)
    #let connectors = blk.tags.at("sysml-connectors", default: ())
    #if type(connectors) == array and connectors.len() > 0 [
      #v(0.7em)
      #block(
        fill: rgb("#e6f7ff"),
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + rgb("#40a9ff")
      )[
        *Connectors* \
        #table(
          columns: (auto, 1fr, auto, 1fr, auto),
          stroke: 0.5pt + rgb("#91d5ff"),
          inset: 5pt,
          align: (left, left, center, left, left),
          [*From*], [], [], [*To*], [*Flow*],
          ..connectors.map(c => {
            let from-str = c.from
            let to-str = c.to
            let flow = c.at("flow", default: "")
            let name = c.at("name", default: none)

            // Determine if delegation (one side has no dot) or internal (both have dots)
            let from-is-block-port = not from-str.contains(".")
            let to-is-block-port = not to-str.contains(".")
            let is-delegation = from-is-block-port or to-is-block-port

            let arrow = if is-delegation {
              text(fill: rgb("#1890ff"), size: 1.2em)[⇒]
            } else {
              text(fill: rgb("#52c41a"), size: 1.2em)[→]
            }

            let from-cell = text(font: "Courier New", size: 0.85em,
              fill: if from-is-block-port { rgb("#d46b08") } else { rgb("#389e0d") }
            )[#from-str]

            let to-cell = text(font: "Courier New", size: 0.85em,
              fill: if to-is-block-port { rgb("#d46b08") } else { rgb("#389e0d") }
            )[#to-str]

            let flow-cell = if flow != "" {
              text(style: "italic", size: 0.85em)[#flow]
            } else {
              []
            }

            (from-cell, [], arrow, to-cell, flow-cell)
          }).flatten()
        )
        #v(0.3em)
        #text(size: 0.75em, fill: gray)[
          Legend: #text(fill: rgb("#d46b08"))[Block Port] | #text(fill: rgb("#389e0d"))[Part.Port] |
          #text(fill: rgb("#1890ff"))[⇒ Delegation] | #text(fill: rgb("#52c41a"))[→ Internal]
        ]
      ]
    ]

    // References (Associations)
    #let references = blk.tags.at("sysml-references", default: ())
    #if type(references) == array and references.len() > 0 [
      #v(0.7em)
      #block(
        fill: rgb("#f0f0f0"),
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + luma(180)
      )[
        *References (Associations)* \
        #for ref in references [
          → #text(font: "Courier New")[#ref] \
        ]
      ]
    ]

    // Constraints
    #let constraints = blk.tags.at("sysml-constraints", default: ())
    #if type(constraints) == array and constraints.len() > 0 [
      #v(0.7em)
      #block(
        fill: rgb("#fff0f0"),
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + rgb("#ff9999")
      )[
        *Constraints* \
        #for constraint in constraints [
          • #text(font: "Courier New", size: 0.85em, fill: red.darken(20%))[{#constraint}] \
        ]
      ]
    ]

    // Traceability Links
    #context {
      let links = __get-links(blk.id)
      if links.len() > 0 [
        #v(0.7em)
        #block(
          fill: rgb("#e6f3ff"),
          inset: 0.7em,
          radius: 3pt,
          stroke: 1pt + rgb("#4a90e2")
        )[
          #text(size: 0.85em, fill: rgb("#2c5aa0"))[
            *Traceability Links:* \
            #for (link-type, targets) in links [
              #text(weight: "bold")[#link-type:] #targets.join(", ") \
            ]
          ]
        ]
      ]
    }
  ]

  v(0.5em)
}

// #block-definition-section: Render all block definitions in the registry
#let block-definition-section(title: "System Architecture – Block Definitions", level: 2) = context {
  let registry = __registry.get()

  let blocks = registry.pairs()
    .filter(p => p.last().type == "block_definition")
    .map(p => p.last())
    .sorted(key: b => b.id)

  if blocks.len() == 0 {
    block(fill: yellow.lighten(80%), inset: 1em)[
      *Note:* No block definitions found in registry.
    ]
    return
  }

  block(
    width: 100%,
    fill: rgb("#e8f4f8"),
    inset: 1em,
    radius: 4pt,
    stroke: 2pt + rgb("#4a90e2")
  )[
    #heading(level: level)[#title]
    #text(size: 0.9em)[
      This section documents the system architecture using SysML block definitions.
      Each block represents a system component with its properties, operations, ports,
      composition relationships, and constraints.

      *Total blocks:* #blocks.len()
    ]
  ]

  v(1em)

  for blk in blocks {
    render-block(blk)
  }
}

// #block-definition-of-block: Render a single block definition by ID
// ──────────────────────────────────────────────────────────────────────────────
// Purpose:      Display a specific block definition from the registry
// Parameter:    block-id - The ID of the block to retrieve and render
// Returns:      The rendered block or panics if not found
#let block-definition-of-block(block-id) = context {
  let registry = __registry.get()
  let blk = registry.at(block-id, default: none)

  if blk == none {
    let available-blocks = registry.pairs()
      .filter(p => p.last().type == "block_definition")
      .map(p => p.first())
      .join(", ")
    panic("Block definition '" + block-id + "' not found in registry. Available block IDs: " + available-blocks)
  }

  if blk.type != "block_definition" {
    panic("Element '" + block-id + "' exists but is not a block definition. Type: " + blk.type)
  }

  render-block(blk)
}

// #render-ibd: Render a single internal block diagram with all details
#let render-ibd(ibd) = {
  block(
    width: 100%,
    fill: rgb("#f0f8ff"),
    inset: 1.2em,
    radius: 4pt,
    stroke: 2pt + rgb("#4169e1"),
    breakable: true
  )[
    === #ibd.title

    #text(size: 0.9em, fill: rgb("#191970"), weight: "bold")[
      «internal block diagram» #ibd.id
    ]

    // General tags (excluding ibd-specific ones)
    #let general-tags = ibd.tags.pairs().filter(p => not str(p.first()).starts-with("ibd-"))
    #if general-tags.len() > 0 [
      #v(0.3em)
      #text(size: 0.85em)[
        #for (key, value) in general-tags [
          #text(weight: "bold")[#key:] #value #h(1em)
        ]
      ]
    ]

    // Description
    #if ibd.body != none and ibd.body != [] [
      #v(0.5em)
      #block(inset: (left: 0.5em))[
        #ibd.body
      ]
    ]

    // Ports
    #let ports = ibd.tags.at("ibd-ports", default: ())
    #if type(ports) == array and ports.len() > 0 [
      #v(0.7em)
      #block(
        fill: white,
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + luma(220)
      )[
        *Boundary Ports* \
        #table(
          columns: (auto, auto, auto),
          stroke: 0.5pt + luma(200),
          inset: 5pt,
          [*Name*], [*Direction*], [*Protocol*],
          ..ports.map(p => (
            text(font: "Courier New")[#p.name],
            text(fill: green.darken(20%))[#p.at("direction", default: "in/out")],
            [#p.at("protocol", default: "")]
          )).flatten()
        )
      ]
    ]

    // Parts (Composition)
    #let parts = ibd.tags.at("ibd-parts", default: ())
    #if type(parts) == array and parts.len() > 0 [
      #v(0.7em)
      #block(
        fill: rgb("#fff9e6"),
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + rgb("#ffd966")
      )[
        *Parts* \
        #table(
          columns: (auto, auto, auto),
          stroke: 0.5pt + rgb("#e6c200"),
          inset: 5pt,
          [*Part Name*], [*Type*], [*Multiplicity*],
          ..parts.map(p => (
            text(font: "Courier New", fill: rgb("#b8860b"))[#p.name],
            text(font: "Courier New", fill: rgb("#8b4513"))[#p.type],
            text(fill: rgb("#b8860b"))[#p.at("multiplicity", default: "1")]
          )).flatten()
        )
      ]
    ]

    // Connectors (Internal Wiring & Delegation)
    #let connectors = ibd.tags.at("ibd-connectors", default: ())
    #if type(connectors) == array and connectors.len() > 0 [
      #v(0.7em)
      #block(
        fill: rgb("#e6f7ff"),
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + rgb("#40a9ff")
      )[
        *Connectors* \
        #table(
          columns: (auto, 1fr, auto, 1fr, auto),
          stroke: 0.5pt + rgb("#91d5ff"),
          inset: 5pt,
          align: (left, left, center, left, left),
          [*From*], [], [], [*To*], [*Flow*],
          ..connectors.map(c => {
            let from-str = c.from
            let to-str = c.to
            let flow = c.at("flow", default: "")

            // Determine if delegation (one side has no dot) or internal (both have dots)
            let from-is-boundary = not from-str.contains(".")
            let to-is-boundary = not to-str.contains(".")
            let is-delegation = from-is-boundary or to-is-boundary

            let arrow = if is-delegation {
              text(fill: rgb("#1890ff"), size: 1.2em)[⇒]
            } else {
              text(fill: rgb("#52c41a"), size: 1.2em)[→]
            }

            let from-cell = text(font: "Courier New", size: 0.85em,
              fill: if from-is-boundary { rgb("#d46b08") } else { rgb("#389e0d") }
            )[#from-str]

            let to-cell = text(font: "Courier New", size: 0.85em,
              fill: if to-is-boundary { rgb("#d46b08") } else { rgb("#389e0d") }
            )[#to-str]

            let flow-cell = if flow != "" {
              text(style: "italic", size: 0.85em)[#flow]
            } else {
              []
            }

            (from-cell, [], arrow, to-cell, flow-cell)
          }).flatten()
        )
        #v(0.3em)
        #text(size: 0.75em, fill: gray)[
          Legend: #text(fill: rgb("#d46b08"))[Boundary Port] | #text(fill: rgb("#389e0d"))[Part.Port] |
          #text(fill: rgb("#1890ff"))[⇒ Delegation] | #text(fill: rgb("#52c41a"))[→ Internal]
        ]
      ]
    ]

    // References
    #let references = ibd.tags.at("ibd-references", default: ())
    #if type(references) == array and references.len() > 0 [
      #v(0.7em)
      #block(
        fill: rgb("#f0f0f0"),
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + luma(180)
      )[
        *References* \
        #for ref in references [
          → #text(font: "Courier New")[#ref] \
        ]
      ]
    ]

    // Traceability Links
    #context {
      let links = __get-links(ibd.id)
      if links.len() > 0 [
        #v(0.7em)
        #block(
          fill: rgb("#e6f3ff"),
          inset: 0.7em,
          radius: 3pt,
          stroke: 1pt + rgb("#4169e1")
        )[
          #text(size: 0.85em, fill: rgb("#191970"))[
            *Traceability Links:* \
            #for (link-type, targets) in links [
              #text(weight: "bold")[#link-type:] #targets.join(", ") \
            ]
          ]
        ]
      ]
    }
  ]

  v(0.5em)
}

// #internal-block-diagram-section: Render all internal block diagrams in the registry
#let internal-block-diagram-section(title: "Internal Block Diagrams", level: 2) = context {
  let registry = __registry.get()

  let ibds = registry.pairs()
    .filter(p => p.last().type == "internal_block_diagram")
    .map(p => p.last())
    .sorted(key: ibd => ibd.id)

  if ibds.len() == 0 {
    block(fill: yellow.lighten(80%), inset: 1em)[
      *Note:* No internal block diagrams found in registry.
    ]
    return
  }

  block(
    width: 100%,
    fill: rgb("#e6f0ff"),
    inset: 1em,
    radius: 4pt,
    stroke: 2pt + rgb("#4169e1")
  )[
    #heading(level: level)[#title]
    #text(size: 0.9em)[
      This section documents the internal structure of system blocks using SysML
      Internal Block Diagrams (IBDs). Each diagram shows how parts are composed
      within a block and how they are interconnected via ports and connectors.

      *Total diagrams:* #ibds.len()
    ]
  ]

  v(1em)

  for ibd in ibds {
    render-ibd(ibd)
  }
}

// #visualize-ibd: Generate visual diagram from internal_block_diagram element
// ──────────────────────────────────────────────────────────────────────────────
// Purpose:      Create a visual IBD from an internal_block_diagram definition
// Parameter:    ibd-id - The ID of the IBD element to visualize
// Returns:      A Fletcher diagram showing the internal structure
#let visualize-ibd(ibd-id) = context {
  let registry = __registry.get()
  let ibd = registry.at(ibd-id, default: none)

  if ibd == none or ibd.type != "internal_block_diagram" {
    block(fill: red.lighten(80%), inset: 1em)[
      *Error:* Internal block diagram "#ibd-id" not found in registry.
    ]
    return
  }

  let parts = ibd.tags.at("ibd-parts", default: ())
  let ports = ibd.tags.at("ibd-ports", default: ())
  let connectors = ibd.tags.at("ibd-connectors", default: ())

  // Generate Fletcher diagram with SysML block frame
  let cols = if parts.len() > 0 { calc.ceil(calc.sqrt(parts.len())) } else { 1 }
  let rows = if parts.len() > 0 { calc.ceil(parts.len() / cols) } else { 1 }

  diagram(
    node-stroke: 1pt,
    edge-stroke: 1pt,
    spacing: (3em, 2em),
    {
      // Frame calculations
      let margin-x = 2.5
      let margin-y = 2.0

      let frame-left = -margin-x
      let frame-right = (cols - 1) + margin-x
      let frame-top = -margin-y
      let frame-bottom = (rows - 1) + margin-y

      let frame-center-x = (frame-left + frame-right) / 2
      let frame-center-y = (frame-top + frame-bottom) / 2

      let frame-width = (frame-right - frame-left) * 3em + 3em
      let frame-height = (frame-bottom - frame-top) * 2em + 2em

      // Block frame
      node(
        (frame-center-x, frame-center-y),
        [],
        width: frame-width,
        height: frame-height,
        stroke: 2pt + black,
        fill: rgb("#fafafa"),
        corner-radius: 0pt,
        name: "block-frame"
      )

      // Block name label
      node(
        (frame-center-x, frame-top - 0.5),
        [#text(size: 0.9em, weight: "bold")[#ibd.title] \ #text(size: 0.7em, style: "italic")[«#ibd.id»]],
        fill: white,
        stroke: none
      )

      // Position ports on frame boundary
      let port-offset = 0.3
      for (i, port) in ports.enumerate() {
        let port-pos = if port.direction == "in" {
          (-port-offset, i * 1.2)
        } else {
          (cols - 1 + port-offset, i * 1.2)
        }

        node(
          port-pos,
          [#text(size: 0.65em)[#port.name]],
          fill: rgb("#ffe7ba"),
          stroke: 2pt + rgb("#d46b08"),
          corner-radius: 0pt,
          width: 1.8em,
          height: 0.9em,
          name: port.name
        )
      }

      // Create nodes for parts
      let row = 0
      let col = 0

      for (i, part) in parts.enumerate() {
        let pos = (col, row)

        node(
          pos,
          [#text(size: 0.8em, weight: "bold")[#part.name] \ #text(size: 0.7em, style: "italic")[:#part.type]],
          fill: rgb("#fff9e6"),
          stroke: rgb("#ffd966"),
          corner-radius: 3pt,
          name: part.name
        )

        col += 1
        if col >= cols {
          col = 0
          row += 1
        }
      }

      // Create edges for connectors
      for conn in connectors {
        let from-str = conn.from
        let to-str = conn.to
        let flow = conn.at("flow", default: "")

        // Handle part-to-part connections
        if from-str.contains(".") and to-str.contains(".") {
          let from-part = from-str.split(".").first()
          let to-part = to-str.split(".").first()

          let from-idx = parts.position(p => p.name == from-part)
          let to-idx = parts.position(p => p.name == to-part)

          if from-idx != none and to-idx != none {
            let from-col = calc.rem(from-idx, cols)
            let from-row = calc.quo(from-idx, cols)
            let to-col = calc.rem(to-idx, cols)
            let to-row = calc.quo(to-idx, cols)

            let mark = if flow != "" { "-|>" } else { "-" }

            edge(
              (from-col, from-row),
              (to-col, to-row),
              mark,
              label: if flow != "" { text(size: 0.6em, style: "italic")[#flow] }
            )
          }
        }
      }
    }
  )
}

// #generate-ibd: Automatically generate Internal Block Diagram from block definition
// ──────────────────────────────────────────────────────────────────────────────
// Purpose:      Create a visual IBD showing parts, ports, and connectors
// Parameter:    block-id - The ID of the block to visualize
// Returns:      A Fletcher diagram showing the internal structure
#let generate-ibd(block-id) = context {
  let registry = __registry.get()
  let blk = registry.at(block-id, default: none)

  if blk == none {
    block(fill: red.lighten(80%), inset: 1em)[
      *Error:* Block "#block-id" not found in registry.
    ]
    return
  }

  let parts = blk.tags.at("sysml-parts", default: ())
  let ports = blk.tags.at("sysml-ports", default: ())
  let connectors = blk.tags.at("sysml-connectors", default: ())

  // Generate Fletcher diagram with SysML block frame
  let cols = if parts.len() > 0 { calc.ceil(calc.sqrt(parts.len())) } else { 1 }
  let rows = if parts.len() > 0 { calc.ceil(parts.len() / cols) } else { 1 }

  diagram(
    node-stroke: 1pt,
    edge-stroke: 1pt,
    spacing: (3em, 2em),
    {
      // Draw block frame (outer boundary) - SysML IBD convention
      // Calculate frame to encompass all parts with proper margins
      // Parts occupy positions from (0,0) to (cols-1, rows-1) in grid coordinates
      // With spacing of (3em, 2em), we need to calculate the actual size

      // Frame should be drawn FIRST (behind everything)
      // Add generous margins around the grid of parts
      let margin-x = 2.5  // Horizontal margin in grid units
      let margin-y = 2.0  // Vertical margin in grid units

      let frame-left = -margin-x
      let frame-right = (cols - 1) + margin-x
      let frame-top = -margin-y
      let frame-bottom = (rows - 1) + margin-y

      let frame-center-x = (frame-left + frame-right) / 2
      let frame-center-y = (frame-top + frame-bottom) / 2

      // Calculate frame dimensions based on grid spacing
      // Note: Fletcher uses the spacing parameter (3em, 2em) for node separation
      let frame-width = (frame-right - frame-left) * 3em + 3em
      let frame-height = (frame-bottom - frame-top) * 2em + 2em

      // Block frame rectangle - drawn FIRST so it appears behind parts
      node(
        (frame-center-x, frame-center-y),
        [],
        width: frame-width,
        height: frame-height,
        stroke: 2pt + black,
        fill: rgb("#fafafa"),  // Very light gray background
        corner-radius: 0pt,
        name: "block-frame"
      )

      // Block name label at top of frame (outside the frame)
      node(
        (frame-center-x, frame-top - 0.5),
        [#text(size: 0.9em, weight: "bold")[#blk.title] \ #text(size: 0.7em, style: "italic")[«#blk.id»]],
        fill: white,
        stroke: none
      )

      // Position block ports on the frame boundary (outside parts area)
      let port-offset = 0.3  // Distance from edge of parts grid
      for (i, port) in ports.enumerate() {
        let port-pos = if port.direction == "in" {
          // Input ports on left edge
          (-port-offset, i * 1.2)
        } else {
          // Output ports on right edge
          (cols - 1 + port-offset, i * 1.2)
        }

        node(
          port-pos,
          [#text(size: 0.65em)[#port.name]],
          fill: rgb("#ffe7ba"),
          stroke: 2pt + rgb("#d46b08"),
          corner-radius: 0pt,
          width: 1.8em,
          height: 0.9em,
          name: port.name
        )
      }

      // Create nodes for each part inside the block frame
      let row = 0
      let col = 0

      for (i, part) in parts.enumerate() {
        let pos = (col, row)

        node(
          pos,
          [#text(size: 0.8em, weight: "bold")[#part.name] \ #text(size: 0.7em, style: "italic")[:#part.type]],
          fill: rgb("#fff9e6"),
          stroke: rgb("#ffd966"),
          corner-radius: 3pt,
          name: part.name
        )

        col += 1
        if col >= cols {
          col = 0
          row += 1
        }
      }

      // Create edges for connectors (part-to-part only for now)
      for conn in connectors {
        let from-str = conn.from
        let to-str = conn.to
        let flow = conn.at("flow", default: "")

        // Only show part-to-part connections (both have dots)
        if from-str.contains(".") and to-str.contains(".") {
          // Extract part names
          let from-part = from-str.split(".").first()
          let to-part = to-str.split(".").first()

          // Find part indices
          let from-idx = parts.position(p => p.name == from-part)
          let to-idx = parts.position(p => p.name == to-part)

          if from-idx != none and to-idx != none {
            let from-col = calc.rem(from-idx, cols)
            let from-row = calc.quo(from-idx, cols)
            let to-col = calc.rem(to-idx, cols)
            let to-row = calc.quo(to-idx, cols)

            // SysML-compliant notation:
            // - Solid line with FILLED triangle for item flow
            let mark = if flow != "" { "-|>" } else { "-" }

            edge(
              (from-col, from-row),
              (to-col, to-row),
              mark,
              label: if flow != "" { text(size: 0.6em, style: "italic")[#flow] }
            )
          }
        }
      }
    }
  )
}


// Re-export simple diagram functions
#import "simple-diagrams.typ": simple-ibd

// Import feature model visualization
#import "feature-diagram.typ": feature-model-diagram

// Import validation module with plugin support
// Import with prefixes to allow wrapping with validation options
#import "validation.typ": (
  plugin-available,
  validate-traceability as __validate-traceability-wasm,
  validate-specification as __validate-specification-wasm,
  validation-status,
  format-validation-errors,
)

// Create wrapper functions that respect validation options
#let validate-traceability(registry, links, active-config: none) = context {
  let opts = __validation-options.get()
  if not opts.sat {
    // Return a skipped result
    return (
      passed: true,
      total_elements: registry.len(),
      message: "SAT validation skipped (disabled in validation options)",
      validation_mode: "basic"
    )
  }
  __validate-traceability-wasm(registry, links, active-config: active-config)
}

#let validate-specification(registry: (:), links: (), active-config: none) = context {
  let opts = __validation-options.get()
  if not opts.sat {
    // Return a skipped result
    return (
      passed: true,
      total_elements: registry.len(),
      message: "SAT validation skipped (disabled in validation options). Basic validations (links, parameters, interfaces) were performed separately.",
      validation_mode: "basic"
    )
  }
  __validate-specification-wasm(registry: registry, links: links, active-config: active-config)
}

// Import and initialize parameter visualization module
#import "parameter-visualization.typ": make-parameter-visualizations

// Create parameter visualization functions with access to registry state
#let __param-viz = make-parameter-visualizations(__registry, __active-config)

// Export visualization functions
#let render-parameter-schema = __param-viz.render-parameter-schema
#let render-all-parameter-schemas = __param-viz.render-all-parameter-schemas
#let render-parameter-bindings = __param-viz.render-parameter-bindings
#let render-all-parameter-bindings = __param-viz.render-all-parameter-bindings
#let render-feature-constraints = __param-viz.render-feature-constraints
#let render-all-constraints = __param-viz.render-all-constraints
#let render-constraint-summary = __param-viz.render-constraint-summary
#let render-parameter-report = __param-viz.render-parameter-report
