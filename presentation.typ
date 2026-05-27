#import "@preview/touying:0.7.3": *
#import themes.university: *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.6.0": *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import cosmos.clouds: *
#import "@preview/showybox:2.0.4": showybox
#show: show-theorion
#show: codly-init.with()
#codly(languages: codly-languages)

#let theorem = theorem.with(supplement: "Izrek")
#let definition = definition.with(supplement: "Definicija")
#let lemma = lemma.with(supplement: "Lema")
#let corollary = corollary.with(supplement: "Posledica")
#let proposition = proposition.with(supplement: "Trditev")
#let example = example.with(supplement: "Primer")
#let remark = remark.with(supplement: "Opomba")
#let proof = proof.with(supplement: "Dokaz")

#show: university-theme.with(
  aspect-ratio: "16-9",
  // align: horizon,
  // config-common(handout: true),
  config-info(
    title: [Formalizacija originalne formulacije Poloniusa],
    subtitle: [Predstavitev diplomske naloge],
    author: [Filip Trplan],
    date: datetime(year: 2026, month: 6, day: 1),
    institution: [Univerza v Ljubljani],
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#title-slide()


= Uvod

== Par predpostavk...

+ Osnovno znanje Rusta in njegove sintakse #pause
+ Osnove prevajalnikov in upravljanja pomnilnika #pause
+ Rust različica `1.95.0` #pause
+ Velikokrat se bomo zanašali na nepopolne vire ali izvorno kodo prevajalnika

== Preden začnemo

moramo še razjasniti dva pojma.

#definition[
  *Varen program* je program, ki ne povzroča pomnilniških napak. ]

#pause

#definition[
  *Veljaven program* pa je program, ki ustreza Rustovim pravilom lastništva in izposojanja.
]

== Kratek uvod v Rustovo upravljanje pomnilnika

- Poznamo ročno in avtomatsko upravljanje pomnilnika
- Rust ubere vmesno pot
- Komponenta prevajalnika: *preverjevalnik izposoj*
- Pravila *lastništva*

#pause

#columns(2)[
  #showybox(
    title: "Prednosti",
    frame: (
      body-color: green.lighten(80%),
      title-color: green.lighten(60%),
      border-color: green.darken(20%),
    ),
    title-style: (
      color: black,
    ),
    [
      - Zagotavljanje pomnilniške varnosti v času prevajanja
      - "Če se prevede, dela"
      - "Brezplačna" pomnilniška varnost
    ],
  )
  #colbreak()
  #pause
  #showybox(
    title: "Slabosti",
    frame: (
      body-color: red.lighten(80%),
      title-color: red.lighten(60%),
      border-color: red.darken(20%),
    ),
    title-style: (
      color: black,
    ),
    [
      - Počasnejši čas prevajanja
      - Nekateri varni programi se ne prevedejo
    ],
  )
]

== Zgodovina razvoja preverjevalnika izposoj

- Sprva bil zelo osnoven, zavrnil veliko veljavnih programov
- *NLL* (non-lexical lifetimes) ga nadgradi
- Trenutno v uporabi NLL
- Naslednja generacija: *Polonius*

== Cilj diplomske naloge

- Polonius do sedaj nikoli uradno formalno opisan
- Magistrska naloga Amande Stjerne
- Originalne spletne objave
- Implementacija v Rustovem prevajalniku #pause
- *Želimo na matematično formalen način opisati konceptualno delovanje Poloniusa*

= Preverjevalnik izposoj

== Deljene reference

Obstajata dve vrsti referenc (zapis `&x`):

#definition(title: "Deljene reference", [
  To so reference, ki nam omogočajo, da ustvarimo več referenc na isto mesto hkrati. Zato morajo biti tudi _nespremenljive_, kar pomeni, da podatkov na referenciranem mestu ne smemo spreminjati. To pravilo mora veljati, da je uporaba tovrstnih referenc varna.
])

== Unikatne reference

#definition(
  title: "Unikatne reference",
  [ To so reference, ki zagotovijo, da obstaja samo ena referenca na mesto hkrati. Občasno želimo tudi spreminjati vrednost, na katero kaže referenca preko te reference. Zato uvedemo unikatne reference, ki so posledično _spremenljive_. Pravilo, ki ohranja pomnilniško varnost, se glasi: če obstaja unikatna referenca na pomnilniško mesto, na to mesto ne sme kazati nobena druga aktivna referenca (deljena ali unikatna). Aktivnost reference tukaj pomeni isto kot aktivnost spremenljivke.],
)

== Primeri uporabe

Pravilna uporaba deljene reference

```rust
let a = 6;
let b = &a;
println!("{}", a);
```

Napačna uporaba deljene reference


```rust
let a = 6;
let b = &a;
*b = 7; // NAPAKA
println!("{}", a);
```

Pravilna uporaba unikatne reference

```rust
let mut a = 6;
let b = &mut a;
*b = 7;
```

Napačna uporaba unikatne reference

```rust
let mut a = 6;
let b = &mut a;
println!("{}", a); // NAPAKA
*b = 7;
```

== Življenjske dobe

- Del Rustovih tipov (`&'a String`)
- Del tipa samo pri referencah!
- _Intuitivno_: nabor vrstic v programu, kjer mora biti refernca veljavna


#[
  #show raw: set text(size: 16pt)
  ```rust
  fn main() {
      let r;                // ---------+-- 'a
                            //          |
      {                     //          |
          let x = 5;        // -+-- 'b  |
          r = &x;           //  |       |
      }                     // -+       |
                            //          |
      println!("r: {r}");   //          |
  }                         // ---------+
  ```
]

= Polonius

== Motivacija


#[

  #show raw: set text(size: 14pt)
  ```rust
  fn process(val: &mut String) {
      unimplemented!();
  }

  fn process_or_default<'a>(map: &'a mut HashMap<&str, String>)
          -> &'a mut String {
      let key = "test";
      match map.get_mut(&key) { // ------------------+ 'lifetime
          Some(value) => value,                   // |
          None => {                               // |
              map.insert(key, String::default()); // |
              //  ^~~~~~ ERROR.                   // |
              map.get_mut(&key).unwrap()          // |
          }                                       // |
      } // <-----------------------------------------+
  }
  ```
]

#[

  #show raw: set text(size: 12pt)
  #codly(number-format: none)
  ```text
  error[E0499]: cannot borrow `*map` as mutable more than once at a time
    --> /tmp/IWXsFebCZD/main.rs:11:13
     |
  5  |   fn process_or_default<'a>(map: &'a mut HashMap<&str, String>)
     |                         -- lifetime `'a` defined here
  ...
  8  |       match map.get_mut(&key) { // ------------------+ 'b
     |       -     --- first mutable borrow occurs here
     |  _____|
     | |
  9  | |         Some(value) => value,                   // |
  10 | |         None => {                               // |
  11 | |             map.insert(key, String::default()); // |
     | |             ^^^ second mutable borrow occurs here
  ...  |
  14 | |         }                                       // |
  15 | |     } // <-----------------------------------------+
     | |_____- returning this value requires that `*map` is borrowed for `'a`
  ```
]

== Pravila



== Diagram relacij
