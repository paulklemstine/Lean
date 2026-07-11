import Mathlib

/-!
# Microscopic weightings of finite metric spaces

In Leinster's magnitude theory a **weighting** of a finite metric space with
similarity matrix `Z_t` (entries `exp(-t·d(x_i,x_j))`) is a vector `w` with
`Z_t w = 𝟙`. As the scale `t → 0` one has `Z_t = J - t·D + O(t²)` with `J` the
all-ones matrix and `D` the **distance matrix**; a first-order analysis of
`Z_t w_t = 𝟙` shows the limiting ("microscopic") weighting `μ` satisfies

  `D μ = λ·𝟙`   and   `Σ μ = 1`

for a scalar `λ`. This file develops the elementary theory of such
*distance-matrix weightings*: the constant `λ` is well defined for symmetric `D`,
the weighting is unique when `D` is invertible, and it exists (via `D⁻¹`).

The heuristic of the research theme — that the microscopic weighting emphasises
boundary points, giving positive weight to vertices of the convex hull and
non-positive weight to interior points — is made concrete in `Examples.lean`.
-/

namespace MicroWeighting

open Matrix BigOperators

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- `w` is a *microscopic weighting* for the distance matrix `D` with constant
`lam` if `D *ᵥ w` is the constant vector `lam` and the entries of `w` sum to `1`.
This is the leading-order (`t → 0`) form of a magnitude weighting. -/
def IsMicroWeighting (D : Matrix n n ℝ) (w : n → ℝ) (lam : ℝ) : Prop :=
  D *ᵥ w = (fun _ => lam) ∧ ∑ i, w i = 1

omit [DecidableEq n] in
/-- For a **symmetric** distance matrix the constant `λ` is independent of the
chosen weighting: any two microscopic weightings share the same constant.
This is the microscopic analogue of the well-definedness of magnitude. -/
theorem microConstant_unique {D : Matrix n n ℝ} (hD : Dᵀ = D)
    {w w' : n → ℝ} {a b : ℝ}
    (hw : IsMicroWeighting D w a) (hw' : IsMicroWeighting D w' b) :
    a = b := by
  obtain ⟨hDw, hsum⟩ := hw
  obtain ⟨hDw', hsum'⟩ := hw'
  -- `w ⬝ᵥ (D w') = b·Σw = b`, and by symmetry it also `= (D w) ⬝ᵥ w' = a·Σw' = a`.
  have key : w ⬝ᵥ (D *ᵥ w') = (D *ᵥ w) ⬝ᵥ w' := by
    rw [dotProduct_mulVec, ← Matrix.mulVec_transpose, hD]
  rw [hDw, hDw'] at key
  simp only [dotProduct] at key
  -- reduce both sides using the sums
  have lhs : ∑ i, w i * b = b := by
    rw [← Finset.sum_mul, hsum, one_mul]
  have rhs : ∑ i, a * w' i = a := by
    rw [← Finset.mul_sum, hsum', mul_one]
  -- `key : ∑ i, w i * (D w')ᵢ = ∑ i, (D w)ᵢ * w' i`; rewrite via the constants
  have hba : ∑ i, w i * b = ∑ i, a * w' i := by simpa [mul_comm] using key
  rw [lhs, rhs] at hba
  exact hba.symm

/-- If `D` is invertible then a microscopic weighting is unique. -/
theorem microWeighting_unique {D : Matrix n n ℝ} (hDsymm : Dᵀ = D)
    (hDinv : IsUnit D.det) {w w' : n → ℝ} {a b : ℝ}
    (hw : IsMicroWeighting D w a) (hw' : IsMicroWeighting D w' b) :
    w = w' := by
  have hab : a = b := microConstant_unique hDsymm hw hw'
  subst hab
  have h : D *ᵥ w = D *ᵥ w' := by rw [hw.1, hw'.1]
  -- multiply on the left by `D⁻¹`
  have := congrArg (fun v => D⁻¹ *ᵥ v) h
  simpa [Matrix.mulVec_mulVec, Matrix.nonsing_inv_mul _ hDinv,
    Matrix.one_mulVec] using this

/-- Existence: if `D` is invertible and the coordinates of `D⁻¹𝟙` sum to a
nonzero value `s`, then `s⁻¹ • (D⁻¹𝟙)` is a microscopic weighting with constant
`s⁻¹`. Concretely `μ = D⁻¹𝟙 / (𝟙ᵀ D⁻¹𝟙)`. -/
theorem microWeighting_exists {D : Matrix n n ℝ} (hDinv : IsUnit D.det)
    (s : ℝ) (hs : s = ∑ i, (D⁻¹ *ᵥ (fun _ => (1:ℝ))) i) (hs0 : s ≠ 0) :
    IsMicroWeighting D (s⁻¹ • (D⁻¹ *ᵥ (fun _ => (1:ℝ)))) s⁻¹ := by
  constructor
  · rw [Matrix.mulVec_smul, Matrix.mulVec_mulVec, Matrix.mul_nonsing_inv _ hDinv,
      Matrix.one_mulVec]
    funext i
    simp [Pi.smul_apply, smul_eq_mul, mul_one]
  · simp only [Pi.smul_apply, smul_eq_mul]
    rw [← Finset.mul_sum, ← hs, inv_mul_cancel₀ hs0]

omit [DecidableEq n] in
/-- **The microscopic constant is the quadratic energy of the weighting.**
For any microscopic weighting `w` with constant `lam`, one has
`lam = w ⬝ᵥ (D *ᵥ w)`. Combined with `microConstant_unique`, this shows the
energy `w ⬝ᵥ (D w)` is an invariant of a symmetric distance matrix, independent
of the chosen weighting. -/
theorem microConstant_eq_energy {D : Matrix n n ℝ} {w : n → ℝ} {lam : ℝ}
    (hw : IsMicroWeighting D w lam) : lam = w ⬝ᵥ (D *ᵥ w) := by
  obtain ⟨hDw, hsum⟩ := hw
  rw [hDw]
  simp only [dotProduct]
  rw [show (∑ i, w i * lam) = (∑ i, w i) * lam from by rw [Finset.sum_mul],
    hsum, one_mul]

end MicroWeighting