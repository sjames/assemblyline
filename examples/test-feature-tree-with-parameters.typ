// Test Feature Tree with Parameter Bindings Display
// Demonstrates the new feature tree parameter visualization

#import "../packages/preview/assemblyline/main/lib/lib.typ": *

// ==============================================================================
// Root Feature
// ==============================================================================

#feature("System Root", id: "ROOT")[
  The root feature for the system.
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
  )
)[
  Configurable in-memory caching for frequently accessed data.
]

#feature("Database", id: "F-DATABASE", parent: "ROOT", group: "XOR")[
  Database backend selection (choose exactly one).
]

#feature("PostgreSQL", id: "F-DB-POSTGRES", parent: "F-DATABASE",
  parameters: (
    max_connections: (
      type: "Integer",
      range: (10, 1000),
      unit: "connections",
      default: 100,
      description: "Maximum number of connections"
    ),
    pool_timeout: (
      type: "Integer",
      range: (1, 300),
      unit: "seconds",
      default: 30,
      description: "Connection pool timeout"
    )
  )
)[
  PostgreSQL relational database backend.
]

#feature("MongoDB", id: "F-DB-MONGO", parent: "F-DATABASE",
  parameters: (
    replica_set_size: (
      type: "Integer",
      range: (1, 7),
      default: 3,
      description: "Number of replica set members"
    ),
    write_concern: (
      type: "Enum",
      values: ("majority", "1", "2", "3"),
      default: "majority",
      description: "Write acknowledgment requirement"
    )
  )
)[
  MongoDB document database backend.
]

#feature("Monitoring", id: "F-MONITORING", parent: "ROOT",
  parameters: (
    sample_rate: (
      type: "Integer",
      range: (1, 3600),
      unit: "seconds",
      default: 60,
      description: "Metrics collection interval"
    ),
    retention_days: (
      type: "Integer",
      range: (1, 365),
      unit: "days",
      default: 30,
      description: "Metrics retention period"
    ),
    enable_alerting: (
      type: "Boolean",
      default: true,
      description: "Enable alert notifications"
    )
  )
)[
  System monitoring and alerting.
]

// ==============================================================================
// Configurations
// ==============================================================================

#config("CFG-BASIC",
  title: "Basic Configuration",
  root_feature_id: "ROOT",
  selected: ("F-CACHE", "F-DB-POSTGRES"),

  bindings: (
    "F-CACHE": (
      cache_size: 128,
      eviction_policy: "LRU",
      enable_compression: false
    ),
    "F-DB-POSTGRES": (
      max_connections: 50,
      pool_timeout: 15
    )
  ),

  tags: (deployment: "development", tier: "basic")
)

#config("CFG-PRODUCTION",
  title: "Production Configuration",
  root_feature_id: "ROOT",
  selected: ("F-CACHE", "F-DB-POSTGRES", "F-MONITORING"),

  bindings: (
    "F-CACHE": (
      cache_size: 1024,
      eviction_policy: "ARC",
      enable_compression: true
    ),
    "F-DB-POSTGRES": (
      max_connections: 500,
      pool_timeout: 60
    ),
    "F-MONITORING": (
      sample_rate: 30,
      retention_days: 90,
      enable_alerting: true
    )
  ),

  tags: (deployment: "production", tier: "enterprise")
)

#config("CFG-MONGO",
  title: "MongoDB Configuration",
  root_feature_id: "ROOT",
  selected: ("F-CACHE", "F-DB-MONGO", "F-MONITORING"),

  bindings: (
    "F-CACHE": (
      cache_size: 512,
      eviction_policy: "LFU",
      enable_compression: true
    ),
    "F-DB-MONGO": (
      replica_set_size: 5,
      write_concern: "majority"
    ),
    "F-MONITORING": (
      sample_rate: 60,
      retention_days: 60,
      enable_alerting: true
    )
  ),

  tags: (deployment: "production", tier: "scalable")
)

// ==============================================================================
// Document
// ==============================================================================

#set page(paper: "a4", margin: 1.5cm)
#set text(font: "Linux Libertine", size: 11pt)

= Feature Tree with Parameter Bindings

This document demonstrates the new parameter binding visualization in feature trees.
Parameter values from the active configuration are displayed inline with each selected feature.

== Configuration: Basic (Parameters Shown - Default)

#set-active-config("CFG-BASIC")
#feature-tree(root: "ROOT")

#pagebreak()

== Configuration: Production (Parameters Shown - Explicit)

#set-active-config("CFG-PRODUCTION")
#feature-tree(root: "ROOT", show-parameters: true)

#pagebreak()

== Configuration: Production (Parameters Hidden)

#feature-tree(root: "ROOT", config: "CFG-PRODUCTION", show-parameters: false)

#pagebreak()

== Configuration: MongoDB (Detailed Tree with Parameters)

#set-active-config("CFG-MONGO")
#feature-tree-detailed(root: "ROOT", show-descriptions: true, show-parameters: true)

#pagebreak()

== Configuration: MongoDB (Detailed Tree without Parameters)

#feature-tree-detailed(root: "ROOT", config: "CFG-MONGO", show-descriptions: true, show-parameters: false)
