// feature-diagram-compact.typ — Compact version for fitting on single page
// Import and re-export with modified defaults

#import "feature-diagram.typ": *

// Compact layout configuration
#let layout-compact = (
  horizontal-spacing: 120pt,  // Reduced from 180pt
  vertical-spacing: 35pt,     // Reduced from 50pt
  node-width: 100pt,          // Reduced from 140pt
  node-height: 28pt,          // Reduced from 35pt
  connection-radius: 3pt,     // Reduced from 4pt
  arc-offset: 12pt,           // Reduced from 15pt
  font-size: 8pt,             // Reduced from 10pt
)

// Override the layout defaults in the imported module
// Note: This requires modifying the original feature-diagram.typ to export layout-defaults
// For now, we'll create a wrapper function

/// Compact feature model diagram (fits more on one page)
#let feature-model-diagram-compact(
  root: "ROOT",
  config: none,
  registry-state: none,
  active-config-state: none,
  show-legend: true,
  scale: 100%,
) = {
  // Use scale to shrink the standard diagram
  let scale-factor = scale / 100%

  scale(x: scale-factor, y: scale-factor, origin: top + left)[
    #feature-model-diagram(
      root: root,
      config: config,
      registry-state: registry-state,
      active-config-state: active-config-state,
      show-legend: show-legend,
    )
  ]
}
