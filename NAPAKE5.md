# Napake v thesis.typ (NAPAKE5)

## Napake v pravopisu / črkovanje

### 1. Vrstica 211 — napačna sklanjatev
**Najdeno:** `s semantičnim modelom imenovanem RustBelt`
**Pravilno:** `s semantičnim modelom imenovanim RustBelt`
**Razlaga:** Po predlogu `s` je potreben instrumental. "Imenovan" mora biti sklonjen v instrumental (`imenovanim`), ne lokativ (`imenovanem`).

---

### 2. Vrstica 617 — napačno črkovanje (manjkajoča črka)
**Najdeno:** `_nekaj za nas nerelevatnih pravil_`
**Pravilno:** `_nekaj za nas nerelevantnih pravil_`
**Razlaga:** Manjka `n` v besedi `nerelevantnih`.

---

## Napake v sklanjatvi / ločilih

### 3. Vrstica 474 — manjkajoča vejica (oziralni odvisnik)
**Najdeno:** `premikati iz mesta na katerega kaže deljena referenca`
**Pravilno:** `premikati iz mesta, na katerega kaže deljena referenca`
**Razlaga:** Pred oziralnim odvisnikom (`na katerega`) manjka vejica.

---

## Morebitne napake (potrebno preveriti)

### 4. Vrstica 285 — odvečna negacija?
**Najdeno:** `Navadno jih delimo na deljene ter nespremenljive reference.`
**Vprašanje:** Rustova standardna terminologija loči reference na deljene (`&T`) in **spremenljive** (`&mut T`). Beseda `nespremenljive` bi podvojila pomen besede `deljene` (deljene reference so že po definiciji nespremenljive). Verjetno pravilno: `deljene ter spremenljive reference`.
