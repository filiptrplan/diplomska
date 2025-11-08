#import "template.typ": thesis, chapter

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()
#codly(languages: codly-languages)
#show raw: set text(size: 9pt)

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

#[
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

Pravilo `Use-Init` nam pove, da lahko uporabljamo samo spremenljivke, ki so zagotovo inicializirane
na točki v programu, kjer jih uporabljamo. Glede na prvotno implementacije Poloniusa Rustove ekipe poleg
osnovnih dejstev opisanih v spletni objavi dobimo še dejstva `var_defined_at`, `var_used_at` in
`var_dropped_at` @RustlangPoloniusDefines.

Mogoče tole zgoraj ni tako relevantno, ker se ukvarjamo z implementacijo že. Lahko definiramo množico
$"Poti"(p)$, ki nam poda vse poti skozi graf poteka od začetka funkcije do začetka trenutne točke $p$
v programu. Potem lahko definiramo še predikat $"Init"(pi, x, p)$, ki velja natanko tedaj, ko je spremenljivka
$x$ skozi pot $pi$ definirana na točki $p$. Končno pravilo se nato glasi:

$ "Use-Init"(x, p) <==> forall pi in "Poti"(p): "Init"(pi, x, p) $

// https://rustc-dev-guide.rust-lang.org/borrow_check/moves_and_initialization/move_paths.html za definicijo move path
Opomba o mestih in poteh premika (_move path_): pojem predpone (_prefix_) je načeloma definiran za pot
premika, vendar ga tukaj posplošimo na mesta iz MIR, ker se nam bolj sklada s terminologijo, ki jo uporabljamo.
Rustov priročnik za prevajalnik tudi omeni, da sta ta pojma približno enaka. Uporabljamo ga namesto spremenljivk
zaradi tega, ker nam opiše lahko bolj fino dostopne podatke kot so polja struktov.

Za pravilo Move-Deinit moramo vpeljati še dva predikata. Prvi nam bo povedal ali se mesti
prekrivata t.j. ali je katero mesto predpona drugega (v Rustovem prevajalniku se temu reče _prefix_). Poimenovali
ga bomo $"Prekrivanje"(m_1, m_2)$, ki velja natanko tedaj, ko je $m_1$ predpona $m_2$ ali obratno. Torej
$"Prekrivanje"("tuple.0", "tuple.0.1")$ bi veljalo, $"Prekrivanje"("tuple.0", "tuple.1")$ pa ne.

Naslednji predikat, ki ga uvedemo je $"Premaknjen"(pi, m, p)$, ki velja natanko tedaj, ko je bilo mesto $m$ premaknjeno
pred točko $p$ na poti $pi$. Kaj točno je premik moram še malo pobrskati po dokumentaciji ampak konceptualno to pomeni,
da lastnik ni več $m$ ampak nekdo drug. Torej pravilo velja ko:

$ "Move-Deinit"(m, p) <==> \ exists.not pi in "Poti"(p), m_2: "Prekrivanje"(m, m_2) and "Premaknjen"(pi, m_2, p) $

Za naslednji pravili Shared-Readonly in Unique-Write moramo definirati še nekaj predikatov. Ker se tokrat
ukvarjamo s posojami, moramo razločevati met deljenimi in spremenljivimi (unikatnimi). V ta namen vpeljemo
predikat $"VrstaPosoje"(L) in {"shrd", "uniq"}$. Da pa lahko razločimo med aktivnimi in preteklimi posojami
pa ustvarimo predikat $"PosojaAktivna"(L,p)$, ki velja natanko tedaj, ko je posoja $L$ aktivna na točki $p$.
Mesto, ki je bilo sposojeno z posojo $L$ označimo z $O(L)$.

Poleg predikatov za posoje pa nam še manjkajo predikati, ki opisujejo operacije, ki se izvajajo nad mesti.
Intuitivno je to lahko več različnih operacij vendar nas zanimajo dve vrsti. Take, ki bi razveljavile deljeno
posojo označimo z $"RazveljaviDeljeno"(m,p)$ in velja natanko tedaj, ko se v točki $p$ nad mestom $m$ izvede
taka operacija, ki bi lahko razveljavila posojo, ki si sposoja iz mesta $m$ (to bi bilo ali pisanje v mesto $m$ ali
pa ustvarjanje spremenljive posoje).

Na podoben način definiramo $"RazveljaviSpremenljivo"(m,p)$, ki velja ko je operacija taka, ki razveljavi
spremenljivo posojo (ustvarjanje kakršnekoli nove posoje, pisanje v mesto, branje iz mesta).
Tako lahko sestavimo naši naslednji dve pravili:

$
  "Shared-Readonly"(p) &<==> exists.not L,m: \
  "PosojaAktivna"(L,p) &and "VrstaPosoje" = "shrd" and \
  "Prekrivanje"(m, O(L)) &and "RazveljaviDeljeno"(m,p)
$

$
  "Unique-Write"(p) &<==> exists.not L,m: \
  "PosojaAktivna"(L,p) &and "VrstaPosoje" = "uniq" and \
  "Prekrivanje"(m, O(L)) &and "RazveljaviSpremenljivo"(m,p)
$

Za zadnje pravilo potrebujemo še en predikat imenovan $"MestoAktivno"(m,p)$, ki velja natanko tedaj,
ko je mesto $m$ še aktivno (torej ni bilo dropped) na točki $p$. Potem pravilo Ref-Live lahko zapišemo tako:

$
  "Ref-Live"(p) &<==> exists.not L, m: \
  "PosojaAktivna"(L,p) &and "Prekrivanje"(m, O(L)) and not "MestoAktivno"(m,p)
$

== Primer

Tekom članka bomo uporabljali naslednji primer izvorne kode anotiran z abstraktnimi regijami (te nimajo čiste bijektivne korespondence z
dejanskimi Rustovimi življenjskimi dobami). Vsi primeri so izvzeti iz originalne spletne objave.

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
  caption: [Primer programa za Polonius],
) <listing:primerPolonius>

== Definicije pojmov

/ Referenca: v Rust-u je podobna kazalcu v ostalih programskih jezikih, vendar prevajalnik zagotavlja, da kaže
  na veljavno vrednost podanega tipa za celotno dobo aktivnosti reference (? pisalo je for the life of the reference) @klabnikRustProgrammingLanguage2023.
  Reference ločimo na dva tipa @crichtonGroundedConceptualModel2023 @yanovskiGhostCellSeparatingPermissions2021 @weissOxideEssenceRust2019:
  - *Deljena referenca (_shared / immutable reference_)*: V programu lahko ustvarimo več deljenih referenc, ki
    kažejo na isto mesto, vendar podatkov na tem mestu ne smemo spreminjati.
  - *Spremenljiva referenca (_unique / mutable reference_)*: Da lahko mutiramo mesto na katerega kaže
    referenca, ustvarimo spremenljivo referenco, ki je ena sama in nam omogoča spreminjanje vrednosti zapisane na posameznem mestu.
    V literaturi jim večinoma pravijo _unique references_, vendar smo izbrali prevod _"spremenljiva"_, saj _"edinstvena"_ ne zveni ustrezno.
  - Tovrsten tip omejevanja ustvarjanja referenc se imenuje _aliasing XOR mutability_. Ta model s pomočjo tipov
    poveže podatke z dovoljenjimi operacijami, ki jih lahko izvajamo na teh podatkih @yanovskiGhostCellSeparatingPermissions2021.

/ Življenska doba (_lifetime_): Vsaka referenca ima življenjsko dobo, ki nam opiše doseg v programu znotraj katerega je
  referenca še vedno veljavna (torej kaže na veljavno mesto) @klabnikRustProgrammingLanguage2023.

/ Posoja (_loan_): je tesno povezana s sorodnim pojmom *izraz izposoje* (_borrow expression_). Izraz izposoje
  je jezikovni konstrukt, ki nam omogoča, da ustvarimo referenco (primer izraza izposoje bi bil `&mut x`).
  Rustov priročnik za prevajlnik @MIRMidlevelIR pojma _borrow expression_ ne definira, ampak ga uporabi tako:

  #quote[An Rvalue is an expression that creates a value: in this case, the rvalue is a
    mutable borrow expression, which looks like `&mut <Place>`]

  Rvalue pa je definiran z enumeratorjem `Rvalue` @RvalueRustc_middleMira. Nas pa zanima specifično
  varianta `Rvalue::ref(Region<'tcx>, BorrowKind, Place<'tcx>)`, ki ustvari referenco tipa `BorrowKind`
  na mesto `Place`.

  Pojem _borrow expression_ pogosto uporabljajo @weissOxideEssenceRust2019 v svojem članku o formalizaciji
  podmnožice Rust-a. Njihov način uporabe se sklada z našo definicijo.

  *Posoja* (_loan_) je interni konstrukt prevajalnika, ki hrani stanje o referenci in njenemu izvoru
  @weissOxideEssenceRust2019. V trenutni implementaciji preverjalnika izposoj je izposoja predstavljena kot
  urejena trojica @2094nllRustRFC `('a, shared|uniq|mut, lvalue)`, kjer je:
  - `'a`: življenjska doba za katero je vrednost izposojena. To se nanaša na življenjske dobe kot
    del Rustovega sistema tipov, ne pa kot množico izposoj, kot jih bomo definirali kasneje.
  - `shared|uniq|mut`: tip izposoje
  - `lvalue`: vrednost, ki je bila izposojena

/ NLL: je trenutna implementacija preverjevalnika izposoj v Rust-ovem prevajalniku.

== Osnovne množice in elementi

=== Množica posoj $cal(L)$

Množico vseh posoj (_angl. loans_) označimo z $cal(L)$. *Pogoji posoje* so lastnosti, ki morajo
držati v določeni točki programa, da smatramo posojo kot veljavno oz. aktivno.
Pravimo, da *razveljavimo pogoje posoje*, če velja ena izmed naslednjih točk:
- Referenca je deljena (_shared_), torej je oblike `&x` in
  - ustvarimo novo spremenljivo referenco
  - pišemo v mesto, ki je bilo izposojeno
- Referenca je spremenljiva in jo spreminjamo na kakršen koli način (ustvarjanje nove reference, pisanje, premikanje)

Ta pravila načeloma sledijo NLLm, bolj formalno jih opisujejo pravila razveljavljanja posoje (_loan killed_).
Iz NLL RFC-ja @2094nllRustRFC:

#quote[For a statement at point P in the graph, we define the "transfer function" – that is,
  which loans it brings into or out of scope – as follows:
  - ...
  - if this is an assignment `lv = <rvalue>`, then any loan for some path P of which `lv` is a prefix is killed.
]

kjer je pojem _prefix_ definiran tako:

#quote[*Prefixes*. We say that the prefixes of an lvalue are all the lvalues you get by stripping away fields and derefs.
  The prefixes of `*a.b` would be `*a.b`, `a.b`, and `a`.]

V članku avtor pravi posojam tudi izrazi izposoje (_borrow expressions_). V našem primeru bi se posoje ustvarile na naslednjih
mestih:

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
  beta: $beta$,
  psi: $psi$,
  zeta: $zeta$,
  iota: $iota$,
  nablaL: $nabla_L$,
  "in": $in$,
  "implies": $arrow.r.double$,
))

#figure(
  ```rust
  fn main() {
    let mut x: i32 = 22;
    let mut v: Vec<&'0 i32> = vec![];
    let r: &'1 mut Vec<&'2 i32> = &'3 mut v; // posoja L0
    let p: &'5 i32 = &'4 x; // posoja L1
    r.push(p);
    x += 1;
    take::<Vec<&'6 i32>>(v);
  }
  fn take<T>(p: T) { .. }
  ```,
  caption: [Posoje v programu],
) <listing:loans>

=== Množica regij $cal(R)$

V trenutni implementaciji preverjevalnika izposoj NLL se posoje spremljajo s pomočjo življenjskih dob.
V tej formulaciji pa je avtor življenjske dobe poimenoval regije (_regions_).
Množica regij je označena z $cal(R) subset 2^cal(L)$.
Na primeru so že označene z `'1`, `'2`, `'3`, itd. Pripadnost posoj regijam bomo kasneje določili z relacijo.

=== Graf poteka izposoje

Graf poteka (_angl. CFG - control flow graph_) je izračunan v prejšnjih fazah analize kode.
Zgrajen je iz osnovnih blokov, ti pa so zgrajeni iz stavkov. Spremlja ga tudi nekaj dodatnih informacij,
ki nam bodo kasneje prišle prav. Te so izračunane tekom analize poteka podatkov
(_dataflow analysis_) @MIRDataflowRust. Graf poteka označimo s $C = (C_V, C_E)$, kjer
je $C_V$ množica vozlišč in $C_E$ množica povezav.

Privzeto se ustvarijo naslednje povezave (to bi moral potrditi v kodi rustc, v članku tako piše):

- Za vsak stavek se ustvari povezava med njegovim začetkom in sredino:
  $forall "stmt" in cal(S): (S("stmt"), M("stmt")) in C_E$
- Če $M("stmt")$ predstavlja _terminator_ (stavek na koncu bloka) potem dodamo povezavo iz njega v $S("stmt"')$
  za vsak stavek $"stmt"'$, ki mu sledi.

_Opomba:_ To je samo matematična formulacija predstavitve grafa poteka, v prevajalniku
je njegova predstavitev precej bolj kompleksna.

==== Množica stavkov in točk

Množico vseh stavkov v MIR označimo s $cal(S)$. Točke v grafu poteka (_CFG - control flow graph_)
označimo s $cal(P)$. Lahko so dveh tipov:
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

=== Začetne relacije

Relacijo označimo kot *začetno* (_input_), ko jo dobimo tako, da jo izpeljemo
iz direktno analize poteka podatkov. Te relacije bodo predstavljale našo izhodiščno točko iz katere bomo izpeljali druge relacije.

==== Začetna relacija vsebovanosti

Začetno relacijo vsebovanosti (_base subset_) bomo označili z
$beta subset cal(R) times cal(R) times cal(P)$. Torej to je relacija, ki povezuje dve regiji
ob neki točki v programu.

Bolj natančno, če velja $(R_1, R_2, P) in beta$ pomeni, da je $R_1$ podmnožica regije $R_2$ na točki $P$ v programu.
To dejstvo mora veljati na sredini stavka ($M("stmt")$), ki inducira zahtevo.

_Opomba:_ Oznaka `<:` nam predstavlja vsebovanost med tipi (_subtyping relation_).

#figure(
  ```rust
  fn main() {
    let mut x: i32 = 22;
    let mut v: Vec<&'0 i32> = vec![];

    let r: &'1 mut Vec<&'2 i32> = &'3 mut v;
    // tukaj zahtevamo naslednje: &'3 mut Vec<&'0 i32> <: &'1 mut Vec<&'2 i32>
    // (r3, r1, P) in beta, (r0, r2, P) in beta, (r2, r0, P) in beta

    let p: &'5 i32 = &'4 x;
    // zahtevamo: &'4 i32 <: &'5 i32
    // (r4, r5, P) in beta

    r.push(p);
    // zahtevamo: &'5 i32 <: &'2 i32
    // (r5, r2, P) in beta

    x += 1;

    take::<Vec<&'6 i32>>(v);
    // zahtevamo Vec<&'0 i32> <: Vec<&'6 i32>
    // (r0, r6, P) in beta
  }
  ```,
  caption: [Začetna relacija vsebovanosti],
)

==== Začetna relacija posoje regij

Začetno relacijo posoje regij (_borrow region_) označimo s $psi subset.eq cal(R) times cal(L) times cal(P)$.

Če velja $(R,L,P) in psi$ pomeni, da izraz izposoje na točki $P$ ustvari posojo $L$ in postane del
regije $R$. Prav tako kot relacija vsebovanosti se ta zahteva vzpostavi na sredini stavka.

#figure(
  ```rust
  fn main() {
    let mut x: i32 = 22;
    let mut v: Vec<&'0 i32> = vec![];
    let r: &'1 mut Vec<&'2 i32> = &'3 mut v;
    // (r3, L0, P) in psi
    let p: &'5 i32 = &'4 x;
    // (r4, L1, P) in psi
    r.push(p);
    x += 1;
    take::<Vec<&'6 i32>>(v);
  }
  ```,
  caption: [Začetna relacija posoje regij],
)

==== Relacija aktivnosti regije

Začetno relacijo aktivnosti regije (_region live at_) označimo z $nabla_R subset.eq cal(R) times cal(P)$.
$(R, P) in nabla_R$ pomeni, da je regija $R$ aktivna na točki $P$. Torej spremenljivka, katere tip vključuje $R$ (recimo `&'a`),
bo morda kasneje v programu uporabljena.

To določi analiza aktivnosti, ki poteka isto kot v NLL RFC. Bolj specifično, s pomočjo raznih omejitev izračuna množico točk
kjer mora biti regija (v RFC-ju poimenovana _lifetime_) aktivna @2094nllRustRFC.

==== Relacija prekinitve posoje

Začetno relacijo prekinitve posoje (_loan killed at_) označimo s $kappa subset.eq cal(L) times cal(P)$.
$(L,P) in kappa$ pomeni, da je posoja $L$ prekinjena (_killed_) na točki $P$. Pojem prekinitve oziroma razveljavitve
pogojev smo definirali že zgoraj. To se običajno zgodi na sredini prireditvenega stavka, ki prepiše pot (_path_) prej povezano s posojo $L$.

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

==== Relacija razveljavitve posoje

Začetno relacijo razveljavitve posoje (_invalidates loan_) označimo z $iota subset cal(P) times cal(L)$.
To pomeni, da dejanje na točki $P$ (recimo mutacija izposojenega mesta) razveljavi pogoje posoje $L$, kar
je že opisano v poglavju o definicije množice $cal(L)$.

#figure(
  ```rust
  fn main() {
    let mut x: i32 = 22;
    let mut v: Vec<&'0 i32> = vec![];
    let r: &'1 mut Vec<&'2 i32> = &'3 mut v;
    // (r3, L0, P) in psi
    let p: &'5 i32 = &'4 x;
    // (r4, L1, P) in psi
    r.push(p);
    x += 1; // tukaj razveljavimo L₁ z mutacijo deljenega referenta
    take::<Vec<&'6 i32>>(v);
  }
  ```,
  caption: [Primer razveljavitve posoje],
) <listing:loanInvalidated>

=== Izpeljane relacije

V tem poglavju bomo opisali relacije, ki jih izpeljemo iz začetnih. Te relacije tvorijo najbolj pomembni del analize
Polonius-a.

V primerih ne bomo označevali točk v grafu poteka pri relacijah, ker bo koda anotirana na tistem mestu, kjer
se posamezna relacija pojavi. V ozadju se to še vedno izvaja na nivoju MIR, vendar za naše poenostavljene
primere to ni ključna informacija. (torej pisali bomo $(R_1, R_2) in beta$ namesto $(R_1, R_2, P) in beta$).

==== Relacija vsebovanosti

Razširimo začetno relacijo vsebovanosti z (raširjeno) relacijo vsebovanosti (_subset_), ki jo označimo z
$Gamma subset.eq cal(R) times cal(R) times cal(P)$. Definirana je z zaprtjem naslednjih pravil:

+ *Začetna relacija:* Če $(R_1, R_2, P) in beta$, potem $(R_1, R_2, P) in Gamma$. Torej vse trojice
  iz začetne relacije se pojavijo tudi v razširjeni.
+ *Tranzitivnost:* Če $(R_1, R_2, P) in Gamma$ in $(R_2, R_3, P) in Gamma$, potem $(R_1, R_3, P) in Gamma$.
  Relacija vsebovanosti na isti točki v programu je tranzitivna.
+ *Propagacija:* Če veljajo vse izmed naštetega:
  + $(R_1, R_2, P) in Gamma$
  + $(P, Q) in C_E$: točki si sledita v grafu poteka
  + $(R_1, Q) in nabla_R$: regija 1 je aktivna na naslednji točki
  + $(R_2, Q) in nabla_R$: regija 2 je aktivna

  potem sledi $(R_1, R_2, Q) in Gamma$. To pomeni, da se relacija propagira čez graf poteka, če sta obe
  regiji aktivni na naslednji točki v grafu. Pogoj za aktivnost nam pride prav kasneje.

Na primeru ustvarimo naslednje relacije:

#figure(
  ```rust
  fn main() {
    let mut x: i32 = 22;
    let mut v: Vec<&'0 i32> = vec![];

    let r: &'1 mut Vec<&'2 i32> = &'3 mut v;
    // (r3, r1) in beta, (r0, r2) in beta, (r2, r0) in beta

    let p: &'5 i32 = &'4 x;
    // (r3, r1) in beta, (r0, r2) in beta, (r2, r0) in beta
    // (r4, r5) in beta

    r.push(p);
    // (r3, r1) in beta, (r0, r2) in beta, (r2, r0) in beta
    // (r4, r5) in beta
    // (r5, r2) in beta

    x += 1;

    take::<Vec<&'6 i32>>(v);
    // (r3, r1) in beta, (r0, r2) in beta, (r2, r0) in beta
    // (r4, r5) in beta
    // (r5, r2) in beta
    // (r0, r6) in beta
  }

  fn take<T>(p: T) { .. }
  ```,
  caption: [Relacija vsebovanosti],
) <listing:subsetRelations>

==== Relacija zahteve

Relacija zahteve nam pove, da regija $R$ zahteva, da pogoji posoje $L$ veljajo na točki $P$. Označimo jo s
$zeta subset.eq cal(R) times cal(L) times cal(P)$ in definirana je z zaprtjem naslednjih pravil:

+ *Začetna relacija:* Če $(R, L, P) in psi$, potem $(R, L, P) in zeta$. To nam pove, da če se trojica
  nahaja v relaciji posoje regij, se nahaja tudi v $zeta$.
+ *Vsebovanost:* Če velja $(R_1, L, P) in zeta$ in $(R_1, R_2, P) in Gamma$, potem sledi
  $(R_2, L, P) in zeta$. To nam pove, da če neka regija $R_1$, ki je podmnožica večje regije $R_2$, na točki $P$
  zahteva posojo $L$, potem tudi $R_2$ zahteva isto posojo.
+ *Propagacija:* Če veljajo vse:
  + $(R,L,P) in zeta$: $R$ zahteva $L$ na $P$
  + $(L, P) in.not kappa$: $L$ ni prekinjena na $P$
  + $(P, Q) in C_E$: $Q$ sledi $P$ v grafu poteka
  + $(R,Q) in nabla_R$: regija $R$ je aktivna na točki $Q$

  potem propagiramo relacijo v $(R,L,Q) in zeta$.

Opazimo, da pri relaciji vsebovanosti $beta$ in pri relaciji zahteve $zeta$ mora biti regija pri pravilu
za propagacijo aktivna na naslednji točki $Q$. Z naslednjim primerom ponazorimo zakaj je to ključna omejitev.

#figure(
  ```rust
  let x = 22;
  let y = 44;

  let mut p: &'0 i32 = &'1 x; // posoja L₀
  // (r1,r0) in beta
  // (r1, L0) in zeta

  p = &'3 y; // posoja L₁
  // (r3,r0) in beta
  // (r3, L1) in zeta
  // r1 ni več aktivna, ker smo jo prepisali z r3

  x += 1;
  // razveljavi se posoja L0: (L0) in iota
  // tukaj bi brez pravila o aktivnosti regij še vedno zahtevali
  // (L0, r0) in zeta zaradi pravila o propagaciji

  print( *p );
  // ta izraz posledično ne bi bil veljaven
  ```,
  caption: [Primer relacije zahteve],
) <listing:reqRelation>

==== Relacija aktivnosti posoje

Relacija aktivnosti posoje (_loan live at_) pomeni, da je posoja $L$ aktivna na točki $P$. Označimo jo s
$nabla_L subset.eq cal(L) times cal(P)$ in jo definiramo takrat, ko

$ exists R in cal(R): (R,P) in nabla_R and (R,L,P) in zeta $

To na kratko pomeni, da je posoja aktivna, če jo na isti točki zahteva neka aktivna regija.

=== Javljanje napake

S pomočjo prejšnjih relacij lahko na koncu definiramo kje v programu javimo napako (v obsegu preverjalnika posoj).
Že spet si pomagamo z relacijo, ki jo tokrat poimenujemo *relacija napake* (_error_) in jo označimo z
$epsilon subset cal(P)$. Ta relacija nam pove, da javimo napako na točki $P$ v programu.

Definiramo jo, ko velja:

$ exists L in cal(L): (P, L) in iota and (L,P) in nabla_L $

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
    // (r4, L1) in zeta
    // (r4, r5) in beta implies (r5, L1) in zeta

    r.push(p);
    // (r5, r2) in beta implies (r2, L1) in zeta

    x += 1;
    // Tukaj se razveljavi posoja L1: (L1) in iota.
    // Da se nam javi napaka mora biti ta posoja aktivna (L1) in nablaL.
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

