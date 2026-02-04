#import "../packages/preview/assemblyline/main/lib/lib.typ": *

// Main sensor feature
#feature("Sensor Suite", id: "F-SENSORS", concrete: true, parent: "ROOT", tags: (
  priority: "P1",
  owner: "Perception Team",
  asil: "D"
))[
  Environmental perception sensor suite for ADAS functions.
]

#req("REQ-SENS-001", belongs_to: "F-SENSORS", tags: (
  type: "functional",
  asil: "D",
  source: "ISO 26262-6"
))[
  The system shall provide redundant environmental perception through multiple sensor modalities.
]

// Camera system (mandatory)
#feature("Camera System", id: "F-CAMERA", concrete: true, parent: "F-SENSORS", tags: (
  priority: "P1",
  asil: "C"
))[
  Vision-based perception using forward-facing cameras.
]

#req("REQ-CAM-001", belongs_to: "F-CAMERA", tags: (type: "functional", asil: "C"))[
  The camera system shall detect lane markings, vehicles, pedestrians, and traffic signs.
]

// XOR group for camera configuration
#feature("Camera Configuration", id: "CAM-CONFIG", concrete: false, parent: "F-CAMERA",
  group: "XOR", tags: (variability: "alternative"))[
  Number and placement of cameras.
]

#feature("Single Camera", id: "F-CAM-1", concrete: true, parent: "CAM-CONFIG", tags: (
  cost-impact: "+0 EUR",
  fov: "52°",
  asil: "B"
))[
  Single forward-facing camera (base configuration).
]

#req("REQ-CAM1-001", belongs_to: "F-CAM-1", tags: (type: "functional", asil: "B"))[
  The single camera shall provide 52° horizontal field of view at 30fps minimum.
]

#feature("Quad Camera", id: "F-CAM-4", concrete: true, parent: "CAM-CONFIG", tags: (
  cost-impact: "+280 EUR",
  fov: "360°",
  asil: "C"
))[
  Surround view with 4 cameras (front, rear, left, right).
]

#req("REQ-CAM4-001", belongs_to: "F-CAM-4", tags: (type: "functional", asil: "C"))[
  The quad camera system shall provide 360° surround view with overlap for stitching.
]

// Radar system (mandatory)
#feature("Radar System", id: "F-RADAR", concrete: true, parent: "F-SENSORS", tags: (
  priority: "P1",
  asil: "C"
))[
  Radar-based perception for distance and velocity measurement.
]

#req("REQ-RAD-001", belongs_to: "F-RADAR", tags: (type: "functional", asil: "C"))[
  The radar system shall detect objects up to 200m range with ±0.5m/s velocity accuracy.
]

// XOR group for radar type
#feature("Radar Type", id: "RADAR-TYPE", concrete: false, parent: "F-RADAR",
  group: "XOR", tags: (variability: "alternative"))[
  Radar sensor type selection.
]

#feature("Short-Range Radar", id: "F-RADAR-SR", concrete: true, parent: "RADAR-TYPE", tags: (
  cost-impact: "+0 EUR",
  range: "80m",
  asil: "B"
))[
  24 GHz short-range radar (base configuration).
]

#req("REQ-RADSR-001", belongs_to: "F-RADAR-SR", tags: (type: "functional", asil: "B"))[
  The short-range radar shall detect objects within 80m range.
]

#feature("Long-Range Radar", id: "F-RADAR-LR", concrete: true, parent: "RADAR-TYPE", tags: (
  cost-impact: "+150 EUR",
  range: "250m",
  asil: "C"
))[
  77 GHz long-range radar for highway scenarios.
]

#req("REQ-RADLR-001", belongs_to: "F-RADAR-LR", tags: (type: "functional", asil: "C"))[
  The long-range radar shall detect objects within 250m range at velocities up to 200 km/h.
]

// LiDAR (optional, premium)
#feature("LiDAR System", id: "F-LIDAR", concrete: true, parent: "F-SENSORS", tags: (
  priority: "P2",
  cost-impact: "+1200 EUR",
  asil: "C",
  optional: true
))[
  High-resolution 3D LiDAR for enhanced perception (premium feature).
]

#req("REQ-LID-001", belongs_to: "F-LIDAR", tags: (type: "functional", asil: "C"))[
  The LiDAR shall provide 360° horizontal coverage with 0.1° angular resolution and 150m range.
]
