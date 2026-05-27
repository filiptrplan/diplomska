#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "@preview/cetz:0.4.2"

#let colors = (
  rgb("#e11d48"),
  rgb("#2563eb"),
  rgb("#059669"),
  rgb("#ca8a04"),
  rgb("#7c3aed"),
  rgb("#ea580c"),
  rgb("#0891b2"),
  rgb("#c026d3"),
)

#let drawing-code-size = 9pt
#let text-size = 9pt
#show raw: set text(size: text-size)

#let code-node(body) = [
  #set text(size: drawing-code-size)
  #body
]

#let region-subset(subset, region, color_idx, name_suffix: "") = {
  import cetz.draw: *
  let group_name = region + name_suffix
  let rectname = group_name + "rect"
  let color = colors.at(color_idx)
  let stroke-color = color.darken(40%)
  let bg-color = color.lighten(60%).transparentize(10%)
  on-layer(-color_idx - 1, {
    group(
      {
        rect-around(subset, padding: 0.2, radius: 0.1, name: rectname, stroke: stroke-color, fill: bg-color)
        content(
          (name: rectname, anchor: "north-west"),
          anchor: "south",
          padding: (bottom: 0.15, rest: 0),
          text(fill: stroke-color, size: text-size)[#raw("'" + region)],
        )
      },
      name: group_name,
    )
  })
}

#let region(region, color_idx, subset: none, name_suffix: "", coord: (0, 0)) = {
  import cetz.draw: *
  let group_name = region + name_suffix
  let rectname = group_name + "rect"
  let color = colors.at(color_idx)
  let stroke-color = color.darken(40%)
  let bg-color = color.lighten(60%).transparentize(10%)
  if subset == none {
    on-layer(-color_idx - 1, {
      group(
        {
          on-layer(0, { content(coord, text(fill: stroke-color, size: text-size)[#raw(region)], name: rectname) })
          rect-around(rectname, padding: 0.2, radius: 0.1, stroke: stroke-color, fill: bg-color)
        },
        name: group_name,
      )
    })
  } else {
    on-layer(-color_idx - 1, {
      group(
        {
          rect-around(
            subset,
            padding: (top: 0.55, rest: 0.2),
            radius: 0.1,
            name: rectname,
            stroke: stroke-color,
            fill: bg-color,
          )
          content(
            (name: rectname, anchor: "north-west"),
            anchor: "north-west",
            padding: (top: 0.15, left: 0.1, rest: 0),
            text(fill: stroke-color, size: text-size)[#raw(region)],
          )
        },
        name: group_name,
      )
    })
  }
}

#let l4vsebovana = cetz.canvas({
  import cetz.draw: *
  region("'3", 0)
  region("'1", 1, subset: "'3")
  region("'0 == '2", 2, coord: (2, 0))
})

#let l5vsebovana = cetz.canvas({
  import cetz.draw: *
  region("'3", 0)
  region("'1", 1, subset: "'3")
  region("'0 == '2", 4, coord: (2, 0))
  region("'4", 2, coord: (4, 0))
  region("'5", 3, subset: "'4")
})

#let l6vsebovana = cetz.canvas({
  import cetz.draw: *
  region("'3", 0)
  region("'1", 1, subset: "'3")
  let r02 = "'0 == '2"
  let r4 = "'4  "
  region(r4, 2, coord: (2.5, 0))
  region("'5", 3, subset: r4)
  region(r02, 4, subset: "'5")
})

#let l8vsebovana = cetz.canvas({
  import cetz.draw: *
  region("'3", 0)
  region("'1", 1, subset: "'3")
  let r02 = "'0 == '2"
  let r4 = "'4  "
  region(r4, 2, coord: (2.5, 0))
  region("'5", 3, subset: r4)
  region(r02, 4, subset: "'5")
  region("'6", 5, subset: r02)
})

#let r0 = `'0`;
#let r1 = `'1`;
#let r2 = `'2`;
#let r3 = `'3`;
#let r4 = `'4`;
#let r5 = `'5`;
#let r6 = `'6`;

#let jevsebovanazacetno = `je_vsebovana_zacetno`
#let regijaposojena = `regija_posojena`
#let regijaaktivnana = `regija_aktivna_na`
#let posojaprekinjenana = `posoja_prekinjena_na`
#let posojarazveljavljenana = `posoja_razveljavljena_na`
#let jevsebovana = `je_vsebovana`
#let zahteva = `zahteva`
#let posojaaktivnana = `posoja_aktivna_na`
#let napaka = `napaka`

#let violet = rgb("#7c3aed")
#let bgred = red.lighten(50%).transparentize(70%)
#let bgviolet = violet.lighten(50%).transparentize(70%)

#let polonius-diagram-original = diagram(
  node-stroke: 1pt,
  edge-stroke: 0.6pt,
  spacing: 2em,
  label-size: text-size,
  node-shape: rect,
  node-corner-radius: 3pt,
  node((0, 0), jevsebovanazacetno, name: <jevsebovanazacetno>, fill: bgred, stroke: red),
  node((1, 1), regijaaktivnana, name: <regijaaktivnana>, fill: bgred, stroke: red),
  node((2, 0), regijaposojena, name: <regijaposojena>, fill: bgred, stroke: red),
  node((2.7, 1), posojaprekinjenana, name: <posojaprekinjenana>, fill: bgred, stroke: red),
  node((0, 2), jevsebovana, name: <jevsebovana>, fill: bgviolet, stroke: violet),
  node((2, 2), zahteva, name: <zahteva>, fill: bgviolet, stroke: violet),
  node((1, 3), posojaaktivnana, name: <posojaaktivnana>, fill: bgviolet, stroke: violet),
  node((1, 4), napaka, name: <napaka>, fill: bgviolet, stroke: violet),
  node((2, 4), posojarazveljavljenana, name: <posojarazveljavljenana>, fill: bgred, stroke: red),
  edge(<jevsebovanazacetno>, <jevsebovana>, "-|>"),
  edge(<regijaaktivnana>, <jevsebovana>, "-|>"),
  edge(<jevsebovana>, <zahteva>, "-|>"),
  edge(<regijaposojena>, <zahteva>, "-|>"),
  edge(<posojaprekinjenana>, <zahteva>, "-|>"),
  edge(<regijaaktivnana>, <posojaaktivnana>, "-|>"),
  edge(<zahteva>, <posojaaktivnana>, "-|>"),
  edge(<posojaaktivnana>, <napaka>, "-|>"),
  edge(<posojarazveljavljenana>, <napaka>, "-|>"),
)

#let final-example-graph-active-horizontal = diagram(
  node-stroke: 1pt,
  edge-stroke: 0.6pt,
  spacing: 1.25em,
  label-size: 10pt,
  node-shape: rect,
  node-corner-radius: 3pt,

  node(
    (0, 0),
    code-node[`let mut x: i32 = 22;` \ ${}$],
    name: <l2aktivna>,
  ),
  node(
    (1, 0),
    code-node[`let mut v: Vec<&'0 i32> = vec![];` \ ${r0}$],
    name: <l3aktivna>,
  ),
  node(
    (2, 0),
    code-node[`let r: &'1 mut Vec<&'2 i32> = &'3 mut v;` \ ${r0, r1, r2, r3}$],
    name: <l4aktivna>,
  ),
  node(
    (2, 1.35),
    code-node[`let p: &'5 i32 = &'4 x;` \ ${r0, r1, r2, r3, r4, r5}$],
    name: <l5aktivna>,
  ),
  node(
    (1.25, 1.35),
    code-node[`r.push(p);` \ ${r0, r1, r2, r3, r4, r5}$],
    name: <l6aktivna>,
  ),
  node(
    (0.7, 1.35),
    code-node[`x += 1;` \ ${r0, r4}$],
    shape: rect,
    name: <l7aktivna>,
  ),
  node(
    (0, 1.35),
    code-node[`take::<Vec<&'6 i32>>(v);` \ ${r0, r4, r6}$],
    name: <l8aktivna>,
  ),

  edge(<l2aktivna>, <l3aktivna>, "-|>"),
  edge(<l3aktivna>, <l4aktivna>, "-|>"),
  edge(<l4aktivna>, <l5aktivna>, "-|>"),
  edge(<l5aktivna>, <l6aktivna>, "-|>"),
  edge(<l6aktivna>, <l7aktivna>, "-|>"),
  edge(<l7aktivna>, <l8aktivna>, "-|>"),
)

#let final-example-graph-subset-horizontal = diagram(
  node-stroke: 1pt,
  edge-stroke: 0.6pt,
  spacing: 1.25em,
  label-size: 6pt,
  node-shape: rect,
  node-corner-radius: 3pt,

  node(
    (1, -0.2),
    code-node[`let mut x: i32 = 22;`],
    name: <l1vsebovana>,
  ),
  node(
    (1, 0.2),
    code-node[`let mut v: Vec<&'0 i32> = vec![];`],
    name: <l3vsebovana>,
  ),
  node(
    (2, 0),
    code-node[`let r: &'1 mut Vec<&'2 i32> = &'3 mut v;` \ #l4vsebovana],
    name: <l4vsebovana>,
  ),
  node(
    (3, 0),
    code-node[`let p: &'5 i32 = &'4 x;` \ #l5vsebovana],
    name: <l5vsebovana>,
  ),
  node(
    (3, 1.35),
    code-node[`r.push(p);` \ #l6vsebovana],
    name: <l6vsebovana>,
  ),
  node(
    (2, 1.35),
    code-node[`x += 1;` \ #l6vsebovana],
    shape: rect,
    name: <l7vsebovana>,
  ),
  node(
    (1, 1.35),
    code-node[`take::<Vec<&'6 i32>>(v);` \ #l8vsebovana],
    name: <l8vsebovana>,
    shape: rect,
  ),

  edge(<l1vsebovana>, <l3vsebovana>, "-|>"),
  edge(<l3vsebovana>, <l4vsebovana>, "-|>"),
  edge(<l4vsebovana>, <l5vsebovana>, "-|>"),
  edge(<l5vsebovana>, <l6vsebovana>, "-|>"),
  edge(<l6vsebovana>, <l7vsebovana>, "-|>"),
  edge(<l7vsebovana>, <l8vsebovana>, "-|>"),
)

#let l4zahteva = cetz.canvas({
  import cetz.draw: *
  on-layer(0, { content((0, 0), name: "L0", [`L0: &'3 mut v`]) })
  region-subset("L0", "3", 0)
  region-subset("3", "1", 1)
})

#let l5zahteva = cetz.canvas({
  import cetz.draw: *
  on-layer(0, { content((0, 0), name: "L0", [`L0: &'3 mut v`]) })
  region-subset("L0", "3", 0)
  region-subset("3", "1", 1)
  on-layer(0, { content((3, 0), name: "L1", [`L1: &'4 x`]) })
  region-subset("L1", "4", 2)
  region-subset("4", "5", 3)
})

#let l6zahteva = cetz.canvas({
  import cetz.draw: *
  let r02 = "0 == '2"
  on-layer(0, { content((0, 0), name: "L0", [`L0: &'3 mut v`]) })
  region-subset("L0", "3", 0)
  region-subset("3", "1", 1)
  on-layer(0, { content((3, 0), name: "L1", [`L1: &'4 x`]) })
  region-subset("L1", "4", 2)
  region-subset("4", "5", 3)
  region-subset("5", r02, 4)
})

#let l8zahteva = cetz.canvas({
  import cetz.draw: *
  let r02 = "0 == '2"
  on-layer(0, { content((0, 0), name: "L0", [`L0: &'3 mut v`]) })
  region-subset("L0", "3", 0)
  region-subset("3", "1", 1)
  on-layer(0, { content((4, 0), name: "L1", [`L1: &'4 x`]) })
  region-subset("L1", "4", 2)
  region-subset("4", "5", 3)
  region-subset("5", r02, 4)
  region-subset(r02, "6", 5)
})

#let final-example-graph-zahteva-horizontal = diagram(
  node-stroke: 1pt,
  edge-stroke: 0.6pt,
  spacing: 1.25em,
  label-size: 6pt,
  node-shape: rect,
  node-corner-radius: 3pt,

  node(
    (1, -0.2),
    code-node[`let mut x: i32 = 22;`],
    name: <l1zahteva>,
  ),
  node(
    (1, 0.2),
    code-node[`let mut v: Vec<&'0 i32> = vec![];`],
    name: <l3zahteva>,
  ),
  node(
    (2, 0),
    code-node[`let r: &'1 mut Vec<&'2 i32> = &'3 mut v;` \ #l4zahteva],
    name: <l4zahteva>,
  ),
  node(
    (3, 0),
    code-node[`let p: &'5 i32 = &'4 x;` \ #l5zahteva],
    name: <l5zahteva>,
  ),
  node(
    (3, 1.35),
    code-node[`r.push(p);` \ #l6zahteva],
    name: <l6zahteva>,
  ),
  node(
    (2, 1.35),
    code-node[`x += 1;` \ #l6zahteva],
    shape: rect,
    name: <l7zahteva>,
  ),
  node(
    (1, 1.35),
    code-node[`take::<Vec<&'6 i32>>(v);` \ #l8zahteva],
    name: <l8zahteva>,
  ),

  edge(<l1zahteva>, <l3zahteva>, "-|>"),
  edge(<l3zahteva>, <l4zahteva>, "-|>"),
  edge(<l4zahteva>, <l5zahteva>, "-|>"),
  edge(<l5zahteva>, <l6zahteva>, "-|>"),
  edge(<l6zahteva>, <l7zahteva>, "-|>"),
  edge(<l7zahteva>, <l8zahteva>, "-|>"),
)
