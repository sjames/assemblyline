// features/audit-logging.typ
#import "../packages/preview/assemblyline/main/lib/lib.typ": *

#feature("Audit & Compliance Logging", id: "F-AUDIT", concrete: true, parent: "ROOT", tags: (
  priority: "P1",
  certification: ("SOC-2", "ISO-27001", "HIPAA"),
  owner: "Compliance Team"
))[
  Comprehensive audit trail for security and compliance.
]

#req("REQ-AUDIT-001", 
belongs_to: "F-AUDIT",
tags: (
    type: "functional",
    security: "audit-trail"
  ))[
    The system shall log all authentication attempts (successful and failed).
  ]

  #req("REQ-AUDIT-002", 
  belongs_to: "F-AUDIT",
  tags: (
    type: "functional",
    security: "audit-trail"
  ))[
    The system shall log all authorization decisions (grants and denials).
  ]

  #req("REQ-AUDIT-003", 
  belongs_to: "F-AUDIT",
  tags: (
    type: "functional",
    security: "audit-trail",
    source: "SOC-2 CC6.3"
  ))[
    Audit logs shall include: timestamp, user ID, action, resource, outcome, IP address.
  ]

  #req("REQ-AUDIT-004", 
  belongs_to: "F-AUDIT",
  tags: (
    type: "functional",
    security: "log-integrity"
  ))[
    Audit logs shall be immutable and cryptographically signed to prevent tampering.
  ]

#feature("Log Storage", id: "LOG-STORAGE", concrete: false, parent: "F-AUDIT", group: "XOR", tags: (
  variability: "alternative"
))[]

#feature("Local File Logging", id: "F-LOG-FILE", concrete: true, parent: "LOG-STORAGE", tags: (
  cost-impact: "+0 EUR",
  retention: "30 days"
))[
  Log to local filesystem with rotation.
]

#req("REQ-LOG-FILE-001", 
belongs_to: "F-LOG-FILE",
tags: (type: "functional"))[
    Logs shall be written to local files with daily rotation.
  ]

#req("REQ-LOG-FILE-002", 
  belongs_to: "F-LOG-FILE", 
  tags: (type: "functional"))[
  Log files older than 30 days shall be automatically archived and compressed.
]


#feature("Centralized Logging (ELK)", id: "F-LOG-ELK", concrete: true, parent: "LOG-STORAGE", tags: (
  cost-impact: "+30 EUR",
  retention: "365 days",
  search: "full-text"
))[
  Elasticsearch/Logstash/Kibana stack integration.
]

#req("REQ-LOG-ELK-001", 
  belongs_to: "F-LOG-ELK",
  tags: (type: "functional"))[
  Logs shall be shipped to Elasticsearch in real-time via Logstash.
]

#req("REQ-LOG-ELK-002", 
  belongs_to: "F-LOG-ELK",
  tags: (type: "functional"))[
  Logs shall be retained for 365 days with automatic deletion.
]

#req("REQ-LOG-ELK-003", 
  belongs_to: "F-LOG-ELK",
  tags: (type: "non-functional"))[
  Log queries shall return results within 2 seconds for date-range queries.
]

#feature("SIEM Integration", id: "F-LOG-SIEM", concrete: true, parent: "LOG-STORAGE", tags: (
  cost-impact: "+50 EUR",
  retention: "7 years",
  compliance: "enterprise"
))[
  Integration with Security Information and Event Management systems.
]

#req("REQ-LOG-SIEM-001", 
belongs_to: "F-LOG-SIEM",
tags: (type: "functional"))[
  Logs shall be forwarded to SIEM via syslog protocol.
]

#req("REQ-LOG-SIEM-002", 
  belongs_to: "F-LOG-SIEM",
  tags: (type: "functional"))[
  The system shall support CEF (Common Event Format) for SIEM compatibility.
]

#feature("Log Analysis & Alerting", id: "F-LOG-ALERT", concrete: true, parent: "F-AUDIT", tags: (
  priority: "P1"
))[
  Automated threat detection and alerting.
]

#req("REQ-ALERT-001", 
  belongs_to: "F-LOG-ALERT",
  tags: (type: "functional", security: "intrusion-detection"))[
  The system shall alert on 5 or more failed login attempts within 5 minutes.
]

#req("REQ-ALERT-002", 
  belongs_to: "F-LOG-ALERT",
  tags: (type: "functional", security: "anomaly-detection"))[
  The system shall alert on login attempts from new geographic locations.
]

#req("REQ-ALERT-003", 
  belongs_to: "F-LOG-ALERT",
  tags: (type: "functional"))[
  Security alerts shall be sent via email and SMS within 60 seconds.
]

#req("REQ-ALERT-004", 
  belongs_to: "F-LOG-ALERT",
  tags: (type: "functional"))[
  The system shall alert on privilege escalation attempts.
]

#feature("Compliance Reporting", id: "F-COMPLIANCE", concrete: true, parent: "F-AUDIT", tags: (
  priority: "P2",
  certification: ("SOC-2", "ISO-27001")
))[
  Automated compliance report generation.
]

#req("REQ-COMP-001", 
  belongs_to: "F-COMPLIANCE",
  tags: (type: "functional"))[
  The system shall generate monthly access reports showing all user activities.
]

#req("REQ-COMP-002", 
  belongs_to: "F-COMPLIANCE",
  tags: (type: "functional"))[
  The system shall provide audit trail exports in CSV and JSON formats.
]

#req("REQ-COMP-003", 
  belongs_to: "F-COMPLIANCE",
  tags: (type: "functional", source: "SOC-2"))[
  Compliance reports shall be automatically archived for 7 years.
]
