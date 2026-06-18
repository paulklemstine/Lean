# Summary of changes for run f90b4b0b-aa26-4af1-afa7-3ccd24361ab4
Created `Catalog/Algebra/KorseltUnitsBridge.lean` with exactly four declarations (three lemmas, then one theorem) after a single `import Mathlib`, with no comments, defs, examples, or `sorry`.

Contents:
1. `unitsMap_surjective_of_squarefree` — surjectivity of `ZMod.unitsMap hd` from `Squarefree n` (used to supply `NeZero n`) via Mathlib's `ZMod.unitsMap_surjective`. The unused `hp` hypothesis is omitted.
2. `exists_orderOf_eq_sub_one_of_prime` — existence of `g : (ZMod p)ˣ` with `orderOf g = p - 1`, using cyclicity (`IsCyclic.exists_ofOrder_eq_natCard`), `ZMod.card_units_eq_totient`, and `Nat.totient_prime`.
3. `orderOf_dvd_of_surjective_of_forall_pow_eq_one` — generic transport: a surjective group hom carries `∀ x, x^m = 1` to `orderOf y ∣ m` for all `y`, by lifting a preimage.
4. `prime_sub_one_dvd_of_forall_units_pow_eq_one` — the target theorem, combining all three ingredients to conclude `(p - 1) ∣ (n - 1)`.

Verified: the file compiles under the project toolchain, contains no `sorry`, and the main theorem depends only on `[propext, Classical.choice, Quot.sound]`. The proof genuinely uses surjectivity of `unitsMap`, the order-`p-1` generator of `(ZMod p)ˣ`, and order-divisibility transport through the surjective homomorphism.