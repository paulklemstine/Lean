Create a new standalone Lean file formalizing a minimal but complete finite information-geometry foundation.

Target file:
- `Catalog/Geometry/InformationGeometry/FiniteCore.lean`

Primary goal:
- Replace the previous malformed attempt with a coherent development that compiles, contains no placeholders, and proves nontrivial facts.

Mathematical scope:
1. Define `FiniteStatModel (Θ Ω)` for finite sample spaces `Ω` with:
   - `pmf : Θ → Ω → ℝ`
   - `pmf_nonneg : ∀ θ ω, 0 ≤ pmf θ ω`
   - `pmf_sum_one : ∀ θ, ∑ ω, pmf θ ω = 1`
   You may omit `logLik` entirely unless it is actually used in proved theorems.

2. Define weighted statistics for any real-valued observable `f : Ω → ℝ` at parameter `θ`:
   - expectation
   - centered observable
   - variance
   - covariance of `f g`

3. Prove a clean package of lemmas such as:
   - expectation of a constant equals that constant
   - covariance is symmetric
   - variance is covariance with itself
   - variance is nonnegative
   - variance of a constant is zero
   - covariance of a constant with any function is zero

4. Define Fisher information using an externally supplied score function:
   - `dlogp : Θ → Ω → Fin n → ℝ`
   - `fisherMatrix M dlogp θ : Matrix (Fin n) (Fin n) ℝ := ...`

5. Prove concrete matrix properties:
   - symmetry of `fisherMatrix`
   - positive semidefiniteness in the explicit quadratic-form sense:
     for any vector `v : Fin n → ℝ`,
     `0 ≤ ∑ i, ∑ j, v i * (fisherMatrix M dlogp θ i j) * v j`
     or an equivalent expanded finite-sum identity reducing the quadratic form to
     `∑ ω, M.pmf θ ω * (∑ i, v i * dlogp θ ω i)^2`.
   This is the main nontrivial theorem.

6. Optional extension only if straightforward and fully provable:
   - define a finite exponential family from a base measure `w : Ω → ℝ` with sufficient statistics `T : Ω → Fin n → ℝ`
   - define `partitionFunction` / normalized pmf
   - prove the pmf sums to 1 under positivity hypotheses ensuring denominator nonzero.
   Keep this elementary; do not introduce derivatives.

Proof strategy:
- Stay entirely in finite sums over `Fintype Ω`.
- Prefer lemmas based on `nlinarith`, `ring`, `linarith`, `positivity`, and sum rearrangement.
- Avoid any incomplete manifold/smoothness structures.
- Avoid unrelated material and do not include placeholder declarations.
- If a theorem becomes awkward in matrix notation, prove the expanded scalar finite-sum statement instead and derive the matrix corollary.

Deliverables:
- One compiling Lean file with definitions and proved theorems.
- Clear module docstring explaining the finite information-geometry scope.
- No `sorry`, no truncated definitions, no unrelated imports beyond what is needed.

Important constraints:
- This is a FORMALIZATION task, not a speculative research theorem.
- Do not attempt Amari alpha-connections, Fisher-Rao manifolds, Hessians, or regularity hypotheses unless they are fully implemented and proved.
- Keep the development small, robust, and mathematically meaningful.

If there is time after the core file is complete, add a second tiny file with examples on a two-point sample space, but only if the core file is already solid.