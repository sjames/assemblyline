// lib/simple-diagrams.typ
// Simple diagram functions using diagramgrid
// Provides simplified SysML Internal Block Diagrams showing parts composition

#import "@local/diagramgrid:0.1.0": dg-rect, dg-flex

// Helper: Extract parts from registry element
// Works with both internal_block_diagram (ibd-parts) and block_definition (sysml-parts)
#let __get-parts-from-element(elem) = {
  if elem == none { return () }

  // Try IBD parts first (ibd-parts tag)
  let parts = elem.tags.at("ibd-parts", default: none)
  if parts != none { return parts }

  // Try block definition parts (sysml-parts tag)
  parts = elem.tags.at("sysml-parts", default: none)
  if parts != none { return parts }

  return ()
}

/// Simple Internal Block Diagram
/// Renders a simplified SysML IBD showing parts composition without ports/connectors.
///
/// Usage:
/// ```typst
/// // From existing IBD in registry
/// #simple-ibd("IBD-AUTH-SERVICE")
///
/// // From block definition in registry
/// #simple-ibd("BLK-AUTH-SERVICE")
///
/// // Inline definition
/// #simple-ibd(
///   title: "Auth Service",
///   parts: (
///     (name: "validator", type: "BLK-VALIDATOR"),
///     (name: "handler", type: "BLK-HANDLER"),
///   ),
/// )
/// ```
///
/// Parameters:
/// - id (positional or named): IBD or Block ID to look up from registry
/// - title: Block name (for inline definition)
/// - parts: Parts array: `((name: "...", type: "..."), ...)`
/// - show-types: Show `:TYPE` annotations on parts (default: true)
/// - show-multiplicity: Show multiplicity (e.g., `[1..*]`) (default: false)
/// - direction: Layout direction: "row" or "column" (default: "row")
/// - gap: Gap between parts (default: 1.5em)
/// - fill: Background color of container (default: light gray)
/// - part-fill: Background color of parts (default: light blue)
#let simple-ibd(
  ..args
) = {
  // Parse arguments
  let pos = args.pos()
  let named = args.named()

  // Get id from positional or named argument
  let id = if pos.len() > 0 {
    pos.first()
  } else {
    named.at("id", default: none)
  }

  // Get other named parameters with defaults
  let title = named.at("title", default: "")
  let parts = named.at("parts", default: ())
  let show-types = named.at("show-types", default: true)
  let show-multiplicity = named.at("show-multiplicity", default: false)
  let direction = named.at("direction", default: "row")
  let gap = named.at("gap", default: 1.5em)
  let fill = named.at("fill", default: rgb("#f1f5f9"))
  let part-fill = named.at("part-fill", default: rgb("#dbeafe"))

  context {
    // Import the registry state
    let registry = state("asln-registry", (:)).get()

    // Resolve data: from registry or inline
    let resolved-title = title
    let resolved-parts = parts

    if id != none {
      let elem = registry.at(id, default: none)
      if elem == none {
        // Return error indicator
        return dg-rect(
          header: [«ibd» #text(fill: red)[ERROR: #id not found]],
          header-fill: rgb("#dc2626"),
          fill: rgb("#fef2f2"),
          text(style: "italic", fill: luma(80))[Element '#id' not found in registry]
        )
      }
      resolved-title = elem.title
      resolved-parts = __get-parts-from-element(elem)
    }

    // Handle empty parts
    if resolved-parts.len() == 0 {
      return dg-rect(
        header: [#text(fill: white, weight: "bold", size: 0.85em)[«ibd» #resolved-title]],
        header-fill: rgb("#1e40af"),
        fill: fill,
        inset: 1em,
        text(style: "italic", fill: luma(120))[No parts defined]
      )
    }

    // Build part boxes
    let part-boxes = resolved-parts.map(p => {
      // Look up the type name from registry using the type ID
      let type-id = p.at("type", default: none)
      let type-name = if type-id != none {
        let type-elem = registry.at(type-id, default: none)
        if type-elem != none {
          type-elem.title
        } else {
          type-id  // Fallback to ID if not found in registry
        }
      } else {
        none
      }

      let label-content = if show-types and type-name != none {
        [
          #text(weight: "bold")[#p.name] \
          #text(size: 0.85em, fill: luma(80))[:#{type-name}]
        ]
      } else {
        text(weight: "bold")[#p.name]
      }

      // Add multiplicity if requested
      let full-content = if show-multiplicity and p.at("multiplicity", default: none) != none {
        [
          #label-content \
          #text(size: 0.8em, fill: luma(100))[\[#p.multiplicity\]]
        ]
      } else {
        label-content
      }

      dg-rect(full-content, fill: part-fill, inset: (x: 12pt, y: 8pt))
    })

    // Render the diagram
    dg-rect(
      header: [#text(fill: white, weight: "bold", size: 0.85em)[«ibd» #resolved-title]],
      header-fill: rgb("#1e40af"),
      fill: fill,
      inset: 1em,
      dg-flex(
        direction: direction,
        justify: "center",
        gap: gap,
        ..part-boxes
      )
    )
  }
}
