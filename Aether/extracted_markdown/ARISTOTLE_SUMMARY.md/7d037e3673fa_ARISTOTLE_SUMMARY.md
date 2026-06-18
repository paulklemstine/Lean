# Summary of changes for run bdfce642-67d7-4052-80e3-40219509a235
## Deliverables

### Lean 4 File: `Bridges/NonArchProbability/DutchBook.lean`

A new self-contained Lean 4 file with **6 machine-verified theorems** (0 sorries, 0 `sorryAx` in axiom traces) extending the `FinProbSpace F n` framework to arbitrary linearly ordered fields:

#### Theorem Declarations

1. **`dutch_book_of_neg_weight`** — If some price p(i₀) < 0, an explicit Dutch book exists (stake 1 on i₀, 0 elsewhere). **Status: proved.** Key insight: cost = p(i₀) < 0, so the bettor is *paid* to take the bet.

2. **`no_dutch_book`** — Probability axioms (nonneg weights, sum = 1) preclude Dutch books. **Status: proved.** Key insight: multiply profit inequality by weights and sum; ∑w = 1 gives contradiction.

3. **`dutch_book_of_sum_ne_one`** — Mispriced totals admit a Dutch book. **Status: proved.** Key insight: uniform stakes ±1 depending on whether ∑p < 1 or > 1.

4. **`dutch_book_full_characterization`** — The headline result: `¬ Nonempty (DutchBook F n p) ↔ (∀ i, 0 ≤ p i) ∧ ∑ i, p i = 1`. **Status: proved.** Key insight: combines all three Dutch book lemmas. The Kolmogorov axioms are *exactly* the coherence conditions for betting prices over *any* linearly ordered field.

5. **`law_of_total_probability`** — P(A) = ∑ⱼ P(A ∩ Bⱼ) for any partition {Bⱼ}. **Status: proved.** Key insight: Finset.sum_biUnion with inherited disjointness.

6. **`variance_nonneg`** — Var(X) ≥ 0 over any ordered field. **Status: proved.** Key insight: each summand w(i)·(X(i)-μ)² is nonneg.

#### Verification
- All 6 theorems compile without warnings
- `#print axioms` confirms only `[propext, Classical.choice, Quot.sound]` — no `sorryAx`
- File is 153 lines, self-contained (imports only Mathlib)

#### Novelty
The **full bidirectional Dutch Book characterization** over arbitrary ordered fields (not just ℝ) is the main novel contribution. Previous formalizations either:
- Only prove one direction (no_dutch_book)
- Work only over ℝ
- Don't handle the negative-weights case

Our characterization covers all three failure modes (∑p < 1, ∑p > 1, ∃i p(i) < 0) with explicit constructions.

### FUTURE_DIRECTIONS.md

Contains 5 falsifiable research directions:
1. Non-Archimedean Chebyshev and concentration inequalities
2. Algebraic Jensen's inequality via induction on atoms
3. Dutch Book theorem with transaction costs (approximate coherence)
4. Tropical probability via valuation maps (connecting to Mathlib's `Tropical` type)
5. Finite de Finetti theorem over ordered fields

The file is placed at both `Bridges/NonArchProbability/DutchBook.lean` (root, for builds) and `Catalog/Bridges/NonArchProbability/DutchBook.lean` (catalog location, matching project structure).