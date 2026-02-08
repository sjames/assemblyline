// Parameter Visualization Demo
// Demonstrates parameter schema tables, binding tables, and constraint visualization

#import "../packages/preview/assemblyline/main/lib/lib.typ": *

#set page(width: auto, height: auto, margin: 20pt)
#set text(size: 10pt)

#heading(level: 1)[Parameter Visualization Demo]

#text(gray)[
  This document demonstrates the parameter visualization capabilities:
  - Parameter Schema Tables
  - Configuration Binding Tables
  - Constraint Visualization
]

#pagebreak()

// =============================================================================
// Define Feature Model with Parameters and Constraints
// =============================================================================

#feature("Root", id: "ROOT", concrete: false)[
  Root feature for IoT device configuration
]

#feature("Communication", id: "F-COMM", parent: "ROOT",
  parameters: (
    protocol: (
      type: "Enum",
      values: ("HTTP", "MQTT", "CoAP"),
      default: "MQTT",
      description: "Communication protocol"
    ),
    timeout: (
      type: "Integer",
      range: (100, 10000),
      unit: "ms",
      default: 5000,
      description: "Connection timeout"
    ),
    enable_tls: (
      type: "Boolean",
      default: true,
      description: "Enable TLS encryption"
    )
  ),
  constraints: (
    "F-COMM.enable_tls => F-COMM.timeout >= 1000",
    "F-COMM.protocol == CoAP => F-COMM.timeout <= 5000",
  )
)[
  Communication subsystem with configurable parameters and constraints.
  TLS requires longer timeouts, CoAP prefers shorter timeouts.
]

#feature("Storage", id: "F-STORAGE", parent: "ROOT",
  parameters: (
    storage_type: (
      type: "Enum",
      values: ("Flash", "EEPROM", "RAM"),
      default: "Flash",
      description: "Storage medium type"
    ),
    capacity: (
      type: "Integer",
      range: (1, 1024),
      unit: "MB",
      default: 128,
      description: "Storage capacity"
    ),
    wear_leveling: (
      type: "Boolean",
      default: true,
      description: "Enable wear leveling"
    )
  ),
  constraints: (
    "F-STORAGE.storage_type == Flash => F-STORAGE.wear_leveling",
    "F-STORAGE.capacity >= 512 => F-STORAGE.storage_type == Flash",
  )
)[
  Storage subsystem with type-specific constraints.
  Flash storage requires wear leveling, large capacity requires Flash.
]

#feature("Sensors", id: "F-SENSORS", parent: "ROOT",
  parameters: (
    sampling_rate: (
      type: "Integer",
      range: (1, 1000),
      unit: "Hz",
      default: 10,
      description: "Sensor sampling rate"
    ),
    buffer_size: (
      type: "Integer",
      range: (10, 10000),
      unit: "samples",
      default: 100,
      description: "Sample buffer size"
    ),
    enable_filtering: (
      type: "Boolean",
      default: true,
      description: "Enable digital filtering"
    )
  ),
  constraints: (
    "F-SENSORS.sampling_rate >= 100 => F-SENSORS.buffer_size >= 1000",
    "F-SENSORS.enable_filtering => F-SENSORS.sampling_rate <= 500",
  )
)[
  Sensor subsystem with rate-dependent buffer requirements.
  High sampling rates require larger buffers.
]

#feature("Power Management", id: "F-POWER", parent: "ROOT",
  parameters: (
    power_mode: (
      type: "Enum",
      values: ("Low", "Normal", "High"),
      default: "Normal",
      description: "Power consumption mode"
    ),
    sleep_timeout: (
      type: "Integer",
      range: (0, 3600),
      unit: "seconds",
      default: 60,
      description: "Idle timeout before sleep"
    )
  ),
  constraints: (
    "F-POWER.power_mode == Low => F-POWER.sleep_timeout <= 300",
    "F-SENSORS is selected => F-POWER.power_mode != Low",
  )
)[
  Power management with mode-dependent constraints.
  Low power mode requires quick sleep, sensors need sufficient power.
]

// =============================================================================
// Define Configurations
// =============================================================================

#config("CFG-BASIC",
  root_feature_id: "ROOT",
  selected: ("F-COMM", "F-STORAGE"),
  bindings: (
    "F-COMM": (
      protocol: "HTTP",
      timeout: 3000,
      enable_tls: false
    ),
    "F-STORAGE": (
      storage_type: "EEPROM",
      capacity: 64,
      wear_leveling: false
    )
  )
)

#config("CFG-ADVANCED",
  root_feature_id: "ROOT",
  selected: ("F-COMM", "F-STORAGE", "F-SENSORS", "F-POWER"),
  bindings: (
    "F-COMM": (
      protocol: "MQTT",
      timeout: 8000,
      enable_tls: true
    ),
    "F-STORAGE": (
      storage_type: "Flash",
      capacity: 512,
      wear_leveling: true
    ),
    "F-SENSORS": (
      sampling_rate: 200,
      buffer_size: 2000,
      enable_filtering: true
    ),
    "F-POWER": (
      power_mode: "Normal",
      sleep_timeout: 120
    )
  )
)

#config("CFG-LOW-POWER",
  root_feature_id: "ROOT",
  selected: ("F-COMM", "F-STORAGE", "F-POWER"),
  bindings: (
    "F-COMM": (
      protocol: "CoAP",
      timeout: 2000,
      enable_tls: false
    ),
    "F-STORAGE": (
      // Using all defaults
    ),
    "F-POWER": (
      power_mode: "Low",
      sleep_timeout: 30
    )
  )
)

// =============================================================================
// SECTION 1: Parameter Schema Tables
// =============================================================================

#pagebreak()

#render-all-parameter-schemas()

#pagebreak()

// =============================================================================
// SECTION 2: Individual Feature Parameter Schemas
// =============================================================================

#heading(level: 2)[Individual Feature Schemas (Detailed)]

#render-parameter-schema("F-COMM", title: "Communication Parameters (Detailed)")
#parbreak()

#render-parameter-schema("F-SENSORS", title: "Sensor Parameters (Detailed)")

#pagebreak()

// =============================================================================
// SECTION 3: Configuration Binding Tables
// =============================================================================

#heading(level: 2)[Configuration Parameter Bindings]

#heading(level: 3)[CFG-BASIC: Basic Configuration]
#text(gray)[
  Simple configuration with HTTP communication and EEPROM storage.
  Shows explicit bindings overriding defaults.
]

#render-parameter-bindings("CFG-BASIC", show-defaults: true)

#pagebreak()

#heading(level: 3)[CFG-ADVANCED: Advanced Configuration]
#text(gray)[
  Full-featured configuration with all subsystems enabled.
  High sampling rate with appropriate buffer size.
]

#render-parameter-bindings("CFG-ADVANCED", show-defaults: true)

#pagebreak()

#heading(level: 3)[CFG-LOW-POWER: Low Power Configuration]
#text(gray)[
  Power-optimized configuration using CoAP and minimal timeouts.
  Storage subsystem uses all default values.
]

#render-parameter-bindings("CFG-LOW-POWER", show-defaults: true)

#pagebreak()

// =============================================================================
// SECTION 4: Constraint Visualization
// =============================================================================

#heading(level: 2)[Feature Constraints (Detailed)]

#text(gray)[
  Constraints define relationships between parameters and features.
  These are validated at configuration time to ensure consistency.
]

#parbreak()

#render-feature-constraints("F-COMM")
#parbreak()

#render-feature-constraints("F-STORAGE")
#parbreak()

#render-feature-constraints("F-SENSORS")
#parbreak()

#render-feature-constraints("F-POWER")

#pagebreak()

// =============================================================================
// SECTION 5: Constraint Summary Table
// =============================================================================

#render-constraint-summary()

#pagebreak()

// =============================================================================
// SECTION 6: Comprehensive Parameter Report
// =============================================================================

#heading(level: 1)[Comprehensive Parameter Report]
#heading(level: 2, outlined: false)[For Configuration: CFG-ADVANCED]

#text(gray)[
  This report combines schemas, bindings, and constraints for a complete
  parameter overview of the CFG-ADVANCED configuration.
]

#pagebreak()

#render-parameter-report(config-id: "CFG-ADVANCED", show-defaults: true)

#pagebreak()

// =============================================================================
// SECTION 7: Comparison View
// =============================================================================

#heading(level: 1)[Configuration Comparison]

#text(gray)[
  Side-by-side comparison of parameter bindings across configurations.
]

#heading(level: 3)[CFG-BASIC vs CFG-ADVANCED]

#grid(
  columns: 2,
  column-gutter: 10pt,
  [
    #heading(level: 4, outlined: false)[CFG-BASIC]
    #render-parameter-bindings("CFG-BASIC", show-defaults: false)
  ],
  [
    #heading(level: 4, outlined: false)[CFG-ADVANCED]
    #render-parameter-bindings("CFG-ADVANCED", show-defaults: false)
  ]
)

#pagebreak()

// =============================================================================
// Summary
// =============================================================================

#heading(level: 1)[Summary]

#text(size: 11pt)[
  This demo showcases AssemblyLine's parameter visualization capabilities:

  *✓ Parameter Schema Tables*
  - Show parameter definitions with types, ranges, defaults
  - Support Integer, Boolean, and Enum types
  - Display units and descriptions

  *✓ Configuration Binding Tables*
  - Show actual parameter values for configurations
  - Distinguish between explicit bindings and defaults
  - Filter to show only overridden values

  *✓ Constraint Visualization*
  - Display constraint expressions clearly
  - Group constraints by feature
  - Provide summary tables for overview

  *✓ Comprehensive Reports*
  - Combined view of all parameter information
  - Configuration-specific reports
  - Comparison views across configurations

  These visualizations support:
  - Design reviews and documentation
  - Configuration validation
  - Product line analysis
  - Traceability and compliance
]
