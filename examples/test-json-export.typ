// Simple JSON export test
#import "../packages/preview/assemblyline/main/lib/lib.typ": *
#import "../packages/preview/assemblyline/main/lib/json-export.typ": export-json-string

#feature("Root", id: "ROOT")[Root]

#feature("Cache", id: "F-CACHE", parent: "ROOT",
  parameters: (
    cache_size: (
      type: "Integer",
      range: (16, 2048),
      unit: "MB",
      default: 256
    )
  ),
  constraints: ("cache_size >= 16",)
)[Cache]

#config("CFG-TEST",
  root_feature_id: "ROOT",
  selected: ("F-CACHE",),
  bindings: (
    "F-CACHE": (cache_size: 512)
  )
)

#set page(width: auto, height: auto, margin: 10pt)
#set text(size: 8pt, font: "Courier New")

= JSON Export Test

#context {
  let json-str = export-json-string()
  json-str
}
