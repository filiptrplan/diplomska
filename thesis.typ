#import "template.typ": chapter, thesis

#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import "@preview/obsidius:0.1.0": *
#import "@preview/cetz:0.4.2"
#import "drawings.typ": *
#show: codly-init.with()
#codly(languages: codly-languages)
#show raw: set text(size: 9pt)

#import "@preview/fontawesome:0.6.0": *
// Define the function
#let remark(body, title: "Remark", color: rgb("#0074d9")) = {
  let background-color = color.lighten(90%)
  let stroke-color = color

  block(
    fill: background-color,
    stroke: (left: 3pt + stroke-color),
    inset: (x: 1.2em, y: 1em),
    outset: (y: 0em), // Keeps it contained vertically
    radius: (right: 4pt), // Subtle rounding on the right looks modern
    width: 100%,
    breakable: true,
    above: 1.2em,
    below: 1.2em,
    stack(
      dir: ltr,
      spacing: 0.4em,
      place(top, box(
        height: 1em,
        baseline: 20%,
        text(stroke-color, fa-icon("circle-info")),
      )),
      pad(left: 1.5em, [
        #set text(fill: stroke-color.darken(20%))
        #strong(title) \
        #set text(fill: black) // Reset text color for body
        #body
      ]),
    ),
  )
}

#let angl(cont) = [(angl. #emph(cont))]

#let subst-env(scope) = it => (
  scope
    .pairs()
    .fold(
      it,
      (it, (k, v)) => {
        show k: v
        it
      },
    )
)

// To je za math mode
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


#show: thesis.with(
  title: "Formalizacija originalne formulacije Poloniusa",
  author: "Filip Trplan",
  study_program: [INTERDISCIPLINARNI UNIVERZITETNI \ ŠTUDIJSKI PROGRAM PRVE STOPNJE \ RAČUNALNIŠTVO IN MATEMATIKA],
  mentor: "doc. dr. Boštjan Slivnik",
  year: "2025",
  faculty: "Fakulteta za računalništvo in informatiko",
  description: [
    Besedilo teme diplomskega dela študent prepiše iz študijskega informacijskega
    sistema, kamor ga je vnesel mentor. V nekaj stavkih bo opisal, kaj pričakuje
    od kandidatovega diplomskega dela. Kaj so cilji, kakšne metode naj uporabi,
    morda bo zapisal tudi ključno literaturo
  ],
  title_en: "Formalization of the Original Formulation of Polonius",
  description_en: [
    opis diplome v angleščini
  ],
  abstract_sl: [
    Ta diplomska naloga se ukvarja s formalizacijo Poloniusa, najnovejše različice preverjevalnika izposoj v programskem jeziku Rust. Rust implementira varnost pomnilnika s pomočjo sistema lastništva, ki preprečuje napake kot so viseči kazalci in uporaba že sproščenega pomnilnika. Medtem ko so bile prejšnje različice preverjevalnika dobro dokumentirane, Polonius obstaja predvsem v obliki spletnih objav in eksperimentalne implementacije. Ta naloga poskusi matematično opisati Polonius z definicijo osnovnih množic, relacij in pravil.
  ],
  keywords_sl: "Rust, Polonius, preverjevalnik izposoj, formalizacija",
  abstract_en: [
    This thesis deals with the formalization of Polonius, the latest version of the borrow checker in the Rust programming language. Rust implements memory safety through an ownership system that prevents errors such as dangling pointers and use-after-free. While previous versions of the checker have been well documented, Polonius exists primarily in the form of blog posts and an experimental implementation. This thesis attempts to mathematically describe Polonius by defining basic sets, relations, and rules.
  ],
  keywords_en: "Rust, Polonius, borrow checker, formalization",
)

#chapter(breakpage: false)[Uvod]
Pomnilniška varnost #angl[memory safety] je na področju pisanja programske opreme vedno aktualna tema. Microsoft je pokazal, da so napake pri upravljanju s pomnilnikom najbolj pogost tip napak @Microsoft70Percent. Pri projektu Chromium, ki je osnova za Google Chrome, so opazili, da okoli 70 procentov hroščev povzročijo tovrstne napake @MemorySafetya. Očitno je, da če bi se znebili te kategorije napak, bi lahko rešili velik del hroščev. Posledično so se pomnilniške varnosti razvijalci jezikov lotili na različne načine.

Eden najbolj uporabljenih jezikov je C, kjer je programerju povsem prepuščeno upravljanje s pomnilnikom.
Tovrsten pristop, imenovan ročno upravljanje s pomnilnikom, lahko vodi do izredno hitrih programov in kratkih časov prevajanja (v primerjavi z bolj kompleksnimi jeziki, kot je Rust @glazarCodingRustBad2023), ampak je tudi vir številnih napak @MemorySafetya.

Alternativni pristop ročnemu upravljanju je avtomatsko upravljanje s pomnilnikom, kjer programski jezik zagotavlja varno dodeljevanje in sproščanje pomnilnika ter s tem razbremeni programerja, da se lahko osredotoči na pisanje programa. Vendar ta način ni brez kompromisa, saj imajo jeziki z avtomatskim upravljanjem s pomnilnikom večjo porabo pomnilnika zaradi zakasnjenega sproščanja. Poleg tega se pojavijo premori med izvajanjem programa ali pa zakasnitve ob vsaki operaciji, da lahko čistilec pomnilnika najde pomnilniške lokacije za sprostitev @bakerListProcessingReal1978.

Rust se upravljanja s pomnilnikom loti na drugačen način. Veljavnost dostopanja do pomnilniških lokacij se preverja med časom prevajanja s pomočjo preverjevalnika izposoj #angl[borrow checker]. To je del Rustovega prevajalnika, ki se ukvarja s tokom podatkov in pomnilniškimi lokacijami #footnote[Vprasanje: ali je res ownership zbirka pravil? RustBook: Ownership is a set of rules that govern how a Rust program manages memory]. Rust imenuje zbirko pravil, ki opisuje delovanje preverjevalnika izposoj, lastništvo #angl[ownership]. Tak pristop nam teoretično omogoči najboljše obeh svetov: zagotovilo, da je naš program pomnilniško varen, ki nam ga da avtomatično upravljanje s pomnilnikom, ter hitrost izvajanja programov jezikov, ki ga lahko dosežemo z ročnim upravljanjem pomnilnika @klabnikRustProgrammingLanguage2023. Pogosto omenjena slabost Rusta je pa dolg čas prevajanja @glazarCodingRustBad2023, ki sicer ni odvisen samo od preverjevalnika izposoj, vendar zagotovo njegov prispevek ni zanemarljiv.

V nadaljevanju bomo uporabljali dva podobna pojma. _Varen program_ bo pomenilo tak program, ki ne povzroča pomnilniških napak. _Veljaven program_ pa bo pomenilo tak program, ki ga Rustova pravila lastništva in izposojanja smatrajo kot varnega.

Preverjevalnik izposoj se je med razvojem Rusta bistveno spremenil od svoje prvotne implementacije. Na začetku je bil dokaj preprost in veliko pravilnih programov ni sprejel zaradi svoje konzervativnosti pri zagotavljanju varnosti @2094nllRustRFC. Zato se je čez par let pojavila naslednja različica preverjevalnika, imenovana NLL (_non-lexical lifetimes_), ki je rešila veliko pogostih problemov s prvotno različico. Vendar NLL še vedno ne sprejema vseh veljavnih programov. Da bi rešili probleme NLL-ja, so Rustovi razvijalci predlagali najnovejšo različico preverjevalnika imenovano Polonius, ki drugače zastavi problem lastništva in tako sprejme še večji delež pravilnih programov @AliasbasedFormulationBorrow.

NLL je bil prvotno zelo natančno opisan v RFC-ju, kar je potem vodilo njegov razvoj. Polonius pa je prvotno nastal kot predlog na spletnem blogu in se počasi razvijal s pomočjo dodatnih objav na blogu enega izmed Rustovih razvijalcev @PoloniusRevisitedPart @PoloniusRevisitedParta @WhatPoloniusPolonius. Do danes ne obstaja celovit centraliziran formalen opis Poloniusa, le nekaj spletnih objav, delni formalni opis v magistrskem delu enega izmed razvijalcev @stjernaModellingRustsReference, nedokončana knjiga @WhatPoloniusPolonius ter trenutna implementacija v Rustovem prevajalniku.

Cilj te naloge je potemtakem na svoj način formalizirati inferenčna pravila, ki sestavljajo Polonius, in nadgraditi nekaj že vzpostavljenih formalizacij @stjernaModellingRustsReference. Najprej bomo raziskali pretekle poskuse formalizacije Rusta in sorodne načine upravljanja s pomnilnikom. Nato sledi intuitivni opis Rustovih pravili izposojanja ter bomo nato končali s formalizacijo Poloniusa ter pravil preverjevalnika izposoj.

== Motivacijski primer <chap:motivacijski-primer>

Za grajenje intuicije o razlikah med trenutno različico preverjevalnika izposoj (NLL) in med naslednjo (Polonius) bomo obravnavali motivacijski primer, ki ga NLL zavrne in Polonius sprejme. Primer je prilagojen iz prvotnega predloga NLL-ja @2094nllRustRFC.

#figure(
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
  ```,
  caption: [Motivacijski primer za Polonius],
) <listing:mot_ex>

#figure(
  ```text
  error[E0499]: cannot borrow `*map` as mutable more than once at a time
    --> /tmp/IWXsFebCZD/main.rs:11:13
     |
  5  |   fn process_or_default<'a>(map: &'a mut HashMap<&str, String>)
     |                         -- lifetime `'a` defined here
  ...
  8  |       match map.get_mut(&key) { // ------------------+ 'lifetime
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
  ```,
  caption: [Napaka pri prevajanju primera @listing:mot_ex],
) <listing:mot_ex_err>

Če postopoma sledimo sporočilu o napaki na @listing:mot_ex_err, lahko vidimo kje NLL ni zmožen sprejeti pravilnega programa. Na vrstici 8 kličemo funkcijo `get_mut`, ki vrne unijo z dvem možnostima. Lahko vrne spremenljivo referenco na vrednost, ki pripada ključu, ali pa ne vrne nič (`None`). Če vrne vrednost, se šteje, kot da je spremenljivka `map` začasno izsposojena (torej obstaja spremenljiva referenca na njene podatke), kar se zgodi v vrstici 9. Vendar Rust-ov prevajalnik smatra, da je `map` še vedno izsposojena, tudi če ne vrnemo reference iz funkcije `get_mut` (vrstice 11-13). Ko torej poskušamo vstaviti nov par, ki je sestavljen iz ključa in vrednosti, nam to Rustov prevajalnik konzervativno prepreči, saj operacija `insert` zahteva spremenljivo referenco, dve spremenljivi referenci na isto mesto pa po pravilih jezika #footnote[Vprasanje: pravila jezika ali preverjevalnika izposoj? Odgovor: spremenil sem na jezik] ne smeta obstajati.

V nasprotju z NLL-om Polonius prevede primer @listing:mot_ex kot veljaven, saj ima večje zmožnosti sledenja kontrolnemu toku in lahko zgornjo analizo opravi bolje. NLL ima trenutno omejene zmožnosti obravnavanja kontrolnega toka, ki jih Polonius nadgradi v zameno za hitrost. Amanda Stjerna, ena izmed razvijalcev Poloniusa, je na predstavitvi na konferenci EuroRust omenila, da je plan v prihodnosti sestaviti dvoslojni preverjevalnik izposoj. Sprva bi se analiza opravila z NLL-jem, saj je bistveno hitrejši, Polonius pa bi obravnaval samo zahtevnejše primere, ki jih NLL zavrne @eurorustFirstSixYears2024 (na 23:15).

#chapter[Pregled literature]

== Poskusi formalizacije Rusta
// za vsak poskus povej iz katerega vidika so se ga lotili in kaj manjka

== Sorodni modeli lastnistvu
// GhostCell
// permission calculus
// kako se povezujejo z Rustom

== Polonius v akademiji in praksi
// Poglej si se ownership types in linear types!!!
// kako je bil opisan z blog postom
// integracija v rustc
// Stjernova formalizacija v Datalogu in Crichtonov borrow checker
// omejitve trenutnih opisov

#chapter[Rustov model upravljanja s pomnilnikom -- lastništvo]

V poglavju @chap:motivacijski-primer smo predstavili primer, ki je motiviral nadgradnjo prejšnjega preverjevalnika izposoj. Zraven smo podali intuitivno razlago, zakaj je bil ta program pravilen, vendar smo se nanašali na pravila, ki so osnovana na lastništvu -- Rustovem naboru pravil za zagotavljanja pomnilniško varnih programov.

Knjiga _The Rust Programming Language_, neuradni priročnik za Rust, nam pove, da lastništvo obsega tri pravila @klabnikRustProgrammingLanguage2023: #footnote[Vprasanje: temelji na treh pravilih? Odgovor: imenujejo se "ownership rules"]

+ Vsaka vrednost v Rustu ima _lastnika_.
+ Za vsako vrednost lahko obstaja samo en lastnik hkrati.
+ Ko lastnik izstopi#footnote[napisano je _goes out of scope_] iz dosega, je vrednost sproščena #angl[dropped].

Lastnik se tukaj nanaša na spremenljivko (bolj natančno _lvalue_), na katero je ta vrednost vezana. V primeru @listing:ownership1 opazimo, da vrednost `hello` enkrat zamenje lastnika, torej njen prvotni lastnik `a` potem ne vsebuje vrednosti. Če hočemo uporabiti `a` potem, ko ni več lastnik vrednosti, nam prevajalnik vrne napako.

#figure(
  ```rust
  let a = "hello";
  let b = a;
  println!("{}", a); // vrne napako
  ```,
  caption: [Primer lastništva],
) <listing:ownership1>

Lastništvo je vezano na doseg. Koncept dosega lahko preprosto prikažemo z leksikalnim dosegom, tako da inicializiramo novo vrednost `a`-ja znotraj gnezdenega bloka, ki ustvari nov scope. To je prikazano v primeru @listing:scope1

#figure(
  ```rust
  {
      let a = "goodbye";
  }
  println!("{}", a); // vrne napako ker `a` ni več v dosegu
  ```,
  caption: [Primer leksičnega dosega],
) <listing:scope1>

V zgornjih primerih nismo videli bistvene razlike med Rustom in sorodnimi jeziki. Razlika je v tem, kako se reference ustvarjajo in kako so razdeljene na dva različna tipa. Ko v Rustu govorimo o referencah, lahko rečemo, da so na prvi pogled podobne kazalcem, kakršne poznamo iz drugih programskih jezikov. Ključna razlika je v tem, da prevajalnik v Rustu poskrbi, da referenca v Rustu vedno kaže na veljavno vrednost pravega tipa -- in to skozi celotno življenjsko dobo te reference @klabnikRustProgrammingLanguage2023. Ta varnostni mehanizem nam omogoča nekaj, kar je v mnogih drugih jezikih bistveno težje doseči: gotovost, da reference "ne visijo v prazno" in da ne dostopamo do podatkov, ki morda sploh več ne obstajajo.

Prevajalnik preverja pomnilniško pravilnost programov, ko so ti pretvorjeni v vmesno kodo *MIR* (_Mid-level intermediate representation_), ki je bistveno poenostavljena oblika Rusta in zadnji korak pred generiranjem strojne kode v zadnjem delu prevajalnika (v Rustovem primeru LLVM). MIR temelji na grafu kontrole toka, ki ga bomo opisali pozneje v nalogi. Ta oblika Rusta je pomembna, ker nam bistveno poenostavi preverjanje izposoj in nam omogoča lažjo analizo. Prav tako je tukaj točno definiran pojem *mesta* #angl[place], ki je eden izmed ključnih izrazov pri analizi pravilnosti programa. Mesto je izraz, ki nam opredeli lokacijo v pomnilniku. To je lahko lokalna spremenljivka (npr. `_1`) ali pa njena projekcija (npr. polje strukture `_1.polje`) @MIRMidlevelIR.

Zdaj lahko s pojmom mesta opredelimo dve glavni vrsti referenc @crichtonGroundedConceptualModel2023 @yanovskiGhostCellSeparatingPermissions2021 @weissOxideEssenceRust2019. Prva vrsta so *deljene in zato nespremenljive reference* #angl[shared references]. Takih je lahko hkrati več in vse lahko kažejo na isto mesto v pomnilniku. Pravilo, ki zagotavlja, da so take deljene reference varne, pravi, da podatkov na tem mestu ne smemo spreminjati. Druga vrsta pa so *spremenljive reference* #angl[mutable / unique references]. Pri teh se pravila ravno obrnejo: lahko imamo zgolj eno tako referenco, zato pa lahko spreminjamo podatke na pomnilniškem mestu, ki ga referencira (preko spremenljive reference, ne preko prvotne spremenljivke).

#remark(title: "Teorija za referencami")[
  Tovrsten tip omejevanja ustvarjanja referenc se imenuje _aliasing XOR mutability_. Ta model s pomočjo tipov
  poveže podatke z dovoljenjimi operacijami, ki jih lahko izvajamo na teh podatkih @yanovskiGhostCellSeparatingPermissions2021.
]

Poglejmo si primera uporabe takih referenc in njuno ključno razliko. Prvo bomo pokazali pravilno in nepravilno uporabo deljene reference nato pa še spremenljive.

#figure(
  ```rust
  let a = 6;
  let b = &a; // ustvarimo deljeno referenco
  println("{}", a); // lahko jo uporabimo, ker za izpis na
                    // ekran potrebujemo samo branje
  ```,
  caption: [Pravilna uporaba deljene reference],
) <lst:uporabadeljena>

#figure(
  ```rust
  let a = 6;
  let b = &a; // ustvarimo deljeno referenco
  *b = 7; // NAPAKA: poskus pisanja skozi deljeno referenco
  println!("{}", a);
  ```,
  caption: [Napačna uporaba deljene reference - poskus pisanja],
) <lst:napacanapacnadeljena>

#figure(
  ```rust
  let mut a = 6;
  let b = &mut a;
  *b = 7; // lahko spremenimo podatke na pomnilniški lokaciji,
          // ker je referenca spremenljiva
  ```,
  caption: [Pravilna uporaba spremenljive reference],
) <lst:uporabaspremenljiva>

#figure(
  ```rust
  let mut a = 6;
  let b = &mut a; // ustvarimo spremenljivo referenco
  println!("{}", a); // NAPAKA: hkratna uporaba lastnika in spremenljive reference
  *b = 7;
  ```,
  caption: [Napačna uporaba spremenljive reference - hkratna uporaba lastnika],
) <lst:napacnaspremenljiva>

Obratne operacije pri obeh primerih bi vrnile napako zaradi kršitve pravil referenc. Torej, če bi v primeru @lst:uporabadeljena po izpisu dodali še vrstico `*b = 7;` (pisanje preko reference), bi nam prevajalnik vrnil napako zaradi kršitve zagotovila o preprečitvi branja. Prav tako če bi poskusili izpisati spremenljivko `a`, ki je bila spremenljivo izposojena v primeru @lst:uporabaspremenljiva, bi bil program zavrnjen, saj prevajalnik prepreči, da bi hkrati uporabljali lastnika vrednosti in njeno spremenljivo referenco.



To razmerje med obema vrstama referenc -- večkratne nespremenljive ali pa ena sama spremenljiva -- lahko strnemo v načelo, ki ga imenujemo _aliasing XOR mutability_ #footnote[slo. prevod?]. Ideja tega načela je preprosta: podatkovne strukture so lahko bodisi dostopne na več načinov hkrati (torej imajo več imen oziroma referenc), vendar jih lahko samo beremo; ali pa jih smemo aktivno spreminjati, vendar z zagotovilom, da ima v tistem trenutku do njih dostop le ena referenca. Model torej na zelo eleganten način povezuje podatke z naborom dovoljenih operacij in to počne prek samega sistema tipov @yanovskiGhostCellSeparatingPermissions2021.

Pravila o referencah lahko povzamemo z dvema praviloma @klabnikRustProgrammingLanguage2023
+ Hkrati je lahko ustvarjena _ali_ ena spremenljiva referenca _ali_ poljubno število deljenih referenc.
+ Reference morajo biti vedno veljavne (kazati na veljavno mesto).

Še ena podrobnost, ki je pomembna za razumevanje lastništva, so *življenjske dobe* #angl[lifetimes]. Te so v Rustu sestavni del tipov. Kot sami tipi v Rustu so ponavadi izpeljane, vendar se pogosto pri funkcijski zapisih #footnote[prevod signatures?] zgodi, da jih moramo eksplicitno podati. Na primer, dejanski tip reference na niz ni `&String` ampak `&'a String`, kjer je `'a` življenjska doba. Pomembno je tudi omeniti, da so življenjske dobe del tipa samo takrat, ko ta predstavlja referenco. Intuitivno si jih lahko predstavljamo kot nabor vrstic v programu, kjer ta referenca mora biti veljavna @klabnikRustProgrammingLanguage2023. Najlažje to predstavimo s primerom @lst:lifetime-annotate.

#figure(
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
  ```,
  caption: [Anotirane življenjske dobe na primeru],
) <lst:lifetime-annotate>

Prevajalnik nam pri primeru @lst:lifetime-annotate vrne napako, saj je spremenljivka `x` veljavna samo za življenjsko dobo `'b`, vendar prevajalnik zahteva, da je veljavna za `'a`. Izračun življenjskih dob je odvisen od implementacije preverjevalnika izposoj, vendar si jih lahko intuitivno predstavljamo kot najmanjšo množico #footnote[Vprasanje: interval? Odgovor: mnozica je, ne nujno strnjen interval] vrstic, kjer bo ta spremenljivka oz. mesto še uporabljeno.

// intuicija glede 2015 verzije borrow checkerja pred NLL: https://youtu.be/uCN_LRcswts?si=S2Ii5VHYF4X7HDo-&t=515
// tukaj razlozim kako gre iz primitivnega do NLL do Poloniusa
// prednosti in slabosti vsakega sistema

#chapter[Formalizacija Poloniusa]

// Glavno delo na področju formalizacije Poloniusa je magistrsko delo Amande Stjerna, ki je nastalo leta 2020, dve leti po prvotni formulaciji @stjernaModellingRustsReference @AliasbasedFormulationBorrow. V delu Stjerna prvo formalizira Polonius kot del sistema tipov avtorjev @weissOxideEssenceRust2019 imenovan Oxide @weissOxideEssenceRust2019. Stjerna upraviči svojo izbiro izhodiščnega sistema tipov s tem, da si deli koncept t.i. _provenance variables_. Delo se nato nadaljuje z implementacijo Poloniusa v jeziku Datalog (podmnožica Prologa), ki služi kot podlaga za prvo različico implementacije v Rustovem prevajalniku @RustlangPolonius2025.

V temu poglavju bomo najprej predstavili intuitivni opis delovanja Poloniusa in temu sledili s formalnim opisom pravil Rustovega preverjevalnika izposoj. Nazadnje bomo še predstavili delovanje Poloniusa z opisom na osnovi množic in relacij.

== Intuitivna razlaga Poloniusa
<chap:intuitivna-razlaga-poloniusa>

Preden formalno predstavimo vse podrobnosti Poloniusa, je pomembno dobiti nekaj intuicije o njegovem delovanju, saj nam bo olajšala razumevanje zapletenih relacij in njihovih pravil, na katerih algoritem temelji. Naslednjo razlago smo prilagodili iz originalne spletne objave, ki je predstavila Polonius @AliasbasedFormulationBorrow. Delovanje bomo predstavili na @lst:intuition[primeru], vendar brez natančnih opisov relacij in množic, ki nastopajo pri dejanski analizi.

#figure(
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
  fn take<T>(p: T) { .. }
  ```,
  caption: [Primer programa za Polonius iz @AliasbasedFormulationBorrow],
) <lst:intuition>

@lst:intuition[Program] ima poleg tipov predpisane še *regije*, kot jih imenuje Polonius, ki si jih lahko predstavljamo kot življenjske dobe, bolj podrobno pa so to množice *posoj* #angl[loans], ki jih kasneje definirano natančno, za zdaj pa si jih lahko predstavljamo kot možne "izvore" #angl[origins] referenc (npr. `&x`, `&mut a.b`, itd.). Označene so s številkami `'0`, `'1`, `'2`, itd. Tukaj so prikazane kot del programa (npr. `&'3 mut v'`), vendar to ni veljavna sintaksa Rusta, je pa uporabna za pedagogične namene.

Zdaj pa si oglejmo korake v programu, ki na koncu privedejo do napake :

- Vrstica 3: Usvarimo vektor deljenih referenc `v`.
- Vrstica 4: Ustvarimo spremenljivo referenco `r`, ki kaže na vektor `v`.
- Vrstici 5 in 6: Deljeno referenco na `x` vstavimo v vektor `v` preko `r`.
- Vrstici 7 in 8: Poskušamo spremeniti vrednost `x`.

Vendar v tem trenutku še vedno obstaja aktivna referenca na `x` v vektorju `v`, ki smo jo vstavili na vrstici 6. Vektor `v` še vedno potrebujemo v vrstici 8, torej javimo napako.

#show "'a": `'a`
#show "'b": `'b`

Oglejmo si, kako se intuitivno razumevanje napake prenese na analizo, ki jo opravi Polonius. Lahko si predstavljamo, da algoritem 3-krat obhodi kodo. To sicer ni povsem res, saj se ti obhodi v implementaciji prekrivajo, vendar je za intuitivno razumevanje koristno.

Prvi obhod izračuna dva glavna elementa: vsebovanost regij in pripadnost posoj regijam.

Vsebovanost dveh regij se izračuna glede na pravila sklepanja Rustovega sistema tipov(subtyping relations?) in jo zapišemo kot `'a: 'b`, kar pomeni da mora regija 'a vsebovati vse #posoje iz regije 'b (intuitivno mora referenca z življenjsko dobo 'b živeti vsaj toliko dolgo kot 'a).

Pripadnost #posoje regijam se določi ob ustvaritvi #posoje. V tem kontekstu pripadnost ne pomeni pripadnost množici vrstic, ki sestavljajo regijo v NLL-u, vendar kot dodaten metapodatek regije. #posoje so interne strukture v Rustovem prevajalniku, ki hranijo podatke o ustvarjeni referenci @weissOxideEssenceRust2019. Ko ustvarimo posojo z `&` ali `&mut`, se tej določi pripadnost glede na regijo, ki je del tipa.

Za boljše razumevanje teh dveh korakov se obrnemo na @lst:intuition2[primer], kjer sta v komentarjih anotirana ta dva koraka.

#figure(
  ```rust
  fn main() {
    let mut x: i32 = 22;
    let mut v: Vec<&'0 i32> = vec![];
    let r: &'1 mut Vec<&'2 i32> = &'3 mut v;
    // V zgornji vrstici se ustvari posoja L0 (iz &mut v), ki pripada regiji '3.
    // Vsebovanost - '3: '1, '2: '0, '0: '2
    let p: &'5 i32 = &'4 x;
    // Ustvarimo L1 (iz &x), ki pripada regiji '4
    // Vsebovanost - '4: '5
    r.push(p);
    // Vsebovanost -  '5: '2
    x += 1;
    take::<Vec<&'6 i32>>(v);
    // Vsebovanost - '0: '6
  }
  fn take<T>(p: T) { .. }
  ```,
  caption: [Primer programa za Polonius iz @AliasbasedFormulationBorrow],
) <lst:intuition2>

#remark(title: "Zakaj na vrstici 6 ustvarimo dvosmerno vsebovanost?")[
  Če v vektor pišemo, kot na vrstici 10, morajo elementi "znotraj" reference živeti vsaj tako dolgo kot elementi v prvotnem vektorju. Zato dodamo vsebovanost `'2: '0`. Ker pa lahko iz vektorja tudi beremo, morajo elementi v prvotnem vektorju živeti vsaj tako dolgo kot tisti "znotraj" reference, saj sicer bi lahko brali neveljaven spomin. Tako dobimo še `'0: '2`.
]

Drugi obhod propagira vsebovanosti iz prvega obhoda (saj lahko nanje gledamo kot relacijo matematične vsebovanosti, ki je tranzitivna), ter s tem tudi propagira pripadnost posoj. Če sledimo tranzitivnemu zaprtju vsebovanosti, lahko opazimo dve verigi:

- Za posojo `L0`: `'3: '1`
- Za posojo `L1`: `'4: '5: '2: '0` (`'0: '2` tukaj ni tako pomembno)

#figure(
  align(center)[#diagram-vsebovanosti-intuition2],
  caption: [Diagram vsebovanosti regij in posoj @lst:intuition2[programa]],
  supplement: "Diagram",
) <fig:diagram-vsebovanosti>

Osredotočimo se na #posoje `L1`, ki je na koncu drugega obhoda pripadnica regije `'0`. Poleg propagiranja vsebovanosti, drugi obhod tudi določi aktivnost regij in #posoje, vendar tukaj tega postopka ne bomo opisali. Povedali bomo samo, da Polonius izračuna, da sta regija `'0` in posledično #posoje `L1` aktivni na vrstici 12 v @lst:intuition2[programu]. Pojma aktivnosti regij in #posoje sta tukaj analogna pojmu aktivnosti spremenljivk pri prevajalnikih.


#figure(
  align(center)[#aktivnosti-regij-intuition2],
  caption: [Označene aktivnosti regij @lst:intuition2[programa]],
  supplement: "Diagram",
) <fig:aktivnosti-regij>


V tretjem obhodu nato javimo napako, ker operacija mutiranja spremenljivke `x` na vrstici 12 v @lst:intuition2[primeru] razveljavi pogoje #posoje `L1`, ki je pa na tisti točki v programu še vedno živa. Razveljavitev pogojev #posoje na kratko pomeni, da operacija ni dovoljena glede na tip reference. To so lahko npr. mutiranje mesta na katero kaže deljena referenca ali pa ustvarjanje nove reference na mesto, ko že obstaja spremenljiva referenca.

V intuitivni razlagi smo izpustili več podrobnosti, kot je izračun aktivnosti #regije in #posoje, podrobnosti propagacije različnih vsebovanosti skozi program in pogoje za ustvarjanje raznih drugih omejitev #angl[constraints]. Prav tako je pomembno omeniti, da analiza deluje na MIR, ki je osnovan na podatkovni strukturi grafa, ne pa na samih vrsticah v programu.

== Formalizacija pravil

Do zdaj smo pravila izposojanja in lastništva opisovali intuitivno, vendar za prihodnje poglavja je bolje razumeti vsa pravila formalno. Trenutno uradnni formalni opis pravil preverjevalnika izposoj ne obstaja, vendar se ekipa za projektom `a-mir-formality` ukvarja ravno s to nalogo @BorrowCheckingAmirformalitya.

Zaradi pomanjkanja uradne specifikacije pravil, se bomo zanesli na delo Amande Stjerne @stjernaModellingRustsReference, kjer je opisno in s tabelo predstavila pravila, ki se jih mora preverjevalnik izposoj držati. Njena pravila bomo nadgradili s formalno notacijo, ki je podobna tisti, ki jo bomo uporabili v naslednjih poglavjih.

V @tab:borrow-check[tabeli] imamo podane pozitivne in negativne primere za vsako pravilo, točno tako kot jih je zastavila Stjerna. S pomočjo teh primerov in njene razlage bomo osnovali formalni zapis teh pravil. Pomembno je tudi omeniti, da vsa ta pravila delujejo na nivoju posamezne funkcije, ne celotnega programa.

#import "rule_table.typ": rule_table
#rule_table

// reset codly stuff
#codly(display-name: true, display-icon: true, number-format: numbering.with("1"))

Pravilo `Use-Init` nam pove, da lahko uporabljamo samo spremenljivke, ki so zagotovo inicializirane
na točki v programu, kjer jih uporabljamo. Skupaj s pravili `Move-Deinit`, ki pravi da ne smemo uporaljati premaknjenih vrednosti, in `Ref-Live`, ki nam onemogoči dostop do sproščenih vrednosti preko referenc, tvori osnovo za sistem lastništva. Ta pravila nam na primer preprečijo vračanje vrednosti, ki je bila ustvarjena na skladu, iz funkcije, saj je vrednost na izhodu iz funkcije sproščena @stjernaModellingRustsReference.

Za formalizacijo pravil se bomo zanašali na *graf poteka* (_angl. CFG - control flow graph_), ki je izračunan v fazah analize kode, ki so opravljene že preden vstopimo v preverjevalnik izposoj. Zgrajen je iz osnovnih blokov, ti pa so zgrajeni iz stavkov. Vozlišča v samem grafu si lahko predstavljamo kot posamezne stavke, vendar jih kasneje v nalogi definiramo bolj podrobno.

Da definiramo pravilo `Use-Init`, najprej uvedemo množico $"Poti"(p)$, ki nam poda vse poti skozi graf poteka od začetka funkcije do začetka trenutne točke $p$ v programu. Te poti so statične, t.j. se ne spreminjajo glede na vrednosti spremenljivk med tekom programa. Lahko si jih predstavljamo kot vse možne poti, po katerih bi lahko dosegli trenutno točko, če bi lahko poljubno spreminjali vhodne vrednosti in spremenljivke. Potem lahko definiramo še predikat $"Init"(pi, x, p)$, ki velja natanko tedaj, ko je spremenljivka $x$ skozi pot $pi$ definirana na točki $p$. Končno pravilo se nato glasi:

$ "Use-Init"(x, p) <==> forall pi in "Poti"(p): "Init"(pi, x, p) $

Pravilo `Move-Deinit` nam prepreči, da uporabimo ime (binding?), iz katerega je bila vrednost premaknjena. V kontekstu lastništva to pomeni, da ime ni več lastnik vrednosti. Da pravilo definiramo formalno, moramo vpeljati še dva predikata.

Za nadaljevanje moramo definirati kaj je predpona, ki jo NLL RFC definira tako @2094nllRustRFC:

/ Predpona #angl[prefix]: Pravimo, da so predpone `lvalue` vse tiste `lvalue`, ki jih dobimo, če odstranimo polja ali dereferenciranja. Na primer, predpone `*a.b` so `*a.b`, `a.b` in `a`.

// https://rustc-dev-guide.rust-lang.org/borrow_check/moves_and_initialization/move_paths.html za definicijo move path
#remark(title: [Opomba o mestih in poteh premika (_move path_)])[
  Pojem predpone (_prefix_) je načeloma definiran kot lastnost poti
  premika, vendar ga tukaj posplošimo na mesta iz MIR, ker se nam bolj sklada s terminologijo, ki jo uporabljamo.
  Rustov priročnik za prevajalnik tudi omeni, da sta ta pojma približno enaka. Pojem predpone uporabljamo namesto spremenljivk
  zaradi tega, ker nam opiše lahko bolj fino dostopne podatke kot so polja struktov.
]

Prvi nam pove ali se mesti prekrivata t.j. ali je katero mesto predpona drugega. Poimenovali
ga bomo $"Prekrivanje"(m_1, m_2)$, ki velja natanko tedaj, ko je $m_1$ predpona $m_2$ ali obratno. Torej $"Prekrivanje"("tuple.0", "tuple.0.1")$ bi veljalo, $"Prekrivanje"("tuple.0", "tuple.1")$ pa ne.

Naslednji predikat, ki ga uvedemo, je $"Premaknjen"(pi, m, p)$, ki velja natanko tedaj, ko je bilo mesto $m$ premaknjeno
pred točko $p$ na poti $pi$. Premik iz perspektive programerja pomeni, da lastnik ni več $m$ ampak nekdo drug. Rustov priročnik za prevajalnik pa nam pove, da v resnici premik iz imena pomeni samo, da ta vrednost ni več v množici inicializiranih vrednosti. Torej pravilo velja ko:

$ "Move-Deinit"(m, p) <==> \ exists.not pi in "Poti"(p), m_2: "Prekrivanje"(m, m_2) and "Premaknjen"(pi, m_2, p) $

Pravili `Shared-Readonly` in `Unique-Write` pa skrbita za veljavnost referenc in omejitve na njihovi uporabi. To so ista pravila, ki smo jih opisali v @chap:intuitivna-razlaga-poloniusa[poglavju]. Za njiju moramo definirati še nekaj dodatnih predikatov.

Da razumemo kaj nam ta pravila pravijo, moramo definirati pojem #posoje, ki je tesno povezana s sorodnim pojmom "izraz izposoje".

/ Izraz izposoje #angl[borrow expression]: #[je jezikovni konstrukt, ki nam omogoča, da ustvarimo referenco (primer izraza izposoje bi bil `&mut x`). Rustov priročnik za prevajalnik @MIRMidlevelIR pojma _borrow expression_ ne definira, ampak ga uporabi tako:

    #quote[An Rvalue is an expression that creates a value: in this case, the rvalue is a
      mutable borrow expression, which looks like `&mut <Place>`]

    Rvalue je definiran z enumeratorjem `Rvalue` @RvalueRustc_middleMir. Nas pa zanima specifično varianta `Rvalue::ref(Region<'tcx>, BorrowKind, Place<'tcx>)`, ki ustvari referenco tipa `BorrowKind` na mesto `Place`.

  ]

Pojem _borrow expression_ pogosto uporabljajo #cite(<weissOxideEssenceRust2019>, form: "author") v svojem članku o formalizaciji podmnožice Rust-a. Njihov način uporabe se sklada z našo definicijo, ki se glasi:

/ #posoje #angl[loan]: #[
    je interni konstrukt prevajalnika, ki hrani stanje o referenci in njenemu izvoru @weissOxideEssenceRust2019. V trenutni implementaciji preverjalnika izposoj je izposoja predstavljena kot urejena trojica @2094nllRustRFC `('a, shared|uniq|mut, lvalue)`, kjer je:
    - `'a`: življenjska doba za katero je vrednost izposojena. To se nanaša na življenjske dobe kot
      del Rustovega sistema tipov, ne pa kot množico izposoj, kot jih bomo definirali kasneje.
    - `shared|uniq|mut`: tip izposoje
    - `lvalue`: vrednost, ki je bila izposojena
  ]

Torej v našem matematičnem zapisu bomo #posoje zapisali kot $L = (alpha, tau, O)$, kjer bo $tau in {"uniq", "shrd", "mut"}$ naš tip #posoje in $O$ naš lvalue (oziroma _origin_ z Rustovsko terminologijo). Da lahko razločimo med aktivnimi in preteklimi #posoje, pa ustvarimo predikat $"PosojaAktivna"(L,p)$, ki velja natanko tedaj, ko je #posoje $L$ aktivna na točki $p$.

Poleg predikatov za #posoje pa nam še manjkajo predikati, ki opisujejo operacije, ki se izvajajo nad mesti. Intuitivno je to lahko več različnih operacij, vendar nas zanimajo dve glavni vrsti. Take, ki bi razveljavile deljeno #posoje označimo z $"RazveljaviDeljeno"(m,p)$ in velja natanko tedaj, ko se v točki $p$ nad mestom $m$ izvede taka operacija, ki bi lahko razveljavila #posoje, ki si sposoja iz mesta $m$ (to bi bilo pisanje v mesto $m$ ali pa ustvarjanje spremenljive #posoje).

Na podoben način definiramo $"RazveljaviSpremenljivo"(m,p)$, ki velja ko je operacija taka, ki razveljavi spremenljivo #posoje (ustvarjanje kakršnekoli nove #posoje, pisanje v mesto, branje iz mesta). Tako lahko sestavimo naši naslednji dve pravili:

$
  "Shared-Readonly"(p) & <==> exists.not L = ("_", tau, O),m: \
  "PosojaAktivna"(L,p) & and tau = "shrd" and \
   "Prekrivanje"(m, O) & and "RazveljaviDeljeno"(m,p)
$

$
     "Unique-Write"(p) & <==> exists.not L = ("_", tau, O),m: \
  "PosojaAktivna"(L,p) & and "VrstaPosoje" in {"uniq", "mut"} and \
   "Prekrivanje"(m, O) & and "RazveljaviSpremenljivo"(m,p)
$

Za zadnje pravilo potrebujemo še en predikat imenovan $"MestoAktivno"(m,p)$, ki velja natanko tedaj, ko je mesto $m$ še aktivno (torej ni bilo dropped) na točki $p$. Potem pravilo `Ref-Live` lahko zapišemo tako:

$
         "Ref-Live"(p) & <==> exists.not L = ("_", "_", O), m: \
  "PosojaAktivna"(L,p) & and "Prekrivanje"(m, O) and not "MestoAktivno"(m,p)
$

== Primer in formalizacija

V naslednjih poglavjih se bomo lotili glavnega dela naloge, ki je matematična formalizacija delovanja Poloniusa. Da si bomo lažje predstavljali relacije in množice bomo celotno delovanje ponazorili na primeru iz @chap:intuitivna-razlaga-poloniusa[poglavja], ki ga bomo tukaj še enkrat prikazali.

#figure(
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
  fn take<T>(p: T) { .. }
  ```,
  caption: [Primer programa za Polonius iz @AliasbasedFormulationBorrow],
) <lst:main-example>

== Osnovne množice in elementi
<chap-osnovne-mnozice>

Da sploh lahko matematično govorimo o delovanju Poloniusa, moramo definirate osnovne množice in elemente s katerimi bomo delali.

=== Množica posoj #posoje

Množico vseh posoj (_angl. loans_) označimo s #posoje. *Pogoji posoje* so lastnosti, ki morajo držati v določeni točki programa, da smatramo posojo kot veljavno oz. aktivno. Pravimo, da *razveljavimo pogoje posoje*, če velja ena izmed naslednjih točk:
- Referenca je deljena (_shared_), torej je oblike `&x` in
  - ustvarimo novo spremenljivo referenco _in/ali_
  - pišemo v mesto, ki je bilo izposojeno
- Referenca je spremenljiva in jo spreminjamo na kakršen koli način (ustvarjanje nove reference, pisanje, premikanje)

Ta pravila načeloma sledijo NLL-u, bolj formalno pa jih opisujejo pravila razveljavljanja posoje #angl[loan killed]. Iz NLL RFC-ja @2094nllRustRFC:

#quote[For a statement at point P in the graph, we define the "transfer function" – that is,
  which loans it brings into or out of scope – as follows:
  - ...
  - if this is an assignment `lv = <rvalue>`, then any loan for some path P of which `lv` is a prefix is killed.
]

Prevedena verzija(?):

#quote[
  Za stavek na točki P v grafu definiramo "funkcijo prenosa" -- torej, katere posoje prinesemo v ali iz obsega. Funkcija je definirana tako:
  - ... ostala pravila
  - Če je stavek dodelitev `lv = <rvalue>`, potem je vsaka posoja poti P katere `lv` je predpona razveljavljena.
]

Poglejmo si še torej posoje, ki bi se ustvarile na našem primeru:

#show: subst-env((
  L0: $"L"_0$,
  L1: $"L"_1$,
  r0: $'0$,
  r1: $'1$,
  r2: $'2$,
  r3: $'3$,
  r4: $'4$,
  r5: $'5$,
  r6: $'6$,
  "inn": $in$,
  "implies": $arrow.r.double$,
))

#figure(
  ```rust
  fn main() {
    let mut x: i32 = 22;
    let mut v: Vec<&'0 i32> = vec![];
    let r: &'1 mut Vec<&'2 i32> = &'3 mut v; // posoja L0 mesta `v`
    let p: &'5 i32 = &'4 x; // posoja L1 mesta `x`
    r.push(p);
    x += 1;
    take::<Vec<&'6 i32>>(v);
  }
  fn take<T>(p: T) { .. }
  ```,
  caption: [Posoje v programu],
) <listing:loans>

Torej končamo z množico $#posoje = {L_0, L_1}$.

=== Množica regij #regije

V trenutni implementaciji preverjevalnika izposoj NLL se posoje spremljajo s pomočjo življenjskih dob. V tej formulaciji pa je avtor življenjske dobe poimenoval regije #angl[regions]. Množica regij je označena z $regije subset 2^posoje$. Na primeru so že označene z `'1`, `'2`, `'3`, itd. Pripadnost posoj regijam bomo kasneje določili z relacijo.

=== Graf poteka izposoje

Graf poteka #angl[CFG - control flow graph] je izračunan v prejšnjih fazah analize kode. Zgrajen je iz osnovnih blokov, ti pa so zgrajeni iz stavkov. Spremlja ga tudi nekaj dodatnih informacij, ki nam bodo kasneje prišle prav. Te so izračunane tekom analize poteka podatkov #angl[dataflow analysis] @MIRDataflowRust. Graf poteka označimo s $C = (C_V, C_E)$, kjer je $C_V$ množica vozlišč in $C_E$ množica povezav.

Privzeto se ustvarijo naslednje povezave (to bi moral potrditi v kodi rustc, v članku tako piše):

- Za vsak stavek se ustvari povezava med njegovim začetkom in sredino:
  $forall "stmt" in stavki: (S("stmt"), M("stmt")) in C_E$
- Če $M("stmt")$ predstavlja _terminator_ (stavek na koncu bloka) potem dodamo povezavo iz njega v $S("stmt"')$
  za vsak stavek $"stmt"'$, ki mu sledi.

_Opomba:_ To je samo matematična formulacija predstavitve grafa poteka, v prevajalniku
je njegova predstavitev precej bolj kompleksna.

==== Množica stavkov in točk

Množico vseh stavkov v MIR označimo s #stavki. Točke v grafu poteka (_CFG - control flow graph_)
označimo s #točke. Lahko so dveh tipov:
- *na začetku stavka:* označuje trenutek preden se stavek izvede. Označimo s $S("stmt")$.
- *med stavkom:* označuje trenutek tik preden ima stavek učinek (v članku napisano "just before the statement takes effect").
  Označimo s $M("stmt")$.

Avtor spletne objave ne opredeli pojmov _na začetku stavka_ in _med stavkom_ natančno,
vendar lahko najdemo razlago v `legacy` implementaciji Polonius preverjevalnika izposoj.
Komentar nad strukturo, ki opisuje množico stavkov, pravi naslednje @RustCompilerRustc_borrowcka:

#quote[Ta struktura prevede MIR lokacijo, ki identificira stavek znotraj osnovnega bloka, v "obogateno lokacijo",
  kar nam omogoči večjo granularnost. Bolj podrobno, ločimo med začetkom in sredino stavka. Sredina stavka
  je točka _tik preden_ ima stavek učinek. Torej za prirejanje `A = B` bi bila sredina stavka
  točka trenutek ravno preden bi se `B` zapisal v `A` ...]

==== Primer grafa

Da si lahko boljše predstavljamo graf poteka, ga bomo kontruirali za naslednji program:

#figure(
  [
    ```rust
    fn primer(pogoj: bool) {
        let mut x = 1;
        if pogoj {
            x = 2;
        }
        let y = x;
    }
    ```
  ],
  caption: "Primer za graf poteka",
) <ex-cfg-example-code>

@ex-cfg-example-code[Program] se prevede v MIR. Tukaj ga bomo ponazorili s psevdokodo, vendar MIR sam je sam skupek struktur v Rustovem prevajalniku.

#figure(
  [
    ```rust
    fn primer(_1: bool) -> () {
        let mut _0: ();                      // povratna vrednost (unit type)
        let mut _2: i32;                     // x
        let mut _3: i32;                     // y

        bb0: {
            _2 = const 1_i32;                // let mut x = 1;
            switchInt(_1) -> [
                false: bb2,                  // če je pogoj false -> skok na y = x
                otherwise: bb1               // če je pogoj true -> skok na x = 2
            ];
        }

        bb1: {
            _2 = const 2_i32;                // x = 2;
            goto -> bb2;
        }

        bb2: {
            _3 = _2;                         // let y = x;
            _0 = const ();                   // funkcija se konča (implicitni return ())
            return;
        }
    }
    ```],
  caption: [MIR za @ex-cfg-example-code[program]],
)

Ker je ta sintaksa povsem izmišljena za pedagoške namene, je ne bomo pojasnili potanko, vendar omenimo par stvari:
- Spremenljivke izgubijo imena in se oštevilčijo (`_1`, `_2`, `_3`)
- Osnovne bloke se označuje z `bb<stevilo>`.
- `switchInt` je tip terminatorja definiran v Rustovem prevajalniku @TerminatorKindRustc_middleMir.

S tem razumevanjem lahko zdaj program ponazorimo v grafu.

#figure(cfg-example, caption: [Graf poteka za @ex-cfg-example-code[program]])


== Začetne relacije

V @chap-osnovne-mnozice[poglavju] smo definirali osnovne množice nad katerimi bomo zdaj definirani različne relacije. Polonius je razdeljen na dva tipa relacij.

*Začetna* #angl[input] relacija, je tista, ki jo dobimo že iz prejšnjih faz analize MIR-a. Predstavljajo izhodiščno točko za celo analizo in prevzamemo, da so že izračunane. Iz njih potem dobimo *izpeljane* relacije, ki so jedro Poloniusove analize ter njegova ključna inovacija.

=== Začetna relacija vsebovanosti

Začetno relacijo vsebovanosti #angl[base subset] bomo označili z $jevsebovanazacetno subset regije times regije times točke$. Torej to je relacija, ki povezuje dve regiji ob neki točki v programu. Za intuicijo zakaj je ta relacija pomembna si lahko ogledate @chap:intuitivna-razlaga-poloniusa[poglavje].

Bolj natančno, če velja $(R_1, R_2, P) in jevsebovanazacetno$ pomeni, da je $R_1$ podmnožica regije $R_2$ na točki $P$ v programu. Ker so regije potenčne množice posoj, si lahko to razlagamo kot da regija $R_1$ vsebuje vse posoje, ki jih vsebuje $R_2$ in zato $R_2$ inducira več omejitev, ki jih bomo spoznali kasneje v formulaciji. To dejstvo mora veljati na sredini stavka ($M("stmt")$), ki inducira zahtevo.


_Opomba:_ Oznaka `<:` nam predstavlja vsebovanost med tipi (_subtyping relation_).

#remark(title: "Povezava z NLL")[
  V NLL-u so regije predstavljene kot množice točk oz. stavkov, kjer je ta vrednost veljavna. Torej `'a: 'b` bi pomenilo, da mora `'a` biti veljavna vssaj toliko dolgo kot `'b`. V angleščini bi temu rekli _'a outlives 'b_. Drugače povedano, množica točk 'b bi bila podmnožica 'a. Kar je pa ravno obratno, kot naš zapis v Poloniusu. Ključna razlika je, da so regije v Poloniusu množice posoj, ne pa točk. Intuitivno gledano lahko rečemo, da vsaka nova posoja doprinese dodatne omejitve k uporabi in ustvarjanju referenc. Zato je smiselno, da je v Poloniusu regija `'a` podmnožica regije `'b`, saj mora vsebovati _vsaj_ vse omejitve, ki se jih mora držati `'b`.
]

#figure(
  ```rust
  fn main() {
    let mut x: i32 = 22;
    let mut v: Vec<&'0 i32> = vec![];

    let r: &'1 mut Vec<&'2 i32> = &'3 mut v;
    // tukaj zahtevamo naslednje: &'3 mut Vec<&'0 i32> <: &'1 mut Vec<&'2 i32>
    // (r3, r1, P) inn je_vsebovana_zacetno, (r0, r2, P) inn je_vsebovana_zacetno, (r2, r0, P) inn je_vsebovana_zacetno

    let p: &'5 i32 = &'4 x;
    // zahtevamo: &'4 i32 <: &'5 i32
    // (r4, r5, P) inn je_vsebovana_zacetno

    r.push(p);
    // zahtevamo: &'5 i32 <: &'2 i32
    // (r5, r2, P) inn je_vsebovana_zacetno

    x += 1;

    take::<Vec<&'6 i32>>(v);
    // zahtevamo Vec<&'0 i32> <: Vec<&'6 i32>
    // (r0, r6, P) inn je_vsebovana_zacetno
  }
  ```,
  caption: [Začetna relacija vsebovanosti],
)


=== Začetna relacija posoje regij

Začetno relacijo posoje regij #angl[borrow region] označimo s $regijaposojena subset.eq regije times posoje times točke$.

Če velja $(R,L,P) in regijaposojena$ pomeni, da izraz izposoje na točki $P$ ustvari posojo $L$ in postane del
regije $R$. Prav tako kot relacija vsebovanosti se ta zahteva vzpostavi na sredini stavka.

To je ključna relacija, ki poveže regije, ki so del Rustovih tipov in posoje, ki so metapodatki v Rustovem prevajalniku. S pomočjo te relacije bomo lahko povezali specifične reference z regijami in sledili kje so aktivne tekom programa in kdaj javimo napako.

#figure(
  ```rust
  fn main() {
    let mut x: i32 = 22;
    let mut v: Vec<&'0 i32> = vec![];
    let r: &'1 mut Vec<&'2 i32> = &'3 mut v;
    // (r3, L0, P) inn regija_posojena
    let p: &'5 i32 = &'4 x;
    // (r4, L1, P) inn regija_posojena
    r.push(p);
    x += 1;
    take::<Vec<&'6 i32>>(v);
  }
  ```,
  caption: [Začetna relacija posoje regij],
  supplement: "Diagram",
)<ex-relacija-posoje-regij>

Z relacijami #jevsebovanazacetno in #regijaposojena lahko sestavimo diagram vsebovanosti. Opazimo, da tranzitivnost trenutno še ne velja za vsebovanost, saj so to samo t.i. začetna dejstva, ostale lastnosti pa se izračunajo kasneje v analizi.

#figure(
  diagram-vsebovanosti-zacetna,
  caption: [Vsebovanosti za @ex-relacija-posoje-regij[program]],
  supplement: "Diagram",
)

=== Relacija aktivnosti regije

Začetno relacijo aktivnosti regije (_region live at_) označimo z $regijaaktivnana subset.eq regije times točke$.
$(R, P) in regijaaktivnana$ pomeni, da je regija $R$ aktivna na točki $P$. Torej spremenljivka, katere tip vključuje $R$ (recimo `&'a`), bo morda kasneje v programu uporabljena.

To določi analiza aktivnosti, ki poteka isto kot v NLL RFC. Bolj specifično, s pomočjo raznih omejitev izračuna množico točk, kjer mora biti regija (v RFC-ju poimenovana _lifetime_) aktivna @2094nllRustRFC.

To relacijo smo vizualizirali na @fig:aktivnosti-regij[diagramu] v @chap:intuitivna-razlaga-poloniusa[poglavju] in si ga je priporočeno še enkrat ogledati za boljšo intuicijo o temu kaj sploh aktivnost pomeni.

=== Relacija prekinitve posoje

Začetno relacijo prekinitve posoje (_loan killed at_) označimo s $posojaprekinjenana subset.eq posoje times točke$. $(L,P) in posojaprekinjenana$ pomeni, da je posoja $L$ prekinjena (_killed_) na točki $P$. Pojem prekinitve oziroma razveljavitve pogojev smo definirali že zgoraj. To se običajno zgodi na sredini prireditvenega stavka, ki prepiše pot (_path_) prej povezano s posojo $L$.

V našem primeru nimamo nobenega primera prekinitve posoje, je pa relacija ključna v naslednjem primeru:

#figure(
  ```rust
  let p = 22;
  let q = 44;
  let x: &mut i32 = &mut p; // `x` kaže na `p`
  let y = &mut *x; // Posoja L0, `y` kaže tudi na `p`
  // ...
  x = &mut q; // `x` kaže na `q`; prekine L0
  // Lahko uporabimo *x tukaj
  ```,
  caption: [Primer prekinitve posoje],
) <listing:loanKilled>

V tem primeru je `x` referenca na `p`, ki je prekopirana v `y`. Dostop do `*x` bi bil tukaj neveljaven,
ker si ga je `y` izposodil. Ko pa `x` priredimo novo vrednost, pa razveljavimo posojo `L0` in s tem si že spet
omogočimo dostop do `x`. Brez prekinitve bi Polonius mislil, da je mesto `*x` še vedno izposojeno, čeprav
zdaj `y` kaže na `p` in `x` na `q`.

=== Relacija razveljavitve posoje

Začetno relacijo razveljavitve posoje (_invalidates loan_) označimo z s $posojarazveljavljenana subset točke times posoje$. To pomeni, da dejanje na točki $P$ (recimo mutacija izposojenega mesta) razveljavi pogoje posoje $L$, kar je že opisano v poglavju o definiciji množice #posoje.

#figure(
  ```rust
  fn main() {
    let mut x: i32 = 22;
    let mut v: Vec<&'0 i32> = vec![];
    let r: &'1 mut Vec<&'2 i32> = &'3 mut v;
    // (r3, L0, P) inn #regija_posojena
    let p: &'5 i32 = &'4 x;
    // (r4, L1, P) inn #regija_posojena
    r.push(p);
    x += 1; // tukaj razveljavimo L1 z mutacijo deljenega referenta
    take::<Vec<&'6 i32>>(v);
  }
  ```,
  caption: [Primer razveljavitve posoje],
) <listing:loanInvalidated>

== Izpeljane relacije

V tem poglavju bomo opisali relacije, ki jih izpeljemo iz začetnih. Te relacije tvorijo najbolj pomembni del analize
Polonius-a.

V primerih ne bomo označevali točk v grafu poteka pri relacijah, ker bo koda anotirana na tistem mestu, kjer
se posamezna relacija pojavi. V ozadju se to še vedno izvaja na nivoju MIR, vendar za naše poenostavljene
primere to ni ključna informacija. (torej pisali bomo $(R_1, R_2) in jevsebovanazacetno$ namesto $(R_1, R_2, P) in jevsebovanazacetno$).

=== Relacija vsebovanosti

Razširimo začetno relacijo vsebovanosti z (raširjeno) relacijo vsebovanosti (_subset_), ki jo označimo z
$jevsebovana subset.eq regije times regije times točke$. Definirana je z zaprtjem naslednjih pravil:

+ *Začetna relacija:* Če $(R_1, R_2, P) in jevsebovanazacetno$, potem $(R_1, R_2, P) in jevsebovana$. Torej vse trojice
  iz začetne relacije se pojavijo tudi v razširjeni.
+ *Tranzitivnost:* Če $(R_1, R_2, P) in jevsebovana$ in $(R_2, R_3, P) in jevsebovana$, potem $(R_1, R_3, P) in jevsebovana$.
  Relacija vsebovanosti na isti točki v programu je tranzitivna.
+ *Propagacija:* Če veljajo vse izmed naštetega:
  + $(R_1, R_2, P) in jevsebovana$
  + $(P, Q) in C_E$: točki si sledita v grafu poteka
  + $(R_1, Q) in regijaaktivnana$: regija 1 je aktivna na naslednji točki
  + $(R_2, Q) in regijaaktivnana$: regija 2 je aktivna

  potem sledi $(R_1, R_2, Q) in jevsebovana$. To pomeni, da se relacija propagira čez graf poteka, če sta obe
  regiji aktivni na naslednji točki v grafu. Pogoj za aktivnost nam pride prav kasneje.

Na primeru ustvarimo naslednje relacije:

#figure(
  ```rust
  fn main() {
    let mut x: i32 = 22;
    let mut v: Vec<&'0 i32> = vec![];

    let r: &'1 mut Vec<&'2 i32> = &'3 mut v;
    // (r3, r1) in je_vsebovana_zacetno, (r0, r2) inn je_vsebovana_zacetno, (r2, r0) inn je_vsebovana_zacetno

    let p: &'5 i32 = &'4 x;
    // (r3, r1) inn je_vsebovana_zacetno, (r0, r2) inn je_vsebovana_zacetno, (r2, r0) inn je_vsebovana_zacetno
    // (r4, r5) inn je_vsebovana_zacetno

    r.push(p);
    // (r3, r1) inn je_vsebovana_zacetno, (r0, r2) inn je_vsebovana_zacetno, (r2, r0) inn je_vsebovana_zacetno
    // (r4, r5) inn je_vsebovana_zacetno
    // (r5, r2) inn je_vsebovana_zacetno

    x += 1;

    take::<Vec<&'6 i32>>(v);
    // (r3, r1) inn je_vsebovana_zacetno, (r0, r2) inn je_vsebovana_zacetno, (r2, r0) inn je_vsebovana_zacetno
    // (r4, r5) inn je_vsebovana_zacetno
    // (r5, r2) inn je_vsebovana_zacetno
    // (r0, r6) inn je_vsebovana_zacetno
  }

  fn take<T>(p: T) { .. }
  ```,
  caption: [Relacija vsebovanosti],
) <listing:subsetRelations>

=== Relacija zahteve

Relacija zahteve nam pove, da regija $R$ zahteva, da pogoji posoje $L$ veljajo na točki $P$. Označimo jo s
$zahteva subset.eq regije times posoje times točke$ in definirana je z zaprtjem naslednjih pravil:

+ *Začetna relacija:* Če $(R, L, P) in regijaposojena$, potem $(R, L, P) in zahteva$. To nam pove, da če se trojica
  nahaja v relaciji posoje regij, se nahaja tudi v zahteva.
+ *Vsebovanost:* Če velja $(R_1, L, P) in zahteva$ in $(R_1, R_2, P) in jevsebovana$, potem sledi
  $(R_2, L, P) in zahteva$. To nam pove, da če neka regija $R_1$, ki je podmnožica večje regije $R_2$, na točki $P$
  zahteva posojo $L$, potem tudi $R_2$ zahteva isto posojo.
+ *Propagacija:* Če veljajo vse:
  + $(R,L,P) in zahteva$: $R$ zahteva $L$ na $P$
  + $(L, P) in.not posojaprekinjenana$: $L$ ni prekinjena na $P$
  + $(P, Q) in C_E$: $Q$ sledi $P$ v grafu poteka
  + $(R,Q) in regijaaktivnana$: regija $R$ je aktivna na točki $Q$

  potem propagiramo relacijo v $(R,L,Q) in zahteva$.

Opazimo, da pri relaciji vsebovanosti #jevsebovanazacetno in pri relaciji zahteve #zahteva mora biti regija pri pravilu za propagacijo aktivna na naslednji točki $Q$. Z naslednjim primerom ponazorimo zakaj je to ključna omejitev.

#figure(
  ```rust
  let x = 22;
  let y = 44;

  let mut p: &'0 i32 = &'1 x; // posoja L0
  // (r1,r0) inn je_vsebovana_zacetno
  // (r1, L0) inn zahteva

  p = &'3 y; // posoja L1
  // (r3,r0) inn je_vsebovana_zacetno
  // (r3, L1) inn zahteva
  // r1 ni več aktivna, ker smo jo prepisali z r3

  x += 1;
  // razveljavi se posoja L0: (L0) inn posoja_razveljavljena_na
  // tukaj bi brez pravila o aktivnosti regij še vedno zahtevali
  // (L0, r0) inn zahteva zaradi pravila o propagaciji

  print( *p );
  // ta izraz posledično ne bi bil veljaven
  ```,
  caption: [Primer relacije zahteve],
) <listing:reqRelation>

=== Relacija aktivnosti posoje

Relacija aktivnosti posoje (_loan live at_) pomeni, da je posoja $L$ aktivna na točki $P$. Označimo jo s $posojaaktivnana subset.eq posoje times točke$ in jo definiramo takrat, ko

$ exists R in regije: (R,P) in regijaaktivnana and (R,L,P) in zahteva $

To na kratko pomeni, da je posoja aktivna, če jo na isti točki zahteva neka aktivna regija.

== Javljanje napake

S pomočjo prejšnjih relacij lahko na koncu definiramo kje v programu javimo napako (v obsegu preverjalnika posoj). Že spet si pomagamo z relacijo, ki jo tokrat poimenujemo *relacija napake* (_error_) in jo označimo z #napaka. Ta relacija nam pove, da javimo napako na točki $P$ v programu.

Definiramo jo, ko velja:

$ exists L in posoje: (P, L) in posojarazveljavljenana and (L,P) in posojaaktivnana $

Torej napaka se javi natanko tedaj, ko neko dejanje na točki $P$ razveljavi pogoje posoje $L$, ki je hkrati tudi
aktivna na točki $P$.

Poglejmo še kako se dokončno napaka javi na našem primeru:

#figure(
  ```rust
  fn main() {
    let mut x: i32 = 22;
    let mut v: Vec<&'0 i32> = vec![];

    let r: &'1 mut Vec<&'2 i32> = &'3 mut v;
    // relacije, ki so ustvarjene tukaj niso relevantne za napako

    let p: &'5 i32 = &'4 x;
    // (r4, L1) inn `zahteva`
    // (r4, r5) inn `je_vsebovana_zacetno` implies (r5, L1) inn `zahteva`

    r.push(p);
    // (r5, r2) inn `je_vsebovana_zacetno` implies (r2, L1) inn `zahteva`

    x += 1;
    // Tukaj se razveljavi posoja L1: (L1) inn `posoja_razveljavljena_na`.
    // Da se nam javi napaka mora biti ta posoja aktivna (L1) inn posoja_aktivna_na.
    // Torej jo mora zahtevati neka aktivna regija, na trenutni točki pa je
    // aktivna regija r2, ker jo lahko uporabimo v funkciji `take`, ki sprejme naš
    // vektor `v`. Elementi vektorja pa imajo regijo r2, ki pa je del posoje L1.
    // Torej, ker smo razveljavili posojo L1, medtem ko je bila aktivna regija,
    // ki jo ta posoja zahteva, javimo napako.

    take::<Vec<&'6 i32>>(v);
  }

  fn take<T>(p: T) { .. }
  ```,
  caption: [Napaka v programu],
) <listing:error>

#pagebreak()
#bibliography("thesis.bib", style: "institute-of-electrical-and-electronics-engineers")

