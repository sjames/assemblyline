// sysml.typ — Reusable SysML palette for CeTZ 0.4.2 (docs-compliant)
#import "@preview/cetz:0.4.2": canvas, draw

/// SysML Block — OMG SysML 1.6 compliant (header tint, compartments, tags)
/// Positions via `at:` (defaults to (0,0))
#let block(
  name,
  at: (0, 0),
  stereotype: none,          // e.g. "block", "interfaceBlock", "system"
  properties: (),            // array of strings: ("speed : km/h", "mass : kg = 1500")
  operations: (),            // array of strings: ("accelerate(power : kW)", "brake()")
  width: 180pt,
  tags: ()                   // array of strings: ("{incomplete}", "{abstract}")
) = {
  // Tuned constants (per docs: stroke defaults to black, 1pt implied)
  let header-height = 28pt
  let compartment-height = 40pt
  let compartment-inset = 8pt
  let line-stroke = (thickness: 0.8pt)
  let prop-height = if properties.len() > 0 { compartment-height } else { 0pt }
  let op-height = if operations.len() > 0 { compartment-height } else { 0pt }
  let total-height = header-height + prop-height + op-height

  // Compartment content builders
  let header-content = {
    let name-part = text(weight: "bold", size: 11pt, name)
    let stereo-part = if stereotype != none {
      linebreak() + text(weight: "regular", size: 9.5pt, "«" + stereotype + "»")
    } else { "" }
    let tags-part = if tags.len() > 0 {
      h(4pt) + tags.map(t => super[#{t}]).join()
    } else { "" }
    name-part + stereo-part + tags-part
  }

  let props-content = if properties.len() > 0 {
    properties.map(p => [- #p]).join(linebreak())
  } else { none }

  let ops-content = if operations.len() > 0 {
    operations.map(o => [+ #o]).join(linebreak())
  } else { none }

  // Draw the block as a named group (docs: enables anchor refs like "block-Car.east")
  draw.group(name: "block-" + name.replace(regex("[^a-zA-Z0-9]"), ""), {
    draw.translate(at)

    // Main background rect (docs: radius as length or dict for per-corner)
    draw.rect(
      (0, 0),
      (width, total-height),
      radius: 4pt,
      stroke: (thickness: 1.6pt),
      fill: white,
      name: "bg"
    )

    // Header tint rect (docs: partial radius for top-only rounding)
    draw.rect(
      (0, 0),
      (width, header-height),
      radius: (top-left: 4pt, top-right: 4pt),
      fill: rgb("#f8f8ff"),
      stroke: none
    )

    // Header content (docs: align(center + horizon) for precise centering)
    draw.content(
      (width / 2, header-height / 2),
      align(center + horizon, header-content),
      padding: 6pt
    )

    // Compartments (docs: line() for simple horizontals)
    let y = header-height
    if props-content != none {
      draw.line((0, y), (width, y), stroke: line-stroke)
      draw.content(
        (compartment-inset, y + (compartment-height / 2)),
        align(left, text(size: 9.5pt, props-content)),
        padding: (top: 6pt, bottom: 6pt, left: 0pt)
      )
      y += compartment-height
    }
    if ops-content != none {
      draw.line((0, y), (width, y), stroke: line-stroke)
      draw.content(
        (compartment-inset, y + (compartment-height / 2)),
        align(left, text(size: 9.5pt, ops-content)),
        padding: (top: 6pt, bottom: 6pt, left: 0pt)
      )
    }

    // Standard anchors (docs: relative to group bounds; south at total-height)
    let south-y = total-height
    draw.anchor("center", (width / 2, total-height / 2))
    draw.anchor("north", (width / 2, 0))
    draw.anchor("south", (width / 2, south-y))
    draw.anchor("west", (0, total-height / 2))
    draw.anchor("east", (width, total-height / 2))
    draw.anchor("north-west", (0, 0))
    draw.anchor("north-east", (width, 0))
    draw.anchor("south-west", (0, south-y))
    draw.anchor("south-east", (width, south-y))
  })
}

/// Variant: Value Type (rounder corners, unit tag)
#let value-type(
  name,
  at: (0, 0),
  properties: (),
  unit: none
) = {
  let tags = if unit != none { ( "[" + str(unit) + "]" ) } else { () }
  block(
    name,
    at: at,
    stereotype: "valueType",
    properties: properties,
    tags: tags
  )
  // Post-group: Override radius (docs: use ctx in group for dynamic styling if needed)
}

/// Variant: Interface Block (no properties, interface stereo)
#let interface-block(
  name,
  at: (0, 0),
  operations: ()
) = {
  block(
    name,
    at: at,
    stereotype: "interface",
    operations: operations
  )
}