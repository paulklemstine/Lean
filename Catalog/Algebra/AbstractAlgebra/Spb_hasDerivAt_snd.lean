import Mathlib

/-! # CatalogBuild.Shared.Spb_hasDerivAt_snd

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 8

Repaired: `spb`, its two identity lemmas and the tangent-addition bridge
`tan_add_eq_spb` (all used but never declared) are supplied here, and the
declarations are in dependency order.
-/

noncomputable section

open Real

/-- The SPB (Stereographic Projection Bridge) operation. -/
def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- Zero is a left identity for SPB. -/
theorem spb_zero_left (x : ℝ) : spb 0 x = x := by simp [spb]

/-- Zero is a right identity for SPB. -/
theorem spb_zero_right (x : ℝ) : spb x 0 = x := by simp [spb]

/-- The tangent addition formula, in SPB form. -/
theorem tan_add_eq_spb (a b : ℝ) (ha : cos a ≠ 0) (hb : cos b ≠ 0) :
    tan (a + b) = spb (tan a) (tan b) := by
  rw [spb, Real.tan_add' ⟨Real.cos_ne_zero_iff.mp ha, Real.cos_ne_zero_iff.mp hb⟩]

theorem spb_hasDerivAt_snd (x y : ℝ) (h : 1 - x * y ≠ 0) :
    HasDerivAt (fun y' => spb x y') ((1 + x ^ 2) / (1 - x * y) ^ 2) y := by
  unfold spb
  convert HasDerivAt.div (HasDerivAt.add (hasDerivAt_const _ _) (hasDerivAt_id y))
    (HasDerivAt.sub (hasDerivAt_const _ _)
      (HasDerivAt.mul (hasDerivAt_const _ _) (hasDerivAt_id y))) h using 1
  norm_num; ring

/-- spb(1, 0) = 1 (identity). -/
theorem spb_tower_1_0 : spb 1 0 = 1 := spb_zero_right 1

theorem spb_hasDerivAt_fst (x y : ℝ) (h : 1 - x * y ≠ 0) :
    HasDerivAt (fun x' => spb x' y) ((1 + y ^ 2) / (1 - x * y) ^ 2) x := by
  unfold spb
  convert HasDerivAt.div (HasDerivAt.add (hasDerivAt_id x) (hasDerivAt_const _ _))
    (HasDerivAt.sub (hasDerivAt_const _ _) (hasDerivAt_mul_const y)) h using 1; ring
  norm_num; ring

/-- SPB with 1: spb(x, 1) = (x+1)/(1-x). -/
theorem spb_one (x : ℝ) : spb x 1 = (x + 1) / (1 - x) := by
  simp [spb, mul_one]

/-- spb(0, 1) = 1. -/
theorem spb_tower_0_1 : spb 0 1 = 1 := spb_zero_left 1

/-- Similarly for the second argument. -/
theorem spb_deriv_snd_pos (x : ℝ) (d : ℝ) (hd : d ≠ 0) :
    (1 + x ^ 2) / d ^ 2 > 0 := by
  apply div_pos
  · linarith [sq_nonneg x]
  · positivity

/-- The double-angle connection: spb(tan θ, tan θ) = tan(2θ). -/
theorem spb_tan_double (t : ℝ) (hc : Real.cos t ≠ 0) :
    spb (Real.tan t) (Real.tan t) = Real.tan (2 * t) := by
  rw [show 2 * t = t + t from by ring]
  exact (tan_add_eq_spb t t hc hc).symm

/-- The partial derivative ∂spb/∂x = (1+y²)/(1-xy)² is always positive
when 1-xy ≠ 0, showing SPB is strictly monotone in each argument. -/
theorem spb_deriv_fst_pos (y : ℝ) (d : ℝ) (hd : d ≠ 0) :
    (1 + y ^ 2) / d ^ 2 > 0 := by
  apply div_pos
  · linarith [sq_nonneg y]
  · positivity

end