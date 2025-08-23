# Loan killed at

Zanima me kje je dejansko posoja killed. Gledal sem po trenutni implementaciji.

loan liveness se izracuna tukaj: https://github.com/rust-lang/rust/blob/c5a6a7bdd89f099544fa0d3fad4d833d238377ad/compiler/rustc_borrowck/src/polonius/loan_liveness.rs

```rs
if liveness.is_live_at(node.region, liveness.location_from_point(node.point)) {
        live_loans.insert(node.point, loan_idx);
}
```

to je pa odvisno od tega liveness objekta, ki nam predstavlja zive regije (regije so konceptualno mnozice loans zato to stima)

liveness regij pa se computa tukaj

https://github.com/rust-lang/rust/blob/c5a6a7bdd89f099544fa0d3fad4d833d238377ad/compiler/rustc_borrowck/src/type_check/liveness/mod.rs

od tukaj naprej je TODO kako tocno se to zgodi
