// feature-diagram.typ — FeatureIDE-style feature model visualization using CeTZ
#import "@preview/cetz:0.4.2": canvas, draw

// Layout configuration constants
#let layout-defaults = (
  horizontal-spacing: 180pt,  // Distance between parent and child levels
  vertical-spacing: 50pt,     // Minimum vertical gap between siblings
  node-width: 140pt,          // Feature box width
  node-height: 35pt,          // Feature box height
  connection-radius: 4pt,     // Mandatory/optional circle size
  arc-offset: 15pt,           // Distance of group arc from nodes
  font-size: 10pt,            // Feature name font size
)

// Color scheme
#let colors = (
  selected-fill: rgb("#d4edda"),
  selected-stroke: rgb("#28a745"),
  selected-text: rgb("#155724"),
  unselected-fill: rgb("#f8f9fa"),
  unselected-stroke: rgb("#6c757d"),
  unselected-text: rgb("#6c757d"),
  abstract-stroke: (dash: "dashed"),
  mandatory-fill: black,
  optional-fill: white,
)

/// Calculate the height of a subtree (in vertical spacing units)
#let compute-subtree-height(feature-id, registry, visited: ()) = {
  // Prevent infinite loops
  if feature-id in visited {
    return 0
  }
  let new-visited = visited + (feature-id,)

  // Get children of this feature
  let children = registry.pairs()
    .filter(p => p.last().type == "feature" and p.last().parent == feature-id)
    .map(p => p.last())

  if children.len() == 0 {
    return 1  // Leaf node has height 1
  }

  // Sum heights of all children
  let total-height = 0
  for child in children {
    total-height += compute-subtree-height(child.id, registry, visited: new-visited)
  }

  total-height
}

/// Recursively compute layout positions for all features
/// Returns: dictionary with feature positions and metadata
#let compute-layout(feature-id, registry, x-pos, y-pos, selected, visited: ()) = {
  // Prevent infinite loops
  if feature-id in visited {
    return (nodes: (), edges: (), height: 0)
  }
  let new-visited = visited + (feature-id,)

  let feature = registry.at(feature-id, default: none)
  if feature == none {
    return (nodes: (), edges: (), height: 0)
  }

  // Get children
  let children = registry.pairs()
    .filter(p => p.last().type == "feature" and p.last().parent == feature-id)
    .map(p => p.last())

  // Calculate this subtree's total height
  let subtree-height = compute-subtree-height(feature-id, registry, visited: visited)

  // Position current feature at vertical center of its subtree
  let my-y = y-pos + (subtree-height - 1) * layout-defaults.vertical-spacing / 2
  let my-pos = (x-pos, my-y)

  // Store this node
  let is-selected = selected.contains(feature-id)
  let nodes = ((
    id: feature-id,
    title: if feature.title != "" { feature.title } else { feature-id },
    pos: my-pos,
    selected: is-selected,
    concrete: feature.concrete,
    group: feature.group,
  ),)

  let edges = ()

  // Recursively layout children
  if children.len() > 0 {
    let child-x = x-pos + layout-defaults.horizontal-spacing
    let child-y = y-pos

    let child-nodes = ()

    for child in children {
      let child-layout = compute-layout(
        child.id,
        registry,
        child-x,
        child-y,
        selected,
        visited: new-visited
      )

      // Accumulate child nodes
      nodes += child-layout.nodes
      edges += child-layout.edges

      // Store child position for edge drawing
      if child-layout.nodes.len() > 0 {
        child-nodes.push(child-layout.nodes.first())
      }

      // Move down for next child
      child-y += child-layout.height * layout-defaults.vertical-spacing
    }

    // Create edges from parent to children
    let parent-node = (
      id: feature-id,
      pos: my-pos,
      group: feature.group,
    )

    for child-node in child-nodes {
      // Determine if child is mandatory (check if it's concrete and not in an XOR/OR group)
      let is-mandatory = child-node.selected or (feature.group == none)

      edges.push((
        from: parent-node,
        to: child-node,
        mandatory: is-mandatory,
        group-type: feature.group,
      ))
    }

    // Store group metadata for arc rendering
    if feature.group in ("XOR", "OR") and child-nodes.len() > 1 {
      edges.push((
        type: "group-arc",
        group-type: feature.group,
        parent: parent-node,
        children: child-nodes,
      ))
    }
  }

  (nodes: nodes, edges: edges, height: subtree-height)
}

/// Draw a feature node (rectangle with text)
#let draw-feature-node(node, ctx) = {
  let pos = node.pos
  let w = layout-defaults.node-width
  let h = layout-defaults.node-height

  // Determine styling based on selection and concrete status
  let fill-color = if node.selected {
    colors.selected-fill
  } else {
    colors.unselected-fill
  }

  let stroke-color = if node.selected {
    colors.selected-stroke
  } else {
    colors.unselected-stroke
  }

  let text-color = if node.selected {
    colors.selected-text
  } else {
    colors.unselected-text
  }

  let stroke-style = if node.concrete {
    1pt + stroke-color
  } else {
    (paint: stroke-color, thickness: 1pt, dash: "dashed")
  }

  // Draw rectangle
  draw.rect(
    (pos.at(0) - w/2, pos.at(1) - h/2),
    (pos.at(0) + w/2, pos.at(1) + h/2),
    fill: fill-color,
    stroke: stroke-style,
    radius: 2pt,
    name: "node-" + node.id
  )

  // Draw text (center aligned)
  draw.content(
    pos,
    text(
      size: layout-defaults.font-size,
      fill: text-color,
      weight: if node.selected { "bold" } else { "regular" },
      style: if not node.concrete { "italic" } else { "normal" }
    )[#node.title]
  )
}

/// Draw connection line with mandatory/optional circle
#let draw-connection(edge, ctx) = {
  if edge.at("type", default: none) == "group-arc" {
    return  // Group arcs handled separately
  }

  let from-pos = edge.from.pos
  let to-pos = edge.to.pos

  let w = layout-defaults.node-width
  let r = layout-defaults.connection-radius

  // Calculate edge start/end points (from right edge of parent to left edge of child)
  let start = (from-pos.at(0) + w/2, from-pos.at(1))
  let end = (to-pos.at(0) - w/2, to-pos.at(1))

  // Connection point for the circle (near the child node)
  let circle-pos = (end.at(0) - r * 2, end.at(1))

  // Draw line
  draw.line(start, circle-pos, stroke: 1pt + black)
  draw.line(circle-pos, end, stroke: 1pt + black)

  // Draw mandatory (filled) or optional (empty) circle
  if edge.mandatory {
    draw.circle(
      circle-pos,
      radius: r,
      fill: colors.mandatory-fill,
      stroke: 1pt + black
    )
  } else {
    draw.circle(
      circle-pos,
      radius: r,
      fill: colors.optional-fill,
      stroke: 1pt + black
    )
  }
}

/// Draw XOR or OR group arc
#let draw-group-arc(edge, ctx) = {
  if edge.at("type", default: none) != "group-arc" {
    return
  }

  let parent-pos = edge.parent.pos
  let children = edge.children
  let group-type = edge.group-type

  if children.len() < 2 {
    return  // No arc needed for single child
  }

  let w = layout-defaults.node-width
  let offset = layout-defaults.arc-offset

  // Calculate arc position (between parent and children)
  let arc-x = parent-pos.at(0) + w/2 + offset

  // Get vertical range of children
  let child-y-positions = children.map(c => c.pos.at(1))
  let min-y = calc.min(..child-y-positions)
  let max-y = calc.max(..child-y-positions)

  // Draw vertical arc line
  draw.line(
    (arc-x, min-y),
    (arc-x, max-y),
    stroke: 1.5pt + black
  )

  // Draw decorator at parent connection point
  let decorator-y = parent-pos.at(1)
  let decorator-size = 6pt

  if group-type == "XOR" {
    // Filled wedge/arc for XOR
    draw.arc(
      (arc-x, decorator-y),
      start: 90deg,
      stop: 270deg,
      radius: decorator-size,
      fill: black,
      stroke: none
    )
  } else if group-type == "OR" {
    // Filled triangle for OR
    let tip = (arc-x + decorator-size, decorator-y)
    let top = (arc-x - decorator-size/2, decorator-y + decorator-size)
    let bottom = (arc-x - decorator-size/2, decorator-y - decorator-size)

    draw.line(tip, top, bottom, close: true, fill: black, stroke: 1pt + black)
  }

  // Draw horizontal lines from arc to children
  for child in children {
    let child-y = child.pos.at(1)
    let child-x = child.pos.at(0) - w/2
    draw.line(
      (arc-x, child-y),
      (child-x, child-y),
      stroke: 1pt + black
    )
  }
}

/// Main feature model diagram function
#let feature-model-diagram(
  root: "ROOT",
  config: none,
  registry-state: none,  // Pass in the __registry state
  active-config-state: none,  // Pass in the __active-config state
  show-legend: true,
  scale-factor: 100%,   // Scale factor (e.g., 70% to shrink, 100% for normal)
) = context {
  // Get registry from state
  let registry = if registry-state != none {
    registry-state.get()
  } else {
    panic("registry-state is required")
  }

  // Determine which configuration to use
  let cfg-id = if config != none {
    config
  } else if active-config-state != none {
    active-config-state.get()
  } else {
    none
  }

  // Get selected features from configuration
  let selected = if cfg-id != none and ("CONFIG:" + cfg-id) in registry {
    registry.at("CONFIG:" + cfg-id).selected
  } else {
    ()
  }

  // Check if root exists
  let root-feature = registry.at(root, default: none)
  if root-feature == none {
    block(fill: red.lighten(80%), inset: 1em)[
      *Error:* Feature "#root" not found in registry.
    ]
    return
  }

  // Compute layout
  let layout-result = compute-layout(root, registry, 0pt, 0pt, selected)

  // Render header
  if cfg-id != none {
    block(
      width: 100%,
      fill: luma(245),
      inset: 0.8em,
      radius: 4pt,
      stroke: 1pt + luma(200)
    )[
      *Feature Model:* #root #h(1em) *Configuration:* #cfg-id
    ]
    v(0.5em)
  }

  // Calculate canvas bounds
  let all-x = layout-result.nodes.map(n => n.pos.at(0))
  let all-y = layout-result.nodes.map(n => n.pos.at(1))

  let min-x = calc.min(..all-x) - layout-defaults.node-width
  let max-x = calc.max(..all-x) + layout-defaults.node-width
  let min-y = calc.min(..all-y) - layout-defaults.node-height
  let max-y = calc.max(..all-y) + layout-defaults.node-height

  let canvas-width = max-x - min-x
  let canvas-height = max-y - min-y

  // Render diagram content
  let diagram-content = [
    #canvas(length: 1pt, {
      import draw: *

      // Draw all edges first (so they appear behind nodes)
      for edge in layout-result.edges {
        if edge.at("type", default: none) != "group-arc" {
          draw-connection(edge, none)
        }
      }

      // Draw group arcs
      for edge in layout-result.edges {
        if edge.at("type", default: none) == "group-arc" {
          draw-group-arc(edge, none)
        }
      }

      // Draw all nodes
      for node in layout-result.nodes {
        draw-feature-node(node, none)
      }
    })
  ]

  // Apply scaling if needed
  if scale-factor != 100% {
    scale(x: scale-factor, y: scale-factor, origin: top + left)[
      #diagram-content
    ]
  } else {
    diagram-content
  }

  // Render legend
  if show-legend {
    v(0.5em)
    block(
      width: 100%,
      fill: luma(250),
      inset: 0.5em,
      radius: 3pt
    )[
      #text(size: 0.85em, fill: gray)[
        *Legend:* ● Mandatory | ○ Optional | ⊕ XOR Group (one must be selected) | ⊙ OR Group (one or more) |
        #box(fill: colors.selected-fill, stroke: 1pt + colors.selected-stroke, inset: 2pt, radius: 2pt)[Selected] |
        #box(fill: colors.unselected-fill, stroke: 1pt + colors.unselected-stroke, inset: 2pt, radius: 2pt)[Unselected] |
        #box(stroke: (paint: black, dash: "dashed"), inset: 2pt, radius: 2pt)[Abstract]
      ]
    ]
  }
}
