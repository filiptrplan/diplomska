// Font sizes taken from here
// https://tug.org/texinfohtml/latex2e.html#Font-sizes
#let small(cont) = text(size: 10.95pt, cont)
#let large(cont) = text(size: 14.4pt, cont)
#let Large(cont) = text(size: 17.28pt, cont)
#let LARGE(cont) = text(size: 20.74pt, cont)
#let huge(cont) = text(size: 24.88pt, cont)
#let Huge(cont) = text(size: 24.88pt, cont)
#let titfont(cont) = strong(LARGE(cont))
#let autfont(cont) = Large(cont)
#let CcImageCc(scale) = image("cc_cc_30.pdf", width: scale * 20pt)
#let CcImageBy(scale) = image("cc_by_30.pdf", width: scale * 20pt)
#let CcImageSa(scale) = image("cc_sa_30.pdf", width: scale * 20pt)

#let thesis(
  title: none,
  author: none,
  study_program: none,
  mentor: none,
  year: none,
  description: none,
  title_en: none,
  description_en: none,
  doc,
) = [
  #set text(size: 12pt, font: "New Computer Modern", lang: "sl")
  #set page(
    paper: "a4",
    margin: 1in,
  )
  #set par(
    leading: 0.9em,
    spacing: 1.2em,
    first-line-indent: 1em,
  )
  #show link: set text(font: "DejaVu Sans Mono", size: 0.9em)
  #set heading(numbering: "1.1")


  // typical latex sizes for chapters/section
  // we treat a level 1 heading as a chapter
  #show heading.where(level: 1): it => [
    #set par(first-line-indent: (amount: 0pt))
    #huge[
      Poglavje #it.level
      #v(1em)
      #it.body
      #v(1em)
    ]
  ]
  #show heading.where(level: 2): it => [
    #v(1em)
    #set par(first-line-indent: (amount: 0pt))
    #Large[#it.numbering #it.body]
  ]

  #align(center + horizon)[
    #v(3em)
    #large[#smallcaps[Univerza v Ljubljani #parbreak() Fakulteta za računalništvo in informatiko]]
    #v(10em)
    #autfont(author) #parbreak()
    #titfont(title) #parbreak()
    #v(1.5em)
    #smallcaps[DIPLOMSKO DELO]
    #v(5mm)
    #study_program #parbreak()
    #v(1fr)
    #large[#smallcaps[Mentor:] #mentor]#parbreak()
    #v(2em)
    #large[Ljubljana, #year]#parbreak()
    #v(5.5em)
  ]

  #set page(
    paper: "a4",
    margin: (
      inside: 1.5in, // oddsidemargin adjustment
      outside: 1in, // marginparwidth adjustment
      top: 2in, // headheight adjustment
      bottom: 2in,
    ),
  )

  #v(5cm)
  #small[
    To delo je ponujeno pod licenco _Creative Commons Priznanje avtorstva-Deljenje pod enakimi pogoji 2.5 Slovenija_ (ali novejšo različico).
    To pomeni, da se tako besedilo, slike, grafi in druge sestavine dela kot tudi rezultati diplomskega dela lahko prosto distribuirajo,
    reproducirajo, uporabljajo, priobčujejo javnosti in predelujejo, pod pogojem, da se jasno in vidno navede avtorja in naslov tega
    dela in da se v primeru spremembe, preoblikovanja ali uporabe tega dela v svojem delu, lahko distribuira predelava le pod
    licenco, ki je enaka tej.
    Podrobnosti licence so dostopne na spletni strani #link("http://creativecommons.si")[creativecommons.si] ali na Inštitutu za
    intelektualno lastnino, Streliška 1, 1000 Ljubljana.
  ]

  #v(1cm)

  #align(center)[
    #grid(
      columns: 3,
      column-gutter: 0.5em,
      CcImageCc(1), CcImageBy(1), CcImageSa(1),
    )
  ]

  #v(1cm)

  #text(size: 0.9em)[
    Izvorna koda diplomskega dela, njeni rezultati in v ta namen razvita programska oprema je ponujena pod licenco GNU General Public License,
    različica 3 (ali novejša). To pomeni, da se lahko prosto distribuira in/ali predeluje pod njenimi pogoji.
    Podrobnosti licence so dostopne na spletni strani #link("http://www.gnu.org/licenses/").
  ]

  #v(1fr)

  #align(center)[
    #v(1fr)

    _Besedilo je oblikovano z urejevalnikom besedil Typst._
  ]

  #pagebreak()

  #v(1fr)
  #v(1em)

  *Kandidat:* #author \
  *Naslov:* #title \
  *Vrsta naloge:* Diplomska naloga na univerzitetnem programu prve stopnje Računalništvo in matematika \
  *Mentor:* #mentor \ \

  *Opis*: \ #description \ \

  *Title*: #title_en \
  *Description*: #description_en

  #v(1fr)
  #v(2cm)

  #pagebreak()

  #v(6em)

  // without dots
  #show outline.entry.where(level: 1): set outline.entry(fill: [])
  #show outline.entry.where(level: 1): set text(weight: "bold")
  #show outline.entry.where(level: 1): it => link(
    it.element.location(),
    text(
      font: "New Computer Modern",
      size: 12pt,
      [
        #v(1em)
        #it.indented(it.prefix(), it.inner())
      ],
    ),
  )
  #outline(title: text(size: 25pt)[Kazalo #v(1em)])

  #pagebreak()

  #doc
]


