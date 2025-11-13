#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()
#codly(languages: codly-languages)
#show raw: set text(size: 9pt)

#let rule_table = [
  #show figure: set block(breakable: true)
  #set block(breakable: true)
  #set raw(block: true)
  #show raw: set block(breakable: false)
  #codly(display-name: false, display-icon: false, number-format: none)
  #figure(
    kind: table,
    table(
      columns: (1fr, 1fr),
      align: (left, left),

      table.header[*Pozitiven primer*][*Negativen primer*],

      table.cell(colspan: 2, fill: gray.lighten(80%))[*Use-Init*],
      {
        codly(
          highlights: (
            (line: 3, start: 5, end: 8, fill: green),
            (line: 5, start: 5, end: 8, fill: green),
            (line: 7, start: 9, end: 9, fill: green),
          ),
        )
        ```rust
        let x: u32;
        if random() {
            x = 17;
        } else {
            x = 18;
        }
        let y = x + 1;
        ```
      },
      {
        codly(
          highlights: (
            (line: 3, start: 5, end: 8, fill: green),
            (line: 6, start: 9, end: 9, fill: red),
          ),
        )
        ```rust
        let x: u32;
        if random() {
            x = 17;
        }
        // ERROR: x not initialized:
        let y = x + 1;
        ```
      },
      table.cell(colspan: 2, fill: gray.lighten(80%))[*Move-Deinit*],
      {
        codly(
          highlights: (
            (line: 2, start: 16, end: 22, fill: green),
            (line: 4, start: 9, end: 15, fill: green),
          ),
        )
        ```rust
        let tuple = (vec![1], vec![2]);
        moves_argument(tuple.1);
        // Does not overlap tuple.1:
        let x = tuple.0[0];
        ```
      },
      {
        codly(
          highlights: (
            (line: 2, start: 16, end: 22, fill: green),
            (line: 4, start: 9, end: 15, fill: red),
          ),
        )
        ```rust
        let tuple = (vec![1], vec![2]);
        moves_argument(tuple.0);
        // ERROR: use of moved value:
        let x = tuple.0[0];
        ```
      },
      table.cell(colspan: 2, fill: gray.lighten(80%))[*Shared-Readonly*],
      {
        codly(
          highlights: (
            (line: 3, start: 9, end: 13, fill: green),
            (line: 4, start: 9, end: 13, fill: green),
            (line: 5, start: 11, end: 11, fill: green),
            (line: 5, start: 25, end: 25, fill: green),
          ),
        )
        ```rust
        struct Point(u32, u32);
        let mut pt = Point(13, 17);
        let x = &pt;
        let y = &pt;
        dummy_use(x); dummy_use(y);
        ```
      },
      {
        codly(
          highlights: (
            (line: 3, start: 9, end: 13, fill: green),
            (line: 6, start: 0, end: 9, fill: red),
            (line: 7, start: 11, end: 11, fill: green),
          ),
        )
        ```rust
        struct Point(u32, u32);
        let mut pt = Point(13, 17);
        let x = &pt;
        // ERROR: assigned to
        //   borrowed value:
        pt.0 += 1;
        dummy_use(x);
        ```
      },

      table.cell(colspan: 2, fill: gray.lighten(80%))[*Unique-Write*],
      {
        codly(
          highlights: (
            (line: 3, start: 9, end: 18, fill: green),
            (line: 4, start: 9, end: 18, fill: green),
            (line: 6, start: 11, end: 11, fill: green),
          ),
        )
        ```rust
        struct Point(u32, u32);
        let mut pt = Point(13, 17);
        let x = &mut pt;
        let y = &mut pt;
        //dummy_use(x);
        dummy_use(y);
        ```
      },
      {
        codly(
          highlights: (
            (line: 3, start: 9, end: 18, fill: red),
            (line: 6, start: 9, end: 18, fill: red),
            (line: 7, start: 11, end: 11, fill: red),
            (line: 8, start: 11, end: 11, fill: green),
          ),
        )
        ```rust
        struct Point(u32, u32);
        let mut pt = Point(13, 17);
        let x = &mut pt;
        // ERROR: cannot borrow `pt`
        // as mutable more than once:
        let y = &mut pt;
        dummy_use(x);
        dummy_use(y);
        ```
      },

      table.cell(colspan: 2, fill: gray.lighten(80%))[*Ref-Live*],
      {
        codly(
          highlights: (
            (line: 4, start: 5, end: 7, fill: green),
            (line: 7, start: 9, end: 11, fill: green),
          ),
        )
        ```rust
        struct Point(u32, u32);
        let pt = Point(6, 9);
        let x = {
            &pt
        }; // pt still in scope

        let z = x.0;
        ```
      },
      {
        codly(
          highlights: (
            (line: 4, start: 5, end: 7, fill: red),
            (line: 8, start: 9, end: 11, fill: red),
          ),
        )
        ```rust
        struct Point(u32, u32);
        let x = {
            let pt = Point(6, 9);
            &pt
        }; // pt goes out of scope
        // ERROR: pt does not live
        // long enough:
        let z = x.0;
        ```
      },
    ),
    caption: [Pravila preverjevalnika izposoj iz @stjernaModellingRustsReference. Pozitivni primeri predstavljajo mesta, kjer preverjevalnik sprejme kodo, negativni pa kjer jo zavrne.],
  ) <tab:borrow-check>
]

// reset codly stuff
#codly(display-name: true, display-icon: true, number-format: numbering.with("1"))
