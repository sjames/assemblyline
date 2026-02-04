// diagram.typ
// One single file – just paste into typst.app or compile locally

#set page(width: auto, height: auto, margin: 1.5cm)
#set text(font: ("Linux Biolinum", "Noto Sans"), size: 11pt)

#let block-def(name, parts: ()) = box(
  width: 220pt,
  stroke: black + 1.6pt,
  inset: 14pt,
  radius: 8pt,
  fill: rgb("#f0f4ff"),
)[
  #align(center)[
    #text(size: 13pt, weight: "bold", smallcaps("block")) \
    #text(size: 16pt, weight: "bold", name)
    #if parts.len() > 0 {
      v(8pt)
      line(length: 100%, stroke: 1pt)
      v(8pt)
      align(left)[#list(marker: none, ..parts.map(strong))]
    }
  ]
]

#let block-instance(name: "", type: "", props: (), width: 150pt) = {

  // title bar is name:Type
  let titlebar = name+":"+ underline(offset: 2pt, text(weight: "bold", type));
  let stereo_type = "<<>>";
  let type-underline = underline(offset: 2pt, text(weight: "bold", type))
  box(
    width: width,
    stroke: black + 1.2pt,
    inset: 0pt,
    radius: 0pt,
    fill: white,
  )[
    
    #v(7pt)
    #align(center)[#text(weight: "semibold", titlebar)]
    #v(-4pt)
    
    #if props.len() > 0 {
      line(length: 100%, stroke: 0.6pt)
      align(left)[
        #table(
          columns: 1fr,
          inset: 6pt,
          stroke: none,
          ..props.map(p => text(size: 10pt, p))
        )
      ]
    }
  ]
}

// ────── Diagram ──────
#align(center)[

  #block-instance(
          name: "myCar",
          type: "Car",
          props: ("color = red", "mileage = 8 200 km", "owner = Alice"),
  )  

 
]

#v(2cm)
#text(size: 10pt, gray, "SysML-style block definition with instances – pure Typst")

