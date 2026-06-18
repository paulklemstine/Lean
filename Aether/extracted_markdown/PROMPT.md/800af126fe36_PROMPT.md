Create a single focused file `Catalog/Algebra/KorseltUnitsBridge.lean` containing exactly four results with COMPLETE proofs. NO other theorems, NO unrelated content.

The four results:

1. `orderOf_dvd_of_forall_pow_eq_one`: If ∀ g : G, g^m = 1 in a monoid, then orderOf g ∣ m. Proof: `exact orderOf_dvd_of_pow_eq_one (h g)`

2. `orderOf_map_dvd_of_surjective`: For a group hom φ : G →* H (surjectivity hypothesis kept for interface but not used in proof), orderOf (φ g) ∣ orderOf g. Proof: apply orderOf_dvd_of_pow_eq_one, rewrite using ← map_pow, pow_orderOf_eq_one, map_one.

3. `unitsMap_surjective_of_squarefree`: If p is prime, p ∣ n, and Squarefree n, then ZMod.unitsMap (ZMod n)ˣ →* (ZMod p)ˣ is surjective. This follows from ZMod.unitsMap_surjective and the fact that Squarefree n implies p.Coprime (n / p).

4. **MAIN THEOREM** `prime_sub_one_dvd_of_forall_units_pow_eq_one`: If n is squarefree, p is prime, p ∣ n, and ∀ u : (ZMod n)ˣ, u ^ (n-1) = 1, then (p-1) ∣ (n-1).

Proof strategy for the main theorem:
- Let g be a generator of (ZMod p)ˣ (exists via IsCyclic.exists_generator or ZMod.unitCommGroup)
- By surjectivity of ZMod.unitsMap (lemma 3), obtain h : (ZMod n)ˣ mapping to g
- By hypothesis, h^(n-1) = 1, so orderOf h ∣ (n-1) (lemma 1)
- By lemma 2, orderOf (ZMod.unitsMap h) ∣ orderOf h, so orderOf g ∣ orderOf h
- Since g is a generator of (ZMod p)ˣ which has order p-1, orderOf g = p - 1
- Therefore (p-1) ∣ (n-1)

CRITICAL: Every proof must be COMPLETE. No `sorry`. No truncated tactics. No unrelated theorems about tables, persistence modules, or de Bruijn indices. The file should be under 80 lines total.