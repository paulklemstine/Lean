# Summary of changes for run 6b66f02b-056f-432f-abd4-efece3be756a
Created `Catalog/MachineLearning/FiniteInfoGeometry.lean`, a self-contained finite information-geometry core built around the "Fisher information = Gram matrix" idea. The file compiles cleanly (verified via `lake build MachineLearning.FiniteInfoGeometry`), contains no `sorry`, and uses only standard axioms.

Contents:
- `FiniteStatModel Ω n`: a finite statistical model over a finite sample space `Ω` with parameters `Fin n → ℝ`, with fields `p`, `score` (treated as a primitive, not derived from logs/differentiability), `p_nonneg`, and `p_sum_one`.
- `weightedScoreMatrix M θ`: matrix `Ω × Fin n` with entries `√(p θ ω) * score θ ω i`.
- `fisherMatrix M θ`: matrix `Fin n × Fin n` with entries `∑ ω, p θ ω * score θ ω i * score θ ω j`.

Theorems (all fully proved):
- `fisher_eq_gram`: `fisherMatrix θ = (weightedScoreMatrix θ)ᵀ * weightedScoreMatrix θ`, via `Matrix.ext`, expansion of matrix multiplication, and the scalar identity `√p * sᵢ * (√p * sⱼ) = p * sᵢ * sⱼ` (using `Real.mul_self_sqrt` and `linear_combination`).
- `fisherMatrix_transpose`: the Fisher matrix is symmetric.
- `fisher_quadratic_form`: `x ⬝ᵥ (fisherMatrix θ).mulVec x = ∑ ω, (∑ i, weightedScoreMatrix θ ω i * x i)^2` (sum-of-squares form).
- `fisher_posSemidef_form`: `0 ≤ x ⬝ᵥ (fisherMatrix θ).mulVec x`, derived from the sum-of-squares formula.
- `fisher_rank`: `(fisherMatrix θ).rank = (weightedScoreMatrix θ).rank`, via Mathlib's `Matrix.rank_transpose_mul_self` (the requested clean rank result that the library supports).

Notes:
- The development follows the finite-dimensional matrix-factorization route exactly (finite sums, matrix multiplication, transpose, `mulVec`, `dotProduct`, real square roots), with no measure theory or manifolds.
- Imports are kept minimal (matrix rank, real square root, and the `linear_combination` tactic) rather than pulling in unrelated material.
- The requested `[DecidableEq Ω]` is included in the ambient setup but turns out to be unnecessary for every result; this is documented in a comment, and it is `omit`ted per-theorem to keep the build warning-free.
- Concise module documentation explains the Fisher-as-Gram idea and lists what is proved.