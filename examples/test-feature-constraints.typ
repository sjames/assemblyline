#import "../packages/preview/assemblyline/main/lib/lib.typ": *

// Feature model demonstrating constraint visualization

#feature("E-Commerce Platform", id: "ROOT", parent: none, concrete: true)[
  Root feature for an e-commerce platform.
]

#feature("Payment Processing", id: "F-PAYMENT", parent: "ROOT", concrete: false, group: "OR")[
  Payment processing capabilities - at least one method required.
]

#feature("Credit Card", id: "F-CREDIT-CARD", parent: "F-PAYMENT", concrete: true,
  tags: (requires: "F-PCI-COMPLIANCE"))[
  Credit card payment processing. Requires PCI compliance.
]

#feature("PayPal", id: "F-PAYPAL", parent: "F-PAYMENT", concrete: true)[
  PayPal integration for payments.
]

#feature("Cryptocurrency", id: "F-CRYPTO", parent: "F-PAYMENT", concrete: true,
  tags: (requires: "F-BLOCKCHAIN", excludes: "F-TRADITIONAL-BANKING"))[
  Cryptocurrency payment support. Requires blockchain integration and excludes traditional banking.
]

#feature("Security", id: "F-SECURITY", parent: "ROOT", concrete: false)[
  Security and compliance features.
]

#feature("PCI Compliance", id: "F-PCI-COMPLIANCE", parent: "F-SECURITY", concrete: true)[
  PCI DSS compliance for credit card processing.
]

#feature("Blockchain Integration", id: "F-BLOCKCHAIN", parent: "F-SECURITY", concrete: true,
  tags: (excludes: "F-CENTRALIZED-DB"))[
  Blockchain for cryptocurrency transactions. Excludes centralized database.
]

#feature("Data Storage", id: "F-STORAGE", parent: "ROOT", concrete: false, group: "XOR")[
  Data storage backend - exactly one must be selected.
]

#feature("Centralized Database", id: "F-CENTRALIZED-DB", parent: "F-STORAGE", concrete: true)[
  Traditional centralized SQL database.
]

#feature("Distributed Database", id: "F-DISTRIBUTED-DB", parent: "F-STORAGE", concrete: true,
  tags: (requires: ("F-CLOUD", "F-REPLICATION")))[
  Distributed database system. Requires cloud infrastructure and replication.
]

#feature("Cloud Infrastructure", id: "F-CLOUD", parent: "ROOT", concrete: true)[
  Cloud-based infrastructure and services.
]

#feature("Replication", id: "F-REPLICATION", parent: "F-CLOUD", concrete: true)[
  Data replication across multiple nodes.
]

#feature("Traditional Banking", id: "F-TRADITIONAL-BANKING", parent: "ROOT", concrete: true)[
  Traditional banking integration for wire transfers.
]

// Define configurations
#config("CFG-TRADITIONAL", title: "Traditional Platform", root_feature_id: "ROOT",
  selected: ("ROOT", "F-PAYMENT", "F-CREDIT-CARD", "F-PAYPAL",
             "F-SECURITY", "F-PCI-COMPLIANCE",
             "F-STORAGE", "F-CENTRALIZED-DB",
             "F-TRADITIONAL-BANKING")
)

#config("CFG-CRYPTO", title: "Crypto Platform", root_feature_id: "ROOT",
  selected: ("ROOT", "F-PAYMENT", "F-CRYPTO",
             "F-SECURITY", "F-BLOCKCHAIN",
             "F-STORAGE", "F-DISTRIBUTED-DB",
             "F-CLOUD", "F-REPLICATION")
)

= Feature Constraint Visualization

This example demonstrates how feature constraints (implies/excludes) are displayed in the feature tree.

== All Features (No Configuration)

Shows the structure with all constraint relationships visible:

#feature-tree(root: "ROOT")

#pagebreak()

== All Features Detailed View

Detailed view with descriptions and constraints:

#feature-tree-detailed(root: "ROOT", show-descriptions: true)

#pagebreak()

== Traditional Platform Configuration

Selected features and their constraints:

#set-active-config("CFG-TRADITIONAL")
#feature-tree-detailed(root: "ROOT", show-descriptions: true)

#pagebreak()

== Crypto Platform Configuration

Note how F-CRYPTO implies F-BLOCKCHAIN and excludes F-TRADITIONAL-BANKING:

#set-active-config("CFG-CRYPTO")
#feature-tree-detailed(root: "ROOT", show-descriptions: true)

#pagebreak()

== Constraint Summary

Key constraints in this model:
- *F-CREDIT-CARD* → implies F-PCI-COMPLIANCE
- *F-CRYPTO* → implies F-BLOCKCHAIN, excludes F-TRADITIONAL-BANKING
- *F-BLOCKCHAIN* → excludes F-CENTRALIZED-DB
- *F-DISTRIBUTED-DB* → implies F-CLOUD and F-REPLICATION

These constraints ensure:
1. Credit card processing always has PCI compliance
2. Crypto and traditional banking are mutually exclusive
3. Blockchain storage is incompatible with centralized databases
4. Distributed databases require cloud infrastructure
