// Test: Parameter Validation
// This should FAIL with validation errors to demonstrate validation works

#import "../packages/preview/assemblyline/main/lib/lib.typ": *

#feature("Root", id: "ROOT")[Root feature]

#feature("Cache", id: "F-CACHE", parent: "ROOT",
  parameters: (
    cache_size: (
      type: "Integer",
      range: (16, 2048),
      default: 256
    ),
    policy: (
      type: "Enum",
      values: ("LRU", "FIFO"),
      default: "LRU"
    )
  )
)[Cache system]

// Configuration with INVALID bindings (should fail validation)
#config("CFG-INVALID",
  title: "Invalid Config",
  root_feature_id: "ROOT",
  selected: ("F-CACHE",),
  bindings: (
    "F-CACHE": (
      cache_size: 5000,        // OUT OF RANGE! Should be [16, 2048]
      policy: "ARC"            // NOT IN ENUM! Should be LRU or FIFO
    )
  )
)

#heading[This should fail with validation errors:]

// This should trigger validation errors
#validate-parameter-bindings("CFG-INVALID")
