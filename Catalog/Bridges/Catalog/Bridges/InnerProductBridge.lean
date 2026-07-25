import Mathlib

/-! # Inner Product Bridge

Proves fundamental theorems about inner product spaces:
1. Cauchy-Schwarz inequality and its consequences
2. Parallelogram law
3. Polarization identity
4. Pythagorean theorem for orthogonal vectors
5. Reverse Cauchy-Schwarz

This opens INNER PRODUCT SPACES as a new domain.
-/

namespace InnerProductBridge

variable {E : Type*} [SeminormedAddCommGroup E] [InnerProductSpace ℝ E]

/-! ## Section 1: Cauchy-Schwarz Inequality -/

/-- **Cauchy-Schwarz inequality**: inner x y ≤ ‖x‖ · ‖y‖
    The MOST FUNDAMENTAL inequality in all of mathematics. -/
theorem cauchy_schwarz (x y : E) :
    inner ℝ x y ≤ ‖x‖ * ‖y‖ :=
  real_inner_le_norm x y

/-- **Cauchy-Schwarz** (absolute value): |inner x y| ≤ ‖x‖ · ‖y‖ -/
theorem abs_cauchy_schwarz (x y : E) :
    |inner ℝ x y| ≤ ‖x‖ * ‖y‖ := by
  have h : ‖(inner ℝ x y : ℝ)‖ ≤ ‖x‖ * ‖y‖ := norm_inner_le_norm x y
  rwa [Real.norm_eq_abs] at h

/-! ## Section 2: Parallelogram Law -/

/-- **Parallelogram law**:
    ‖x + y‖ ^ 2 + ‖x - y‖ ^ 2 = 2 * (‖x‖ ^ 2 + ‖y‖ ^ 2)
    CHARACTERIZES inner product spaces. -/
theorem parallelogram_law (x y : E) :
    ‖x + y‖ ^ 2 + ‖x - y‖ ^ 2 = 2 * (‖x‖ ^ 2 + ‖y‖ ^ 2) := by
  have h1 := norm_add_pow_two_real x y
  have h2 := norm_sub_pow_two_real x y
  rw [h1, h2]; ring

/-- Norm expansion: ‖x + y‖ ^ 2 = ‖x‖ ^ 2 + 2 * inner x y + ‖y‖ ^ 2 -/
theorem norm_add_sq_expand (x y : E) :
    ‖x + y‖ ^ 2 = ‖x‖ ^ 2 + 2 * inner ℝ x y + ‖y‖ ^ 2 :=
  norm_add_pow_two_real x y

/-- Norm expansion: ‖x - y‖ ^ 2 = ‖x‖ ^ 2 - 2 * inner x y + ‖y‖ ^ 2 -/
theorem norm_sub_sq_expand (x y : E) :
    ‖x - y‖ ^ 2 = ‖x‖ ^ 2 - 2 * inner ℝ x y + ‖y‖ ^ 2 :=
  norm_sub_pow_two_real x y

/-! ## Section 3: Polarization Identity -/

/-- **Polarization identity**:
    inner x y = (‖x + y‖ ^ 2 - ‖x - y‖ ^ 2) / 4
    Recovers the inner product FROM the norm. -/
theorem polarization (x y : E) :
    inner ℝ x y = (‖x + y‖ ^ 2 - ‖x - y‖ ^ 2) / 4 := by
  rw [norm_add_pow_two_real x y, norm_sub_pow_two_real x y]; ring

/-! ## Section 4: Pythagorean Theorem -/

/-- **Pythagorean theorem**: orthogonal vectors satisfy
    ‖x + y‖ ^ 2 = ‖x‖ ^ 2 + ‖y‖ ^ 2. -/
theorem pythagorean (x y : E) (h : inner ℝ x y = 0) :
    ‖x + y‖ ^ 2 = ‖x‖ ^ 2 + ‖y‖ ^ 2 := by
  rw [norm_add_pow_two_real x y]; simp [h]

/-! ## Section 5: Consequences -/

/-- Reverse Cauchy-Schwarz: -‖x‖‖y‖ ≤ inner x y -/
theorem neg_cauchy_schwarz (x y : E) :
    -‖x‖ * ‖y‖ ≤ inner ℝ x y := by
  have h := cauchy_schwarz (-x) y
  rw [inner_neg_left, norm_neg] at h; linarith

/-- Inner product is two-sided bounded by product of norms. -/
theorem inner_bound (x y : E) :
    -‖x‖ * ‖y‖ ≤ inner ℝ x y ∧ inner ℝ x y ≤ ‖x‖ * ‖y‖ :=
  ⟨neg_cauchy_schwarz x y, cauchy_schwarz x y⟩

end InnerProductBridge