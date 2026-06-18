Create a single Lean 4 file formalizing a finite information geometry core centered on the Fisher matrix as a Gram matrix, and make sure the file compiles with no `sorry`.

Target file: `Catalog/MachineLearning/FiniteInfoGeometry.lean`

Mathematical scope:
- Work over a finite sample space `Ω` with `[Fintype Ω] [DecidableEq Ω]` and parameter dimension `n : ℕ`.
- Define `FiniteStatModel (Ω) (n)` with fields
  - `p : (Fin n → ℝ) → Ω → ℝ`
  - `score : (Fin n → ℝ) → Ω → Fin n → ℝ`
  - `p_nonneg : ∀ θ ω, 0 ≤ p θ ω`
  - optionally `p_sum_one : ∀ θ, ∑ ω, p θ ω = 1`
- Do not derive scores from logs or differentiability; treat them as primitive.

Definitions to implement:
- `weightedScoreMatrix (M : FiniteStatModel Ω n) (θ : Fin n → ℝ) : Matrix Ω (Fin n) ℝ`
  with entries `Real.sqrt (M.p θ ω) * M.score θ ω i`
- `fisherMatrix (M : FiniteStatModel Ω n) (θ : Fin n → ℝ) : Matrix (Fin n) (Fin n) ℝ`
  with entries `∑ ω, M.p θ ω * M.score θ ω i * M.score θ ω j`

Main theorem to prove first:
- `fisher_eq_gram : M.fisherMatrix θ = (M.weightedScoreMatrix θ)ᵀ ⬝ M.weightedScoreMatrix θ`
Use `Matrix.ext` and expand matrix multiplication. The crucial scalar step is
`Real.sqrt (p) * s_i * (Real.sqrt (p) * s_j) = p * s_i * s_j`
from `p_nonneg` and `Real.sq_sqrt` / `Real.sqrt_mul_self`.

Then derive the following concrete corollaries, all with complete proofs:
1. `fisherMatrix_transpose : (M.fisherMatrix θ)ᵀ = M.fisherMatrix θ`
2. A quadratic-form expansion for any `x : Fin n → ℝ`, preferably in one of these Lean-friendly forms:
   - `x ⬝ᵥ ((M.fisherMatrix θ).mulVec x) = ∑ ω, (∑ i, M.weightedScoreMatrix θ ω i * x i)^2`, or
   - an equivalent sum-of-squares identity phrased via `dotProduct` / `mulVec`.
3. Positive semidefiniteness:
   - `0 ≤ x ⬝ᵥ ((M.fisherMatrix θ).mulVec x)`
   proved from the sum-of-squares formula.
4. If straightforward from existing Mathlib lemmas, add a rank statement such as
   - `Module.rank ℝ (Matrix.colSpace (M.fisherMatrix θ)) ≤ Module.rank ℝ (Matrix.colSpace (M.weightedScoreMatrix θ))`, or
   - a simpler matrix rank inequality / equality for Gram matrices.
   But only include rank results if they are already supported by available lemmas and can be proved cleanly. Do not leave placeholders.

Proof strategy requirements:
- Follow the finite-dimensional matrix-factorization route exactly; do not switch to measure theory, manifolds, or abstract information geometry.
- Keep the development minimal and robust: finite sums, matrix multiplication, transpose, `mulVec`, and real square roots.
- Avoid any unrelated lemmas or imports beyond what is needed.
- If a theorem becomes awkward due to unavailable library support, replace it with a slightly weaker but still meaningful theorem that compiles, rather than leaving incomplete declarations.

Deliverable quality bar:
- The file must be coherent, self-contained, and free of unrelated material.
- Every declaration must have a complete body.
- Include concise module documentation explaining the Fisher-as-Gram idea and what has been proved.

This is a retry of a partial result, so prioritize finishing a smaller, complete theorem pipeline over aiming for maximal generality.