// demo-feature-model-diagram.typ
// Demonstration of the FeatureIDE-style feature model visualization

#import "../../packages/preview/assemblyline/main/lib/lib.typ": *

// Set up landscape page for horizontal tree layout
#set page(
  width: 297mm,   // A4 landscape width
  height: 210mm,  // A4 landscape height
  margin: 1.5cm
)

#set text(font: "Arial", size: 11pt)

// Define a simple feature model
#feature("Smart Home System", id: "ROOT", parent: none, concrete: false)[
  The root of the smart home product line.
]

#feature("Authentication", id: "F-AUTH", parent: "ROOT", concrete: false, group: "XOR")[
  User authentication subsystem.
]

#feature("Biometric", id: "F-BIO", parent: "F-AUTH", concrete: true)[
  Fingerprint or facial recognition authentication.
]

#feature("Password", id: "F-PWD", parent: "F-AUTH", concrete: true)[
  Traditional password-based authentication.
]

#feature("Two-Factor", id: "F-2FA", parent: "F-AUTH", concrete: true)[
  Multi-factor authentication with TOTP or push notifications.
]

#feature("Sensors", id: "F-SENSORS", parent: "ROOT", concrete: false, group: "OR")[
  Environmental sensors for home monitoring.
]

#feature("Temperature", id: "F-TEMP", parent: "F-SENSORS", concrete: true)[
  Temperature monitoring sensors.
]

#feature("Motion", id: "F-MOTION", parent: "F-SENSORS", concrete: true)[
  Motion detection sensors.
]

#feature("Camera", id: "F-CAMERA", parent: "F-SENSORS", concrete: true)[
  Video surveillance cameras.
]

#feature("User Interface", id: "F-UI", parent: "ROOT", concrete: false)[
  User interface options.
]

#feature("Mobile App", id: "F-MOBILE", parent: "F-UI", concrete: true)[
  Smartphone application for system control.
]

#feature("Web Portal", id: "F-WEB", parent: "F-UI", concrete: true)[
  Web-based control interface.
]

// Define configurations
#config(
  "Premium Smart Home",
  id: "CFG-PREMIUM",
  root_feature_id: "ROOT",
  selected: ("ROOT", "F-AUTH", "F-2FA", "F-SENSORS", "F-TEMP", "F-MOTION", "F-CAMERA", "F-UI", "F-MOBILE", "F-WEB"),
  tags: (market: "premium", price: "high")
)

#config(
  "Basic Smart Home",
  id: "CFG-BASIC",
  root_feature_id: "ROOT",
  selected: ("ROOT", "F-AUTH", "F-PWD", "F-SENSORS", "F-TEMP", "F-UI", "F-MOBILE"),
  tags: (market: "entry-level", price: "low")
)

= Feature Model Visualization Demo

== Premium Configuration

This shows the premium smart home configuration with all advanced features selected.

#feature-model-diagram(
  root: "ROOT",
  config: "CFG-PREMIUM",
  registry-state: __registry,
  active-config-state: __active-config,
  show-legend: true
)

#pagebreak()

== Basic Configuration

This shows the basic smart home configuration with only essential features.

#feature-model-diagram(
  root: "ROOT",
  config: "CFG-BASIC",
  registry-state: __registry,
  active-config-state: __active-config,
  show-legend: true
)

#pagebreak()

== Full Feature Model (No Configuration)

This shows all features without any configuration highlighting.

#feature-model-diagram(
  root: "ROOT",
  config: none,
  registry-state: __registry,
  active-config-state: __active-config,
  show-legend: true
)

#pagebreak()

== Comparison: Old vs New Visualization

=== Traditional Text-Based Tree

#feature-tree(root: "ROOT", config: "CFG-PREMIUM")

#v(1em)

=== New FeatureIDE-Style Diagram

#feature-model-diagram(
  root: "ROOT",
  config: "CFG-PREMIUM",
  registry-state: __registry,
  active-config-state: __active-config,
  show-legend: true
)
