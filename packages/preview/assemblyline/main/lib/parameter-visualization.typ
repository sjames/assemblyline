/// Parameter Visualization Module
/// Provides functions to render parameter schemas, bindings, and constraints
///
/// This module creates visualization functions that have access to the registry state

// =============================================================================
// Factory function that creates visualization functions with access to states
// =============================================================================

#let make-parameter-visualizations(__registry, __active-config) = {

  // ===========================================================================
  // 1. Parameter Schema Table - Show parameter definitions for a feature
  // ===========================================================================

  /// Render parameter schema table for a single feature
  ///
  /// Parameters:
  /// - feature-id: Feature ID to show parameters for
  /// - title: Optional custom title (default: "Parameters for {feature-id}")
  let render-parameter-schema(feature-id, title: none) = context {
    let registry = __registry.get()
    let feature = registry.at(feature-id, default: none)

    if feature == none {
      text(red)[Error: Feature '#feature-id' not found]
      return
    }

    let params = feature.at("parameters", default: none)

    if params == none or params.len() == 0 {
      text(gray)[Feature '#feature-id' has no parameters]
      return
    }

    // Title
    let display-title = if title != none {
      title
    } else {
      "Parameters for " + feature-id
    }

    heading(level: 3, display-title)

    // Build table rows
    let rows = ()

    for (param-name, schema) in params.pairs().sorted(key: p => p.first()) {
      let param-key = str(param-name)  // Ensure it's a string
      let param-type = schema.at("type", default: "Unknown")
      let range-str = if schema.at("range", default: none) != none {
        let r = schema.range
        "[" + str(r.at(0)) + ", " + str(r.at(1)) + "]"
      } else {
        "—"
      }
      let values-str = if schema.at("values", default: none) != none {
        schema.values.join(", ")
      } else {
        "—"
      }
      let unit-str = schema.at("unit", default: "—")
      let default-val = schema.at("default", default: none)
      let default-str = if default-val != none {
        if type(default-val) == bool {
          if default-val { "true" } else { "false" }
        } else {
          str(default-val)
        }
      } else {
        "—"
      }
      let desc-str = schema.at("description", default: "—")

      rows.push([#param-key])
      rows.push([#param-type])
      rows.push([#range-str])
      rows.push([#values-str])
      rows.push([#unit-str])
      rows.push([#default-str])
      rows.push([#desc-str])
    }

    // Render table
    table(
      columns: (auto, auto, auto, auto, auto, auto, 1fr),
      align: (left, left, left, left, left, left, left),
      table.header(
        [*Parameter*], [*Type*], [*Range*], [*Values*], [*Unit*], [*Default*], [*Description*]
      ),
      ..rows
    )
  }

  /// Render parameter schemas for all features that have parameters
  let render-all-parameter-schemas() = context {
    let registry = __registry.get()

    heading(level: 2)[Parameter Schemas]

    // Find all features with parameters
    let features-with-params = registry.pairs()
      .filter(p => {
        let elem = p.last()
        (elem.at("type", default: none) == "feature" and
         elem.at("parameters", default: none) != none and
         elem.parameters.len() > 0)
      })
      .sorted(key: p => p.first())

    if features-with-params.len() == 0 {
      text(gray)[No features have parameters defined]
      return
    }

    for (feature-id, feature) in features-with-params {
      render-parameter-schema(feature-id)
      parbreak()
    }
  }

  // ===========================================================================
  // 2. Configuration Binding Table - Show actual parameter values
  // ===========================================================================

  /// Render parameter bindings for a configuration
  ///
  /// Parameters:
  /// - config-id: Configuration ID to show bindings for
  /// - show-defaults: Whether to show parameters using default values (default: true)
  /// - title: Optional custom title
  let render-parameter-bindings(config-id, show-defaults: true, title: none) = context {
    let registry = __registry.get()
    let config-key = "CONFIG:" + config-id
    let config = registry.at(config-key, default: none)

    if config == none {
      text(red)[Error: Configuration '#config-id' not found]
      return
    }

    // Title
    let display-title = if title != none {
      title
    } else {
      "Parameter Bindings for " + config-id
    }

    heading(level: 3, display-title)

    let selected = config.at("selected", default: ())
    let bindings = config.at("bindings", default: (:))

    // Build table rows
    let rows = ()
    let has-content = false

    for feature-id in selected.sorted() {
      let feature = registry.at(feature-id, default: none)
      if feature == none { continue }

      let params = feature.at("parameters", default: none)
      if params == none or params.len() == 0 { continue }

      let feature-bindings = bindings.at(feature-id, default: (:))

      for (param-name, schema) in params.pairs().sorted(key: p => p.first()) {
        let param-key = str(param-name)  // Ensure it's a string
        let bound-value = if param-key in feature-bindings {
          feature-bindings.at(param-key)
        } else {
          none
        }
        let default-value = schema.at("default", default: none)
        let using-default = bound-value == none

        // Skip if using default and show-defaults is false
        if using-default and not show-defaults { continue }

        let value-str = if using-default {
          if type(default-value) == bool {
            if default-value { "true" } else { "false" }
          } else {
            str(default-value)
          }
        } else {
          if type(bound-value) == bool {
            if bound-value { "true" } else { "false" }
          } else {
            str(bound-value)
          }
        }

        let default-str = if type(default-value) == bool {
          if default-value { "true" } else { "false" }
        } else if default-value != none {
          str(default-value)
        } else {
          "—"
        }

        let source = if using-default {
          text(gray)[default]
        } else {
          text(blue)[binding]
        }

        rows.push([#feature-id])
        rows.push([#param-key])
        rows.push([#value-str])
        rows.push([#default-str])
        rows.push([#source])

        has-content = true
      }
    }

    if not has-content {
      text(gray)[No parameters bound in this configuration]
      return
    }

    // Render table
    table(
      columns: (auto, auto, auto, auto, auto),
      align: (left, left, left, left, center),
      table.header(
        [*Feature*], [*Parameter*], [*Value*], [*Default*], [*Source*]
      ),
      ..rows
    )
  }

  /// Render parameter bindings for all configurations
  let render-all-parameter-bindings(show-defaults: true) = context {
    let registry = __registry.get()

    heading(level: 2)[Configuration Parameter Bindings]

    // Find all configurations
    let configs = registry.pairs()
      .filter(p => p.first().starts-with("CONFIG:"))
      .sorted(key: p => p.first())

    if configs.len() == 0 {
      text(gray)[No configurations defined]
      return
    }

    for (config-key, config) in configs {
      let config-id = config.id
      render-parameter-bindings(config-id, show-defaults: show-defaults)
      parbreak()
    }
  }

  // ===========================================================================
  // 3. Constraint Visualization - Display constraints in readable format
  // ===========================================================================

  /// Render constraints for a single feature
  ///
  /// Parameters:
  /// - feature-id: Feature ID to show constraints for
  /// - title: Optional custom title
  let render-feature-constraints(feature-id, title: none) = context {
    let registry = __registry.get()
    let feature = registry.at(feature-id, default: none)

    if feature == none {
      text(red)[Error: Feature '#feature-id' not found]
      return
    }

    let constraints = feature.at("constraints", default: none)

    if constraints == none or constraints.len() == 0 {
      text(gray)[Feature '#feature-id' has no constraints]
      return
    }

    // Title
    let display-title = if title != none {
      title
    } else {
      "Constraints for " + feature-id
    }

    heading(level: 3, display-title)

    // Render as numbered list with code blocks
    for (idx, constraint) in constraints.enumerate() {
      let num = idx + 1
      [*C#num:* ]
      raw(constraint, lang: "constraint", block: false)
      linebreak()
    }
  }

  /// Render constraints for all features that have constraints
  let render-all-constraints() = context {
    let registry = __registry.get()

    heading(level: 2)[Feature Constraints]

    // Find all features with constraints
    let features-with-constraints = registry.pairs()
      .filter(p => {
        let elem = p.last()
        (elem.at("type", default: none) == "feature" and
         elem.at("constraints", default: none) != none and
         elem.constraints.len() > 0)
      })
      .sorted(key: p => p.first())

    if features-with-constraints.len() == 0 {
      text(gray)[No features have constraints defined]
      return
    }

    for (feature-id, feature) in features-with-constraints {
      render-feature-constraints(feature-id)
      parbreak()
    }
  }

  /// Render a comprehensive constraint summary table
  /// Shows all features with their constraints in a table format
  let render-constraint-summary() = context {
    let registry = __registry.get()

    heading(level: 2)[Constraint Summary]

    // Find all features with constraints
    let features-with-constraints = registry.pairs()
      .filter(p => {
        let elem = p.last()
        (elem.at("type", default: none) == "feature" and
         elem.at("constraints", default: none) != none and
         elem.constraints.len() > 0)
      })
      .sorted(key: p => p.first())

    if features-with-constraints.len() == 0 {
      text(gray)[No features have constraints defined]
      return
    }

    // Build table rows
    let rows = ()

    for (feature-id, feature) in features-with-constraints {
      let constraints = feature.constraints
      let feature-title = feature.at("title", default: feature-id)

      // Add row for each constraint
      for (idx, constraint) in constraints.enumerate() {
        if idx == 0 {
          rows.push([#feature-id])
          rows.push([#feature-title])
        } else {
          rows.push([])
          rows.push([])
        }
        rows.push([C#(idx + 1)])
        rows.push(raw(constraint, lang: "constraint", block: false))
      }
    }

    // Render table
    table(
      columns: (auto, 1fr, auto, 2fr),
      align: (left, left, center, left),
      table.header(
        [*Feature ID*], [*Feature Title*], [*ID*], [*Constraint Expression*]
      ),
      ..rows
    )
  }

  // ===========================================================================
  // 4. Combined Report - All parameter information
  // ===========================================================================

  /// Render a comprehensive parameter report including schemas, bindings, and constraints
  ///
  /// Parameters:
  /// - config-id: Optional configuration ID to highlight bindings for
  /// - show-defaults: Whether to show default values in bindings table
  let render-parameter-report(config-id: none, show-defaults: true) = {
    heading(level: 1)[Parameter Report]

    // Section 1: Parameter Schemas
    render-all-parameter-schemas()
    pagebreak()

    // Section 2: Configuration Bindings
    if config-id != none {
      render-parameter-bindings(config-id, show-defaults: show-defaults)
    } else {
      render-all-parameter-bindings(show-defaults: show-defaults)
    }
    pagebreak()

    // Section 3: Constraints
    render-all-constraints()
    parbreak()
    render-constraint-summary()
  }

  // Return all visualization functions
  (
    render-parameter-schema: render-parameter-schema,
    render-all-parameter-schemas: render-all-parameter-schemas,
    render-parameter-bindings: render-parameter-bindings,
    render-all-parameter-bindings: render-all-parameter-bindings,
    render-feature-constraints: render-feature-constraints,
    render-all-constraints: render-all-constraints,
    render-constraint-summary: render-constraint-summary,
    render-parameter-report: render-parameter-report,
  )
}
