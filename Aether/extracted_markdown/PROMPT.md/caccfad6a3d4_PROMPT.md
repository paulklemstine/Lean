Produce ONE self-contained, fully-verified Lean 4 file (0 sorries, 0 incomplete proofs) establishing the arithmetic bridge toward Korselt's criterion. The file should contain exactly these results, each with a COMPLETE proof:

1. `orderOf_dvd_of_forall_pow_eq_one` — If g^m = 1 for every g in a monoid, then orderOf g ∣ m for every g. (Wrapper around Mathlib's orderOf_dvd_of_pow_eq_one.)

2. `orderOf_map_dvd_of_surjective` — If φ : G →* H is a surjective group homomorphism, then orderOf (φ g) ∣ orderOf g. (Use map_pow, pow_orderOf_eq_one, map_one.)

3. `unitsMap_surjective_of_dvd` — For prime p dividing n, ZMod.unitsMap (show p ∣ n := ...) from (ZMod n)ˣ to (ZMod p)ˣ is surjective. (This may already be in Mathlib; search for it before proving from scratch.)

4. `prime_sub_one_dvd_of_forall_units_pow_eq_one` — MAIN THEOREM: Let n be a natural number, p a prime dividing n, with n squarefree. If ∀ u : (ZMod n)ˣ, u^(n-1) = 1, then (p - 1) ∣ (n - 1). Proof strategy: (a) Transport the hypothesis to (ZMod p)ˣ via the surjective unitsMap. (b) Since (ZMod p)ˣ is cyclic of order p-1, it contains an element of exact order p-1 (use exists_orderOf_eq or similar from Mathlib). (c) Apply orderOf_dvd_of_forall_pow_eq_one to conclude (p-1) ∣ (n-1).

CRITICAL: The main theorem proof must NOT be circular. Every step must reduce to already-proved lemmas or Mathlib results. Do NOT include theorem signatures from unrelated domains (no Table, PersMod, DBTerm, HodgeLap). Do NOT include any sorry. Every def/theorem must have a complete proof that closes.

Import only Mathlib. Name the file KorseltUnitsBridge.lean. Use namespace KorseltUnitsBridge.