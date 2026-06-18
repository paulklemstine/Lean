Produce a single Lean 4 file formalizing a precise factorization/divisibility bridge on natural numbers, and keep the scope tightly limited to results that can be completed cleanly with existing Mathlib lemmas.

Target file: Catalog/Bridges/KorseltFactorizationBridge.lean

Primary theorem:
- Prove a clean theorem of the form
  `theorem dvd_iff_factorization_le {a b : ℕ} (ha : a ≠ 0) : a ∣ b ↔ ∀ p : ℕ, a.factorization p ≤ b.factorization p`
  preferably by directly using the existing Mathlib characterization `Nat.factorization_le_iff_dvd` or a nearby lemma.
- If the exact library statement has hypotheses on both `a` and `b`, adapt the theorem statement accordingly, but keep the user-facing theorem as simple as possible.

Required corollaries:
1. A specialization for prime divisors of n:
   `theorem prime_dvd_iff_factorization_le {p n : ℕ} (hp : p.Prime) : p ∣ n ↔ ∀ q : ℕ, p.factorization q ≤ n.factorization q`
   and simplify the left factorization side using the standard description of the factorization of a prime if convenient.
2. A generic restatement for the `(p - 1) ∣ (n - 1)` style clause:
   `theorem dvd_pred_iff_factorization_le {m n : ℕ} (hm : m ≠ 0) : m ∣ (n - 1) ↔ ∀ q : ℕ, m.factorization q ≤ (n - 1).factorization q`
   Keep it purely as a divisibility/factorization bridge; do not introduce Carmichael numbers or prove Korselt’s criterion from scratch.

Optional final packaging:
- If there is already a local or catalog definition/theorem expressing a Korselt-style criterion as
  `Squarefree n ∧ ∀ p, p.Prime → p ∣ n → (p - 1) ∣ (n - 1)`,
  then add a theorem that restates only the divisibility clauses via factorization-coordinate domination. This theorem must be a shallow rewrite of an already available criterion, not a new proof of Korselt.
- If no such existing criterion is available in the referenced files, omit this part entirely.

Constraints:
- Do not define `Carmichael` via `∀ a : ℤ, (n : ℤ) ∣ a^n - a` and do not attempt a from-scratch proof of Korselt.
- Do not include any unrelated material from statistics, logic, exponential families, or other domains.
- The file must be coherent, self-contained, and compilable.
- Prefer short proofs that explicitly cite Mathlib lemmas already expressing factorization-vs-divisibility.
- Add concise module documentation explaining that the phrase “factorization-coordinate domination” means the pointwise inequality on `Nat.factorization`.

Deliverable:
- One clean Lean file with the above theorem(s), complete proofs, and minimal imports.
- If an optional Korselt restatement is included, clearly separate it from the core bridge theorem and ensure it depends only on pre-existing results, not on new number-theoretic development.