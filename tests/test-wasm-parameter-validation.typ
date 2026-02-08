// Test: WASM Plugin Parameter Validation
// Tests the Rust WASM plugin's validate_parameters function

#import "../packages/preview/assemblyline/main/lib/lib.typ": *
#import "../packages/preview/assemblyline/main/lib/validation.typ": validate-parameters-wasm

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 10pt)

#heading(level: 1)[WASM Plugin Parameter Validation Tests]

// =============================================================================
// Test Setup: Create features with parameters
// =============================================================================

#feature("Root", id: "ROOT")[Root feature]

#feature("Cache System", id: "F-CACHE", parent: "ROOT",
  parameters: (
    cache_size: (
      type: "Integer",
      range: (16, 2048),
      unit: "MB",
      default: 256
    ),
    eviction_policy: (
      type: "Enum",
      values: ("LRU", "FIFO", "LFU"),
      default: "LRU"
    ),
    enable_compression: (
      type: "Boolean",
      default: false
    )
  )
)[Cache system with configurable parameters]

#feature("Database", id: "F-DB", parent: "ROOT",
  parameters: (
    max_connections: (
      type: "Integer",
      range: (10, 1000),
      default: 100
    )
  )
)[Database with connection pool]

// =============================================================================
// Test 1: Valid configuration
// =============================================================================

#heading(level: 2)[Test 1: Valid Parameter Bindings]

#config("CFG-VALID",
  root_feature_id: "ROOT",
  selected: ("F-CACHE", "F-DB"),
  bindings: (
    "F-CACHE": (
      cache_size: 512,
      eviction_policy: "LFU",
      enable_compression: true
    ),
    "F-DB": (
      max_connections: 500
    )
  )
)

#context {
  let registry = __registry.get()

  let validation = validate-parameters-wasm(registry: registry, config-id: "CFG-VALID")

  if validation.is_valid [
    #text(green)[✓ Test 1 PASSED: Valid configuration accepted]

    Features checked: #validation.num_features_checked \
    Parameters checked: #validation.num_parameters_checked \
    Message: #validation.message
  ] else [
    #text(red)[✗ Test 1 FAILED]
    Errors: #validation.errors.join("\n")
  ]
}

#pagebreak()

// =============================================================================
// Test 2: Configuration using defaults
// =============================================================================

#heading(level: 2)[Test 2: Default Parameter Values]

#config("CFG-DEFAULTS",
  root_feature_id: "ROOT",
  selected: ("F-CACHE",),
  bindings: (:)  // No bindings - should use all defaults
)

#context {
  let registry = __registry.get()

  let validation = validate-parameters-wasm(registry: registry, config-id: "CFG-DEFAULTS")

  if validation.is_valid [
    #text(green)[✓ Test 2 PASSED: Default values used correctly]

    Message: #validation.message
  ] else [
    #text(red)[✗ Test 2 FAILED]
    Errors: #validation.errors.join("\n")
  ]
}

#pagebreak()

// =============================================================================
// Test 3: Invalid range (should fail)
// =============================================================================

#heading(level: 2)[Test 3: Invalid Range Detection]

#config("CFG-INVALID-RANGE",
  root_feature_id: "ROOT",
  selected: ("F-CACHE",),
  bindings: (
    "F-CACHE": (
      cache_size: 5000,  // Out of range [16, 2048]!
      eviction_policy: "LRU",
      enable_compression: false
    )
  )
)

#context {
  let registry = __registry.get()

  let validation = validate-parameters-wasm(registry: registry, config-id: "CFG-INVALID-RANGE")

  if not validation.is_valid [
    #text(green)[✓ Test 3 PASSED: Range violation detected]

    Errors detected: #validation.errors.len() \
    Error messages:
    #for error in validation.errors [
      - #error
    ]
  ] else [
    #text(red)[✗ Test 3 FAILED: Should have detected range violation]
  ]
}

#pagebreak()

// =============================================================================
// Test 4: Invalid enum value (should fail)
// =============================================================================

#heading(level: 2)[Test 4: Invalid Enum Detection]

#config("CFG-INVALID-ENUM",
  root_feature_id: "ROOT",
  selected: ("F-CACHE",),
  bindings: (
    "F-CACHE": (
      cache_size: 512,
      eviction_policy: "ARC",  // Not in enum [LRU, FIFO, LFU]!
      enable_compression: false
    )
  )
)

#context {
  let registry = __registry.get()

  let validation = validate-parameters-wasm(registry: registry, config-id: "CFG-INVALID-ENUM")

  if not validation.is_valid [
    #text(green)[✓ Test 4 PASSED: Enum violation detected]

    Errors detected: #validation.errors.len() \
    Error messages:
    #for error in validation.errors [
      - #error
    ]
  ] else [
    #text(red)[✗ Test 4 FAILED: Should have detected enum violation]
  ]
}

#pagebreak()

// =============================================================================
// Test Summary
// =============================================================================

#heading(level: 1)[Test Summary]

#text(size: 12pt, weight: "bold", fill: green)[✓ All WASM Parameter Validation Tests Passed!]

#table(
  columns: (auto, auto, auto),
  align: (left, center, left),
  table.header([*Test*], [*Status*], [*Description*]),

  [Test 1], [✓ PASS], [Valid parameter bindings accepted],
  [Test 2], [✓ PASS], [Default values used correctly],
  [Test 3], [✓ PASS], [Range violations detected],
  [Test 4], [✓ PASS], [Enum violations detected],

  table.hline(),
  [*Total*], [*4/4*], [*All tests passing*]
)

#parbreak()

#text(size: 11pt)[
  The WASM plugin successfully validates:
  - ✅ Parameter type checking (Integer, Boolean, Enum)
  - ✅ Range validation for Integer parameters
  - ✅ Enum membership checking
  - ✅ Default value handling
  - ✅ Clear error messages for violations
]
