# Napake v `thesis.typ`

## Najdbe

### Jasne jezikovne / tipkarske napake

- **L234**: `#angl[nighlty]` → verjetno `#angl[nightly]`.
- **L474**: `Te dve pravili` → verjetno `Ti dve pravili`.
- **L1013**: `preverjalnika posoj` → verjetno `preverjevalnika izposoj`.
- **L1074**: `v njem` je verjetno ustrezneje kot `v njemu`.
- **L1074**: `Datalog implentacijo` → verjetno `Datalog implementacijo`.

### Verjetne slovnične napake

- **L224**: `s sistemom ... osnovanem na Milnerjevem sistemu tipov` → verjetno `s sistemom ... osnovanim na Milnerjevem sistemu tipov`.

### Napake v formulah / matematičnem zapisu

- **L552-L553**: v formuli za `Shared-Readonly` sta podvojena operatorja `& and`.
- **L560-L561**: v formuli za `Unique-Write` sta podvojena operatorja `& and`.
- **L573-L574**: formula za `Ref-Live` je pokvarjena:
  - `L & =` je sumljivo,
  - spet se pojavi `& and`.
- **L1015**: `\(P, L)` vsebuje odvečen začetni poševni znak.

### Ponavljajoča se tipkarska napaka v komentarjih znotraj izpisov kode

Na več mestih se pojavlja `inn` namesto `in`.

Pojavitve:
- **L781, L785, L789, L795**
- **L815, L817**
- **L874, L876**
- **L913, L916-L922, L927-L930**
- **L960-L961, L964-L965, L969-L970**
- **L1037-L1045**

## Opomba

Datoteke `thesis.typ` nisem spreminjal; napake so samo evidentirane tukaj.
