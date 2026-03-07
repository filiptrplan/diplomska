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
#set scale(reflow: true)

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

#let angl(cont) = [(angl. #cont)]

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
    Naloga matematično formalizira novo različico Rustovega preverjevalnika izposoj s pomočjo množic in relacij na preprost in razumljiv način.
  ],
  title_en: "Formalization of the Original Formulation of Polonius",
  description_en: [
    The thesis provides a mathematical formalization of the new version of Rust's borrow checker using sets and relations in a simple and understandable manner.
  ],
  abstract_sl: [
    Naloga zastavi matematično formalizacijo Poloniusa, preverjevalnika izposoj za programski jezik Rust. Posebnost Rusta je ta, da zagotovi pomnilniško varnost s pomočjo svojega sistema tipov in preverjevalnika izposoj ter s tem prevajalnik ne vpliva na izvajanje programa. Trenutna implementacija, imenovana NLL, je v nekaterih primerih preveč konzervativna, zato so razvijalci Rusta uvedli novo različico, imenovano Polonius, ki je osnovana na bolj natančni analizi toka podatkov. Polonius pa nikjer ni uradno definiran in viri o njem so razpršeni, zato je cilj te naloge postaviti matematičen okvir, skozi katerega lahko razumemo to novo različico. Tega se lotimo z uporabo množic in izjav, tako da pravila, ki so bila zastavljena v raznih virih, opišemo s pomočjo predikatov ter pravil sklepanja. Končni izdelek je poenostavljen, vendar formalen, opis Poloniusa.
  ],
  keywords_sl: "Rust, Polonius, preverjevalnik izposoj, formalizacija",
  abstract_en: [
    This thesis provides a mathematical formalization of Polonius, the next-generation borrow checker for the Rust programming language. Rust's distinguishing feature is its ability to guarantee memory safety through its type system and borrow checker, ensuring safety without impacting runtime performance. The current implementation, known as NLL (Non-Lexical Lifetimes), remains overly conservative in certain cases -- consequently, Rust developers have introduced a new version called Polonius, which is based on a more precise data-flow analysis. However, Polonius lacks an official specification, and information regarding its workings remains scattered. The goal of this thesis is to establish a mathematical framework that enables a clear understanding of this new implementation. This is approached using sets and logical statements, describing the rules established in various sources through predicates and inference rules. The final result is a simplified but formal description of Polonius.
  ],
  keywords_en: "Rust, Polonius, borrow checker, formalization",
  zahvala: [
    Zahvaljujem se svojemu mentorju doc. dr. Boštjanu Slivniku za vodstvo, pomoč in temeljite ter koristne popravke ob izdelavi diplomskega dela. Zahvala gre tudi mojim staršem za spodbudo in punci Klari za vso podporo ter optimizem ob pisanju.
  ],
  kratice: [
    #table(
      columns: (15%, 85%),
      stroke: none,
      gutter: 0.6em,
      [*NLL*], [Non-Lexical Lifetimes (neleksikalne življenjske dobe)],
      [*MIR*], [Mid-level Intermediate Representation (srednjenivojska vmesna predstavitev)],
      [*CFG*], [Control Flow Graph (graf poteka programa)],
      [*RFC*], [Request for Comments (dokument s specifikacijami)],
    )
  ],
)

#chapter(breakpage: false)[Uvod]
Pomnilniška varnost #angl[memory safety] je na področju pisanja programske opreme vedno aktualna tema. Razvijalci pri Microsoftu so pokazali, da so napake pri upravljanju s pomnilnikom najbolj pogost tip napak @Microsoft70Percent. Pri projektu Chromium, na katerem je osnovan Google Chrome, so opazili, da okoli 70 procentov hroščev povzročijo tovrstne napake @MemorySafetya. Če bi se lahko znebili te kategorije napak, bi se izognili precejšnemu delu hroščev. Posledično so se pomnilniške varnosti razvijalci jezikov lotili na različne načine.

Eden najbolj razširjenih jezikov je C, kjer je programerju upravljanje s pomnilnikom povsem prepuščeno. Tovrsten pristop, imenovan ročno upravljanje s pomnilnikom, lahko vodi do izredno hitrih programov in krajših časov prevajanja v primerjavi z Rustom @glazarCodingRustBad2023. Vendar je obenem tudi pogost vir napak @MemorySafetya.

Alternativni pristop ročnemu upravljanju je avtomatsko upravljanje s pomnilnikom, kjer programski jezik zagotavlja varno dodeljevanje in sproščanje pomnilnika. S tem razbremeni programerja, da se lahko osredotoči na pisanje programa. Vendar imajo jeziki z avtomatskim upravljanjem pomnilnika dve glavni slabosti: zaradi zakasnjenega sproščanja se pojavi večja poraba pomnilnik ter, da lahko čistilec pomnilnika najde pomnilniške lokacije za sprostitev, pride do premorov med izvajanjem programa ali zakasnitev ob vsaki operaciji @bakerListProcessingReal1978.

Rust pristopi k upravljanju s pomnilnikom na drugačen način. Veljavnost dostopanja do pomnilniških lokacij se preverja med časom prevajanja s pomočjo preverjevalnika izposoj #angl[borrow checker]. Ta je komponenta Rustovega prevajalnika, ki se ukvarja s tokom podatkov in pomnilniškimi lokacijami. Rust imenuje zbirko pravil, ki opisuje delovanje preverjevalnika izposoj, lastništvo #angl[ownership]. V knjigi _The Rust Programming Language_ lastništvo avtorji opišejo tako: _"Ownership is a set of rules that govern how a Rust program manages memory"_ @klabnikRustProgrammingLanguage2023. Tak pristop ima dve glavni prednosti: zagotovi nam, da je naš program pomnilniško varen, kot pri avtomatičnem upravljanju s pomnilnikom, ter omogoči hitrost izvajanja programov, ki jo lahko dosežemo z ročnim upravljanjem pomnilnika @klabnikRustProgrammingLanguage2023. Pogosto omenjena slabost Rusta je dolg čas prevajanja @glazarCodingRustBad2023, ki sicer ni odvisen samo od preverjevalnika izposoj, vendar njegov prispevek ni zanemarljiv.

V nadaljevanju bomo uporabljali dva podobna pojma. _Varen program_ je program, ki ne povzroča pomnilniških napak. _Veljaven program_ pa je program, ki je glede na Rustova pravila lastništva in izposojanja veljaven. Cilj Rustovega prevajalnika je, da bi bili ti dve množici programov enaki, vendar se zaradi neizračunljivosti izkaže, da je vsak veljavni program tudi varen, vendar zato žal v Rustu ni vsak varen program veljaven.

Preverjevalnik izposoj se je med razvojem Rusta bistveno spremenil od svoje prvotne implementacije. Na začetku je bil preprost in zaradi svoje konzervativnosti pri zagotavljanju varnosti veliko varnih programov ni sprejel @2094nllRustRFC. Zato se je čez par let pojavila naslednja različica preverjevalnika, imenovana NLL #angl[non-lexical lifetimes], ki je rešila veliko pogostih problemov s prvotno različico. Vendar NLL še vedno ni sprejemal vseh varnih programov. Da bi to naslovili, so Rustovi razvijalci predlagali najnovejšo različico preverjevalnika, imenovano Polonius, ki drugače zastavi problem lastništva in tako sprejme še večji delež varnih programov @matsakisAliasbasedFormulationBorrow.

NLL je bil natančno opisan v RFC-ju #angl[request for comment], kar je potem vodilo njegov razvoj. Polonius pa je nastal kot predlog na spletnem blogu enega izmed razvijalcev Rusta, kjer se je postopoma razvijal skozi nadaljne objave @PoloniusRevisitedPartb @PoloniusRevisitedPartc @WhatPoloniusPolonius. Celovit centraliziran formalen opis Poloniusa trenutno ne obstaja, imamo le nekaj spletnih objav, delni formalni opis v magistrskem delu enega izmed razvijalcev @stjernaModellingRustsReference2020, nedokončana knjiga na GitHubu @WhatPoloniusPolonius ter trenutna implementacija v Rustovem prevajalniku.

Cilj te naloge je torej na svoj način formalizirati pravila, na katerih temelji Polonius. Najprej raziščemo pretekle poskuse formalizacije Rusta ter sorodne načine upravljanja s pomnilnikom. Sledi intuitivni opis Rustovih pravili izposojanja in nato formalni opis Poloniusovih inferenčnih pravil.

== Motivacijski primer <chap:motivacijski-primer>

Za grajenje intuicije o razlikah med trenutno različico preverjevalnika izposoj (NLL) in med Poloniusom bomo obravnavali motivacijski primer (@listing:mot_ex[program]), ki ga NLL zavrne ter Polonius sprejme. Primer je prilagojen iz prvotnega predloga NLL-ja @2094nllRustRFC.

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
  ```,
  caption: [Napaka pri prevajanju primera @listing:mot_ex z NLL-jem],
  supplement: "Izpis",
) <listing:mot_ex_err>

// TODO: smatra?

Če postopoma sledimo sporočilu o napaki na @listing:mot_ex_err[izpisu], lahko vidimo, kje NLL ne sprejme varnega programa. V vrstici 8 kličemo funkcijo `get_mut`, ki vrne unijo z dvema možnostima. Lahko vrne spremenljivo referenco na vrednost, ki pripada ključu (`Some(value)`), ali pa ne vrne ničesar (`None`). Če vrne vrednost, je spremenljivka `map` začasno izsposojena (torej obstaja spremenljiva referenca na pomnilniško lokacijo z njenimi podatki), kar se zgodi v vrstici 9. Vendar NLL presodi, da je spremenljivka `map` še vedno izsposojena, tudi če nismo vrnili njene reference iz funkcije `get_mut` (v vrsticah 11-13). Ko torej poskušamo vstaviti nov par v `map`, nam to preverjevalnik izposoj konzervativno prepreči, saj operacija `insert` zahteva spremenljivo referenco na spremenljivko `map` (saj jo spreminjamo z vstavljanjem para), dve spremenljivi referenci na isto mesto pa po pravilih jezika ne smeta obstajati.

V nasprotju z NLL-om Polonius prevede @listing:mot_ex[program] kot veljaven, saj ima večje zmožnosti sledenja kontrolnemu toku in lahko zgornjo analizo opravi podrobneje. NLL ima omejene zmožnosti obravnavanja kontrolnega toka, ki jih Polonius nadgradi v zameno za hitrost. Amanda Stjerna, ena izmed razvijalcev Poloniusa, je na predstavitvi na konferenci EuroRust omenila, da v prihodnosti načrtujejo dvoslojni preverjevalnik izposoj. Med prevajanjem bi se sprva analiza opravila z NLL-jem, saj je bistveno hitrejši, Polonius pa bi obravnaval samo zahtevnejše primere, ki jih NLL zavrne @eurorustFirstSixYears2024 (na 23:15).

#chapter[Pregled literature]

Rust je jezik inžinirjev, ne raziskovalcev. Od začetka je bil zasnovan tako, da reši današnje probleme ter se ukvarja s specifikacijami in formalnostjo kasneje. Ta način dela je porodil veliko vprašanj o temu, kako jezik deluje, zakaj deluje in ali deluje pravilno. Čeprav je Rust prišel na svet šele leta 2015 @4YearsRust, je v zadnjem desetletju nastalo vrsto člankov o raznih formalnih pogledih na Rust.

V tem poglavju se bomo lotili treh glavnih kategorij raziskav in virov:
+ *Poskusi formalizacije Rusta:* ogledali si bomo, kako so se raziskovalci lotili problema formalizacije različnih komponent Rusta.
+ *Modeli sorodni lastništvu:* ker je Rustov pomnilniški model eden izmed njegovih ključnih značilnosti, si bomo ogledali sorodne modele.
+ *Polonius v akademskem svetu in praksi:* tukaj bomo opisali, kako je Polonius nastal, kje trenutno je in drugo literaturo o njem.

== Poskusi formalizacije Rusta

Formalizacija Rusta in preverjanje pravilnosti kode je zelo relevantna tema, saj je jezik kompleksen in brez uradne specifikacije. Osredotočili se bomo na formalizacije preverjevalnika izposoj, saj je to tema te naloge. Obstajajo pa tudi številne druge formalizacije, ki se ukvarjajo s sistemom tipov ali s pravilnostjo programov @matsushitaRustHornBeltSemanticFoundation2022a @villaniTreeBorrows2025a.

#show "lambdaR": $lambda_"Rust"$

V nadaljevanju bomo omenili vmesno kodo _MIR_ #angl[Mid-level intermediate representation], s pomočjo katere prevajalnik preverja pomnilniško pravilnost prograrmov. MIR je bistveno poenostavljena oblika Rusta in zadnji korak pred generiranjem strojne kode v zadnjem delu prevajalnika (v Rustovem primeru je zadnji del LLVM). Temelji na grafu kontrole toka, ki ga opišemo pozneje v nalogi.

Še en pomemben pojem je _zataknjeno stanje_ #angl[stuck state], ki intuitivno pomeni da program ne more nadaljevati, saj iz trenutnega stanja glede na operacijsko semantiko jezika ni več veljavnega koraka. Torej stanje je glede na definicijo jezika nesmiselno @pierceTypesProgrammingLanguages2002.

Eden izmed ključnih del na področju formalizacije je akademski članek RustBelt Junga idr., ki so zasnovali jezik imenovan lambdaR ter ga opremili s semantičnim modelom imenovan RustBelt. Jezik lambdaR je sam bolj podoben MIRu kot pa izvirni kodi Rusta. Vsebuje tudi sistem tipov in pravila sklepanja, ki modelirajo MIR. Članek se konča z dokazom, da katerikoli lambdaR program, ki je semantično in tipsko pravilen, ne bo končal v zataknjenem stanju @jungRustBeltSecuringFoundations2018.

// TODO: to z bistvom rusta

Še en model Rusta je imenovan Oxide @weissOxideEssenceRust2019, kjer avtorji zasnujejo višjenivojski jezik, tokrat bolj podoben izvirni kodi Rusta. V primerjavi z RustBeltom, se avtorji bolj osredotočijo na preverjevalnik izposoj, saj niso želeli natančno modelirati operacijske semantike, temveč je bil njihov cilj zajeti bistvo Rusta. Oxidova sintaksa je zelo podobna Rustovi, le da so vsi tipi eksplicitno podani. Avtorji nadaljujejo članek s tem, da podajo pravila sklepanja v temu sistemu tipov in uvedejo pojem _domnevnega izvora_  #angl[approximate provenance], ki je njihov način izražanja regij, kot so zastavljene v NLL-ju. Članek se nadaljuje s semantiko majhnih korakov in konča s formalnim dokazom, da pravilno konstruirani programi v Oxidu ne končajo v zataknjenem stanju. Pri tem članku je še zanimivo, da specifično omenijo Polonius ter povejo, da je Poloniusov model regij zelo podoben njihovim domnevnim izvorom. Omenijo, da kljub temu, da niso raziskali povezave med Poloniusom in Oxidom, lahko na Oxide gledamo kot formulacijo Poloniusa preko sistema tipov.

// TODO: zataknjenem

Takih podobnih modelov je še mnogo. Članek Crihchtona idr. zastavi poenostavljen pedagoški model za razumevanja sistema lastništva @crichtonGroundedConceptualModel2023. V njemu tudi eksplicitno, vendar le na kratko, opišejo Polonius. Patina @reedPatinaFormalizationRust je eden izmed prvih formalnih semantičnih modelov za Rust in je nastala še pred uvedbo NLL-ja. KRust @wangKRustFormalExecutable2018 je formalni izvedljiv semantični model v ogrodju imenovanem K in tudi, v kolikor vemo, prvi semantični model v dobi NLL-a. Featherweight Rust @pearceLightweightFormalismReference2021 se eksplicitno ukvarja s formalizacijo preverjevalnika izposoj (vrste NLL), tako da definira slovnico in semantiko majhnih korakov. Zasnovan je bil kot striktna podmnožica Rustove sintakse. Še zadnji članek, ki ga bomo omenili, je od Ho idr., ki so dokazali, da LLBC (low-level borrow calculus, model rustovega MIR), res pravilno modelira Rust in ne konča v zataknjenem stanju @hoSoundBorrowCheckingRust2024.

== Modeli sorodni lastništvu

V temu poglavju se bomo osredotočili na _regijsko upravljanje s pomnilnikom_ #angl[region-based memory management] @tofteRegionBasedMemoryManagement1997, ki sta ga prvo opisala Tofte in Talpin. Ta model upravljanja s pomnilnikom lahko razumemo skoraj kot direktni predhodnik lastništva.

Njuna poglavitna motivacija je bila, da najdeta kompromis med ročnim upravljanjem s pomnilnikom, kot pri C-ju, ter avtomatskim čiščenjem pomnilnika, kot pri Javi. Za navdih sta vzela delovanje sklada, kjer se spomin dodeli na začetku okvirja ter sprosti na koncu. Tako sta ustvarila koncept regij, ki so dodatne označbe poleg tipov in podajo informacije o tem kdaj se vrednost mora sprostiti.

Ker bi bilo anotiranje vsake vrednosti z regijami nepraktično, sta uvedla način avtomatskega izračuna teh regij, podoben tistemu, ki izračuna življenjske dobe v Rustu. V delu definirata visokonivojski jezik `SExp` podoben SML-u skupaj s sistemom ML tipov in semantiko majhnih korakov. Nato uvedeta jezik `TExp` v katerega se `SExp` pretvarja. Ključna razlika med njima je, da ima `TExp` regijske anotacije, `SExp` pa ne. Delo nadaljujeta s sistemom za avtomatično inferenciranje teh regij osnovnanem na Milnerjevemu sistemu tipov. Končata z dokazi o pravilnosti njunega sistema in pravilnosti prevoda med `SExp` in `TExp`.

// TODO: memory leaks

Rust ni bil prvi jezik, ki je uvedel pomnilniški model soroden regijskem upravljanju s pomnilnikom (poleg seveda akademskega jezika predstavljenega v izvornem delu). Eden izmed najbolj znanih jezikov, ki so v praksi uporabili regijsko upravljanje s pomnilnikom, je Cyclone @grossmanRegionBasedMemoryManagement. Ustvarjen je bil kot dopolnilo C-ju z raznimi bolj naprednimi tipi. Kasneje so tudi dodali regijsko upravljanje s pomnilnikom, ki ga lahko programer doda C programu z nekaj dodatnimi regijskimi anotacijami. Prva implementacija sicer ni bila popolna in je še vedno kdaj uvedla puščanje pomnilnika #angl[memory leaks], vendar so kasnejše različice jezika z linearnimi regijami to poskušale popraviti @fluetLinearRegionsAre2006.

== Polonius v akademskem svetu in praksi

Polonius je bil prvotno formuliran v spletni objavi N. D. Matsakisa, kjer je poljudno pojasnil, kako bi Polonius naslovil problem starega NLL, in podal osnovno formulacijo v Datalogu @matsakisAliasbasedFormulationBorrow. Delo se je nato nadaljevalo v GitHub repozitoriju `rust-lang/polonius` @RustlangPolonius2025, kjer so to originalno formulacijo implementirali v Rustu.

Leta #cite(<stjernaModellingRustsReference2020>, form: "year") je Amanda Stjerna v svojem magistrskem delu podala prvo matematično formulacijo Poloniusa kot sistema tipov @stjernaModellingRustsReference2020. Ta formulacija je bila močno osnovana na Oxidu, saj sta si modela zelo podobna. V svojem delu je tudi opisala pravila za preverjevalnik posoj, ki jih kasneje v nalogi tudi opišemo in formaliziramo. Njeno delo se nadaljuje natančnejšim opisom Poloniusovega notranjega delovanja z vsemi podrobnostmi, potrebnimi za konkretno implementacijo. Kolikor vemo, je to delo eno izmed najbolj podrobnih in celovitih opisov Poloniusovega delovanja.

Trenutno še ne obstaja uradna specifikacija za Polonius, vendar se stanje počasi spreminja. Leta 2025 je bil Polonius implementiran v glavni veji Rustovega prevajalnika in je trenutno na zahtevo dostopen v `nightly` različici prevajalnika @ScalablePoloniusSupporta. Če pogledamo izvorno kodo prevajalnika, lahko vidimo da obstajata dve različici Poloniusa @RustlangRust2026: osnovna #angl[legacy] različica podobna prvotni implementaciji iz @RustlangPolonius2025 ter prilagojena #angl[alpha] različica, ki je nastala zaradi počasnega izvajanja osnovne različice. Prilagojena različica je napisana v Rustu in ne poskuša emulirati Dataloga, vendar ji manjkajo nekatere sposobnosti osnovne različice napisane v Datalogu @ScalablePoloniusSupporta.

#show "amir": `a-mir-formality`

Pomanjkanje uradne specifikacije je problem, ki ga trenutno rešuje Rustova ekipa za tipe v okviru projekta imenovanem amir @BorrowCheckingAmirformalityb @RustlangAmirformality2026. Ekipa želi ustvariti uradno izvedljivo specifikacijo za Rust, s katero se bo potem preverjalo pravilno delovanje Rustovega prevajalnika. "Izvedljiva" v tem kontekstu pomeni, da ji lahko kot vhod damo Rust program (oziroma trenutno MiniRust, ki je bolj podoben MIR @MinirustMinirust2026), amir pa ga sprejme ali zavrne, glede na to, ali je pravilno tipiziran in pomnilniško varen. V drugi polovici leta 2025 se je začelo delo na specifikaciji za prilagojeno različico Poloniusa, ki je v času pisanja na začetku 2026 že skoraj končana. Če se delo pod amir nadaljuje, bo lahko Rust končno dobil uradno specifikacijo, ki mu že od spočetja manjka.

#chapter[Rustov model upravljanja s pomnilnikom -- lastništvo]

V @chap:motivacijski-primer[razdelku] smo s @listing:mot_ex[programom] predstavili primer, ki je motiviral nastanek Poloniusa. Zraven smo podali intuitivno razlago, zakaj je ta program varen, vendar smo se nanašali na pravila, ki so osnovana na lastništvu -- Rustovem naboru pravil za zagotavljanje pomnilniško varnih programov.

Knjiga _The Rust Programming Language_, neuradni priročnik za Rust, nam pove, da lastništvo temelji na treh pravilih @klabnikRustProgrammingLanguage2023:

+ Vsaka vrednost v Rustu ima _lastnika_.
+ Za vsako vrednost lahko obstaja samo en lastnik hkrati.
+ Ko lastnik ni več v dosegu, je vrednost sproščena #angl[dropped].

Lastnik se tukaj nanaša na spremenljivko (bolj natančno lvalue), na katero je ta vrednost vezana. V @listing:ownership1[programu] opazimo, da vrednost `"hello"` enkrat zamenja lastnika, torej njen prvotni lastnik `a` potem več ne vsebuje vrednosti, saj je ta zdaj v lasti `b`. Če hočemo uporabiti `a` potem, ko ni več lastnik vrednosti, nam prevajalnik vrne napako.

#figure(
  ```rust
  let a = "hello";
  let b = a;
  println!("{}", a); // vrne napako
  ```,
  caption: [Primer napačnega lastništva],
) <listing:ownership1>

// TODO: leksikalnim dosegom

Lastništvo je vezano na doseg. Koncept dosega lahko preprosto ponazorimo z leksikalnim dosegom, tako da inicializiramo novo vrednost vezano na `a` znotraj gnezdenega bloka, ki ustvari nov doseg. To je prikazano v @listing:scope1[programu].

#figure(
  ```rust
  {
      let a = "goodbye";
  }
  println!("{}", a); // vrne napako ker `a` ni več v dosegu
  ```,
  caption: [Primer leksičnega dosega],
) <listing:scope1>

// TODO: zivljenjsko dobo te reference?

V primerih 3 in 4 nismo opazili bistvene razlike med Rustom ter sorodnimi jeziki, kot sta C in C++. Razlika se pojavi v načinu ustavrjanja referenc ter v njihovi delitvi na dva različna tipa. Rustove reference so na prvi pogled podobne kazalcem, kakršne poznamo iz drugih programskih jezikov. Ključna razlika je v tem, da Rustov prevajalnik poskrbi, da referenca vedno kaže na veljavno vrednost pravega tipa -- in to skozi celotno življenjsko dobo te reference @klabnikRustProgrammingLanguage2023. Ta varnostni mehanizem nam omogoča nekaj, kar je v mnogih drugih jezikih bistveno težje doseči: zagotovilo, da reference "ne visijo v prazno" ter da ne dostopamo do podatkov, ki morda sploh več ne obstajajo.

V preostanku naloge ima MIR osrednjo vlogo, saj Rusta bistveno poenostavi preverjanje izposoj in omogoča lažjo analizo. Prav tako je v okviru MIRa točno definiran pojem _mesta_ #angl[place], ki je eden izmed ključnih pojmov pri analizi pomnilniške varnosti programa. Mesto je izraz, ki nam opredeli lokacijo v pomnilniku. To je lahko lokalna spremenljivka (npr. `oseba`) ali pa njena projekcija (npr. polje strukture `oseba.starost`) @MIRMidlevelIR.

Zdaj lahko s pojmom mesta opredelimo dve glavni vrsti referenc @crichtonGroundedConceptualModel2023 @yanovskiGhostCellSeparatingPermissions2021 @weissOxideEssenceRust2019. Delimo jih lahko na dveh oseh: spremenljive oz. nespremenljive ali unikatne oz. deljene. Ker slednja delitev bolje ponazori omejitve pri ustvarjanju referenc, bomo uporabljali naslednjo terminologijo:

/ Deljene reference #angl[shared references]: Ker s tem tipom želimo ustvariti več referenc na isto pomnilniško mesto, morajo biti tudi zato _nespremenljive_ #angl[immutable], kar pomeni, da podatkov na tem mestu ne smemo spreminjati. To pravilo mora veljati, da je uporaba tovrstnih referenc varna

/ Unikatne reference #angl[unique references]: Občasno želimo tudi spreminjati vrednost na katero kaže referenca preko te reference. Zato uvedemo unikatne reference, ki so tudi posledično _spremenljive_ #angl[mutable]. Pravilo, ki ohranja pomnilniško varnost se glasi: če obstaja unikatna referenca na pomnilniško mesto, na to mesto ne sme kazati nobena druga aktivna referenca (deljena ali unikatna). Aktivnost reference tukaj pomeni isto kot aktivnost spremenljivke.

_Opomba:_ V Rustovski terminologiji se ponavadi reference ne ločijo po isti osi. Ponavadi jih delimo na deljene ter nespremenljive reference.

// #remark(title: "Teorija za referencami")[
//   Tovrsten tip omejevanja ustvarjanja referenc se imenuje _aliasing XOR mutability_. Ta model s pomočjo tipov
//   poveže podatke z dovoljenjimi operacijami, ki jih lahko izvajamo na teh podatkih @yanovskiGhostCellSeparatingPermissions2021.
// ]

Programi 5-8 ponazorijo pravilno ter nepravilno uporabo različnih tipov referenc. Če prvo obravnavamo programa 5 in 6, vidimo kako se pravilo o nespremenljivosti izrazi v kodi. Če bi v @lst:uporabadeljena[programu] po izpisu dodali še vrstico `*b = 7` (pisanje preko reference), bi nam prevajalnik vrnil napako zaradi kršitve zagotovila o preprečitvi branja.

V programih 7 in 8 prav tako opazimo, da če bi poskusili izpisati spremenljivko `a`, ki je bila spremenljivo izposojena v @lst:uporabaspremenljiva[programu], bi bil program zavrnjen, saj prevajalnik prepreči, da bi hkrati uporabljali lastnika vrednosti in njeno spremenljivo referenco.

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




To razmerje med obema vrstama referenc -- večkratne nespremenljive ali pa ena sama spremenljiva -- lahko strnemo v načelo, ki ga angleško imenujemo _aliasing XOR mutability_. Ideja tega načela je preprosta: podatkovne strukture so lahko bodisi dostopne na več mestih hkrati (torej imajo več imen oziroma referenc), vendar jih lahko samo beremo; ali pa jih smemo aktivno spreminjati, vendar z zagotovilom, da ima v tistem trenutku do njih dostop le ena referenca. Model tako na zelo eleganten način povezuje podatke z naborom dovoljenih operacij in to počne prek samega sistema tipov @yanovskiGhostCellSeparatingPermissions2021.

Še ena podrobnost, ki je pomembna za razumevanje lastništva, so _življenjske dobe_ #angl[lifetimes], ki so v Rustu sestavni del tipov. Kot sami tipi v Rustu so ponavadi izpeljane, vendar se pogosto pri podpisu funkcije zgodi, da jih moramo eksplicitno pripisati. Na primer, dejanski tip reference na niz ni `&String` ampak `&'a String`, kjer je `'a` življenjska doba. Življenjske dobe pa so del tipa samo takrat, ko ta predstavlja referenco. Intuitivno si jih lahko predstavljamo kot nabor vrstic v programu, kjer ta referenca mora biti veljavna @klabnikRustProgrammingLanguage2023. Koncept življenjskih dob kot nabor vrstic predstavimo s @lst:lifetime-annotate[programom].


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
  caption: [Pripisane življenjske dobe],
) <lst:lifetime-annotate>

Prevajalnik nam pri @lst:lifetime-annotate[programu] vrne napako, saj je spremenljivka `x` veljavna samo za življenjsko dobo `'b`, vendar prevajalnik zahteva, da je veljavna za `'a`, saj se uporabi pri izpisu na zaslon. V gnezdenem bloku efektivno dodelimo tipu `&'a i32` vrednost tipa `&'b i32`, vendar slednja ni podtip prve, saj je nabor vrstic `'b`-ja striktna podmnožica `'a`-jevega nabora. Izračun življenjskih dob je odvisen od implementacije preverjevalnika izposoj, vendar si jih lahko intuitivno predstavljamo kot najmanjšo množico vrstic, kjer bo ta spremenljivka oz. mesto še uporabljeno.

// intuicija glede 2015 verzije borrow checkerja pred NLL: https://youtu.be/uCN_LRcswts?si=S2Ii5VHYF4X7HDo-&t=515
// tukaj razlozim kako gre iz primitivnega do NLL do Poloniusa
// prednosti in slabosti vsakega sistema

#chapter[Formalizacija Poloniusa]

V temu poglavju najprej predstavimo intuitivni opis delovanja Poloniusa in temu sledimo s formalnim opisom pravil Rustovega preverjevalnika izposoj. Nazadnje predstavimo formalizacijo Poloniusa z opisom na osnovi množic in relacij.

== Intuitivna razlaga Poloniusa
<chap:intuitivna-razlaga-poloniusa>

Preden formalno opišemo vse podrobnosti Poloniusa, je pomembno pridobiti nekaj intuicije o njegovem delovanju, saj nam bo olajšala razumevanje pravil, na katerih algoritem temelji. Naslednjo razlago smo prilagodili iz spletne objave, ki je prvotno predstavila Polonius @matsakisAliasbasedFormulationBorrow. Delovanje bomo ponazorili na @lst:intuition[programu], vendar brez natančnih opisov relacij in množic, ki nastopajo pri dejanski analizi.

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
  caption: [Primer programa za Polonius iz @matsakisAliasbasedFormulationBorrow],
) <lst:intuition>

// TODO: celo diplomsko poglej za unikatne / spremenljive reference

@lst:intuition[Program] ima poleg tipov predpisane še _regije_ #angl[regions], kot jih imenuje Polonius, ki si jih lahko predstavljamo kot življenjske dobe. Bolj podrobno pa so to množice _posoj_ #angl[loans], ki jih kasneje natančno definiramo, za zdaj pa si jih lahko predstavljamo kot možne "izvore" #angl[origins] referenc (npr. `&x`, `&mut a.b`, itd.). Reference so označene s številkami `'0`, `'1`, `'2`, itd. Tukaj so prikazane kot del programa, vendar to ni veljavna sintaksa Rusta, je pa uporabna za razlago.

Oglejmo si korake v @lst:intuition[programu], ki na koncu privedejo do napake :

- vrstica 3: Usvarimo vektor deljenih referenc `v`.
- vrstica 4: Ustvarimo unikatno referenco `r`, ki kaže na vektor `v`.
- vrstici 5 in 6: Deljeno referenco na `x` vstavimo v vektor `v` preko `r`.
- vrstici 7 in 8: Poskušamo spremeniti vrednost `x`.

Vendar v vrstici 7 še vedno obstaja aktivna referenca na `x` v vektorju `v`, ki smo jo vstavili na vrstici 6. Vektor `v` še vedno potrebujemo v vrstici 8, torej javimo napako.

#show "'a": `'a`
#show "'b": `'b`

Oglejmo si, kako se intuitivno razumevanje napake prenese na analizo, ki jo opravi Polonius. Za lažje razumevanje si lahko predstavljamo, da algoritem trikrat obhodi kodo. To sicer ni povsem res, saj se ti obhodi v implementaciji prekrivajo, vendar je za koristno.

Prvi obhod izračuna dva glavna elementa: vsebovanost regij med sabo in pripadnost posoj regijam.

Vsebovanost dveh regij se izračuna glede na pravila sklepanja Rustovega sistema tipov in jo zapišemo kot `'a: 'b`. To pomeni, da mora regija 'a vsebovati vse posoje iz regije 'b. Intuitivno, referenca z življenjsko dobo 'b mora živeti vsaj toliko dolgo kot 'a.

Pripadnost posoje regijam se določi ob ustvaritvi posoje. Posoje so interne strukture v Rustovem prevajalniku, ki hranijo podatke o ustvarjeni referenci @weissOxideEssenceRust2019. V temu kontekstu pripadnost regiji pomeni, da se posoja zapiše kot dodaten metapodatek regije. Ko ustvarimo posojo z `&` ali `&mut`, se tej določi pripadnost glede na regijo, ki je del tipa.

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
  caption: [Primer programa za Polonius iz @matsakisAliasbasedFormulationBorrow],
) <lst:intuition2>

#remark(title: "Zakaj na vrstici 6 programa 11 ustvarimo dvosmerno vsebovanost?")[
  Če v vektor pišemo, kot na vrstici 10, morajo elementi "znotraj" reference živeti vsaj tako dolgo kot elementi v prvotnem vektorju. Zato dodamo vsebovanost `'2: '0`. Ker pa lahko iz vektorja tudi beremo, morajo elementi v prvotnem vektorju živeti vsaj tako dolgo kot tisti "znotraj" reference, saj sicer bi lahko brali neveljaven spomin. Tako dobimo še `'0: '2`.
]

Drugi obhod razširi vsebovanosti iz prvega obhoda (saj lahko nanje gledamo kot relacijo matematične vsebovanosti, ki je tranzitivna), ter s tem tudi dodeli posoje večim regijam. Če sledimo tranzitivnemu zaprtju vsebovanosti, lahko opazimo dve verigi:

- Za posojo `L0`: `'3: '1`
- Za posojo `L1`: `'4: '5: '2: '0` (`'0: '2` tukaj ni tako pomembno)

#figure(
  align(center)[#diagram-vsebovanosti-intuition2],
  caption: [Diagram vsebovanosti regij in posoj @lst:intuition2[programa]],
  supplement: "Diagram",
) <fig:diagram-vsebovanosti>

Osredotočimo se na posojo `L1`, ki je na koncu drugega obhoda pripadnica regije `'0`. Poleg razširitve vsebovanosti, drugi obhod tudi določi aktivnost regij in posoj, vendar tukaj tega postopka ne bomo opisali. Povedali bomo samo, da Polonius izračuna, da sta regija `'0` in posledično posoja `L1` aktivni na vrstici 12 v @lst:intuition2[programu]. Pojma aktivnosti regij in posoj sta tukaj analogna pojmu aktivnosti spremenljivk pri prevajalnikih.


#figure(
  align(center)[#aktivnosti-regij-intuition2],
  caption: [Označene aktivnosti regij @lst:intuition2[programa]],
  supplement: "Diagram",
) <fig:aktivnosti-regij>


V tretjem obhodu nato javimo napako, ker operacija mutiranja spremenljivke `x` na vrstici 12 v @lst:intuition2[primeru] razveljavi pogoje posoje `L1`, ki je pa na tisti točki v programu še vedno živa. Razveljavitev pogojev posoje na kratko pomeni, da operacija ni dovoljena glede na tip reference, ki je ustvarila posojo. To so lahko npr. mutiranje mesta na katero kaže deljena referenca ali pa ustvarjanje nove reference na mesto, ko že obstaja unikatna referenca.

// TODO: poleg tega omenimo?

V intuitivni razlagi smo izpustili številne podrobnosti, kot so izračun aktivnosti regij in posoj, podrobnosti razširitve različnih vsebovanosti skozi program ter pogoje za ustvarjanje raznih drugih omejitev #angl[constraints]. Poleg tega omenimo, da analiza deluje na MIR, ki je v prevajalniku predstavljen kot graf, ne pa na samih vrsticah v izvorni kodi programa.

== Formalizacija pravil

Cilj preverjevalnika izposoj je zadostiti pravilom lastništva. Ta pravila so ponavadi podana intuitivno ali pa na primerih, kar je težko rigorozno implementirati v prevajalniku. Zaradi pomanjkanja uradne specifikacije pravil se bomo oprli na delo Amande Stjerne @stjernaModellingRustsReference2020, kjer je s tabelo in opisom predstavila pet pravil.

V @tab:borrow-check[tabeli] imamo podane pozitivne in negativne primere za vsako pravilo, kot jih je zastavila Stjerna. Na podlagi teh primerov in njene razlage bomo formalno zapisali ta pravila z matematično notacijo. Vsa ta pravila delujejo na ravni posamezne funkcije, ne pa celotnega programa.

#import "rule_table.typ": rule_table
#rule_table

// reset codly stuff
#codly(display-name: true, display-icon: true, number-format: numbering.with("1"))

Pravilo Use-Init nam pove, da lahko uporabljamo samo spremenljivke, ki so zagotovo inicializirane na točki v programu, kjer jih uporabljamo. Skupaj s praviloma Move-Deinit, ki pravi da ne smemo uporabljati premaknjenih vrednosti, ter Ref-Live, ki nam onemogoči dostop do sproščenih vrednosti preko referenc, tvori osnovo za sistem lastništva. Ta pravila nam na primer preprečijo vračanje vrednosti, ustvarjeno na skladu, saj je ta na izhodu iz funkcije že sproščena @stjernaModellingRustsReference2020.

Pri formalizaciji pravil bomo izhajali iz _grafa poteka_ #angl[CFG - control flow graph], ki ga prevajalnik konstruira, še preden se začne faza preverjevalnika izposoj. Sestavljen je iz osnovnih blokov, ti pa iz stavkov. Vozlišča v samem grafu si lahko predstavljamo kot posamezne stavke, vendar jih kasneje v nalogi definiramo bolj podrobno.

Da lahko definiramo pravilo Use-Init moramo uvesti še dve množici ter en predikat:

/ $"Poti"(p)$: Množica $"Poti"(p)$ nam poda vse poti skozi graf poteka od začetka funkcije do trenutne točke $p$ v programu. Te poti so statične -- ne spreminjajo se glede na vrednosti spremenljivk med izvajanjem programa. Predstavljamo si jih kot vse možne poti do trenutne točke ob poljubnih vhodnih vrednostih in spremenljivkah.

/ $"UporabljenaMesta"(p)$: To je množica vseh mest, ki jih uporabimo na točki $p$. Uporaba je lahko branje iz ali pisanje v spremenljivko, ki je vezana na to mesto, uporaba polj struktov, branje preko reference itd. Bolj natančno definiramo s pomočjo interne strukture MIRa. Mesto se šteje kot uporabljeno, če nastopa kot operand ali ciljno mesto kjerkoli v stavku. Za bolj podroben pregled, kaj vse uporaba vključuje, si lahko ogledate enumerator `StatementKind` @StatementKindRustc_middleMir.

/ $"Inicializirana"(pi, m, p)$: Predikat $"Inicializirana"(pi, m, p)$ velja natanko tedaj, ko je mesto $m$ skozi pot $pi$ definirano na točki $p$.

Formalno zapisano pravilo se nato glasi:

$ "Use-Init"(p) <==> \ forall pi in "Poti"(p), m in "UporabljenaMesta"(p): "Inicializirana"(pi, m, p) $

Kot vsa druga pravila v tem razdelku ga bomo brali tako: "Če velja predikat $"Use-Init"(p)$ za vsako točko $p$ v funkciji, potem velja pravilo Use-Init in _ne_ javimo napake."

Pred nadaljevanjem definiramo še pojem predpone, ki jo NLL RFC opiše tako @2094nllRustRFC:

/ Predpona #angl[prefix]: Pravimo, da so predpone leve vrednosti #angl[lvalue] vse tiste leve vrednosti, ki jih dobimo, če prvi odstranimo polja ali dereferenciranja. Na primer, predpone leve vrednosti `*a.b` so `*a.b`, `a.b` in `a`.

// https://rustc-dev-guide.rust-lang.org/borrow_check/moves_and_initialization/move_paths.html za definicijo move path
#remark(title: [Opomba o mestih in poteh premika #angl[move path]])[
  Pojem predpone je načeloma definiran kot lastnost poti premika, ki je interni konstrukt prevajalnika. Vendar ga tukaj posplošimo na mesta iz MIRa, ker se bolje sklada z uporabljeno terminologijo. Rustov priročnik za prevajalnik tudi omeni, da sta ta pojma približno enaka. Pojem predpone uporabljamo namesto spremenljivk zaradi tega, ker nam lahko opiše gnezdene podatke kot so polja struktov.
]

Pravilo Move-Deinit nam prepreči, da uporabimo vezavo, iz katere je bila vrednost premaknjena. V kontekstu lastništva to pomeni, da ime ni več lastnik vrednosti. Da pravilo definiramo formalno, moramo vpeljati še eno množico ter en predikat.

/ $"Prekrivanje"(m_1, m_2)$: Ta predikat nam pove ali se mesti prekrivata t.j. ali je katero mesto predpona drugega. Velja natanko tedaj, ko je mesto $m_1$ predpona mesta $m_2$ ali obratno. Torej $"Prekrivanje"("tuple.0", "tuple.0.1")$ bi veljalo, $"Prekrivanje"("tuple.0", "tuple.1")$ pa ne.

/ $"Premaknjen"(pi, m, p)$: Predikat velja natanko tedaj, ko je bilo mesto $m$ premaknjeno pred točko $p$ na poti $pi$. Premik iz perspektive programerja pomeni, da lastnik ni več $m$ vendar nekdo drug. Rustov priročnik za prevajalnik pa nam pove, da v prevajalniku premik iz imena pomeni samo, da ta vrednost ni več v množici inicializiranih vrednosti.


Torej pravilo Move-Deinit zapišemo tako:

$
  "Move-Deinit"(p) <==> \ exists.not pi in "Poti"(p), m_1 in "UporabljenaMesta"(p), m_2: \ "Prekrivanje"(m_1, m_2) and "Premaknjen"(pi, m_2, p)
$

Z besedami povedano, pravilo Move-Deinit na neki točki $p$ velja, ko ne obstaja nobena pot $pi$ do $p$, na kateri smo premaknili mesto $m_2$, ki je predpona uporabljenega mesta $m_1$.

Da bomo lahko razumeli naslednja pravila, moramo definirati pojem posoje, ki je tesno povezana s sorodnim pojmom "izraz izposoje".

/ Izraz izposoje #angl[borrow expression]: #[je jezikovni konstrukt, ki nam omogoča, da ustvarimo referenco (primer izraza izposoje bi bil `&mut x`). Rustov priročnik za prevajalnik @MIRMidlevelIR pojma _borrow expression_ ne definira, ampak ga uporabi tako:

    #quote[An Rvalue is an expression that creates a value: in this case, the rvalue is a
      mutable borrow expression, which looks like `&mut <Place>`]

    Rvalue je definiran z enumeratorjem `Rvalue` @RvalueRustc_middleMira. Izraz izposoje pa natančno predstavlja varianta `Rvalue::ref(Region<'tcx>, BorrowKind, Place<'tcx>)`, ki ustvari referenco tipa `BorrowKind` na mesto `Place`.

  ]

Pojem izraza izposoje pogosto uporabljajo Weiss idr. v svojem članku o formalizaciji podmnožice Rusta. Njihov način uporabe se sklada z našo definicijo, ki se glasi:

/ Posoja #angl[loan]: #[
    Posoja je interni konstrukt prevajalnika, ki hrani podatke o referenci in njenem izvoru @weissOxideEssenceRust2019. V trenutni implementaciji preverjalnika izposoj je izposoja predstavljena kot urejena trojica @2094nllRustRFC `('a, shared|uniq|mut, lvalue)`, kjer je:
    - `'a`: življenjska doba, za katero je vrednost izposojena. To se nanaša na življenjske dobe kot
      del Rustovega sistema tipov, ne pa na alternativno definicijo kasneje v nalogi, ki razume življenjske dobe kot množico izposoj.
    // TODO: poglej kaj je razlika med uniq in mut
    - `shared|uniq|mut`: tip izposoje
    - `lvalue`: leva vrednost, ki je bila izposojena
  ]

Torej v našem zapisu bomo posoje zapisali kot $L = (alpha, tau, O)$, kjer bo $tau in {"uniq", "shrd", "mut"}$ predstavljal tip posoje in $O$ predstavljal levo vrednost (oziroma _izvor_ z Rustovsko terminologijo).

Pravili Shared-Readonly in Unique-Write skrbita za veljavnost referenc in omejujeta njihovo uporabo. To so ista pravila, ki smo jih opisali v @chap:intuitivna-razlaga-poloniusa[razdelku]. Pred opisom pravil moramo definirati še nekaj dodatnih predikatov.

/ $"PosojaAktivna"(L,p)$: Predikat velja natanko tedaj, ko je posoja $L$ aktivna na točki $p$.

Poleg predikata za posojo potrebujemo še predikate, ki opisujejo operacije nad mesti. V prevajalniku je takih tipov operacij več, vendar mi jih bomo zajeli v dve glavni vrsti.

/ $"RazveljaviDeljeno"(m,p)$: Predikat velja natanko tedaj, ko se v točki $p$ nad mestom $m$ izvede taka operacija, ki bi lahko razveljavila deljeno posojo, ki si sposoja iz mesta $m$ (to bi bilo pisanje v mesto $m$ ali pa ustvarjanje spremenljive posoje).

/ $"RazveljaviUnikatno"(m,p)$: Predikat velja, ko operacija razveljavi unikatno posojo (ustvarjanje kakršnekoli nove posoje, pisanje v mesto, branje iz mesta).

Zdaj lahko sestavimo naslednji dve pravili:

$
  "Shared-Readonly"(p) & <==> exists.not L = ("_", tau, O),m: \
  "PosojaAktivna"(L,p) & and tau = "shrd" and \
   "Prekrivanje"(m, O) & and "RazveljaviDeljeno"(m,p)
$

$
     "Unique-Write"(p) & <==> exists.not L = ("_", tau, O),m: \
  "PosojaAktivna"(L,p) & and tau in {"uniq", "mut"} and \
   "Prekrivanje"(m, O) & and "RazveljaviUnikatno"(m,p)
$

Pravilo Shared-Readonly na točki $p$ torej velja, ko ne obstaja taka posoja $L = ("_", tau, O)$, ki je aktivna in katere izvor $O$ se  prekriva z mestom $m$ nad katerim smo ravno izvedli operacijo, ki bi razveljavila deljeno posojo. Podobno razložimo pravilo Unique-Write.

// TODO: dropped?

Za zadnje pravilo potrebujemo samo še en predikat.

/ $"MestoAktivno"(m,p)$: Predikat velja natanko tedaj, ko je mesto $m$ še aktivno na točki $p$. Aktivnost mesta pomeni, da še na tej točki v programu ni bilo sproščeno #angl[dropped].

Potem pravilo Ref-Live lahko zapišemo tako:

$
         "Ref-Live"(p) & <==> exists.not L = ("_", "_", O), m: \
  "PosojaAktivna"(L,p) & and "Prekrivanje"(m, O) and not "MestoAktivno"(m,p)
$

To preprosto pomeni, da morajo biti vse predpone izvora $O$ aktivne posoje $L$ tudi hkrati same aktivne.

== Primer in formalizacija

V naslednjih poglavjih se bomo lotili glavnega dela naloge, ki je matematična formalizacija delovanja Poloniusa. Da si bomo lažje predstavljali relacije in množice bomo celotno delovanje ponazorili na primeru iz @chap:intuitivna-razlaga-poloniusa[razdelka].

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
  caption: [Primer programa za Polonius iz @matsakisAliasbasedFormulationBorrow],
  placement: none,
) <lst:main-example>

== Osnovne množice in elementi
<chap-osnovne-mnozice>

Da sploh lahko matematično govorimo o delovanju Poloniusa, moramo definirati osnovne množice in elemente s katerimi bomo delali.

=== Množica posoj #posoje
<chap-mnozica-posoj>

Množico vseh posoj (_angl. loans_) označimo s #posoje. _Pogoji posoje_ so lastnosti, ki morajo držati v določeni točki programa, da smatramo posojo kot veljavno oz. aktivno. Pravimo, da _razveljavimo pogoje posoje_, če velja ena izmed naslednjih točk:
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

// TODO: prevedena verzija?

Prevedena verzija(?):

#quote[
  Za stavek na točki P v grafu definiramo "funkcijo prenosa" -- torej, katere posoje prinesemo v ali iz obsega. Funkcija je definirana tako:
  - ... ostala pravila
  - Če je stavek dodelitev `lv = <rvalue>`, potem je vsaka posoja poti P katere `lv` je predpona razveljavljena.
]

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

V @listing:loans[programu] vidimo kako se posoje ustvarjajo tekom programa. Končamo z množico $#posoje = {L_0, L_1}$.

=== Množica regij #regije

V trenutni implementaciji preverjevalnika izposoj NLL se posoje spremljajo s pomočjo življenjskih dob. V tej formulaciji pa je avtor življenjske dobe poimenoval regije #angl[regions]. Množica regij je označena z $regije subset 2^posoje$. Na primeru so že označene z `'1`, `'2`, `'3`, itd. Pripadnost posoj regijam bomo kasneje določili z relacijo.

=== Graf poteka izposoje

Graf poteka #angl[CFG - control flow graph] je izračunan v prejšnjih fazah analize kode. Zgrajen je iz osnovnih blokov, ti pa so zgrajeni iz stavkov. Spremlja ga tudi nekaj dodatnih informacij, ki nam bodo kasneje prišle prav. Te so izračunane tekom analize poteka podatkov #angl[dataflow analysis] @MIRDataflowRust. Graf poteka označimo s $C = (C_V, C_E)$, kjer je $C_V$ množica vozlišč in $C_E$ množica povezav.

Privzeto se ustvarijo naslednje povezave:

- Za vsak stavek se ustvari povezava med njegovim začetkom in sredino:
  $forall "stmt" in stavki: (S("stmt"), M("stmt")) in C_E$
- Če $M("stmt")$ predstavlja _terminator_ (stavek na koncu bloka) potem dodamo povezavo iz njega v $S("stmt"')$
  za vsak stavek $"stmt"'$, ki mu sledi.

_Opomba:_ To je samo matematična formulacija predstavitve grafa poteka, v prevajalniku
je njegova predstavitev precej bolj kompleksna.

==== Množica stavkov in točk

Množico vseh stavkov v MIR označimo s #stavki. Točke v grafu poteka označimo s #točke. Lahko so dveh tipov:
- _na začetku stavka:_ označuje trenutek preden se stavek izvede. Označimo s $S("stmt")$.
- _med stavkom:_ označuje trenutek tik preden ima stavek učinek (v članku napisano "just before the statement takes effect").
  Označimo z $M("stmt")$.

Avtor spletne objave ne opredeli pojmov _na začetku stavka_ in _med stavkom_ natančno,
vendar lahko najdemo razlago v `legacy` implementaciji Polonius preverjevalnika izposoj.
Komentar nad strukturo, ki opisuje množico stavkov, pravi naslednje @RustCompilerRustc_borrowcka:

#quote[Ta struktura prevede MIR lokacijo, ki identificira stavek znotraj osnovnega bloka, v "obogateno lokacijo",
  kar nam omogoči večjo granularnost. Bolj podrobno, ločimo med začetkom in sredino stavka. Sredina stavka
  je točka _tik preden_ ima stavek učinek. Torej za prirejanje `A = B` bi bila sredina stavka
  točka trenutek ravno preden bi se `B` zapisal v `A` ...]

==== Primer grafa

Da si lahko boljše predstavljamo graf poteka, ga bomo konstruirali za @ex-cfg-example-code[program] in njegov prevod v MIR (@ex-cfg-example-mir[program]). MIR bomo tukaj ponazorili s psevdokodo, vendar je sam MIR skupek struktur v Rustovem prevajalniku.

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
) <ex-cfg-example-mir>

Ker je ta sintaksa povsem izmišljena za pedagoške namene, je ne bomo pojasnili potanko, vendar omenimo par stvari:
- Spremenljivke izgubijo imena in se oštevilčijo (`_1`, `_2`, `_3`)
- Osnovne bloke se označuje z `bb<stevilo>`.
- `switchInt` je tip terminatorja definiran v Rustovem prevajalniku @TerminatorKindRustc_middleMir.

S tem razumevanjem lahko zdaj program ponazorimo v grafu.

#figure(cfg-example, caption: [Graf poteka za @ex-cfg-example-code[program]], placement: none)


== Začetne relacije

V @chap-osnovne-mnozice[poglavju] smo definirali osnovne množice nad katerimi bomo zdaj definirani različne relacije. Polonius je razdeljen na dva tipa relacij.

_Začetna_ #angl[input] relacija, je tista, ki jo dobimo že iz prejšnjih faz analize MIR-a. Predstavljajo izhodiščno točko za celo analizo in prevzamemo, da so že izračunane. Iz njih potem dobimo _izpeljane_ relacije, ki so jedro Poloniusove analize ter njegova ključna inovacija.

=== Začetna relacija vsebovanosti

Začetno relacijo vsebovanosti #angl[base subset] bomo označili z $jevsebovanazacetno subset regije times regije times točke$. Torej to je relacija, ki povezuje dve regiji ob neki točki v programu. Za intuicijo zakaj je ta relacija pomembna si lahko ogledate @chap:intuitivna-razlaga-poloniusa[poglavje].

Bolj natančno, če velja $(R_1, R_2, P) in jevsebovanazacetno$ pomeni, da je $R_1$ podmnožica regije $R_2$ na točki $P$ v programu. Ker so regije potenčne množice posoj, si lahko to razlagamo, kot da regija $R_1$ vsebuje vse posoje, ki jih vsebuje $R_2$ in zato $R_2$ inducira več omejitev, ki jih bomo spoznali kasneje v formulaciji. To dejstvo mora veljati na sredini stavka ($M("stmt")$), ki inducira zahtevo.


_Opomba:_ Oznaka `<:` nam predstavlja vsebovanost med tipi (_subtyping relation_).

#remark(title: "Povezava z NLL")[
  V NLL-u so regije predstavljene kot množice točk oz. stavkov, kjer je ta vrednost veljavna. Torej `'a: 'b` bi pomenilo, da mora `'a` biti veljavna vsaj toliko dolgo kot `'b`. V angleščini bi temu rekli _'a outlives 'b_. Drugače povedano, množica točk 'b bi bila podmnožica 'a. Kar je pa ravno obratno, kot naš zapis v Poloniusu. Ključna razlika je, da so regije v Poloniusu množice posoj, ne pa točk. Intuitivno gledano lahko rečemo, da vsaka nova posoja doprinese dodatne omejitve k uporabi in ustvarjanju referenc. Zato je smiselno, da je v Poloniusu regija `'a` podmnožica regije `'b`, saj mora vsebovati _vsaj_ vse omejitve, ki se jih mora držati `'b`.
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

To je ključna relacija, ki poveže regije, ki so del Rustovih tipov in posoje, ki so metapodatki v Rustovem prevajalniku. S pomočjo te relacije bomo lahko povezali specifične reference z regijami in sledili kje so aktivne tekom programa ter kdaj javimo napako.

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

Začetno relacijo prekinitve posoje #angl[loan killed at] označimo s $posojaprekinjenana subset.eq posoje times točke$. $(L,P) in posojaprekinjenana$ pomeni, da je posoja $L$ prekinjena #angl[killed] na točki $P$. Pojem prekinitve oziroma razveljavitve pogojev smo definirali že zgoraj v @chap-mnozica-posoj[poglavju]. To se običajno zgodi na sredini prireditvenega stavka, ki prepiše pot prej povezano s posojo $L$.

V našem primeru nimamo nobenega primera prekinitve posoje, je pa relacija ključna v @listing:loanKilled[programu].

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
  placement: none,
) <listing:loanKilled>

V tem primeru je `x` referenca na `p`, ki je prekopirana v `y`. Dostop do `*x` bi bil tukaj neveljaven,
ker si ga je `y` izposodil. Ko pa `x` priredimo novo vrednost, pa razveljavimo posojo `L0` in s tem si že spet
omogočimo dostop do `x`. Brez prekinitve bi Polonius mislil, da je mesto `*x` še vedno izposojeno, čeprav
zdaj `y` kaže na `p` in `x` na `q`.

=== Relacija razveljavitve posoje

Začetno relacijo razveljavitve posoje #angl[invalidates loan] označimo s $posojarazveljavljenana subset točke times posoje$. To pomeni, da dejanje na točki $P$ (recimo mutacija izposojenega mesta) razveljavi pogoje posoje $L$, kar je že opisano v poglavju o definiciji množice #posoje.

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
    x += 1; // tukaj razveljavimo L1 z mutacijo deljenega referenta
    take::<Vec<&'6 i32>>(v);
  }
  ```,
  caption: [Primer razveljavitve posoje],
) <listing:loanInvalidated>

== Izpeljane relacije

V tem poglavju bomo opisali relacije, ki jih izpeljemo iz začetnih. Te relacije tvorijo najpomembnejši del analize Poloniusa.

V primerih ne bomo označevali točk v grafu poteka pri relacijah, ker bo koda anotirana na tistem mestu, kjer
se posamezna relacija pojavi. V ozadju se to še vedno izvaja na nivoju MIR, vendar za naše poenostavljene
primere to ni ključna informacija. (torej pisali bomo $(R_1, R_2) in jevsebovanazacetno$ namesto $(R_1, R_2, P) in jevsebovanazacetno$).

=== Relacija vsebovanosti

Razširimo začetno relacijo vsebovanosti z (raširjeno) relacijo vsebovanosti #angl[subset], ki jo označimo z
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

Na primeru predpišemo te relacije v @listing:subsetRelations[programu].

#figure(
  ```rust
  fn main() {
    let mut x: i32 = 22;
    let mut v: Vec<&'0 i32> = vec![];

    let r: &'1 mut Vec<&'2 i32> = &'3 mut v;
    // (r3, r1) in je_vsebovana, (r0, r2) inn je_vsebovana, (r2, r0) inn je_vsebovana

    let p: &'5 i32 = &'4 x;
    // (r3, r1) inn je_vsebovana, (r0, r2) inn je_vsebovana, (r2, r0) inn je_vsebovana
    // (r4, r5) inn je_vsebovana

    r.push(p);
    // (r3, r1) inn je_vsebovana, (r0, r2) inn je_vsebovana, (r2, r0) inn je_vsebovana
    // (r4, r5) inn je_vsebovana
    // (r5, r2) inn je_vsebovana

    x += 1;

    take::<Vec<&'6 i32>>(v);
    // (r3, r1) inn je_vsebovana, (r0, r2) inn je_vsebovana, (r2, r0) inn je_vsebovana
    // (r4, r5) inn je_vsebovana
    // (r5, r2) inn je_vsebovana
    // (r0, r6) inn je_vsebovana
  }

  fn take<T>(p: T) { .. }
  ```,
  caption: [Relacija vsebovanosti],
) <listing:subsetRelations>

=== Relacija zahteve
<chap-relacija-zahteve>

Relacija zahteve nam pove, da regija $R$ zahteva, da pogoji posoje $L$ veljajo na točki $P$. Označimo jo s
$zahteva subset.eq regije times posoje times točke$ in je definirana z zaprtjem naslednjih pravil:

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

~ Opazimo, da pri relaciji vsebovanosti #jevsebovanazacetno in pri relaciji zahteve #zahteva mora biti regija pri pravilu za propagacijo aktivna na naslednji točki $Q$. S @listing:reqRelation[programom] ponazorimo zakaj je to ključna omejitev.

#figure(
  ```rust
  let x = 22;
  let y = 44;

  let mut p: &'0 i32 = &'1 x; // posoja L0
  // (r1,r0) inn je_vsebovana
  // (r1, L0) inn zahteva

  p = &'3 y; // posoja L1
  // (r3, r0) inn je_vsebovana
  // (r3, L1) inn zahteva
  // r1 ni več aktivna, ker smo jo prepisali z r3

  x += 1;
  // razveljavi se posoja L0: (L0) inn posoja_razveljavljena_na
  // tukaj bi brez pravila o aktivnosti regij še vedno zahtevali
  // (L0, r0) inn zahteva zaradi pravila o propagaciji

  print( *p );
  // ta izraz je tukaj, da je referenca `p` še vedno živa na
  // izrazu x += 1, sicer bi Rustov prevajalnik takoj že zavrgel (drop)
  // spremenljivko `p` po vrstici 8.
  ```,
  caption: [Primer relacije zahteve],
) <listing:reqRelation>

=== Relacija aktivnosti posoje

Relacija aktivnosti posoje #angl[loan live at] pomeni, da je posoja $L$ aktivna na točki $P$. Označimo jo s $posojaaktivnana subset.eq posoje times točke$ in jo definiramo takrat, ko

$ exists R in regije: (R,P) in regijaaktivnana and (R,L,P) in zahteva $

To na kratko pomeni, da je posoja aktivna, če jo na isti točki zahteva neka aktivna regija.

=== Vizualizacija na primeru

Poskusimo zdaj vizualizirati te glavne relacije na našem glavnem primeru, ki ga tukaj prikažemo še enkrat.

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
  caption: [Primer programa za Polonius iz @matsakisAliasbasedFormulationBorrow],
  placement: none,
) <lst:main-example2>

Prvo bomo na vsaki točki (oz. vrstici v našem poenostavljenem primeru) določili množico vseh aktivnih regij. To nam poda relacija #regijaaktivnana in je prikazana na @ex-graph-active[diagramu].

#figure(
  final-example-graph-active,
  caption: [Relacija #regijaaktivnana],
  supplement: "Diagram",
) <ex-graph-active>

Potem bomo vizualno ponazorili razširjeno relacijo #jevsebovana, ki že upošteva pravila tranzitivnosti ter propagacije čez točke v grafu. To nam pokaže @ex-graph-subset[diagram].

#figure(
  scale(90%, final-example-graph-subset),
  caption: [Relacija #jevsebovana],
  supplement: "Diagram",
) <ex-graph-subset>

Iz diagrama za #jevsebovana lahko potem izhajamo, da konstruiramo @ex-graph-zahteva[diagram] za #zahteva, tako da sledimo pravilom opisanih v @chap-relacija-zahteve[poglavju].


#figure(
  scale(85%, final-example-graph-zahteva),
  caption: [Relacija #zahteva],
  supplement: "Diagram",
) <ex-graph-zahteva>

== Javljanje napake

S pomočjo prejšnjih relacij lahko na koncu definiramo kje v programu javimo napako (v obsegu preverjalnika posoj). Že spet si pomagamo z relacijo, ki jo tokrat poimenujemo _relacija napake_ #angl[error] in jo označimo z #napaka. Ta relacija nam pove, da javimo napako na točki $P$ v programu.

Definiramo jo, ko velja:

$ exists L in posoje: (P, L) in posojarazveljavljenana and (L,P) in posojaaktivnana $

Torej napaka se javi natanko tedaj, ko neko dejanje na točki $P$ razveljavi pogoje posoje $L$, ki je hkrati tudi
aktivna na točki $P$.

Poglejmo še kako se dokončno napaka javi na našem primeru. Če je kakšen korak nejasen, si lahko pomagate z diagram v prejšnjem poglavju.

#figure(
  ```rust
  fn main() {
    let mut x: i32 = 22;
    let mut v: Vec<&'0 i32> = vec![];

    let r: &'1 mut Vec<&'2 i32> = &'3 mut v;
    // relacije, ki so ustvarjene tukaj niso relevantne za napako

    let p: &'5 i32 = &'4 x;
    // (r4, L1) inn `zahteva`
    // (r4, r5) inn `je_vsebovana` implies (r5, L1) inn `zahteva`

    r.push(p);
    // (r5, r2) inn `je_vsebovana` implies (r2, L1) inn `zahteva`

    x += 1;
    // Tukaj se razveljavi posoja L1: (L1) inn `posoja_razveljavljena_na`.
    // Da se nam javi napaka mora biti ta posoja aktivna (L1) inn posoja_aktivna_na.
    // Torej jo mora zahtevati neka aktivna regija, na trenutni točki pa je aktivna regija r2, ker jo lahko uporabimo v funkciji `take`, ki sprejme našvektor `v`. Elementi vektorja pa imajo regijo r2, ki pa je del posoje L1.
    // Torej, ker smo razveljavili posojo L1, medtem ko je bila aktivna regija, ki jo ta posoja zahteva, javimo napako.

    take::<Vec<&'6 i32>>(v);
  }

  fn take<T>(p: T) { .. }
  ```,
  caption: [Napaka v programu],
  placement: none,
) <listing:error>

== Vizualna reprezentacija delovanja Poloniusa

Da si lažje predstavljamo kako se različne relacije povezujejo bomo tukaj prikazali diagram vseh relacij in povezav med njimi. Graf je zelo podoben tistemu iz @stjernaModellingRustsReference2020, vendar poenostavljen saj se naša naloga ukvarja samo z bistvom Poloniusa in ne njegovo implementacijo.

#figure(
  scale(80%, polonius-diagram),
  supplement: "Diagram",
  caption: "Relacije Poloniusa. Z rdečo so označene začetne relacije in z vijolično izpeljane.",
)

#chapter("Zaključek")

Ena izmed Rustovih glavnih prednosti je njegovo "brezplačno" #angl[zero-cost] upravljanje s pomnilnikom med izvajanjem programa. To nas sicer stane časa pri prevajanju zaradi preverjevalnika izposoj, ki določa kaj je smatrano kot pomnilniško varno, kaj pa se zavrne, ker bi lahko povzročalo nedoločeno obnašanje #angl[undefined behaviour].

Trenutna implementacija preverjevalnika izposoj NLL je preveč konzervativna v nekaterih primerih in posledično zavrne varne programe, ki bi jih lahko sprejeli z bolj natančno analizo. Zato je #cite(<matsakisAliasbasedFormulationBorrow>, form: "author") v svoji spletni objavi zastavil Polonius, ki bolje sledi toku podatkov v programu in lahko sprejme te bolj kompleksne primere.

V nasprotju z NLL-om, ki je bi dokaj formalno definiran znotraj RFC dokumenta @2094nllRustRFC, je bila Poloniusova definicija že od začetka zelo neformalna in povezana z implementacijo. Napisan je bil v Datalogu, ki je podmnožica Prologa, nato pa v Rustu. Ekipa, ki ga je implementirala, se nikoli ni ukvarjala s točnim opisom njegovega delovanja in do pred kratkim je bil eden izmed edinih virov magistrska naloga Amande Stjerne @stjernaModellingRustsReference2020, ki je ena izmed razvijalcev Rusta. V zadnjem letu se je šele pojavil projekt imenovan `a-mir-formality`, ki hoče sestaviti uradno specifikacijo za Rustov sistem tipov in preverjevalnik izposoj (vključno s Poloniusom) @BorrowCheckingAmirformalityb.

Cilj te naloge je bil formulirati alternativo Datalog implementaciji Poloniusa na formalen matematičen način, da bi omogočili lažje razumevanje tega kompleksnega sistema. To smo storili s pomočjo množic in relacij definiranih nad njimi. Osnovne množice, kot so #točke, #regije in #posoje, so predstavljale Rustove strukture v prevajalniku, s pomočjo katerih se definira začetne relacije, ki so dejstva, iz katerih izhaja celotna analiza.

Te smo nadgradili z izpeljanimi relacijami, ki tvorijo jedro Poloniusovega delovanja. Začetno dejstvo #jevsebovanazacetno smo s pravili propagacije skozi graf in tranzitivnosti razširili v #jevsebovana in s pomočjo relacij, ki določajo aktivnost (#regijaaktivnana, #posojaaktivnana) definirali t.i. "glavno" relacijo #zahteva, ki nam je povedala katera regija kdaj zahteva, da so pogoji posoje veljavni. Vse relacije smo potem združili v končno relacjo #napaka, ki nam pove kje se nahaja napaka v programu (oz. kjer je ni).

Lahko bi rekli, da je ta formalizacija odveč, saj že Datalog pravila formalno definirajo delovanje Poloniusa. Vendar, če se spustimo v izvorno kodo implementacije, lahko vidimo, da je že začetnih relacij 18 @RustlangPolonius2026. Naša formalizacija poda poenostavljen način razumevanja delovanja algoritma iz matematičnega vidika. Sicer ni dosti močna, da bi lahko z njo dokazevali izreke ali leme, vendar nam poda trdno osnovo iz katere lahko gradimo razumevanje Rustovega preverjevalnika izposoj.


#pagebreak()
#bibliography("thesis.bib", style: "ieee.csl")

