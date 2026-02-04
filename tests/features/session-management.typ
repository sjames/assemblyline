// features/session-management.typ
#import "../packages/preview/assemblyline/main/lib/lib.typ": *

#feature("Session Management", id: "F-SESSION", concrete: true, parent: "ROOT", tags: (
  priority: "P1",
  certification: ("OWASP-ASVS", "ISO-27001"),
  owner: "Security Team"
))[
  Secure session lifecycle management.
]


#req("REQ-SESSION-001", belongs_to: "F-SESSION", tags: (
    type: "functional",
    security: "session-management"
  ))[
    The system shall create a unique session identifier upon successful authentication.
  ]

  #req("REQ-SESSION-002", belongs_to: "F-SESSION", tags: (
    type: "functional",
    security: "session-fixation"
  ))[
    Session identifiers shall be regenerated after privilege level changes.
  ]

  #req("REQ-SESSION-003", belongs_to: "F-SESSION", tags: (
    type: "performance",
    security: "session-timeout"
  ))[
    Inactive sessions shall be automatically terminated after 15 minutes of inactivity.
  ]

#feature("Session Storage", id: "SESSION-STORE", concrete: false, parent: "F-SESSION", group: "XOR", tags: (
  variability: "alternative"
))[]

#feature("In-Memory Sessions", id: "F-SESSION-MEM", concrete: true, parent: "SESSION-STORE", tags: (
  cost-impact: "+0 EUR",
  scalability: "low"
))[
  Server-side in-memory session storage.
]

#req("REQ-SESS-MEM-001", belongs_to: "F-SESSION-MEM", tags: (type: "functional"))[
    Sessions shall be stored in server memory with automatic garbage collection.
  ]

  #req("REQ-SESS-MEM-002", belongs_to: "F-SESSION-MEM", tags: (type: "non-functional"))[
    Session lookup shall complete in less than 1ms.
  ]

#feature("Redis Sessions", id: "F-SESSION-REDIS", concrete: true, parent: "SESSION-STORE", tags: (
  cost-impact: "+12 EUR",
  scalability: "high"
))[
  Distributed session storage using Redis.
]

#req("REQ-SESS-REDIS-001", belongs_to: "F-SESSION-REDIS", tags: (type: "functional"))[
    Sessions shall be stored in Redis with automatic expiration.
  ]

  #req("REQ-SESS-REDIS-002", belongs_to: "F-SESSION-REDIS", tags: (type: "non-functional"))[
    The system shall support session sharing across multiple application instances.
  ]

  #req("REQ-SESS-REDIS-003", belongs_to: "F-SESSION-REDIS", tags: (type: "non-functional"))[
    Session operations shall complete in less than 5ms at p99.
  ]


#feature("Database Sessions", id: "F-SESSION-DB", concrete: true, parent: "SESSION-STORE", tags: (
  cost-impact: "+5 EUR",
  scalability: "medium"
))[
  Persistent session storage in database.
]

#req("REQ-SESS-DB-001", belongs_to: "F-SESSION-DB", tags: (type: "functional"))[
    Sessions shall be persisted to the primary database.
  ]

  #req("REQ-SESS-DB-002", belongs_to: "F-SESSION-DB", tags: (type: "functional"))[
    Session data shall survive application restarts.
  ]


#feature("Concurrent Session Control", id: "F-SESSION-CONCURRENT", concrete: true, parent: "F-SESSION", tags: (
  priority: "P2"
))[
  Management of multiple simultaneous sessions per user.
]

#req("REQ-CONC-001", belongs_to: "F-SESSION-CONCURRENT", tags: (type: "functional"))[
    The system shall allow users to view all active sessions.
  ]

  #req("REQ-CONC-002", belongs_to: "F-SESSION-CONCURRENT", tags: (type: "functional"))[
    Users shall be able to terminate any of their active sessions remotely.
  ]

  #req("REQ-CONC-003", belongs_to: "F-SESSION-CONCURRENT", tags: (type: "functional"))[
    The system shall limit users to a maximum of 5 concurrent sessions.
  ]

#feature("Session Security", id: "F-SESSION-SEC", concrete: true, parent: "F-SESSION", tags: (
  priority: "P1",
  certification: ("OWASP-ASVS",)
))[
  Enhanced session security features.
]

#req("REQ-SESS-SEC-001", belongs_to: "F-SESSION-SEC", tags: (type: "functional", security: "transport"))[
  Session cookies shall be marked as Secure and HttpOnly.
]

#req("REQ-SESS-SEC-002", belongs_to: "F-SESSION-SEC", tags: (type: "functional", security: "csrf"))[
  The system shall implement CSRF protection for all state-changing operations.
]

#req("REQ-SESS-SEC-003", belongs_to: "F-SESSION-SEC", tags: (type: "functional", security: "binding"))[
  Sessions shall be bound to the originating IP address to prevent session hijacking.
]
