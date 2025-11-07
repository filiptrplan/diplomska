#import "template.typ": thesis, chapter

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()
#codly(languages: codly-languages)
#show raw: set text(size: 9pt)

#let angl(cont) = [(angl. #emph(cont))]

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

#chapter[Uvod]
Pomnilniška varnost #angl[memory safety] je na področju pisanja programske opreme vedno aktualna tema. Microsoft je pokazal, da so napake pri upravljanju s pomnilnikom najbolj pogost tip napak @Microsoft70Percent. Pri projektu Chromium, ki je osnova za Google Chrome, so opazili, da okoli 70 procentov hroščev povzročijo tovrstne napake @MemorySafetya. Očitno je, da če bi se znebili te kategorije napak, bi lahko rešili velik del hroščev. Posledično so se pomnilniške varnosti razvijalci jezikov lotili na različne načine.

Eden najbolj uporabljenih jezikov je C, kjer je programerju povsem prepuščeno upravljanje s pomnilnikom.
Tovrsten pristop, imenovan ročno upravljanje s pomnilnikom, lahko vodi do izredno hitrih programov in kratkih časov prevajanja (v primerjavi z bolj kompleksnimi jeziki, kot je Rust @glazarCodingRustBad2023), ampak je tudi vir številnih napak @MemorySafetya.

Alternativni pristop ročnemu upravljanju je avtomatsko upravljanje s pomnilnikom #angl[garbage collection], kjer programski jezik zagotavlja varno dodeljevanje in sproščanje pomnilnika ter s tem razbremeni programerja, da se lahko osredotoči na pisanje programa. Vendar ta način ni brez kompromisa, saj imajo jeziki z avtomatskim upravljanjem s pomnilnikom večjo porabo pomnilnika zaradi zakasnjenega sproščanja. Poleg tega se pojavijo premori med izvajanjem programa ali pa zakasnitve pred vsako operacijo, da lahko čistilec pomnilnika najde pomnilniške lokacije za sprostitev @bakerListProcessingReal1978.

Rust se upravljanja s pomnilnikom loti na drugačen način. Veljavnost dostopanja do pomnilniških lokacij se preverja med časom prevajanja s pomočjo preverjevalnika izposoj #angl[borrow checker]. To je del Rustovega prevajalnika, ki se ukvarja s tokom podatkov in pomnilniškimi lokacijami. Rust imenuje zbirko pravil, ki opisuje delovanje preverjevalnika izposoj, lastništvo #angl[ownership]. Tak pristop nam teoretično, omogoči najboljše obeh svetov: zagotovilo, da je naš program pomnilniško varen, ki nam ga da avtomatično upravljanje s pomnilnikom ter hitrost izvajanja programov jezikov, ki ga lahko dosežemo z ročnim upravljanjem pomnilnika @klabnikRustProgrammingLanguage2023. Pogosto omenjena slabost Rusta je pa dolg čas prevajanja \cite{glazarCodingRustBad2023}, ki sicer ni samo odvisen od preverjevalnika izposoj, vendar zagotovo njegov prispevek ni zanemarljiv.

V nadaljevanju bomo smatrali, da pojma _varen program_ in _pravilen program_ pomenita tak program, ki ne povzroča napak prip upravljanju s pomnilnikom ne glede na to, ali je prevajalnik zaradi težav z izračunljivostjo to sposoben ugotoviti ali pa ne.

Preverjevalnik izposoj se je med razvojem Rusta bistveno spremenil od svoje prvotne implementacije. Na začetku je bil dokaj preprost in ni sprejel veliko pravilnih programov zaradi svoje konzervativnosti pri zagotavljanju varnosti @2094nllRustRFC. Zato se je čez par let pojavila naslednja različica preverjevalnika, imenovana NLL (_non-lexical lifetimes_), ki je rešila veliko pogostih problemov s prvotno različico. Vendar NLL še vedno ne sprejema vseh veljavnih programov. Da bi rešili probleme NLL-ja, so Rustovi razvijalci predlagali najnovejšo različico preverjevalnika imenovano Polonius, ki drugače zastavi problem lastništva in tako sprejme še večji delež pravilnih programov @AliasbasedFormulationBorrow.

NLL je bil prvotno natančno opisan v RFC-ju z zelo točnim jezikom, kar je potem vodilo njegov razvoj. Polonius pa je prvotno nastal kot predlog na spletnem blogu in se počasi razvijal s pomočjo dodatnih objav na blogu enega izmed Rustovih razvijalcev @PoloniusRevisitedPartb @PoloniusRevisitedPartc @WhatPoloniusPolonius. Do danes ne obstaja celovit centraliziran formalen opis Poloniusa, le nekaj spletnih objav, delni formalni opis v magisterskem delu enega izmed razvijalcev @stjernaModellingRustsReference, nedokončana knjiga @WhatPoloniusPolonius ter trenutna implementacija v Rustovem prevajalniku.

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

Če postopoma sledimo sporočilu o napaki na @listing:mot_ex_err, lahko vidimo kje NLL ni zmožen sprejeti pravilnega programa. Na vrstici 8 kličemo funkcijo `get_mut`, ki vrne unijo z dvem možnostima. Lahko vrne spremenljivo referenco na vrednost, ki pripada ključu, ali pa ne vrne nič (`None`). Če vrne vrednost, se šteje, kot da je spremenljivka `map` začasno izsposojena (torej obstaja spremenljiva referenca na njene podatke), kar se zgodi v vrstici 9. Vendar Rust-ov prevajalnik smatra, da je `map` še vedno izsposojena, tudi če ne vrnemo reference iz funkcije `get_mut` (vrstice 11-13). Ko torej poskušamo vstaviti nov par, ki je sestavljen iz vrednosti in ključa, nam to Rustov prevajalnik konzervativno prepreči, saj operacija `insert` zahteva spremenljivo referenco, dve spremenljivi referenci na isto mesto pa po pravilih preverjevalnika izposoj ne smeta obstajati.

Pri primeru @listing:mot_ex, kjer se NLL ne sprejme pravilnega programa, pa ga Polonius pravilno prevede. Namreč ima večje zmožnosti sledenja kontrolnemu toku in lahko zgornjo analizo opravi bolje. NLL ima trenutno omejene zmožnosti obravnavanja kontrolnega toka, ki jih Polonius nadgradi v zameno za hitrost. Amanda Stjerna, ena izmed razvijalcev Poloniusa, je na predstavitvi na konferenci EuroRust omenila, da je plan v prihodnosti sestaviti dvoslojni preverjevalnik izposoj. Sprva bi se analiza opravila z NLL-jem, saj je bistveno hitrejši, Polonius pa bi obravnaval samo zahtevnejše primere, ki jih NLL zavrne @eurorustFirstSixYears2024 (na 23:15).

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

Knjiga _The Rust Programming Language_, neuradni priročnik za Rust, nam pove, da lastništvo obsega tri pravila @klabnikRustProgrammingLanguage2023:

+ Vsaka vrednost v Rustu ima _lastnika_.
+ Za vsako vrednost lahko obstaja samo en lastnik hkrati.
+ Ko lastnik izstopi iz dosega, je vrednost sproščena #angl[dropped].

Lastnik tukaj se nanaša na spremenljivko (bolj podrobno _lvalue_) na katero je ta vrednost vezana. V spodnjem preprostem primeru opazimo, da vrednost `hello` enkrat zamenje lastnika, torej njen prvotni lastnik `a` potem ne vsebuje vrednosti. Če hočemo uporabiti `a` potem, ko ni več lastnik vrednosti, nam prevajalnik vrne napako.

#figure(
  ```rust
  let a = "hello";
  let b = a;
  println!("{}", a); // vrne napako
  ```,
  caption: [Primer lastništva],
) <listing:ownership1>

Lastništvo je pa tudi vezano na doseg. Koncept dosega pa lahko preprosto prikažemo z leksičnim dosegom, tako da inicializiramo novo vrednost `a`-ja znotraj gnezdenega bloka, ki ustvari nov scope.

#figure(
  ```rust
  {
      let a = "goodbye";
  }
  println!("{}", a); // vrne napako ker `a` ni več v dosegu
  ```,
  caption: [Primer leksičnega dosega],
) <listing:scope1>

// obrazloži kako se lastništvo povezuje z življenjskimi dobami in referencami
V zgornjih primerih nismo videli bistvene razlike med Rustom in sorodnimi jeziki. Razlika nastopi v tem, kako se reference ustvarjajo in razdelitvi teh na dva različna tipa. Ko v Rustu govorimo o referencah, lahko rečemo, da so na prvi pogled podobne kazalcem, kakršne poznamo iz drugih programskih jezikov. Ključna razlika je v tem, da prevajalnik v Rustu poskrbi, da takšna referenca vedno kaže na veljavno vrednost pravega tipa -- in to skozi celotno življenjsko dobo te reference @klabnikRustProgrammingLanguage2023. Ta varnostni mehanizem nam omogoča nekaj, kar je v mnogih drugih jezikih bistveno težje doseči: gotovost, da reference "ne visijo v prazno" in da ne dostopamo do podatkov, ki morda sploh več ne obstajajo.

Prevajalnik preverja pomnilniško pravilnost programov s t.i. *MIR* (_Mid-level intermediate representation_), ki je bistveno poenostavljena oblika Rusta in zadnji korak pred generiranjem kode za _backend_ (? kako po slovensko). Temelji na grafu kontrole toka, ki ga bomo opisali pozneje v nalogi. Ta oblika Rusta je pomembna, ker nam bistveno poenostavi preverjanje izposoj in nam omogoča lažjo analizo. Prav tako je tukaj točno definiran pojem *mesta* #angl[place], ki je eden izmed ključnih izrazov pri analizi pravilnosti programa. Mesto je izraz, ki nam opredeli lokacijo v pomnilniku. To je lahko lokalna spremenljivka (npr. `_1`) ali pa njena projekcija (npr. polje strukture `_1.polje`) @MIRMidlevelIR.

Zdaj lahko s pojmom mesta opredelimo dve glavni vrsti referenc @crichtonGroundedConceptualModel2023 @yanovskiGhostCellSeparatingPermissions2021 @weissOxideEssenceRust2019. Prva vrsta so *deljene oz. nespremenljive reference* #angl[shared references]. Takih je lahko hkrati več in vse lahko kažejo na isto mesto v pomnilniku. Pravilo, ki zagotavlja da so take deljene reference varne, pravi, da podatkov na tem mestu ne smemo spreminjati. Druga vrsta pa so *spremenljive reference* #angl[mutable / unique references]. Pri teh se pravila ravno obrnejo; lahko jih imamo zgolj eno in lahko spreminjamo podatke na pomnilniškem mestu, ki ga referencira (preko spremenljive reference, ne preko prvotne spremenljivke).

Poglejmo si primera uporabe takih referenc in njuno ključno razliko. Prvo bomo za vsako pokazali veljaven primer uporabe in nato še neveljaven.

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
  let mut a = 6;
  let b = &mut a;
  *b = 7; // lahko spremenimo podatke na pomnilniški lokaciji,
          // ker je referenca spremenljiva
  ```,
  caption: [Pravilna uporaba spremenljive reference],
) <lst:uporabaspremenljiva>

Obratne operacije pri obeh primerih bi vrnile napako zaradi kršitve pravil referenc. Torej, če bi poskusili pisati
v deljeno referenco kot v primeru @lst:uporabadeljena bi nam prevajalnik vrnil napako zaradi kršitve zagotovila o preprečitvi
branja. Prav tako če bi poskusili izpisati spremenljivko `a`, ki je bila spremenljivo izposojena v primeru @lst:uporabaspremenljiva,
bi bil program zavrnjen, saj prevajalnik prepreči, da bi hkrati uporabljali lastnika vrednosti in njeno spremenljivo referenco.

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
  let b = &mut a; // ustvarimo spremenljivo referenco
  println!("{}", a); // NAPAKA: hkratna uporaba lastnika in spremenljive reference
  *b = 7;
  ```,
  caption: [Napačna uporaba spremenljive reference - hkratna uporaba lastnika],
) <lst:napacnaspremenljiva>

To razmerje med obema vrstama referenc -- večkratne nespremenljive ali pa ena sama spremenljiva -- lahko strnemo v načelo, ki ga imenujemo _aliasing XOR mutability_. Ideja tega načela je preprosta: podatkovne strukture so lahko bodisi dostopne na več načinov hkrati (torej imajo več imen oziroma referenc), vendar jih lahko samo beremo; ali pa jih smemo aktivno spreminjati, vendar z zagotovilom, da ima v tistem trenutku do njih dostop le ena referenca. Model torej na zelo eleganten način povezuje podatke z naborom dovoljenih operacij in to počne prek samega sistema tipov @yanovskiGhostCellSeparatingPermissions2021.

Pravila o referencah lahko povzamemo z dvemi pravili @klabnikRustProgrammingLanguage2023
+ Hkrati je lahko ustvarjena _ali_ ena spremenljiva referenca _ali_ poljubno število deljenih referenc.
+ Reference morajo biti vedno veljavne (kazati na veljavno mesto).

Še ena podrobnost, ki je pomembna za razumevanje lastništva so *življenjske dobe* #angl[lifetimes], ki so sestavni del tipov. Kot sami tipi v Rustu, so ponavadi izpeljane, vendar se pogosto pri funkcijski zapisih (signatures?) zgodi, da jih moramo eksplicitno podati. Na primer, dejanski tip reference na niz ni `&String` ampak `&'a String`, kjer je `'a` življenjska doba. Pomembno je tudi omeniti, da so življenjske dobe del tipa samo takrat, ko ta predstavlja referenco. Intuitivno si jih lahko predstavljamo kot nabor vrstic v programu, kjer ta referenca mora biti veljavna @klabnikRustProgrammingLanguage2023. Najlažje si to ogledamo s primerom @lst:lifetime-annotate.

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

Ta program nam vrne napako, saj je spremenljivka `x` veljavna samo za življenjsko dobo `'b`, vendar program zahteva, da je veljavna za `'a`. Izračun življenjskih dob je odvisen od implementacije preverjevalnika izposoj, vendar si jih lahko intuitivno predstavljamo kot najmanjšo množico vrstic, kjer bo ta spremenljivka oz. mesto še uporabljeno.

// intuicija glede 2015 verzije borrow checkerja pred NLL: https://youtu.be/uCN_LRcswts?si=S2Ii5VHYF4X7HDo-&t=515
// tukaj razlozim kako gre iz primitivnega do NLL do Poloniusa
// prednosti in slabosti vsakega sistema

#chapter[Formalizacija]

Glavno delo na področju formalizacije Poloniusa je magistrsko delo Amande Stjerna, ki je nastalo leta 2020, dve leti po prvotni formulaciji @stjernaModellingRustsReference @AliasbasedFormulationBorrow. V delu Stjerna prvo formalizira Polonius kot del sistema tipov avtorjev @weissOxideEssenceRust2019 imenovan Oxide @weissOxideEssenceRust2019. Stjerna upraviči svojo izbiro izhodiščnega sistema tipov s tem, da si deli koncept t.i. _provenance variables_. Delo se nato nadaljuje z implementacijo Poloniusa v jeziku Datalog (podmnožica Prologa), ki služi kot podlaga za prvo različico implementacije v Rustovem prevajalniku @RustlangPolonius2025.

V temu poglavju bomo sprva predstavili intuitivni opis delovanja Poloniusa in temu sledili s formalnim opisom pravil Rustovega prevajalnika. Nazadnje bomo še predstavili delovanje Poloniusa iz vidika množic.

== Formalizacija pravil
Da Rustov preverjevalnik izposoj zadosti zagotovilom o varnosti programa mora zavrniti programe,
ki se ne drzijo naslednjih pravil izvzetih iz @stjernaModellingRustsReference.

#pagebreak()
#[
  #show figure: set block(breakable: true)
  #set block(breakable: true)
  #set raw(block: true)
  #show raw: set block(breakable: false)
  #codly(display-name: false, display-icon: false)
  #figure(
    kind: table,
    table(
      columns: (1fr, 1fr),
      align: (left, left),

      table.header[*Pozitiven primer*][*Negativen primer*],

      table.cell(colspan: 2, fill: gray.lighten(80%))[*Use-Init*],
      ```rust
      let x: u32;
      if random() {
          x = 17;
      } else {
          x = 18;
      }
      let y = x + 1;
      ```,
      ```rust
      let x: u32;
      if random() {
          x = 17;
      }
      // ERROR: x not initialized:
      let y = x + 1;
      ```,
      table.cell(colspan: 2, fill: gray.lighten(80%))[*Move-Deinit*],
      ```rust
      let tuple = (vec![1], vec![2]);
      moves_argument(tuple.1);
      // Does not overlap tuple.1:
      let x = tuple.0[0];
      ```,
      ```rust
      let tuple = (vec![1], vec![2]);
      moves_argument(tuple.0);
      // ERROR: use of moved value:
      let x = tuple.0[0];
      ```,
      table.cell(colspan: 2, fill: gray.lighten(80%))[*Shared-Readonly*],
      ```rust
      struct Point(u32, u32);
      let mut pt = Point(13, 17);
      let x = &pt;
      let y = &pt;
      dummy_use(x); dummy_use(y);
      ```,
      ```rust
      struct Point(u32, u32);
      let mut pt = Point(13, 17);
      let x = &pt;
      // ERROR: assigned to
      //   borrowed value:
      pt.0 += 1;
      dummy_use(x);
      ```,

      table.cell(colspan: 2, fill: gray.lighten(80%))[*Unique-Write*],
      ```rust
      struct Point(u32, u32);
      let mut pt = Point(13, 17);
      let x = &mut pt;
      let y = &mut pt;
      //dummy_use(x);
      dummy_use(y);
      ```,
      ```rust
      struct Point(u32, u32);
      let mut pt = Point(13, 17);
      let x = &mut pt;
      // ERROR: cannot borrow `pt`
      // as mutable more than once:
      let y = &mut pt;
      dummy_use(x);
      dummy_use(y);
      ```,

      table.cell(colspan: 2, fill: gray.lighten(80%))[*Ref-Live*],
      ```rust
      struct Point(u32, u32);
      let pt = Point(6, 9);
      let x = {
          &pt
      }; // pt still in scope

      let z = x.0;
      ```,
      ```rust
      struct Point(u32, u32);
      let x = {
          let pt = Point(6, 9);
          &pt
      }; // pt goes out of scope
      // ERROR: pt does not live
      // long enough:
      let z = x.0;
      ```,
    ),
    caption: [Pravila preverjevalnika izposoj iz @stjernaModellingRustsReference. Pozitivni primeri predstavljajo mesta, kjer preverjevalnik sprejme kodo, negativni pa kjer jo zavrne.],
  ) <tab:borrow-check>
]

#pagebreak()
#bibliography("thesis.bib")

