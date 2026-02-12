#import "../packages/preview/assemblyline/main/lib/lib.typ": *

// Define a simple feature model with descriptions

#feature("Automotive System", id: "ROOT", parent: none, concrete: false)[
  Root feature of the automotive product line. Represents the complete vehicle system with all available features.
]

#feature("ADAS", id: "L1-ADAS", parent: "ROOT", concrete: false, group: "OR")[
  Advanced driver assistance systems. Provides safety and convenience features to assist the driver.
]

#feature("Lane Assist", id: "L2-LANE-ASSIST", parent: "L1-ADAS", concrete: true)[
  Provides lane keeping assistance using camera-based lane detection and steering corrections. Warns the driver when unintentional lane departure is detected.
]

#feature("Adaptive Cruise Control", id: "L2-ACC", parent: "L1-ADAS", concrete: true)[
  Maintains safe following distance using radar sensing. Automatically adjusts vehicle speed to maintain preset gap from vehicle ahead.
]

#feature("Parking Assistance", id: "L2-PARK", parent: "L1-ADAS", concrete: true)[
  Semi-automated parking assistance with ultrasonic sensors. Provides steering control while driver controls throttle and brake.
]

#feature("Infotainment", id: "L1-INFOTAINMENT", parent: "ROOT", concrete: false, group: "XOR")[
  In-vehicle information and entertainment system. Provides navigation, media, and connectivity features.
]

#feature("Basic Radio", id: "L2-RADIO-BASIC", parent: "L1-INFOTAINMENT", concrete: true)[
  AM/FM radio with USB audio input. Simple interface with physical buttons.
]

#feature("Premium Audio", id: "L2-AUDIO-PREMIUM", parent: "L1-INFOTAINMENT", concrete: true)[
  Premium audio system with touchscreen, navigation, smartphone integration (Apple CarPlay, Android Auto), and streaming services.
]

#feature("Connectivity", id: "L1-CONNECTIVITY", parent: "ROOT", concrete: false)[
  Vehicle connectivity and telematics features.
]

#feature("WiFi Hotspot", id: "L2-WIFI", parent: "L1-CONNECTIVITY", concrete: true)[
  Built-in 4G LTE WiFi hotspot supporting up to 8 connected devices.
]

#feature("Over-the-Air Updates", id: "L2-OTA", parent: "L1-CONNECTIVITY", concrete: true)[
  Enables remote software updates for vehicle control units. Updates can be delivered wirelessly without dealer visit.
]

// Define two configurations
#config("CFG-BASIC", title: "Basic Configuration", root_feature_id: "ROOT",
  selected: ("ROOT", "L1-ADAS", "L2-LANE-ASSIST", "L1-INFOTAINMENT", "L2-RADIO-BASIC")
)

#config("CFG-PREMIUM", title: "Premium Configuration", root_feature_id: "ROOT",
  selected: ("ROOT", "L1-ADAS", "L2-LANE-ASSIST", "L2-ACC", "L2-PARK",
             "L1-INFOTAINMENT", "L2-AUDIO-PREMIUM",
             "L1-CONNECTIVITY", "L2-WIFI", "L2-OTA")
)

= Feature Tree Visualization Examples

This document demonstrates the difference between the standard feature tree and the detailed feature tree with descriptions.

== Standard Feature Tree (Compact)

Shows only the structure without descriptions:

#feature-tree(root: "ROOT", config: none)

#pagebreak()

== Detailed Feature Tree (With Descriptions)

Shows the complete structure with feature descriptions:

#feature-tree-detailed(root: "ROOT", config: none, show-descriptions: true)

#pagebreak()

== Basic Configuration - Standard View

#set-active-config("CFG-BASIC")
#feature-tree(root: "ROOT")

#pagebreak()

== Basic Configuration - Detailed View

#feature-tree-detailed(root: "ROOT", show-descriptions: true)

#pagebreak()

== Premium Configuration - Detailed View

Selected features are shown in *bold green* to highlight the configuration:

#set-active-config("CFG-PREMIUM")
#feature-tree-detailed(root: "ROOT", show-descriptions: true)

#pagebreak()

== Detailed View Without Descriptions

You can also use the detailed function but hide descriptions (same as standard view):

#feature-tree-detailed(root: "ROOT", show-descriptions: false)

#pagebreak()

== Advanced Features

=== Starting from Specific Feature

View only the ADAS subsystem:

#set-active-config(none)
#feature-tree-detailed(root: "L1-ADAS", show-descriptions: true)

=== Depth-Limited View

Show only 2 levels deep:

#feature-tree-detailed(root: "ROOT", show-descriptions: true, max-depth: 2)

#pagebreak()

=== Configuration + Depth Limit

Premium configuration showing only top 2 levels:

#set-active-config("CFG-PREMIUM")
#feature-tree-detailed(root: "ROOT", show-descriptions: true, max-depth: 2)
