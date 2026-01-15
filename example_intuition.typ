#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()
#codly(languages: codly-languages)
#show raw: set text(size: 9pt)
#set page(width: 450pt, height: 265pt, margin: (x: 0cm, y: 0cm))

```rust
  fn main() {
    let mut x: i32 = 22;
    let mut v: Vec<&'0 i32> = vec![];
    let r: &'1 mut Vec<&'2 i32> = &'3 mut v;
    // ...
    // ...
    let p: &'5 i32 = &'4 x;
    // ...
    // ...
    r.push(p);
    // ...
    x += 1; // L1 in '0 aktivni tukaj
    take::<Vec<&'6 i32>>(v);
    // ...
  }
  fn take<T>(p: T) { .. }
```
