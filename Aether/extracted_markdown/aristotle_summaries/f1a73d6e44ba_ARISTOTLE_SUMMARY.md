# Summary of changes for run ae122bee-344e-4b2f-9d04-5fc7b680bb3b
Created `Catalog/MachineLearning/FiniteInfoGeometry.lean`, a complete and fully proved Lean 4 development of finite information geometry centered on the Fisher matrix as a Gram matrix of weighted score vectors. The file builds cleanly (no `sorry`, no warnings) and every theorem checks out with only the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

Contents (all in namespace `FiniteInfoGeometry`, over a finite sample space `Ω` with `[Fintype Ω] [DecidableEq Ω]` and parameter dimension `n`):

Definitions:
- `FiniteStatModel Ω n` — structure with fields `pmf`, `pmf_nonneg`, `pmf_sum_one`, and a primitive `score`. (`[Fintype Ω]` is required on the structure so that the `pmf_sum_one` field sum is well typed; `DecidableEq Ω` is kept in the ambient setting as requested but `omit`ted from automatic inclusion since no result needs it.)
- `weightedScoreMatrix M θ ω i = √(pmf θ ω) * score θ ω i`
- `fisherMatrix M θ i j = ∑ ω, pmf θ ω * score θ ω i * score θ ω j`
- `fisherQuad M θ v = v ⬝ᵥ (fisherMatrix M θ).mulVec v`

Core theorem:
- `fisherMatrix_eq_transpose_mul_weightedScoreMatrix` — the Gram factorization `fisherMatrix M θ = (weightedScoreMatrix M θ)ᵀ * (weightedScoreMatrix M θ)`, proved entrywise by expanding matrix multiplication and replacing `√p * √p` by `p` via `Real.mul_self_sqrt` and `pmf_nonneg`.

Consequences derived from the factorization:
- `fisherMatrix_symm` — symmetry of the Fisher matrix.
- `fisherQuad_eq_sum_sq` — quadratic-form/sum-of-squares formula `fisherQuad M θ v = ∑ ω, (∑ i, weightedScoreMatrix M θ ω i * v i)^2`.
- `fisherQuad_nonneg` and `fisherMatrix_quad_nonneg` — nonnegativity of the quadratic form for all test vectors.
- `fisherMatrix_posSemidef` — positive semidefiniteness via mathlib's canonical `Matrix.PosSemidef`.
- `fisherMatrix_rank_le` — `rank (fisherMatrix M θ) ≤ rank (weightedScoreMatrix M θ)`.
- `fisherMatrix_rank_eq` — the sharper Gram-matrix rank equality `rank (fisherMatrix M θ) = rank (weightedScoreMatrix M θ)`.

A module docstring explains the program: on a finite sample space the Fisher information is literally the Gram matrix of `√(p)`-weighted score vectors, so the linear-algebraic complexity (rank) of those vectors controls Fisher rank, giving a Lean-feasible surrogate for latent-dimension lower bounds.

The file uses only `import Mathlib` and existing mathlib lemmas (`Matrix.mul_apply`, `Real.mul_self_sqrt`, `Matrix.posSemidef_conjTranspose_mul_self`, `Matrix.rank_mul_le_right`, `Matrix.rank_transpose_mul_self`, etc.), consistent with the project's other `MachineLearning` files. Build verified via the module target `MachineLearning.FiniteInfoGeometry`.