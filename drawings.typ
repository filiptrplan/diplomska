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

#let green = rgb("#059669")
#let violet = rgb("#7c3aed")

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
          text(fill: stroke-color, size: 0.8em)[#raw("'" + region)],
        )
      },
      name: group_name,
    )
  })
}

#let diagram-vsebovanosti-intuition2 = cetz.canvas({
  import cetz.draw: *
  on-layer(0, { content((0, 0), name: "L0", [`L0: &mut v`]) })
  region-subset("L0", "3", 0)
  region-subset("3", "1", 1)

  on-layer(0, { content((rel: (2.5, 0), to: (name: "L0", anchor: "east")), [`L1: &x`], name: "L1") })
  region-subset("L1", "4", 2)
  region-subset("4", "5", 3)
  region-subset("5", "2", 4)
  region-subset("2", "0", 5)
})

#let diagram-vsebovanosti-zacetna = cetz.canvas({
  import cetz.draw: *
  // 1. VRSTICA: r = &mut v
  // L0 je vsebovan v '3, '3 v '1
  on-layer(0, { content((0, 0), name: "L0", [`L0: &mut v`]) })
  region-subset("L0", "3", 0)
  region-subset("3", "1", 1)

  // Invariančnost pri dodelitvi r: '0: '2 in '2: '0
  on-layer(0, { content((3.5, 0), name: "R0_1", [`'0`]) })
  region-subset("R0_1", "2", 2, name_suffix: "_inv1")

  on-layer(0, { content((5.5, 0), name: "R2_1", [`'2`]) })
  region-subset("R2_1", "0", 3, name_suffix: "_inv2")

  // 2. VRSTICA: p = &x
  on-layer(0, { content((0, -2.5), name: "L1", [`L1: &x`]) })
  region-subset("L1", "4", 4)
  region-subset("4", "5", 5)

  // 3. VRSTICA: r.push(p)
  // '5 vsebovan v '2
  on-layer(0, { content((3.5, -2.5), name: "R5_1", [`'5`]) })
  region-subset("R5_1", "2", 2, name_suffix: "_push")

  // 4. VRSTICA: take(v)
  // '0 vsebovan v '6
  on-layer(0, { content((6.5, -2.5), name: "R0_2", [`'0`]) })
  region-subset("R0_2", "6", 6)
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
  node(pos, shape: rect, fill: white, inset: 5pt, ..args, body)
}

#let r0 = `'0`;
#let r1 = `'1`;
#let r2 = `'2`;
#let r3 = `'3`;
#let r4 = `'4`;
#let r5 = `'5`;
#let r6 = `'6`;


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
          on-layer(0, {
            content(
              coord,
              text(fill: stroke-color, size: 0.8em)[#raw(region)],
              name: rectname,
            )
          })
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
            text(fill: stroke-color, size: 0.8em)[#raw(region)],
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

  let r02 = "'0 == '2"
  region(r02, 2, coord: (2, 0))
})

#let l5vsebovana = cetz.canvas({
  import cetz.draw: *
  region("'3", 0)
  region("'1", 1, subset: "'3")

  let r02 = "'0 == '2"
  region(r02, 4, coord: (2, 0))
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

#let final-example-graph-subset = diagram(
  node-stroke: 1pt,
  spacing: 2em,
  label-size: 8pt,
  // --- je_vsebovana ---
  node(
    (0, 0),
    [
      `let mut x: i32 = 22;` \
    ],
    name: <l1vsebovana>,
  ),
  edge("d", "-|>"),

  node(
    (0, 1),
    [
      `let mut v: Vec<&'0 i32> = vec![];` \
    ],
    name: <l3vsebovana>,
  ),

  edge("d", "-|>"),
  node(
    (0, 2),
    [
      `let r: &'1 mut Vec<&'2 i32> = &'3 mut v;` \
      #l4vsebovana
    ],
    name: <l4vsebovana>,
  ),

  edge("d", "-|>"),
  node(
    (0, 3),
    [
      `let p: &'5 i32 = &'4 x;` \
      #l5vsebovana
    ],
    name: <l5vsebovana>,
  ),

  edge("d", "-|>"),
  node(
    (0, 4),
    [
      `r.push(p);` \
      #l6vsebovana
    ],
    name: <l6vsebovana>,
    shape: rect,
  ),

  edge("d", "-|>"),
  node(
    (0, 5),
    [
      `x += 1;` \
      #l6vsebovana
    ],
    shape: rect,
    name: <l7vsebovana>,
  ),

  edge("d", "-|>"),
  node(
    (0, 6),
    [
      `take::<Vec<&'6 i32>>(v);` \
      #l8vsebovana
    ],
    name: <l8vsebovana>,
    shape: rect,
  ),

  // node(enclose: (<l1vsebovana>, <l4vsebovana>, <l8vsebovana>), name: <vsebovana-enclose>),
  // fletcher-title(<vsebovana-enclose.north-west>, [`vsebovana`]),
)


#let l4zahteva = cetz.canvas({
  import cetz.draw: *
  let r02 = "'0 == '2"
  on-layer(0, { content((0, 0), name: "L0", [`L0: &mut v`]) })
  region-subset("L0", "3", 0)
  region-subset("3", "1", 1)
})

#let l5zahteva = cetz.canvas({
  import cetz.draw: *
  on-layer(0, { content((0, 0), name: "L0", [`L0: &mut v`]) })
  region-subset("L0", "3", 0)
  region-subset("3", "1", 1)


  on-layer(0, { content((3, 0), name: "L1", [`L1: &x`]) })
  region-subset("L1", "4", 2)
  region-subset("4", "5", 3)
})


#let l6zahteva = cetz.canvas({
  import cetz.draw: *
  let r02 = "0 == '2"
  on-layer(0, { content((0, 0), name: "L0", [`L0: &mut v`]) })
  region-subset("L0", "3", 0)
  region-subset("3", "1", 1)


  on-layer(0, { content((3, 0), name: "L1", [`L1: &x`]) })
  region-subset("L1", "4", 2)
  region-subset("4", "5", 3)
  region-subset("5", r02, 4)
})


#let l8zahteva = cetz.canvas({
  import cetz.draw: *
  let r02 = "0 == '2"
  on-layer(0, { content((0, 0), name: "L0", [`L0: &mut v`]) })
  region-subset("L0", "3", 0)
  region-subset("3", "1", 1)


  on-layer(0, { content((4, 0), name: "L1", [`L1: &x`]) })
  region-subset("L1", "4", 2)
  region-subset("4", "5", 3)
  region-subset("5", r02, 4)
  region-subset(r02, "6", 5)
})

#let final-example-graph-zahteva = diagram(
  node-stroke: 1pt,
  spacing: 2em,
  label-size: 8pt,
  // --- je_zahteva ---
  node(
    (0, 0),
    [
      `let mut x: i32 = 22;` \
    ],
    name: <l1zahteva>,
  ),
  edge("d", "-|>"),

  node(
    (0, 1),
    [
      `let mut v: Vec<&'0 i32> = vec![];` \
    ],
    name: <l3zahteva>,
  ),

  edge("d", "-|>"),
  node(
    (0, 2),
    [
      `let r: &'1 mut Vec<&'2 i32> = &'3 mut v;` \
      #l4zahteva
    ],
    name: <l4zahteva>,
  ),

  edge("d", "-|>"),
  node(
    (0, 3),
    [
      `let p: &'5 i32 = &'4 x;` \
      #l5zahteva
    ],
    name: <l5zahteva>,
  ),

  edge("d", "-|>"),
  node(
    (0, 4),
    [
      `r.push(p);` \
      #l6zahteva
    ],
    name: <l6zahteva>,
  ),

  edge("d", "-|>"),
  node(
    (0, 5),
    [
      `x += 1;` \
      #l6zahteva
    ],
    shape: rect,
    name: <l7zahteva>,
  ),

  edge("d", "-|>"),
  node(
    (0, 6),
    [
      `take::<Vec<&'6 i32>>(v);` \
      #l8zahteva
    ],
    name: <l8zahteva>,
    shape: rect,
  ),

  // node(enclose: (<l1vsebovana>, <l4vsebovana>, <l8vsebovana>), name: <vsebovana-enclose>),
  // fletcher-title(<vsebovana-enclose.north-west>, [`vsebovana`]),
)

#let final-example-graph-active = diagram(
  node-stroke: 1pt,
  spacing: 2em,
  label-size: 8pt,
  node(
    (0, 0),
    [
      `let mut x: i32 = 22;` \
      ${}$
    ],
    name: <l2aktivna>,
  ),
  edge("d", "-|>"),

  node(
    (0, 1),
    [
      `let mut v: Vec<&'0 i32> = vec![];` \
      ${r0}$
    ],
    name: <l3aktivna>,
  ),

  edge("d", "-|>"),
  node(
    (0, 2),
    [
      `let r: &'1 mut Vec<&'2 i32> = &'3 mut v;` \
      ${r0, r1, r2, r3}$
    ],
    name: <l4aktivna>,
  ),

  edge("d", "-|>"),
  node(
    (0, 3),
    [
      `let p: &'5 i32 = &'4 x;` \
      ${r0, r1, r2, r3, r4, r5}$
    ],
    name: <l5aktivna>,
  ),

  edge("d", "-|>"),
  node(
    (0, 4),
    [
      `r.push(p);` \
      ${r0, r1, r2, r3, r4, r5}$
    ],
    name: <l6aktivna>,
  ),

  edge("d", "-|>"),
  node(
    (0, 5),
    [
      `x += 1;` \
      ${r0, r4}$
    ],
    shape: rect,
    name: <l7aktivna>,
  ),

  edge("d", "-|>"),
  node(
    (0, 6),
    [
      `take::<Vec<&'6 i32>>(v);` \
      ${r0, r4, r6}$
    ],
    name: <l8aktivna>,
  ),

  // node(enclose: (<l2aktivna>, <l4aktivna>, <l8aktivna>), name: <aktivna-enclose>),
  // fletcher-title(<aktivna-enclose.north-west>, [`je_regija_aktivna`]),
)

#let cfg-example = diagram(
  node-stroke: 1pt,
  spacing: 2em,
  label-size: 8pt,

  // --- Osnovni blok bb0 (Vstop in If pogoj) ---
  node((0, 0), [$S(s_1)$], name: <s1s>),
  edge(<s1s>, <s1m>, "-|>"),
  node((0, 1), [$M(s_1):$ #raw("_2 = const 1_i32")], name: <s1m>), // x = 1
  edge(<s1m>, <s2s>, "-|>"),
  node((0, 2), [$S(s_2)$], name: <s2s>),
  edge(<s2s>, <s2m>, "-|>"),
  node((0, 3), [$M(s_2):$ #raw("switchInt(_1)")], name: <s2m>),

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
  node((0, 6), [$M(s_3):$ #raw("_2 = const 2_i32")], name: <s3m>),
  edge(<s3m>, <s4s>, "-|>"),
  node((0, 7), [$S(s_4)$], name: <s4s>),
  edge(<s4s>, <s4m>, "-|>"),
  node((0, 8), [$M(s_4):$ #raw("goto -> bb2")], name: <s4m>),

  node(
    enclose: (<s3s>, <s4m>, <s3m>),
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
  node((2, 6), [$M(s_5):$ #raw("_3 = _2")], name: <s5m>), // y = x
  edge(<s5m>, <s6s>, "-|>"),
  node((2, 7), [$S(s_6)$], name: <s6s>),
  edge(<s6s>, <s6m>, "-|>"),
  node((2, 8), [$M(s_6):$ #raw("_0 = const ()")], name: <s6m>), // y = x
  edge(<s6m>, <s7s>, "-|>"),
  node((2, 9), [$S(s_7)$], name: <s7s>),
  edge(<s7s>, <s7m>, "-|>"),
  node((2, 10), [$M(s_7):$ #raw("return")], name: <s7m>),

  node(
    enclose: (<s5s>, <s7m>, <s6m>),
    stroke: black,
    fill: gray.lighten(90%),
    inset: 10pt,
    snap: -1,
    name: <bb2>,
  ),
  fletcher-title(<bb2.north-east>)[`BB2`],

  // --- Povezave terminatorjev ---
  // Iz BB0 (switchInt) v BB1 (true) in BB2 (false)
  edge(<s2m.south>, <s3s.north>, [`true`], "-|>", label-anchor: "east", label-sep: -4pt),
  edge(<s2m.south>, (0, 4), (2, 4), <s5s.north>, [`false`], label-sep: 2pt, "-|>"),

  // Iz BB1 (goto) v BB2
  edge(<s4m.east>, (1, 8), (1, 5), <s5s.west>, "-|>"),
)

#let posoje = `posoje`
#let regije = `regije`
#let stavki = `stavki`
#let točke = `točke`
#let jevsebovanazacetno = `je_vsebovana_zacetno`
#let regijaposojena = `regija_posojena`
#let regijaaktivnana = `regija_aktivna_na`
#let posojaprekinjenana = `posoja_prekinjena_na`
#let posojarazveljavljenana = `posoja_razveljavljena_na`
#let jevsebovana = `je_vsebovana`
#let zahteva = `zahteva`
#let posojaaktivnana = `posoja_aktivna_na`
#let napaka = `napaka`

#let bgred = red.lighten(50%).transparentize(70%)
#let bgviolet = violet.lighten(50%).transparentize(70%)

#let polonius-diagram = diagram(
  node-stroke: 1pt,
  edge-stroke: 0.6pt,
  spacing: 2em,
  label-size: 8pt,
  node-corner-radius: 3pt,
  node((0, 0), jevsebovanazacetno, name: <jevsebovanazacetno>, fill: bgred, stroke: red),
  node((1, 1), regijaaktivnana, name: <regijaaktivnana>, fill: bgred, stroke: red),
  node((2, 0), regijaposojena, name: <regijaposojena>, fill: bgred, stroke: red),
  node((2.7, 1), posojaprekinjenana, name: <posojaprekinjenana>, fill: bgred, stroke: red),
  node((0, 2), jevsebovana, name: <jevsebovana>, fill: bgviolet, stroke: violet),
  node((2, 2), zahteva, name: <zahteva>, fill: bgviolet, stroke: violet),
  node((1, 3), posojaaktivnana, name: <posojaaktivnana>, fill: bgviolet, stroke: violet),
  node((1, 4), napaka, name: <napaka>, fill: bgviolet, stroke: violet),
  node((2, 4), posojarazveljavljenana, name: <posojarazvljevljenana>, fill: bgred, stroke: red),
  edge(<jevsebovanazacetno>, <jevsebovana>, "-|>"),
  edge(<regijaaktivnana>, <jevsebovana>, "-|>"),
  edge(<jevsebovana>, <zahteva>, "-|>"),
  edge(<regijaposojena>, <zahteva>, "-|>"),
  edge(<posojaprekinjenana>, <zahteva>, "-|>"),
  edge(<regijaaktivnana>, <posojaaktivnana>, "-|>"),
  edge(<zahteva>, <posojaaktivnana>, "-|>"),
  edge(<posojaaktivnana>, <napaka>, "-|>"),
  edge(<posojarazvljevljenana>, <napaka>, "-|>"),
)
