# AssemblyLine Modelling Language

EXPERIMENTAL

A text-based modelling language for systems engineering and product-line engineering, implemented as a Typst library.

## Overview

AssemblyLine provides domain-specific constructs for defining:

- **Features** - Product-line feature modelling with variability (mandatory/optional/XOR/OR)
- **Requirements** - Traceable requirements with explicit feature or parent requirement relationships
- **Use Cases** - Behavioural scenarios with actor goals and requirement traceability
- **Architecture** - SysML-compliant block definitions with ports, parts, and connectors
- **Configurations** - Product variant definitions with feature selections
- **Traceability** - Built-in link validation and coverage reporting

## Quick Start

```bash
# Compile the full specification to PDF
typst compile main.typ

# Export to JSON for external tools
typst compile --input export-json=stdout main.typ
```

## Project Structure

```
├── main.typ                 # Main entry point - compile this for full PDF
├── lib/
│   ├── lib.typ              # Core language library
│   ├── json-export.typ      # JSON serialization
│   └── json-helpers.typ     # JSON utilities
├── features/
│   ├── root.typ             # Root feature definition
│   └── *.typ                # Feature definitions and requirements
├── use-cases/
│   └── *.typ                # Behavioural scenarios
├── diagrams/
│   └── *.typ                # Sequence diagrams, IBDs
├── configurations.typ       # Product configurations
└── paper/
    └── assemblyline-user-guide.md  # Comprehensive user guide
```

## Example

```typst
#import "lib/lib.typ": *

// Define a feature with requirements
#feature("Secure Authentication", id: "F-AUTH", concrete: true, parent: "ROOT",
  tags: (priority: "P1", certification: ("GDPR", "ISO-27001"))
)[
  Every device shall provide strong authentication.
]

#req("REQ-AUTH-001", belongs_to: "F-AUTH", tags: (type: "functional"))[
  The system shall enforce multi-factor authentication.
]

#req("REQ-AUTH-001a", derives_from: "REQ-AUTH-001", tags: (type: "functional"))[
  The system shall support TOTP (RFC 6238) as second factor.
]

// Define a use case with traceability
#use_case("Successful Remote Login", id: "UC-LOGIN",
  links: (trace: ("REQ-AUTH-001", "REQ-AUTH-001a")),
  tags: (actor: "Homeowner")
)[
  The homeowner opens the mobile app and logs in using MFA.
]
```

## Key Concepts

### Traceability Rules

1. **Requirements** must have either `belongs_to` (linking to a feature) or `derives_from` (linking to a parent requirement)
2. **Features** form a tree with exactly one root (empty parent)
3. **Use cases** trace to requirements via `links: (trace: (...))`
4. **Diagrams** satisfy requirements via `links: (satisfy: (...))`

### Link Validation

All links are automatically validated at compile time. Missing targets produce clear error messages:

```
Link from 'REQ-AUTH-001' to 'UC-INVALID' (type: 'trace') references non-existent element
```

## Documentation

See [paper/assemblyline-user-guide.md](paper/assemblyline-user-guide.md) for the comprehensive user guide.

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
