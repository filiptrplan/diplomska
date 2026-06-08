#import "@preview/touying:0.7.3": *
#import themes.university: *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.6.0": *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import cosmos.clouds: *
#import "presentation_drawings.typ": (
  final-example-graph-active-horizontal, final-example-graph-subset-horizontal, final-example-graph-zahteva-horizontal,
  polonius-diagram-original,
)
#import "@preview/showybox:2.0.4": showybox
#show: show-theorion
#show: codly-init.with()
#codly(languages: codly-languages)

#let definition(title: "", body) = showybox(
  title: if title == "" { "Definicija" } else { "Definicija (" + title + ")" },
  frame: (
    body-color: green.lighten(90%),
    title-color: green.lighten(80%),
    border-color: green.darken(20%),
  ),
  title-style: (color: black),
  body,
)

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
- Cilj: ${"veljavni programi"} = {"varni programi"}$
- Praksa: ${"veljavni programi"} subset {"varni programi"}$

== Zgodovina razvoja preverjevalnika izposoj

- Sprva bil zelo osnoven, zavrnil veliko varnih programov
- *NLL* (non-lexical lifetimes) ga nadgradi
- Trenutno v uporabi NLL
- Naslednja generacija: *Polonius*

== Cilj diplomske naloge

- Polonius do sedaj nikoli uradno formalno opisan
- Magistrska naloga Amande Stjerne
- Originalne spletne objave
- Implementacija v Rustovem prevajalniku #pause
- *Želimo na matematično formalen način opisati konceptualno delovanje Poloniusa*

= Polonius

== Par pojmov

Obstajata dve vrsti referenc (zapis `&x`):

#definition(title: "Deljene reference", [
  To so reference, ki nam omogočajo, da ustvarimo več referenc na isto mesto hkrati. Zato morajo biti tudi _nespremenljive_, kar pomeni, da podatkov na referenciranem mestu ne smemo spreminjati. To pravilo mora veljati, da je uporaba tovrstnih referenc varna.
])

#definition(
  title: "Unikatne reference",
  [ To so reference, ki zagotovijo, da obstaja samo ena referenca na mesto hkrati. Občasno želimo tudi spreminjati vrednost, na katero kaže referenca preko te reference. Zato uvedemo unikatne reference, ki so posledično _spremenljive_. Pravilo, ki ohranja pomnilniško varnost, se glasi: če obstaja unikatna referenca na pomnilniško mesto, na to mesto ne sme kazati nobena druga aktivna referenca (deljena ali unikatna). Aktivnost reference tukaj pomeni isto kot aktivnost spremenljivke.],
)

#definition(title: "Regije", [
  Regije si lahko predstavljamo kot življenjske dobe referenc. Natančneje so to množice posoj, ki so interne strukture prevajalnika, ki se uporabljajo za sledenje izvorom referenc.
])

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

== Graf poteka

- Polonius ne analizira neposredno izvorne kode, ampak deluje na MIRu (vmesni kodi)
- MIR predstavimo kot *graf poteka*
- Vozlišča predstavljajo stavke v programu, povezave pa možne prehode med njimi
- Relacije Poloniusa so zato vezane na posamezne točke grafa (uporabljamo izraz točko namesto vozlišča)

== Pravila preverjevalnika izposoj

- Pravila veljajo na ravni posamezne funkcije
- Osnovana na grafu poteka programa
- Niso ista kot pravila lastništva ampak jih zagotavljajo
- Prvotno zastavila Amanda Stjerna
- Pet pravil:
  - Use-Init
  - Move-Deinit
  - Shared-Readonly
  - Unique-Write
  - Ref-Live


== Diagram relacij

#v(1fr)
#align(center)[
  #scale(75%, polonius-diagram-original)
]
#v(1fr)

== Primer

#[
  #show raw: set text(size: 14pt)
  ```rust
  fn main() {
    let mut x: i32 = 22;
    let mut v: Vec<&'0 i32> = vec![];
    let r: &'1 mut Vec<&'2 i32> = &'3 mut v;
    let p: &'5 i32 = &'4 x;
    r.push(p);
    x += 1;
    take::<Vec<&'6 i32>>(v);
  }
  ```
]

== Korak 1: aktivne regije

#v(3em)
#align(center)[
  #scale(160%, final-example-graph-active-horizontal)
]
#v(2em)

`regija_aktivna_na` pove, katere regije bomo še potrebovali v nadaljevanju programa.

== Korak 2: vsebovanost

#v(2em)
#align(center)[
  #scale(140%, final-example-graph-subset-horizontal)
]
#v(1em)

Iz začetnih vsebovanosti zgradimo `je_vsebovana`, ki upošteva tranzitivnost in propagacijo po grafu poteka.

== Korak 3: zahteve

#v(1em)
#align(center)[
  #scale(120%, final-example-graph-zahteva-horizontal)
]
#v(1em)

Relacija `zahteva` pove, katere regije na posamezni točki zahtevajo veljavnost posameznih posoj.

== Korak 4: aktivne posoje in napaka

$ (L,P) in "posoja_aktivna_na" <==> \ exists R: (R,P) in "regija_aktivna_na" and (R,L,P) in "zahteva" $

$ P in "napaka" <==> \ exists L: (P,L) in "posoja_razveljavljena_na" and (L,P) in "posoja_aktivna_na" $

V primeru se pri `x += 1` razveljavi posoja `L1`, ki je še vedno aktivna, zato Polonius javi napako.

= Zakjuček

- V delu smo formalizirali delovanje Poloniusa na razumljiv način
- Naš cilj ni bil natančno opisati semantike trenutne implementacije
- Delo na formalizaciji Poloniusa se tudi nadaljuje v okviru projekta `a-mir-formality` Rustove razvijalske ekipe
