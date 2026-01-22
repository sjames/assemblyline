// assemblyline/lib.typ
// AssemblyLine – FINAL, BULLETPROOF, WORKING (December 2025)
// No errors. No locate/state issues. #links works anywhere.

// Import Fletcher for automatic diagram generation
#import "@preview/fletcher:0.5.8": diagram, node, edge

#let __registry      = state("asln-registry", (:))
#let __links         = state("asln-links", ())        // Individual link records
#let __active-config = state("asln-active-config", none)

// Extract trailing content block safely
#let __body(args) = {
  let pos = args.pos()
  if pos.len() > 0 { pos.last() } else { [] }
}


// Helper functions for link management (defined before __element)
// Add a single link record
#let __add-link(source, link-type, target) = {
  context {
    __links.update(links => links + (
      (source: source, type: link-type, target: target),
    ))
  }
}

// Add multiple links from a dictionary (convenience function)
#let __add-links(source, link-dict) = {
  for (link-type, targets) in link-dict {
    if targets != none {
      let target-array = if type(targets) == array { targets } else { (targets,) }
      for target in target-array {
        __add-link(source, link-type, target)
      }
    }
  }
}

// Validate all links at document end
// Call this function after all elements are registered to check link integrity
#let validate-links() = context {
  let registry = __registry.get()
  let all-links = __links.get()
  let violations = ()

  // Check each link
  for link in all-links {
    let source = link.source
    let target = link.target
    let link-type = link.at("type")

    // Check if source exists (should always be true, but verify)
    if source not in registry {
      violations.push("Link source '" + source + "' does not exist")
    }

    // Check if target exists
    if target not in registry {
      violations.push(
        "Link from '" + source + "' to '" + target + "' (type: '" +
        link-type + "') references non-existent element '" + target + "'"
      )
    }
  }

  // Report violations
  if violations.len() > 0 {
    let msg = "Link validation failed with " + str(violations.len()) + " error(s):\n" + violations.join("\n")
    panic(msg)
  }
}

// Get all links for a specific element (by source)
// NOTE: This function must be called from within a context block
#let __get-links(element-id) = {
  let all-links = __links.get()
  let elem-links = (:)  // Dictionary: link-type → (targets,)

  // Find all links where source == element-id
  for link in all-links {
    if link.source == element-id {
      let link-type = link.at("type")
      let target = link.target

      if link-type in elem-links {
        elem-links.at(link-type) += (target,)
      } else {
        elem-links.insert(link-type, (target,))
      }
    }
  }

  elem-links
}

// Register element silently
#let __element(
  type, id, title: "", tags: (:), links: (:),
  parent: none, concrete: none, group: none, body: none
) = {
  context {
    // Register element WITHOUT links field
    __registry.update(r => {
      r.insert(id, (
        type: type,
        id: id,
        title: title,
        tags: tags,
        // NO links field here
        parent: parent,
        concrete: concrete,
        group: group,
        body: body
      ))
      r
    })

    // Add links to separate storage
    __add-links(id, links)
  }
}

// #feature
#let feature(title, ..args) = {
  let named = args.named()
  let body  = __body(args)
  let id       = named.at("id")
  let tags     = named.at("tags", default: (:))
  let parent   = named.at("parent", default: none)
  let concrete = named.at("concrete", default: true)
  let group    = named.at("group", default: none)

  __element("feature", id,
    title: title,
    tags: tags,
    links: (child_of: parent),
    parent: parent,
    concrete: concrete,
    group: group,
    body: body
  )
}

// #req
// ──────────────────────────────────────────────────────────────────────────────
// Purpose:      Requirements specification with explicit traceability
// Mandatory:    id: "UNIQUE"
//               EITHER belongs_to: "FEATURE-ID" (top-level requirement)
//               OR derives_from: "REQ-ID" (derived/decomposed requirement)
// Optional:     tags: (type: "functional", safety: "QM", ...) → metadata
// Content:      The requirement text
// Validation:   Exactly one of belongs_to or derives_from must be specified
#let req(id, belongs_to: none, derives_from: none, ..args) = {
  // Validation: EITHER belongs_to OR derives_from must be present (XOR)
  let has_belongs_to = belongs_to != none
  let has_derives_from = derives_from != none

  assert(
    has_belongs_to or has_derives_from,
    message: "Requirement '" + id + "' must have either 'belongs_to' (linking to a feature) or 'derives_from' (linking to a parent requirement)"
  )

  assert(
    not (has_belongs_to and has_derives_from),
    message: "Requirement '" + id + "' cannot have both 'belongs_to' and 'derives_from'. Use 'belongs_to' for top-level requirements or 'derives_from' for derived requirements."
  )

  let named = args.named()
  let body  = __body(args)
  let tags  = named.at("tags", default: (:))

  // Build links based on which parameter was provided
  let links = (:)
  if has_belongs_to   { links.belongs_to = (belongs_to,) }
  if has_derives_from { links.derives_from = (derives_from,) }

  metadata((type: "req", id: id))

  __element("req", id, tags: tags, links: links, body: body)
}

// Generic elements
#let use_case(title, ..args) = {
  let named = args.named()
  let body = __body(args)
  let id = named.at("id")
  let tags = named.at("tags", default: (:))
  let links-param = named.at("links", default: (:))
  __element("use_case", id, title: title, tags: tags, links: links-param, body: body)
}

// #block_definition – Full SysML Block Definition
// ──────────────────────────────────────────────────────────────────────────────
// Purpose:      Define system components with full SysML block semantics
// Required:     id, title
// SysML Features:
//   properties:   ((name: "prop1", type: "Integer", default: 0, unit: "ms"), ...)
//   operations:   ((name: "start", params: "void", returns: "bool"), ...)
//   ports:        ((name: "httpPort", direction: "in", protocol: "HTTP"), ...)
//   parts:        ((name: "authService", type: "BLK-AUTH", multiplicity: "1"), ...) – composition with role names
//   connectors:   ((from: "httpPort", to: "authService.authAPI", flow: "HTTPRequest"), ...) – internal wiring & delegation
//                 - No dot = block's own port (delegation)
//                 - With dot = part.port (internal wiring)
//   references:   ("BLK-EXT1", "BLK-EXT2") – associations (external block IDs)
//   constraints:  ("weight < 500g", "power < 10W") – OCL-like constraints
//   tags:         (stereotype: "subsystem", complexity: "high", ...)
//   body:         Free-form description
#let block_definition(
  id,
  title: "",
  properties: (),
  operations: (),
  ports: (),
  parts: (),
  connectors: (),
  references: (),
  constraints: (),
  ..args
) = {
  let named = args.named()
  let body  = __body(args)
  let tags  = named.at("tags", default: (:))
  let links-param = named.at("links", default: (:))

  // Store SysML-specific data in tags for easy access
  let full-tags = tags + (
    sysml-properties: properties,
    sysml-operations: operations,
    sysml-ports: ports,
    sysml-parts: parts,
    sysml-connectors: connectors,
    sysml-references: references,
    sysml-constraints: constraints
  )

  __element("block_definition", id, title: title, tags: full-tags, links: links-param, body: body)
}

// #internal_block_diagram – Standalone SysML Internal Block Diagram
// ──────────────────────────────────────────────────────────────────────────────
// Purpose:      Define internal structure independently from block definitions
// Required:     id, title
// SysML Features:
//   parts:        ((name: "part1", type: "BLK-TYPE", multiplicity: "1"), ...)
//   ports:        ((name: "port1", direction: "in", protocol: "HTTP"), ...)
//   connectors:   ((from: "port", to: "part.port", flow: "Data"), ...)
//   references:   ("BLK-EXT1", "BLK-EXT2") – external block references
//   tags:         (tool: "PlantUML", author: "...", ...)
//   body:         Free-form description
#let internal_block_diagram(
  id,
  title: "",
  parts: (),
  ports: (),
  connectors: (),
  references: (),
  ..args
) = {
  let named = args.named()
  let body  = __body(args)
  let tags  = named.at("tags", default: (:))
  let links-param = named.at("links", default: (:))

  // Store IBD-specific data in tags for easy access
  let full-tags = tags + (
    ibd-parts: parts,
    ibd-ports: ports,
    ibd-connectors: connectors,
    ibd-references: references
  )

  __element("internal_block_diagram", id, title: title, tags: full-tags, links: links-param, body: body)
}

#let sequence_diagram(id, title: "", ..args) = {
  let named = args.named()
  let tags = named.at("tags", default: (:))
  let links-param = named.at("links", default: (:))
  __element("sequence_diagram", id, title: title, tags: tags, links: links-param, body: __body(args))
}
#let implementation(id, title: "", ..args)    = __element("implementation", id, title: title, tags: args.named().at("tags", default: (:)), body: __body(args))
#let test_case(id, title: "", ..args)         = __element("test_case", id, title: title, tags: args.named().at("tags", default: (:)), body: __body(args))

// NOTE: #links() function removed - links are now passed as parameters to elements

// #config
#let config(id, title: "", root_feature_id: "ROOT", selected: (), tags: (:)) = {
  context {
    __registry.update(r => {
      r.insert("CONFIG:" + id, (
        type: "config",
        id: id,
        title: title,
        root: root_feature_id,
        selected: selected,
        tags: tags
      ))
      r
    })
  }
}

#let set-active-config(id) = __active-config.update(id)

// Reporting

// Render a feature tree node recursively
#let __render-tree-node(feature, registry, selected, depth) = {
  let indent = "  " * depth
  let is-selected = selected.contains(feature.id)

  // Determine node symbols and styling
  let group-symbol = if feature.group == "XOR" {
    "⊕"
  } else if feature.group == "OR" {
    "⊙"
  } else {
    "●"
  }

  let concrete-marker = if feature.concrete == false {
    " (abstract)"
  } else {
    ""
  }

  // Style based on selection
  let node-content = if is-selected {
    text(fill: green.darken(20%), weight: "bold")[
      #group-symbol #feature.id#if feature.title != "" [ – #feature.title]#concrete-marker
    ]
  } else {
    text(fill: gray)[
      #group-symbol #feature.id#if feature.title != "" [ – #feature.title]#concrete-marker
    ]
  }

  // Render this node
  [#indent#node-content\ ]

  // Find and render children
  let children = registry.pairs()
    .filter(p => p.last().type == "feature" and p.last().parent == feature.id)
    .map(p => p.last())

  for child in children {
    __render-tree-node(child, registry, selected, depth + 1)
  }
}

// Render a feature tree node with requirements
#let __render-tree-node-with-requirements(feature, registry, all-links, selected, depth) = {
  let indent = "  " * depth
  let is-selected = selected.contains(feature.id)

  // Determine node symbols and styling
  let group-symbol = if feature.group == "XOR" {
    "⊕"
  } else if feature.group == "OR" {
    "⊙"
  } else {
    "●"
  }

  let concrete-marker = if feature.concrete == false {
    " (abstract)"
  } else {
    ""
  }

  // Style based on selection
  let node-content = if is-selected {
    text(fill: green.darken(20%), weight: "bold")[
      #group-symbol #feature.id#if feature.title != "" [ – #feature.title]#concrete-marker
    ]
  } else {
    text(fill: gray)[
      #group-symbol #feature.id#if feature.title != "" [ – #feature.title]#concrete-marker
    ]
  }

  // Render this node
  [#indent#node-content\ ]

  // Find and render requirements that belong to this feature
  // Only show requirements if the feature is selected (or if no configuration is active)
  let show-requirements = is-selected or selected.len() == 0

  if show-requirements {
    let feature-reqs = all-links
      .filter(link => link.type == "belongs_to" and link.target == feature.id)
      .map(link => link.source)

    if feature-reqs.len() > 0 {
      let req-indent = "  " * (depth + 1)
      for req-id in feature-reqs {
        let req = registry.at(req-id, default: none)
        if req != none and req.type == "req" {
          // Create a labeled requirement using figure for proper anchoring
          [#figure(
            kind: "requirement",
            supplement: [],
            numbering: _ => [],  // No visible numbering
            gap: 0pt,
            text(fill: blue.darken(10%), size: 0.9em, weight: "bold")[#req-indent→ #req-id:] + " " + text(fill: blue.darken(20%), size: 0.85em)[#req.body]
          ) #label(req-id) #v(-0.5em)]
        }
      }
    }
  }

  // Find and render children features
  let children = registry.pairs()
    .filter(p => p.last().type == "feature" and p.last().parent == feature.id)
    .map(p => p.last())

  for child in children {
    __render-tree-node-with-requirements(child, registry, all-links, selected, depth + 1)
  }
}

// Setup show rule for requirement references (call this at document start)
#let setup-requirement-references(body) = {
  show ref: it => {
    if it.element != none and it.element.func() == figure and it.element.kind == "requirement" {
      // Extract the label from the reference and display it
      let label-str = str(it.target)
      link(it.target)[#label-str]
    } else {
      it
    }
  }

  body
}

// #feature-tree-with-requirements: Render hierarchical feature model with requirements
#let feature-tree-with-requirements(root: "ROOT", config: none, level: 2) = context {
    // Get registry and links from state
    let registry = __registry.get()
    let all-links = __links.get()

    // Determine which configuration to use
    let cfg-id = if config != none {
      config
    } else {
      __active-config.get()
    }

  // Get selected features from configuration
  let selected = if cfg-id != none and ("CONFIG:" + cfg-id) in registry {
    registry.at("CONFIG:" + cfg-id).selected
  } else {
    ()
  }

  // Get root feature
  let root-feature = registry.at(root, default: none)

  if root-feature == none {
    block(fill: red.lighten(80%), inset: 1em)[
      *Error:* Feature "#root" not found in registry. \
      *Registry keys:* #registry.keys().join(", ") \
      *Registry has #registry.len() items*
    ]
    return
  }

  // Count total requirements linked to features
  let total-reqs = all-links
    .filter(link => link.type == "belongs_to")
    .map(link => link.source)
    .len()

  // Render header (non-breakable)
  block(
    width: 100%,
    fill: luma(245),
    inset: 1em,
    radius: 4pt,
    stroke: 1pt + luma(200)
  )[
    #heading(level: level)[Feature Tree with Requirements]
    #if cfg-id != none [
      *Configuration:* #cfg-id \
      *Selected features:* #selected.len() of #registry.pairs().filter(p => p.last().type == "feature").len() \
      *Top-level requirements:* #total-reqs
    ]
    #if cfg-id == none [
      _(No active configuration – showing all features)_ \
      *Top-level requirements:* #total-reqs
    ]
  ]

  v(0.5em)

  // Render tree content (breakable across pages)
  text(font: "Courier New", size: 0.9em)[
    #__render-tree-node-with-requirements(root-feature, registry, all-links, selected, 0)
  ]

  v(0.5em)

  // Render legend (non-breakable)
  block(
    width: 100%,
    fill: luma(250),
    inset: 0.5em,
    radius: 3pt
  )[
    #text(size: 0.85em, fill: gray)[
      *Legend:* ● Feature | ⊕ XOR Group | ⊙ OR Group | → Requirement | #text(fill: green.darken(20%), weight: "bold")[Selected] | #text(fill: gray)[Not Selected]
    ]
  ]
}

// #feature-tree: Render hierarchical feature model with configuration
#let feature-tree(root: "ROOT", config: none) = context {
  // Get registry from state
  let registry = __registry.get()

  // Determine which configuration to use
  let cfg-id = if config != none {
    config
  } else {
    __active-config.get()
  }

  // Get selected features from configuration
  let selected = if cfg-id != none and ("CONFIG:" + cfg-id) in registry {
    registry.at("CONFIG:" + cfg-id).selected
  } else {
    ()
  }

  // Get root feature
  let root-feature = registry.at(root, default: none)

  if root-feature == none {
    block(fill: red.lighten(80%), inset: 1em)[
      *Error:* Feature "#root" not found in registry. \
      *Registry keys:* #registry.keys().join(", ") \
      *Registry has #registry.len() items*
    ]
    return
  }

  // Render header (non-breakable)
  block(
    width: 100%,
    fill: luma(245),
    inset: 1em,
    radius: 4pt,
    stroke: 1pt + luma(200)
  )[
    === Feature Tree
    #if cfg-id != none [
      *Configuration:* #cfg-id \
      *Selected features:* #selected.len() of #registry.pairs().filter(p => p.last().type == "feature").len()
    ]
    #if cfg-id == none [
      _(No active configuration – showing all features)_
    ]
  ]

  v(0.5em)

  // Render tree content (breakable across pages)
  text(font: "Courier New", size: 0.9em)[
    #__render-tree-node(root-feature, registry, selected, 0)
  ]

  v(0.5em)

  // Render legend (non-breakable)
  block(
    width: 100%,
    fill: luma(250),
    inset: 0.5em,
    radius: 3pt
  )[
    #text(size: 0.85em, fill: gray)[
      *Legend:* ● Feature | ⊕ XOR Group | ⊙ OR Group | #text(fill: green.darken(20%), weight: "bold")[Selected] | #text(fill: gray)[Not Selected]
    ]
  ]
}

#let coverage-table() = block(fill: luma(240))[Traceability matrix – rendered here]

// #render-use-case: Render a single use case with all details
#let render-use-case(uc) = {
  block(
    width: 100%,
    fill: luma(248),
    inset: 1em,
    radius: 4pt,
    stroke: 1pt + luma(220),
    breakable: true
  )[
    === #uc.title

    #text(size: 0.9em, fill: blue.darken(20%), weight: "bold")[
      ID: #uc.id
    ]

    #if uc.tags.len() > 0 [
      #v(0.3em)
      #text(size: 0.85em)[
        #for (key, value) in uc.tags [
          #text(weight: "bold")[#key:] #value #h(1em)
        ]
      ]
    ]

    #v(0.5em)
    #block(inset: (left: 0.5em))[
      #uc.body
    ]

    #context {
      let links = __get-links(uc.id)
      if links.len() > 0 [
        #v(0.5em)
        #block(
          fill: luma(255),
          inset: 0.5em,
          radius: 3pt,
          stroke: 1pt + blue.lighten(70%)
        )[
          #text(size: 0.85em, fill: blue.darken(30%))[
            *Traceability Links:* \
            #for (link-type, targets) in links [
              #text(weight: "bold")[#link-type:] #targets.join(", ") \
            ]
          ]
        ]
      ]
    }
  ]

  v(0.5em)
}

// #use-case-section: Render all use cases in the registry
#let use-case-section(title: "Use Cases", level: 2) = context {
  let registry = __registry.get()

  let use-cases = registry.pairs()
    .filter(p => p.last().type == "use_case")
    .map(p => p.last())
    .sorted(key: uc => uc.id)

  if use-cases.len() == 0 {
    block(fill: yellow.lighten(80%), inset: 1em)[
      *Note:* No use cases found in registry.
    ]
    return
  }

  block(
    width: 100%,
    fill: blue.lighten(90%),
    inset: 1em,
    radius: 4pt,
    stroke: 2pt + blue.lighten(50%)
  )[
    #heading(level: level)[#title]
    #text(size: 0.9em)[
      This section documents all behavioral scenarios showing how actors interact with the system to achieve their goals.

      *Total use cases:* #use-cases.len()
    ]
  ]

  v(1em)

  for uc in use-cases {
    render-use-case(uc)
  }
}

// #render-block: Render a single SysML block definition with all features
#let render-block(blk) = {
  block(
    width: 100%,
    fill: rgb("#f5f9ff"),
    inset: 1.2em,
    radius: 4pt,
    stroke: 2pt + rgb("#4a90e2"),
    breakable: true
  )[
    === #blk.title

    #text(size: 0.9em, fill: rgb("#2c5aa0"), weight: "bold")[
      «block» #blk.id
    ]

    // General tags (excluding sysml-specific ones)
    #let general-tags = blk.tags.pairs().filter(p => not str(p.first()).starts-with("sysml-"))
    #if general-tags.len() > 0 [
      #v(0.3em)
      #text(size: 0.85em)[
        #for (key, value) in general-tags [
          #text(weight: "bold")[#key:] #value #h(1em)
        ]
      ]
    ]

    // Description
    #if blk.body != none and blk.body != [] [
      #v(0.5em)
      #block(inset: (left: 0.5em))[
        #blk.body
      ]
    ]

    // Properties
    #let properties = blk.tags.at("sysml-properties", default: ())
    #if properties.len() > 0 [
      #v(0.7em)
      #block(
        fill: white,
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + luma(220)
      )[
        *Properties* \
        #table(
          columns: (auto, auto, auto, auto),
          stroke: 0.5pt + luma(200),
          inset: 5pt,
          [*Name*], [*Type*], [*Default*], [*Unit*],
          ..properties.map(p => (
            text(font: "Courier New")[#p.name],
            text(fill: blue.darken(20%))[#p.at("type", default: "")],
            text(font: "Courier New", size: 0.85em)[#p.at("default", default: "")],
            text(style: "italic")[#p.at("unit", default: "")]
          )).flatten()
        )
      ]
    ]

    // Operations
    #let operations = blk.tags.at("sysml-operations", default: ())
    #if operations.len() > 0 [
      #v(0.7em)
      #block(
        fill: white,
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + luma(220)
      )[
        *Operations* \
        #for op in operations {
          let params = op.at("params", default: "")
          let ret = op.at("returns", default: "void")
          let sig = op.name + "(" + params + "): " + ret
          [+ #text(font: "Courier New", size: 0.9em)[#sig] \ ]
        }
      ]
    ]

    // Ports
    #let ports = blk.tags.at("sysml-ports", default: ())
    #if ports.len() > 0 [
      #v(0.7em)
      #block(
        fill: white,
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + luma(220)
      )[
        *Ports* \
        #table(
          columns: (auto, auto, auto),
          stroke: 0.5pt + luma(200),
          inset: 5pt,
          [*Name*], [*Direction*], [*Protocol*],
          ..ports.map(p => (
            text(font: "Courier New")[#p.name],
            text(fill: green.darken(20%))[#p.at("direction", default: "in/out")],
            [#p.at("protocol", default: "")]
          )).flatten()
        )
      ]
    ]

    // Parts (Composition)
    #let parts = blk.tags.at("sysml-parts", default: ())
    #if parts.len() > 0 [
      #v(0.7em)
      #block(
        fill: rgb("#fff9e6"),
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + rgb("#ffd966")
      )[
        *Parts (Composition)* \
        #table(
          columns: (auto, auto, auto),
          stroke: 0.5pt + rgb("#e6c200"),
          inset: 5pt,
          [*Part Name*], [*Type*], [*Multiplicity*],
          ..parts.map(p => (
            text(font: "Courier New", fill: rgb("#b8860b"))[#p.name],
            text(font: "Courier New", fill: rgb("#8b4513"))[#p.type],
            text(fill: rgb("#b8860b"))[#p.at("multiplicity", default: "1")]
          )).flatten()
        )
      ]
    ]

    // Connectors (Internal Wiring & Delegation)
    #let connectors = blk.tags.at("sysml-connectors", default: ())
    #if connectors.len() > 0 [
      #v(0.7em)
      #block(
        fill: rgb("#e6f7ff"),
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + rgb("#40a9ff")
      )[
        *Connectors* \
        #table(
          columns: (auto, 1fr, auto, 1fr, auto),
          stroke: 0.5pt + rgb("#91d5ff"),
          inset: 5pt,
          align: (left, left, center, left, left),
          [*From*], [], [], [*To*], [*Flow*],
          ..connectors.map(c => {
            let from-str = c.from
            let to-str = c.to
            let flow = c.at("flow", default: "")
            let name = c.at("name", default: none)

            // Determine if delegation (one side has no dot) or internal (both have dots)
            let from-is-block-port = not from-str.contains(".")
            let to-is-block-port = not to-str.contains(".")
            let is-delegation = from-is-block-port or to-is-block-port

            let arrow = if is-delegation {
              text(fill: rgb("#1890ff"), size: 1.2em)[⇒]
            } else {
              text(fill: rgb("#52c41a"), size: 1.2em)[→]
            }

            let from-cell = text(font: "Courier New", size: 0.85em,
              fill: if from-is-block-port { rgb("#d46b08") } else { rgb("#389e0d") }
            )[#from-str]

            let to-cell = text(font: "Courier New", size: 0.85em,
              fill: if to-is-block-port { rgb("#d46b08") } else { rgb("#389e0d") }
            )[#to-str]

            let flow-cell = if flow != "" {
              text(style: "italic", size: 0.85em)[#flow]
            } else {
              []
            }

            (from-cell, [], arrow, to-cell, flow-cell)
          }).flatten()
        )
        #v(0.3em)
        #text(size: 0.75em, fill: gray)[
          Legend: #text(fill: rgb("#d46b08"))[Block Port] | #text(fill: rgb("#389e0d"))[Part.Port] |
          #text(fill: rgb("#1890ff"))[⇒ Delegation] | #text(fill: rgb("#52c41a"))[→ Internal]
        ]
      ]
    ]

    // References (Associations)
    #let references = blk.tags.at("sysml-references", default: ())
    #if references.len() > 0 [
      #v(0.7em)
      #block(
        fill: rgb("#f0f0f0"),
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + luma(180)
      )[
        *References (Associations)* \
        #for ref in references [
          → #text(font: "Courier New")[#ref] \
        ]
      ]
    ]

    // Constraints
    #let constraints = blk.tags.at("sysml-constraints", default: ())
    #if constraints.len() > 0 [
      #v(0.7em)
      #block(
        fill: rgb("#fff0f0"),
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + rgb("#ff9999")
      )[
        *Constraints* \
        #for constraint in constraints [
          • #text(font: "Courier New", size: 0.85em, fill: red.darken(20%))[{#constraint}] \
        ]
      ]
    ]

    // Traceability Links
    #context {
      let links = __get-links(blk.id)
      if links.len() > 0 [
        #v(0.7em)
        #block(
          fill: rgb("#e6f3ff"),
          inset: 0.7em,
          radius: 3pt,
          stroke: 1pt + rgb("#4a90e2")
        )[
          #text(size: 0.85em, fill: rgb("#2c5aa0"))[
            *Traceability Links:* \
            #for (link-type, targets) in links [
              #text(weight: "bold")[#link-type:] #targets.join(", ") \
            ]
          ]
        ]
      ]
    }
  ]

  v(0.5em)
}

// #block-definition-section: Render all block definitions in the registry
#let block-definition-section(title: "System Architecture – Block Definitions", level: 2) = context {
  let registry = __registry.get()

  let blocks = registry.pairs()
    .filter(p => p.last().type == "block_definition")
    .map(p => p.last())
    .sorted(key: b => b.id)

  if blocks.len() == 0 {
    block(fill: yellow.lighten(80%), inset: 1em)[
      *Note:* No block definitions found in registry.
    ]
    return
  }

  block(
    width: 100%,
    fill: rgb("#e8f4f8"),
    inset: 1em,
    radius: 4pt,
    stroke: 2pt + rgb("#4a90e2")
  )[
    #heading(level: level)[#title]
    #text(size: 0.9em)[
      This section documents the system architecture using SysML block definitions.
      Each block represents a system component with its properties, operations, ports,
      composition relationships, and constraints.

      *Total blocks:* #blocks.len()
    ]
  ]

  v(1em)

  for blk in blocks {
    render-block(blk)
  }
}

// #block-definition-of-block: Render a single block definition by ID
// ──────────────────────────────────────────────────────────────────────────────
// Purpose:      Display a specific block definition from the registry
// Parameter:    block-id - The ID of the block to retrieve and render
// Returns:      The rendered block or panics if not found
#let block-definition-of-block(block-id) = context {
  let registry = __registry.get()
  let blk = registry.at(block-id, default: none)

  if blk == none {
    let available-blocks = registry.pairs()
      .filter(p => p.last().type == "block_definition")
      .map(p => p.first())
      .join(", ")
    panic("Block definition '" + block-id + "' not found in registry. Available block IDs: " + available-blocks)
  }

  if blk.type != "block_definition" {
    panic("Element '" + block-id + "' exists but is not a block definition. Type: " + blk.type)
  }

  render-block(blk)
}

// #render-ibd: Render a single internal block diagram with all details
#let render-ibd(ibd) = {
  block(
    width: 100%,
    fill: rgb("#f0f8ff"),
    inset: 1.2em,
    radius: 4pt,
    stroke: 2pt + rgb("#4169e1"),
    breakable: true
  )[
    === #ibd.title

    #text(size: 0.9em, fill: rgb("#191970"), weight: "bold")[
      «internal block diagram» #ibd.id
    ]

    // General tags (excluding ibd-specific ones)
    #let general-tags = ibd.tags.pairs().filter(p => not str(p.first()).starts-with("ibd-"))
    #if general-tags.len() > 0 [
      #v(0.3em)
      #text(size: 0.85em)[
        #for (key, value) in general-tags [
          #text(weight: "bold")[#key:] #value #h(1em)
        ]
      ]
    ]

    // Description
    #if ibd.body != none and ibd.body != [] [
      #v(0.5em)
      #block(inset: (left: 0.5em))[
        #ibd.body
      ]
    ]

    // Ports
    #let ports = ibd.tags.at("ibd-ports", default: ())
    #if ports.len() > 0 [
      #v(0.7em)
      #block(
        fill: white,
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + luma(220)
      )[
        *Boundary Ports* \
        #table(
          columns: (auto, auto, auto),
          stroke: 0.5pt + luma(200),
          inset: 5pt,
          [*Name*], [*Direction*], [*Protocol*],
          ..ports.map(p => (
            text(font: "Courier New")[#p.name],
            text(fill: green.darken(20%))[#p.at("direction", default: "in/out")],
            [#p.at("protocol", default: "")]
          )).flatten()
        )
      ]
    ]

    // Parts (Composition)
    #let parts = ibd.tags.at("ibd-parts", default: ())
    #if parts.len() > 0 [
      #v(0.7em)
      #block(
        fill: rgb("#fff9e6"),
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + rgb("#ffd966")
      )[
        *Parts* \
        #table(
          columns: (auto, auto, auto),
          stroke: 0.5pt + rgb("#e6c200"),
          inset: 5pt,
          [*Part Name*], [*Type*], [*Multiplicity*],
          ..parts.map(p => (
            text(font: "Courier New", fill: rgb("#b8860b"))[#p.name],
            text(font: "Courier New", fill: rgb("#8b4513"))[#p.type],
            text(fill: rgb("#b8860b"))[#p.at("multiplicity", default: "1")]
          )).flatten()
        )
      ]
    ]

    // Connectors (Internal Wiring & Delegation)
    #let connectors = ibd.tags.at("ibd-connectors", default: ())
    #if connectors.len() > 0 [
      #v(0.7em)
      #block(
        fill: rgb("#e6f7ff"),
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + rgb("#40a9ff")
      )[
        *Connectors* \
        #table(
          columns: (auto, 1fr, auto, 1fr, auto),
          stroke: 0.5pt + rgb("#91d5ff"),
          inset: 5pt,
          align: (left, left, center, left, left),
          [*From*], [], [], [*To*], [*Flow*],
          ..connectors.map(c => {
            let from-str = c.from
            let to-str = c.to
            let flow = c.at("flow", default: "")

            // Determine if delegation (one side has no dot) or internal (both have dots)
            let from-is-boundary = not from-str.contains(".")
            let to-is-boundary = not to-str.contains(".")
            let is-delegation = from-is-boundary or to-is-boundary

            let arrow = if is-delegation {
              text(fill: rgb("#1890ff"), size: 1.2em)[⇒]
            } else {
              text(fill: rgb("#52c41a"), size: 1.2em)[→]
            }

            let from-cell = text(font: "Courier New", size: 0.85em,
              fill: if from-is-boundary { rgb("#d46b08") } else { rgb("#389e0d") }
            )[#from-str]

            let to-cell = text(font: "Courier New", size: 0.85em,
              fill: if to-is-boundary { rgb("#d46b08") } else { rgb("#389e0d") }
            )[#to-str]

            let flow-cell = if flow != "" {
              text(style: "italic", size: 0.85em)[#flow]
            } else {
              []
            }

            (from-cell, [], arrow, to-cell, flow-cell)
          }).flatten()
        )
        #v(0.3em)
        #text(size: 0.75em, fill: gray)[
          Legend: #text(fill: rgb("#d46b08"))[Boundary Port] | #text(fill: rgb("#389e0d"))[Part.Port] |
          #text(fill: rgb("#1890ff"))[⇒ Delegation] | #text(fill: rgb("#52c41a"))[→ Internal]
        ]
      ]
    ]

    // References
    #let references = ibd.tags.at("ibd-references", default: ())
    #if references.len() > 0 [
      #v(0.7em)
      #block(
        fill: rgb("#f0f0f0"),
        inset: 0.7em,
        radius: 3pt,
        stroke: 1pt + luma(180)
      )[
        *References* \
        #for ref in references [
          → #text(font: "Courier New")[#ref] \
        ]
      ]
    ]

    // Traceability Links
    #context {
      let links = __get-links(ibd.id)
      if links.len() > 0 [
        #v(0.7em)
        #block(
          fill: rgb("#e6f3ff"),
          inset: 0.7em,
          radius: 3pt,
          stroke: 1pt + rgb("#4169e1")
        )[
          #text(size: 0.85em, fill: rgb("#191970"))[
            *Traceability Links:* \
            #for (link-type, targets) in links [
              #text(weight: "bold")[#link-type:] #targets.join(", ") \
            ]
          ]
        ]
      ]
    }
  ]

  v(0.5em)
}

// #internal-block-diagram-section: Render all internal block diagrams in the registry
#let internal-block-diagram-section(title: "Internal Block Diagrams", level: 2) = context {
  let registry = __registry.get()

  let ibds = registry.pairs()
    .filter(p => p.last().type == "internal_block_diagram")
    .map(p => p.last())
    .sorted(key: ibd => ibd.id)

  if ibds.len() == 0 {
    block(fill: yellow.lighten(80%), inset: 1em)[
      *Note:* No internal block diagrams found in registry.
    ]
    return
  }

  block(
    width: 100%,
    fill: rgb("#e6f0ff"),
    inset: 1em,
    radius: 4pt,
    stroke: 2pt + rgb("#4169e1")
  )[
    #heading(level: level)[#title]
    #text(size: 0.9em)[
      This section documents the internal structure of system blocks using SysML
      Internal Block Diagrams (IBDs). Each diagram shows how parts are composed
      within a block and how they are interconnected via ports and connectors.

      *Total diagrams:* #ibds.len()
    ]
  ]

  v(1em)

  for ibd in ibds {
    render-ibd(ibd)
  }
}

// #visualize-ibd: Generate visual diagram from internal_block_diagram element
// ──────────────────────────────────────────────────────────────────────────────
// Purpose:      Create a visual IBD from an internal_block_diagram definition
// Parameter:    ibd-id - The ID of the IBD element to visualize
// Returns:      A Fletcher diagram showing the internal structure
#let visualize-ibd(ibd-id) = context {
  let registry = __registry.get()
  let ibd = registry.at(ibd-id, default: none)

  if ibd == none or ibd.type != "internal_block_diagram" {
    block(fill: red.lighten(80%), inset: 1em)[
      *Error:* Internal block diagram "#ibd-id" not found in registry.
    ]
    return
  }

  let parts = ibd.tags.at("ibd-parts", default: ())
  let ports = ibd.tags.at("ibd-ports", default: ())
  let connectors = ibd.tags.at("ibd-connectors", default: ())

  // Generate Fletcher diagram with SysML block frame
  let cols = if parts.len() > 0 { calc.ceil(calc.sqrt(parts.len())) } else { 1 }
  let rows = if parts.len() > 0 { calc.ceil(parts.len() / cols) } else { 1 }

  diagram(
    node-stroke: 1pt,
    edge-stroke: 1pt,
    spacing: (3em, 2em),
    {
      // Frame calculations
      let margin-x = 2.5
      let margin-y = 2.0

      let frame-left = -margin-x
      let frame-right = (cols - 1) + margin-x
      let frame-top = -margin-y
      let frame-bottom = (rows - 1) + margin-y

      let frame-center-x = (frame-left + frame-right) / 2
      let frame-center-y = (frame-top + frame-bottom) / 2

      let frame-width = (frame-right - frame-left) * 3em + 3em
      let frame-height = (frame-bottom - frame-top) * 2em + 2em

      // Block frame
      node(
        (frame-center-x, frame-center-y),
        [],
        width: frame-width,
        height: frame-height,
        stroke: 2pt + black,
        fill: rgb("#fafafa"),
        corner-radius: 0pt,
        name: "block-frame"
      )

      // Block name label
      node(
        (frame-center-x, frame-top - 0.5),
        [#text(size: 0.9em, weight: "bold")[#ibd.title] \ #text(size: 0.7em, style: "italic")[«#ibd.id»]],
        fill: white,
        stroke: none
      )

      // Position ports on frame boundary
      let port-offset = 0.3
      for (i, port) in ports.enumerate() {
        let port-pos = if port.direction == "in" {
          (-port-offset, i * 1.2)
        } else {
          (cols - 1 + port-offset, i * 1.2)
        }

        node(
          port-pos,
          [#text(size: 0.65em)[#port.name]],
          fill: rgb("#ffe7ba"),
          stroke: 2pt + rgb("#d46b08"),
          corner-radius: 0pt,
          width: 1.8em,
          height: 0.9em,
          name: port.name
        )
      }

      // Create nodes for parts
      let row = 0
      let col = 0

      for (i, part) in parts.enumerate() {
        let pos = (col, row)

        node(
          pos,
          [#text(size: 0.8em, weight: "bold")[#part.name] \ #text(size: 0.7em, style: "italic")[:#part.type]],
          fill: rgb("#fff9e6"),
          stroke: rgb("#ffd966"),
          corner-radius: 3pt,
          name: part.name
        )

        col += 1
        if col >= cols {
          col = 0
          row += 1
        }
      }

      // Create edges for connectors
      for conn in connectors {
        let from-str = conn.from
        let to-str = conn.to
        let flow = conn.at("flow", default: "")

        // Handle part-to-part connections
        if from-str.contains(".") and to-str.contains(".") {
          let from-part = from-str.split(".").first()
          let to-part = to-str.split(".").first()

          let from-idx = parts.position(p => p.name == from-part)
          let to-idx = parts.position(p => p.name == to-part)

          if from-idx != none and to-idx != none {
            let from-col = calc.rem(from-idx, cols)
            let from-row = calc.quo(from-idx, cols)
            let to-col = calc.rem(to-idx, cols)
            let to-row = calc.quo(to-idx, cols)

            let mark = if flow != "" { "-|>" } else { "-" }

            edge(
              (from-col, from-row),
              (to-col, to-row),
              mark,
              label: if flow != "" { text(size: 0.6em, style: "italic")[#flow] }
            )
          }
        }
      }
    }
  )
}

// #generate-ibd: Automatically generate Internal Block Diagram from block definition
// ──────────────────────────────────────────────────────────────────────────────
// Purpose:      Create a visual IBD showing parts, ports, and connectors
// Parameter:    block-id - The ID of the block to visualize
// Returns:      A Fletcher diagram showing the internal structure
#let generate-ibd(block-id) = context {
  let registry = __registry.get()
  let blk = registry.at(block-id, default: none)

  if blk == none {
    block(fill: red.lighten(80%), inset: 1em)[
      *Error:* Block "#block-id" not found in registry.
    ]
    return
  }

  let parts = blk.tags.at("sysml-parts", default: ())
  let ports = blk.tags.at("sysml-ports", default: ())
  let connectors = blk.tags.at("sysml-connectors", default: ())

  // Generate Fletcher diagram with SysML block frame
  let cols = if parts.len() > 0 { calc.ceil(calc.sqrt(parts.len())) } else { 1 }
  let rows = if parts.len() > 0 { calc.ceil(parts.len() / cols) } else { 1 }

  diagram(
    node-stroke: 1pt,
    edge-stroke: 1pt,
    spacing: (3em, 2em),
    {
      // Draw block frame (outer boundary) - SysML IBD convention
      // Calculate frame to encompass all parts with proper margins
      // Parts occupy positions from (0,0) to (cols-1, rows-1) in grid coordinates
      // With spacing of (3em, 2em), we need to calculate the actual size

      // Frame should be drawn FIRST (behind everything)
      // Add generous margins around the grid of parts
      let margin-x = 2.5  // Horizontal margin in grid units
      let margin-y = 2.0  // Vertical margin in grid units

      let frame-left = -margin-x
      let frame-right = (cols - 1) + margin-x
      let frame-top = -margin-y
      let frame-bottom = (rows - 1) + margin-y

      let frame-center-x = (frame-left + frame-right) / 2
      let frame-center-y = (frame-top + frame-bottom) / 2

      // Calculate frame dimensions based on grid spacing
      // Note: Fletcher uses the spacing parameter (3em, 2em) for node separation
      let frame-width = (frame-right - frame-left) * 3em + 3em
      let frame-height = (frame-bottom - frame-top) * 2em + 2em

      // Block frame rectangle - drawn FIRST so it appears behind parts
      node(
        (frame-center-x, frame-center-y),
        [],
        width: frame-width,
        height: frame-height,
        stroke: 2pt + black,
        fill: rgb("#fafafa"),  // Very light gray background
        corner-radius: 0pt,
        name: "block-frame"
      )

      // Block name label at top of frame (outside the frame)
      node(
        (frame-center-x, frame-top - 0.5),
        [#text(size: 0.9em, weight: "bold")[#blk.title] \ #text(size: 0.7em, style: "italic")[«#blk.id»]],
        fill: white,
        stroke: none
      )

      // Position block ports on the frame boundary (outside parts area)
      let port-offset = 0.3  // Distance from edge of parts grid
      for (i, port) in ports.enumerate() {
        let port-pos = if port.direction == "in" {
          // Input ports on left edge
          (-port-offset, i * 1.2)
        } else {
          // Output ports on right edge
          (cols - 1 + port-offset, i * 1.2)
        }

        node(
          port-pos,
          [#text(size: 0.65em)[#port.name]],
          fill: rgb("#ffe7ba"),
          stroke: 2pt + rgb("#d46b08"),
          corner-radius: 0pt,
          width: 1.8em,
          height: 0.9em,
          name: port.name
        )
      }

      // Create nodes for each part inside the block frame
      let row = 0
      let col = 0

      for (i, part) in parts.enumerate() {
        let pos = (col, row)

        node(
          pos,
          [#text(size: 0.8em, weight: "bold")[#part.name] \ #text(size: 0.7em, style: "italic")[:#part.type]],
          fill: rgb("#fff9e6"),
          stroke: rgb("#ffd966"),
          corner-radius: 3pt,
          name: part.name
        )

        col += 1
        if col >= cols {
          col = 0
          row += 1
        }
      }

      // Create edges for connectors (part-to-part only for now)
      for conn in connectors {
        let from-str = conn.from
        let to-str = conn.to
        let flow = conn.at("flow", default: "")

        // Only show part-to-part connections (both have dots)
        if from-str.contains(".") and to-str.contains(".") {
          // Extract part names
          let from-part = from-str.split(".").first()
          let to-part = to-str.split(".").first()

          // Find part indices
          let from-idx = parts.position(p => p.name == from-part)
          let to-idx = parts.position(p => p.name == to-part)

          if from-idx != none and to-idx != none {
            let from-col = calc.rem(from-idx, cols)
            let from-row = calc.quo(from-idx, cols)
            let to-col = calc.rem(to-idx, cols)
            let to-row = calc.quo(to-idx, cols)

            // SysML-compliant notation:
            // - Solid line with FILLED triangle for item flow
            let mark = if flow != "" { "-|>" } else { "-" }

            edge(
              (from-col, from-row),
              (to-col, to-row),
              mark,
              label: if flow != "" { text(size: 0.6em, style: "italic")[#flow] }
            )
          }
        }
      }
    }
  )
}

