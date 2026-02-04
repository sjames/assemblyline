#import "packages/preview/assemblyline/main/lib/lib.typ": *

// Setup requirement references to display properly
#show: setup-requirement-references

// Define a simple feature hierarchy
#feature("Root System", id: "ROOT", parent: none, concrete: false)

#feature("Authentication", id: "F-AUTH", parent: "ROOT", concrete: true,
  tags: (priority: "P1")
)[
  Provides user authentication capabilities.
]

#feature("Basic Auth", id: "F-AUTH-BASIC", parent: "F-AUTH", concrete: true)[
  Username and password authentication.
]

#feature("Multi-Factor Auth", id: "F-AUTH-MFA", parent: "F-AUTH", concrete: true)[
  Two-factor authentication support.
]

#feature("User Management", id: "F-USER", parent: "ROOT", concrete: true)[
  User account management features.
]

// Define requirements that belong to features
#req("REQ-AUTH-001", belongs_to: "F-AUTH", tags: (type: "functional"))[
  The system shall provide authentication mechanisms.
]

#req("REQ-AUTH-002", belongs_to: "F-AUTH", tags: (type: "security"))[
  Authentication credentials shall be encrypted at rest.
]

#req("REQ-AUTH-BASIC-001", belongs_to: "F-AUTH-BASIC", tags: (type: "functional"))[
  The system shall support username and password authentication.
]

#req("REQ-AUTH-MFA-001", belongs_to: "F-AUTH-MFA", tags: (type: "functional"))[
  The system shall support TOTP-based two-factor authentication.
]

#req("REQ-USER-001", belongs_to: "F-USER", tags: (type: "functional"))[
  The system shall allow administrators to create new user accounts.
]

#req("REQ-USER-002", belongs_to: "F-USER", tags: (type: "functional"))[
  The system shall allow administrators to deactivate user accounts.
]

// Define a configuration that selects some features
#config("CFG-BASIC",
  title: "Basic Configuration",
  root_feature_id: "ROOT",
  selected: ("F-AUTH", "F-AUTH-BASIC", "F-USER")
)

// Render the feature tree with requirements
// Note: We only render once to avoid duplicate labels.
// In a real document, you would typically only have one feature tree with requirements.

= Feature Tree with Requirements (Basic Configuration Selected)

#set-active-config("CFG-BASIC")
#feature-tree-with-requirements(root: "ROOT", config: "CFG-BASIC")

#pagebreak()

= Standard Feature Tree (For Comparison)

#feature-tree(root: "ROOT", config: "CFG-BASIC")

#pagebreak()

= Demonstration of Cross-Referencing

The new feature tree with requirements creates anchors for each requirement,
allowing you to reference them from anywhere in the document.

For example, you can reference requirements from the selected features:
- You can reference @REQ-AUTH-001 (from selected feature F-AUTH)
- Or reference @REQ-AUTH-BASIC-001 (from selected feature F-AUTH-BASIC)
- Or reference @REQ-USER-002 (from selected feature F-USER)

Note: REQ-AUTH-MFA-001 is NOT shown because F-AUTH-MFA is not selected in the CFG-BASIC configuration.

These references will automatically link to the requirement in the feature tree.

== Example Use Case with Requirement Links

This use case demonstrates authentication and satisfies the following requirements from selected features:
- @REQ-AUTH-001 (Authentication mechanisms)
- @REQ-AUTH-BASIC-001 (Username/password support)

The user management functionality addresses @REQ-USER-001 and @REQ-USER-002.
