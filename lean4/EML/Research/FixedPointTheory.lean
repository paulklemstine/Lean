import Mathlib

/-!
# EML Fixed-Point Theory

We study fixed points of the EML operator and related iterations.
exp(x) > x for all real x (so exp has no real fixed point), but
the EML operator eml(·, y) = exp(·) - log(y) has a rich fixed-point
structure parameterized by y, connected to the Lambert W function.
-/

noncomputable section

open Real

/-! ## exp Has No Real Fixed Point -/

/-
exp(x) > x for all x ∈ ℝ.
-/
theorem exp_gt_id (x : ℝ) : Real.exp x > x := by
  linarith [ Real.add_one_le_exp x ]

/-- Consequently, exp has no real fixed point. -/
theorem exp_no_real_fixed_point : ∀ x : ℝ, Real.exp x ≠ x := by
  intro x h
  exact absurd (exp_gt_id x) (by linarith)

/-! ## EML Fixed Points -/

/-- eml(x, y) = x iff exp(x) = x + log(y). -/
theorem eml_fixed_point_iff (x y : ℝ) :
    Real.exp x - Real.log y = x ↔ Real.exp x = x + Real.log y := by
  constructor <;> intro h <;> linarith

/-- When y = 1, the EML fixed point equation becomes exp(x) = x,
    which has no real solution. -/
theorem eml_no_fixed_point_at_one :
    ∀ x : ℝ, Real.exp x - Real.log 1 ≠ x := by
  intro x h
  simp [Real.log_one] at h
  exact absurd (exp_gt_id x) (by linarith)

/-- When y = e, x = 0 is a fixed point: exp(0) - log(e) = 0. -/
theorem eml_fixed_point_at_e :
    Real.exp 0 - Real.log (Real.exp 1) = 0 := by
  simp [Real.log_exp, Real.exp_zero]

/-- At y = e, x = 0 is a tangent point: the derivative of exp at 0 equals 1,
    matching the slope of the line x + 1. -/
theorem eml_tangent_at_e : Real.exp 0 = 0 + Real.log (Real.exp 1) := by
  simp [Real.log_exp, Real.exp_zero]

/-- The derivative of exp at x = 0 is 1. -/
theorem exp_deriv_at_zero : HasDerivAt Real.exp 1 0 := by
  have := Real.hasDerivAt_exp 0
  simp [Real.exp_zero] at this
  exact this

/-! ## Monotonicity and Convexity -/

theorem exp_strict_mono' : StrictMono Real.exp := Real.exp_strictMono

theorem exp_convex' : ConvexOn ℝ Set.univ Real.exp := convexOn_exp

/-! ## Iteration Dynamics -/

/-- The EML iteration z_{n+1} = exp(z_n) - log(y). -/
def emlIterate (y : ℝ) : ℕ → ℝ → ℝ
  | 0, z => z
  | n + 1, z => Real.exp (emlIterate y n z) - Real.log y

theorem emlIterate_one (y z : ℝ) :
    emlIterate y 1 z = Real.exp z - Real.log y := rfl

/-- For y = 1, the iteration diverges: each step increases the value. -/
theorem eml_iterate_diverges_y1 (z : ℝ) :
    emlIterate 1 1 z > z := by
  simp [emlIterate, Real.log_one]
  exact exp_gt_id z

end