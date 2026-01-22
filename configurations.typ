// configurations.typ
#import "lib/lib.typ": *

// European Market Configuration
#config(
  "CFG-EU",
  title: "European Market Configuration",
  root_feature_id: "ROOT",
  selected: (
    // Authentication
    "F-AUTH",
    "F-PUSH",
    // Authorization
    "F-AUTHZ",
    "F-ABAC",  // GDPR requires fine-grained control
    "F-PERM-MGMT",
    // User Management
    "F-USER-MGMT",
    "F-USER-REG",
    "F-PROFILE",
    "F-ACCOUNT-DEL",  // GDPR right to erasure
    "F-PWD-RECOVERY",
    // Session Management
    "F-SESSION",
    "F-SESSION-REDIS",  // Scalability for EU market
    "F-SESSION-CONCURRENT",
    "F-SESSION-SEC",
    // Audit & Logging
    "F-AUDIT",
    "F-LOG-ELK",  // Centralized logging
    "F-LOG-ALERT",
    "F-COMPLIANCE",
    // Data Protection
    "F-DATA-PROTECT",
    "F-ENCRYPT-REST",
    "F-ENCRYPT-TRANSIT",
    "F-KEY-CLOUD",  // Cloud KMS for EU
    "F-DATA-MASK",
    "F-DLP",
    // API Security
    "F-API-SEC",
    "F-OAUTH2",
    "F-JWT",
    "F-RATE-LIMIT",
    "F-API-GATEWAY",
    "F-API-VERSION",
    "F-API-DOCS",
    // Monitoring
    "F-MONITOR",
    "F-METRICS",
    "F-TRACING",
    "F-HEALTH",
    "F-ALERT",
    "F-DASHBOARD",
    "F-LOG-AGG",
    "F-PROFILING"
  ),
  tags: (
    market: "Europe",
    regulations: ("GDPR", "ISO-27001", "SOC-2"),
    target-cost: "mid-range",
    deployment: "cloud"
  )
)

// North American Market Configuration
#config(
  "CFG-NA",
  title: "North American Market Configuration",
  root_feature_id: "ROOT",
  selected: (
    // Authentication
    "F-AUTH",
    "F-BIO",  // Enterprise prefers biometric
    // Authorization
    "F-AUTHZ",
    "F-RBAC-HIER",  // Hierarchical for large orgs
    "F-PERM-MGMT",
    // User Management
    "F-USER-MGMT",
    "F-USER-REG",
    "F-PROFILE",
    "F-ACCOUNT-DEL",
    "F-PWD-RECOVERY",
    // Session Management
    "F-SESSION",
    "F-SESSION-DB",  // Persistence for compliance
    "F-SESSION-CONCURRENT",
    "F-SESSION-SEC",
    // Audit & Logging
    "F-AUDIT",
    "F-LOG-SIEM",  // Enterprise SIEM integration
    "F-LOG-ALERT",
    "F-COMPLIANCE",
    // Data Protection
    "F-DATA-PROTECT",
    "F-ENCRYPT-REST",
    "F-ENCRYPT-TRANSIT",
    "F-KEY-HSM",  // Maximum security for NA enterprise
    "F-DATA-MASK",
    "F-DLP",
    // API Security
    "F-API-SEC",
    "F-API-KEY",
    "F-OAUTH2",
    "F-JWT",
    "F-MTLS",  // Maximum security
    "F-RATE-LIMIT",
    "F-API-GATEWAY",
    "F-API-VERSION",
    "F-API-DOCS",
    // Monitoring
    "F-MONITOR",
    "F-METRICS",
    "F-TRACING",
    "F-HEALTH",
    "F-ALERT",
    "F-DASHBOARD",
    "F-LOG-AGG",
    "F-PROFILING"
  ),
  tags: (
    market: "North America",
    regulations: ("SOC-2", "HIPAA", "NIST"),
    target-cost: "premium",
    deployment: "hybrid"
  )
)

// Small Business Configuration
#config(
  "CFG-SMB",
  title: "Small Business Configuration",
  root_feature_id: "ROOT",
  selected: (
    // Authentication
    "F-AUTH",
    "F-PUSH",  // Cost-effective option
    // Authorization
    "F-AUTHZ",
    "F-RBAC-SIMPLE",  // Simple RBAC for small teams
    "F-PERM-MGMT",
    // User Management
    "F-USER-MGMT",
    "F-USER-REG",
    "F-PROFILE",
    "F-PWD-RECOVERY",
    // Session Management
    "F-SESSION",
    "F-SESSION-MEM",  // Low cost for small deployments
    "F-SESSION-SEC",
    // Audit & Logging
    "F-AUDIT",
    "F-LOG-FILE",  // Basic file logging
    "F-LOG-ALERT",
    // Data Protection
    "F-DATA-PROTECT",
    "F-ENCRYPT-REST",
    "F-ENCRYPT-TRANSIT",
    "F-KEY-SOFTWARE",  // Budget option
    "F-DATA-MASK",
    // API Security
    "F-API-SEC",
    "F-API-KEY",
    "F-JWT",
    "F-RATE-LIMIT",
    "F-API-VERSION",
    "F-API-DOCS",
    // Monitoring
    "F-MONITOR",
    "F-METRICS",
    "F-HEALTH",
    "F-ALERT",
    "F-DASHBOARD"
  ),
  tags: (
    market: "Global",
    regulations: ("Basic",),
    target-cost: "budget",
    deployment: "single-server"
  )
)
