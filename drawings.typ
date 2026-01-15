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
