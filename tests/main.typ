// main.typ ← compile this file to get the full specification PDF
#import "packages/preview/assemblyline/main/lib/lib.typ": *
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

= Simple IBD Test (DiagramGrid)

These simplified diagrams use the `diagramgrid` package to render structural composition views.

== From IBD Definition

#simple-ibd("IBD-AUTH-SERVICE")

== From Block Definition

#simple-ibd("BLK-AUTH-SERVICE")

== From Block Definition (BLK-SYSTEM)

#simple-ibd("BLK-SYSTEM")

== Inline Definition

#simple-ibd(
  title: "Custom Block",
  parts: (
    (name: "ComponentA", type: "TypeA"),
    (name: "ComponentB", type: "TypeB"),
    (name: "ComponentC", type: "TypeC"),
  ),
)

== Column Layout with Multiplicity

#simple-ibd(
  title: "Vertical Layout Example",
  parts: (
    (name: "Layer1", type: "BLK-TOP", multiplicity: "1"),
    (name: "Layer2", type: "BLK-MIDDLE", multiplicity: "1..*"),
    (name: "Layer3", type: "BLK-BOTTOM", multiplicity: "0..1"),
  ),
  direction: "column",
  show-multiplicity: true,
)

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

  // Run validation using the library's wrapper function
  let result = validate-specification(
    registry: registry,
    links: links,
    active-config: active_config
  )

  // Display the validation results
  heading(level: 2)[Validation Summary]

  [
    *Status:* #validation-status(result)

    *Total Elements:* #result.at("total_elements", default: 0)

    *Message:* #result.at("message", default: "No validation message")
  ]

  // Display any validation errors
  format-validation-errors(result)

  // If validation failed, halt the build immediately
  if not result.at("passed", default: false) {
    panic(
      "BUILD FAILED: Validation errors detected\n\n" +
      result.at("message", default: "Unknown validation error") +
      "\n\nFix validation errors before building the specification."
    )
  }



  // Example Block definition diagram




}

#pagebreak()

= Traceability Graph (Debug)

#traceability-graph()


