#import "../packages/preview/assemblyline/main/lib/lib.typ": *

// Simple test to show new group markers

#feature("Root", id: "ROOT", parent: none, concrete: false)[
  Root feature.
]

#feature("OR Group Feature", id: "OR-GROUP", parent: "ROOT", concrete: false, group: "OR")[
  This is an OR group - select any children.
]

#feature("Child A", id: "CHILD-A", parent: "OR-GROUP", concrete: true)[
  First option.
]

#feature("Child B", id: "CHILD-B", parent: "OR-GROUP", concrete: true)[
  Second option.
]

#feature("XOR Group Feature", id: "XOR-GROUP", parent: "ROOT", concrete: false, group: "XOR")[
  This is an XOR group - select only one child.
]

#feature("Option 1", id: "OPT-1", parent: "XOR-GROUP", concrete: true)[
  First exclusive option.
]

#feature("Option 2", id: "OPT-2", parent: "XOR-GROUP", concrete: true)[
  Second exclusive option.
]

#feature("Regular Feature", id: "REGULAR", parent: "ROOT", concrete: true)[
  A regular feature with no group.
]

= Group Marker Demonstration

== Standard Tree

#feature-tree(root: "ROOT")

#pagebreak()

== Detailed Tree

#feature-tree-detailed(root: "ROOT", show-descriptions: true)
