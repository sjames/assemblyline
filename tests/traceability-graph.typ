// traceability-graph.typ
// Generate a visual graph of all elements and their links

#import "packages/preview/assemblyline/main/lib/lib.typ": *
#import "@preview/fletcher:0.5.8": diagram, node, edge

// Generate a traceability graph showing all elements and links
#let traceability-graph() = context {
  let registry = __registry.get()
  let all-links = __links.get()

  // Build node list - assign each element a position
  let elements = registry.pairs().map(p => p.last())
  let node-map = (:)  // Maps ID -> index for edge creation

  // Group elements by type for layout
  let features = elements.filter(e => e.type == "feature")
  let reqs = elements.filter(e => e.type == "req")
  let use-cases = elements.filter(e => e.type == "use_case")
  let blocks = elements.filter(e => e.type == "block")
  let diagrams = elements.filter(e => e.type == "sequence_diagram" or e.type == "internal_block_diagram")

  pagebreak()
  heading(level: 1, "Traceability Graph")

  diagram(
    node-stroke: 1pt,
    spacing: 4em,
    edge-stroke: 1pt,
    node-corner-radius: 5pt,
    {
      // Define color scheme by element type
      let colors = (
        feature: eastern,
        req: blue,
        use_case: green,
        block: purple,
        sequence_diagram: orange,
        internal_block_diagram: orange,
      )

      // Layout: arrange by type in columns
      let col = 0
      let row = 0

      // Features column
      for (i, elem) in features.enumerate() {
        node((0, i), elem.id, fill: colors.at(elem.type, default: gray).lighten(70%), stroke: colors.at(elem.type, default: gray))
        node-map.insert(elem.id, (0, i))
      }

      // Requirements column
      for (i, elem) in reqs.enumerate() {
        node((1, i), elem.id, fill: colors.at(elem.type, default: gray).lighten(70%), stroke: colors.at(elem.type, default: gray))
        node-map.insert(elem.id, (1, i))
      }

      // Use cases column
      for (i, elem) in use-cases.enumerate() {
        node((2, i), elem.id, fill: colors.at(elem.type, default: gray).lighten(70%), stroke: colors.at(elem.type, default: gray))
        node-map.insert(elem.id, (2, i))
      }

      // Blocks column
      for (i, elem) in blocks.enumerate() {
        node((3, i), elem.id, fill: colors.at(elem.type, default: gray).lighten(70%), stroke: colors.at(elem.type, default: gray))
        node-map.insert(elem.id, (3, i))
      }

      // Diagrams column
      for (i, elem) in diagrams.enumerate() {
        node((4, i), elem.id, fill: colors.at(elem.type, default: gray).lighten(70%), stroke: colors.at(elem.type, default: gray))
        node-map.insert(elem.id, (4, i))
      }

      // Draw edges for all links
      for link in all-links {
        let from-pos = node-map.at(link.source, default: none)
        let to-pos = node-map.at(link.target, default: none)

        if from-pos != none and to-pos != none {
          // Color edges by link type
          let edge-colors = (
            belongs_to: blue,
            derives_from: purple,
            child_of: gray,
            trace: green,
            satisfy: orange,
            allocated_to: red,
          )

          edge(from-pos, to-pos,
            "->",
            label: text(size: 8pt, fill: edge-colors.at(link.type, default: black))[#link.type],
            stroke: edge-colors.at(link.type, default: black)
          )
        }
      }
    }
  )

  // Legend
  block(
    fill: gray.lighten(90%),
    width: 100%,
    inset: 10pt,
    radius: 5pt,
    [
      *Legend:*
      - #text(fill: eastern)[■] Features
      - #text(fill: blue)[■] Requirements
      - #text(fill: green)[■] Use Cases
      - #text(fill: purple)[■] Blocks
      - #text(fill: orange)[■] Diagrams

      *Link Types:*
      - #text(fill: blue)[belongs_to] (req → feature)
      - #text(fill: purple)[derives_from] (req → req)
      - #text(fill: gray)[child_of] (feature → feature)
      - #text(fill: green)[trace] (use case → req)
      - #text(fill: orange)[satisfy] (diagram → req)
      - #text(fill: red)[allocated_to] (block → req)
    ]
  )
}
