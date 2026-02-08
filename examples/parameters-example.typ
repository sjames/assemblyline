// AssemblyLine Feature Parameters Example
// Demonstrates Phase 1: Core Parameter Support

#import "../packages/preview/assemblyline/main/lib/lib.typ": *

// ==============================================================================
// Root Feature
// ==============================================================================

#feature("Root", id: "ROOT")[
  The root feature for the product line.
]

// ==============================================================================
// Features with Parameters
// ==============================================================================

#feature("Cache System", id: "F-CACHE", parent: "ROOT",
  parameters: (
    cache_size: (
      type: "Integer",
      range: (16, 2048),
      unit: "MB",
      default: 256,
      description: "Maximum cache size in memory"
    ),
    eviction_policy: (
      type: "Enum",
      values: ("LRU", "FIFO", "LFU", "ARC"),
      default: "LRU",
      description: "Cache eviction algorithm"
    ),
    enable_compression: (
      type: "Boolean",
      default: false,
      description: "Enable compression for cached data"
    )
  ),
  constraints: (
    "cache_size >= 16",
    "enable_compression == true => cache_size >= 128"
  )
)[
  Provides configurable in-memory caching for frequently accessed data.

  The cache system can be tuned for different performance requirements by
  adjusting the cache size, eviction policy, and compression settings.
]

#feature("Database Pool", id: "F-DB-POOL", parent: "ROOT",
  parameters: (
    max_connections: (
      type: "Integer",
      range: (10, 10000),
      unit: "connections",
      default: 100,
      description: "Maximum number of database connections"
    ),
    connection_timeout: (
      type: "Integer",
      range: (1, 300),
      unit: "seconds",
      default: 30,
      description: "Timeout for establishing connections"
    )
  ),
  constraints: (
    "max_connections >= 10",
    "connection_timeout >= 1"
  ),
  requires: ("F-CACHE")
)[
  Database connection pooling with configurable connection limits and timeouts.
]

#feature("User Management", id: "F-USER-MGMT", parent: "ROOT",
  parameters: (
    max_users: (
      type: "Integer",
      range: (100, 100000),
      default: 1000,
      description: "Maximum number of concurrent users"
    ),
    session_timeout: (
      type: "Integer",
      range: (5, 1440),
      unit: "minutes",
      default: 60,
      description: "Session timeout duration"
    ),
    password_policy: (
      type: "Enum",
      values: ("basic", "standard", "strict"),
      default: "standard",
      description: "Password complexity requirements"
    )
  )
)[
  User account management with configurable capacity and security policies.
]

#feature("Feature Flags", id: "F-FLAGS", parent: "ROOT",
  parameters: (
    enable_dark_mode: (
      type: "Boolean",
      default: false,
      description: "Enable dark mode UI"
    ),
    enable_analytics: (
      type: "Boolean",
      default: true,
      description: "Enable usage analytics"
    ),
    enable_beta_features: (
      type: "Boolean",
      default: false,
      description: "Enable experimental beta features"
    )
  )
)[
  Runtime feature toggles for optional functionality.
]

// ==============================================================================
// Configurations
// ==============================================================================

#config("CFG-STARTER",
  title: "Starter Edition",
  root_feature_id: "ROOT",
  selected: ("F-CACHE", "F-USER-MGMT", "F-FLAGS"),

  bindings: (
    "F-CACHE": (
      cache_size: 64,
      eviction_policy: "LRU",
      enable_compression: false
    ),
    "F-USER-MGMT": (
      max_users: 100,
      session_timeout: 30,
      password_policy: "basic"
    ),
    "F-FLAGS": (
      enable_dark_mode: true,
      enable_analytics: false,
      enable_beta_features: false
    )
  ),

  tags: (market: "small-business", price: "low")
)

#config("CFG-PROFESSIONAL",
  title: "Professional Edition",
  root_feature_id: "ROOT",
  selected: ("F-CACHE", "F-DB-POOL", "F-USER-MGMT", "F-FLAGS"),

  bindings: (
    "F-CACHE": (
      cache_size: 512,
      eviction_policy: "LFU",
      enable_compression: true
    ),
    "F-DB-POOL": (
      max_connections: 500,
      connection_timeout: 30
    ),
    "F-USER-MGMT": (
      max_users: 5000,
      session_timeout: 60,
      password_policy: "standard"
    ),
    "F-FLAGS": (
      enable_dark_mode: true,
      enable_analytics: true,
      enable_beta_features: false
    )
  ),

  tags: (market: "mid-market", price: "medium")
)

#config("CFG-ENTERPRISE",
  title: "Enterprise Edition",
  root_feature_id: "ROOT",
  selected: ("F-CACHE", "F-DB-POOL", "F-USER-MGMT", "F-FLAGS"),

  bindings: (
    "F-CACHE": (
      cache_size: 2048,
      eviction_policy: "ARC",
      enable_compression: true
    ),
    "F-DB-POOL": (
      max_connections: 5000,
      connection_timeout: 60
    ),
    "F-USER-MGMT": (
      max_users: 100000,
      session_timeout: 120,
      password_policy: "strict"
    ),
    "F-FLAGS": (
      enable_dark_mode: true,
      enable_analytics: true,
      enable_beta_features: true
    )
  ),

  tags: (market: "enterprise", price: "high", support: "24/7")
)

// ==============================================================================
// Validation
// ==============================================================================

#heading(level: 1)[Parameter Validation Report]

Validating configurations...

#validate-links()
#validate-parameter-bindings("CFG-STARTER")
#validate-parameter-bindings("CFG-PROFESSIONAL")
#validate-parameter-bindings("CFG-ENTERPRISE")

#text(green)[✓ All parameter bindings are valid!]

// ==============================================================================
// Configuration Comparison
// ==============================================================================

#heading(level: 1)[Configuration Comparison]

#table(
  columns: (auto, auto, auto, auto),
  align: (left, center, center, center),
  table.header(
    [*Parameter*], [*Starter*], [*Professional*], [*Enterprise*]
  ),

  [*Cache Size*], [64 MB], [512 MB], [2048 MB],
  [*Cache Eviction*], [LRU], [LFU], [ARC],
  [*Cache Compression*], [No], [Yes], [Yes],
  [*Max Users*], [100], [5000], [100000],
  [*Session Timeout*], [30 min], [60 min], [120 min],
  [*Password Policy*], [Basic], [Standard], [Strict],
  [*Dark Mode*], [Yes], [Yes], [Yes],
  [*Analytics*], [No], [Yes], [Yes],
  [*Beta Features*], [No], [No], [Yes],
)

// ==============================================================================
// Feature Details with Parameters
// ==============================================================================

#heading(level: 1)[Feature Details]

#context {
  let registry = __registry.get()

  // Get all features with parameters
  let features-with-params = registry.pairs()
    .filter(p => p.last().type == "feature" and p.last().at("parameters", default: none) != none)
    .map(p => p.last())

  for feature in features-with-params {
    heading(level: 2, feature.title + " [" + feature.id + "]")

    if feature.body != none {
      feature.body
      parbreak()
    }

    // Parameters table
    if feature.parameters != none and feature.parameters != (:) {
      heading(level: 3, "Parameters")

      table(
        columns: (1.5fr, 1fr, 1.5fr, 0.8fr, 1fr),
        align: (left, center, left, center, left),
        table.header(
          [*Name*], [*Type*], [*Range/Values*], [*Unit*], [*Default*]
        ),

        ..for (param-name, param-schema) in feature.parameters {
          let param-type = param-schema.at("type")
          let range-str = if param-type == "Integer" {
            let range = param-schema.at("range", default: none)
            if range != none {
              let (min-val, max-val) = range
              "[" + str(min-val) + ", " + str(max-val) + "]"
            } else { "-" }
          } else if param-type == "Enum" {
            let values = param-schema.at("values", default: ())
            values.join(", ")
          } else { "-" }

          let unit-str = param-schema.at("unit", default: "-")
          let default-val = param-schema.at("default")
          let default-str = if type(default-val) == bool {
            if default-val { "true" } else { "false" }
          } else {
            str(default-val)
          }

          (
            [#param-name],
            [#param-type],
            [#range-str],
            [#unit-str],
            [#default-str],
          )
        }
      )
      parbreak()
    }

    // Constraints
    if feature.constraints != none and feature.constraints != () {
      heading(level: 3, "Constraints")
      list(..feature.constraints)
      parbreak()
    }

    // Requirements
    if feature.requires != none {
      heading(level: 3, "Requires")
      let req-list = if type(feature.requires) == array { feature.requires } else { (feature.requires,) }
      list(..req-list.map(r => [Feature #r]))
      parbreak()
    }
  }
}
