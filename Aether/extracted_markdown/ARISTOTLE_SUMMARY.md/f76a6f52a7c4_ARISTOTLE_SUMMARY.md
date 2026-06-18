# Summary of changes for run c4b506fd-2902-4a8b-915a-be1c4e47278a
## Completed Deliverables

### 1. Formally Verified Mathematics (Lean 4) — Zero Sorries

Two sorry-free Lean files in `Speculative/Dixon/`:

**`BinomialBounds.lean`** (195 lines) — Core inequalities:
- `sum_inv_choose_le`: For n ≥ 6, ∑_{k=1}^{⌊n/2⌋} 1/C(n,k) ≤ 1/n + 5/n² ✓
- `sum_inv_choose_le_tight`: For n ≥ 15, the tighter bound with constant 3 ✓  
- `sum_inv_choose_tail_le`: For n ≥ 6, ∑_{k=2}^{⌊n/2⌋} 1/C(n,k) ≤ 5/n² ✓
- Helper lemmas: `choose_mono_le_half`, `choose_three_le`, `inv_choose_le_inv_choose_three`, `algebraic_key_ineq`, `sum_inv_choose_le_small` (finite verification for n=6..80)

**`ObstructionFramework.lean`** (180 lines) — Obstruction calculus:
- `obstructionProbIntransitive`: Definition of the intransitive obstruction bound
- `intransitive_obstruction_le`: Certified bound 1/n + 5/n² for n ≥ 6 ✓
- `intransitive_obstruction_le_tight`: Tighter bound 1/n + 3/n² for n ≥ 15 ✓
- `intransitive_obstruction_tends_to_inv_n`: Asymptotic bound ≤ 2/n ✓
- `union_bound_term_eq`: Union bound identity C(n,k)·(1/C(n,k))² = 1/C(n,k) ✓
- `obstruction_decomp_bound`: Total three-class obstruction bound ✓
- `generation_prob_lower_bound`: P(⟨σ,τ⟩ ⊇ Aₙ) ≥ 1 - 1/n - 7/n² - 1/n³ ✓
- `commonFixedPointProb`: Exact inclusion-exclusion formula for r-generator common fixed points
- `common_fixed_point_trivial`, `common_fixed_point_small_example`: Verified computations ✓
- `ObstructionClass` inductive type and `obstructionBound` definitions

All proofs verified with `lean_build` and use only standard axioms (propext, Classical.choice, Quot.sound, Lean.ofReduceBool, Lean.trustCompiler).

**Key discovery:** The original conjecture (constant 3 for n ≥ 6) is **false** for n = 6 through 14. The constant 5 is the smallest integer that works uniformly for all n ≥ 6. The optimal rational constant is 152/35 ≈ 4.343, achieved at n = 8.

### 2. Popular Science Article — `ARTICLE.md`
~1800 words on "The Hidden Order in Randomness," explaining the obstruction calculus through the metaphor of shuffling cards, suitable for a general audience.

### 3. Research Paper — `RESEARCH_PAPER.md`
~3500 words covering motivation, precise theorem statements, proof strategies, computational experiments (with tables), applications, and references to Dixon, Babai, Liebeck-Shalev.

### 4. Python Code
- `demo.py`: Numerical demonstrations of all theorems with formatted output
- `algorithms.py`: Implementations of reciprocal binomial sums, inclusion-exclusion, obstruction spectrum computation, with self-tests
- `applications.py`: Cryptographic key generation analysis, Monte Carlo validation, obstruction anatomy, multi-generator scaling

### 5. Future Directions — `FUTURE_DIRECTIONS.md`
Five falsifiable hypotheses: constant sharpening (H1), imprimitive obstruction O(1/n²) (H2), multi-generator phase transition (H3), alternating group parity correction (H4), transfer to GL(n,q) via Gaussian binomials (H5).

### 6. JSON Package — `PACKAGE.json`
Complete bundle of all deliverables for web templating.