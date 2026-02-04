// Test document for block-definition-of-block function
#import "packages/preview/assemblyline/main/lib/lib.typ": *

// Define a sample block
#block_definition(
  "BLK-TEST-001",
  title: "Test Authentication Service",
  properties: (
    (name: "maxRetries", type: "Integer", default: 3, unit: "attempts"),
    (name: "timeout", type: "Duration", default: 30, unit: "seconds")
  ),
  operations: (
    (name: "authenticate", params: "credentials: String", returns: "Token"),
    (name: "validate", params: "token: Token", returns: "Boolean")
  ),
  ports: (
    (name: "authAPI", direction: "in", protocol: "REST"),
    (name: "dbConnection", direction: "out", protocol: "SQL")
  ),
  tags: (stereotype: "service", criticality: "high")
)[
  This is a test authentication service that demonstrates the block-definition-of-block function.
  It provides user authentication and token validation capabilities.
]

// Define another block to test error handling
#block_definition(
  "BLK-TEST-002",
  title: "Test Database Service",
  properties: (
    (name: "connectionPool", type: "Integer", default: 10, unit: "connections"),
  ),
  tags: (stereotype: "infrastructure")
)[
  A simple database service for testing purposes.
]

#pagebreak()

= Test: Display Single Block Definition

== Test 1: Valid Block ID
Displaying block BLK-TEST-001:

#block-definition-of-block("BLK-TEST-001")

#pagebreak()

== Test 2: Another Valid Block ID
Displaying block BLK-TEST-002:

#block-definition-of-block("BLK-TEST-002")

#pagebreak()

== Test 3: All Blocks (For Comparison)
Here's how the section renderer shows all blocks:

#block-definition-section()
