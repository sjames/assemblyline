// features/data-protection.typ
#import "../packages/preview/assemblyline/main/lib/lib.typ": *

#feature("Data Protection & Encryption", id: "F-DATA-PROTECT", concrete: true, parent: "ROOT", tags: (
  priority: "P1",
  certification: ("GDPR", "HIPAA", "PCI-DSS"),
  owner: "Security Team"
))[
  Comprehensive data protection through encryption and secure storage.
]

#req("REQ-DATA-001", 
belongs_to: "F-DATA-PROTECT",
tags: (
  type: "functional",
  security: "encryption",
  source: "GDPR Art. 32"
))[
  All personally identifiable information (PII) shall be encrypted at rest using AES-256.
]

#req("REQ-DATA-002", 
belongs_to: "F-DATA-PROTECT",
tags: (
  type: "functional",
  security: "encryption"
))[
  All data transmissions shall use TLS 1.3 or higher.
]

#req("REQ-DATA-003", 
  belongs_to: "F-DATA-PROTECT",
  tags: (
    type: "functional",
    security: "key-management"
))[
  Encryption keys shall be rotated every 90 days.
]

#feature("Encryption at Rest", id: "F-ENCRYPT-REST", concrete: true, parent: "F-DATA-PROTECT", tags: (
  priority: "P1"
))[
  Database and file system encryption.
]

#req("REQ-ENC-REST-001", 
  belongs_to: "F-ENCRYPT-REST",
  tags: (type: "functional"))[
  Database fields containing PII shall be encrypted using AES-256-GCM.
]

#req("REQ-ENC-REST-002", 
  belongs_to: "F-ENCRYPT-REST",
  tags: (type: "functional"))[
  File uploads shall be encrypted before storage.
]

#req("REQ-ENC-REST-003", 
  belongs_to: "F-ENCRYPT-REST",
  tags: (type: "functional"))[
  Encryption keys shall be stored in a dedicated Hardware Security Module (HSM) or key vault.
]

#feature("Encryption in Transit", id: "F-ENCRYPT-TRANSIT", concrete: true, parent: "F-DATA-PROTECT", tags: (
  priority: "P1"
))[
  Secure communication channels.
]

#req("REQ-ENC-TRANSIT-001", 
  belongs_to: "F-ENCRYPT-TRANSIT",
  tags: (type: "functional"))[
  All HTTP traffic shall be redirected to HTTPS.
]

#req("REQ-ENC-TRANSIT-002", 
  belongs_to: "F-ENCRYPT-TRANSIT",
  tags: (type: "functional"))[
  TLS certificates shall be renewed automatically 30 days before expiration.
]

#req("REQ-ENC-TRANSIT-003", 
  belongs_to: "F-ENCRYPT-TRANSIT",
  tags: (type: "functional"))[
  The system shall enforce perfect forward secrecy (PFS) in TLS connections.
]

#feature("Key Management", id: "KEY-MGMT", concrete: false, parent: "F-DATA-PROTECT", group: "XOR", tags: (
  variability: "alternative"
))[]

#feature("Software Key Management", id: "F-KEY-SOFTWARE", concrete: true, parent: "KEY-MGMT", tags: (
  cost-impact: "+0 EUR",
  security-level: "standard"
))[
  Application-level key management.
]

#req("REQ-KEY-SW-001", 
  belongs_to: "F-KEY-SOFTWARE",
  tags: (type: "functional"))[
  Keys shall be stored encrypted in application configuration.
]

#req("REQ-KEY-SW-002", 
  belongs_to: "F-KEY-SOFTWARE",
  tags: (type: "functional"))[
  Master key shall be derived from secure random number generator.
]

#feature("Cloud KMS Integration", id: "F-KEY-CLOUD", concrete: true, parent: "KEY-MGMT", tags: (
  cost-impact: "+15 EUR",
  security-level: "high"
))[
  Integration with cloud provider key management services (AWS KMS, Azure Key Vault).
]

#req("REQ-KEY-CLOUD-001", 
  belongs_to: "F-KEY-CLOUD",
  tags: (type: "functional"))[
    The system shall integrate with cloud provider KMS for key storage and operations.
  ]

#req("REQ-KEY-CLOUD-002", 
  belongs_to: "F-KEY-CLOUD",
  tags: (type: "functional"))[
    Keys shall never be exported from the cloud KMS.
  ]

#feature("Hardware Security Module", id: "F-KEY-HSM", concrete: true, parent: "KEY-MGMT", tags: (
  cost-impact: "+150 EUR",
  security-level: "maximum",
  certification: ("FIPS-140-2 Level 3",)
))[
  FIPS 140-2 certified hardware security module.
]

#req("REQ-KEY-HSM-001", 
belongs_to: "F-KEY-HSM",
tags: (type: "functional"))[
  All cryptographic operations shall be performed within FIPS 140-2 Level 3 certified HSM.
]

#req("REQ-KEY-HSM-002", 
belongs_to: "F-KEY-HSM",
tags: (type: "functional"))[
  HSM shall provide tamper detection and key destruction on physical attack.
]

#feature("Data Masking", id: "F-DATA-MASK", concrete: true, parent: "F-DATA-PROTECT", tags: (
  priority: "P2"
))[
  Sensitive data masking for non-production environments.
]

  #req("REQ-MASK-001", 
  belongs_to: "F-DATA-MASK",
  tags: (type: "functional"))[
    PII shall be automatically masked in development and staging environments.
  ]

  #req("REQ-MASK-002", 
  belongs_to: "F-DATA-MASK",
  tags: (type: "functional"))[
    Data masking shall preserve data format and referential integrity.
  ]

  #req("REQ-MASK-003", 
  belongs_to: "F-DATA-MASK",
  tags: (type: "functional"))[
    Credit card numbers shall be masked to show only last 4 digits.
  ]


#feature("Data Loss Prevention", id: "F-DLP", concrete: true, parent: "F-DATA-PROTECT", tags: (
  priority: "P2",
  certification: ("PCI-DSS",)
))[
  Prevention of unauthorized data exfiltration.
]

#req("REQ-DLP-001", 
  belongs_to: "F-DLP",
  tags: (type: "functional"))[
  The system shall detect and block attempts to export sensitive data in bulk.
]

#req("REQ-DLP-002", 
  belongs_to: "F-DLP",
  tags: (type: "functional"))[
  Data export operations exceeding 1000 records shall require manager approval.
]

#req("REQ-DLP-003", 
  belongs_to: "F-DLP",
  tags: (type: "functional"))[
  The system shall watermark all exported sensitive documents with user ID and timestamp.
]
