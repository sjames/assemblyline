# Traceability Link Analysis - ADAS Product Line Model

## Overview
This document provides a comprehensive analysis of all traceability links used in the ADAS (Advanced Driver Assistance Systems) product-line model.

## Link Type Summary

| Link Type | Count | Source Element Type | Target Element Type | Validation Rule | Purpose |
|-----------|-------|---------------------|---------------------|-----------------|---------|
| `belongs_to` | 25 | Requirement | Feature | RULE 1 | Links top-level requirements to their parent features |
| `derives_from` | 4 | Requirement | Requirement | RULE 1 | Links derived/refined requirements to parent requirements |
| `parent` | 28 | Feature | Feature | RULE 2, 3 | Establishes feature hierarchy (feature tree) |
| `satisfy` | 5 | Block Definition | Requirement(s) | RULE 7 | Links architecture blocks to requirements they satisfy |
| `trace` | 6 | Test Case | Requirement(s) | RULE 4 | Links test cases to requirements they verify |

**Total Links: 68**

---

## Detailed Link Type Descriptions

### 1. `belongs_to` - Requirement → Feature (25 links)

**Purpose**: Establishes which feature owns a top-level requirement.

**Cardinality**: Many-to-One (multiple requirements can belong to one feature)

**Validation**:
- RULE 1: Every requirement must have EITHER `belongs_to` OR `derives_from` (mutually exclusive)
- Target feature must exist in the registry

**Examples**:
```typst
// Sensor requirement belongs to sensor feature
#req("REQ-SENS-001", belongs_to: "F-SENSORS", tags: (asil: "D"))[
  The system shall provide redundant environmental perception.
]

// LDW requirement belongs to LDW feature
#req("REQ-LDW-001", belongs_to: "F-LDW", tags: (asil: "B"))[
  The system shall warn within 0.5s of lane departure.
]

// HMI requirement belongs to HMI feature
#req("REQ-HMI-001", belongs_to: "F-HMI", tags: (asil: "B"))[
  The HMI shall provide clear visual and audible feedback.
]
```

**Distribution by Feature Area**:
- Sensors: 6 requirements (REQ-SENS-001, REQ-CAM-001, REQ-CAM1-001, REQ-CAM4-001, REQ-RAD-001, REQ-RADSR-001, REQ-RADLR-001, REQ-LID-001)
- ADAS Functions: 8 requirements (REQ-ADAS-001, REQ-LDW-001, REQ-LKA-001, REQ-AEB-001, REQ-ACC-001, REQ-BSD-001, REQ-RCTA-001, REQ-TSR-001)
- HMI: 4 requirements (REQ-HMI-001, REQ-CLUSTER-001, REQ-HUD-001, REQ-HAPTIC-001)
- ECU: 5 requirements (REQ-ECU-001, REQ-SINGLE-001, REQ-MULTI-001, REQ-MEM-001, REQ-COMM-001)

---

### 2. `derives_from` - Requirement → Requirement (4 links)

**Purpose**: Establishes requirement decomposition/refinement hierarchy.

**Cardinality**: Many-to-One (multiple derived requirements can come from one parent)

**Validation**:
- RULE 1: Every requirement must have EITHER `belongs_to` OR `derives_from`
- RULE 6: If a requirement has `derives_from`, it should NOT have `allocated_to` links
- Parent requirement must exist

**Examples**:
```typst
// Parent requirement (top-level)
#req("REQ-LDW-001", belongs_to: "F-LDW")[
  The system shall warn within 0.5s of lane departure above 60 km/h.
]

// Derived requirement (decomposition)
#req("REQ-LDW-002", derives_from: "REQ-LDW-001")[
  The warning shall be both visual (icon) and audible (tone).
]

// Parent requirement
#req("REQ-AEB-001", belongs_to: "F-AEB")[
  The system shall brake when collision probability > 90% and TTC < 2.5s.
]

// Derived requirement (performance detail)
#req("REQ-AEB-002", derives_from: "REQ-AEB-001")[
  The system shall achieve full braking (10 m/s²) within 200ms.
]
```

**Decomposition Tree**:
```
REQ-LDW-001 (top-level)
  └─ REQ-LDW-002 (modality specification)

REQ-LKA-001 (top-level)
  └─ REQ-LKA-002 (driver override constraint)

REQ-AEB-001 (top-level)
  └─ REQ-AEB-002 (timing/performance detail)

REQ-ACC-001 (top-level)
  └─ REQ-ACC-002 (accuracy specification)
```

**Depth**: Currently 2 levels (1 parent → 1 child), but language supports arbitrary depth

---

### 3. `parent` - Feature → Feature (28 links)

**Purpose**: Establishes feature hierarchy for product-line variability modeling.

**Cardinality**: Many-to-One (multiple children, one parent)

**Special Cases**:
- Exactly ONE feature has no parent (ROOT feature) - RULE 2
- All other features must have valid parent - RULE 3

**Validation**:
- RULE 2: Exactly one feature with empty/no parent (the root)
- RULE 3: All other features must reference an existing parent feature

**Feature Tree Structure**:
```
ROOT (no parent)
├─ F-SENSORS (parent: ROOT)
│  ├─ F-CAMERA (parent: F-SENSORS)
│  │  ├─ CAM-CONFIG (parent: F-CAMERA, concrete: false, group: XOR)
│  │  │  ├─ F-CAM-1 (parent: CAM-CONFIG) [Base: single camera]
│  │  │  └─ F-CAM-4 (parent: CAM-CONFIG) [Premium: quad camera]
│  ├─ F-RADAR (parent: F-SENSORS)
│  │  ├─ RADAR-TYPE (parent: F-RADAR, concrete: false, group: XOR)
│  │  │  ├─ F-RADAR-SR (parent: RADAR-TYPE) [Base: short-range]
│  │  │  └─ F-RADAR-LR (parent: RADAR-TYPE) [Premium: long-range]
│  └─ F-LIDAR (parent: F-SENSORS) [Premium only]
├─ F-ADAS-FUNC (parent: ROOT)
│  └─ FUNC-SUITE (parent: F-ADAS-FUNC, concrete: false, group: OR)
│     ├─ F-LDW (parent: FUNC-SUITE) [Base + Premium]
│     ├─ F-LKA (parent: FUNC-SUITE) [Premium only]
│     ├─ F-AEB (parent: FUNC-SUITE) [Base + Premium]
│     ├─ F-ACC (parent: FUNC-SUITE) [Premium only]
│     ├─ F-BSD (parent: FUNC-SUITE) [Premium only]
│     ├─ F-RCTA (parent: FUNC-SUITE) [Premium only]
│     └─ F-TSR (parent: FUNC-SUITE) [Premium only]
├─ F-HMI (parent: ROOT)
│  ├─ HMI-DISPLAY (parent: F-HMI, concrete: false, group: XOR)
│  │  ├─ F-HMI-CLUSTER (parent: HMI-DISPLAY) [Base: cluster]
│  │  └─ F-HMI-HUD (parent: HMI-DISPLAY) [Premium: HUD]
│  └─ F-HMI-HAPTIC (parent: F-HMI) [Premium: haptic feedback]
└─ F-ECU (parent: ROOT)
   └─ ECU-PROC (parent: F-ECU, concrete: false, group: XOR)
      ├─ F-ECU-SINGLE (parent: ECU-PROC) [Base: single-core]
      └─ F-ECU-MULTI (parent: ECU-PROC) [Premium: multi-core]
```

**Variability Groups**:
- **XOR groups** (4): Exactly one child must be selected
  - Camera: F-CAM-1 OR F-CAM-4
  - Radar: F-RADAR-SR OR F-RADAR-LR
  - HMI Display: F-HMI-CLUSTER OR F-HMI-HUD
  - ECU Processor: F-ECU-SINGLE OR F-ECU-MULTI

- **OR groups** (1): Multiple children can be selected
  - ADAS Functions: Any combination of LDW, LKA, AEB, ACC, BSD, RCTA, TSR

**Tree Statistics**:
- Root nodes: 1 (ROOT)
- Maximum depth: 4 levels
- Total features: 29 (including ROOT, variability groups, and concrete features)
- Concrete features: 20 (selectable in configurations)
- Abstract features: 9 (structural/grouping only)

---

### 4. `satisfy` - Block Definition → Requirement(s) (5 links, 13 requirement refs)

**Purpose**: Links architecture blocks to requirements they implement/satisfy.

**Cardinality**: Many-to-Many (one block can satisfy multiple requirements, one requirement can be satisfied by multiple blocks)

**Validation**:
- RULE 7: If enabled, requirements without `derives_from` must have incoming `satisfy` links
- All target requirements must exist

**Examples**:
```typst
// Top-level system block satisfies multiple requirements
#block_definition(
  "BLK-ADAS-SYSTEM",
  title: "ADAS System",
  // ... properties, operations, ports, parts ...
  links: (satisfy: ("REQ-SENS-001", "REQ-ADAS-001", "REQ-HMI-001", "REQ-ECU-001"))
)[
  Top-level ADAS system comprising perception, control, HMI, and ECU.
]

// Perception module satisfies sensor requirements
#block_definition(
  "BLK-PERCEPTION",
  title: "Perception Module",
  // ... properties ...
  links: (satisfy: ("REQ-SENS-001", "REQ-CAM-001", "REQ-RAD-001"))
)[
  Sensor data fusion and environmental perception.
]

// ADAS controller satisfies function requirements
#block_definition(
  "BLK-ADAS-CTRL",
  title: "ADAS Controller",
  // ... properties ...
  links: (satisfy: ("REQ-LDW-001", "REQ-LKA-001", "REQ-AEB-001", "REQ-ACC-001"))
)[
  ADAS function arbitration and decision-making.
]
```

**Satisfaction Matrix**:

| Block | Requirements Satisfied | Count |
|-------|------------------------|-------|
| BLK-ADAS-SYSTEM | REQ-SENS-001, REQ-ADAS-001, REQ-HMI-001, REQ-ECU-001 | 4 |
| BLK-PERCEPTION | REQ-SENS-001, REQ-CAM-001, REQ-RAD-001 | 3 |
| BLK-ADAS-CTRL | REQ-LDW-001, REQ-LKA-001, REQ-AEB-001, REQ-ACC-001 | 4 |
| BLK-HMI-CTRL | REQ-HMI-001, REQ-CLUSTER-001 | 2 |
| BLK-ECU | REQ-ECU-001, REQ-COMM-001 | 2 |

**Coverage Analysis**:
- Total unique requirements satisfied: 11
- Total requirements in model: 29
- Top-level requirements with satisfy links: 11 out of 25 (44%)
- Derived requirements (should NOT have satisfy): 4 (correctly not satisfied by blocks)

---

### 5. `trace` - Test Case → Requirement(s) (6 links, 13 requirement refs)

**Purpose**: Links test cases to requirements they verify/validate.

**Cardinality**: Many-to-Many (one test can verify multiple requirements, one requirement can be verified by multiple tests)

**Validation**:
- RULE 4: Use cases (and test cases) should trace to requirements
- All target requirements must exist

**Examples**:
```typst
// Test verifies multiple requirements
#test_case("TC-LDW-001",
  title: "Lane Departure Warning - Unintended Drift",
  tags: (type: "functional", asil: "B"),
  links: (trace: ("REQ-LDW-001", "REQ-LDW-002"))
)[
  Verifies LDW activates correctly and uses proper modality.
]

// Test verifies derived requirements for AEB
#test_case("TC-AEB-001",
  title: "AEB - Stationary Vehicle at 50 km/h",
  tags: (type: "safety-critical", asil: "D"),
  links: (trace: ("REQ-AEB-001", "REQ-AEB-002"))
)[
  Verifies AEB prevents collision with proper timing.
]

// Integration test verifies sensor fusion
#test_case("TC-PERC-001",
  title: "Sensor Fusion - Camera + Radar Detection",
  tags: (type: "integration", asil: "D"),
  links: (trace: ("REQ-SENS-001", "REQ-CAM-001", "REQ-RAD-001"))
)[
  Verifies sensor fusion correctly combines multiple sensors.
]
```

**Test Coverage Matrix**:

| Test Case | Requirements Verified | Test Type | ASIL |
|-----------|----------------------|-----------|------|
| TC-LDW-001 | REQ-LDW-001, REQ-LDW-002 | Functional | B |
| TC-AEB-001 | REQ-AEB-001, REQ-AEB-002 | Safety-Critical | D |
| TC-ACC-001 | REQ-ACC-001, REQ-ACC-002 | Functional | B |
| TC-LKA-001 | REQ-LKA-001, REQ-LKA-002 | Functional | C |
| TC-PERC-001 | REQ-SENS-001, REQ-CAM-001, REQ-RAD-001 | Integration | D |
| TC-HMI-001 | REQ-HMI-001, REQ-CLUSTER-001 | Functional | B |

**Coverage Statistics**:
- Total requirements traced by tests: 11 unique requirements
- Requirements with test coverage: 11 out of 29 (38%)
- Safety-critical tests (ASIL C/D): 3 tests covering 7 requirements
- Test methods: HIL (5), Proving Ground (1), Manual (1)

---

## Traceability Validation Rules

### RULE 1: Requirement Links
**Status**: ✅ All 29 requirements have either `belongs_to` (25) or `derives_from` (4)

**Validated**:
- 25 top-level requirements → features via `belongs_to`
- 4 derived requirements → parent requirements via `derives_from`
- No requirement has both (mutually exclusive)
- No requirement has neither (would fail validation)

### RULE 2: Single Root Feature
**Status**: ✅ Exactly one feature (ROOT) has no parent

**Validated**:
- ROOT feature has no parent attribute
- All other 28 features have valid parent attributes

### RULE 3: Valid Feature Parents
**Status**: ✅ All 28 non-root features have valid parent references

**Parent Chain Validation**:
- All parent IDs resolve to existing features
- No circular references
- All paths lead back to ROOT

### RULE 4: Use Case Traces
**Status**: ✅ All 6 test cases trace to requirements

**Note**: Model uses test cases instead of use cases for behavioral validation

### RULE 5: Requirement Allocation
**Status**: ⚠️ Partial (not enforced in this model)

**Current State**:
- 11 requirements have `satisfy` links from blocks
- 18 requirements do not have allocation links
- Validation rule not strictly enforced (would be in production system)

### RULE 6: Allocation vs Derivation
**Status**: ✅ No conflicts detected

**Validated**:
- Derived requirements (4) do NOT have `satisfy` links (correct)
- Top-level requirements CAN have `satisfy` links (11 do, 14 don't)

### RULE 7: Requirement Satisfaction
**Status**: ⚠️ Partial (optional in this example)

**Current State**:
- When enabled, checks that non-derived requirements have `satisfy` links
- Currently 44% of top-level requirements have satisfaction links
- In production, would require 100% coverage

---

## Link Direction and Cardinality Summary

| Link Type | Direction | Cardinality | Navigable | Inverse Link |
|-----------|-----------|-------------|-----------|--------------|
| `belongs_to` | Req → Feature | N:1 | Forward | (computed) |
| `derives_from` | Req → Req | N:1 | Forward | (computed) |
| `parent` | Feature → Feature | N:1 | Forward | `children` (computed) |
| `satisfy` | Block → Req(s) | N:M | Forward | `satisfied_by` (computed) |
| `trace` | Test → Req(s) | N:M | Forward | `traced_by` (computed) |

**Navigation**:
- All links are stored in forward direction (source → target)
- Inverse navigation is computed on-demand by validation plugin
- Traceability matrices can be generated in both directions

---

## Product Configuration Impact

### Base Configuration (CFG-BASE) - 12 features selected
- **Features**: F-SENSORS, F-CAMERA, F-CAM-1, F-RADAR, F-RADAR-SR, F-ADAS-FUNC, F-LDW, F-AEB, F-HMI, F-HMI-CLUSTER, F-ECU, F-ECU-SINGLE
- **Requirements (via belongs_to)**: 12 feature requirements + their children
- **Architecture**: All 5 blocks active (but with reduced functionality)
- **Tests**: All 6 tests run (LDW, AEB tests required; others pass with reduced scope)

### Premium Configuration (CFG-PREMIUM) - 18 features selected
- **Features**: All base features + F-CAM-4, F-RADAR-LR, F-LIDAR, F-LKA, F-ACC, F-BSD, F-RCTA, F-TSR, F-HMI-HUD, F-HMI-HAPTIC, F-ECU-MULTI
- **Requirements**: All 29 requirements active
- **Architecture**: All 5 blocks with full functionality
- **Tests**: All 6 tests run with full coverage

**Configuration Validation**:
- XOR constraints checked: Only one option from each XOR group selected
- OR constraints checked: At least one ADAS function selected
- Mandatory features: Sensors, HMI, ECU present in both configs

---

## Recommendations

### For Production Use

1. **Increase Test Coverage**: Currently 38% requirement coverage by tests
   - Goal: 100% for safety-critical requirements (ASIL C/D)
   - Add tests for: BSD, RCTA, TSR, processor variants, display variants

2. **Complete Architecture Links**: Currently 44% requirements have `satisfy` links
   - Add allocation links for all 25 top-level requirements
   - Enable RULE 5 validation (strict allocation checking)

3. **Add Use Cases**: Model has test cases but no behavioral use cases
   - Add use case scenarios for driver interactions
   - Link use cases to requirements via `trace` links

4. **Expand Derived Requirements**: Only 4 derived requirements currently
   - Decompose high-level requirements further
   - Create requirement hierarchy depth of 3-4 levels

5. **Add Cross-References**:
   - Block-to-block `depends_on` links
   - Test-to-test `prerequisite` links
   - Requirement-to-requirement `conflicts_with` links

---

## Statistics Summary

| Metric | Count | Percentage |
|--------|-------|------------|
| Total Elements | 70 | - |
| Features | 29 | 41% |
| Requirements | 29 | 41% |
| Blocks | 5 | 7% |
| Test Cases | 6 | 9% |
| Configurations | 2 | 3% |
| **Total Links** | **68** | **-** |
| belongs_to | 25 | 37% |
| derives_from | 4 | 6% |
| parent | 28 | 41% |
| satisfy | 5 (→13 refs) | 7% |
| trace | 6 (→13 refs) | 9% |

**Traceability Completeness**:
- Requirements with feature link: 100% (25 top + 4 derived)
- Requirements with architecture link: 44% (11/25 top-level)
- Requirements with test link: 38% (11/29 total)
- Features with parent link: 97% (28/29, ROOT excluded)
- End-to-end traceability: ~38% (Feature → Req → Block → Test)

---

## Visualization Opportunities

The link structure supports generation of:
- **Feature Trees**: Hierarchical visualization with XOR/OR groups
- **Requirements Hierarchy**: Top-level → derived decomposition
- **Allocation Matrices**: Requirements × Blocks
- **Verification Matrices**: Requirements × Tests
- **Impact Analysis**: Change propagation via links
- **Coverage Reports**: Gaps in satisfy/trace links

---

*Generated from ADAS Full Model Example*
*Model Version: 1.0*
*Analysis Date: 2026-02-04*
