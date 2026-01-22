// diagrams/auth-service-ibd.typ
// Internal Block Diagram for Authentication Service
#import "../lib/lib.typ": *

#internal_block_diagram(
  "IBD-AUTH-SERVICE",
  title: "Authentication Service – Internal Structure",
  parts: (
    (name: "passwordValidator", type: "BLK-PASSWORD-VALIDATOR", multiplicity: "1"),
    (name: "mfaHandler", type: "BLK-MFA-HANDLER", multiplicity: "1"),
    (name: "tokenManager", type: "BLK-TOKEN-MANAGER", multiplicity: "1")
  ),
  ports: (
    (name: "authAPI", direction: "in", protocol: "REST/HTTPS"),
    (name: "mfaPort", direction: "out", protocol: "TOTP/Push"),
    (name: "userDbPort", direction: "out", protocol: "SQL")
  ),
  connectors: (
    // Delegation: External auth API to internal components
    (from: "authAPI", to: "passwordValidator.validatePort", flow: "Credentials"),
    (from: "authAPI", to: "mfaHandler.verifyPort", flow: "MFAChallenge"),

    // Internal: Password validator to token manager
    (from: "passwordValidator.resultPort", to: "tokenManager.createPort", flow: "ValidationResult"),

    // Internal: MFA handler to token manager
    (from: "mfaHandler.resultPort", to: "tokenManager.createPort", flow: "MFAResult"),

    // Delegation: Token manager to external MFA port
    (from: "tokenManager.mfaPort", to: "mfaPort", flow: "TOTPRequest")
  ),
  references: (
    "BLK-USER-MGR",
    "BLK-AUDIT-SERVICE"
  ),
  tags: (
    version: "2.0",
    reviewed: "2025-12-10",
    author: "System Architect",
    detail_level: "high"
  ),
  links: (
    satisfy: ("REQ-AUTH-001", "REQ-AUTH-001.1", "REQ-AUTH-001.2"),
    belongs_to: "BLK-AUTH-SERVICE",
    trace: "UC-LOGIN"
  )
)[
  This internal block diagram shows how the Authentication Service decomposes into
  three specialized components that work together to provide secure authentication.

  *Component Responsibilities:*

  - *Password Validator*: Validates user credentials against the user database using
    Argon2id hashing. Implements rate limiting and brute-force protection.

  - *MFA Handler*: Processes multi-factor authentication challenges including TOTP
    (Time-based One-Time Password) and mobile push notifications. Supports multiple
    MFA methods per user.

  - *Token Manager*: Issues JWT tokens upon successful authentication, manages token
    lifecycle (creation, refresh, revocation), and maintains token blacklists for
    security.

  *Connector Semantics:*

  - Delegation connectors (boundary port to part port) enable the block to expose
    internal component functionality through its external interface.

  - Internal connectors (part port to part port) show how components collaborate
    within the block to fulfill authentication workflows.

  *Design Rationale:*

  The separation into three components provides:
  - Independent scaling of password validation and MFA processing
  - Clear separation of concerns and single responsibility per component
  - Easy substitution of authentication methods
  - Better testability and maintainability
]
