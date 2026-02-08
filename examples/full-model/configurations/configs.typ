#import "../packages/preview/assemblyline/main/lib/lib.typ": *

// Base safety package configuration
#config(
  "CFG-BASE",
  title: "ADAS Base Safety Package",
  root_feature_id: "ROOT",
  selected: (
    // Sensors (mandatory base sensors)
    "F-SENSORS",        // Sensor suite (mandatory)
    "F-CAMERA",         // Camera system (mandatory)
    "F-CAM-1",          // Single forward camera (base)
    "F-RADAR",          // Radar system (mandatory)
    "F-RADAR-SR",       // Short-range radar (base)

    // ADAS Functions (essential safety functions)
    "F-ADAS-FUNC",      // ADAS functions (mandatory)
    "F-LDW",            // Lane Departure Warning (required for Euro NCAP)
    "F-AEB",            // Automatic Emergency Braking (required for Euro NCAP)

    // HMI
    "F-HMI",            // HMI (mandatory)
    "F-HMI-CLUSTER",    // Instrument cluster display (base)

    // ECU Platform
    "F-ECU",            // ECU platform (mandatory)
    "F-ECU-SINGLE"      // Single-core processor (base)
  ),
  bindings: (
    "F-RADAR": (
      update_rate: 20,              // Standard update rate for base configuration
      angular_resolution: 3,         // Moderate resolution
      enable_tracking: true,         // Enable tracking for safety
      processing_mode: "Balanced"    // Balanced performance
    )
  ),
  tags: (
    market: "Entry-Level Vehicles",
    segment: "B-segment / Compact",
    price-point: "Budget",
    target-cost: "850 EUR",
    euro-ncap: "4-star minimum",
    regulations: ("UN R152 AEB", "UN R130 LDW"),
    asil-max: "D"
  )
)

// Premium ADAS package configuration
#config(
  "CFG-PREMIUM",
  title: "ADAS Premium Package",
  root_feature_id: "ROOT",
  selected: (
    // Sensors (full sensor suite)
    "F-SENSORS",        // Sensor suite (mandatory)
    "F-CAMERA",         // Camera system (mandatory)
    "F-CAM-4",          // Quad-camera surround view (premium)
    "F-RADAR",          // Radar system (mandatory)
    "F-RADAR-LR",       // Long-range radar (premium)
    "F-LIDAR",          // LiDAR system (premium)

    // ADAS Functions (full suite)
    "F-ADAS-FUNC",      // ADAS functions (mandatory)
    "F-LDW",            // Lane Departure Warning
    "F-LKA",            // Lane Keeping Assist
    "F-AEB",            // Automatic Emergency Braking
    "F-ACC",            // Adaptive Cruise Control
    "F-BSD",            // Blind Spot Detection
    "F-RCTA",           // Rear Cross Traffic Alert
    "F-TSR",            // Traffic Sign Recognition

    // HMI (premium)
    "F-HMI",            // HMI (mandatory)
    "F-HMI-HUD",        // Head-Up Display (premium)
    "F-HMI-HAPTIC",     // Haptic feedback (premium)

    // ECU Platform (high-performance)
    "F-ECU",            // ECU platform (mandatory)
    "F-ECU-MULTI"       // Multi-core processor (premium)
  ),
  bindings: (
    "F-RADAR": (
      update_rate: 40,               // Higher update rate for premium performance
      angular_resolution: 2,         // Better angular resolution
      enable_tracking: true,         // Enable tracking
      processing_mode: "Accurate"    // Accurate mode for premium
    ),
    "F-ACC": (
      min_speed: 20,                 // Lower minimum for stop-and-go
      max_speed: 180,                // High max speed for highway
      default_time_gap: 15,          // Shorter gap for sportier feel
      comfort_mode: "Sport",         // Sport mode for premium
      enable_stop_and_go: true       // Premium stop-and-go capability
    )
  ),
  tags: (
    market: "Premium Vehicles",
    segment: "D/E-segment / Luxury",
    price-point: "Premium",
    target-cost: "3200 EUR",
    euro-ncap: "5-star target",
    regulations: ("UN R152", "UN R130", "UN R157 ALKS"),
    level: "Level 2+ ADAS",
    asil-max: "D"
  )
)
