// Test: Comprehensive Parameter Validation
// Tests all aspects of feature parameter support

#import "../packages/preview/assemblyline/main/lib/lib.typ": *

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 10pt)

// =============================================================================
// Test Setup
// =============================================================================

#heading(level: 1)[Parameter Validation Tests]

// =============================================================================
// TEST 1: Integer Parameters with Range Validation
// =============================================================================

#heading(level: 2)[Test 1: Integer Parameters with Range Validation]

#feature("Root", id: "ROOT")[Root]

#feature("Test Integer", id: "F-INT", parent: "ROOT",
  parameters: (
    small_range: (
      type: "Integer",
      range: (1, 10),
      default: 5
    ),
    large_range: (
      type: "Integer",
      range: (100, 10000),
      default: 1000
    ),
    negative_range: (
      type: "Integer",
      range: (-100, 100),
      default: 0
    )
  )
)[Feature with integer parameters]

// Test: Valid values within ranges
#config("CFG-INT-VALID",
  root_feature_id: "ROOT",
  selected: ("F-INT",),
  bindings: (
    "F-INT": (
      small_range: 7,      // Valid: 1 <= 7 <= 10
      large_range: 5000,   // Valid: 100 <= 5000 <= 10000
      negative_range: -50  // Valid: -100 <= -50 <= 100
    )
  )
)

#validate-parameter-bindings("CFG-INT-VALID")
#text(green)[✓ Test 1.1: Valid integer values within ranges]

// Test: Boundary values (min)
#config("CFG-INT-MIN",
  root_feature_id: "ROOT",
  selected: ("F-INT",),
  bindings: (
    "F-INT": (
      small_range: 1,      // Valid: min boundary
      large_range: 100,    // Valid: min boundary
      negative_range: -100 // Valid: min boundary
    )
  )
)

#validate-parameter-bindings("CFG-INT-MIN")
#text(green)[✓ Test 1.2: Integer boundary values (minimum)]

// Test: Boundary values (max)
#config("CFG-INT-MAX",
  root_feature_id: "ROOT",
  selected: ("F-INT",),
  bindings: (
    "F-INT": (
      small_range: 10,     // Valid: max boundary
      large_range: 10000,  // Valid: max boundary
      negative_range: 100  // Valid: max boundary
    )
  )
)

#validate-parameter-bindings("CFG-INT-MAX")
#text(green)[✓ Test 1.3: Integer boundary values (maximum)]

#pagebreak()

// =============================================================================
// TEST 2: Boolean Parameters
// =============================================================================

#heading(level: 2)[Test 2: Boolean Parameters]

#feature("Test Boolean", id: "F-BOOL", parent: "ROOT",
  parameters: (
    flag1: (type: "Boolean", default: false),
    flag2: (type: "Boolean", default: true),
    flag3: (type: "Boolean", default: false)
  )
)[Feature with boolean parameters]

// Test: Boolean true values
#config("CFG-BOOL-TRUE",
  root_feature_id: "ROOT",
  selected: ("F-BOOL",),
  bindings: (
    "F-BOOL": (
      flag1: true,
      flag2: true,
      flag3: true
    )
  )
)

#validate-parameter-bindings("CFG-BOOL-TRUE")
#text(green)[✓ Test 2.1: Boolean parameters set to true]

// Test: Boolean false values
#config("CFG-BOOL-FALSE",
  root_feature_id: "ROOT",
  selected: ("F-BOOL",),
  bindings: (
    "F-BOOL": (
      flag1: false,
      flag2: false,
      flag3: false
    )
  )
)

#validate-parameter-bindings("CFG-BOOL-FALSE")
#text(green)[✓ Test 2.2: Boolean parameters set to false]

// Test: Boolean mixed values
#config("CFG-BOOL-MIXED",
  root_feature_id: "ROOT",
  selected: ("F-BOOL",),
  bindings: (
    "F-BOOL": (
      flag1: true,
      flag2: false,
      flag3: true
    )
  )
)

#validate-parameter-bindings("CFG-BOOL-MIXED")
#text(green)[✓ Test 2.3: Boolean parameters with mixed values]

#pagebreak()

// =============================================================================
// TEST 3: Enum Parameters
// =============================================================================

#heading(level: 2)[Test 3: Enum Parameters]

#feature("Test Enum", id: "F-ENUM", parent: "ROOT",
  parameters: (
    size: (
      type: "Enum",
      values: ("small", "medium", "large", "xlarge"),
      default: "medium"
    ),
    priority: (
      type: "Enum",
      values: ("low", "normal", "high", "critical"),
      default: "normal"
    ),
    region: (
      type: "Enum",
      values: ("us-east", "us-west", "eu-west", "ap-southeast"),
      default: "us-east"
    )
  )
)[Feature with enum parameters]

// Test: All valid enum values for size
#config("CFG-ENUM-SIZE-SMALL",
  root_feature_id: "ROOT",
  selected: ("F-ENUM",),
  bindings: ("F-ENUM": (size: "small", priority: "normal", region: "us-east"))
)
#validate-parameter-bindings("CFG-ENUM-SIZE-SMALL")
#text(green)[✓ Test 3.1: Enum value "small"]

#config("CFG-ENUM-SIZE-MEDIUM",
  root_feature_id: "ROOT",
  selected: ("F-ENUM",),
  bindings: ("F-ENUM": (size: "medium", priority: "normal", region: "us-east"))
)
#validate-parameter-bindings("CFG-ENUM-SIZE-MEDIUM")
#text(green)[✓ Test 3.2: Enum value "medium"]

#config("CFG-ENUM-SIZE-LARGE",
  root_feature_id: "ROOT",
  selected: ("F-ENUM",),
  bindings: ("F-ENUM": (size: "large", priority: "normal", region: "us-east"))
)
#validate-parameter-bindings("CFG-ENUM-SIZE-LARGE")
#text(green)[✓ Test 3.3: Enum value "large"]

#config("CFG-ENUM-SIZE-XLARGE",
  root_feature_id: "ROOT",
  selected: ("F-ENUM",),
  bindings: ("F-ENUM": (size: "xlarge", priority: "normal", region: "us-east"))
)
#validate-parameter-bindings("CFG-ENUM-SIZE-XLARGE")
#text(green)[✓ Test 3.4: Enum value "xlarge"]

// Test: All priorities
#config("CFG-ENUM-PRIORITY-LOW",
  root_feature_id: "ROOT",
  selected: ("F-ENUM",),
  bindings: ("F-ENUM": (size: "medium", priority: "low", region: "us-east"))
)
#validate-parameter-bindings("CFG-ENUM-PRIORITY-LOW")
#text(green)[✓ Test 3.5: Priority "low"]

#config("CFG-ENUM-PRIORITY-CRITICAL",
  root_feature_id: "ROOT",
  selected: ("F-ENUM",),
  bindings: ("F-ENUM": (size: "medium", priority: "critical", region: "us-east"))
)
#validate-parameter-bindings("CFG-ENUM-PRIORITY-CRITICAL")
#text(green)[✓ Test 3.6: Priority "critical"]

// Test: All regions
#config("CFG-ENUM-REGION-EU",
  root_feature_id: "ROOT",
  selected: ("F-ENUM",),
  bindings: ("F-ENUM": (size: "medium", priority: "normal", region: "eu-west"))
)
#validate-parameter-bindings("CFG-ENUM-REGION-EU")
#text(green)[✓ Test 3.7: Region "eu-west"]

#config("CFG-ENUM-REGION-APAC",
  root_feature_id: "ROOT",
  selected: ("F-ENUM",),
  bindings: ("F-ENUM": (size: "medium", priority: "normal", region: "ap-southeast"))
)
#validate-parameter-bindings("CFG-ENUM-REGION-APAC")
#text(green)[✓ Test 3.8: Region "ap-southeast"]

#pagebreak()

// =============================================================================
// TEST 4: Default Value Handling
// =============================================================================

#heading(level: 2)[Test 4: Default Value Handling]

#feature("Test Defaults", id: "F-DEFAULT", parent: "ROOT",
  parameters: (
    param_with_default: (
      type: "Integer",
      range: (1, 100),
      default: 50
    ),
    another_default: (
      type: "Boolean",
      default: true
    ),
    enum_default: (
      type: "Enum",
      values: ("a", "b", "c"),
      default: "b"
    )
  )
)[Feature with default values]

// Test: No bindings provided - should use all defaults
// Note: Empty dictionary for feature means all parameters use defaults
#config("CFG-ALL-DEFAULTS",
  root_feature_id: "ROOT",
  selected: ("F-DEFAULT",),
  bindings: (:)  // No bindings at all - all features use defaults
)

#validate-parameter-bindings("CFG-ALL-DEFAULTS")
#text(green)[✓ Test 4.1: All parameters use default values]

// Test: Partial bindings - mix of explicit and defaults
#config("CFG-PARTIAL-DEFAULTS",
  root_feature_id: "ROOT",
  selected: ("F-DEFAULT",),
  bindings: (
    "F-DEFAULT": (
      param_with_default: 75  // Explicit binding; others use defaults
    )
  )
)

#validate-parameter-bindings("CFG-PARTIAL-DEFAULTS")
#text(green)[✓ Test 4.2: Partial bindings with defaults]

// Test: Override all defaults with explicit values
#config("CFG-OVERRIDE-DEFAULTS",
  root_feature_id: "ROOT",
  selected: ("F-DEFAULT",),
  bindings: (
    "F-DEFAULT": (
      param_with_default: 25,    // Override default 50
      another_default: false,    // Override default true
      enum_default: "c"          // Override default "b"
    )
  )
)

#validate-parameter-bindings("CFG-OVERRIDE-DEFAULTS")
#text(green)[✓ Test 4.3: Override all default values]

#pagebreak()

// =============================================================================
// TEST 5: Multiple Features with Parameters
// =============================================================================

#heading(level: 2)[Test 5: Multiple Features with Parameters]

#feature("Cache", id: "F-CACHE-MULTI", parent: "ROOT",
  parameters: (
    size: (type: "Integer", range: (16, 2048), default: 256),
    policy: (type: "Enum", values: ("LRU", "FIFO"), default: "LRU")
  )
)[Cache feature]

#feature("Database", id: "F-DB-MULTI", parent: "ROOT",
  parameters: (
    max_conn: (type: "Integer", range: (10, 1000), default: 100),
    timeout: (type: "Integer", range: (1, 300), default: 30)
  )
)[Database feature]

#feature("Logging", id: "F-LOG-MULTI", parent: "ROOT",
  parameters: (
    level: (type: "Enum", values: ("debug", "info", "warn", "error"), default: "info"),
    enabled: (type: "Boolean", default: true)
  )
)[Logging feature]

// Test: Multiple features with parameters in one configuration
#config("CFG-MULTI-FEATURES",
  root_feature_id: "ROOT",
  selected: ("F-CACHE-MULTI", "F-DB-MULTI", "F-LOG-MULTI"),
  bindings: (
    "F-CACHE-MULTI": (
      size: 512,
      policy: "FIFO"
    ),
    "F-DB-MULTI": (
      max_conn: 500,
      timeout: 60
    ),
    "F-LOG-MULTI": (
      level: "debug",
      enabled: true
    )
  )
)

#validate-parameter-bindings("CFG-MULTI-FEATURES")
#text(green)[✓ Test 5.1: Multiple features with parameters]

// Test: Some features use defaults, some have explicit bindings
#config("CFG-MIXED-BINDINGS",
  root_feature_id: "ROOT",
  selected: ("F-CACHE-MULTI", "F-DB-MULTI", "F-LOG-MULTI"),
  bindings: (
    "F-CACHE-MULTI": (
      size: 1024,
      // policy uses default "LRU"
    ),
    "F-DB-MULTI": (
      // max_conn uses default 100
      timeout: 120
    ),
    "F-LOG-MULTI": (
      level: "error",
      enabled: false
    )
  )
)

#validate-parameter-bindings("CFG-MIXED-BINDINGS")
#text(green)[✓ Test 5.2: Mixed explicit bindings and defaults]

#pagebreak()

// =============================================================================
// TEST 6: Complex Parameter Schemas
// =============================================================================

#heading(level: 2)[Test 6: Complex Parameter Schemas]

#feature("Complex Feature", id: "F-COMPLEX", parent: "ROOT",
  parameters: (
    // Integer with large range
    capacity: (
      type: "Integer",
      range: (1, 1000000),
      unit: "items",
      default: 10000,
      description: "Maximum item capacity"
    ),
    // Enum with many values
    mode: (
      type: "Enum",
      values: ("development", "testing", "staging", "production", "disaster-recovery"),
      default: "production",
      description: "Deployment mode"
    ),
    // Multiple boolean flags
    flag_a: (type: "Boolean", default: false, description: "Enable feature A"),
    flag_b: (type: "Boolean", default: true, description: "Enable feature B"),
    flag_c: (type: "Boolean", default: false, description: "Enable feature C"),
    // Integer with unit
    timeout_ms: (
      type: "Integer",
      range: (100, 60000),
      unit: "milliseconds",
      default: 5000,
      description: "Request timeout"
    )
  ),
  constraints: (
    "capacity >= 1",
    "timeout_ms >= 100"
  )
)[Complex feature with many parameters]

// Test: All parameters explicitly set
#config("CFG-COMPLEX-EXPLICIT",
  root_feature_id: "ROOT",
  selected: ("F-COMPLEX",),
  bindings: (
    "F-COMPLEX": (
      capacity: 500000,
      mode: "staging",
      flag_a: true,
      flag_b: false,
      flag_c: true,
      timeout_ms: 30000
    )
  )
)

#validate-parameter-bindings("CFG-COMPLEX-EXPLICIT")
#text(green)[✓ Test 6.1: Complex feature with all explicit values]

// Test: Minimal bindings with many defaults
#config("CFG-COMPLEX-DEFAULTS",
  root_feature_id: "ROOT",
  selected: ("F-COMPLEX",),
  bindings: (
    "F-COMPLEX": (
      capacity: 50000,
      mode: "development"
      // All flags use defaults
      // timeout_ms uses default
    )
  )
)

#validate-parameter-bindings("CFG-COMPLEX-DEFAULTS")
#text(green)[✓ Test 6.2: Complex feature with minimal bindings]

#pagebreak()

// =============================================================================
// TEST 7: Edge Cases
// =============================================================================

#heading(level: 2)[Test 7: Edge Cases]

#feature("Edge Cases", id: "F-EDGE", parent: "ROOT",
  parameters: (
    // Single value range
    single: (type: "Integer", range: (42, 42), default: 42),
    // Two value enum
    binary: (type: "Enum", values: ("on", "off"), default: "off"),
    // Large numbers
    big_number: (type: "Integer", range: (1000000, 999999999), default: 5000000)
  )
)[Edge case parameters]

// Test: Single value range
#config("CFG-EDGE-SINGLE",
  root_feature_id: "ROOT",
  selected: ("F-EDGE",),
  bindings: (
    "F-EDGE": (
      single: 42,  // Only valid value
      binary: "on",
      big_number: 50000000
    )
  )
)

#validate-parameter-bindings("CFG-EDGE-SINGLE")
#text(green)[✓ Test 7.1: Single-value range parameter]

// Test: Binary enum
#config("CFG-EDGE-BINARY-ON",
  root_feature_id: "ROOT",
  selected: ("F-EDGE",),
  bindings: (
    "F-EDGE": (
      single: 42,
      binary: "on",
      big_number: 1000000
    )
  )
)

#validate-parameter-bindings("CFG-EDGE-BINARY-ON")
#text(green)[✓ Test 7.2: Binary enum value "on"]

#config("CFG-EDGE-BINARY-OFF",
  root_feature_id: "ROOT",
  selected: ("F-EDGE",),
  bindings: (
    "F-EDGE": (
      single: 42,
      binary: "off",
      big_number: 999999999
    )
  )
)

#validate-parameter-bindings("CFG-EDGE-BINARY-OFF")
#text(green)[✓ Test 7.3: Binary enum value "off"]

// Test: Large numbers
#config("CFG-EDGE-LARGE",
  root_feature_id: "ROOT",
  selected: ("F-EDGE",),
  bindings: (
    "F-EDGE": (
      single: 42,
      binary: "on",
      big_number: 999999999  // Maximum value
    )
  )
)

#validate-parameter-bindings("CFG-EDGE-LARGE")
#text(green)[✓ Test 7.4: Large number at maximum]

#pagebreak()

// =============================================================================
// Test Summary
// =============================================================================

#heading(level: 1)[Test Summary]

#text(size: 12pt, weight: "bold", fill: green)[✓ All Parameter Validation Tests Passed!]

#table(
  columns: (auto, auto, auto),
  align: (left, center, left),
  table.header([*Test Category*], [*Tests*], [*Coverage*]),

  [Integer Parameters], [3], [Range validation, boundaries, negative values],
  [Boolean Parameters], [3], [True, false, mixed values],
  [Enum Parameters], [8], [All enum values across multiple parameters],
  [Default Values], [3], [All defaults, partial, overrides],
  [Multiple Features], [2], [Multi-feature configs, mixed bindings],
  [Complex Schemas], [2], [Many parameters, units, descriptions],
  [Edge Cases], [4], [Single-value range, binary enum, large numbers],

  table.hline(),
  [*Total*], [*25*], [*Comprehensive coverage*]
)

#parbreak()

#text(size: 11pt)[
  This test suite validates:
  - ✅ Integer type validation and range checking
  - ✅ Boolean type validation
  - ✅ Enum type validation and membership checking
  - ✅ Default value handling (all, partial, override)
  - ✅ Multiple features with parameters in one configuration
  - ✅ Complex parameter schemas with units and descriptions
  - ✅ Edge cases (single-value ranges, binary enums, large numbers)
  - ✅ Boundary value testing (min/max ranges)
]
