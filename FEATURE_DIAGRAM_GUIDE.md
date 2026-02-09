# Feature Model Diagram Visualization Guide

This guide explains how to use the `#feature-model-diagram()` function to visualize feature models in AssemblyLine.

## Overview

The feature model diagram provides a FeatureIDE-style horizontal tree layout with support for:
- **XOR and OR groups** with proper notation
- **Configuration highlighting** (selected features shown in green)
- **Mandatory/optional relationships** (filled/empty circles)
- **Flexible display options** (hide root, limit depth, scale)

## Function Signature

```typst
#feature-model-diagram(
  root: "ROOT",                    // Starting feature ID
  config: none,                    // Configuration ID to highlight
  registry-state: __registry,      // Required: registry state
  active-config-state: __active-config,  // Optional: active config state
  show-legend: true,               // Show/hide legend
  show-root: true,                 // Show/hide root node
  scale-factor: 100%,              // Scale diagram (e.g., 70% to shrink)
  max-depth: none,                 // Maximum levels to show (none = unlimited)
)
```

## Parameters

### `root: "FEATURE-ID"` (required)
- The feature to use as the starting point
- Can be any feature in the model, not just the root
- Useful for focusing on specific subtrees

**Examples:**
```typst
root: "ROOT"           // Start from root
root: "F-ADAS"         // Start from ADAS subtree
root: "F-SENSORS"      // Start from sensors subtree
```

### `config: "CONFIG-ID"` (optional)
- Configuration to highlight in the diagram
- Selected features appear in green with bold text
- Unselected features appear in gray
- If `none`, all features shown with equal styling

**Examples:**
```typst
config: "CFG-BASE"     // Highlight BASE configuration
config: "CFG-PREMIUM"  // Highlight PREMIUM configuration
config: none           // No highlighting
```

### `show-root: true|false` (default: `true`)
- Controls whether the root feature is displayed
- Setting to `false` saves horizontal space
- When `false`, starts directly from the root's children

**Use cases:**
- `show-root: true` - Default, shows complete hierarchy
- `show-root: false` - Saves space, focuses on child features

**Example:**
```typst
// With root node (default)
#feature-model-diagram(
  root: "ROOT",
  show-root: true,
  registry-state: __registry
)

// Without root node (space-saving)
#feature-model-diagram(
  root: "ROOT",
  show-root: false,
  registry-state: __registry
)
```

### `scale-factor: N%` (default: `100%`)
- Scales the entire diagram by the specified percentage
- Values less than 100% shrink the diagram
- Values greater than 100% enlarge the diagram
- Useful for fitting large models on a page

**Examples:**
```typst
scale-factor: 100%     // Normal size
scale-factor: 70%      // Shrink to 70% (fits more on page)
scale-factor: 50%      // Shrink to 50% (very compact)
scale-factor: 150%     // Enlarge to 150% (for presentations)
```

### `max-depth: N` (default: `none`)
- Limits the number of levels to display
- Depth is counted from the starting feature
- `none` means unlimited depth (show all descendants)
- `1` shows only the root
- `2` shows root + direct children
- `3` shows root + children + grandchildren, etc.

**Depth counting with `show-root: true`:**
```
max-depth: 1  →  ROOT
max-depth: 2  →  ROOT + Level 1
max-depth: 3  →  ROOT + Level 1 + Level 2
```

**Depth counting with `show-root: false`:**
```
max-depth: 1  →  Level 1 only
max-depth: 2  →  Level 1 + Level 2
max-depth: 3  →  Level 1 + Level 2 + Level 3
```

**Examples:**
```typst
max-depth: none        // Show all levels (default)
max-depth: 2           // Show only 2 levels
max-depth: 3           // Show only 3 levels
```

### `show-legend: true|false` (default: `true`)
- Controls whether the legend is displayed below the diagram
- Legend explains symbols: ● Mandatory, ○ Optional, ⊕ XOR, ⊙ OR

## Common Use Cases

### 1. Complete Feature Model Overview
Show the entire feature model with all details:

```typst
#feature-model-diagram(
  root: "ROOT",
  config: "CFG-BASE",
  registry-state: __registry,
  show-root: true,
  show-legend: true
)
```

### 2. Space-Saving Display
Hide the root node to save horizontal space:

```typst
#feature-model-diagram(
  root: "ROOT",
  config: "CFG-BASE",
  registry-state: __registry,
  show-root: false,     // Saves space
  show-legend: true
)
```

### 3. Scaled to Fit Page
Shrink large diagrams to fit on a single page:

```typst
#feature-model-diagram(
  root: "ROOT",
  config: "CFG-BASE",
  registry-state: __registry,
  scale-factor: 60%,    // Shrink to 60%
  show-legend: true
)
```

### 4. High-Level Overview (Limited Depth)
Show only top-level features for executive summary:

```typst
#feature-model-diagram(
  root: "ROOT",
  registry-state: __registry,
  max-depth: 2,         // Only ROOT + Level 1
  show-legend: true
)
```

### 5. Focus on Specific Subtree
Display only a portion of the feature model:

```typst
#feature-model-diagram(
  root: "F-ADAS",       // Start from ADAS feature
  config: "CFG-BASE",
  registry-state: __registry,
  show-root: true,
  show-legend: true
)
```

### 6. Detailed Subtree View
Focus on a subsystem with limited depth:

```typst
#feature-model-diagram(
  root: "F-SENSORS",    // Start from sensors
  max-depth: 3,         // Show 3 levels
  registry-state: __registry,
  show-root: true,
  show-legend: true
)
```

### 7. Compact Subtree (All Three Features Combined)
Maximum space efficiency:

```typst
#feature-model-diagram(
  root: "F-ADAS",       // Start from subtree
  config: "CFG-BASE",
  registry-state: __registry,
  show-root: false,     // Hide root
  max-depth: 3,         // Limit depth
  scale-factor: 70%,    // Scale down
  show-legend: true
)
```

### 8. Multiple Configurations Comparison
Show different configurations side-by-side:

```typst
= Configuration Comparison

== Base Configuration
#feature-model-diagram(
  root: "ROOT",
  config: "CFG-BASE",
  registry-state: __registry,
  scale-factor: 70%
)

== Premium Configuration
#feature-model-diagram(
  root: "ROOT",
  config: "CFG-PREMIUM",
  registry-state: __registry,
  scale-factor: 70%
)
```

## Visual Elements

### Feature Nodes
- **Rectangle**: Feature box
- **Solid border**: Concrete feature (can be selected)
- **Dashed border**: Abstract feature (grouping only)
- **Green background**: Selected in configuration
- **Gray background**: Not selected

### Connections
- **Filled circle (●)**: Mandatory relationship
- **Empty circle (○)**: Optional relationship
- **Solid line**: Parent-child connection

### Group Notation
- **Vertical arc with filled wedge (⊕)**: XOR group (exactly one must be selected)
- **Vertical arc with filled triangle (⊙)**: OR group (one or more must be selected)

## Tips and Best Practices

1. **Start with limited depth** for complex models to understand high-level structure
2. **Use `show-root: false`** when the root node adds no information
3. **Scale down large diagrams** rather than splitting across pages
4. **Combine all three features** for maximum compactness:
   - Hide root (`show-root: false`)
   - Limit depth (`max-depth: 3`)
   - Scale down (`scale-factor: 70%`)
5. **Create focused views** by starting from subsystem features
6. **Use landscape orientation** for wide diagrams:
   ```typst
   #set page(width: 297mm, height: 210mm)  // A4 landscape
   ```

## Examples

See the following example files:
- `examples/feature-diagram-test.typ` - Basic scaling and root hiding
- `examples/feature-subtree-demo.typ` - Comprehensive depth limiting examples
- `examples/full-model/feature-model-visualization-demo.typ` - Real-world ADAS system

## Troubleshooting

### Diagram too wide for page
**Solution:** Use `scale-factor` to shrink:
```typst
scale-factor: 60%  // or lower
```

### Too much detail
**Solution:** Limit depth:
```typst
max-depth: 2  // or 3
```

### Unnecessary root node taking space
**Solution:** Hide the root:
```typst
show-root: false
```

### Want to focus on specific subsystem
**Solution:** Change the root parameter:
```typst
root: "F-SUBSYSTEM"  // Start from subsystem
```
