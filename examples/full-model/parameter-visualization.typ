// ADAS Parameter Visualization Demo
// Demonstrates parameter schemas, bindings, and constraints for the full ADAS model

#import "packages/preview/assemblyline/main/lib/lib.typ": *

// Include all model components (this executes the feature definitions)
#include "features/root.typ"
#include "features/sensors.typ"
#include "features/adas-functions.typ"
#include "features/hmi.typ"
#include "features/ecu.typ"
#include "configurations/configs.typ"

#set page(width: 210mm, height: 297mm, margin: 20mm)
#set text(size: 10pt)
#set heading(numbering: "1.")

#align(center)[
  #text(size: 18pt, weight: "bold")[ADAS System Parameter Report]
  #v(5mm)
  #text(size: 12pt)[Automotive Advanced Driver Assistance System]
  #v(2mm)
  #text(size: 10pt, fill: gray)[Configuration Parameter Analysis]
]

#v(10mm)

// =============================================================================
// SECTION 1: Parameter Schemas
// =============================================================================

#pagebreak()

= Parameter Schema Definitions

This section documents all configurable parameters in the ADAS system, including their types, valid ranges, and default values.

#v(5mm)

== Radar System Parameters

#render-parameter-schema("F-RADAR")

#v(5mm)

The radar system provides four configurable parameters that affect performance and resource usage:

- *Update Rate*: Controls the frequency of radar measurements. Higher rates provide more responsive tracking but require more processing power.

- *Angular Resolution*: Determines the minimum angular separation between two targets. Lower values (better resolution) enable more precise target localization.

- *Target Tracking*: When enabled, maintains persistent track IDs across measurement cycles, essential for predictive functions like ACC.

- *Processing Mode*: Balances latency, accuracy, and computational load. Fast mode prioritizes low latency, Accurate mode maximizes precision.

#pagebreak()

== Adaptive Cruise Control Parameters

#render-parameter-schema("F-ACC")

#v(5mm)

The ACC system offers five parameters that customize driving behavior:

- *Min/Max Speed*: Defines the operational speed range. Premium configurations extend the lower bound for stop-and-go traffic.

- *Default Time Gap*: Sets the initial following distance (in deciseconds). Range 1.0-3.0s balances safety and traffic flow.

- *Comfort Mode*: Determines acceleration/braking aggressiveness:
  - *Eco*: Gentle inputs, optimized for fuel efficiency
  - *Comfort*: Smooth operation for passenger comfort
  - *Sport*: Responsive dynamics for engaged driving

- *Stop-and-Go*: Enables full-speed-range operation including complete stops in traffic queues.

#pagebreak()

// =============================================================================
// SECTION 2: Configuration Bindings
// =============================================================================

= Configuration Parameter Bindings

This section shows how parameters are bound in different product configurations.

== Base Configuration (CFG-BASE)

The base configuration targets entry-level vehicles with cost-optimized sensor settings:

#render-parameter-bindings("CFG-BASE", show-defaults: true)

#v(5mm)

*Analysis*: The base configuration uses standard radar parameters suitable for basic ADAS functions (LDW, AEB). ACC is not included in this configuration, so ACC parameters are not bound.

#pagebreak()

== Premium Configuration (CFG-PREMIUM)

The premium configuration targets luxury vehicles with performance-optimized parameters:

#render-parameter-bindings("CFG-PREMIUM", show-defaults: true)

#v(5mm)

*Analysis*:
- Radar operates at 2× the base update rate (40Hz vs 20Hz) for improved responsiveness
- Angular resolution is improved (2° vs 3°) for better target separation
- Accurate processing mode provides maximum precision for Level 2+ ADAS
- ACC is configured with Sport mode and stop-and-go capability
- Shorter time gap (1.5s vs 1.8s default) suits premium customer expectations

#pagebreak()

// =============================================================================
// SECTION 3: Constraint Validation
// =============================================================================

= Feature Constraints

This section documents constraints that ensure parameter consistency and safety.

#render-all-constraints()

#v(5mm)

== Constraint Analysis

=== Radar System Constraints

*C1: High update rate processing requirements*
```constraint
F-RADAR.update_rate >= 50 => F-RADAR.processing_mode == Fast || !F-RADAR.enable_tracking
```

Rationale: Update rates ≥50Hz generate significant computational load. Either use Fast processing mode (lower latency, acceptable accuracy) or disable tracking (reduces per-frame computation).

*C2: Accurate mode resolution limit*
```constraint
F-RADAR.processing_mode == Accurate => F-RADAR.angular_resolution <= 3
```

Rationale: Accurate processing mode requires longer integration times. This is only feasible with moderate angular resolution (≤3°) to maintain real-time operation.

#pagebreak()

=== ACC System Constraints

*C1: Stop-and-go minimum speed*
```constraint
F-ACC.enable_stop_and_go => F-ACC.min_speed <= 30
```

Rationale: Stop-and-go functionality requires operation at very low speeds (including 0 km/h). The minimum speed threshold must be ≤30 km/h to enable this capability.

*C2: Sport mode maximum speed*
```constraint
F-ACC.comfort_mode == Sport => F-ACC.max_speed >= 160
```

Rationale: Sport mode is marketed for high-performance driving. A maximum speed of at least 160 km/h is required to support highway overtaking scenarios.

*C3: Eco mode time gap*
```constraint
F-ACC.comfort_mode == Eco => F-ACC.default_time_gap >= 20
```

Rationale: Eco mode prioritizes fuel efficiency. Longer following distances (≥2.0s) reduce unnecessary braking/acceleration cycles, improving fuel economy.

#pagebreak()

// =============================================================================
// SECTION 4: Constraint Summary Table
// =============================================================================

= Constraint Summary

#render-constraint-summary()

#pagebreak()

// =============================================================================
// SECTION 5: Configuration Comparison
// =============================================================================

= Configuration Comparison

Side-by-side comparison of parameter bindings across product lines:

#grid(
  columns: 2,
  column-gutter: 15mm,
  [
    == Base Configuration
    #text(size: 9pt)[
      #render-parameter-bindings("CFG-BASE", show-defaults: false)
    ]
  ],
  [
    == Premium Configuration
    #text(size: 9pt)[
      #render-parameter-bindings("CFG-PREMIUM", show-defaults: false)
    ]
  ]
)

#v(10mm)

== Key Differences

#table(
  columns: (1fr, 1fr, 1fr),
  align: (left, left, left),
  table.header([*Parameter*], [*Base*], [*Premium*]),

  [Radar Update Rate], [20 Hz], [40 Hz (2× faster)],
  [Radar Resolution], [3°], [2° (33% better)],
  [Radar Processing], [Balanced], [Accurate],
  [ACC Included], [No], [Yes],
  [ACC Comfort Mode], [—], [Sport],
  [ACC Stop-and-Go], [—], [Enabled],
)

#pagebreak()

// =============================================================================
// SECTION 6: Validation Status
// =============================================================================

= Parameter Validation Status

#import "packages/preview/assemblyline/main/lib/validation.typ": validate-parameters-wasm

#context {
  let registry = __registry.get()

  heading(level: 2)[CFG-BASE Validation]

  let base-result = validate-parameters-wasm(registry: registry, config-id: "CFG-BASE")

  if base-result.is_valid [
    #text(green)[✓ All parameters valid]

    - Features checked: #base-result.num_features_checked
    - Parameters checked: #base-result.num_parameters_checked
    - Message: #base-result.message
  ] else [
    #text(red)[✗ Validation failed]

    Errors:
    #for error in base-result.errors [
      - #error
    ]
  ]

  heading(level: 2)[CFG-PREMIUM Validation]

  let premium-result = validate-parameters-wasm(registry: registry, config-id: "CFG-PREMIUM")

  if premium-result.is_valid [
    #text(green)[✓ All parameters valid]

    - Features checked: #premium-result.num_features_checked
    - Parameters checked: #premium-result.num_parameters_checked
    - Message: #premium-result.message
  ] else [
    #text(red)[✗ Validation failed]

    Errors:
    #for error in premium-result.errors [
      - #error
    ]
  ]
}

#pagebreak()

// =============================================================================
// Summary
// =============================================================================

= Summary

This parameter report demonstrates AssemblyLine's parametric variability capabilities applied to a realistic ADAS system:

== Parameter Types Supported
- ✅ *Integer* parameters with range constraints (update rates, speeds, time gaps)
- ✅ *Boolean* parameters for feature toggles (tracking, stop-and-go)
- ✅ *Enum* parameters for mode selection (processing modes, comfort modes)

== Constraint Validation
- ✅ Cross-parameter implications (high rate requires fast processing)
- ✅ Mode-dependent limits (eco mode requires longer gaps)
- ✅ Feature dependencies (stop-and-go requires low min speed)

== Configuration Management
- ✅ Multiple product configurations with different parameter bindings
- ✅ Default value handling for parameters not explicitly bound
- ✅ WASM-based validation ensures constraint satisfaction

== Engineering Benefits
1. *Clear Documentation*: Parameter schemas serve as interface contracts
2. *Configuration Validation*: Catch invalid combinations at compile time
3. *Variability Management*: Explicit parameter spaces for product lines
4. *Traceability*: Parameter decisions linked to feature requirements

This approach scales to complex automotive systems with hundreds of configurable parameters across dozens of ECUs.
