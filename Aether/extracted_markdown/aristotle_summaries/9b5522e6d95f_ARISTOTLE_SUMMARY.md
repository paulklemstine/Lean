# Summary of changes for run c242cb72-2703-45f4-a6bd-bc1a28ef8345
Created `Bridges/KorseltUnitsBridge.lean` (under the Catalog source tree), a single clean, self-contained file proving the arithmetic bridge toward Korselt's criterion for Carmichael numbers.

Contents (exactly 4 theorems, no other declarations, no `sorry`):
1. `orderOf_dvd_of_forall_pow_eq_one` — if every element of a monoid satisfies `g ^ m = 1`, the order of any element divides `m` (wrapper around `orderOf_dvd_of_pow_eq_one`).
2. `orderOf_map_dvd_of_surjective` — the order of `φ g` divides the order of `g` for a group homomorphism `φ`.
3. `unitsMap_surjective_of_dvd` — surjectivity of the unit reduction map `(ZMod n)ˣ →* (ZMod p)ˣ` for `p ∣ n` (wrapper around `ZMod.unitsMap_surjective`).
4. `prime_sub_one_dvd_of_forall_units_pow_eq_one` — the main theorem: for `n` with `[NeZero n]`, prime `p ∣ n`, `Squarefree n`, and `∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1`, we get `(p - 1) ∣ (n - 1)`.

The main proof follows the requested strategy: transport the hypothesis along the surjective unit map to `(ZMod p)ˣ`, use that `(ZMod p)ˣ` is cyclic of order `p - 1` (via `IsCyclic.exists_ofOrder_eq_natCard` and `ZMod.card_units`) to get an element `g` of order `p - 1`, then derive `orderOf g ∣ (n - 1)` (the `have hdvd` step) before rewriting to conclude.

Verification: the file compiles cleanly (`lake build Bridges.KorseltUnitsBridge` succeeded), contains no `sorry`, and the main theorem depends only on the allowed axioms `propext`, `Classical.choice`, and `Quot.sound`.

Note: the `Squarefree` hypothesis `hsq` is part of the requested interface but is not actually needed for this arithmetic step; it is kept (producing only an unused-variable linter warning) to match the requested statement, with this noted in the docstring.