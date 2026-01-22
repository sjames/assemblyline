// use-cases/login.typ
#import "../lib/lib.typ": *

// #use_case
// ──────────────────────────────────────────────────────────────────────────────
// Purpose:      Behavioural scenario that shows how actors achieve goals
// Links:        trace → requirements (classic use-case to req traceability)
//               belongs_to → can be owned by a feature or subsystem (optional)
// New in v1.1:  Diagrams can belong_to a use-case (see below)

#use_case("UC-01 – Successful Remote Login", id: "UC-LOGIN",
  tags: (
    actor: "Homeowner",
    frequency: "high",
    pre-condition: "Internet available"
  ),
  links: (
    trace: ("REQ-AUTH-001", "REQ-AUTH-001.1", "REQ-AUTH-001.2")
  )
)[
  The homeowner opens the mobile app and successfully logs in using the selected
  second factor (push approval or TOTP).
]

