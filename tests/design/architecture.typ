// architecture.typ
// System Architecture using SysML Block Definitions
#import "../packages/preview/assemblyline/main/lib/lib.typ": *

// ══════════════════════════════════════════════════════════════════════════════
// Top-Level System Block
// ══════════════════════════════════════════════════════════════════════════════

#block_definition(
  "BLK-SYSTEM",
  title: "Enterprise Security Platform",
  properties: (
    (name: "maxUsers", type: "Integer", default: "10000", unit: "users"),
    (name: "maxSessions", type: "Integer", default: "50000", unit: "sessions"),
    (name: "responseTime", type: "Real", default: "100", unit: "ms"),
    (name: "availability", type: "Real", default: "99.9", unit: "%"),
  ),
  operations: (
    (name: "initialize", params: "config: Config", returns: "bool"),
    (name: "shutdown", params: "void", returns: "void"),
    (name: "healthCheck", params: "void", returns: "HealthStatus"),
  ),
  ports: (
    (name: "httpPort", direction: "in", protocol: "HTTPS"),
    (name: "adminPort", direction: "in", protocol: "HTTPS"),
    (name: "metricsPort", direction: "out", protocol: "Prometheus"),
  ),
  parts: (
    (name: "authService", type: "BLK-AUTH-SERVICE", multiplicity: "1"),
    (name: "authzService", type: "BLK-AUTHZ-SERVICE", multiplicity: "1"),
    (name: "sessionManager", type: "BLK-SESSION-MGR", multiplicity: "1"),
    (name: "auditService", type: "BLK-AUDIT-SERVICE", multiplicity: "1"),
    (name: "userManager", type: "BLK-USER-MGR", multiplicity: "1")
  ),
  connectors: (
    // Delegation: External HTTP port to auth service API
    (from: "httpPort", to: "authService.authAPI", flow: "HTTPRequest"),

    // Delegation: External admin port to user manager API
    (from: "adminPort", to: "userManager.userAPI", flow: "AdminRequest"),

    // Internal: Auth service to user manager database
    (from: "authService.userDbPort", to: "userManager.userDb", flow: "UserQuery"),

    // Internal: Auth service to authorization service
    (from: "authService.authAPI", to: "authzService.authzAPI", flow: "AuthzRequest"),

    // Internal: Auth service to session manager
    (from: "authService.authAPI", to: "sessionManager.sessionAPI", flow: "SessionRequest"),

    // Internal: All services to audit service
    (from: "authService.auditPort", to: "auditService.logAPI", flow: "AuditEvent"),
    (from: "authzService.auditPort", to: "auditService.logAPI", flow: "AuditEvent"),
    (from: "sessionManager.auditPort", to: "auditService.logAPI", flow: "AuditEvent"),
    (from: "userManager.auditPort", to: "auditService.logAPI", flow: "AuditEvent"),

    // Delegation: Audit service SIEM to external metrics port
    (from: "auditService.metricsPort", to: "metricsPort", flow: "Metrics")
  ),
  constraints: (
    "responseTime <= 200ms",
    "availability >= 99.5%",
    "maxConcurrentUsers <= maxUsers * 1.2"
  ),
  tags: (
    stereotype: "system",
    deployment: "kubernetes",
    criticality: "high"
  ),
  links: (
    satisfy: ()  // TODO: Add system-level requirements
  )
)[
  The Enterprise Security Platform is a comprehensive authentication, authorization,
  and user management system designed for enterprise-scale deployments. It provides
  secure access control with full audit logging and compliance features.

  The system is designed as a distributed microservices architecture with independent
  scaling capabilities for each service component.
]

// // Internal block diagram for the system
// #internal-block-diagram(
//   "IBD-SYSTEM",
//   title: "System Internal Block Diagram",
//   block: "BLK-SYSTEM"
// )[
//   // The internal structure is defined by the parts and connectors in the BLK-SYSTEM definition.
//   // Th
        
// ]
// )


// ══════════════════════════════════════════════════════════════════════════════
// Authentication Service
// ══════════════════════════════════════════════════════════════════════════════

#block_definition(
  "BLK-AUTH-SERVICE",
  title: "Authentication Service",
  properties: (
    (name: "tokenLifetime", type: "Integer", default: "3600", unit: "seconds"),
    (name: "refreshLifetime", type: "Integer", default: "86400", unit: "seconds"),
    (name: "maxFailedAttempts", type: "Integer", default: "5", unit: "attempts"),
    (name: "lockoutDuration", type: "Integer", default: "900", unit: "seconds"),
  ),
  operations: (
    (name: "authenticate", params: "credentials: Credentials", returns: "Token"),
    (name: "verifyMFA", params: "token: string, code: string", returns: "bool"),
    (name: "refreshToken", params: "refreshToken: string", returns: "Token"),
    (name: "logout", params: "token: string", returns: "void"),
  ),
  ports: (
    (name: "authAPI", direction: "in", protocol: "REST/HTTPS"),
    (name: "mfaPort", direction: "out", protocol: "TOTP/Push"),
    (name: "userDbPort", direction: "out", protocol: "SQL"),
  ),
  parts: (
    (name: "passwordValidator", type: "BLK-PASSWORD-VALIDATOR", multiplicity: "1"),
    (name: "mfaHandler", type: "BLK-MFA-HANDLER", multiplicity: "1"),
    (name: "tokenManager", type: "BLK-TOKEN-MANAGER", multiplicity: "1")
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
  constraints: (
    "tokenLifetime < refreshLifetime",
    "maxFailedAttempts >= 3 AND maxFailedAttempts <= 10",
    "lockoutDuration >= 300"
  ),
  tags: (
    stereotype: "service",
    language: "Go",
    framework: "Gin"
  ),
  links: (
    satisfy: ("REQ-AUTH-001", "REQ-AUTH-001.1", "REQ-AUTH-001.2")
  )
)[
  The Authentication Service handles all user authentication flows including
  password validation, multi-factor authentication (TOTP and push notifications),
  and token lifecycle management.

  It implements secure password hashing using Argon2id and enforces configurable
  lockout policies to prevent brute-force attacks.
]

// ══════════════════════════════════════════════════════════════════════════════
// Authorization Service
// ══════════════════════════════════════════════════════════════════════════════

#block_definition(
  "BLK-AUTHZ-SERVICE",
  title: "Authorization Service",
  properties: (
    (name: "policyEvalTimeout", type: "Integer", default: "50", unit: "ms"),
    (name: "cacheSize", type: "Integer", default: "10000", unit: "entries"),
    (name: "cacheTTL", type: "Integer", default: "300", unit: "seconds"),
  ),
  operations: (
    (name: "authorize", params: "subject: Principal, resource: Resource, action: Action", returns: "Decision"),
    (name: "evaluatePolicy", params: "policy: Policy, context: Context", returns: "bool"),
    (name: "listPermissions", params: "principal: Principal", returns: "Permission[]"),
  ),
  ports: (
    (name: "authzAPI", direction: "in", protocol: "gRPC"),
    (name: "policyStore", direction: "out", protocol: "Redis"),
  ),
  parts: (
    (name: "rbacEngine", type: "BLK-RBAC-ENGINE", multiplicity: "1"),
    (name: "abacEngine", type: "BLK-ABAC-ENGINE", multiplicity: "1"),
    (name: "policyCache", type: "BLK-POLICY-CACHE", multiplicity: "1")
  ),
  references: (
    "BLK-USER-MGR",
    "BLK-AUDIT-SERVICE"
  ),
  constraints: (
    "policyEvalTimeout <= 100ms",
    "cacheSize <= 100000"
  ),
  tags: (
    stereotype: "service",
    language: "Rust",
    performance: "critical"
  ),
  links: (
    satisfy: ("REQ-AUTHZ-001", "REQ-AUTHZ-002")
  )
)[
  The Authorization Service provides fine-grained access control using both
  Role-Based Access Control (RBAC) and Attribute-Based Access Control (ABAC).

  It evaluates authorization policies in real-time with sub-100ms latency and
  maintains an in-memory cache for frequently accessed permissions.
]

// ══════════════════════════════════════════════════════════════════════════════
// Session Manager
// ══════════════════════════════════════════════════════════════════════════════

#block_definition(
  "BLK-SESSION-MGR",
  title: "Session Manager",
  properties: (
    (name: "sessionTimeout", type: "Integer", default: "1800", unit: "seconds"),
    (name: "maxSessionsPerUser", type: "Integer", default: "5", unit: "sessions"),
    (name: "cleanupInterval", type: "Integer", default: "60", unit: "seconds"),
  ),
  operations: (
    (name: "createSession", params: "userId: UUID, metadata: Map", returns: "Session"),
    (name: "getSession", params: "sessionId: UUID", returns: "Session"),
    (name: "updateActivity", params: "sessionId: UUID", returns: "void"),
    (name: "terminateSession", params: "sessionId: UUID", returns: "void"),
    (name: "cleanupExpired", params: "void", returns: "int"),
  ),
  ports: (
    (name: "sessionAPI", direction: "in", protocol: "REST"),
    (name: "sessionStore", direction: "out", protocol: "Redis/PostgreSQL"),
  ),
  references: (
    "BLK-AUTH-SERVICE",
    "BLK-AUDIT-SERVICE"
  ),
  constraints: (
    "sessionTimeout >= 300",
    "maxSessionsPerUser >= 1 AND maxSessionsPerUser <= 20"
  ),
  tags: (
    stereotype: "service",
    language: "TypeScript",
    framework: "NestJS"
  ),
  links: (
    satisfy: ("REQ-SESSION-001", "REQ-SESSION-002", "REQ-SESSION-003")
  )
)[
  The Session Manager handles the lifecycle of user sessions including creation,
  validation, renewal, and cleanup of expired sessions.

  Sessions can be stored either in Redis for distributed deployments or PostgreSQL
  for single-instance deployments, as configured by the active product configuration.
]

// ══════════════════════════════════════════════════════════════════════════════
// Audit Service
// ══════════════════════════════════════════════════════════════════════════════

#block_definition(
  "BLK-AUDIT-SERVICE",
  title: "Audit Logging Service",
  properties: (
    (name: "bufferSize", type: "Integer", default: "1000", unit: "events"),
    (name: "flushInterval", type: "Integer", default: "5", unit: "seconds"),
    (name: "retentionDays", type: "Integer", default: "365", unit: "days"),
    (name: "compressionEnabled", type: "Boolean", default: "true", unit: ""),
  ),
  operations: (
    (name: "logEvent", params: "event: AuditEvent", returns: "void"),
    (name: "query", params: "filter: Filter, timeRange: TimeRange", returns: "AuditEvent[]"),
    (name: "export", params: "filter: Filter, format: ExportFormat", returns: "Stream"),
  ),
  ports: (
    (name: "logAPI", direction: "in", protocol: "gRPC/Async"),
    (name: "logStore", direction: "out", protocol: "Elasticsearch/S3"),
    (name: "siemPort", direction: "out", protocol: "Syslog/CEF"),
  ),
  constraints: (
    "bufferSize >= 100 AND bufferSize <= 10000",
    "retentionDays >= 90",
    "flushInterval <= 30"
  ),
  tags: (
    stereotype: "service",
    language: "Go",
    compliance: ("GDPR", "SOC-2", "ISO-27001")
  ),
  links: (
    satisfy: ("REQ-AUDIT-001", "REQ-AUDIT-002", "REQ-AUDIT-003", "REQ-AUDIT-004")
  )
)[
  The Audit Logging Service captures all security-relevant events across the platform
  including authentication attempts, authorization decisions, administrative actions,
  and configuration changes.

  Events are buffered in-memory and flushed periodically to persistent storage
  (Elasticsearch for searchability or S3 for long-term archival). Integration
  with external SIEM systems is provided via standard protocols.
]

// ══════════════════════════════════════════════════════════════════════════════
// User Manager
// ══════════════════════════════════════════════════════════════════════════════

#block_definition(
  "BLK-USER-MGR",
  title: "User Management Service",
  properties: (
    (name: "passwordMinLength", type: "Integer", default: "12", unit: "chars"),
    (name: "passwordExpireDays", type: "Integer", default: "90", unit: "days"),
    (name: "emailVerificationRequired", type: "Boolean", default: "true", unit: ""),
  ),
  operations: (
    (name: "createUser", params: "userData: UserData", returns: "User"),
    (name: "updateUser", params: "userId: UUID, updates: UserData", returns: "User"),
    (name: "deleteUser", params: "userId: UUID", returns: "void"),
    (name: "assignRole", params: "userId: UUID, roleId: UUID", returns: "void"),
    (name: "resetPassword", params: "userId: UUID, token: string", returns: "void"),
  ),
  ports: (
    (name: "userAPI", direction: "in", protocol: "REST/GraphQL"),
    (name: "userDb", direction: "out", protocol: "PostgreSQL"),
    (name: "emailPort", direction: "out", protocol: "SMTP"),
  ),
  references: (
    "BLK-AUTH-SERVICE",
    "BLK-AUDIT-SERVICE"
  ),
  constraints: (
    "passwordMinLength >= 8",
    "passwordExpireDays >= 30 AND passwordExpireDays <= 365"
  ),
  tags: (
    stereotype: "service",
    language: "Python",
    framework: "FastAPI"
  ),
  links: (
    satisfy: ("REQ-USER-001")  // TODO: Add more user management requirements
  )
)[
  The User Management Service handles user lifecycle operations including creation,
  modification, deletion, and role assignment. It enforces password policies and
  manages email verification workflows.

  User data is stored in PostgreSQL with encrypted sensitive fields (password hashes,
  MFA secrets, recovery codes).
]

// ══════════════════════════════════════════════════════════════════════════════
// Authentication Service Sub-Components
// ══════════════════════════════════════════════════════════════════════════════

#block_definition(
  "BLK-PASSWORD-VALIDATOR",
  title: "Password Validator",
  properties: (
    (name: "hashAlgorithm", type: "String", default: "Argon2id", unit: ""),
    (name: "memoryCost", type: "Integer", default: "65536", unit: "KB"),
    (name: "timeCost", type: "Integer", default: "3", unit: "iterations"),
  ),
  operations: (
    (name: "validate", params: "username: string, password: string", returns: "ValidationResult"),
    (name: "hashPassword", params: "password: string", returns: "string"),
  ),
  ports: (
    (name: "validatePort", direction: "in", protocol: "Internal"),
    (name: "resultPort", direction: "out", protocol: "Internal"),
  ),
  tags: (
    stereotype: "component",
    criticality: "high"
  )
)[
  The Password Validator component performs secure password hashing and validation
  using Argon2id algorithm with configurable parameters.
]

#block_definition(
  "BLK-MFA-HANDLER",
  title: "Multi-Factor Authentication Handler",
  properties: (
    (name: "totpWindowSize", type: "Integer", default: "1", unit: "steps"),
    (name: "pushTimeout", type: "Integer", default: "60", unit: "seconds"),
  ),
  operations: (
    (name: "verifyTOTP", params: "secret: string, code: string", returns: "bool"),
    (name: "sendPushNotification", params: "userId: UUID, deviceId: string", returns: "bool"),
  ),
  ports: (
    (name: "verifyPort", direction: "in", protocol: "Internal"),
    (name: "resultPort", direction: "out", protocol: "Internal"),
  ),
  tags: (
    stereotype: "component"
  )
)[
  The MFA Handler manages multi-factor authentication including TOTP verification
  and push notification delivery.
]

#block_definition(
  "BLK-TOKEN-MANAGER",
  title: "Token Manager",
  properties: (
    (name: "signingAlgorithm", type: "String", default: "RS256", unit: ""),
    (name: "issuer", type: "String", default: "auth-service", unit: ""),
  ),
  operations: (
    (name: "createToken", params: "claims: Map", returns: "JWT"),
    (name: "verifyToken", params: "token: string", returns: "Claims"),
    (name: "refreshToken", params: "refreshToken: string", returns: "JWT"),
  ),
  ports: (
    (name: "createPort", direction: "in", protocol: "Internal"),
    (name: "mfaPort", direction: "out", protocol: "Internal"),
  ),
  tags: (
    stereotype: "component",
    criticality: "high"
  )
)[
  The Token Manager handles JWT token creation, verification, and refresh operations.
]

// ══════════════════════════════════════════════════════════════════════════════
// Authorization Service Sub-Components
// ══════════════════════════════════════════════════════════════════════════════

#block_definition(
  "BLK-RBAC-ENGINE",
  title: "RBAC Engine",
  properties: (
    (name: "roleHierarchyEnabled", type: "Boolean", default: "true", unit: ""),
  ),
  operations: (
    (name: "checkPermission", params: "roles: Set<Role>, permission: Permission", returns: "bool"),
    (name: "getRolePermissions", params: "role: Role", returns: "Permission[]"),
  ),
  ports: (
    (name: "evalPort", direction: "in", protocol: "Internal"),
  ),
  tags: (
    stereotype: "component"
  )
)[
  The RBAC Engine evaluates role-based access control policies with support for
  hierarchical role inheritance.
]

#block_definition(
  "BLK-ABAC-ENGINE",
  title: "ABAC Engine",
  properties: (
    (name: "policyLanguage", type: "String", default: "XACML", unit: ""),
  ),
  operations: (
    (name: "evaluatePolicy", params: "subject: Principal, resource: Resource, action: Action, context: Context", returns: "Decision"),
  ),
  ports: (
    (name: "evalPort", direction: "in", protocol: "Internal"),
  ),
  tags: (
    stereotype: "component"
  )
)[
  The ABAC Engine evaluates attribute-based access control policies using XACML
  or custom policy languages.
]

#block_definition(
  "BLK-POLICY-CACHE",
  title: "Policy Cache",
  properties: (
    (name: "maxSize", type: "Integer", default: "10000", unit: "entries"),
    (name: "ttl", type: "Integer", default: "300", unit: "seconds"),
  ),
  operations: (
    (name: "get", params: "key: string", returns: "Policy"),
    (name: "put", params: "key: string, policy: Policy", returns: "void"),
    (name: "invalidate", params: "key: string", returns: "void"),
  ),
  ports: (
    (name: "cachePort", direction: "in", protocol: "Internal"),
  ),
  tags: (
    stereotype: "component"
  )
)[
  The Policy Cache provides high-performance caching of authorization policies
  with configurable TTL and size limits.
]


