// diagrams/login-sequence.typ
#import "../packages/preview/assemblyline/main/lib/lib.typ": *

// #sequence_diagram (or any diagram type)
// ──────────────────────────────────────────────────────────────────────────────
// Purpose:      Behavioural design artefact that formally satisfies requirements
// New in v1.1:  belongs_to: "UC-LOGIN" → explicitly declares this diagram
//               illustrates the named use-case (very common in regulated industries)
// Allowed links:
//   satisfy:      → requirements (SysML term)
//   belongs_to:   → use-case (new – enables perfect bidirectional traceability)

#sequence_diagram("SD-LOGIN",
  title: "Login Sequence – Mobile Push + TOTP Path",
  tags: (
    variant: "F-PUSH",
    tool: "mermaid",
    reviewed: "2025-11-15",
    author: "Maria García"
  ),
  links: (
    satisfy: ("REQ-AUTH-001", "REQ-AUTH-001.1", "REQ-AUTH-001.2"),
    belongs_to: "UC-LOGIN"        // This is the new link type you asked for
  )
)[
  // Actual Mermaid/PlantUML/TikZ source can be here or in external file.
  // The element is still part of the model even if body is empty.
]

