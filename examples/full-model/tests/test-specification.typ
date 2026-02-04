#import "../packages/preview/assemblyline/main/lib/lib.typ": *

// Test case for Lane Departure Warning
#test_case("TC-LDW-001", title: "Lane Departure Warning - Unintended Drift", tags: (
  type: "functional",
  priority: "P1",
  automation: "HIL",
  asil: "B",
  euro-ncap: "required"
), links: (verify: ("REQ-LDW-001", "REQ-LDW-002")))[
  *Objective*: Verify LDW activates when vehicle drifts without turn signal.

  *Preconditions*:
  - Vehicle speed ≥ 60 km/h
  - Lane markings clearly visible
  - LDW function enabled
  - Turn signal OFF

  *Test Steps*:
  1. Drive vehicle at 80 km/h on straight road with visible lane markings
  2. Gradually steer toward lane boundary (0.3 m lateral offset)
  3. Continue drift until crossing lane marking
  4. Measure time from lane crossing to warning activation
  5. Verify warning modality (visual + audible)

  *Expected Results*:
  - Warning activates within 0.5s of lane crossing
  - Dashboard icon illuminates (amber)
  - Audible tone sounds (3 beeps, 80 dB)
  - No intervention on steering

  *Pass Criteria*:
  - Latency ≤ 500ms (per REQ-LDW-001)
  - Both visual and audible warnings active (per REQ-LDW-002)

  *Traceability*: Verifies REQ-LDW-001, REQ-LDW-002
]

// Test case for Automatic Emergency Braking
#test_case("TC-AEB-001", title: "AEB - Stationary Vehicle at 50 km/h", tags: (
  type: "safety-critical",
  priority: "P1",
  automation: "proving-ground",
  asil: "D",
  euro-ncap: "required",
  unece: "R152"
), links: (verify: ("REQ-AEB-001", "REQ-AEB-002")))[
  *Objective*: Verify AEB prevents collision with stationary vehicle.

  *Preconditions*:
  - Test vehicle speed: 50 km/h
  - Target: Stationary EURO NCAP vehicle surrogate (VSVT)
  - Clear weather, dry road
  - AEB function enabled

  *Test Steps*:
  1. Accelerate test vehicle to 50 km/h
  2. Approach stationary target vehicle on straight path
  3. Do NOT apply brakes (driver hands-off)
  4. Monitor AEB activation
  5. Measure TTC at brake activation
  6. Measure final stopping distance
  7. Record deceleration profile

  *Expected Results*:
  - AEB activates when TTC ≤ 2.5s
  - Full braking (≥ 10 m/s²) within 200ms
  - Vehicle stops before collision (stopping distance < initial distance - vehicle length)
  - No collision or contact with target

  *Pass Criteria*:
  - Collision avoided (per REQ-AEB-001)
  - Braking latency ≤ 200ms (per REQ-AEB-002)
  - Deceleration ≥ 10 m/s²

  *Traceability*: Verifies REQ-AEB-001, REQ-AEB-002
]

// Test case for Adaptive Cruise Control
#test_case("TC-ACC-001", title: "ACC - Speed Maintenance and Distance Control", tags: (
  type: "functional",
  priority: "P1",
  automation: "HIL",
  asil: "B"
), links: (verify: ("REQ-ACC-001", "REQ-ACC-002")))[
  *Objective*: Verify ACC maintains set speed and following distance.

  *Preconditions*:
  - ACC enabled at 100 km/h set speed
  - Time gap setting: 2.0 seconds
  - Lead vehicle present at 90 km/h

  *Test Steps*:
  1. Activate ACC at 100 km/h on straight road
  2. Introduce lead vehicle at 90 km/h
  3. Monitor vehicle speed adjustment
  4. Measure steady-state following distance
  5. Remove lead vehicle
  6. Monitor speed return to set speed

  *Expected Results*:
  - Vehicle decelerates smoothly to 90 km/h
  - Following distance stabilizes at 2.0s time gap (50 m at 90 km/h)
  - Distance error ≤ 0.2s (±5 m)
  - After lead vehicle removal, speed returns to 100 km/h
  - Speed error ≤ 2 km/h

  *Pass Criteria*:
  - Speed within ±2 km/h of target (per REQ-ACC-002)
  - Distance within ±0.2s of set time gap (per REQ-ACC-002)

  *Traceability*: Verifies REQ-ACC-001, REQ-ACC-002
]

// Test case for Lane Keeping Assist
#test_case("TC-LKA-001", title: "LKA - Steering Intervention and Driver Override", tags: (
  type: "functional",
  priority: "P1",
  automation: "HIL",
  asil: "C",
  unece: "R157"
), links: (verify: ("REQ-LKA-001", "REQ-LKA-002")))[
  *Objective*: Verify LKA applies corrective steering and allows driver override.

  *Preconditions*:
  - Vehicle speed ≥ 60 km/h
  - LKA enabled
  - Lane markings visible
  - Hands-on-wheel detection active

  *Test Steps*:
  1. Drive at 80 km/h with LKA active
  2. Induce lateral drift (0.2 m from lane center)
  3. Measure steering torque applied by LKA
  4. Verify vehicle returns to lane center
  5. Apply driver steering torque > 5 Nm
  6. Verify LKA deactivates

  *Expected Results*:
  - LKA applies corrective torque ≤ 3 Nm
  - Vehicle returns to ±0.1 m of lane center
  - Driver override torque > 5 Nm deactivates LKA immediately
  - No residual steering torque after override

  *Pass Criteria*:
  - Corrective torque ≤ 3 Nm (per REQ-LKA-001)
  - Driver override at > 5 Nm (per REQ-LKA-002)

  *Traceability*: Verifies REQ-LKA-001, REQ-LKA-002
]

// Test case for Sensor Fusion
#test_case("TC-PERC-001", title: "Sensor Fusion - Camera + Radar Detection", tags: (
  type: "integration",
  priority: "P1",
  automation: "HIL",
  asil: "D"
), links: (verify: ("REQ-SENS-001", "REQ-CAM-001", "REQ-RAD-001")))[
  *Objective*: Verify sensor fusion correctly combines camera and radar detections.

  *Preconditions*:
  - Camera system operational
  - Radar system operational
  - Test scenario: Single vehicle 50m ahead

  *Test Steps*:
  1. Place target vehicle 50m ahead in same lane
  2. Monitor camera detection (bounding box, classification)
  3. Monitor radar detection (range, velocity)
  4. Verify sensor fusion creates single fused object
  5. Compare fused object position with ground truth
  6. Introduce occlusion (camera blocked, radar operational)
  7. Verify continued tracking via radar only

  *Expected Results*:
  - Single fused object (not duplicate detections)
  - Position accuracy ≤ 0.5m
  - Velocity accuracy ≤ 0.5 m/s
  - Continued tracking during camera occlusion

  *Pass Criteria*:
  - Redundant perception via multiple sensors (per REQ-SENS-001)

  *Traceability*: Verifies REQ-SENS-001, REQ-CAM-001, REQ-RAD-001
]

// Test case for HMI
#test_case("TC-HMI-001", title: "HMI - ADAS Status Display", tags: (
  type: "functional",
  priority: "P2",
  automation: "manual",
  asil: "B"
), links: (verify: ("REQ-HMI-001", "REQ-CLUSTER-001")))[
  *Objective*: Verify HMI displays ADAS function status correctly.

  *Preconditions*:
  - Instrument cluster or HUD operational
  - ADAS functions enabled

  *Test Steps*:
  1. Power on vehicle
  2. Verify ADAS status icons displayed during startup
  3. Enable ACC function
  4. Verify ACC icon and set speed displayed
  5. Enable LKA function
  6. Verify LKA icon displayed
  7. Trigger LDW warning
  8. Verify warning icon and audible feedback

  *Expected Results*:
  - All ADAS icons visible and correct
  - Status updates within 100ms
  - Warnings clearly distinguishable (color, intensity, sound)

  *Pass Criteria*:
  - Clear visual and audible feedback (per REQ-HMI-001)

  *Traceability*: Verifies REQ-HMI-001, REQ-CLUSTER-001
]
