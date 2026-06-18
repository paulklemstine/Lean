Develop a complete Lean 4 file formalizing a precise follow-up to `Catalog/Bridges/RipsTropicalFunctor.lean`, focused on higher cliques rather than an informal all-dimensions slogan.

Target file: `Catalog/Bridges/RipsTropicalCliques.lean`

Primary goal:
Build a fully checked finite-combinatorial bridge between the existing tropical threshold `tropBirthSum α` and the presence of all cliques of a fixed size `m` in the Vietoris–Rips complex of a finite pseudometric space.

Mathematical scope:
Let `α` be a finite type with decidable equality and pseudometric structure. Define:
1. `IsRipsClique (ε : ℝ) (s : Finset α) : Prop` meaning every distinct pair in `s` has distance `≤ ε`.
2. `cliqueCount (m : ℕ) (ε : ℝ) : ℕ` as the number of `m`-element finite subsets that are Rips cliques at scale `ε`.

Required theorem package:

A. Basic definitions and monotonicity
- Prove `IsRipsClique_mono`: if `ε ≤ ε'` and `IsRipsClique ε s`, then `IsRipsClique ε' s`.
- Prove `cliqueCount_monotone`: for fixed `m`, the function `ε ↦ cliqueCount m ε` is monotone.

B. Saturation/counting criterion
- Prove an exact criterion of the form
  `cliqueCount m ε = Nat.choose (Fintype.card α) m ↔ ∀ s : Finset α, s.card = m → IsRipsClique ε s`.
If the exact `Nat.choose` counting statement is awkward, it is acceptable to phrase this using the filtered powerset/cardinality enumeration already available in Mathlib, but the theorem must explicitly characterize maximal clique count as “every m-subset is a clique”.

C. Finite extension lemma (the real bottleneck)
- Prove a lemma: if `x ≠ y`, `2 ≤ m`, and `m ≤ Fintype.card α`, then there exists a finset `s : Finset α` such that
  `s.card = m`, `x ∈ s`, and `y ∈ s`.
This should be isolated as a reusable combinatorial lemma. Prefer a proof via complements / choosing `m-2` extra vertices from `univ.erase x.erase y`, or any clean finite-type argument already supported by Mathlib.

D. Fixed-size clique bridge to the tropical threshold
- Prove the forward implication:
  if every `m`-element subset is a Rips clique at scale `ε`, and `2 ≤ m ≤ Fintype.card α`, then the Rips 1-skeleton is complete at scale `ε`.
  The proof should use the extension lemma to place any pair into an `m`-subset.
- Combine this with the existing theorem from `Catalog/Bridges/RipsTropicalFunctor.lean` to derive:
  `(∀ s : Finset α, s.card = m → IsRipsClique ε s) ↔ tropBirthSum α ≤ ε`
  under hypotheses `2 ≤ m` and `m ≤ Fintype.card α`.
  More precisely, if the reverse direction is easier via complete 1-skeleton, it is fine to state the theorem in an equivalent form that factors through the existing bridge.

E. Optional stronger corollary
- If convenient after the main theorem, derive a counting corollary:
  `cliqueCount m ε = Nat.choose (Fintype.card α) m ↔ tropBirthSum α ≤ ε`
  under the same hypotheses `2 ≤ m` and `m ≤ Fintype.card α`.
This is desirable but secondary to a complete proof of parts A–D.

Important constraints:
- Do not restate an unproved all-`k` skeleton theorem. Keep the result fixed-size and hypothesis-explicit.
- No placeholders, `sorry`, or truncated declarations.
- Reuse the exact bridge already proved in `Catalog/Bridges/RipsTropicalFunctor.lean` rather than reproving the tropical 1-skeleton theorem.
- Prefer `Catalog/FINAL/` references when available.
- Include module documentation explaining that the key insight is that for any fixed clique size `m ≥ 2`, maximal presence of `m`-cliques is equivalent to complete graph presence, because every edge extends to an `m`-subset in a finite ambient set.

Why now?
This is tractable now because the catalog already contains the 1-skeleton/tropical threshold bridge; the missing work is finite combinatorics on `Finset`/`Fintype`, not new tropical geometry. The central novelty is a reusable extension lemma turning pairwise completeness into fixed-cardinality clique saturation.

Deliverables:
1. A complete Lean file `Catalog/Bridges/RipsTropicalCliques.lean`.
2. Clear separation between newly proved finite-combinatorial lemmas and imported bridge results.
3. Brief comments noting any Mathlib lemmas that were essential for the extension argument.