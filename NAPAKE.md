# Napake v `thesis.typ`

## Jasne jezikovne / tipkarske napake

- **L127**: `v Rusti` → verjetno `v Rustu`.
- **L194**: `inžinirjev` → verjetno `inženirjev`.
- **L234**: `#angl[niglty]` → verjetno `#angl[nightly]`.
- **L437**: `iz prvega obhod` → verjetno `iz prvega obhoda`.
- **L529**: `preverjalnika izposoj` → verjetno `preverjevalnika izposoj`.
- **L570**: `Potem more za Ref-Live` → verjetno `Potem mora za Ref-Live`.
- **L1013**: `preverjalnika posoj` → verjetno `preverjevalnika izposoj`.
- **L1013**: viden je še očiten delovni opomnik v sprotni opombi: `vase vpr: zakaj italics ...`; to deluje kot nezaželen placeholder v končni verziji.
- **L1074**: `v njemu` → verjetno `v njem`.
- **L1074**: `Datalog implentacija` → verjetno `Datalog implementacija` oziroma glede na stavek `z Datalog implementacijo`.

## Napake v formulah / zapisu

- **L552-L553**: podvojeni operatorji `& and` v formuli za `Shared-Readonly`.
- **L560-L561**: podvojeni operatorji `& and` v formuli za `Unique-Write`.
- **L573-L574**: formula za `Ref-Live` je verjetno pokvarjena:
  - `L & =` je sumljivo,
  - ponovno se pojavi `& and`.
- **L1015**: v formuli je `\(P, L)`; začetni `\` deluje kot odvečen znak.

## Ponavljajoče se tipkarske napake v komentarjih znotraj izpisov kode

Na več mestih se pojavlja `inn` namesto `in`. To je vidno v komentarjih znotraj prikazanih programov / relacij, zato se bo najbrž poznalo tudi v PDF-ju.

Pojavitve:
- **L781, L785, L789, L795**
- **L815, L817**
- **L874, L876**
- **L913, L916-L922, L927-L930**
- **L960-L961, L964-L965, L969-L970**
- **L1037-L1045**

## Opomba

Datoteke `thesis.typ` nisem spreminjal; napake so samo evidentirane tukaj.
