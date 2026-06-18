# Summary of changes for run 530308aa-de6a-4c50-8a74-304ff01ef999
Created `Catalog/Algebra/KorseltUnitsBridge.lean`, a self-contained, sorry-free file proving the requested arithmetic bridge toward Korselt's criterion.

Main theorem (using the suggested shape exactly):
`prime_sub_one_dvd_of_forall_units_pow_eq_one {n p : ℕ} (hp : p.Prime) (hpn : p ∣ n) (hpow : ∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1) : p - 1 ∣ n - 1`.

Proof strategy (as requested, reusing existing mathlib APIs):
- Handle the `n = 0` case trivially (`n - 1 = 0`).
- Take a generator `g` of the cyclic group `(ZMod p)ˣ` via `IsCyclic.exists_ofOrder_eq_natCard`, with `orderOf g = p - 1` using `ZMod.card_units`.
- Lift `g` to a unit mod `n` through the reduction homomorphism on units `ZMod.unitsMap`, which is surjective (`ZMod.unitsMap_surjective`, requiring `NeZero n`).
- Transport the universal relation `u ^ (n-1) = 1` along this multiplicative map to get `g ^ (n-1) = 1`, then conclude `p - 1 = orderOf g ∣ n - 1` via `orderOf_dvd_of_pow_eq_one`.

The file includes module documentation explaining its role as one step toward Korselt's criterion, stays narrowly scoped (only this result), and compiles cleanly. Verification: no `sorry` present, and `#print axioms` reports dependence only on the standard `propext`, `Classical.choice`, `Quot.sound`.

Note: the project's overall `lake build` default targets have a pre-existing source-directory/glob mismatch unrelated to this task, so the new file was verified by compiling it directly with `lake env lean` against the project's mathlib (module name `Algebra.KorseltUnitsBridge`).