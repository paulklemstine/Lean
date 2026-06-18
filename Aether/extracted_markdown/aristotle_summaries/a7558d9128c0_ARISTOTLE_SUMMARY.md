# Summary of changes for run 59b3c0bc-9de4-40a6-af90-050d10ca7117
Created `Catalog/Novelty/KorseltUnitsBridge.lean` with exactly the requested content: the two helper lemmas plus the single main theorem, all fully proved (no `sorry`, no circular reasoning, no unrelated fragments).

Contents:
- `orderOf_dvd_of_forall_pow_eq_one` — `g ^ m = 1 → orderOf g ∣ m` (via `orderOf_dvd_of_pow_eq_one`).
- `orderOf_map_dvd_of_surjective` — for a surjective monoid hom `φ`, `orderOf (φ g) ∣ orderOf g` (via `orderOf_map_dvd`).
- `prime_sub_one_dvd_of_forall_units_pow_eq_one` — the Korselt units bridge: if `n` is squarefree and every unit `u : (ZMod n)ˣ` satisfies `u ^ (n-1) = 1`, then for every prime `p ∣ n`, `(p-1) ∣ (n-1)`.

The main proof follows the prescribed bottom-up strategy:
1. `ZMod.unitsMap_surjective hpn` gives surjectivity of the reduction map `(ZMod n)ˣ →* (ZMod p)ˣ`.
2. For each `v : (ZMod p)ˣ`, pull back to `u` with `φ u = v` and map `u^(n-1)=1` through `φ` to get `v^(n-1)=1`.
3. `IsCyclic.exists_ofOrder_eq_natCard` yields a generator `g`; `Nat.card_eq_fintype_card`, `ZMod.card_units_eq_totient`, and `Nat.totient_prime` give `orderOf g = p - 1`.
4. `orderOf g ∣ (n-1)` (helper 1 applied to `g^(n-1)=1`) combined with `orderOf g = p - 1` yields `(p-1) ∣ (n-1)`.

The proof was verified to elaborate with zero diagnostics against the pinned Mathlib revision. (Note: the repository's default build targets are independently broken due to a pre-existing missing file `Catalog/Algebra/Jacobian/Defs.lean`, unrelated to this file.)