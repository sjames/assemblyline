// feature-model-standalone.typ
// Single-page standalone feature model visualization
// Perfect for presentations, posters, or quick reference

#import "packages/preview/assemblyline/main/lib/lib.typ": *

// Landscape page for wide feature trees
#set page(
  width: 420mm,   // A3 landscape width (or use 297mm for A4)
  height: 297mm,  // A3 landscape height (or use 210mm for A4)
  margin: 1.5cm
)

#set text(font: "Arial", size: 10pt)

// Include all features
#include "features/root.typ"
#include "features/sensors.typ"
#include "features/adas-functions.typ"
#include "features/hmi.typ"
#include "features/ecu.typ"

// Include configurations
#include "configurations/configs.typ"

// Title header (minimal)
#align(center)[
  #text(size: 18pt, weight: "bold")[ADAS Product Line Feature Model]
  #v(0.3em)
  #text(size: 11pt, fill: gray)[Configuration: Premium Package (CFG-PREMIUM)]
]

#v(1em)

// Main feature model diagram
#feature-model-diagram(
  root: "ROOT",
  config: "CFG-PREMIUM",  // Change this to show different configurations
  registry-state: __registry,
  active-config-state: __active-config,
  show-legend: true
)
