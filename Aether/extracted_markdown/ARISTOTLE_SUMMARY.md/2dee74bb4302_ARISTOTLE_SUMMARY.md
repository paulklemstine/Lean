# Summary of changes for run bfcf0564-7ced-4c79-9421-a9c701a20d45
Created `Catalog/Algebra/KorseltUnitsBridge.lean`, a self-contained, fully compiling file (no sorries; depends only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`).

It proves the requested main theorem with exactly the suggested statement:

`prime_sub_one_dvd_of_forall_units_pow_eq_one {n p : ℕ} (hp : p.Prime) (hpn : p ∣ n) (hn : n ≠ 0) (hpow : ∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1) : p - 1 ∣ n - 1`.

Proof structure, following the requested strategy:
1. Reduce units modulo `p` via mathlib's `ZMod.unitsMap`, using its surjectivity `ZMod.unitsMap_surjective` (which needs `NeZero n`, obtained from `hn`).
2. Transport the universal exponent hypothesis along the surjection to get `∀ v : (ZMod p)ˣ, v ^ (n - 1) = 1`.
3. Use that `(ZMod p)ˣ` is cyclic (`ZMod.isCyclic_units_prime`), so its exponent equals its cardinality `p - 1` (`IsCyclic.exponent_eq_card`, `ZMod.card_units_eq_totient`, `Nat.totient_prime`), and the exponent divides any universal power exponent (`Monoid.exponent_dvd_of_forall_pow_eq_one`), yielding `p - 1 ∣ n - 1`.

A single small generic helper `orderOf_dvd_of_forall_pow_eq_one` is included. No squarefreeness or other extra hypotheses are assumed, and a module docstring explains that this is the arithmetic divisibility bridge toward Korselt's criterion, not the full criterion. Verified by building the module `Algebra.KorseltUnitsBridge` and checking the axioms.

Note: the broader project contains a pre-existing unrelated build breakage (a missing `Algebra/Jacobian/Defs.lean` referenced elsewhere) that is independent of this file; the new module itself builds successfully on its own.