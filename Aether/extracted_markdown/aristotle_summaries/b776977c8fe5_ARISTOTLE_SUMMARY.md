# Summary of changes for run d426bead-4c21-46dd-82c7-14908c700cd2
Created the standalone Lean 4 file `Catalog/Algebra/KorseltUnitsBridge.lean`, which compiles with no `sorry` and uses only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

The file formalizes one arithmetic bridge lemma toward Korselt's criterion, organized exactly as requested, all in namespace `KorseltUnitsBridge`:

1. `orderOf_dvd_of_forall_pow_eq_one` — reusable lemma: in a monoid, if `∀ x, x ^ m = 1` then `orderOf g ∣ m`.
2. `forall_pow_eq_one_of_surjective` — transport along a surjective monoid hom `φ : G →* H`: if `∀ g, g ^ m = 1`, then `∀ h, h ^ m = 1`.
3. `unitsMap_surjective_of_dvd` — the precise reduction-map lemma: surjectivity of the canonical hom `(ZMod n)ˣ →* (ZMod p)ˣ` (mathlib's `ZMod.unitsMap`) for `p ∣ n`, `n ≠ 0`.
4. `prime_sub_one_dvd_of_forall_units_pow_eq_one` — the final theorem: for `[Fact p.Prime]`, `hp : p ∣ n`, and `hpow : ∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1`, concludes `p - 1 ∣ n - 1`.

The final proof transports the exponent condition along the surjective reduction map to `(ZMod p)ˣ`, then uses cyclicity of `(ZMod p)ˣ` (`IsCyclic.exists_ofOrder_eq_natCard`) together with `Nat.card (ZMod p)ˣ = p - 1` to obtain an element of order exactly `p - 1`, whose order divides `n - 1`.

Note on hypotheses: surjectivity of the reduction map (mathlib's `ZMod.unitsMap_surjective`) only requires `n ≠ 0`, not squarefreeness, so the statement keeps the original shape with no `Squarefree` hypothesis. The `n = 0` case is handled separately and is trivial since `n - 1 = 0`. This is documented in the module docstring. The file is tightly focused with no unrelated declarations.