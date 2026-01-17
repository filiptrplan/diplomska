#import "@preview/cetz:0.4.2"
#let colors = (
  rgb("#e11d48"), // Rose 600
  rgb("#2563eb"), // Blue 600
  rgb("#059669"), // Emerald 600
  rgb("#ca8a04"), // Yellow 600
  rgb("#7c3aed"), // Violet 600
  rgb("#ea580c"), // Orange 600
  rgb("#0891b2"), // Cyan 600
  rgb("#c026d3"), // Fuchsia 600
  rgb("#4f46e5"), // Indigo 600
  rgb("#16a34a"), // Green 600
  rgb("#db2777"), // Pink 600
  rgb("#9333ea"), // Purple 600
  rgb("#2563eb"), // Blue 600 (repeated/alternative)
  rgb("#dc2626"), // Red 600
)
#let diagram-vsebovanosti-intuition2 = cetz.canvas({
  import cetz.draw: *
  let region-subset(subset, region, color_idx) = {
    let rectname = region + "rect"
    let color = colors.at(color_idx)
    let stroke-color = color.darken(10%)
    let bg-color = color.lighten(80%)
    on-layer(-color_idx - 1, {
      group(
        {
          rect-around(subset, padding: 0.2, radius: 0.1, name: rectname, stroke: stroke-color, fill: bg-color)
          content(
            (name: rectname, anchor: "north-west"),
            anchor: "south",
            padding: (
              bottom: 0.15,
              rest: 0,
            ),
            text(fill: stroke-color)[#raw("'" + region)],
          )
        },
        name: region,
      )
    })
  }
  on-layer(0, { content((0, 0), name: "L0", [`L0: &mut v`]) })
  region-subset("L0", "3", 0)
  region-subset("3", "1", 1)

  on-layer(0, { content((rel: (2.5, 0), to: (name: "L0", anchor: "east")), [`L1: &x`], name: "L1") })
  region-subset("L1", "4", 2)
  region-subset("4", "5", 3)
  region-subset("5", "2", 4)
  region-subset("2", "0", 5)
})



#let aktivnosti-regij-intuition2 = cetz.canvas({
  import cetz.draw: *
  content((0, 0), anchor: "north-west", image("example_intuition.pdf", page: 1))
  let draw-line(start-line, end-line, x, color-idx, region, dir: "right") = {
    let line-height = 0.545
    let color = colors.at(color-idx)
    let y-start = -(start-line - 1) * line-height
    let y-end = -(end-line - 1) * line-height
    let y-mid = (y-start + y-end) / 2
    let linename = region + "line"
    let line-stroke = color + 1.15pt
    line((x, y-start), (x, y-end), stroke: line-stroke, name: linename)
    let end-offset = if dir == "right" { +0.15 } else { -0.15 }
    line((x, y-start), (x + end-offset, y-start), stroke: line-stroke)
    line((x, y-end), (x + end-offset, y-end), stroke: line-stroke)
    let text-offset = if dir == "right" { -0.1 } else { 0.1 }
    content((rel: (text-offset, 0), to: (name: linename, anchor: "50%")), anchor: "west", text(
      fill: color,
      weight: "bold",
      raw(
        "'" + region,
      ),
    ))
  }
  let o(idx) = 9.5 + idx * 0.65 // helper function for x calculation
  draw-line(3, 14, o(0), 0, "0", dir: "left")
  draw-line(4, 11, o(1), 1, "1", dir: "left")
  draw-line(4, 11, o(2), 2, "2", dir: "left")
  draw-line(4, 11, o(3), 3, "3", dir: "left")
  draw-line(7, 11, o(4), 4, "4", dir: "left")
  draw-line(7, 11, o(5), 5, "5", dir: "left")
  draw-line(13, 14, o(6), 6, "6", dir: "left")
})


#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#let fletcher-title(pos, body, ..args) = {
  body = text(size: 10pt, body)
  node(pos, shape: rect, fill: white, inset: 3pt, ..args, body)
}

#let cfg-example = diagram(
  node-stroke: 1pt,
  spacing: 2em,
  label-size: 8pt,

  // --- Osnovni blok bb0 (Vstop in If pogoj) ---
  node((0, 0), [$S(s_1)$], name: <s1s>),
  edge(<s1s>, <s1m>, "-|>"),
  node((0, 1), [$M(s_1):$ #raw("_1 = 1")], name: <s1m>), // x = 1
  edge(<s1m>, <s2s>, "-|>"),
  node((0, 2), [$S(s_2)$], name: <s2s>),
  edge(<s2s>, <s2m>, "-|>"),
  node((0, 3), [$M(s_2):$ #raw("switchInt(pogoj)")], name: <s2m>),

  node(
    enclose: (<s1s>, <s2m>),
    stroke: black,
    fill: gray.lighten(90%),
    inset: 10pt,
    snap: -1,
    name: <bb0>,
  ),
  fletcher-title(<bb0.north-west>)[`BB0`],

  // --- Osnovni blok bb1 (True veja: x = 2) ---
  node((0, 5), [$S(s_3)$], name: <s3s>),
  edge(<s3s>, <s3m>, "-|>"),
  node((0, 6), [$M(s_3):$ #raw("_1 = 2")], name: <s3m>),
  edge(<s3m>, <s4s>, "-|>"),
  node((0, 7), [$S(s_4)$], name: <s4s>),
  edge(<s4s>, <s4m>, "-|>"),
  node((0, 8), [$M(s_4):$ #raw("goto")], name: <s4m>),

  node(
    enclose: (<s3s>, <s4m>),
    stroke: black,
    fill: gray.lighten(90%),
    inset: 10pt,
    snap: -1,
    name: <bb1>,
  ),
  fletcher-title(<bb1.north-west>)[`BB1`],

  // --- Osnovni blok bb2 (Združitev: let y = x) ---
  node((2, 5), [$S(s_5)$], name: <s5s>),
  edge(<s5s>, <s5m>, "-|>"),
  node((2, 6), [$M(s_5):$ #raw("_2 = _1")], name: <s5m>), // y = x
  edge(<s5m>, <s6s>, "-|>"),
  node((2, 7), [$S(s_6)$], name: <s6s>),
  edge(<s6s>, <s6m>, "-|>"),
  node((2, 8), [$M(s_6):$ #raw("return")], name: <s6m>),

  node(
    enclose: (<s5s>, <s6m>),
    stroke: black,
    fill: gray.lighten(90%),
    inset: 10pt,
    snap: -1,
    name: <bb2>,
  ),
  fletcher-title(<bb2.north-east>)[`BB2`],

  // --- Povezave terminatorjev ---
  // Iz BB0 (switchInt) v BB1 (true) in BB2 (false)
  edge(<s2m.south>, <s3s.north>, [`true`], "-|>"),
  edge(<s2m.south>, (0, 4), (2, 4), <s5s.north>, [`false`], label-sep: 2pt, "-|>"),

  // Iz BB1 (goto) v BB2
  edge(<s4m.east>, (1, 8), (1, 5), <s5s.west>, "-|>"),
)
