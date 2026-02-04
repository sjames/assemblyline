#import "../packages/preview/assemblyline/main/lib/lib.typ": *

// Top-level ADAS system block
#block_definition(
  "BLK-ADAS-SYSTEM",
  title: "ADAS System",
  properties: (
    (name: "vehicleId", type: "String", default: "UNASSIGNED"),
    (name: "softwareVersion", type: "String", default: "2.0.0"),
    (name: "asilLevel", type: "String", default: "ASIL-D"),
    (name: "cycleTime", type: "Integer", default: "50", unit: "ms")
  ),
  operations: (
    (name: "initialize", params: "void", returns: "SafetyStatus"),
    (name: "perceiveEnvironment", params: "void", returns: "EnvironmentModel"),
    (name: "planActions", params: "model: EnvironmentModel", returns: "ActionPlan"),
    (name: "executeActions", params: "plan: ActionPlan", returns: "bool")
  ),
  ports: (
    (name: "canFdPort", direction: "inout", protocol: "CAN-FD"),
    (name: "ethernetPort", direction: "inout", protocol: "100BASE-T1"),
    (name: "diagPort", direction: "in", protocol: "UDS")
  ),
  parts: (
    (name: "perceptionModule", type: "BLK-PERCEPTION", multiplicity: "1"),
    (name: "adasController", type: "BLK-ADAS-CTRL", multiplicity: "1"),
    (name: "hmiController", type: "BLK-HMI-CTRL", multiplicity: "1"),
    (name: "ecuPlatform", type: "BLK-ECU", multiplicity: "1")
  ),
  connectors: (
    (from: "canFdPort", to: "ecuPlatform.canPort", flow: "VehicleData"),
    (from: "ethernetPort", to: "perceptionModule.sensorPort", flow: "SensorData"),
    (from: "perceptionModule.outputPort", to: "adasController.inputPort", flow: "EnvironmentModel"),
    (from: "adasController.hmiPort", to: "hmiController.inputPort", flow: "DisplayCommands")
  ),
  references: ("BLK-VEHICLE-DYNAMICS", "BLK-POWERTRAIN"),
  constraints: (
    "cycleTime <= 50ms",
    "endToEndLatency <= 150ms",
    "availability >= 99.9%"
  ),
  tags: (
    stereotype: "system",
    asil: "D",
    autosar: "Adaptive-R21-11",
    language: "C++17"
  ),
  links: (satisfy: ("REQ-SENS-001", "REQ-ADAS-001", "REQ-HMI-001", "REQ-ECU-001"))
)[
  Top-level ADAS system comprising perception, control, HMI, and ECU platform.
]

// Perception subsystem
#block_definition(
  "BLK-PERCEPTION",
  title: "Perception Module",
  properties: (
    (name: "fusionAlgorithm", type: "String", default: "ExtendedKalmanFilter"),
    (name: "detectionRange", type: "Integer", default: "200", unit: "m"),
    (name: "trackingObjects", type: "Integer", default: "64", unit: "objects")
  ),
  operations: (
    (name: "fuseData", params: "camera: Image[], radar: RadarTracks[], lidar: PointCloud", returns: "FusedObjects"),
    (name: "detectLanes", params: "image: Image", returns: "LaneModel"),
    (name: "classifyObjects", params: "objects: FusedObjects", returns: "ClassifiedObjects")
  ),
  ports: (
    (name: "sensorPort", direction: "in", protocol: "Ethernet"),
    (name: "outputPort", direction: "out", protocol: "Internal")
  ),
  references: ("BLK-CAMERA", "BLK-RADAR", "BLK-LIDAR"),
  constraints: (
    "fusionLatency <= 80ms",
    "falsePositiveRate < 1%"
  ),
  tags: (
    stereotype: "subsystem",
    asil: "D",
    algorithm: "Sensor Fusion"
  ),
  links: (satisfy: ("REQ-SENS-001", "REQ-CAM-001", "REQ-RAD-001"))
)[
  Sensor data fusion and environmental perception.
]

// ADAS controller
#block_definition(
  "BLK-ADAS-CTRL",
  title: "ADAS Controller",
  properties: (
    (name: "activeFunction", type: "String", default: "NONE"),
    (name: "interventionLevel", type: "String", default: "WARNING")
  ),
  operations: (
    (name: "assessSituation", params: "env: EnvironmentModel", returns: "ThreatAssessment"),
    (name: "decideAction", params: "threat: ThreatAssessment", returns: "ActionDecision"),
    (name: "arbitrate", params: "decisions: ActionDecision[]", returns: "ActionPlan")
  ),
  ports: (
    (name: "inputPort", direction: "in", protocol: "Internal"),
    (name: "hmiPort", direction: "out", protocol: "Internal"),
    (name: "actuationPort", direction: "out", protocol: "CAN-FD")
  ),
  references: ("BLK-BRAKING", "BLK-STEERING"),
  constraints: (
    "decisionLatency <= 50ms"
  ),
  tags: (
    stereotype: "subsystem",
    asil: "D",
    functions: ("LDW", "LKA", "AEB", "ACC")
  ),
  links: (satisfy: ("REQ-LDW-001", "REQ-LKA-001", "REQ-AEB-001", "REQ-ACC-001"))
)[
  ADAS function arbitration and decision-making.
]

// HMI controller
#block_definition(
  "BLK-HMI-CTRL",
  title: "HMI Controller",
  properties: (
    (name: "displayMode", type: "String", default: "NORMAL"),
    (name: "warningLevel", type: "Integer", default: "0", unit: "0-3")
  ),
  operations: (
    (name: "renderStatus", params: "status: AdasStatus", returns: "DisplayFrame"),
    (name: "playWarning", params: "warning: WarningType", returns: "void"),
    (name: "activateHaptic", params: "pattern: HapticPattern", returns: "void")
  ),
  ports: (
    (name: "inputPort", direction: "in", protocol: "Internal")
  ),
  references: ("BLK-CLUSTER-DISPLAY", "BLK-HUD", "BLK-HAPTIC"),
  constraints: (
    "renderLatency <= 100ms"
  ),
  tags: (
    stereotype: "subsystem",
    asil: "B"
  ),
  links: (satisfy: ("REQ-HMI-001", "REQ-CLUSTER-001"))
)[
  Driver information display and warning presentation.
]

// ECU platform
#block_definition(
  "BLK-ECU",
  title: "ECU Platform",
  properties: (
    (name: "cpuLoad", type: "Integer", default: "0", unit: "%"),
    (name: "memoryUsage", type: "Integer", default: "0", unit: "MB"),
    (name: "temperature", type: "Integer", default: "25", unit: "°C")
  ),
  operations: (
    (name: "monitorHealth", params: "void", returns: "HealthStatus"),
    (name: "executeSafeState", params: "void", returns: "bool"),
    (name: "performDiagnostics", params: "void", returns: "DiagnosticReport")
  ),
  ports: (
    (name: "canPort", direction: "inout", protocol: "CAN-FD"),
    (name: "powerPort", direction: "in", protocol: "12V-Automotive")
  ),
  constraints: (
    "cpuLoad <= 80%",
    "temperature <= 125°C"
  ),
  tags: (
    stereotype: "platform",
    processor: "ARM-Cortex",
    asil: "D",
    autosar: "Classic-R20-11"
  ),
  links: (satisfy: ("REQ-ECU-001", "REQ-COMM-001"))
)[
  Real-time ECU platform with safety mechanisms.
]
