# AssemblyLine Modelling Language Project Instructions

## Project Overview
This is an AssemblyLine Modelling Language specification repository written in Typst. It demonstrates a complete product-line engineering specification with features, requirements, use cases, diagrams, and configurations. The language is implemented as a Typst library that provides domain-specific constructs for systems engineering and product-line engineering.

## Project Structure
```
├── main.typ                 # Main entry point - compile this for full PDF
├── features/
│   ├── root.typ
│   ├── authentication.typ   # Feature definitions and requirements
│   └── [other features]     # Authorization, user management, etc.
├── use-cases/
│   ├── login.typ           # Behavioral scenarios
│   └── authorization.typ
├── diagrams/
│   ├── login-sequence.typ     # Sequence diagrams with traceability
│   └── auth-service-ibd.typ   # Internal block diagrams
├── architecture.typ         # System architecture (block definitions)
├── configurations.typ       # Product configurations
├── lib/
│   ├── lib.typ             # Core language library (1200+ lines)
│   ├── json-export.typ     # JSON serialization for external tools
│   └── json-helpers.typ    # JSON utilities
└── assembly-cli/           # Command-line tool for validation (in development)
    ├── src/
    │   ├── main.rs         # CLI entry point
    │   ├── compile.rs      # Compilation pipeline
    │   ├── world.rs        # File system and caching
    │   ├── query.rs        # Element extraction (basis for validation)
    │   └── [16 other modules]
    └── Cargo.toml          # Rust project (fork of typst-cli)
```

## Key Language Constructs

### Core Element Types

#### #feature
- **Purpose**: Product-line feature modeling (mandatory/optional/XOR/OR variability)
- **Required**: `id: "UNIQUE"`
- **Structural Parameters**:
  - `parent: "ID"` → Establishes feature hierarchy
  - `concrete: true|false` → Only concrete features can be selected in configurations (default: true)
  - `group: "XOR"|"OR"` → Variability group type (only on parent features)
- **Tags**: Infinite extensibility via `tags: (key: value, ...)` for metadata
  - Examples: `priority`, `certification`, `owner`, `cost-impact`, `hardware-required`
- **Content Body**: Free-form description of the feature

**Example**:
```typst
#feature("Secure Authentication", id: "F-AUTH", concrete: true, parent: "ROOT",
  tags: (priority: "P1", certification: ("GDPR", "ISO-27001"))
)[
  Every device shall provide strong authentication.
]

// Top-level requirements link to features via belongs_to
#req("REQ-AUTH-001", belongs_to: "F-AUTH", tags: (type: "functional", safety: "QM"))[
  The system shall enforce multi-factor authentication.
]

// Derived requirements link to parent requirements via derives_from
#req("REQ-AUTH-001a", derives_from: "REQ-AUTH-001", tags: (type: "functional"))[
  The system shall support TOTP (RFC 6238) as second factor.
]
```

#### #req
- **Purpose**: Requirements specification with explicit feature or parent requirement relationships
- **Required**:
  - `id: "UNIQUE"`
  - **EITHER** `belongs_to: "FEATURE-ID"` (for top-level requirements linked to features)
  - **OR** `derives_from: "REQ-ID"` (for derived/decomposed requirements linked to parent requirements)
- **Parameters**:
  - `tags: (...)` → Metadata (type, safety level, security properties, source references)
- **Content Body**: The requirement text

**Example**:
```typst
// Top-level requirement - belongs to a feature
#req("REQ-AUTH-001", belongs_to: "F-AUTH", tags: (type: "functional", safety: "QM"))[
  The system shall enforce multi-factor authentication.
]

// Derived requirement - decomposes parent requirement
#req("REQ-AUTH-001a", derives_from: "REQ-AUTH-001", tags: (type: "functional"))[
  The system shall support TOTP (RFC 6238) as second factor.
]

// Another derived requirement from the same parent
#req("REQ-AUTH-001b", derives_from: "REQ-AUTH-001", tags: (type: "functional"))[
  The system shall support push-based approval via mobile app.
]
```

#### #use_case
- **Purpose**: Behavioral scenarios showing how actors achieve goals
- **Required**: `id: "UNIQUE"`
- **Parameters**:
  - `title: "..."` → Use case name
  - `tags: (...)` → Metadata (actor, goal, preconditions, etc.)
- **Traceability**: Use `#links(trace: ("REQ-1", "REQ-2"))` to link to requirements
- **Content Body**: Scenario description (steps, flows, variants)

#### #config
- **Purpose**: Product configuration definitions (feature selections)
- **Required**: `id: "UNIQUE"`
- **Parameters**:
  - `title: "..."` → Configuration name
  - `root_feature_id: "ROOT"` → Root of feature tree
  - `selected: ("F-1", "F-2", ...)` → Array of selected concrete feature IDs
  - `tags: (...)` → Configuration metadata (market, compliance, deployment)

#### #block_definition (SysML)
- **Purpose**: Full SysML block definition for system architecture
- **Required**: `id: "UNIQUE"`, `title: "..."`
- **SysML Features**:
  - `properties: ((name: "prop", type: "Integer", default: 0, unit: "ms"), ...)`
  - `operations: ((name: "start", params: "void", returns: "bool"), ...)`
  - `ports: ((name: "httpPort", direction: "in", protocol: "HTTP"), ...)`
  - `parts: ((name: "authService", type: "BLK-AUTH", multiplicity: "1"), ...)` → Composition
  - `connectors: ((from: "httpPort", to: "authService.authAPI", flow: "HTTPRequest"), ...)`
    - No dot = block's own port (delegation)
    - With dot = part.port (internal wiring)
  - `references: ("BLK-EXT1", ...)` → Associations to external blocks
  - `constraints: ("weight < 500g", "power < 10W")` → OCL-like constraints
- **Tags**: Additional metadata (stereotype, complexity, etc.)
- **Visual Generation**: `#generate-ibd("BLK-ID")` creates visual diagram

#### #internal_block_diagram (SysML)
- **Purpose**: Standalone internal block diagram (independent of block definition)
- **Required**: `id: "UNIQUE"`, `title: "..."`
- **Parameters**: Similar to block_definition (parts, ports, connectors, references)
- **Use Case**: Define focused architectural views at different abstraction levels
- **Visual Generation**: `#visualize-ibd("IBD-ID")` creates visual diagram

#### #sequence_diagram
- **Purpose**: Behavioral sequence diagrams
- **Required**: `id: "UNIQUE"`
- **Parameters**: `title: "..."`, `tags: (...)`
- **Traceability**:
  - `#links(satisfy: ("REQ-1", "REQ-2"))` → Shows diagram satisfies requirements
  - `#links(belongs_to: "UC-ID")` → Associates diagram with use case

#### #implementation
- **Purpose**: Implementation artifacts (code, modules, components)
- **Required**: `id: "UNIQUE"`
- **Parameters**: `title: "..."`, `tags: (...)`
- **Traceability**: Link to requirements/designs they implement

#### #test_case
- **Purpose**: Test case definitions
- **Required**: `id: "UNIQUE"`
- **Parameters**: `title: "..."`, `tags: (...)`
- **Traceability**: Link to requirements being verified

### Traceability Mechanism

#### #links
- **Purpose**: Establishes explicit traceability relationships
- **Usage**: Pass links as parameters to element constructors via `links: (type: ("target-id1", "target-id2"))`
- **Link Types**:
  - `belongs_to: "FEATURE-ID"` → Requirement belongs to feature (for top-level requirements)
  - `derives_from: "REQ-ID"` → Requirement decomposition/refinement (for derived requirements)
  - `child_of: "PARENT-ID"` → Hierarchical parent relationship (for features)
  - `trace: ("REQ-1", ...)` → Use case traces to requirements
  - `satisfy: ("REQ-1", ...)` → Design/diagram satisfies requirements
  - **Custom types**: Any key can be used for domain-specific relationships

**Note**: Every requirement must have **either** `belongs_to` (linking to a feature) **or** `derives_from` (linking to a parent requirement).

## Language Implementation Architecture

### State Management (lib.typ)
The language uses Typst's `state` system for global element storage:

- **`__registry`**: Global state storing all elements in dictionary form
  - Key: Element ID (string)
  - Value: Element record with fields: `type`, `id`, `title`, `tags`, `links`, `parent`, `concrete`, `group`, `body`
  - Configurations stored with key prefix `CONFIG:`

- **`__links-buffer`**: Temporary buffer for pending `#links` calls
  - Accumulates link definitions
  - Applied to most recently registered element via show rule
  - Enables `#links` to work anywhere (inside or after element definitions)

- **`__active-config`**: Currently selected configuration ID
  - Set via `#set-active-config("CFG-ID")`
  - Used by `#feature-tree()` to highlight selected features

### Element Registration Flow
1. User calls element function (e.g., `#feature(...)`, `#req(...)`)
2. Function calls `__element(type, id, ...)` which updates `__registry` state
3. If `#links(...)` is called, it adds to `__links-buffer`
4. Show rule processes buffer and merges links into most recent element
5. Buffer is cleared after each element

### Rendering System
Elements are stored during compilation and can be rendered at any point:

- **Section renderers**: `#use-case-section()`, `#block-definition-section()`, `#internal-block-diagram-section()`
  - Query registry for elements of specific type
  - Sort by ID
  - Call individual element renderers

- **Individual renderers**: `#render-use-case(uc)`, `#render-block(blk)`, `#render-ibd(ibd)`
  - Format element with styled boxes
  - Display properties, operations, ports, parts, connectors
  - Show traceability links

- **Visual diagram generators**: `#generate-ibd("BLK-ID")`, `#visualize-ibd("IBD-ID")`
  - Use Fletcher library for automatic layout
  - Convert structural data (parts, connectors) to visual diagrams
  - SysML-compliant notation (block frames, port symbols)

### JSON Export (json-export.typ)
For integration with external tools:

```bash
# Export to JSON
typst compile --input export-json=output.json main.typ
typst compile --input export-json=stdout main.typ
```

Exports complete registry with all elements, tags, and links in JSON format.

## Working with this Project

### Compilation
- **Full specification**: `typst compile main.typ` → Generates complete PDF
- **Individual files**: Each `.typ` file is self-contained and can be compiled separately
- **JSON export**: `typst compile --input export-json=stdout main.typ` → Exports element registry

### Traceability Network
- **Top-level Requirements → Features**: `belongs_to: "F-ID"` parameter in `#req`
- **Derived Requirements → Parent Requirements**: `derives_from: "REQ-PARENT"` parameter in `#req`
  - **Rule**: Every requirement must have **either** `belongs_to` **or** `derives_from` (not both, not neither)
- **Requirements ← Use Cases**: `links: (trace: ("REQ-1", "REQ-2"))` in use case
- **Requirements ← Diagrams**: `links: (satisfy: ("REQ-1", "REQ-2"))` in diagram
- **Diagrams → Use Cases**: `links: (belongs_to: "UC-ID")` in diagram
- **Blocks → Blocks**: `parts`, `references`, `connectors` in `#block_definition`

### Link Validation

The AssemblyLine language provides **automatic link validation** to ensure all link targets exist in the specification. This catches errors at compile-time and prevents broken traceability.

**How it works**:
- The `#validate-links()` function validates all links after all elements are registered
- Called automatically in main.typ before generating the validation report
- Checks that every link target element exists in the registry
- Reports clear error messages with source element, target element, and link type

**Validation timing**: Document-end (after all elements are registered)
- ✅ **Allows forward references**: Elements can reference others defined later in the document
- ✅ **No ordering constraints**: Files can be included in any order
- ✅ **Clear error messages**: Shows exactly which link is broken and which element is missing

**Error message format**:
```
Link validation failed with 1 error(s):
Link from 'REQ-AUTH-001' to 'UC-INVALID' (type: 'trace') references non-existent element 'UC-INVALID'
```

**Usage**:
The validation is automatic when compiling main.typ. No manual function calls needed for normal use.

To add validation to custom documents:
```typst
#import "lib/lib.typ": *

// ... include your specification files ...

// Validate all links before generating reports
#validate-links()
```

**Complementary validation**: This Typst-native validation provides basic existence checks. The Rust WASM plugin (in main.typ) provides additional validation for advanced traceability rules (RULE 1-7).

### Traceability Rules

This section documents the mandatory traceability relationships and validation rules for the AssemblyLine specification.

 RULE 1: All requirements shall either "belong_to" a feature or be "derived_from" a requirement. A requirement without 
         one of these links is considered an error. Having both is also considered an error.
 RULE 2: Only one feature shall have an empty parent - and that is considered the root feature.
 RULE 3: All other features shall have a valid parent feature
 RULE 4: A use-case shall have a "traces" link to one or more requirements. This allows us to build a coverage of
         use-cases to requirements.
 RULE 5: A requrement shall be called allocated if there is a link from a block to the requirement. If "check-requirement-allocation" 
         validation is enabled, then all requirement shall have a single validation link. It is considered an error if there are 
         more than one incoming allocated_to link from a block to a requirement.
 RULE 6: If "check-requirement-allocation" is enabled the following rules apply:
           6.1 A requirement shall have either an incoming allocated link or, one or more incoming "derived_from" link to other requirements.
           6.2 A requirement shall not have both "derived_from" links and "allocated"
 RULE 7: If "check-requirement-satifaction" is enabled the following rules apply:
           6.1 Unless a requirement has an incoming "derived_from" link, it MUST have one or more incoming "satisfies" link that comes from 
               a block or a sequence diagram or an implementation_spec.

#### Structural Rules
<!-- Add structural traceability rules here -->

### Configuration Management
- **Define configurations**: `#config("CFG-EU", selected: ("F-AUTH", "F-PUSH", ...))`
- **Activate configuration**: `#set-active-config("CFG-EU")`
- **Visualize**: `#feature-tree(root: "ROOT", config: "CFG-EU")` shows selected features in green
- **Validation**: Feature selection must respect XOR/OR constraints

### Queries and Reports
- **`#feature-tree(root: "ROOT", config: "CFG-EU")`** - Visualize feature hierarchy with configuration
  - Shows mandatory/optional/XOR/OR structure
  - Highlights selected features
  - Displays concrete vs. abstract features

- **`#use-case-section(title: "...")`** - Render all use cases with traceability
- **`#block-definition-section(title: "...")`** - Render all SysML blocks
- **`#internal-block-diagram-section(title: "...")`** - Render all IBDs
- **`#coverage-table(...)`** - Generate traceability matrices (TODO: implement)

### Context-Aware Queries (via Typst)
Access registry programmatically for custom reports:

```typst
#context {
  let registry = __registry.get()
  let reqs = registry.pairs()
    .filter(p => p.last().type == "req")
    .map(p => p.last())
  // Process requirements...
}
```

## Conventions
- Feature IDs: `F-XXX` format
- Requirement IDs: `REQ-XXX-###` format (with optional letter suffixes for refinements)
- Use Case IDs: `UC-XXX` format
- Diagram IDs: `SD-XXX`, `BD-XXX`, etc.
- Configuration IDs: `CFG-XXX` format

## When Modifying
- Always maintain traceability links when adding/changing elements
- **Requirements must specify either**:
  - `belongs_to: "FEATURE-ID"` for top-level requirements linked to features, **OR**
  - `derives_from: "REQ-ID"` for derived/decomposed requirements linked to parent requirements
- Use tags extensively for metadata (priority, owner, certification, cost, etc.)
- Keep files focused and organized by concern (features, use cases, diagrams, etc.)
- Ensure all IDs are unique across the entire specification



