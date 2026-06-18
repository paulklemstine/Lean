Repair the failed attempt by discarding the unrelated Pushout/HIT material and focusing only on the original NumberTheory goal.

Target theorem to prove in Lean:

- A theorem of the form
  `prime_sub_one_dvd_of_forall_units_pow_eq_one`
  asserting:
  for natural numbers `n p`, if `Nat.Squarefree n`, `p.Prime`, `p ∣ n`, and
  `∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1`,
  then `(p - 1) ∣ (n - 1)`.

Required proof strategy:
1. Use the canonical ring hom `ZMod n →+* ZMod p` available when `p ∣ n`, and the induced units hom `Units.map` / `ZMod.unitsMap` to obtain a surjective group hom
   `(ZMod n)ˣ →* (ZMod p)ˣ`.
2. Transport the hypothesis `∀ u : (ZMod n)ˣ, u^(n-1)=1` across this surjection to show
   `∀ v : (ZMod p)ˣ, v^(n-1)=1`.
3. Apply the already verified helper lemmas:
   - `orderOf_dvd_of_forall_pow_eq_one`
   - `orderOf_map_dvd_of_surjective`
   if useful, or otherwise directly deduce for each `v : (ZMod p)ˣ` that `orderOf v ∣ (n - 1)`.
4. Use the fact that `(ZMod p)ˣ` is cyclic for prime `p`, together with the standard cardinality theorem
   `Nat.card (ZMod p)ˣ = p - 1`, to choose a generator `g` with `orderOf g = p - 1` (or equivalent via `IsCyclic.exists_orderOf_eq_natCard`).
5. Conclude `(p - 1) ∣ (n - 1)`.

Constraints:
- Stay entirely in NumberTheory / algebraic structures already present in Mathlib.
- Do not add unrelated abstractions, topology, logic, HITs, pushouts, or exploratory material.
- Prefer a short, robust proof over generalization.
- If the squarefree hypothesis is not actually needed for the final theorem as stated, keep it in the theorem statement anyway unless removing it is necessary for compilation; if removed, explain by theorem naming/comment that it was unused in this bridge lemma.
- Produce a complete Lean file with no `sorry`, no malformed declarations, and no broken syntax.

Suggested implementation plan:
- Search for the verified helper lemmas from the previous cycle and import the exact file(s) containing them.
- Search Mathlib for the relevant `ZMod` map-to-divisor and induced units-map surjectivity lemmas; if names differ from expectation, adapt to the available API rather than inventing new infrastructure.
- Keep all auxiliary lemmas local and minimal, mainly to bridge theorem-name/API mismatches.

Primary success criterion:
- A fully verified theorem proving `(p - 1) ∣ (n - 1)` from the stated hypotheses, in the intended NumberTheory file.