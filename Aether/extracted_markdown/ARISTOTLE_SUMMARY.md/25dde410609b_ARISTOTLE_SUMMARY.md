# Summary of changes for run 4e41613a-f7a9-4bfb-966b-f34572591390
Created a single, focused Lean file `Bridges/KorseltUnitsBridge.lean` formalizing the arithmetic bridge toward Korselt's criterion.

Contents (namespace `KorseltUnitsBridge`):
- `pow_eq_one_of_surjective`: a generic transport lemma — if `f : G →* H` is a surjective monoid hom and every `x : G` satisfies `x ^ m = 1`, then every `y : H` satisfies `y ^ m = 1`.
- `prime_sub_one_dvd_of_forall_units_pow_eq_one`: the target theorem. For `n p : ℕ` with `hp : p.Prime`, `hpn : p ∣ n`, and `hpow : ∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1`, it concludes `(p - 1) ∣ (n - 1)`.

Proof plan followed exactly as requested:
- The `n = 0` case is dispatched first (giving `NeZero n` afterward).
- The exponent identity is transported along the canonical reduction map `(ZMod n)ˣ →* (ZMod p)ˣ` using `ZMod.unitsMap_surjective` (with `NeZero n`).
- `Monoid.exponent_dvd_of_forall_pow_eq_one` gives `Monoid.exponent (ZMod p)ˣ ∣ (n - 1)`.
- The exponent is rewritten to `p - 1` via `IsCyclic.exponent_eq_card`, `Nat.card_eq_fintype_card`, and `ZMod.card_units`, reusing Mathlib's existing cyclicity instance rather than constructing a generator.

Verification: the module builds successfully with no warnings and contains no `sorry`. An axiom check confirmed the theorem depends only on the standard axioms `propext`, `Classical.choice`, and `Quot.sound`.