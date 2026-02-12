#import "../packages/preview/assemblyline/main/lib/lib.typ": *

// Define a comprehensive feature model with multiple levels

#feature("Automotive System", id: "ROOT", parent: none, concrete: false)[
  Root feature of the automotive product line. Represents the complete vehicle system with all available features.
]

#feature("ADAS", id: "L1-ADAS", parent: "ROOT", concrete: false, group: "OR")[
  Advanced driver assistance systems. Provides safety and convenience features to assist the driver.
]

#feature("Lane Assist", id: "L2-LANE-ASSIST", parent: "L1-ADAS", concrete: true)[
  Provides lane keeping assistance using camera-based lane detection and steering corrections.
]

#feature("Lane Departure Warning", id: "L3-LDW", parent: "L2-LANE-ASSIST", concrete: true)[
  Visual and audible warnings when unintentional lane departure is detected.
]

#feature("Lane Centering", id: "L3-LC", parent: "L2-LANE-ASSIST", concrete: true)[
  Active steering control to keep vehicle centered in the lane.
]

#feature("Adaptive Cruise Control", id: "L2-ACC", parent: "L1-ADAS", concrete: true)[
  Maintains safe following distance using radar sensing.
]

#feature("Full Speed Range ACC", id: "L3-ACC-FULL", parent: "L2-ACC", concrete: true)[
  ACC operational from 0-150 km/h including stop-and-go traffic.
]

#feature("Highway Only ACC", id: "L3-ACC-HWY", parent: "L2-ACC", concrete: true)[
  ACC operational only above 30 km/h for highway use.
]

#feature("Parking Assistance", id: "L2-PARK", parent: "L1-ADAS", concrete: true)[
  Semi-automated parking assistance with ultrasonic sensors.
]

#feature("Parallel Parking", id: "L3-PARK-PARALLEL", parent: "L2-PARK", concrete: true)[
  Automated parallel parking into street-side spaces.
]

#feature("Perpendicular Parking", id: "L3-PARK-PERP", parent: "L2-PARK", concrete: true)[
  Automated perpendicular parking into parking lot spaces.
]

#feature("Infotainment", id: "L1-INFOTAINMENT", parent: "ROOT", concrete: false, group: "XOR")[
  In-vehicle information and entertainment system.
]

#feature("Basic Radio", id: "L2-RADIO-BASIC", parent: "L1-INFOTAINMENT", concrete: true)[
  AM/FM radio with USB audio input and Bluetooth connectivity.
]

#feature("Premium Audio", id: "L2-AUDIO-PREMIUM", parent: "L1-INFOTAINMENT", concrete: true)[
  Premium audio system with navigation and smartphone integration.
]

#feature("Apple CarPlay", id: "L3-CARPLAY", parent: "L2-AUDIO-PREMIUM", concrete: true)[
  Apple CarPlay support for iPhone integration with touchscreen control.
]

#feature("Android Auto", id: "L3-ANDROID-AUTO", parent: "L2-AUDIO-PREMIUM", concrete: true)[
  Android Auto support for Android phone integration.
]

#feature("Navigation", id: "L3-NAV", parent: "L2-AUDIO-PREMIUM", concrete: true)[
  Built-in GPS navigation with real-time traffic updates.
]

#feature("Connectivity", id: "L1-CONNECTIVITY", parent: "ROOT", concrete: false)[
  Vehicle connectivity and telematics features.
]

#feature("WiFi Hotspot", id: "L2-WIFI", parent: "L1-CONNECTIVITY", concrete: true)[
  Built-in 4G LTE WiFi hotspot supporting up to 8 connected devices.
]

#feature("Over-the-Air Updates", id: "L2-OTA", parent: "L1-CONNECTIVITY", concrete: true)[
  Enables remote software updates for vehicle control units.
]

#feature("Telematics", id: "L2-TELEMATICS", parent: "L1-CONNECTIVITY", concrete: true)[
  Vehicle health monitoring and remote diagnostics.
]

// Define configurations
#config("CFG-BASIC", title: "Basic Configuration", root_feature_id: "ROOT",
  selected: ("ROOT", "L1-ADAS", "L2-LANE-ASSIST", "L3-LDW",
             "L1-INFOTAINMENT", "L2-RADIO-BASIC")
)

#config("CFG-PREMIUM", title: "Premium Configuration", root_feature_id: "ROOT",
  selected: ("ROOT",
             "L1-ADAS", "L2-LANE-ASSIST", "L3-LDW", "L3-LC",
             "L2-ACC", "L3-ACC-FULL",
             "L2-PARK", "L3-PARK-PARALLEL", "L3-PARK-PERP",
             "L1-INFOTAINMENT", "L2-AUDIO-PREMIUM", "L3-CARPLAY", "L3-ANDROID-AUTO", "L3-NAV",
             "L1-CONNECTIVITY", "L2-WIFI", "L2-OTA", "L2-TELEMATICS")
)

= Feature Tree Advanced Demonstrations

This document demonstrates the advanced capabilities of the detailed feature tree:
- Starting from any feature node
- Depth control
- Configuration highlighting (selected features in green)

#pagebreak()

== Full Tree View (All Features)

Complete view starting from ROOT with unlimited depth:

#feature-tree-detailed(root: "ROOT", show-descriptions: true)

#pagebreak()

== Depth-Limited Views

=== Depth 0 (Root Only)

Shows only the root feature:

#feature-tree-detailed(root: "ROOT", show-descriptions: true, max-depth: 0)

=== Depth 1 (Root + Direct Children)

Shows root and its immediate children:

#feature-tree-detailed(root: "ROOT", show-descriptions: true, max-depth: 1)

#pagebreak()

=== Depth 2 (Root + 2 Levels)

Shows root, children, and grandchildren:

#feature-tree-detailed(root: "ROOT", show-descriptions: true, max-depth: 2)

#pagebreak()

== Subtree Views (Starting from Non-Root)

=== ADAS Subsystem Only

View the ADAS feature subtree in isolation:

#feature-tree-detailed(root: "L1-ADAS", show-descriptions: true)

#pagebreak()

=== ADAS with Depth Limit

ADAS subsystem showing only 1 level deep:

#feature-tree-detailed(root: "L1-ADAS", show-descriptions: true, max-depth: 1)

#pagebreak()

=== Infotainment Subsystem

View just the infotainment features:

#feature-tree-detailed(root: "L1-INFOTAINMENT", show-descriptions: true)

#pagebreak()

== Configuration Views (Selected Features in Green)

=== Basic Configuration - Full View

#set-active-config("CFG-BASIC")
#feature-tree-detailed(root: "ROOT", show-descriptions: true)

#pagebreak()

=== Basic Configuration - Depth 2

Quick overview of selected features at 2 levels:

#feature-tree-detailed(root: "ROOT", show-descriptions: true, max-depth: 2)

#pagebreak()

=== Premium Configuration - Full View

#set-active-config("CFG-PREMIUM")
#feature-tree-detailed(root: "ROOT", show-descriptions: true)

#pagebreak()

=== Premium Configuration - ADAS Focus

View only the ADAS subsystem with premium selections highlighted:

#feature-tree-detailed(root: "L1-ADAS", show-descriptions: true)

#pagebreak()

=== Premium Configuration - Infotainment Focus

View only the infotainment subsystem with premium selections highlighted:

#feature-tree-detailed(root: "L1-INFOTAINMENT", show-descriptions: true)

#pagebreak()

== Compact Views (Without Descriptions)

=== Full Tree - Structure Only

Same as standard feature-tree but using the detailed function:

#feature-tree-detailed(root: "ROOT", show-descriptions: false)

#pagebreak()

=== Configuration with Structure Only

Premium configuration showing only structure (no descriptions):

#feature-tree-detailed(root: "ROOT", show-descriptions: false)

#pagebreak()

== Comparison: With vs Without Config

#set-active-config(none)

=== No Configuration Active (All Gray)

#feature-tree-detailed(root: "L1-ADAS", show-descriptions: true, max-depth: 2)

=== Premium Configuration Active (Selected in Green)

#set-active-config("CFG-PREMIUM")
#feature-tree-detailed(root: "L1-ADAS", show-descriptions: true, max-depth: 2)
