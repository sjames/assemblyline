#import "../packages/preview/assemblyline/main/lib/lib.typ": *

// ECU Platform
#feature("ECU Platform", id: "F-ECU", concrete: true, parent: "ROOT", tags: (
  priority: "P1",
  owner: "Platform Team",
  asil: "D"
))[
  Electronic Control Unit hardware and software platform.
]

#req("REQ-ECU-001", belongs_to: "F-ECU", tags: (type: "functional", asil: "D"))[
  The ECU shall provide real-time processing of sensor data with deterministic timing.
]

// XOR group for processor
#feature("Processor", id: "ECU-PROC", concrete: false, parent: "F-ECU",
  group: "XOR", tags: (variability: "alternative"))[
  Central processing unit selection.
]

#feature("Single-Core Processor", id: "F-ECU-SINGLE", concrete: true, parent: "ECU-PROC", tags: (
  cost-impact: "+0 EUR",
  cores: "1",
  frequency: "800 MHz",
  asil: "B"
))[
  ARM Cortex-R5 single-core processor (base configuration).
]

#req("REQ-SINGLE-001", belongs_to: "F-ECU-SINGLE", tags: (type: "performance", asil: "B"))[
  The single-core processor shall provide minimum 800 MHz clock with lockstep execution.
]

#feature("Multi-Core Processor", id: "F-ECU-MULTI", concrete: true, parent: "ECU-PROC", tags: (
  cost-impact: "+180 EUR",
  cores: "4",
  frequency: "1.2 GHz",
  asil: "D"
))[
  ARM Cortex-A53 quad-core processor for complex ADAS functions.
]

#req("REQ-MULTI-001", belongs_to: "F-ECU-MULTI", tags: (type: "performance", asil: "D"))[
  The multi-core processor shall provide ASIL-D decomposition with dual lockstep cores.
]

// Memory (mandatory configurations)
#req("REQ-MEM-001", belongs_to: "F-ECU", tags: (type: "functional", asil: "D"))[
  The ECU shall provide ECC-protected RAM and redundant flash storage.
]

// CAN/Ethernet connectivity
#req("REQ-COMM-001", belongs_to: "F-ECU", tags: (type: "functional", asil: "C"))[
  The ECU shall support CAN FD and automotive Ethernet (100BASE-T1) communication.
]
