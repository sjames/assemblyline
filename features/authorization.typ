// features/authorization.typ
#import "../lib/lib.typ": *

#feature("Authorization & Access Control", id: "F-AUTHZ", concrete: true, parent: "ROOT", tags: (
  priority: "P1",
  certification: ("GDPR", "ISO-27001", "SOC-2"),
  owner: "Security Team"
))[
  System shall enforce role-based access control (RBAC) for all protected resources.
]

#req("REQ-AUTHZ-001", 
belongs_to: "F-AUTHZ", 
tags: (
    type: "functional",
    safety: "QM",
    security: "authorization"
  ))[
    The system shall implement role-based access control with at least three privilege levels: Admin, User, and Guest.
  ]

  #req("REQ-AUTHZ-002", belongs_to: "F-AUTHZ", tags: (
    type: "functional",
    security: "least-privilege"
  ))[
    The system shall enforce the principle of least privilege for all user accounts.
  ]

  #req("REQ-AUTHZ-003", belongs_to: "F-AUTHZ", tags: (
    type: "functional",
    security: "authorization"
  ))[
    The system shall log all authorization failures for security auditing.
  ]


#feature("RBAC Model", id: "AUTHZ-MODEL", concrete: false, parent: "F-AUTHZ", group: "XOR", tags: (
  variability: "alternative"
))[]

#feature("Simple RBAC", id: "F-RBAC-SIMPLE", concrete: true, parent: "AUTHZ-MODEL", tags: (
  complexity: "low",
  cost-impact: "+2 EUR"
))[
  Basic role-based access control with predefined roles.

]

#req("REQ-RBAC-S-001", belongs_to: "F-RBAC-SIMPLE", tags: (type: "functional"))[
    The system shall support three predefined roles: Admin, User, Guest.
  ]

#feature("Hierarchical RBAC", id: "F-RBAC-HIER", concrete: true, parent: "AUTHZ-MODEL", tags: (
  complexity: "medium",
  cost-impact: "+8 EUR"
))[
  Role hierarchy with inheritance of permissions.

]

#req("REQ-RBAC-H-001", belongs_to: "F-RBAC-HIER", tags: (type: "functional"))[
    The system shall support role inheritance where higher-level roles inherit permissions from lower-level roles.
  ]

  #req("REQ-RBAC-H-002", belongs_to: "F-RBAC-HIER", tags: (type: "functional"))[
    The system shall allow up to 5 levels of role hierarchy.
  ]

#feature("Attribute-Based Access Control", id: "F-ABAC", concrete: true, parent: "AUTHZ-MODEL", tags: (
  complexity: "high",
  cost-impact: "+25 EUR",
  user-experience: "enterprise"
))[
  Fine-grained access control based on user, resource, and environment attributes.
]

#req("REQ-ABAC-001", belongs_to: "F-ABAC", tags: (type: "functional"))[
    The system shall evaluate access policies based on user attributes (role, department, clearance level).
  ]

  #req("REQ-ABAC-002", belongs_to: "F-ABAC", tags: (type: "functional"))[
    The system shall evaluate access policies based on resource attributes (classification, owner, type).
  ]

  #req("REQ-ABAC-003", belongs_to: "F-ABAC", tags: (type: "functional"))[
    The system shall evaluate access policies based on environmental attributes (time, location, device type).
  ]

#feature("Permission Management", id: "F-PERM-MGMT", concrete: true, parent: "F-AUTHZ", tags: (
  priority: "P2"
))[
  Dynamic permission assignment and revocation.
]

#req("REQ-PERM-001", belongs_to: "F-PERM-MGMT", tags: (type: "functional"))[
    Administrators shall be able to assign permissions to roles at runtime.
  ]

  #req("REQ-PERM-002", belongs_to: "F-PERM-MGMT", tags: (type: "functional"))[
    Permission changes shall take effect within 60 seconds.
  ]

  #req("REQ-PERM-003", belongs_to: "F-PERM-MGMT", tags: (type: "functional"))[
    The system shall support permission delegation for temporary access grants.
  ]
