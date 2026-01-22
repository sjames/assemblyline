# AssemblyLine Modeling Language: User Guide

## Introduction

### What is AssemblyLine?

AssemblyLine is a **text-based modeling language** for systems engineering that helps you define, organize, and track complex product families. Think of it as a unified way to express:

- **What** your product can do (features)
- **What** it must do (requirements)
- **How** it behaves (use cases)
- **How** it's built (architecture)
- **Which** variants you offer (configurations)

All in plain text files that you can version control, review, and collaborate on—just like code.

### Why AssemblyLine?

Modern products come in families, not single versions:
- A security platform might have **Enterprise**, **SMB**, and **Consumer** editions
- An automotive system might have **Base**, **Sport**, and **Luxury** variants
- A medical device might have **US**, **EU**, and **Asia** configurations

Each variant shares common components but differs in specific features. Managing this complexity traditionally requires:

```mermaid
graph LR
    A[Requirements Tool<br/>DOORS] -.broken links.-> B[Architecture Tool<br/>Enterprise Architect]
    B -.manual sync.-> C[Feature Model<br/>Excel/pure::variants]
    C -.copy-paste.-> D[Documentation<br/>Word/Confluence]

    style A fill:#ffcdd2
    style B fill:#ffcdd2
    style C fill:#ffcdd2
    style D fill:#ffcdd2
```

**Problems with this approach:**
- Traceability breaks when tools don't talk to each other
- Manual synchronization is error-prone
- Impact analysis is nearly impossible
- Compliance verification takes weeks
- Nobody knows the "true" specification

**AssemblyLine's solution:**

```mermaid
graph TB
    A[Single Source<br/>AssemblyLine Model] --> B[PDF Documentation]
    A --> C[JSON Export]
    A --> D[Traceability Report]
    A --> E[Configuration Validation]

    style A fill:#c8e6c9
    style B fill:#e1f5ff
    style C fill:#e1f5ff
    style D fill:#e1f5ff
    style E fill:#e1f5ff
```

**Single source of truth** in version-controlled text files
**Built-in traceability** with automatic validation
**Variability management** with feature models
**Professional output** with typeset-quality PDFs
**Tool integration** via JSON export

---

## Core Concepts

AssemblyLine is built on four interconnected modeling dimensions:

### 1. Features: What Can It Do?

**Features** represent capabilities your product family offers. They organize around **variability**—what changes between product variants.

```mermaid
graph TB
    ROOT["Emergency Response System"]

    UI["● User Interface"]
    INFORM["● Inform emergency"]
    DISPLAY["● Display neighborhood"]
    SHORTCUT["● Shortcut calls"]

    EARTHQUAKE["○ Inform Earthquake"]
    FLOOD["○ Inform flood"]
    OR1(("OR"))

    MAP["○ Map"]
    TEXT["○ Textual directions"]
    OR2(("OR"))

    DANGER["○ Display danger zone"]
    SAFE["○ Display safe zone"]
    PATH["○ Display path to safe zone"]

    COPS["○ Cops"]
    AMBULANCE["○ Ambulance"]
    FIREMEN["○ Firemen"]
    OR3(("OR"))

    ROOT --- UI
    ROOT --- INFORM
    ROOT --- DISPLAY
    ROOT --- SHORTCUT

    INFORM --- OR1
    OR1 --- EARTHQUAKE
    OR1 --- FLOOD

    DISPLAY --- OR2
    OR2 --- MAP
    OR2 --- TEXT

    MAP --- DANGER
    MAP --- SAFE
    MAP --- PATH

    SHORTCUT --- OR3
    OR3 --- COPS
    OR3 --- AMBULANCE
    OR3 --- FIREMEN

    style ROOT fill:#b8c9e8,stroke:#333,stroke-width:3px
    style UI fill:#b8c9e8,stroke:#333
    style INFORM fill:#b8c9e8,stroke:#333
    style DISPLAY fill:#b8c9e8,stroke:#333
    style SHORTCUT fill:#b8c9e8,stroke:#333
    style EARTHQUAKE fill:#b8c9e8,stroke:#333
    style FLOOD fill:#b8c9e8,stroke:#333
    style MAP fill:#b8c9e8,stroke:#333
    style TEXT fill:#b8c9e8,stroke:#333
    style DANGER fill:#b8c9e8,stroke:#333
    style SAFE fill:#b8c9e8,stroke:#333
    style PATH fill:#b8c9e8,stroke:#333
    style COPS fill:#b8c9e8,stroke:#333
    style AMBULANCE fill:#b8c9e8,stroke:#333
    style FIREMEN fill:#b8c9e8,stroke:#333
    style OR1 fill:#fff9c4,stroke:#f57f17
    style OR2 fill:#fff9c4,stroke:#f57f17
    style OR3 fill:#fff9c4,stroke:#f57f17
```

**Key concepts:**
- **● Mandatory features**: Every product variant includes these
- **○ Optional features**: Some product variants include these
- **OR groups** (yellow circle): Pick at least one (can select multiple)
- **XOR groups**: Pick exactly one alternative (mutually exclusive)

### 2. Requirements: What Must It Do?

**Requirements** specify exactly what each feature must do. They form a hierarchy through decomposition:

```mermaid
graph TB
    F[Feature:<br/>Authentication]

    R1[REQ-AUTH-001<br/>System shall enforce multi-factor authentication<br/>belongs_to: F-AUTH]

    R2[REQ-AUTH-001.1<br/>System shall support TOTP<br/>derives_from: REQ-AUTH-001]

    R3[REQ-AUTH-001.2<br/>System shall support push notifications<br/>derives_from: REQ-AUTH-001]

    R4[REQ-AUTH-001.1.1<br/>TOTP shall use SHA-256<br/>derives_from: REQ-AUTH-001.1]

    R5[REQ-AUTH-001.1.2<br/>Time step configurable 30-60s<br/>derives_from: REQ-AUTH-001.1]

    R1 -->|belongs_to| F
    R2 -->|derives_from| R1
    R3 -->|derives_from| R1
    R4 -->|derives_from| R2
    R5 -->|derives_from| R2

    style F fill:#e1f5ff
    style R1 fill:#fff4e1,stroke:#ff6f00,stroke-width:3px
    style R2 fill:#fff4e1
    style R3 fill:#fff4e1
    style R4 fill:#fff9e1
    style R5 fill:#fff9e1
```

**Two-level traceability:**
- **Top-level requirements** link to features (`belongs_to`)
- **Derived requirements** decompose parents (`derives_from`)
- **Rule**: Every requirement has exactly ONE parent link

### 3. Architecture: How Is It Built?

**Architecture** uses SysML-style blocks to show system structure:

```mermaid
graph TB
    subgraph BLK-AUTH-SERVICE["Authentication Service"]
        direction TB

        API["authAPI<br/>(in)"]
        MFA_OUT["mfaPort<br/>(out)"]

        PV["Password<br/>Validator"]
        MH["MFA<br/>Handler"]
        TM["Token<br/>Manager"]

        API -->|Credentials| PV
        API -->|MFA Challenge| MH
        PV -->|Result| TM
        MH -->|Result| TM
        TM -->|TOTP Request| MFA_OUT
    end

    USER_DB[(User Database)]
    PUSH_SVC[Push Service]

    BLK-AUTH-SERVICE --> USER_DB
    BLK-AUTH-SERVICE --> PUSH_SVC

    style API fill:#4fc3f7
    style MFA_OUT fill:#4fc3f7
    style PV fill:#c8e6c9
    style MH fill:#c8e6c9
    style TM fill:#c8e6c9
```

**Key elements:**
- **Blocks**: Components with properties, operations, and ports
- **Ports**: Interfaces for communication
- **Connectors**: Message flows between components
- **Parts**: Internal sub-components

### 4. Configurations: Which Variants Do We Offer?

**Configurations** select specific features for each product variant:

```mermaid
graph LR
    subgraph "European Configuration"
        EU_F1[User Interface]
        EU_F2[Inform Earthquake]
        EU_F3[Inform Flood]
        EU_F4[Map Display]
    end

    subgraph "North American Configuration"
        NA_F1[User Interface]
        NA_F2[Inform Earthquake]
        NA_F3[Textual Directions]
        NA_F4[Shortcut Calls]
    end

    style EU_F1 fill:#c8e6c9
    style EU_F2 fill:#c8e6c9
    style EU_F3 fill:#c8e6c9
    style EU_F4 fill:#c8e6c9

    style NA_F1 fill:#c8e6c9
    style NA_F2 fill:#c8e6c9
    style NA_F3 fill:#c8e6c9
    style NA_F4 fill:#c8e6c9
```

---

## The Traceability Web

AssemblyLine's power comes from **linking everything together**:

```mermaid
graph TB
    F[Feature:<br/>Authentication]

    R1[Requirement:<br/>Multi-factor auth<br/>Parent - Not Allocated]
    R2[Requirement:<br/>TOTP support<br/>Leaf - Allocated]
    R3[Requirement:<br/>Push notification support<br/>Leaf - Allocated]

    UC[Use Case:<br/>User Login]

    SD[Sequence Diagram:<br/>Login Flow]

    BLK1[Block:<br/>TOTP Handler]
    BLK2[Block:<br/>Push Handler]

    TC[Test Case:<br/>Test Login]

    R1 -->|belongs_to| F
    R2 -->|derives_from| R1
    R3 -->|derives_from| R1

    UC -->|traces| R2
    UC -->|traces| R3

    SD -->|satisfies| R2
    SD -->|satisfies| R3
    SD -->|belongs_to| UC

    BLK1 -->|allocate| R2
    BLK2 -->|allocate| R3

    TC -->|verifies| R2
    TC -->|verifies| R3

    style F fill:#e1f5ff
    style R1 fill:#fff4e1,stroke:#ff6f00,stroke-width:2px,stroke-dasharray: 5 5
    style R2 fill:#c8e6c9
    style R3 fill:#c8e6c9
    style UC fill:#fce4ec
    style SD fill:#fff9c4
    style BLK1 fill:#e8f5e9
    style BLK2 fill:#e8f5e9
    style TC fill:#f3e5f5
```

**Traceability links:**
- Features → Requirements: `belongs_to` (top-level requirements link to features)
- Requirements → Requirements: `derives_from` (decomposition into more specific requirements)
- Use Cases → **Leaf Requirements**: `trace` (validation - ONLY to leaf requirements)
- Diagrams → **Leaf Requirements**: `satisfy` (implementation - ONLY to leaf requirements)
- Blocks → **Leaf Requirements**: `allocate` (ownership/responsibility - ONLY to leaf requirements)
- Tests → **Leaf Requirements**: `verify` (verification - ONLY to leaf requirements)

**Critical constraint (Rule 2):**
- **Parent requirements** (R1 - shown with dashed border) have derived requirements, so they CANNOT have ANY incoming links except `derives_from` from their children
- **Leaf requirements** (R2, R3 - shown with solid green fill) have no derived requirements, so they CAN receive all types of links
- ALL implementation, validation, and verification links point ONLY to leaf requirements

**Why this matters:**
- **Impact analysis**: "Which requirements does feature X affect?"
- **Coverage**: "Which requirements aren't tested?"
- **Compliance**: "Prove every requirement is implemented"
- **Change management**: "What breaks if I change this?"
- **Clear ownership**: Each block owns specific leaf requirements (R2, R3), not abstract parents (R1)

---

## Fundamental Modeling Rules

AssemblyLine enforces structural rules that govern how models can grow and evolve. These rules ensure consistency, traceability, and architectural clarity.

### Rule 1: Requirements Must Have a Parent

**Every requirement must have exactly one parent relationship.**

A requirement can have:
- **Feature parent** (via `belongs_to: "FEATURE-ID"`): Top-level requirements that directly implement a feature
- **Requirement parent** (via `derives_from: "REQ-ID"`): Derived requirements that decompose a parent requirement

**Valid examples:**

```typst
// Top-level requirement linked to feature
#req("REQ-AUTH-001",
  belongs_to: "F-AUTH",
  tags: (type: "functional")
)[
  The system shall enforce multi-factor authentication.
]

// Derived requirement linked to parent requirement
#req("REQ-AUTH-001.1",
  derives_from: "REQ-AUTH-001",
  tags: (type: "functional")
)[
  The system shall support TOTP (RFC 6238) as second factor.
]
```

**Invalid examples:**

```typst
// INVALID: No parent relationship
#req("REQ-ORPHAN", tags: (type: "functional"))[
  This requirement has no parent.
]

// INVALID: Both parent relationships
#req("REQ-BOTH",
  belongs_to: "F-AUTH",
  derives_from: "REQ-AUTH-001"
)[
  Cannot have both feature parent and requirement parent.
]
```

**Rationale:** Every requirement must trace back to a feature through the parent chain. This ensures complete traceability from features to implementation-level requirements.

### Rule 2: Requirement Decomposition Isolation

**If a requirement is decomposed (has derived requirements), it cannot have ANY incoming links except `derives_from` links from its children.**

This rule enforces strict separation between abstract (parent) and concrete (leaf) requirements.

**The rule states:**
1. If a requirement has derived requirements (other requirements point to it via `derives_from`), then it is a **parent requirement**
2. Parent requirements CANNOT receive:
   - `allocate` links from blocks (ownership)
   - `satisfy` links from diagrams (implementation)
   - `trace` links from use cases (validation)
   - `verify` links from test cases (verification)
   - Any other incoming links except `derives_from`
3. Only **leaf requirements** (those with no derived requirements) can receive implementation, allocation, and verification links

#### Allocation Rule

A requirement can be allocated to a single block using the `allocate` link:

```typst
#req("REQ-AUTH-001.1.1",
  derives_from: "REQ-AUTH-001.1",
  tags: (type: "functional")
)[
  The TOTP implementation shall use SHA-256 hash algorithm.
]

#block_definition(
  "BLK-MFA-HANDLER",
  title: "Multi-Factor Authentication Handler",
  // ... properties, operations, ports ...
  links: (
    allocate: ("REQ-AUTH-001.1.1",)  // Allocated to this block
  )
)[]
```

#### Mutual Exclusion: Parent Requirements vs. Leaf Requirements

**A requirement is either a parent (has derived requirements) OR a leaf (can receive implementation/verification links). Never both.**

**Case 1: Leaf requirement (allocatable, implementable, verifiable)**

```typst
// Leaf requirement - allocated to a block
#req("REQ-CRYPTO-001",
  derives_from: "REQ-AUTH-001.1",
  tags: (type: "functional")
)[
  Cryptographic operations shall use hardware acceleration when available.
]

#block_definition("BLK-CRYPTO-MODULE",
  links: (allocate: ("REQ-CRYPTO-001",))  // This block owns this requirement
)[]

#use_case("UC-CRYPTO",
  links: (trace: ("REQ-CRYPTO-001",))  // Use case can trace to leaf requirement
)[]

#sequence_diagram("SD-CRYPTO",
  links: (satisfy: ("REQ-CRYPTO-001",))  // Diagram can satisfy leaf requirement
)[]

// VALID: No further decomposition - this is a leaf requirement
// INVALID: Cannot create REQ-CRYPTO-001.1 because REQ-CRYPTO-001 has incoming links
```

**Case 2: Parent requirement (abstract, must be decomposed)**

```typst
// High-level requirement - too abstract for direct implementation
#req("REQ-SYSTEM-001",
  belongs_to: "F-SECURITY",
  tags: (type: "functional")
)[
  The system shall provide end-to-end security for all user data.
]

// INVALID: Cannot have ANY of these links - this requirement will be decomposed
// #block_definition("BLK-X", links: (allocate: ("REQ-SYSTEM-001",)))[]  // NO!
// #use_case("UC-X", links: (trace: ("REQ-SYSTEM-001",)))[]  // NO!
// #sequence_diagram("SD-X", links: (satisfy: ("REQ-SYSTEM-001",)))[]  // NO!

// MUST decompose into specific requirements:

#req("REQ-SYSTEM-001.1",
  derives_from: "REQ-SYSTEM-001"
)[
  Authentication service shall validate all user credentials.
]

#req("REQ-SYSTEM-001.2",
  derives_from: "REQ-SYSTEM-001"
)[
  Database layer shall encrypt all data at rest using AES-256.
]

#req("REQ-SYSTEM-001.3",
  derives_from: "REQ-SYSTEM-001"
)[
  Network layer shall enforce TLS 1.3 for all communications.
]

// Now each leaf requirement can receive all types of links
#block_definition("BLK-AUTH-SERVICE",
  links: (allocate: ("REQ-SYSTEM-001.1",))
)[]

#use_case("UC-LOGIN",
  links: (trace: ("REQ-SYSTEM-001.1",))
)[]

#block_definition("BLK-DATABASE",
  links: (allocate: ("REQ-SYSTEM-001.2",))
)[]

#sequence_diagram("SD-ENCRYPT",
  links: (satisfy: ("REQ-SYSTEM-001.2",))
)[]

#block_definition("BLK-NETWORK-MGR",
  links: (allocate: ("REQ-SYSTEM-001.3",))
)[]

#test_case("TC-TLS",
  links: (verify: ("REQ-SYSTEM-001.3",))
)[]
```

#### Workflow: Removing Links to Allow Decomposition

If you discover that a requirement with implementation/verification links needs decomposition:

```typst
// STEP 1: Initial state - requirement has implementation links
#req("REQ-AUTH-100",
  belongs_to: "F-AUTH"
)[
  The system shall provide secure authentication.
]

#block_definition("BLK-AUTH",
  links: (allocate: ("REQ-AUTH-100",))
)[]

#use_case("UC-AUTH",
  links: (trace: ("REQ-AUTH-100",))
)[]

#sequence_diagram("SD-AUTH",
  links: (satisfy: ("REQ-AUTH-100",))
)[]

// STEP 2: Realize REQ-AUTH-100 is too broad - needs decomposition
// MUST remove ALL incoming links first:

#block_definition("BLK-AUTH",
  links: (allocate: ())  // Remove allocate link
)[]

#use_case("UC-AUTH",
  links: (trace: ())  // Remove trace link
)[]

#sequence_diagram("SD-AUTH",
  links: (satisfy: ())  // Remove satisfy link
)[]

// STEP 3: Now decompose into allocatable requirements

#req("REQ-AUTH-100.1",
  derives_from: "REQ-AUTH-100"
)[
  Password validation shall enforce complexity rules.
]

#req("REQ-AUTH-100.2",
  derives_from: "REQ-AUTH-100"
)[
  MFA handler shall support TOTP and push notifications.
]

// STEP 4: Re-establish links to leaf requirements

#block_definition("BLK-PASSWORD-VALIDATOR",
  links: (allocate: ("REQ-AUTH-100.1",))
)[]

#use_case("UC-AUTH",
  links: (trace: ("REQ-AUTH-100.1", "REQ-AUTH-100.2"))  // Trace to specific requirements
)[]

#block_definition("BLK-MFA-HANDLER",
  links: (allocate: ("REQ-AUTH-100.2",))
)[]

#sequence_diagram("SD-AUTH",
  links: (satisfy: ("REQ-AUTH-100.1", "REQ-AUTH-100.2"))  // Satisfy specific requirements
)[]
```

#### Decision Flow: Allocate or Decompose?

```mermaid
graph TD
    START[New Requirement]
    CHECK{Is this concrete<br/>and implementable?}
    LEAF_IT[Make it a Leaf<br/>Allow implementation links]
    DECOMPOSE[Decompose into<br/>Derived Requirements]
    LEAF[Leaf Requirement<br/>Can have allocate/satisfy/trace/verify links]
    CONTINUE[Continue decomposing<br/>each derived requirement]

    START --> CHECK
    CHECK -->|Yes| LEAF_IT
    CHECK -->|No| DECOMPOSE
    LEAF_IT --> LEAF
    DECOMPOSE --> CONTINUE
    CONTINUE --> CHECK

    style START fill:#e1f5ff
    style CHECK fill:#fff9c4
    style LEAF_IT fill:#c8e6c9
    style DECOMPOSE fill:#ffe0b2
    style LEAF fill:#c8e6c9
    style CONTINUE fill:#ffe0b2
```

**Decision criteria:**
- **Make it a leaf** if: Requirement is specific enough to be implemented, verified, and tested directly
- **Decompose** if: Requirement is too abstract or spans multiple concerns
- **Stop decomposing** when: Each requirement is concrete and implementable

**Rationale:** This rule ensures:
- **Clear separation**: Abstract requirements (organizational) vs. concrete requirements (implementable)
- **No ambiguity**: Only leaf requirements have actual implementation/verification artifacts
- **Proper granularity**: Forces decomposition until requirements are concrete and testable
- **Clean traceability**: Implementation artifacts (blocks, diagrams, tests) link only to concrete requirements
- **Coverage analysis**: Easy to verify that all leaf requirements are implemented and tested

### Rule 3: Feature Hierarchy

**Every feature must have exactly one parent feature, except the root feature. There can be only one root feature.**

#### Single Root

```typst
// VALID: Single root feature
#feature("Product Family", id: "ROOT",
  tags: (version: "2.0")
)[
  The complete product family specification.
]

// INVALID: Second root feature
#feature("Another Root", id: "ROOT2")[
  // ERROR: Only one feature can have no parent
]
```

#### All Features Have Parents

```typst
// VALID: Feature hierarchy
#feature("Product Family", id: "ROOT")[]

#feature("Security", id: "F-SECURITY",
  parent: "ROOT"  // Parent specified
)[]

#feature("Authentication", id: "F-AUTH",
  parent: "F-SECURITY"  // Parent specified
)[]

// INVALID: Orphan feature
#feature("Orphan", id: "F-ORPHAN")[
  // ERROR: No parent specified and not root
]

// INVALID: Non-existent parent
#feature("Auth", id: "F-AUTH",
  parent: "F-NONEXISTENT"  // ERROR: Parent doesn't exist
)[]
```

#### Valid Feature Tree Structure

```mermaid
graph TB
    ROOT["ROOT: Emergency Response System"]

    UI["● F-UI: User Interface"]
    INFORM["● F-INFORM: Inform emergency"]
    DISPLAY["● F-DISPLAY: Display neighborhood"]
    SHORTCUT["● F-SHORTCUT: Shortcut calls"]

    OR1(("OR"))
    EARTHQUAKE["○ F-QUAKE: Inform Earthquake"]
    FLOOD["○ F-FLOOD: Inform flood"]

    OR2(("OR"))
    MAP["○ F-MAP: Map"]
    TEXT["○ F-TEXT: Textual directions"]

    UI --> ROOT
    INFORM --> ROOT
    DISPLAY --> ROOT
    SHORTCUT --> ROOT

    OR1 --> INFORM
    EARTHQUAKE --> OR1
    FLOOD --> OR1

    OR2 --> DISPLAY
    MAP --> OR2
    TEXT --> OR2

    style ROOT fill:#b8c9e8,stroke:#01579b,stroke-width:3px
    style UI fill:#b8c9e8
    style INFORM fill:#b8c9e8
    style DISPLAY fill:#b8c9e8
    style SHORTCUT fill:#b8c9e8
    style OR1 fill:#fff9c4,stroke:#f57f17
    style OR2 fill:#fff9c4,stroke:#f57f17
    style EARTHQUAKE fill:#b8c9e8
    style FLOOD fill:#b8c9e8
    style MAP fill:#b8c9e8
    style TEXT fill:#b8c9e8
```

**Rationale:**
- **Unambiguous hierarchy**: Clear parent-child relationships
- **Traceability**: Requirements can trace to features through well-defined paths
- **Configuration management**: Feature selection follows clear tree structure
- **Prevents orphans**: All features connected to product definition

### Summary: Fundamental Rules Quick Reference

| Rule | Element | Constraint | Purpose |
|------|---------|------------|---------|
| **Rule 1** | Requirements | Must have exactly ONE parent: `belongs_to` (feature) XOR `derives_from` (requirement) | Ensures complete traceability chain |
| **Rule 2** | Requirements | Parent requirements (with derived requirements) CANNOT have ANY incoming links except `derives_from` | Forces strict separation: abstract parents vs. concrete leaves |
| **Rule 2** | Requirements | ONLY leaf requirements (no derived requirements) can have `satisfy`, `trace`, `verify` links | Only concrete requirements get implemented/verified |
| **Rule 3** | Features | Every feature must have parent (except root). Only ONE root feature allowed. | Ensures single, well-defined feature hierarchy |

**Key principle:** These rules work together to create a **clean, traceable model** where:
- Every requirement traces back to a business feature (Rule 1)
- Abstract requirements organize, concrete requirements implement (Rule 2)
- Only leaf requirements connect to implementation artifacts (blocks, diagrams, tests)
- The feature tree forms a single, navigable hierarchy (Rule 3)

---

## Language Syntax

### Features

Define capabilities with variability:

```typst
#feature("Inform emergency",
  id: "F-INFORM",            // Unique identifier
  concrete: true,            // Can be selected in configs?
  parent: "ROOT",            // Parent feature ID
  tags: (                    // Extensible metadata
    priority: "P1",
    owner: "Emergency Team",
    cost: "+0 EUR"
  )
)[
  System shall inform users about emergency situations.
]
```

**OR groups** (at least one child):

```typst
// Parent with OR group
#feature("Inform emergency",
  id: "F-INFORM",
  concrete: false,           // Not selectable (abstract)
  parent: "ROOT",
  group: "OR"                // Can select multiple
)[]

// Alternative 1
#feature("Inform Earthquake",
  id: "F-QUAKE",
  parent: "F-INFORM"
)[]

// Alternative 2
#feature("Inform flood",
  id: "F-FLOOD",
  parent: "F-INFORM"
)[]
```

**XOR groups** (exactly one child):

```typst
#feature("Display neighborhood",
  id: "F-DISPLAY",
  parent: "ROOT",
  group: "XOR"               // Pick exactly one
)[]

#feature("Map", id: "F-MAP", parent: "F-DISPLAY")[]
#feature("Textual directions", id: "F-TEXT", parent: "F-DISPLAY")[]
```

### Requirements

Specify what the system must do:

**Top-level requirement** (linked to feature):

```typst
#req("REQ-INFORM-001",
  belongs_to: "F-INFORM",    // Links to feature
  tags: (
    type: "functional",
    safety: "ASIL-B",
    source: "ISO 22320"
  )
)[
  The system shall inform users about emergency situations within 30 seconds.
]
```

**Derived requirements** (decomposition):

```typst
#req("REQ-INFORM-001.1",
  derives_from: "REQ-INFORM-001",  // Decomposes parent requirement
  tags: (type: "functional")
)[
  The system shall display earthquake alerts with magnitude and location.
]

#req("REQ-INFORM-001.1.1",
  derives_from: "REQ-INFORM-001.1",
  tags: (implementation: "alert-module")
)[
  Earthquake alerts shall include evacuation route recommendations.
]
```

**Critical rule:** Every requirement needs **either**:
- `belongs_to: "FEATURE-ID"` (top-level), **OR**
- `derives_from: "REQ-ID"` (derived)

Never both. Never neither.

### Use Cases

Describe behavioral scenarios:

```typst
#use_case("UC-01 – Receive Earthquake Alert",
  id: "UC-QUAKE-ALERT",
  tags: (
    actor: "Resident",
    frequency: "low",
    pre-condition: "User has app installed and notifications enabled"
  ),
  links: (
    trace: ("REQ-INFORM-001", "REQ-INFORM-001.1")  // Traces to requirements
  )
)[
  A resident receives an earthquake alert and views evacuation information.

  *Main Flow:*
  1. Earthquake detected by monitoring system
  2. System determines affected area
  3. System sends push notification to user
  4. User opens alert notification
  5. System displays earthquake magnitude and location
  6. System shows recommended evacuation routes
  7. User follows evacuation guidance

  *Alternate Flow (No Network):*
  - At step 3, if no network, queue alert for delivery when connected
  - Display cached evacuation routes from local storage
]
```

### Architecture Blocks (SysML)

Define system structure:

```typst
#block_definition(
  "BLK-ALERT-SERVICE",
  title: "Alert Service",

  // Properties (state variables)
  properties: (
    (name: "alertTimeout", type: "Integer", default: "30", unit: "seconds"),
    (name: "maxRetries", type: "Integer", default: "3", unit: "attempts")
  ),

  // Operations (methods)
  operations: (
    (name: "sendAlert", params: "alert: AlertData", returns: "bool"),
    (name: "getEvacuationRoute", params: "location: Coordinates", returns: "Route")
  ),

  // Ports (interfaces)
  ports: (
    (name: "alertAPI", direction: "in", protocol: "HTTPS"),
    (name: "notifyPort", direction: "out", protocol: "Push")
  ),

  // Parts (internal components - composition)
  parts: (
    (name: "earthquakeHandler", type: "BLK-QUAKE-HANDLER", multiplicity: "1"),
    (name: "floodHandler", type: "BLK-FLOOD-HANDLER", multiplicity: "1"),
    (name: "routePlanner", type: "BLK-ROUTE-PLANNER", multiplicity: "1")
  ),

  // Connectors (message flows)
  connectors: (
    // External port → Internal part
    (from: "alertAPI", to: "earthquakeHandler.detectPort", flow: "SeismicData"),

    // Internal part → Internal part
    (from: "earthquakeHandler.routePort", to: "routePlanner.calculatePort",
     flow: "EvacuationRequest"),

    // Internal part → External port
    (from: "routePlanner.notifyPort", to: "notifyPort", flow: "AlertNotification")
  ),

  // References (associations to external blocks)
  references: ("BLK-GIS-SERVICE", "BLK-NOTIFICATION-SERVICE"),

  // Constraints (OCL-like rules)
  constraints: (
    "alertTimeout >= 5 AND alertTimeout <= 60",
    "maxRetries >= 1"
  ),

  tags: (language: "Go", framework: "Gin"),

  links: (
    allocate: ("REQ-INFORM-001", "REQ-INFORM-001.1")  // Allocated requirements
  )
)[
  Handles emergency alerts including earthquake detection,
  flood warnings, and evacuation route planning.
]
```

**Connector notation:**
- `"alertAPI"` → Block's own port (no dot)
- `"earthquakeHandler.detectPort"` → Part's port (with dot)

### Sequence Diagrams

Show interactions over time:

```typst
#sequence_diagram("SD-QUAKE-ALERT",
  title: "Earthquake Alert Sequence",
  tags: (tool: "mermaid"),
  links: (
    satisfy: ("REQ-INFORM-001", "REQ-INFORM-001.1"),  // Satisfies requirements
    belongs_to: "UC-QUAKE-ALERT"                       // Belongs to use case
  )
)[
  // Diagram content (Mermaid, PlantUML, or image reference)
]
```

### Configurations

Select features for product variants:

```typst
#config(
  "CFG-EU",
  title: "European Configuration",
  root_feature_id: "ROOT",
  selected: (
    // List of concrete feature IDs
    "F-UI",
    "F-QUAKE",          // Earthquake alerts
    "F-FLOOD",          // Flood alerts
    "F-MAP"             // Map display (not textual)
  ),
  tags: (
    market: "Europe",
    regulations: ("EU-Alert", "GDPR")
  )
)

#config(
  "CFG-NA",
  title: "North American Configuration",
  root_feature_id: "ROOT",
  selected: (
    "F-UI",
    "F-QUAKE",          // Earthquake alerts only
    "F-TEXT",           // Textual directions (not map)
    "F-SHORTCUT"        // Emergency shortcut calls
  ),
  tags: (
    market: "North America",
    regulations: ("FEMA", "FCC-EAS")
  )
)
```

---

## Complete Example: Medical Device Security

Let's build a complete model for a medical device with configurable security features.

### Step 1: Define the Feature Model

```typst
#import "lib/lib.typ": *

// Root feature
#feature("CardioCare Monitor", id: "ROOT",
  tags: (version: "2.0", class: "IIb")
)[
  Patient monitoring system with secure remote access.
]

// Mandatory: Authentication
#feature("User Authentication", id: "F-AUTH",
  concrete: true,
  parent: "ROOT",
  tags: (
    priority: "P1",
    safety: "ASIL-D",
    regulation: "IEC 62304"
  )
)[
  All users must authenticate before accessing patient data.
]

// XOR: Choose authentication method
#feature("Authentication Method", id: "AUTH-METHOD",
  concrete: false,
  parent: "F-AUTH",
  group: "XOR"
)[]

#feature("PIN Code", id: "F-PIN",
  concrete: true,
  parent: "AUTH-METHOD",
  tags: (cost: "+0 EUR", security-level: "basic")
)[
  4-8 digit PIN code authentication.
]

#feature("Smart Card", id: "F-SMARTCARD",
  concrete: true,
  parent: "AUTH-METHOD",
  tags: (cost: "+45 EUR", security-level: "high", hardware: "card-reader-v2")
)[
  ISO 7816 smart card authentication.
]

#feature("Biometric", id: "F-BIO",
  concrete: true,
  parent: "AUTH-METHOD",
  tags: (cost: "+120 EUR", security-level: "very-high", hardware: "fingerprint-scanner")
)[
  Fingerprint-based biometric authentication.
]

// Optional: Audit logging
#feature("Audit Logging", id: "F-AUDIT",
  concrete: true,
  parent: "ROOT",
  tags: (priority: "P1", regulation: "FDA 21 CFR Part 11")
)[
  Comprehensive audit trail of all access and modifications.
]

// Optional: Data encryption
#feature("Data Encryption", id: "F-ENCRYPT",
  concrete: true,
  parent: "ROOT",
  tags: (priority: "P2", regulation: "GDPR")
)[
  Encrypt patient data at rest and in transit.
]

// Optional: Emergency access
#feature("Emergency Override", id: "F-EMERGENCY",
  concrete: true,
  parent: "ROOT",
  tags: (priority: "P1", safety: "ASIL-D")
)[
  Emergency access bypass for life-critical situations.
]
```

### Step 2: Define Requirements

```typst
// ========== AUTHENTICATION REQUIREMENTS ==========

#req("REQ-AUTH-001",
  belongs_to: "F-AUTH",
  tags: (
    type: "functional",
    safety: "ASIL-D",
    source: "IEC 62304 Section 5.2"
  )
)[
  The system shall authenticate all users before granting access to patient data.
]

#req("REQ-AUTH-001.1",
  derives_from: "REQ-AUTH-001",
  tags: (type: "functional")
)[
  The system shall support configurable authentication methods: PIN, smart card, or biometric.
]

#req("REQ-AUTH-001.1.1",
  derives_from: "REQ-AUTH-001.1",
  tags: (type: "functional", variant: "F-PIN")
)[
  PIN authentication shall require 4-8 digit codes.
]

#req("REQ-AUTH-001.1.2",
  derives_from: "REQ-AUTH-001.1",
  tags: (type: "functional", variant: "F-SMARTCARD")
)[
  Smart card authentication shall comply with ISO 7816-4.
]

#req("REQ-AUTH-001.1.3",
  derives_from: "REQ-AUTH-001.1",
  tags: (type: "functional", variant: "F-BIO")
)[
  Biometric authentication shall achieve FAR < 0.001% and FRR < 1%.
]

#req("REQ-AUTH-002",
  belongs_to: "F-AUTH",
  tags: (type: "security", safety: "ASIL-C")
)[
  The system shall lock accounts after 3 consecutive failed authentication attempts.
]

#req("REQ-AUTH-002.1",
  derives_from: "REQ-AUTH-002",
  tags: (type: "functional")
)[
  Account lockout shall persist until administrative unlock or 30-minute timeout.
]

// ========== AUDIT REQUIREMENTS ==========

#req("REQ-AUDIT-001",
  belongs_to: "F-AUDIT",
  tags: (
    type: "functional",
    regulation: "FDA 21 CFR Part 11.10(e)"
  )
)[
  The system shall create audit records for all user access and patient data modifications.
]

#req("REQ-AUDIT-001.1",
  derives_from: "REQ-AUDIT-001",
  tags: (type: "functional")
)[
  Audit records shall include: timestamp, user ID, action type, patient ID, and outcome.
]

#req("REQ-AUDIT-001.2",
  derives_from: "REQ-AUDIT-001",
  tags: (type: "security")
)[
  Audit records shall be immutable and cryptographically signed.
]

// ========== ENCRYPTION REQUIREMENTS ==========

#req("REQ-ENCRYPT-001",
  belongs_to: "F-ENCRYPT",
  tags: (type: "security", regulation: "GDPR Art. 32")
)[
  The system shall encrypt all patient data at rest using AES-256.
]

#req("REQ-ENCRYPT-002",
  belongs_to: "F-ENCRYPT",
  tags: (type: "security")
)[
  The system shall encrypt all network communications using TLS 1.3.
]

// ========== EMERGENCY ACCESS REQUIREMENTS ==========

#req("REQ-EMERG-001",
  belongs_to: "F-EMERGENCY",
  tags: (
    type: "functional",
    safety: "ASIL-D",
    source: "Risk Analysis RA-2024-03"
  )
)[
  The system shall provide emergency override access within 10 seconds in life-critical situations.
]

#req("REQ-EMERG-001.1",
  derives_from: "REQ-EMERG-001",
  tags: (type: "functional")
)[
  Emergency override shall be activated by physical button press or administrative code.
]

#req("REQ-EMERG-001.2",
  derives_from: "REQ-EMERG-001",
  tags: (type: "security")
)[
  All emergency override activations shall be logged with justification and reviewed within 24 hours.
]
```

### Step 3: Define Use Cases

```typst
#use_case("UC-01 – Physician Access Patient Record",
  id: "UC-ACCESS",
  tags: (
    actor: "Physician",
    frequency: "very-high",
    pre-condition: "Physician has valid credentials"
  ),
  links: (
    trace: ("REQ-AUTH-001.1.1", "REQ-AUTH-001.1.2", "REQ-AUDIT-001.1")
  )
)[
  A physician authenticates and accesses a patient's vital signs and medical history.

  *Main Flow:*
  1. Physician approaches CardioCare Monitor
  2. System displays authentication prompt
  3. Physician enters credentials (PIN/card/fingerprint depending on configuration)
  4. System validates credentials against user database
  5. System logs authentication event to audit trail
  6. System displays patient selection screen
  7. Physician selects patient
  8. System logs patient access event
  9. System displays patient vital signs and history
  10. Physician reviews data

  *Alternate Flow 1 (Invalid Credentials):*
  - At step 4, if credentials invalid:
    - System increments failed attempt counter
    - System displays error message
    - Return to step 3
    - If 3rd failed attempt, lock account (REQ-AUTH-002) and alert administrator

  *Alternate Flow 2 (Emergency Override):*
  - At step 2, if emergency situation:
    - Physician presses emergency override button
    - System grants immediate access
    - System logs emergency override with justification prompt
    - Continue to step 6
]

#use_case("UC-02 – Emergency Override Activation",
  id: "UC-EMERGENCY",
  tags: (
    actor: "Clinician",
    frequency: "low",
    criticality: "life-critical"
  ),
  links: (
    trace: ("REQ-EMERG-001.1", "REQ-EMERG-001.2", "REQ-AUDIT-001.1")
  )
)[
  In a life-critical emergency, clinician bypasses normal authentication to access patient data.

  *Main Flow:*
  1. Emergency situation occurs (cardiac arrest, trauma, etc.)
  2. Clinician presses physical EMERGENCY ACCESS button
  3. System activates emergency override mode within 5 seconds
  4. System displays patient selection with emergency banner
  5. Clinician selects patient
  6. System grants full access to patient data
  7. System logs emergency access event with timestamp and user badge scan
  8. Clinician treats patient using accessed data
  9. After emergency resolved, system prompts for justification
  10. Clinician enters justification text
  11. System submits emergency access event for review

  *Safety Constraint:*
  - System shall NEVER delay emergency access for authentication
  - Maximum time from button press to data display: 10 seconds (REQ-EMERG-001)
]
```

### Step 4: Define Architecture

```typst
#block_definition(
  "BLK-CARDIOCARE",
  title: "CardioCare Monitor System",

  properties: (
    (name: "maxPatients", type: "Integer", default: "50", unit: "patients"),
    (name: "authTimeout", type: "Integer", default: "300", unit: "seconds"),
    (name: "emergencyMode", type: "Boolean", default: "false")
  ),

  operations: (
    (name: "initialize", params: "config: Config", returns: "bool"),
    (name: "authenticate", params: "credentials: Credentials", returns: "SessionToken"),
    (name: "activateEmergency", params: "void", returns: "void"),
    (name: "getPatientData", params: "patientId: ID", returns: "PatientRecord")
  ),

  ports: (
    (name: "displayPort", direction: "out", protocol: "HDMI"),
    (name: "networkPort", direction: "in-out", protocol: "Ethernet"),
    (name: "emergencyButton", direction: "in", protocol: "GPIO"),
    (name: "auditPort", direction: "out", protocol: "Syslog")
  ),

  parts: (
    (name: "authService", type: "BLK-AUTH-SERVICE", multiplicity: "1"),
    (name: "patientDb", type: "BLK-PATIENT-DB", multiplicity: "1"),
    (name: "auditLogger", type: "BLK-AUDIT-LOGGER", multiplicity: "1"),
    (name: "encryptionModule", type: "BLK-CRYPTO", multiplicity: "1"),
    (name: "displayController", type: "BLK-DISPLAY", multiplicity: "1")
  ),

  connectors: (
    // Emergency button to auth service
    (from: "emergencyButton", to: "authService.emergencyPort", flow: "EmergencySignal"),

    // Auth service to patient database
    (from: "authService.dbPort", to: "patientDb.queryPort", flow: "AuthQuery"),

    // Patient database to encryption module
    (from: "patientDb.encryptPort", to: "encryptionModule.cryptoPort", flow: "EncryptRequest"),

    // Auth service to audit logger
    (from: "authService.auditPort", to: "auditLogger.logPort", flow: "AuditEvent"),

    // Display controller to external display
    (from: "displayController.videoPort", to: "displayPort", flow: "VideoSignal"),

    // Audit logger to external syslog
    (from: "auditLogger.syslogPort", to: "auditPort", flow: "SyslogMessage")
  ),

  constraints: (
    "authTimeout >= 60 AND authTimeout <= 600",
    "emergencyMode = true IMPLIES authTimeout = 0"
  ),

  tags: (
    device-class: "IIb",
    standard: "IEC 62304",
    criticality: "high"
  ),

  links: (
    satisfy: ("REQ-AUTH-001", "REQ-AUDIT-001", "REQ-ENCRYPT-001", "REQ-EMERG-001")
  )
)[
  The CardioCare Monitor is a bedside patient monitoring system that displays
  vital signs and provides secure access to electronic health records.
]

#block_definition(
  "BLK-AUTH-SERVICE",
  title: "Authentication Service",

  properties: (
    (name: "authMethod", type: "Enum", default: "PIN", unit: "PIN|SmartCard|Biometric"),
    (name: "maxAttempts", type: "Integer", default: "3"),
    (name: "lockoutDuration", type: "Integer", default: "1800", unit: "seconds")
  ),

  operations: (
    (name: "authenticate", params: "credentials: Credentials", returns: "Token"),
    (name: "validatePIN", params: "pin: string", returns: "bool"),
    (name: "validateSmartCard", params: "cardData: bytes", returns: "bool"),
    (name: "validateBiometric", params: "fingerprint: Image", returns: "bool"),
    (name: "emergencyOverride", params: "void", returns: "EmergencyToken")
  ),

  ports: (
    (name: "authAPI", direction: "in", protocol: "Internal"),
    (name: "emergencyPort", direction: "in", protocol: "GPIO"),
    (name: "dbPort", direction: "out", protocol: "SQL"),
    (name: "auditPort", direction: "out", protocol: "Internal")
  ),

  parts: (
    (name: "pinValidator", type: "BLK-PIN-VALIDATOR", multiplicity: "0..1"),
    (name: "cardValidator", type: "BLK-CARD-VALIDATOR", multiplicity: "0..1"),
    (name: "bioValidator", type: "BLK-BIO-VALIDATOR", multiplicity: "0..1"),
    (name: "lockoutManager", type: "BLK-LOCKOUT-MGR", multiplicity: "1")
  ),

  connectors: (),

  tags: (language: "C", safety: "ASIL-D"),

  links: (
    satisfy: ("REQ-AUTH-001", "REQ-AUTH-001.1", "REQ-AUTH-002", "REQ-EMERG-001")
  )
)[
  Handles all authentication operations with configurable methods.
  Parts are instantiated based on selected authentication feature.
]
```

### Step 5: Define Configurations

```typst
// Basic Configuration (Low-cost)
#config(
  "CFG-BASIC",
  title: "Basic Configuration",
  root_feature_id: "ROOT",
  selected: (
    "F-AUTH",
    "F-PIN",           // PIN authentication (lowest cost)
    "F-AUDIT"          // Mandatory audit logging
  ),
  tags: (
    market: "Emerging Markets",
    cost: "budget",
    target-price: "5000 EUR"
  )
)

// Standard Configuration (Mid-range)
#config(
  "CFG-STANDARD",
  title: "Standard Configuration",
  root_feature_id: "ROOT",
  selected: (
    "F-AUTH",
    "F-SMARTCARD",     // Smart card authentication
    "F-AUDIT",
    "F-ENCRYPT",       // Add data encryption
    "F-EMERGENCY"      // Emergency override
  ),
  tags: (
    market: "Europe/North America",
    cost: "mid-range",
    target-price: "8000 EUR",
    regulations: ("GDPR", "FDA 21 CFR Part 11")
  )
)

// Premium Configuration (High-security)
#config(
  "CFG-PREMIUM",
  title: "Premium Configuration",
  root_feature_id: "ROOT",
  selected: (
    "F-AUTH",
    "F-BIO",           // Biometric authentication (highest security)
    "F-AUDIT",
    "F-ENCRYPT",
    "F-EMERGENCY"
  ),
  tags: (
    market: "High-security Facilities",
    cost: "premium",
    target-price: "12000 EUR",
    regulations: ("GDPR", "HIPAA", "FDA 21 CFR Part 11"),
    security-level: "maximum"
  )
)
```

### Step 6: Validate and Generate

Create your main document:

```typst
// main.typ
#import "lib/lib.typ": *

#set document(title: "CardioCare Monitor Specification")
#set page(numbering: "1", margin: 2cm)

// Title
#align(center)[
  #text(size: 24pt, weight: "bold")[CardioCare Monitor]
  #v(0.5em)
  #text(size: 14pt)[Product Line Specification v2.0]
]
#pagebreak()

// Include all model files
#include "features.typ"
#include "requirements.typ"
#include "use-cases.typ"
#include "architecture.typ"
#include "configurations.typ"

// Validate all links
#validate-links()

// Generate documentation
#pagebreak()
= Feature Model
#feature-tree(root: "ROOT")

#pagebreak()
= Requirements by Feature
#feature-tree-with-requirements(root: "ROOT")

#pagebreak()
= Use Case Specifications
#use-case-section()

#pagebreak()
= System Architecture
#block-definition-section()

#pagebreak()
= Configuration Comparison
#config-comparison-table()
```

Compile to PDF:

```bash
typst compile main.typ
```

**Output:**
- Professional PDF with all specifications
- Feature tree visualization
- Requirements traced to features
- Use cases linked to requirements
- Architecture with SysML diagrams
- Configuration tables
- Traceability validation report

---

## Traceability Validation

AssemblyLine automatically validates your model:

### Link Existence Check

```bash
typst compile main.typ
```

**If you have broken links:**

```
Link validation failed with 1 error(s):
Link from 'REQ-AUTH-001' to 'F-INVALID' (type: 'belongs_to')
references non-existent element 'F-INVALID'
```

Fix by correcting the feature ID:

```typst
// BROKEN
#req("REQ-AUTH-001", belongs_to: "F-INVALID")[]

// FIXED
#req("REQ-AUTH-001", belongs_to: "F-AUTH")[]
```

### Structural Rules

The built-in validator enforces the **Fundamental Modeling Rules** described earlier in this guide:

1. **Rule 1: Every requirement has exactly one parent**
   ```typst
   // INVALID: No parent
   #req("REQ-001")[]

   // VALID: Has belongs_to
   #req("REQ-001", belongs_to: "F-AUTH")[]

   // VALID: Has derives_from
   #req("REQ-001.1", derives_from: "REQ-001")[]
   ```

2. **Rule 2: Parent requirements cannot have implementation/verification links**
   ```typst
   // VALID: Leaf requirement with implementation links
   #req("REQ-IMPL-001", derives_from: "REQ-001")[]
   #block_definition("BLK-AUTH", links: (allocate: ("REQ-IMPL-001",)))[]
   #use_case("UC-TEST", links: (trace: ("REQ-IMPL-001",)))[]

   // INVALID: Parent requirement cannot have ANY incoming links
   #req("REQ-PARENT", belongs_to: "F-AUTH")[]
   #req("REQ-PARENT.1", derives_from: "REQ-PARENT")[]  // Has derived requirements

   // ALL of these are ERRORS:
   #block_definition("BLK-X", links: (allocate: ("REQ-PARENT",)))[]  // ERROR!
   #use_case("UC-X", links: (trace: ("REQ-PARENT",)))[]  // ERROR!
   #sequence_diagram("SD-X", links: (satisfy: ("REQ-PARENT",)))[]  // ERROR!
   #test_case("TC-X", links: (verify: ("REQ-PARENT",)))[]  // ERROR!
   ```

3. **Rule 3: Only one root feature**
   ```typst
   // VALID: One root
   #feature("Product", id: "ROOT")[]

   // INVALID: Second root
   #feature("Another Root", id: "ROOT2")[]
   ```

4. **Rule 3: All features have valid parents**
   ```typst
   // INVALID: Parent doesn't exist
   #feature("Auth", id: "F-AUTH", parent: "NON-EXISTENT")[]
   ```

5. **Use cases trace to requirements**
   ```typst
   // INVALID: No trace links
   #use_case("Login", id: "UC-LOGIN")[]

   // VALID: Has trace links
   #use_case("Login", id: "UC-LOGIN",
     links: (trace: ("REQ-AUTH-001",))
   )[]
   ```

**See the "Fundamental Modeling Rules" section for detailed explanations, examples, and rationale for each rule.**

---

## Best Practices

### 1. Organize by Concern

Structure your files logically:

```
project/
├── main.typ                    # Entry point
├── lib/lib.typ                 # Language library (don't modify)
├── features/
│   ├── authentication.typ
│   ├── authorization.typ
│   └── monitoring.typ
├── requirements/               # Alternative: requirements with features
├── use-cases/
│   ├── login.typ
│   └── access-control.typ
├── architecture/
│   └── blocks.typ
├── diagrams/
│   ├── sequence/
│   └── blocks/
└── configurations.typ
```

### 2. Use Consistent ID Schemes

```typst
// Features: F-XXX
#feature("Authentication", id: "F-AUTH", ...)

// Requirements: REQ-XXX-### with dot notation for decomposition
#req("REQ-AUTH-001", ...)
#req("REQ-AUTH-001.1", derives_from: "REQ-AUTH-001", ...)
#req("REQ-AUTH-001.1.1", derives_from: "REQ-AUTH-001.1", ...)

// Use Cases: UC-XXX
#use_case("Login", id: "UC-LOGIN", ...)

// Blocks: BLK-XXX
#block_definition("BLK-AUTH-SERVICE", ...)

// Configurations: CFG-XXX
#config("CFG-EU", ...)
```

### 3. Tag Extensively

Tags make models searchable and analyzable:

```typst
#req("REQ-AUTH-001",
  belongs_to: "F-AUTH",
  tags: (
    // Classification
    type: "functional",
    category: "security",

    // Safety/Security
    safety-level: "ASIL-D",
    security-property: "confidentiality",

    // Traceability
    source: "ISO 26262 Section 6.4.3",
    external-id: "DOORS-REQ-12345",

    // Project metadata
    owner: "Security Team",
    priority: "P1",
    status: "approved",
    reviewer: "J.Smith",
    review-date: "2025-11-15",

    // Implementation
    component: "auth-service",
    estimated-effort: "8 hours",

    // Testing
    verification-method: "test",
    test-type: "integration"
  )
)[]
```

### 4. Write Clear Requirement Text

```typst
// BAD: Vague, untestable
#req("REQ-001", belongs_to: "F-AUTH")[
  The system should have good security.
]

// GOOD: Specific, measurable, testable
#req("REQ-001", belongs_to: "F-AUTH")[
  The system shall enforce multi-factor authentication using TOTP (RFC 6238)
  with SHA-256 hash algorithm and 30-second time step for all remote access
  connections initiated outside the local network (non-192.168.x.x addresses).
]
```

### 5. Maintain Decomposition Depth

```typst
// GOOD: 2-3 levels of decomposition
Feature: F-AUTH
  └─ REQ-AUTH-001 (top-level: MFA required)
      ├─ REQ-AUTH-001.1 (method: TOTP support)
      │   ├─ REQ-AUTH-001.1.1 (detail: SHA-256)
      │   └─ REQ-AUTH-001.1.2 (detail: time step)
      └─ REQ-AUTH-001.2 (method: Push support)

// AVOID: Too many levels (hard to manage)
REQ-AUTH-001.1.1.1.1.1
```

### 6. Link Everything

```typst
// Create complete traceability chains
Feature: F-AUTH
  ↓ belongs_to
Requirement: REQ-AUTH-001
  ↓ derives_from
Requirement: REQ-AUTH-001.1
  ↑ trace           ↑ satisfy              ↑ satisfy
Use Case: UC-LOGIN  Diagram: SD-LOGIN  Block: BLK-AUTH-SERVICE
```

### 7. Document Rationale in Tags

```typst
#req("REQ-AUTH-002.1",
  derives_from: "REQ-AUTH-002",
  tags: (
    rationale: "30-minute timeout balances security (prevent brute force) with usability (don't frustrate legitimate users who mistype password)"
  )
)[]
```

---

## Advanced Topics

### Custom Link Types

Beyond built-in links (`belongs_to`, `derives_from`, `trace`, `satisfy`), define custom types:

```typst
#req("REQ-SAFETY-001",
  belongs_to: "F-EMERGENCY",
  tags: (safety: "ASIL-D"),
  links: (
    mitigates: ("HAZARD-001", "HAZARD-003"),      // Custom link type
    tested_by: ("TC-SAFETY-001", "TC-SAFETY-002"),
    approved_by: "REGULATORY-REVIEW-2025-Q1"
  )
)[]
```

### Conditional Features

Use tags to mark feature variants:

```typst
#req("REQ-AUTH-001.1.1",
  derives_from: "REQ-AUTH-001.1",
  tags: (
    type: "functional",
    applies_if: "F-PIN",        // Only if PIN feature selected
    variant: "basic"
  )
)[
  PIN codes shall be 4-8 digits.
]

#req("REQ-AUTH-001.1.2",
  derives_from: "REQ-AUTH-001.1",
  tags: (
    applies_if: "F-BIO",        // Only if biometric feature selected
    variant: "premium"
  )
)[
  Fingerprint matching shall achieve FAR < 0.001%.
]
```

### JSON Export for Tool Integration

```bash
# Export model to JSON
typst compile --input export-json=model.json main.typ

# Use with external tools
python analyze_coverage.py model.json
./requirements_db_import model.json
```

**JSON structure:**

```json
{
  "elements": {
    "F-AUTH": {
      "type": "feature",
      "id": "F-AUTH",
      "title": "Secure Authentication",
      "tags": {
        "priority": "P1",
        "owner": "Security Team"
      },
      "parent": "ROOT",
      "concrete": true
    },
    "REQ-AUTH-001": {
      "type": "req",
      "id": "REQ-AUTH-001",
      "body": "The system shall enforce multi-factor authentication...",
      "tags": {
        "type": "functional",
        "safety": "QM"
      }
    }
  },
  "links": [
    {
      "source": "REQ-AUTH-001",
      "type": "belongs_to",
      "target": "F-AUTH"
    }
  ]
}
```

---

## Workflow Integration

### Version Control

AssemblyLine models are plain text—perfect for Git:

```bash
git init
git add *.typ
git commit -m "Initial model: authentication feature"

# Branch for new feature
git checkout -b feature/biometric-auth
# Edit features/authentication.typ
git commit -m "Add biometric authentication variant"
git push origin feature/biometric-auth

# Create pull request for review
```

**Benefits:**
- Line-by-line diffs for changes
- Merge conflict resolution
- Branch-based feature development
- Full history and blame tracking

### Continuous Integration

Automate validation in CI/CD:

```yaml
# .github/workflows/validate.yml
name: Validate Model

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Install Typst
        run: |
          curl -L https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-gnu.tar.xz | tar -xJ
          sudo mv typst-x86_64-unknown-linux-gnu/typst /usr/local/bin/

      - name: Compile and Validate
        run: typst compile main.typ

      - name: Export JSON
        run: typst compile --input export-json=model.json main.typ

      - name: Upload Artifact
        uses: actions/upload-artifact@v2
        with:
          name: specification-pdf
          path: main.pdf
```

### Review Process

Use pull requests for specification reviews:

1. **Developer** creates branch and modifies model
2. **CI** validates links and generates PDF
3. **Reviewers** see exactly what changed:
   ```diff
   + #req("REQ-AUTH-003", belongs_to: "F-AUTH",
   +   tags: (type: "security", priority: "P1")
   + )[
   +   The system shall rate-limit authentication attempts to
   +   maximum 10 attempts per minute per IP address.
   + ]
   ```
4. **Merge** after approval

---

## Common Questions

### Q: Why text-based instead of GUI tools?

**A:** Text-based modeling provides:
- **Version control**: Git diffs, branches, merges
- **Collaboration**: Multiple people can edit different files
- **Automation**: Scripts, CI/CD, code generation
- **Portability**: No vendor lock-in, works anywhere
- **Search**: `grep`, `ripgrep`, IDE find-in-files

GUI tools scatter data across databases and binary formats.

### Q: How does this compare to DOORS/Polarion?

**A:** AssemblyLine complements or replaces requirements tools:

| Feature | DOORS/Polarion | AssemblyLine |
|---------|----------------|--------------|
| Requirements management | Mature | Text-based |
| Feature modeling | Limited | Native XOR/OR |
| Architecture (SysML) | Via plugins | Built-in |
| Version control | Internal | Git-native |
| Traceability | GUI links | Validated links |
| Cost | Expensive | Free (open source) |
| Learning curve | High (GUI complexity) | Medium (syntax) |

### Q: Can I import existing requirements?

**A:** Yes, via JSON:

```python
# import_from_doors.py
import json

doors_export = load_doors_export("requirements.csv")

model = {
    "elements": {},
    "links": []
}

for req in doors_export:
    model["elements"][req['id']] = {
        "type": "req",
        "id": req['id'],
        "body": req['text'],
        "tags": {
            "type": req['type'],
            "priority": req['priority'],
            "source": "DOORS"
        }
    }

    if req['parent_feature']:
        model["links"].append({
            "source": req['id'],
            "type": "belongs_to",
            "target": req['parent_feature']
        })

# Generate AssemblyLine .typ file
generate_typst_file(model, "imported_requirements.typ")
```

### Q: How do I handle large models (1000+ requirements)?

**A:** Split into multiple files:

```typst
// requirements/authentication.typ (50 requirements)
#include "requirements/authentication.typ"

// requirements/authorization.typ (80 requirements)
#include "requirements/authorization.typ"

// ... etc (20 files)
```

Typst compiles incrementally and caches unchanged files.

### Q: Can teams collaborate on the same model?

**A:** Yes, like code collaboration:

```
Team Structure:
├── Security Team       → features/authentication.typ
├── Platform Team       → architecture/infrastructure.typ
├── UI Team            → use-cases/user-interactions.typ
└── QA Team            → requirements/ (reviews all)

Workflow:
1. Each team owns files
2. Changes via pull requests
3. Cross-team reviews
4. CI validates on every commit
```

---

## Next Steps

### 1. Get Started

```bash
# Clone template
git clone https://github.com/yourorg/assemblyline-template
cd assemblyline-template

# Compile example
typst compile main.typ

# Open generated PDF
open main.pdf
```

### 2. Adapt for Your Domain

Replace the example model with your product:

1. **Features**: What capabilities does your product family offer?
2. **Requirements**: What must each feature do?
3. **Use Cases**: How do users interact with it?
4. **Architecture**: How is it structured?
5. **Configurations**: Which variants do you sell?

### 3. Establish Conventions

Document your team's conventions:

```markdown
# Project Modeling Conventions

## ID Schemes
- Features: F-[SUBSYSTEM]-[NAME]
- Requirements: REQ-[SUBSYSTEM]-###
- Blocks: BLK-[SUBSYSTEM]

## Required Tags
- All requirements: type, priority, owner
- All features: cost-impact, team
- All blocks: language, framework

## Decomposition Limits
- Maximum 3 levels of requirement decomposition
- Maximum 4 levels of feature hierarchy

## Review Process
- All requirement changes need 2 approvals
- Architecture changes need architect approval
```

### 4. Integrate with Tools

Export to JSON and integrate:

```bash
# Export
typst compile --input export-json=model.json main.typ

# Import to requirements database
./import_to_db.sh model.json

# Generate traceability matrix
python generate_trace_matrix.py model.json --output trace.xlsx

# Check coverage
./coverage_check.py model.json --config CFG-EU
```

### 5. Continuous Improvement

Track model quality metrics:

- **Coverage**: % requirements with tests
- **Traceability**: % requirements traced to features
- **Satisfaction**: % requirements satisfied by architecture
- **Completeness**: % use cases linked to requirements

---

## Conclusion

AssemblyLine provides a **unified, text-based language** for modeling product-line systems that:

**Integrates** features, requirements, use cases, and architecture
**Validates** traceability automatically
**Scales** from small projects to large product families
**Collaborates** via version control
**Documents** with professional PDF output

Start with small models, grow incrementally, and adapt to your domain. The text-based approach means you own your data forever—no vendor lock-in, no proprietary formats, just plain text that lasts.

**Happy modeling!**

---

## Appendix: Quick Reference

### Element Types

| Element | Purpose | Required Parameters | Key Links |
|---------|---------|---------------------|-----------|
| `#feature` | Product capability | `id`, `parent` | `child_of` (implicit) |
| `#req` | Specification | `id`, `belongs_to` OR `derives_from` | `belongs_to`, `derives_from` |
| `#use_case` | Behavioral scenario | `id` | `trace` (to requirements) |
| `#block_definition` | SysML block | `id`, `title` | `allocate` (requirements) |
| `#sequence_diagram` | Interaction diagram | `id` | `satisfy`, `belongs_to` |
| `#config` | Product variant | `id`, `selected` | — |

### Link Types

| Link Type | From | To | Meaning |
|-----------|------|-----|---------|
| `belongs_to` | Requirement | Feature | Top-level req belongs to feature |
| `derives_from` | Requirement | Requirement | Requirement decomposes parent |
| `trace` | Use Case | Requirement | Use case validates requirement |
| `allocate` | Block | Requirement | Block owns/is responsible for requirement |
| `satisfy` | Diagram | Requirement | Diagram satisfies requirement |
| `belongs_to` | Diagram | Use Case | Diagram visualizes use case |

### File Structure Template

```
project/
├── main.typ
├── lib/
│   └── lib.typ
├── features/
│   ├── feature1.typ
│   └── feature2.typ
├── use-cases/
│   └── *.typ
├── architecture/
│   └── blocks.typ
├── diagrams/
│   └── *.typ
└── configurations.typ
```

### Compilation Commands

```bash
# Compile to PDF
typst compile main.typ

# Export to JSON
typst compile --input export-json=output.json main.typ

# Watch mode (auto-recompile on changes)
typst watch main.typ
```
