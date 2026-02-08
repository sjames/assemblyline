#import "../packages/preview/assemblyline/main/lib/lib.typ": *

// Main ADAS functions feature
#feature("ADAS Functions", id: "F-ADAS-FUNC", concrete: true, parent: "ROOT", tags: (
  priority: "P1",
  owner: "ADAS Functions Team"
))[
  Advanced driver assistance and automated driving functions.
]

#req("REQ-ADAS-001", belongs_to: "F-ADAS-FUNC", tags: (
  type: "functional",
  asil: "D",
  source: "ISO 26262"
))[
  All ADAS functions shall be designed to ASIL-D decomposition requirements.
]

// OR group - multiple ADAS functions can be selected
#feature("Function Suite", id: "FUNC-SUITE", concrete: false, parent: "F-ADAS-FUNC",
  group: "OR", tags: (variability: "multiple-selection"))[
  Available ADAS functions (multiple can be selected).
]

// Lane Departure Warning (LDW)
#feature("Lane Departure Warning", id: "F-LDW", concrete: true, parent: "FUNC-SUITE", tags: (
  cost-impact: "+0 EUR",
  asil: "B",
  unece: "R130"
))[
  Visual and audible warning when vehicle drifts from lane without turn signal.
]

#req("REQ-LDW-001", belongs_to: "F-LDW", tags: (type: "functional", asil: "B"))[
  The system shall warn the driver within 0.5s of detecting unintended lane departure above 60 km/h.
]

#req("REQ-LDW-002", derives_from: "REQ-LDW-001", tags: (type: "functional", asil: "B"))[
  The warning shall be both visual (dashboard icon) and audible (tone or vibration).
]

// Lane Keeping Assist (LKA)
#feature("Lane Keeping Assist", id: "F-LKA", concrete: true, parent: "FUNC-SUITE", tags: (
  cost-impact: "+80 EUR",
  asil: "C",
  unece: "R157"
))[
  Active steering intervention to keep vehicle centered in lane.
]

#req("REQ-LKA-001", belongs_to: "F-LKA", tags: (type: "functional", asil: "C"))[
  The system shall apply corrective steering torque up to 3 Nm to maintain lane center.
]

#req("REQ-LKA-002", derives_from: "REQ-LKA-001", tags: (type: "safety", asil: "C"))[
  The system shall allow driver override at any time with steering torque > 5 Nm.
]

// Automatic Emergency Braking (AEB)
#feature("Automatic Emergency Braking", id: "F-AEB", concrete: true, parent: "FUNC-SUITE", tags: (
  cost-impact: "+120 EUR",
  asil: "D",
  unece: "R152",
  euro-ncap: "required"
))[
  Autonomous braking to prevent or mitigate frontal collisions.
]

#req("REQ-AEB-001", belongs_to: "F-AEB", tags: (type: "functional", asil: "D"))[
  The system shall autonomously brake when collision probability exceeds 90% and TTC < 2.5s.
]

#req("REQ-AEB-002", derives_from: "REQ-AEB-001", tags: (type: "performance", asil: "D"))[
  The system shall achieve full braking (10 m/s²) within 200ms of decision.
]

// Adaptive Cruise Control (ACC) with configurable parameters
#feature("Adaptive Cruise Control", id: "F-ACC", concrete: true, parent: "FUNC-SUITE",
  tags: (
    cost-impact: "+200 EUR",
    asil: "B"
  ),
  parameters: (
    min_speed: (
      type: "Integer",
      range: (20, 50),
      unit: "km/h",
      default: 30,
      description: "Minimum operational speed"
    ),
    max_speed: (
      type: "Integer",
      range: (120, 200),
      unit: "km/h",
      default: 180,
      description: "Maximum operational speed"
    ),
    default_time_gap: (
      type: "Integer",
      range: (10, 30),
      unit: "deciseconds",
      default: 18,
      description: "Default following time gap (tenths of second)"
    ),
    comfort_mode: (
      type: "Enum",
      values: ("Eco", "Comfort", "Sport"),
      default: "Comfort",
      description: "Acceleration/braking aggressiveness"
    ),
    enable_stop_and_go: (
      type: "Boolean",
      default: false,
      description: "Enable stop-and-go traffic capability"
    )
  ),
  constraints: (
    // Stop-and-go requires lower minimum speed
    "F-ACC.enable_stop_and_go => F-ACC.min_speed <= 30",
    // Sport mode requires higher max speed
    "F-ACC.comfort_mode == Sport => F-ACC.max_speed >= 160",
    // Eco mode uses longer time gaps
    "F-ACC.comfort_mode == Eco => F-ACC.default_time_gap >= 20"
  )
)[
  Speed and distance control with lead vehicle following. Configurable for different driving styles and traffic conditions.
]

#req("REQ-ACC-001", belongs_to: "F-ACC", tags: (type: "functional", asil: "B"))[
  The system shall maintain set speed (30-180 km/h) or follow lead vehicle at configurable time gap (1-3s).
]

#req("REQ-ACC-002", derives_from: "REQ-ACC-001", tags: (type: "performance", asil: "B"))[
  The system shall maintain speed within ±2 km/h and distance within ±0.2s of target time gap.
]

// Blind Spot Detection (BSD)
#feature("Blind Spot Detection", id: "F-BSD", concrete: true, parent: "FUNC-SUITE", tags: (
  cost-impact: "+60 EUR",
  asil: "A"
))[
  Visual warning when vehicle detected in blind spot.
]

#req("REQ-BSD-001", belongs_to: "F-BSD", tags: (type: "functional", asil: "A"))[
  The system shall illuminate mirror indicator when vehicle detected in blind spot zone.
]

// Rear Cross Traffic Alert (RCTA)
#feature("Rear Cross Traffic Alert", id: "F-RCTA", concrete: true, parent: "FUNC-SUITE", tags: (
  cost-impact: "+40 EUR",
  asil: "A"
))[
  Warning for crossing traffic when reversing out of parking space.
]

#req("REQ-RCTA-001", belongs_to: "F-RCTA", tags: (type: "functional", asil: "A"))[
  The system shall warn driver of approaching cross traffic within 20m when in reverse gear.
]

// Traffic Sign Recognition (TSR)
#feature("Traffic Sign Recognition", id: "F-TSR", concrete: true, parent: "FUNC-SUITE", tags: (
  cost-impact: "+25 EUR",
  asil: "A"
))[
  Detection and display of speed limits and traffic signs.
]

#req("REQ-TSR-001", belongs_to: "F-TSR", tags: (type: "functional", asil: "A"))[
  The system shall detect and display current speed limit signs with > 95% accuracy.
]
