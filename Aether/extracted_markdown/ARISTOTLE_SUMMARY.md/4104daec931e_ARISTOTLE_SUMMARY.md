# Summary of changes for run 8352bfd1-6236-42ac-952e-a63c14a8770c
Created a complete, self-contained formalization of finite information geometry in `Catalog/MachineLearning/FiniteInfoGeometry.lean` (namespace `FiniteInfoGeometry`). The file compiles with no `sorry` and no warnings, depending only on the standard axioms `propext`, `Classical.choice`, and `Quot.sound`.

Structure and definitions:
- `FiniteStatModel Ω n`: a finite statistical model over a finite sample space `Ω` and parameter space `Fin n → ℝ`, carrying a probability mass function `pmf`, its nonnegativity (`pmf_nonneg`) and normalization (`pmf_normalized`), and externally supplied score data `score : Θ → Ω → Fin n → ℝ` (kept as raw finite algebraic data, so no logarithm/`logLik` axiom is introduced).
- `FullSupport`: every outcome has strictly positive probability.
- `wExp`: weighted expectation on the finite space.
- `scoreDir`: the directional score `⟪s_ω, v⟫ = ∑ i, score i · v i`.
- `fisherMatrix`: the Fisher information matrix `I(θ)_{ij} = ∑ ω, p θ ω · sᵢ · sⱼ`.
- `scoreMatrix`: the `Ω × Fin n` matrix whose rows are the score vectors.

Main proved results:
- `fisherMatrix_symm` and `fisherMatrix_isHermitian`: the Fisher matrix is symmetric/Hermitian.
- `fisher_quadForm`: the quadratic form `vᵀ I v` equals the finite weighted sum of squares `∑ ω, p θ ω · ⟪s_ω, v⟫²`.
- `fisher_quadForm_nonneg` and `fisherMatrix_posSemidef`: nonnegativity of the quadratic form, hence positive semidefiniteness in mathlib's `Matrix.PosSemidef` sense.
- `weighted_sq_sum_eq_zero_iff`, `fisher_mulVec_eq_zero_iff`: a coordinate description of the kernel.
- `fisher_ker_eq_score_annihilator`: under full support, the kernel of the Fisher matrix is exactly the common orthogonal annihilator of all score vectors.
- `fisher_ker_eq_scoreMatrix_ker`, `rank_fisher_eq_rank_score`, `rank_fisher_eq_finrank_span_score`: under full support, the rank of the Fisher matrix equals the rank of the score matrix, i.e. the dimension of the span of the score vectors.
- `rank_fisher_ge_of_linearIndependent`: the culminating complexity lower bound — exhibiting `k` linearly independent score vectors forces `rank(fisherMatrix θ) ≥ k`, so statistical/geometric complexity is detected by Fisher rank.

The file is placed under the existing `MachineLearning` library and reuses mathlib's matrix, rank, and linear-algebra API throughout, making the lemmas reusable for later representation lower-bound work.