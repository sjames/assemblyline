// AssemblyLine Modelling Language – Official Multi-File Specification
// This repository contains the complete, normative, executable specification
// of the modelling syntax. Every file is valid Typst and can be compiled
// individually or together.
//
// Repository layout (real projects will use exactly this structure):
//
// ├── main.typ                 main entry point (compiles everything)
// ├── features/
// │   ├── root.typ
// features/authentication.typ
#import "../packages/preview/assemblyline/main/lib/lib.typ": *

// #feature
// ──────────────────────────────────────────────────────────────────────────────
// Purpose:      Product-line feature modelling (mandatory/optional/XOR/OR)
// Mandatory:    id: "UNIQUE"
// Structural:   parent: "ID"          → hierarchy
//               concrete: true|false  → only concrete features can be selected
//               group: "XOR"|"OR"     → variability group (only on parent)
// Optional:     tags: (key: value, ...) → infinite extensibility
// Content:      Free-form description of the feature
// Rationale:    Features are the primary organising principle in product-line
//               engineering. Requirements are linked to features via the
//               belongs_to parameter (see #req below).

#feature("Secure Authentication", id: "F-AUTH", concrete: true, parent: "ROOT", tags: (
  priority: "P1",
  certification: ("GDPR", "CC-EAL4+", "ISO-27001"),
  owner: "Security Team",
  rationale: "Regulatory requirement for all 2025 devices"
))[
  Every device shall provide strong, configurable authentication.
]

// ══════════════════════════════════════════════════════════════════════════════
// TOP-LEVEL REQUIREMENTS (linked to features via belongs_to)
// ══════════════════════════════════════════════════════════════════════════════

#req("REQ-AUTH-001", belongs_to: "F-AUTH", tags: (
  type: "functional",
  safety: "QM",
  security: "confidentiality-integrity",
  source: "GDPR Art. 32"
))[
  The system shall enforce multi-factor authentication for all remote access.
]

// ══════════════════════════════════════════════════════════════════════════════
// DERIVED REQUIREMENTS (decomposition via derives_from)
// These requirements inherit their feature relationship through the parent chain
// ══════════════════════════════════════════════════════════════════════════════

#req("REQ-AUTH-001.1", derives_from: "REQ-AUTH-001", tags: (
  type: "functional",
  rationale: "TOTP is industry standard for time-based second factor"
))[
  The system shall support Time-based One-Time Password (RFC 6238) as second factor.
]

#req("REQ-AUTH-001.2", derives_from: "REQ-AUTH-001", tags: (
  type: "functional",
  rationale: "Push notifications provide better UX than manual code entry"
))[
  The system shall support push-based approval via the mobile companion app.
]

// Further decomposition: Breaking down TOTP requirement into implementation details
#req("REQ-AUTH-001.1.1", derives_from: "REQ-AUTH-001.1", tags: (
  type: "functional",
  implementation: "security-module"
))[
  The TOTP implementation shall use SHA-256 as the hash algorithm.
]

#req("REQ-AUTH-001.1.2", derives_from: "REQ-AUTH-001.1", tags: (
  type: "functional",
  implementation: "security-module"
))[
  The TOTP time step shall be configurable between 30 and 60 seconds.
]

#req("REQ-AUTH-001.1.3", derives_from: "REQ-AUTH-001.1", tags: (
  type: "functional",
  implementation: "security-module"
))[
  The system shall accept codes from the previous and next time window to account for clock skew.
]

#feature("Authentication Method", id: "AUTH-METHOD", concrete: false, parent: "F-AUTH", group: "XOR", tags: (
  variability: "alternative"
))[]

#feature("Biometric – Fingerprint", id: "F-BIO", concrete: true, parent: "AUTH-METHOD", tags: (
  hardware-required: "fingerprint-module-v3",
  cost-impact: "+18 EUR"
))[ /* requirements in separate file if desired */ ]

#feature("Mobile Push + TOTP", id: "F-PUSH", concrete: true, parent: "AUTH-METHOD", tags: (
  cost-impact: "+0 EUR",
  user-experience: "best"
))[]

