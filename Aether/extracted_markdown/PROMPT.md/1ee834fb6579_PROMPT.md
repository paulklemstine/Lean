Create a single Lean 4 file `KorseltUnitsBridge.lean` that proves the following theorem cleanly and completely:

**Main Theorem:** If `n` is squarefree, `p` is a prime dividing `n`, and every unit `u : (ZMod n)ˣ` satisfies `u ^ (n - 1) = 1`, then `(p - 1) ∣ (n - 1)`.

**Proof strategy (follow exactly):**

Step 1: From the hypothesis `∀ u : (ZMod n)ˣ, u ^ (n-1) = 1`, conclude `orderOf u ∣ (n-1)` for all `u` using `orderOf_dvd_of_pow_eq_one`.

Step 2: Use `ZMod.unitsMap` (the reduction homomorphism `(ZMod n)ˣ →* (ZMod p)ˣ`) and prove it is surjective when `p ∣ n` and `n` is squarefree. Search Mathlib for `ZMod.unitsMap_surjective` or related lemmas. The key fact is that when `p ∣ n` and `n` is squarefree, the reduction map on units is surjective.

Step 3: Since `(ZMod p)ˣ` is cyclic of order `p - 1` (use `ZMod.units_cyclic` or `isCyclic_of_subsingleton_of_one_le_card` combined with `ZMod.card_units`), it contains an element of order `p - 1`.

Step 4: Transport the divisibility from Step 1 through the surjective homomorphism from Step 2: if `φ : G →* H` is surjective and `orderOf g ∣ m` for all `g : G`, then `orderOf h ∣ m` for all `h : H` (since any `h = φ g` for some `g`, and `orderOf (φ g) ∣ orderOf g ∣ m`).

Step 5: The element of order `p - 1` from Step 3 satisfies `(p - 1) ∣ (n - 1)` by Step 4.

**CRITICAL RULES:**
- Do NOT include any theorem signatures without complete proofs.
- Do NOT include any content from unrelated domains (no Table, SpExpr, graph theory, Belnap logic, etc.).
- The main theorem proof must NOT be circular — do not reference a hypothesis in its own definition.
- Every `by` block must terminate in a valid tactic proof.
- Import only `Mathlib`.
- The file should be under 150 lines total.
- Use `sorry` ONLY if completely stuck on one sub-step, and mark it clearly with a comment explaining what remains.