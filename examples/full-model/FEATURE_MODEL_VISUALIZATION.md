# Feature Model Visualization Guide

## Overview

The AssemblyLine library now includes a **FeatureIDE-style feature model diagram** that visualizes feature trees horizontally with professional notation.

## Features

✨ **Horizontal Layout** - Tree grows left-to-right (root on left)
🎨 **FeatureIDE-Compliant** - Uses standard feature modeling notation
⚙️ **Configuration Support** - Highlights selected/unselected features
📊 **Group Relationships** - Visual XOR/OR group indicators
🎯 **Abstract Features** - Distinguished with dashed borders and italics

## Visual Elements

### Feature Notation
- **Rectangle boxes** - Each feature shown as a styled rectangle
- **Green boxes** - Selected features in active configuration
- **Gray boxes** - Unselected features
- **Dashed borders** - Abstract features (cannot be directly selected)
- **Italic text** - Abstract feature names

### Connection Notation
- **● Filled circle** - Mandatory child feature
- **○ Empty circle** - Optional child feature

### Group Notation
- **⊕ XOR Group** - Arc with filled wedge (exactly one must be selected)
- **⊙ OR Group** - Arc with filled triangle (one or more must be selected)

## Usage

### Basic Usage

```typst
#import "@preview/assemblyline:1.0.0": *

// Define your features
#feature("Root", id: "ROOT", parent: none)[...]
#feature("Child", id: "CHILD", parent: "ROOT")[...]

// Visualize the feature model
#feature-model-diagram(
  root: "ROOT",
  registry-state: __registry,
  active-config-state: __active-config,
)
```

### With Configuration Highlighting

```typst
// Define a configuration
#config(
  "Premium Package",
  id: "CFG-PREMIUM",
  root_feature_id: "ROOT",
  selected: ("ROOT", "CHILD", "FEATURE-A"),
  tags: (market: "premium")
)

// Visualize with configuration
#feature-model-diagram(
  root: "ROOT",
  config: "CFG-PREMIUM",  // Highlight this configuration
  registry-state: __registry,
  active-config-state: __active-config,
  show-legend: true
)
```

### Single-Page Landscape Document

For presentations or posters, use landscape orientation:

```typst
#set page(
  width: 297mm,   // A4 landscape (or 420mm for A3)
  height: 210mm,  // A4 landscape (or 297mm for A3)
  margin: 1cm
)

#feature-model-diagram(
  root: "ROOT",
  config: "CFG-PREMIUM",
  registry-state: __registry,
  active-config-state: __active-config,
  show-legend: true
)
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `root` | string | `"ROOT"` | ID of the root feature to visualize |
| `config` | string \| none | `none` | Configuration ID to highlight |
| `registry-state` | state | *required* | Pass `__registry` state |
| `active-config-state` | state | *required* | Pass `__active-config` state |
| `show-legend` | bool | `true` | Show legend explaining symbols |

## Examples

See the following example files:

1. **`feature-model-visualization-demo.typ`** - Full demonstration with multiple configurations
2. **`feature-model-standalone.typ`** - Single-page template for quick visualization

## Compilation

```bash
# Compile the full demo (16 pages)
typst compile feature-model-visualization-demo.typ demo.pdf

# Compile standalone single-page
typst compile feature-model-standalone.typ standalone.pdf
```

## Comparison with Text-Based Tree

### Old: `#feature-tree()` (Vertical Text)
```
ROOT – Root Feature
  ● F-AUTH – Authentication
    ⊕ XOR-GROUP
      ○ F-BIO – Biometric
      ○ F-PWD – Password
```

### New: `#feature-model-diagram()` (Horizontal Graphical)
```
┌────────┐      ┌──────────────┐      ┌────────────┐
│  ROOT  │──●──→│ Authentication│──⊕──┼─○─→│ Biometric  │
└────────┘      └──────────────┘      ├─○─→│ Password   │
                                      └─────────────────
```

## Layout Algorithm

The diagram uses a **recursive tree layout** algorithm:

1. **Calculate subtree heights** - Determine vertical space needed
2. **Position parent nodes** - Centered vertically in their subtree
3. **Position child nodes** - Stacked vertically with spacing
4. **Draw connections** - Lines with mandatory/optional circles
5. **Draw group arcs** - XOR/OR decorators for grouped children

## Customization

### Layout Constants

Edit `packages/preview/assemblyline/main/lib/feature-diagram.typ`:

```typst
#let layout-defaults = (
  horizontal-spacing: 180pt,  // Parent-child distance
  vertical-spacing: 50pt,     // Sibling spacing
  node-width: 140pt,          // Feature box width
  node-height: 35pt,          // Feature box height
  connection-radius: 4pt,     // Circle size
  arc-offset: 15pt,           // Group arc distance
  font-size: 10pt,            // Feature name size
)
```

### Color Scheme

```typst
#let colors = (
  selected-fill: rgb("#d4edda"),      // Light green
  selected-stroke: rgb("#28a745"),     // Green
  unselected-fill: rgb("#f8f9fa"),    // Light gray
  unselected-stroke: rgb("#6c757d"),   // Gray
  // ...
)
```

## Implementation Details

- **Library**: CeTZ 0.4.2 (Canvas-based drawing)
- **Layout**: Recursive tree positioning algorithm
- **Rendering**: Custom shapes and connectors
- **State Management**: Typst state system for registry access

## Tips

1. **Large trees** - Use A3 landscape (420mm × 297mm) for models with many features
2. **Multiple configurations** - Create separate pages for each configuration
3. **Presentation mode** - Use standalone template for single-page posters
4. **Print quality** - Compile to PDF for high-quality vector output

## Troubleshooting

### Tree is cut off
- Increase page width (use A3 or custom dimensions)
- Reduce `horizontal-spacing` or `vertical-spacing`
- Split into multiple subtrees

### Text is too small
- Increase `font-size` in layout defaults
- Use larger page dimensions

### Features overlap
- Increase `vertical-spacing`
- Check for circular parent relationships

## Future Enhancements

Potential improvements for future versions:

- [ ] Auto-scaling to fit page
- [ ] Vertical orientation option
- [ ] Constraint indicators (requires/excludes)
- [ ] Cross-tree references
- [ ] Export to SVG
- [ ] Interactive HTML output
- [ ] Compact layout mode
- [ ] Feature attributes display
- [ ] Cost/effort annotations

## References

- FeatureIDE: https://featureide.github.io/
- Feature Modeling Notation: Czarnecki & Eisenecker (2000)
- SysML/UML: OMG Systems Modeling Language
