/-
# OISCC V9.1: The Diagonal Map d(x) = exp(x) - ln(x)
-/

import Mathlib

noncomputable section

open Real Filter Topology Set

/-- The diagonal map d(x) = exp(x) - ln(x). -/
def diagMap (x : ℝ) : ℝ := Real.exp x - Real.log x

/-- d(x) > x for all x > 0. -/
theorem diagMap_gt_id (x : ℝ) (hx : 0 < x) : diagMap x > x := by
  unfold diagMap
  have hexp : Real.exp x ≥ 1 + x + x ^ 2 / 2 := quadratic_le_exp_of_nonneg hx.le
  have hlog : Real.log x ≤ x - 1 := Real.log_le_sub_one_of_pos hx
  nlinarith [sq_nonneg x]

/-- d(x) ≥ 2 for all x > 0. -/
theorem diagMap_ge_two (x : ℝ) (hx : 0 < x) : diagMap x ≥ 2 := by
  unfold diagMap
  linarith [Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx]

/-- The diagonal map has no fixed points on ℝ₊. -/
theorem diagMap_no_fixed_point (x : ℝ) (hx : 0 < x) : diagMap x ≠ x :=
  ne_of_gt (diagMap_gt_id x hx)

/-- d(1) = e. -/
theorem diagMap_one : diagMap 1 = Real.exp 1 := by
  simp [diagMap, Real.log_one]

/-- d(x) is positive for all x > 0. -/
theorem diagMap_pos (x : ℝ) (hx : 0 < x) : 0 < diagMap x := by
  linarith [diagMap_ge_two x hx]

/-- The diagonal map is differentiable on ℝ₊. -/
theorem diagMap_differentiableAt (x : ℝ) (hx : 0 < x) :
    DifferentiableAt ℝ diagMap x :=
  (Real.differentiableAt_exp.sub (Real.differentiableAt_log hx.ne'))

/-- d'(x) = exp(x) - 1/x. -/
theorem diagMap_hasDerivAt (x : ℝ) (hx : 0 < x) :
    HasDerivAt diagMap (Real.exp x - x⁻¹) x := by
  exact (Real.hasDerivAt_exp x).sub (Real.hasDerivAt_log hx.ne')

/-- Iterated diagonal map. -/
def diagIter : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => diagMap (diagIter n x)

/-
diagIter (n+1) x > diagIter n x for x > 0.
-/
theorem diagIter_strictly_increasing (n : ℕ) (x : ℝ) (hx : 0 < x) :
    diagIter (n + 1) x > diagIter n x := by
  -- By induction on $n$, we can show that $diagIter n x > 0$ for all $n$.
  have h_diagIter_pos : ∀ n, 0 < diagIter n x := by
    -- We proceed by induction on $n$.
    intro n
    induction' n with n ih;
    · exact hx;
    · exact diagMap_pos _ ih;
  exact diagMap_gt_id _ ( h_diagIter_pos _ )

/-- d is strictly convex on (0, ∞). -/
theorem diagMap_convex : ConvexOn ℝ (Set.Ioi 0) diagMap := by
  sorry

end