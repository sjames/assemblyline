// main.typ ← compile this file to get the full specification PDF
#import "lib/lib.typ": *
#import "@preview/cetz:0.4.2": *
#import "traceability-graph.typ": traceability-graph

#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 2.5cm),
)
#set text(size: 11pt)
#set heading(numbering: "1.1")

// Include features
#include "features/root.typ"
#include "features/authentication.typ"
#include "features/authorization.typ"
#include "features/user-management.typ"
#include "features/session-management.typ"
#include "features/audit-logging.typ"
#include "features/data-protection.typ"
#include "features/api-security.typ"
#include "features/monitoring.typ"

// Include use cases and diagrams
#include "use-cases/login.typ"
#include "use-cases/authorization.typ"
#include "diagrams/login-sequence.typ"
#include "diagrams/auth-service-ibd.typ"

// Include architecture
#include "design/architecture.typ"

// Include configurations
#include "configurations.typ"

#set-active-config("CFG-EU")

#align(center)[
  #text(size: 24pt, weight: "bold")[
    Enterprise Security Platform
  ]

  #v(0.5em)

  #text(size: 14pt)[
    Product Line Specification
  ]

  #v(0.5em)

  #text(size: 11pt, style: "italic")[
    Version 1.0 | December 2025
  ]
]

#pagebreak()

#outline(depth: 3, indent: 1em)

#pagebreak()

= Executive Summary

This document specifies the Enterprise Security Platform product line, a comprehensive authentication, authorization, and user management system designed for compliance with GDPR, SOC-2, ISO-27001, and OWASP security standards.

The platform provides a configurable feature set supporting multiple market segments from small businesses to enterprise deployments.

#pagebreak()

= Product Line Feature Model

#feature-tree-with-requirements()

#pagebreak()

= Configurations

The product line supports multiple configurations for different market segments and compliance requirements.

== European Market Configuration (CFG-EU)

Target market: European Union
- GDPR compliance mandatory
- Mobile push authentication for better UX
- Redis-based sessions for scalability
- Centralized logging (ELK stack)
- ABAC for fine-grained access control

== North American Market Configuration (CFG-NA)

Target market: North America
- SOC-2 compliance focus
- Biometric authentication
- Database sessions for persistence
- SIEM integration for enterprise security
- Hierarchical RBAC

#pagebreak()

= Use Cases

#use-case-section()

#pagebreak()

= System Architecture

#block-definition-section()

#pagebreak()

#block-definition-of-block("BLK-SYSTEM")

= Internal Block Diagrams (Manual Definitions)

These diagrams define internal block structures independently from block definitions,
allowing for focused architectural views and different levels of detail.

#internal-block-diagram-section()

== Visual Diagrams

The manually defined IBDs can also be visualized using the Fletcher diagramming library:

=== IBD-AUTH-SERVICE Visualization

#visualize-ibd("IBD-AUTH-SERVICE")

#pagebreak()

= Internal Block Diagrams (Auto-Generated)

These diagrams are automatically generated from the block definitions, showing the internal structure, parts, and connectors.

== BLK-AUTH-SERVICE Internal Block Diagram

#generate-ibd("BLK-AUTH-SERVICE")

== BLK-SYSTEM Internal Block Diagram

#generate-ibd("BLK-SYSTEM")

#pagebreak()

= Validation Report

// Validate that all link targets exist
#validate-links()

#context {
  // Get the current state of all three variables
  let registry = __registry.get()
  let links = __links.get()
  let active_config = __active-config.get()

  // DEBUG: Show what we're getting
  heading(level: 2)[Debug Information]
  [
    *Registry:*
    - Type: #type(registry)
    - Element count: #registry.keys().len()
    - Sample keys: #registry.keys().slice(0, calc.min(5, registry.keys().len())).join(", ")

    *Links:*
    - Type: #type(links)
    - Count: #links.len()
    - Sample: #repr(links.slice(0, calc.min(3, links.len())))
  ]

  heading(level: 3)[All Links Detail]
  [
    #for link in links [
      - Source: #link.source, Type: #link.at("type"), Target: #link.target
    ]
  ]

  heading(level: 3)[Use Cases in Registry]
  [
    #for (id, elem) in registry.pairs() {
      if elem.type == "use_case" [
        - #id: #elem.title
      ]
    }
  ]

  heading(level: 3)[Requirements in Registry (first 20)]
  [
    #let req_count = 0
    #for (id, elem) in registry.pairs() {
      if elem.type == "req" and req_count < 20 {
        [- #id: #elem.at("body", default: "")]
        req_count = req_count + 1
      }
    }
  ]


  [
    *Active Config:*
    - Type: #type(active_config)
    - Value: #repr(active_config)
  ]

  // Load the WASM plugin
  let plugin = plugin("assembly_plugin/target/wasm32-unknown-unknown/release/assembly_plugin.wasm")

  // Prepare the input structure for the plugin
  let input = (
    registry: registry,
    links: links,
    active_config: active_config,
  )

  // Serialize to JSON and convert to bytes
  let input_json = json.encode(input)

  // DEBUG: Show JSON snippet
  let json_preview = input_json.slice(0, calc.min(1000, input_json.len()))
  [
    *JSON Output:*
    - Length: #input_json.len() bytes
    - First 1000 chars:

    #raw(json_preview, lang: "json", block: true)
  ]

  let input_bytes = bytes(input_json)

  // Call the validate_rules function in the WASM plugin
  let result_bytes = plugin.validate_rules(input_bytes)

  // Decode the result (pass bytes directly to json)
  let result = json(result_bytes)

  // Display the validation results
  heading(level: 2)[Validation Summary]

  [
    *Status:* #if result.passed [✓ PASSED] else [✗ FAILED]

    *Total Elements:* #result.total_elements

    *Message:* #result.message
  ]

  // If result failed, I want to cause a compilation error to halt the build
  {
    if not result.passed {
    panic("Validation failed: " + result.message)
    }
  }



  // Example Block definition diagram




}

#pagebreak()

= Traceability Graph (Debug)

#traceability-graph()


