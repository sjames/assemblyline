#import "packages/preview/assemblyline/main/lib/lib.typ": *

// Test 1: Links passed as parameters (current pattern)
#use_case("Test UC 1", id: "UC-TEST-1", tags: (actor: "Test"), links: (trace: ("REQ-TEST-1",)))[
  Test use case 1 content.
]

// Test 2: Multiple trace links
#use_case("Test UC 2", id: "UC-TEST-2", tags: (actor: "Test"), links: (trace: ("REQ-TEST-1", "REQ-TEST-2")))[
  Test use case 2 content with multiple requirements.
]

// Test 3: Requirements with belongs_to links
#feature("Test Feature", id: "F-TEST")[Test feature]
#req("REQ-TEST-1", belongs_to: "F-TEST")[Test requirement 1]
#req("REQ-TEST-2", belongs_to: "F-TEST")[Test requirement 2]

// Show the results
#pagebreak()
= Links Debug

#context {
  let links = __links.get()
  let registry = __registry.get()

  [*Total Links:* #links.len()]

  [*Total Elements:* #registry.len()]

  [== All Links:]
  for link in links [
    - *Source:* #link.source | *Type:* #link.at("type") | *Target:* #link.target
  ]

  [== Use Cases in Registry:]
  for (id, elem) in registry.pairs() {
    if elem.type == "use_case" [
      - *ID:* #id | *Title:* #elem.title
    ]
  }
}
