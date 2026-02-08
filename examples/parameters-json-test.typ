// Test JSON export with parameters
#import "../packages/preview/assemblyline/main/lib/lib.typ": *
#import "../packages/preview/assemblyline/main/lib/json-export.typ": handle-json-export

#feature("Root", id: "ROOT")[Root]

#feature("Cache", id: "F-CACHE", parent: "ROOT",
  parameters: (
    cache_size: (
      type: "Integer",
      range: (16, 2048),
      unit: "MB",
      default: 256
    ),
    policy: (
      type: "Enum",
      values: ("LRU", "FIFO"),
      default: "LRU"
    )
  ),
  constraints: (
    "cache_size >= 16",
  )
)[Cache]

#config("CFG-TEST",
  root_feature_id: "ROOT",
  selected: ("F-CACHE",),
  bindings: (
    "F-CACHE": (
      cache_size: 512,
      policy: "FIFO"
    )
  )
)

// Export JSON
#handle-json-export()
