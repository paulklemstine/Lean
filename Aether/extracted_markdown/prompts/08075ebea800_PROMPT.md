Formalize a small but complete support file for future Korselt-style arguments, avoiding any unfinished theorem stubs and focusing on explicit reusable corollaries rather than only restating a Mathlib equivalence.

Create a Lean file `Catalog/Bridges/KorseltFactorizationBridge.lean` that imports Mathlib and works in a namespace such as `Catalog.Bridges`.

Main task:
1. Prove a coordinatewise divisibility/factorization bridge for naturals:
   - theorem `dvd_iff_factorization_forall_le {a b : ℕ} (ha : a ≠ 0) (hb : b ≠ 0) :
       a ∣ b ↔ ∀ p, a.factorization p ≤ b.factorization p`
   This should be proved by rewriting `Nat.factorization_le_iff_dvd ha hb` through `Finsupp.le_def` or an equivalent pointwise formulation.

2. Derive a specialized divisor corollary:
   - theorem `dvd_iff_primeFactorization_forall_le {p n : ℕ} (hp : p ≠ 0) (hn : n ≠ 0) :
       p ∣ n ↔ ∀ q, p.factorization q ≤ n.factorization q`
   This is just the previous theorem specialized, but give it a clear name and exact statement because it will be used later in Korselt-style files.

3. Derive the predecessor-modulus corollary:
   - theorem `dvd_pred_iff_factorization_forall_le {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 1) :
       m ∣ (n - 1) ↔ ∀ q, m.factorization q ≤ (n - 1).factorization q`
   You will need to prove `(n - 1) ≠ 0` from `n ≠ 1` in the natural-number setting. Use a helper lemma if convenient.

4. Add the Korselt-style specialization:
   - theorem `dvd_sub_one_iff_factorization_forall_le {p n : ℕ} (hp : 2 ≤ p) (hn : 2 ≤ n) :
       (p - 1) ∣ (n - 1) ↔ ∀ q, (p - 1).factorization q ≤ (n - 1).factorization q`
   Here you should derive `p - 1 ≠ 0` and `n - 1 ≠ 0` from the `2 ≤` hypotheses.

Requirements:
- Ensure the file type-checks end-to-end with no truncation.
- Keep the statements precise and usable; do not start proving Korselt’s criterion itself.
- Add short module documentation explaining that this is a bridge file for divisibility clauses appearing in Korselt-style arguments.
- Prefer direct proofs from existing Mathlib lemmas rather than elaborate custom machinery.
- If a theorem name collides with Mathlib or existing local names, choose a nearby unambiguous name, but preserve the mathematical content above.

The goal is not novelty for its own sake; it is a complete, polished, directly reusable formal bridge tailored to the exact `p ∣ n` and `(p - 1) ∣ (n - 1)` clauses that later Carmichael/Korselt developments need.