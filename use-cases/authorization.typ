// use-cases/authorization.typ
#import "../lib/lib.typ": *

#use_case("UC-02 – Access Protected Resource", id: "UC-ACCESS",
  tags: (
    actor: "Authenticated User",
    frequency: "very-high",
    pre-condition: "User is authenticated",
    post-condition: "Access granted or denied based on permissions"
  ),
  links: (
    trace: ("REQ-AUTHZ-001", "REQ-AUTHZ-002")
  )
)[
  An authenticated user attempts to access a protected resource (e.g., admin panel, sensitive data).
  The system evaluates the user's permissions against the resource's access control policy
  and either grants or denies access.

  *Main Flow:*
  1. User requests access to protected resource
  2. System retrieves user's roles and attributes
  3. System evaluates access control policy (RBAC or ABAC)
  4. System grants access if authorized
  5. User accesses the resource

  *Alternate Flow (Access Denied):*
  - If user lacks required permissions, system returns 403 Forbidden
  - System logs the access attempt for audit purposes
]

#use_case("UC-03 – Session Timeout and Re-authentication", id: "UC-TIMEOUT",
  tags: (
    actor: "Authenticated User",
    frequency: "medium",
    pre-condition: "User session is active",
    post-condition: "User is logged out or re-authenticated"
  ),
  links: (
    trace: ("REQ-SESSION-002", "REQ-SESSION-003")
  )
)[
  After a period of inactivity, the user's session expires and they must re-authenticate
  to continue using the system. This ensures security by limiting the window of opportunity
  for session hijacking.

  *Main Flow:*
  1. User is inactive for configured timeout period (e.g., 30 minutes)
  2. System detects session expiration
  3. System invalidates session token
  4. User attempts to perform an action
  5. System prompts for re-authentication
  6. User provides credentials
  7. System creates new session

  *Security Considerations:*
  - Timeout period configurable per deployment
  - Sensitive operations may require immediate re-authentication regardless of session age
]

#use_case("UC-04 – Audit Log Review", id: "UC-AUDIT",
  tags: (
    actor: "Security Administrator",
    frequency: "daily",
    pre-condition: "Administrator has audit viewer role",
    post-condition: "Security events reviewed"
  ),
  links: (
    trace: ("REQ-AUDIT-001", "REQ-AUDIT-002", "REQ-AUDIT-003")
  )
)[
  Security administrators regularly review audit logs to detect suspicious activities,
  ensure compliance, and investigate security incidents.

  *Main Flow:*
  1. Administrator accesses audit log interface
  2. System displays recent security events (logins, permission changes, access denials)
  3. Administrator filters logs by time range, user, event type, or severity
  4. Administrator identifies suspicious patterns or policy violations
  5. Administrator exports logs for compliance reporting or further analysis

  *Logged Events Include:*
  - Authentication attempts (successful and failed)
  - Authorization decisions (granted and denied)
  - Session lifecycle events
  - Administrative actions (user/role modifications)
  - Configuration changes
]
