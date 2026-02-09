// feature-model-visualization-demo.typ
// Demonstration of the new FeatureIDE-style feature model visualization

#import "packages/preview/assemblyline/main/lib/lib.typ": *

// Set up landscape page for horizontal tree layout
#set page(
  width: 297mm,   // A4 landscape width
  height: 210mm,  // A4 landscape height
  margin: 1cm
)

#set text(font: "Arial", size: 11pt)
#set heading(numbering: "1.")

// Include all features
#include "features/root.typ"
#include "features/sensors.typ"
#include "features/adas-functions.typ"
#include "features/hmi.typ"
#include "features/ecu.typ"

// Include configurations
#include "configurations/configs.typ"

// Title page
#align(center)[
  #text(size: 20pt, weight: "bold")[Feature Model Visualization Demo]
  #v(1em)
  #text(size: 14pt)[FeatureIDE-Style Horizontal Tree Layout]
  #v(2em)
  #text(size: 10pt)[
    AssemblyLine Modeling Language \
    Generated: #datetime.today().display()
  ]
]

#pagebreak()

// Table of contents
#outline(depth: 2)

#pagebreak()

= Feature Model Visualizations

== Base Configuration (CFG-BASE) - With Root Node

This shows the BASE ADAS safety package configuration with only essential features selected.

#feature-model-diagram(
  root: "ROOT",
  config: "CFG-BASE",
  registry-state: __registry,
  active-config-state: __active-config,
  show-root: true,
  show-legend: true
)

#pagebreak()

== Base Configuration (CFG-BASE) - Without Root Node (Space-Saving)

Same configuration but with the root node hidden to save horizontal space.

#feature-model-diagram(
  root: "ROOT",
  config: "CFG-BASE",
  registry-state: __registry,
  active-config-state: __active-config,
  show-root: false,
  show-legend: true
)

#pagebreak()

== Premium Configuration (CFG-PREMIUM)

This shows the PREMIUM ADAS package with advanced features enabled.

#feature-model-diagram(
  root: "ROOT",
  config: "CFG-PREMIUM",
  registry-state: __registry,
  active-config-state: __active-config,
  show-legend: true
)

#pagebreak()

== Full Feature Model (No Configuration) - Scaled to 70%

This shows the complete feature model without any configuration highlighting, scaled to 70% to fit more compactly.

#feature-model-diagram(
  root: "ROOT",
  config: none,
  registry-state: __registry,
  active-config-state: __active-config,
  show-root: false,
  scale-factor: 70%,
  show-legend: true
)

#pagebreak()

= Comparison: Traditional vs. New Visualization

== Traditional Text-Based Tree (Vertical Layout)

This is the existing `#feature-tree()` function:

#feature-tree(root: "ROOT", config: "CFG-BASE")

#pagebreak()

== New FeatureIDE-Style Diagram (Horizontal Layout)

This is the new `#feature-model-diagram()` function:

#feature-model-diagram(
  root: "ROOT",
  config: "CFG-BASE",
  registry-state: __registry,
  active-config-state: __active-config,
  show-legend: true
)
