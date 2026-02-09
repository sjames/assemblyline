// Demonstration of feature model subtree visualization with depth limiting
// Shows how to focus on specific parts of a feature model

#import "../packages/preview/assemblyline/main/lib/lib.typ": *

#set page(width: 210mm, height: 297mm, margin: 1cm)
#set text(size: 10pt)

// Define a deeper feature hierarchy for testing
#feature("Automotive System", id: "ROOT", parent: none, concrete: false)[
  Complete automotive system with multiple subsystems.
]

// Level 1: Major subsystems
#feature("Powertrain", id: "L1-POWER", parent: "ROOT", concrete: false, group: "XOR")[
  Vehicle powertrain system.
]

#feature("ADAS", id: "L1-ADAS", parent: "ROOT", concrete: false, group: "OR")[
  Advanced driver assistance systems.
]

#feature("Infotainment", id: "L1-INFO", parent: "ROOT", concrete: false)[
  Information and entertainment system.
]

// Level 2: Powertrain options
#feature("Electric Powertrain", id: "L2-ELEC", parent: "L1-POWER", concrete: true)[
  Full electric powertrain.
]

#feature("Hybrid Powertrain", id: "L2-HYBRID", parent: "L1-POWER", concrete: true)[
  Hybrid electric/combustion powertrain.
]

#feature("Combustion Powertrain", id: "L2-COMBUST", parent: "L1-POWER", concrete: true)[
  Traditional combustion engine.
]

// Level 2: ADAS features
#feature("Perception", id: "L2-PERCEPT", parent: "L1-ADAS", concrete: false)[
  Sensor perception systems.
]

#feature("Planning", id: "L2-PLAN", parent: "L1-ADAS", concrete: false)[
  Path planning and decision making.
]

#feature("Control", id: "L2-CTRL", parent: "L1-ADAS", concrete: false)[
  Vehicle control systems.
]

// Level 3: Perception sensors
#feature("Camera", id: "L3-CAM", parent: "L2-PERCEPT", concrete: true)[
  Camera-based perception.
]

#feature("Radar", id: "L3-RAD", parent: "L2-PERCEPT", concrete: true)[
  Radar-based perception.
]

#feature("Lidar", id: "L3-LID", parent: "L2-PERCEPT", concrete: true)[
  Lidar-based perception.
]

#feature("Ultrasonic", id: "L3-ULT", parent: "L2-PERCEPT", concrete: true)[
  Ultrasonic sensors for close range.
]

// Level 3: Planning functions
#feature("Lane Keeping", id: "L3-LK", parent: "L2-PLAN", concrete: true)[
  Keep vehicle in lane.
]

#feature("Adaptive Cruise", id: "L3-ACC", parent: "L2-PLAN", concrete: true)[
  Adaptive cruise control.
]

#feature("Automatic Emergency Braking", id: "L3-AEB", parent: "L2-PLAN", concrete: true)[
  Emergency braking system.
]

// Level 3: Control actuators
#feature("Steering Control", id: "L3-STEER", parent: "L2-CTRL", concrete: true)[
  Active steering control.
]

#feature("Brake Control", id: "L3-BRAKE", parent: "L2-CTRL", concrete: true)[
  Active brake control.
]

#feature("Throttle Control", id: "L3-THROT", parent: "L2-CTRL", concrete: true)[
  Active throttle control.
]

// Level 2: Infotainment features
#feature("Navigation", id: "L2-NAV", parent: "L1-INFO", concrete: true)[
  GPS navigation system.
]

#feature("Media Player", id: "L2-MEDIA", parent: "L1-INFO", concrete: true)[
  Audio/video entertainment.
]

#feature("Connectivity", id: "L2-CONNECT", parent: "L1-INFO", concrete: true)[
  Smartphone connectivity.
]

// Configuration
#config("CFG-DEMO", title: "Demo Configuration",
  selected: ("L2-ELEC", "L2-PERCEPT", "L3-CAM", "L3-RAD", "L2-PLAN", "L3-LK", "L3-ACC", "L2-NAV")
)

= Feature Model Depth Limiting Examples

This document demonstrates how to display portions of a feature model using the `max-depth` parameter.

== Full Model (Unlimited Depth)

The complete feature model showing all levels (4 levels total: ROOT → L1 → L2 → L3).

#feature-model-diagram(
  root: "ROOT",
  config: "CFG-DEMO",
  registry-state: __registry,
  active-config-state: __active-config,
  show-root: true,
  max-depth: none,
  scale-factor: 70%,
  show-legend: true
)

#pagebreak()

== Limited to 2 Levels (Root + Level 1)

Shows only the root and its direct children. Useful for high-level overview.

#feature-model-diagram(
  root: "ROOT",
  config: "CFG-DEMO",
  registry-state: __registry,
  active-config-state: __active-config,
  show-root: true,
  max-depth: 2,
  scale-factor: 100%,
  show-legend: true
)

#pagebreak()

== Limited to 3 Levels (Root + Level 1 + Level 2)

Shows root through level 2. Good for mid-level detail.

#feature-model-diagram(
  root: "ROOT",
  config: "CFG-DEMO",
  registry-state: __registry,
  active-config-state: __active-config,
  show-root: true,
  max-depth: 3,
  scale-factor: 80%,
  show-legend: true
)

#pagebreak()

== Subtree: Starting from ADAS (2 Levels)

Focus on just the ADAS subsystem and its children. The `root` parameter specifies where to start.

#feature-model-diagram(
  root: "L1-ADAS",
  config: "CFG-DEMO",
  registry-state: __registry,
  active-config-state: __active-config,
  show-root: true,
  max-depth: 2,
  scale-factor: 100%,
  show-legend: true
)

#pagebreak()

== Subtree: ADAS with Full Depth

Show the complete ADAS subtree with all its descendants.

#feature-model-diagram(
  root: "L1-ADAS",
  config: "CFG-DEMO",
  registry-state: __registry,
  active-config-state: __active-config,
  show-root: true,
  max-depth: none,
  scale-factor: 70%,
  show-legend: true
)

#pagebreak()

== Subtree: Perception Only (Without Root, 2 Levels)

Focus on the Perception subsystem, hiding its parent node to save space.

#feature-model-diagram(
  root: "L2-PERCEPT",
  config: "CFG-DEMO",
  registry-state: __registry,
  active-config-state: __active-config,
  show-root: false,
  max-depth: 2,
  scale-factor: 100%,
  show-legend: true
)

#pagebreak()

== Combined: Subtree + Hidden Root + Scaled

Demonstrates all three features together:
- Start from ADAS subsystem (`root: "L1-ADAS"`)
- Hide the ADAS root node (`show-root: false`)
- Limit to 3 levels (`max-depth: 3`)
- Scale to 80% (`scale-factor: 80%`)

#feature-model-diagram(
  root: "L1-ADAS",
  config: "CFG-DEMO",
  registry-state: __registry,
  active-config-state: __active-config,
  show-root: false,
  max-depth: 3,
  scale-factor: 80%,
  show-legend: true
)
