// Test suite for AssemblyLine validation module
// Tests the plugin loading and wrapper functions

#import "packages/preview/assemblyline/main/lib/lib.typ": *

= Validation Module Tests

== Test 1: Plugin Availability

```
Plugin available: #plugin-available()
```

== Test 2: Basic Feature and Requirement

Register a simple feature and requirement to test the validation system:

#feature("Test Feature", id: "F-TEST", concrete: true)[
  This is a test feature.
]

#req("REQ-TEST-001", belongs_to: "F-TEST")[
  This is a test requirement.
]

#feature("Root Feature", id: "F-ROOT")[
  Root of the feature tree.
]

== Test 3: Validation Results

#context {
  let registry = __registry.get()
  let all-links = __links.get()

  heading(level: 3)[Registry State]

  [
    *Elements registered:* #registry.len()

    *Elements:*
    #for (id, elem) in registry.pairs() [
      - `#id` (#elem.type): #elem.at("title", default: "")
    ]
  ]

  heading(level: 3)[Links State]

  [
    *Total links:* #all-links.len()

    #if all-links.len() > 0 [
      *Links:*
      #for link in all-links [
        - #link.source → #link.target (type: #link.at("type"))
      ]
    ]
  ]

  heading(level: 3)[Running Validation]

  let result = validate-traceability(registry, all-links)

  [
    *Validation Result:*
    - Status: #validation-status(result)
    - Message: #result.at("message", default: "No message")
  ]

  format-validation-errors(result)
}

== Test 4: Validation with Config

#config("CFG-TEST", root_feature_id: "F-ROOT", selected: ("F-TEST", "F-ROOT"))

#context {
  let registry = __registry.get()
  let all-links = __links.get()
  let active = __active-config.get()

  heading(level: 3)[With Configuration]

  let result = validate-traceability(registry, all-links, active-config: active)

  [
    *Validation with active config:*
    - Status: #validation-status(result)
  ]
}

== Test 5: Use Case with Link

#use_case("Test Use Case", id: "UC-TEST", links: (trace: ("REQ-TEST-001",)))[
  This use case tests the traceability system.
]

#context {
  let all-links = __links.get()

  heading(level: 3)[Links Added]

  [
    #for link in all-links.filter(l => l.source == "UC-TEST") [
      - Link from UC-TEST to #link.target (type: #link.at("type"))
    ]
  ]
}

== Summary

This test file verifies:
- ✓ Plugin loading mechanism
- ✓ Basic element registration
- ✓ Link tracking
- ✓ Validation function execution
- ✓ Result formatting
- ✓ Configuration support
