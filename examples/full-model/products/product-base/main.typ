#import "../../packages/preview/assemblyline/main/lib/lib.typ": *

// Page setup
#set page(paper: "a4", margin: (x: 2.5cm, y: 2.5cm))
#set text(size: 11pt)
#set heading(numbering: "1.1")

// Include specification files (shared across products)
#include "../../features/root.typ"
#include "../../features/sensors.typ"
#include "../../features/adas-functions.typ"
#include "../../features/hmi.typ"
#include "../../features/ecu.typ"

#include "../../architecture/system-architecture.typ"
#include "../../tests/test-specification.typ"
#include "../../configurations/configs.typ"

// Activate BASE configuration
#set-active-config("CFG-BASE")

// Title page
#align(center)[
  #text(size: 24pt, weight: "bold")[ADAS Base Safety Package]
  #v(1em)
  #text(size: 16pt)[Product Specification]
  #v(1em)
  #text(size: 12pt)[Configuration: CFG-BASE]
  #v(2em)
  #text(size: 10pt)[
    Version 1.0 \
    Document ID: ADAS-BASE-SPEC-001 \
    ASIL Level: D \
    Generated: #datetime.today().display()
  ]
]

#pagebreak()

// Table of contents
#outline(depth: 3, indent: 1em)
#pagebreak()

// Executive summary
= Executive Summary

This document specifies the *Base Safety Package* of the ADAS product line.
This configuration targets entry-level B/C-segment vehicles requiring Euro NCAP 4-star minimum rating.

*Key Features*:
- Single forward-facing camera
- Short-range radar (80m)
- Lane Departure Warning (LDW) - UN R130 compliant
- Automatic Emergency Braking (AEB) - UN R152 compliant
- Instrument cluster HMI
- Single-core ASIL-B processor

*Target Cost*: 850 EUR

*Target Vehicles*: Compact cars (B/C-segment) with cost-sensitive safety requirements.

*Compliance*: UN R152 (AEB), UN R130 (LDW), Euro NCAP 4-star minimum

#pagebreak()

// Feature model
= Product Line Feature Model

#feature-tree-with-requirements()

#pagebreak()

// Configuration details
= Configuration: Base Safety Package

#context {
  let registry = __registry.get()
  let config = registry.at("CONFIG:CFG-BASE")

  [
    *Configuration ID*: #config.id \
    *Market*: #config.tags.at("market", default: "N/A") \
    *Vehicle Segment*: #config.tags.at("segment", default: "N/A") \
    *Price Point*: #config.tags.at("price-point", default: "N/A") \
    *Target Cost*: #config.tags.at("target-cost", default: "N/A") \
    *Euro NCAP*: #config.tags.at("euro-ncap", default: "N/A") \
    *Max ASIL*: #config.tags.at("asil-max", default: "N/A")

    *Selected Features*:
  ]

  for feature_id in config.selected [
    - #feature_id
  ]
}

#pagebreak()

// System architecture
= System Architecture

#block-definition-section()

#pagebreak()

// Test specification
= Test Specification

#context {
  let registry = __registry.get()
  let tests = registry.pairs()
    .filter(p => p.last().type == "test_case")
    .map(p => p.last())

  for test in tests {
    heading(level: 2, test.title)
    test.body
  }
}

#pagebreak()

// Validation report
= Validation Report

== Link Validation
#validate-links()

== Specification Validation

#context {
  let registry = __registry.get()
  let links = __links.get()
  let active_config = __active-config.get()

  let result = validate-specification(
    registry: registry,
    links: links,
    active-config: active_config
  )

  if result.at("passed", default: false) {
    text(fill: green)[✓ All validation checks passed]
  } else {
    text(fill: red)[✗ Validation failed]

    let message = result.at("message", default: "Unknown validation error")
    block(
      inset: 0.5em,
      fill: rgb("#ffe6e6"),
      radius: 0.25em,
      [*Validation Errors:* #message]
    )

    panic("BUILD FAILED: Validation errors detected")
  }
}
