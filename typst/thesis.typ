#import "template.typ": thesis

#let angl(cont) = [(angl. #emph(cont))]

#show: thesis.with(
  title: "Formalizacija originalne formulacije Poloniusa",
  author: "Filip Trplan",
  study_program: [INTERDISCIPLINARNI UNIVERZITETNI \ ŠTUDIJSKI PROGRAM PRVE STOPNJE \ RAČUNALNIŠTVO IN MATEMATIKA],
  mentor: "doc. dr. Boštjan Slivnik",
  year: "2025",
  description: [
    Besedilo teme diplomskega dela študent prepiše iz študijskega informacijskega
    sistema, kamor ga je vnesel mentor. V nekaj stavkih bo opisal, kaj pričakuje
    od kandidatovega diplomskega dela. Kaj so cilji, kakšne metode naj uporabi,
    morda bo zapisal tudi ključno literaturo
  ],
)

= Uvod
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

#bibliography("thesis.bib")

