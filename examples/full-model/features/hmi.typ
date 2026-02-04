#import "../packages/preview/assemblyline/main/lib/lib.typ": *

// Human-Machine Interface
#feature("Human-Machine Interface", id: "F-HMI", concrete: true, parent: "ROOT", tags: (
  priority: "P2",
  owner: "HMI Team",
  asil: "B"
))[
  Driver information and control interface for ADAS functions.
]

#req("REQ-HMI-001", belongs_to: "F-HMI", tags: (type: "functional", asil: "B"))[
  The HMI shall provide clear visual and audible feedback for all ADAS function states.
]

// XOR group for display type
#feature("Display Type", id: "HMI-DISPLAY", concrete: false, parent: "F-HMI",
  group: "XOR", tags: (variability: "alternative"))[
  Primary display technology for ADAS information.
]

#feature("Instrument Cluster Display", id: "F-HMI-CLUSTER", concrete: true, parent: "HMI-DISPLAY", tags: (
  cost-impact: "+0 EUR",
  resolution: "480x240"
))[
  Dedicated ADAS information area in instrument cluster (base configuration).
]

#req("REQ-CLUSTER-001", belongs_to: "F-HMI-CLUSTER", tags: (type: "functional", asil: "B"))[
  The cluster display shall show ADAS status icons and warnings in driver's primary field of view.
]

#feature("Head-Up Display", id: "F-HMI-HUD", concrete: true, parent: "HMI-DISPLAY", tags: (
  cost-impact: "+450 EUR",
  resolution: "800x400"
))[
  Augmented reality head-up display with lane projection.
]

#req("REQ-HUD-001", belongs_to: "F-HMI-HUD", tags: (type: "functional", asil: "B"))[
  The HUD shall project ADAS information onto windshield with lane guidance overlay.
]

// Haptic feedback (optional)
#feature("Haptic Feedback", id: "F-HMI-HAPTIC", concrete: true, parent: "F-HMI", tags: (
  cost-impact: "+80 EUR",
  asil: "A",
  optional: true
))[
  Steering wheel vibration for warnings.
]

#req("REQ-HAPTIC-001", belongs_to: "F-HMI-HAPTIC", tags: (type: "functional", asil: "A"))[
  The system shall provide directional haptic feedback through steering wheel for lane departure warnings.
]
