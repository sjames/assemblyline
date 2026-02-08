// single-page-fitting-examples.typ
// Demonstrates different techniques to fit feature model on one page

#import "packages/preview/assemblyline/main/lib/lib.typ": *

// Include all features
#include "features/root.typ"
#include "features/sensors.typ"
#include "features/adas-functions.typ"
#include "features/hmi.typ"
#include "features/ecu.typ"
#include "configurations/configs.typ"

// ============================================================================
// METHOD 1: Use built-in scale-factor parameter
// ============================================================================
#set page(width: 297mm, height: 210mm, margin: 1cm)
#set text(font: "Arial", size: 11pt)

#align(center)[
  #text(size: 16pt, weight: "bold")[Method 1: Built-in Scale Parameter]
  #v(0.5em)
  #text(size: 10pt, fill: gray)[Use `scale-factor: 70%` to shrink diagram]
]

#v(1em)

#feature-model-diagram(
  root: "ROOT",
  config: "CFG-PREMIUM",
  registry-state: __registry,
  active-config-state: __active-config,
  show-legend: true,
  scale-factor: 70%,  // ← Shrink to 70% of original size
)

#pagebreak()

// ============================================================================
// METHOD 2: Larger page size (A3 landscape)
// ============================================================================
#set page(width: 420mm, height: 297mm, margin: 1cm)

#align(center)[
  #text(size: 16pt, weight: "bold")[Method 2: A3 Landscape Page]
  #v(0.5em)
  #text(size: 10pt, fill: gray)[420mm × 297mm page size]
]

#v(1em)

#feature-model-diagram(
  root: "ROOT",
  config: "CFG-PREMIUM",
  registry-state: __registry,
  active-config-state: __active-config,
  show-legend: true,
  scale-factor: 100%,  // Full size
)

#pagebreak()

// ============================================================================
// METHOD 3: Custom extra-wide page
// ============================================================================
#set page(width: 500mm, height: 250mm, margin: 0.8cm)

#align(center)[
  #text(size: 16pt, weight: "bold")[Method 3: Custom Wide Page]
  #v(0.5em)
  #text(size: 10pt, fill: gray)[500mm × 250mm custom dimensions]
]

#v(0.5em)

#feature-model-diagram(
  root: "ROOT",
  config: "CFG-PREMIUM",
  registry-state: __registry,
  active-config-state: __active-config,
  show-legend: true,
)

#pagebreak()

// ============================================================================
// METHOD 4: Aggressive scaling for complex models
// ============================================================================
#set page(width: 297mm, height: 210mm, margin: 0.5cm)

#align(center)[
  #text(size: 16pt, weight: "bold")[Method 4: Aggressive Scaling]
  #v(0.5em)
  #text(size: 10pt, fill: gray)[50% scale for very large models]
]

#v(0.5em)

#feature-model-diagram(
  root: "ROOT",
  config: "CFG-PREMIUM",
  registry-state: __registry,
  active-config-state: __active-config,
  show-legend: true,
  scale-factor: 50%,  // ← Very small for complex trees
)

#pagebreak()

// ============================================================================
// METHOD 5: Scale with Typst's scale() function (alternative)
// ============================================================================
#set page(width: 297mm, height: 210mm, margin: 1cm)

#align(center)[
  #text(size: 16pt, weight: "bold")[Method 5: External Scale Wrapper]
  #v(0.5em)
  #text(size: 10pt, fill: gray)[Wrap diagram in Typst's scale() function]
]

#v(1em)

// Alternative: use Typst's scale() to wrap the entire diagram
#scale(x: 65%, y: 65%, origin: top + left)[
  #feature-model-diagram(
    root: "ROOT",
    config: "CFG-PREMIUM",
    registry-state: __registry,
    active-config-state: __active-config,
    show-legend: false,  // Can hide legend when space is tight
  )
]

#pagebreak()

// ============================================================================
// METHOD 6: Portrait orientation with scaling (for tall trees)
// ============================================================================
#set page(width: 210mm, height: 297mm, margin: 1cm)  // Portrait

#align(center)[
  #text(size: 16pt, weight: "bold")[Method 6: Portrait with Rotation]
  #v(0.5em)
  #text(size: 10pt, fill: gray)[Rotate diagram 90° for portrait pages]
]

#v(1em)

// Rotate diagram to fit portrait orientation
#rotate(90deg, origin: top + left)[
  #box(width: 250mm)[
    #feature-model-diagram(
      root: "ROOT",
      config: "CFG-PREMIUM",
      registry-state: __registry,
      active-config-state: __active-config,
      show-legend: true,
      scale-factor: 80%,
    )
  ]
]

#pagebreak()

// ============================================================================
// SUMMARY PAGE
// ============================================================================
#set page(width: 210mm, height: 297mm, margin: 2cm)

= Summary: Techniques to Fit Diagrams on One Page

== Quick Reference

#table(
  columns: (auto, 1fr, auto, auto),
  [*Method*], [*Technique*], [*Best For*], [*Code*],

  [1], [Built-in scale], [Most models], [`scale-factor: 70%`],
  [2], [A3 landscape], [Medium trees], [`width: 420mm`],
  [3], [Custom page], [Specific needs], [`width: 500mm`],
  [4], [Aggressive scale], [Large trees], [`scale-factor: 50%`],
  [5], [External scale()], [Fine control], [`#scale(x: 65%)`],
  [6], [Portrait rotate], [Tall trees], [`#rotate(90deg)`],
)

== Recommended Approach

For most feature models, use *Method 1* (built-in scale):

```typst
#feature-model-diagram(
  root: "ROOT",
  config: "CFG-PREMIUM",
  registry-state: __registry,
  active-config-state: __active-config,
  scale-factor: 70%,  // Adjust as needed
)
```

== Finding the Right Scale

Try these values:
- `scale-factor: 100%` - Full size (may overflow)
- `scale-factor: 80%` - Slightly smaller
- `scale-factor: 70%` - Good for most models
- `scale-factor: 50%` - Very large models
- `scale-factor: 40%` - Extremely large models

== Tips

1. *Start with 70%* and adjust up/down
2. *Use A3* (420mm × 297mm) for presentation slides
3. *Hide legend* (`show-legend: false`) to save vertical space
4. *Reduce margins* (`margin: 0.5cm`) for more room
5. *Test print* before finalizing to check readability

== Page Size Quick Reference

```typst
// A4 landscape (standard)
#set page(width: 297mm, height: 210mm)

// A3 landscape (larger)
#set page(width: 420mm, height: 297mm)

// A2 landscape (poster size)
#set page(width: 594mm, height: 420mm)

// Custom ultra-wide
#set page(width: 600mm, height: 250mm)
```
