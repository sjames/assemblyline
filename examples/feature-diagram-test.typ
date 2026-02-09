// Test for feature diagram improvements:
// 1. Hiding root node (show-root: false)
// 2. Scaling to fit page (scale-factor)

#import "../packages/preview/assemblyline/main/lib/lib.typ": *

#set page(width: 210mm, height: 297mm, margin: 1cm)

// Define a simple feature model
#feature("Vehicle System", id: "ROOT", parent: none, concrete: false)[
  Root feature representing the entire vehicle system.
]

#feature("Powertrain", id: "F-POWER", parent: "ROOT", group: "XOR")[
  Vehicle powertrain system.
]

#feature("Electric", id: "F-ELEC", parent: "F-POWER")[
  Electric powertrain with battery.
]

#feature("Hybrid", id: "F-HYBRID", parent: "F-POWER")[
  Hybrid powertrain combining electric and combustion.
]

#feature("Combustion", id: "F-COMBUST", parent: "F-POWER")[
  Traditional combustion engine.
]

#feature("ADAS", id: "F-ADAS", parent: "ROOT", group: "OR")[
  Advanced driver assistance systems.
]

#feature("Lane Keeping", id: "F-LK", parent: "F-ADAS")[
  Lane keeping assistance system.
]

#feature("Adaptive Cruise", id: "F-ACC", parent: "F-ADAS")[
  Adaptive cruise control.
]

#feature("Parking Assist", id: "F-PARK", parent: "F-ADAS")[
  Automated parking assistance.
]

// Define a configuration
#config("CFG-TEST", title: "Test Configuration",
  selected: ("F-ELEC", "F-LK", "F-ACC")
)

= Feature Diagram Tests

== Default: With Root Node (100% scale)

This shows the complete feature model including the root node.

#feature-model-diagram(
  root: "ROOT",
  config: "CFG-TEST",
  registry-state: __registry,
  active-config-state: __active-config,
  show-root: true,
  scale-factor: 100%,
  show-legend: true
)

#pagebreak()

== Space-Saving: Without Root Node (100% scale)

This hides the root node to save horizontal space.

#feature-model-diagram(
  root: "ROOT",
  config: "CFG-TEST",
  registry-state: __registry,
  active-config-state: __active-config,
  show-root: false,
  scale-factor: 100%,
  show-legend: true
)

#pagebreak()

== Scaled: Without Root Node (60% scale)

This combines both features: hides root and scales down to 60% to fit more compactly.

#feature-model-diagram(
  root: "ROOT",
  config: "CFG-TEST",
  registry-state: __registry,
  active-config-state: __active-config,
  show-root: false,
  scale-factor: 60%,
  show-legend: true
)
