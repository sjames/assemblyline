// features/api-security.typ
#import "../lib/lib.typ": *

#feature("API Security", id: "F-API-SEC", concrete: true, parent: "ROOT", tags: (
  priority: "P1",
  certification: ("OWASP-API-Top-10",),
  owner: "API Team"
))[
  Comprehensive API security controls and protection mechanisms.
]

#req("REQ-API-001", 
  belongs_to: "F-API-SEC",
  tags: (
    type: "functional",
    security: "api-authentication"
  ))[
  All API endpoints shall require authentication except public documentation endpoints.
]

#req("REQ-API-002", 
  belongs_to: "F-API-SEC",
  tags: (
  type: "functional",
  security: "rate-limiting"
))[
  API requests shall be rate-limited to prevent abuse and DoS attacks.
]

#req("REQ-API-003", 
  belongs_to: "F-API-SEC",
  tags: (
  type: "functional",
  security: "input-validation"
))[
  All API inputs shall be validated against defined schemas before processing.
]

#feature("API Authentication", id: "API-AUTH", concrete: false, parent: "F-API-SEC", group: "OR", tags: (
  variability: "multiple-selection"
))[
  Multiple API authentication methods can be supported simultaneously.
]

#feature("API Key Authentication", id: "F-API-KEY", concrete: true, parent: "API-AUTH", tags: (
  complexity: "low",
  cost-impact: "+2 EUR"
))[
  Simple API key-based authentication.
]

#req("REQ-API-KEY-001", 
  belongs_to: "F-API-KEY",
  tags: (type: "functional"))[
  API keys shall be at least 32 characters long and cryptographically random.
]

#req("REQ-API-KEY-002", 
  belongs_to: "F-API-KEY",
  tags: (type: "functional"))[
  API keys shall be transmitted via HTTP Authorization header, not query parameters.
]

#req("REQ-API-KEY-003", 
  belongs_to: "F-API-KEY",
  tags: (type: "functional"))[
  Users shall be able to generate, revoke, and rotate API keys.
]

#req("REQ-API-KEY-004", 
  belongs_to: "F-API-KEY",
  tags: (type: "functional"))[
  API keys shall expire after 365 days of inactivity.
]


#feature("OAuth 2.0", id: "F-OAUTH2", concrete: true, parent: "API-AUTH", tags: (
  complexity: "medium",
  cost-impact: "+20 EUR",
  standards: ("RFC 6749",)
))[
  OAuth 2.0 authorization framework.
]

#req("REQ-OAUTH-001", 
  belongs_to: "F-OAUTH2",
  tags: (type: "functional"))[
  The system shall support OAuth 2.0 authorization code flow with PKCE.
]

#req("REQ-OAUTH-002", 
  belongs_to: "F-OAUTH2",
  tags: (type: "functional"))[
  The system shall support client credentials flow for server-to-server communication.
]

#req("REQ-OAUTH-003", 
  belongs_to: "F-OAUTH2",
  tags: (type: "functional"))[
  Access tokens shall expire after 1 hour.
]

#req("REQ-OAUTH-004", 
  belongs_to: "F-OAUTH2",
  tags: (type: "functional"))[
  Refresh tokens shall be rotated on each use.
]


#feature("JWT Tokens", id: "F-JWT", concrete: true, parent: "API-AUTH", tags: (
  complexity: "medium",
  cost-impact: "+10 EUR",
  standards: ("RFC 7519",)
))[
  JSON Web Token authentication.
]

#req("REQ-JWT-001", 
  belongs_to: "F-JWT",
  tags: (type: "functional"))[
  JWTs shall be signed using RS256 (RSA signature with SHA-256).
]

#req("REQ-JWT-002", 
  belongs_to: "F-JWT",
  tags: (type: "functional"))[
  JWTs shall include expiration (exp), issued-at (iat), and audience (aud) claims.
]

#req("REQ-JWT-003", 
  belongs_to: "F-JWT",
  tags: (type: "functional"))[
  The system shall maintain a token blacklist for revoked JWTs.
]


#feature("Mutual TLS", id: "F-MTLS", concrete: true, parent: "API-AUTH", tags: (
  complexity: "high",
  cost-impact: "+35 EUR",
  security-level: "maximum"
))[
  Client certificate authentication.
]

#req("REQ-MTLS-001", 
  belongs_to: "F-MTLS",
  tags: (type: "functional"))[
  The system shall require valid client certificates for API access.
]

#req("REQ-MTLS-002", 
  belongs_to: "F-MTLS",
  tags: (type: "functional"))[
  Client certificates shall be validated against a trusted certificate authority.
]

#req("REQ-MTLS-003", 
  belongs_to: "F-MTLS",
  tags: (type: "functional"))[
  Certificate revocation shall be checked via CRL or OCSP.
]

#feature("Rate Limiting", id: "F-RATE-LIMIT", concrete: true, parent: "F-API-SEC", tags: (
  priority: "P1"
))[
  Intelligent request throttling.
]

  #req("REQ-RATE-001", 
  belongs_to: "F-RATE-LIMIT",
  tags: (type: "functional"))[
    The system shall limit unauthenticated requests to 10 per minute per IP address.
  ]

  #req("REQ-RATE-002", 
  belongs_to: "F-RATE-LIMIT",
  tags: (type: "functional"))[
    The system shall limit authenticated requests to 1000 per hour per user.
  ]

  #req("REQ-RATE-003", 
  belongs_to: "F-RATE-LIMIT",
  tags: (type: "functional"))[
    Rate limit headers (X-RateLimit-Limit, X-RateLimit-Remaining) shall be included in responses.
  ]

  #req("REQ-RATE-004", 
  belongs_to: "F-RATE-LIMIT",
  tags: (type: "functional"))[
    Premium tier users shall have 10x higher rate limits.
  ]

#feature("API Gateway", id: "F-API-GATEWAY", concrete: true, parent: "F-API-SEC", tags: (
  priority: "P2",
  cost-impact: "+40 EUR"
))[
  Centralized API management and security.
]

#req("REQ-GATEWAY-001", 
  belongs_to: "F-API-GATEWAY",
  tags: (type: "functional"))[
  All API traffic shall route through a centralized API gateway.
]

#req("REQ-GATEWAY-002", 
  belongs_to: "F-API-GATEWAY",
  tags: (type: "functional"))[
  The gateway shall provide request/response transformation capabilities.
]

#req("REQ-GATEWAY-003", 
  belongs_to: "F-API-GATEWAY",
  tags: (type: "functional"))[
  The gateway shall implement circuit breaker pattern for backend failures.
]

#req("REQ-GATEWAY-004", 
  belongs_to: "F-API-GATEWAY",
  tags: (type: "functional"))[
  The gateway shall cache GET responses for 60 seconds by default.
]

#feature("API Versioning", id: "F-API-VERSION", concrete: true, parent: "F-API-SEC", tags: (
  priority: "P2"
))[
  Backward-compatible API evolution.
]

#req("REQ-VERSION-001", 
  belongs_to: "F-API-VERSION",
  tags: (type: "functional"))[
  The system shall support multiple API versions simultaneously (v1, v2, v3).
]

#req("REQ-VERSION-002", 
  belongs_to: "F-API-VERSION",
  tags: (type: "functional"))[
  API version shall be specified in the URL path (e.g., /api/v2/users).
]

#req("REQ-VERSION-003", 
  belongs_to: "F-API-VERSION",
  tags: (type: "functional"))[
  Deprecated API versions shall be supported for at least 12 months after deprecation notice.
]

#req("REQ-VERSION-004", 
  belongs_to: "F-API-VERSION",
  tags: (type: "functional"))[
  The system shall send deprecation warnings in response headers for deprecated versions.
]

#feature("API Documentation", id: "F-API-DOCS", concrete: true, parent: "F-API-SEC", tags: (
  priority: "P2"
))[
  Interactive API documentation and testing.
]);

  #req("REQ-DOCS-001", 
    belongs_to: "F-API-DOCS",
    tags: (type: "functional"))[
    The system shall provide OpenAPI 3.0 specification for all APIs.
  ]

  #req("REQ-DOCS-002", 
    belongs_to: "F-API-DOCS",
    tags: (type: "functional"))[
    Interactive API documentation shall be available via Swagger UI.
  ]

  #req("REQ-DOCS-003", 
    belongs_to: "F-API-DOCS",
    tags: (type: "functional"))[
    API documentation shall include authentication examples and sample requests.
  ]
