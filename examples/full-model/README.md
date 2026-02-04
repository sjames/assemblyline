# Full Model Example - Automotive ADAS System

This example demonstrates a complete end-to-end automotive product-line engineering specification using the AssemblyLine modelling language. The domain is Advanced Driver Assistance Systems (ADAS) for passenger vehicles.

## Model Contents

1. **Feature Model** (`features/`)
   - ADAS product-line features with variability (XOR/OR groups)
   - Safety requirements linked to features (ASIL-rated per ISO 26262)
   - Cost, certification, and regulation metadata
   - Features: Sensors, ADAS Functions, HMI, ECU Platform

2. **System Architecture** (`architecture/`)
   - SysML block definitions for ADAS system
   - System decomposition (Perception, ADAS Controller, HMI, ECU Platform)
   - Parts, ports, and connectors showing data flow
   - Traceability to safety requirements

3. **Test Specification** (`tests/`)
   - Safety-critical test cases (Euro NCAP, UN regulations)
   - HIL (Hardware-in-Loop) and proving ground tests
   - ASIL-rated test procedures
   - Coverage of key functional safety requirements

4. **Configurations** (`configurations/`)
   - Two product variants: Base Safety Package and Premium Package
   - Different sensor suites and ADAS function sets
   - Market-specific metadata (Euro NCAP rating, UN regulations)

5. **Products** (`products/`)
   - Product-specific top-level files for each configuration
   - Each compiles to a complete product specification PDF
   - Integrated validation (traceability, safety, configuration)

## Product Variants

### Base Safety Package (850 EUR)
- Single forward-facing camera
- Short-range radar (80m)
- Lane Departure Warning (LDW) - UN R130
- Automatic Emergency Braking (AEB) - UN R152
- Instrument cluster HMI
- Single-core ASIL-B processor
- **Target**: B/C-segment vehicles, Euro NCAP 4-star minimum

**Compile**: `typst compile products/product-base/main.typ`

### Premium Package (3200 EUR)
- Quad-camera surround view (360°)
- Long-range radar (250m) + LiDAR
- Full ADAS suite: LDW, LKA, AEB, ACC, BSD, RCTA, TSR
- Head-Up Display with AR lane guidance
- Haptic steering wheel feedback
- Quad-core ASIL-D processor
- **Target**: D/E-segment luxury vehicles, Euro NCAP 5-star, Level 2+ automation

**Compile**: `typst compile products/product-premium/main.typ`

## Safety and Validation

Each product variant includes:
- **Link validation**: All traceability links verified
- **Specification validation**: Requirements structure, feature hierarchy, allocations
- **Configuration validation**: Feature selections respect XOR/OR constraints
- **Safety compliance**: ASIL levels, UN regulations, Euro NCAP requirements

Build fails immediately if validation errors detected, ensuring specification integrity.

## Traceability Chain

Complete end-to-end traceability:
- **Features → Top-Level Requirements** (`belongs_to` links)
- **Top-Level Requirements → Derived Requirements** (`derives_from` links)
- **Requirements → Architecture Blocks** (`satisfy` links)
- **Requirements → Test Cases** (`trace` links)
- **Configurations → Feature Selections** (`selected` arrays)

## Domain: Automotive ADAS

**Standards Compliance**:
- ISO 26262 (Functional Safety) - ASIL A/B/C/D ratings
- UN R152 (Automatic Emergency Braking)
- UN R130 (Lane Departure Warning)
- UN R157 (Automated Lane Keeping Systems)
- Euro NCAP (Safety Assessment Protocol)

**Automation Levels**:
- Base Package: SAE Level 1 (driver assistance)
- Premium Package: SAE Level 2+ (partial automation with hands-on supervision)

## File Organization

```
examples/full-model/
├── features/           # Feature model with ASIL-rated requirements
├── architecture/       # SysML blocks (perception, control, HMI, ECU)
├── tests/             # Safety-critical test specifications
├── configurations/    # Two product configurations
└── products/          # Product-specific specifications
    ├── product-base/      # Base safety package (compile here)
    └── product-premium/   # Premium package (compile here)
```

## Usage

1. **Compile Base Package**: `typst compile products/product-base/main.typ`
2. **Compile Premium Package**: `typst compile products/product-premium/main.typ`
3. **Export JSON**: `typst compile --input export-json=stdout products/product-base/main.typ`

Each compilation generates a complete product specification PDF with:
- Feature tree with selected features highlighted
- Requirements hierarchy with ASIL levels
- System architecture diagrams
- Test specifications
- Validation report (pass/fail)
