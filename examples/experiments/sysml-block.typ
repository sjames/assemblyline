= SysML Block — Basic Typst File

S. James
2025-12-15

== Introduction
A minimal Typst template to get started. Shows headings, lists, an inline code block, a small macro, math, and an image placeholder.

== Formatting examples
Bold: *bold*
Italic: *italic*
Monospace: `code`

== Lists
* Bullet item A
* Bullet item B

1. First step
2. Second step dsd

== Small macro + box
#import "@preview/cetz:0.4.2"
// define a function that can draw into a canvas

#let draw_block_instance(
  position: none,
  name: none,
  block_type: none,
  stereotype: none,
  properties: (),
  operations: (),
  parts: (),
  width: 6,
  min-content-height: 1.5,
  padding: 0.5,
  line-height: 0.9,
  title-padding-y: 0.3,
  corner-radius: 0.2,
  sep-stroke: 0.05pt + black,
) = {
  import cetz.draw: *

  assert(position != none)
  assert(name != none)
  assert(position.len() == 2)

  let (cx, cy) = position

  let title-content = {
    if stereotype != none {
      align(center)[#smallcaps(stereotype)]
      linebreak()
    }
    align(center)[#strong(name)]
    if block_type != none {
      linebreak()
      align(center)[#underline(strong(block_type))]
    }
  }

  // Simplified fixed-size layout (since we can't measure inside canvas)
  let title-h = 1.5
  let num-elements = properties.len() + operations.len() + parts.len()
  let content-h = calc.max(min-content-height, num-elements * line-height + 2 * padding)

  let total-h = title-h + content-h
  let half-w = width / 2
  let half-h = total-h / 2

  let y-top = cy + half-h
  let y-bottom = cy - half-h
  let x-left = cx - half-w
  let x-right = cx + half-w
  let y-title-bottom = y-top - title-h

  // Top rounded part (title compartment)
  rect(
    (x-left, y-title-bottom),
    (x-right, y-top),
    radius: (top-left: corner-radius, top-right: corner-radius),
    stroke: black,
  )

  // Bottom part
  rect(
    (x-left, y-bottom),
    (x-right, y-title-bottom),
    radius: (bottom-left: corner-radius, bottom-right: corner-radius),
    stroke: black,
  )

  // Vertical sides
  line((x-left, y-top), (x-left, y-bottom), stroke: black)
  line((x-right, y-top), (x-right, y-bottom), stroke: black)

  // Title separator
  line((x-left, y-title-bottom), (x-right, y-title-bottom), stroke: sep-stroke)

  // Compartment separators
  let current-y = y-title-bottom - padding
  if properties.len() > 0 and (operations.len() > 0 or parts.len() > 0) {
    current-y -= properties.len() * line-height
    line((x-left, current-y), (x-right, current-y), stroke: sep-stroke)
  }
  if operations.len() > 0 and parts.len() > 0 {
    current-y -= operations.len() * line-height
    line((x-left, current-y), (x-right, current-y), stroke: sep-stroke)
  }

  // Title placement
  content((cx, y-top - title-h / 2), title-content)

  // Compartment contents
  let y-offset = y-title-bottom - padding - line-height / 2

  for item in properties {
    content((x-left + padding, y-offset), align(left, item))
    y-offset -= line-height
  }
  for item in operations {
    content((x-left + padding, y-offset), align(left, item))
    y-offset -= line-height
  }
  for item in parts {
    content((x-left + padding, y-offset), align(left, item))
    y-offset -= line-height
  }
}

#cetz.canvas(length: 1cm, {
  import cetz.draw: *
  //circle((0,0), radius:(0.65,0.5), fill: color.aqua)
  draw_block_instance(
    position: (0, 0),
    name: "instance",
    block_type: "BlockType",
    stereotype: "stereotype",
    properties: ("mass : Real", "velocity : Real"),
    operations: ("accelerate()", "brake()"),
    )
})

