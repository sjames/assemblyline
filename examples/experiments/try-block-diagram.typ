#import "@preview/cetz:0.4.2"

#cetz.canvas(length: 1cm, {
  import cetz.draw: *
//  import cetz.anchor

  // Reusable SysML block function – now a simple function with drawing commands
  let sysml-block(
    pos: (0,0),
    name: "BlockName",
    instance-of: none,
    stereotype: "block",
    properties: (),
    operations: (),
    parts: (),
    width: 4,
    height: none,
    group-name: "block"
  ) = {
    group(name: group-name, {  // No ctx here anymore
      translate(pos)
    import cetz.draw: *

      // Count compartments (step-by-step)
      let comp-count = 1  // name compartment always present
      if stereotype != none { comp-count += 1 }
      if properties.len() > 0 { comp-count += 1 }
      if operations.len() > 0 { comp-count += 1 }
      if parts.len() > 0 { comp-count += 1 }

      let comp-height = 1.2
      let total-height = if height == none { comp-count * comp-height } else { height }

      // Main rectangle
      rect((-width/2, -total-height/2), (width/2, total-height/2),
           stroke: black, fill: white)

      // Helper for separators
      let draw-line(y) = line((-width/2, y), (width/2, y))

      let y = total-height/2

      // Stereotype
      if stereotype != none {
        content((0, y - comp-height/2), [«#stereotype»])
        draw-line(y - comp-height)
        y -= comp-height
      }

      // Name compartment
      let name-content = if instance-of != none {
        underline[#name : #instance-of]
      } else {
        [#name]
      }
      content((0, y - comp-height/2), name-content, weight: "bold")
      draw-line(y - comp-height)
      y -= comp-height

      // Properties
      if properties.len() > 0 {
        content((0, y - comp-height/2),
          properties.map(p => [- #p]).join(linebreak()))
        draw-line(y - comp-height)
        y -= comp-height
      }

      // Operations
      if operations.len() > 0 {
        content((0, y - comp-height/2),
          operations.map(o => [+ #o]).join(linebreak()))
        draw-line(y - comp-height)
        y -= comp-height
      }

      // Parts
      if parts.len() > 0 {
        content((0, y - comp-height/2),
          parts.map(p => [~ #p]).join(linebreak()))
      }

      // Anchors

     anchor("center", (0,0))
     anchor("north", (0, total-height/2))
     anchor("south", (0, -total-height/2))
     anchor("west", (-width/2, 0))
     anchor("east", (width/2, 0))


    })
  }

  // Draw the blocks – just call the function (no extra () needed)
  sysml-block(
    pos: (0, 4),
    name: "Vehicle",
    stereotype: "block",
    properties: ("mass : Real", "velocity : Real"),
    operations: ("accelerate()", "brake()"),
    group-name: "veh"
  )

  sysml-block(
    pos: (8, 4),
    name: "myCar",
    instance-of: "Vehicle",
    properties: ("mass = 1500 kg",),
    group-name: "car"
  )

  sysml-block(
    pos: (4, -1),
    name: "Engine",
    properties: ("power : kW",),
    group-name: "eng"
  )

  // Relationships
  line("veh.south", "eng.north", mark: (end: ">"))
  line("veh.south-west", "car.north-east",
       mark: (start: "diamond", fill: white))
})

