// features/user-management.typ
#import "../lib/lib.typ": *

#feature("User Management", id: "F-USER-MGMT", concrete: true, parent: "ROOT", tags: (
  priority: "P1",
  owner: "Platform Team"
))[
  Comprehensive user lifecycle management capabilities.
]

#req("REQ-USER-001", belongs_to: "F-USER-MGMT", tags: (
    type: "functional",
    source: "GDPR Art. 15"
  ))[
    The system shall support user registration, profile management, and account deletion.
  ]

  #req("REQ-USER-002", belongs_to: "F-USER-MGMT", tags: (
    type: "functional",
    security: "data-protection"
  ))[
    User passwords shall be hashed using bcrypt with a minimum cost factor of 12.
  ]

#feature("User Registration", id: "F-USER-REG", concrete: true, parent: "F-USER-MGMT", tags: (
  priority: "P1"
))[
  Self-service user registration with validation.
]

#req("REQ-USER-REG-001", belongs_to: "F-USER-REG", tags: (type: "functional"))[
   Users shall be able to self-register using email address and password.
  ]

  #req("REQ-USER-REG-002", belongs_to: "F-USER-REG", tags: (type: "functional", security: "input-validation"))[
    Email addresses shall be validated for proper format and verified via confirmation link.
  ]

  #req("REQ-USER-REG-003", belongs_to: "F-USER-REG", tags: (type: "functional", security: "password-policy"))[
    Passwords shall meet minimum complexity requirements: 12 characters, mixed case, numbers, special characters.
  ]

  #req("REQ-USER-REG-004", belongs_to: "F-USER-REG", tags: (type: "functional"))[
    Registration confirmation emails shall be sent within 30 seconds of registration.
  ]


#feature("Profile Management", id: "F-PROFILE", concrete: true, parent: "F-USER-MGMT", tags: (
  priority: "P2"
))[
  User profile viewing and editing capabilities.
]

#req("REQ-PROFILE-001", belongs_to: "F-PROFILE", tags: (type: "functional"))[
    Users shall be able to view and edit their profile information (name, email, phone, avatar).
  ]

  #req("REQ-PROFILE-002", belongs_to: "F-PROFILE", tags: (type: "functional", source: "GDPR Art. 20"))[
    Users shall be able to export their profile data in JSON format.
  ]

  #req("REQ-PROFILE-003", belongs_to: "F-PROFILE", tags: (type: "functional"))[
    Profile changes shall require re-authentication for sensitive fields (email, password).
  ]

#feature("Account Deletion", id: "F-ACCOUNT-DEL", concrete: true, parent: "F-USER-MGMT", tags: (
  priority: "P1",
  certification: ("GDPR",)
))[
  Right to erasure implementation.
]

#req("REQ-DEL-001", belongs_to: "F-ACCOUNT-DEL", tags: (
    type: "functional",
    source: "GDPR Art. 17"
  ))[
    Users shall be able to request permanent deletion of their account and all associated data.
  ]

  #req("REQ-DEL-002", belongs_to: "F-ACCOUNT-DEL", tags: (type: "functional"))[
    Account deletion requests shall be processed within 30 days.
  ]

  #req("REQ-DEL-003", belongs_to: "F-ACCOUNT-DEL", tags: (type: "functional"))[
    The system shall retain audit logs of deleted accounts for 90 days for compliance purposes.
  ]

#feature("Password Recovery", id: "F-PWD-RECOVERY", concrete: true, parent: "F-USER-MGMT", tags: (
  priority: "P1"
))[
  Secure password reset mechanism.
]


#req("REQ-PWD-REC-001", belongs_to: "F-PWD-RECOVERY", tags: (type: "functional", security: "authentication"))[
   Users shall be able to reset forgotten passwords via email verification.
  ]

  #req("REQ-PWD-REC-002", belongs_to: "F-PWD-RECOVERY", tags: (type: "functional", security: "token-expiry"))[
    Password reset tokens shall expire after 1 hour.
  ]

  #req("REQ-PWD-REC-003", belongs_to: "F-PWD-RECOVERY", tags: (type: "functional", security: "rate-limiting"))[
    Password reset requests shall be rate-limited to 3 requests per hour per account.
  ]
