# Feature Model Visual Notation Reference

Quick reference for the FeatureIDE-style feature model diagram notation.

## Feature Nodes

### Selected Feature (Concrete)
```
┌────────────────┐
│  Feature Name  │  ← Green background (#d4edda)
└────────────────┘     Green border (#28a745)
                       Bold text
```

### Unselected Feature (Concrete)
```
┌────────────────┐
│  Feature Name  │  ← Gray background (#f8f9fa)
└────────────────┘     Gray border (#6c757d)
                       Normal text, gray color
```

### Abstract Feature
```
┌ ─ ─ ─ ─ ─ ─ ─ ┐
│  Feature Name  │  ← Dashed border
└ ─ ─ ─ ─ ─ ─ ─ ┘     Italic text
                      Cannot be directly selected
```

## Connection Types

### Mandatory Feature
```
Parent ───●─── Child

● = Filled black circle
    Child must be included if parent is included
```

### Optional Feature
```
Parent ───○─── Child

○ = Empty circle with black border
    Child may or may not be included
```

## Group Relationships

### XOR Group (Alternative)
```
            ┌─○─ Option A
            │
Parent ──⊕──┼─○─ Option B
            │
            └─○─ Option C

⊕ = Arc with filled wedge
    Exactly ONE option must be selected
    Mutually exclusive
```

### OR Group (Inclusive)
```
            ┌─○─ Option A
            │
Parent ──⊙──┼─○─ Option B
            │
            └─○─ Option C

⊙ = Arc with filled triangle
    ONE OR MORE options must be selected
    Multiple selection allowed
```

## Complete Example

```
                                        ┌─○─[Biometric]   (gray, optional)
                                        │
[ROOT]──●──[Authentication]──⊕──────────┼─○─[Password]    (gray, optional)
  │         (abstract)                  │
  │                                     └─●─[Two-Factor]  (green, mandatory)
  │
  │                                     ┌─●─[Temperature] (green, selected)
  │                                     │
  ├─●──[Sensors]──⊙───────────────────┼─○─[Motion]      (gray, not selected)
  │     (abstract)                      │
  │                                     └─○─[Camera]      (gray, not selected)
  │
  │
  └─●──[User Interface]───○──[Mobile App] (green, selected)
        (abstract)
```

## Color Coding

| Color | Hex Code | Meaning |
|-------|----------|---------|
| Green fill | `#d4edda` | Feature selected in configuration |
| Green border | `#28a745` | Feature selected in configuration |
| Green text | `#155724` | Feature selected in configuration |
| Gray fill | `#f8f9fa` | Feature not selected |
| Gray border | `#6c757d` | Feature not selected |
| Gray text | `#6c757d` | Feature not selected |
| Black fill | `#000000` | Mandatory indicator, group decorators |
| White fill | `#ffffff` | Optional indicator |

## Border Styles

| Style | Meaning |
|-------|---------|
| Solid line | Concrete feature (can be selected) |
| Dashed line | Abstract feature (structural only) |

## Text Styles

| Style | Meaning |
|-------|---------|
| **Bold** | Selected feature |
| Normal | Unselected concrete feature |
| *Italic* | Abstract feature |

## Layout Direction

```
LEFT (Root)  →  RIGHT (Leaves)

Features are arranged horizontally:
- Root feature on the LEFT
- Tree grows to the RIGHT
- Siblings stacked VERTICALLY
```

## Feature Properties

### Concrete vs Abstract

**Concrete features:**
- Can be directly selected in a configuration
- Solid border
- Normal or bold text

**Abstract features:**
- Structural grouping only
- Cannot be directly selected
- Dashed border
- Italic text
- Often have a group type (XOR/OR)

### Group Types

**None** (default)
- No special group relationship
- Each child is independent

**XOR** (Exclusive-OR)
- Exactly one child must be selected
- Shown with ⊕ arc and filled wedge

**OR** (Inclusive-OR)
- One or more children must be selected
- Shown with ⊙ arc and filled triangle

## Legend Symbols

When `show-legend: true`, the diagram includes:

```
Legend:
● Mandatory | ○ Optional |
⊕ XOR Group (one must be selected) |
⊙ OR Group (one or more) |
[Selected] | [Unselected] | [Abstract]
```

## Practical Tips

### Reading a Feature Model

1. **Start at the root** (leftmost feature)
2. **Follow mandatory connections** (●) - these must be included
3. **Check optional connections** (○) - these are choices
4. **Look for group arcs** (⊕/⊙) - special selection rules
5. **Check selection status** (green = selected, gray = not)

### Understanding Configurations

- **Green features** = Selected in this configuration
- **Gray features** = Not selected (but available)
- **All paths from root to selected leaves should be green**

### Identifying Variability Points

- **XOR groups (⊕)** = Major alternatives (e.g., authentication methods)
- **OR groups (⊙)** = Feature bundles (e.g., sensor packages)
- **Optional features (○)** = Individual choices

## Quick Reference Table

| Element | Symbol | Meaning |
|---------|--------|---------|
| Mandatory child | ● | Must include if parent selected |
| Optional child | ○ | May include if parent selected |
| XOR group | ⊕ | Pick exactly one alternative |
| OR group | ⊙ | Pick one or more options |
| Selected | Green | Included in configuration |
| Unselected | Gray | Not in configuration |
| Abstract | Dashed/Italic | Structural grouping |
| Concrete | Solid/Normal | Can be selected |

## Example Interpretation

Given this model:
```
[ROOT]──●──[Feature A]──⊕──┬─○─[Option 1]
                           └─○─[Option 2]
```

**Reading:**
1. ROOT is mandatory (it's the root)
2. Feature A is mandatory if ROOT is selected (● connection)
3. Feature A has an XOR group (⊕)
4. Either Option 1 OR Option 2 must be selected (but not both)
5. Both options are optional at their connection (○)

## Validation Rules

When viewing a configuration:

✅ **Valid:**
- Green path from root to each selected leaf
- All mandatory features (●) are selected
- XOR groups have exactly one selection
- OR groups have at least one selection

❌ **Invalid:**
- Selected feature with unselected mandatory parent
- XOR group with 0 or >1 selections
- OR group with 0 selections
- Unselected features that are mandatory

---

*For detailed usage instructions, see `FEATURE_MODEL_VISUALIZATION.md`*
