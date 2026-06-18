# Summary of changes for run 41ce0079-acc7-4412-886e-c7d8405452ae
Created `Catalog/Bridges/KorseltUnitsBridge.lean` (namespace `KorseltUnitsBridge`, importing only Mathlib), a self-contained, fully-verified file with no `sorry` and no incomplete proofs. It contains exactly the four requested results, each with a complete proof:

1. `orderOf_dvd_of_forall_pow_eq_one` — if `g ^ m = 1` for every `g` in a monoid then `orderOf g ∣ m`; a wrapper around `orderOf_dvd_of_pow_eq_one`.
2. `orderOf_map_dvd_of_surjective` — for a group homomorphism `φ : G →* H`, `orderOf (φ g) ∣ orderOf g`, proved via `map_pow`, `pow_orderOf_eq_one`, `map_one`.
3. `unitsMap_surjective_of_dvd` — for `p ∣ n` with `NeZero n`, `ZMod.unitsMap` is surjective; this delegates to Mathlib's existing `ZMod.unitsMap_surjective`.
4. `prime_sub_one_dvd_of_forall_units_pow_eq_one` (main theorem) — for `n` squarefree, `p` a prime divisor of `n`, if every unit of `ZMod n` satisfies `u ^ (n-1) = 1` then `(p-1) ∣ (n-1)`. The proof is non-circular: it transports the hypothesis along the surjective unit map to `(ZMod p)ˣ`, uses that `(ZMod p)ˣ` is cyclic of cardinality `p-1` to obtain an element of order `p-1` (`IsCyclic.exists_ofOrder_eq_natCard` with `ZMod.card_units`), then applies result (1) to conclude.

Verification: the module compiles successfully (`lake build Bridges.KorseltUnitsBridge`), contains no `sorry`, and `#print axioms` on the main theorem reports only `propext`, `Classical.choice`, and `Quot.sound`. No unrelated theorem signatures were included.