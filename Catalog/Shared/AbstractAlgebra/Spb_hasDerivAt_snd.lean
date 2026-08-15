import Mathlib

/-! # CatalogBuild.Shared.Spb_hasDerivAt_snd

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 8
-/

noncomputable section

/-- The speed-addition law `spb x y = (x + y) / (1 - x y)`. -/
def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- [Section: # CatalogBuild.Shared.Spb_hasDerivAt_snd
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 9] -/
theorem spb_hasDerivAt_snd (x y : ℝ) (h : 1 - x * y ≠ 0) :
    HasDerivAt (fun y' => spb x y') ((1 + x ^ 2) / (1 - x * y) ^ 2) y := by
  unfold spb
  convert HasDerivAt.div ( HasDerivAt.add ( hasDerivAt_const _ _ ) ( hasDerivAt_id y ) ) ( HasDerivAt.sub ( hasDerivAt_const _ _ ) ( HasDerivAt.mul ( hasDerivAt_const _ _ ) ( hasDerivAt_id y ) ) ) h using 1;
  norm_num ; ring

/-- [Section: # CatalogBuild.Shared.Spb_hasDerivAt_snd
Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 8] -/
theorem spb_hasDerivAt_fst (x y : ℝ) (h : 1 - x * y ≠ 0) :
    HasDerivAt (fun x' => spb x' y) ((1 + y ^ 2) / (1 - x * y) ^ 2) x := by
  unfold spb
  convert HasDerivAt.div ( HasDerivAt.add ( hasDerivAt_id x ) ( hasDerivAt_const _ _ ) ) ( HasDerivAt.sub ( hasDerivAt_const _ _ ) ( hasDerivAt_mul_const y ) ) h using 1 ; ring;
  norm_num ; ring

/-- SPB with 1: spb(x, 1) = (x+1)/(1-x). -/
theorem spb_one (x : ℝ) (hx : x ≠ 1) : spb x 1 = (x + 1) / (1 - x) := by
  simp [spb, mul_one]

/-- Similarly for the second argument. -/
theorem spb_deriv_snd_pos (x : ℝ) (d : ℝ) (hd : d ≠ 0) :
    (1 + x ^ 2) / d ^ 2 > 0 := by
  apply div_pos
  · linarith [sq_nonneg x]
  · positivity

/-- The partial derivative ∂spb/∂x = (1+y²)/(1-xy)² is always positive
when 1-xy ≠ 0, showing SPB is strictly monotone in each argument. -/
theorem spb_deriv_fst_pos (y : ℝ) (d : ℝ) (hd : d ≠ 0) :
    (1 + y ^ 2) / d ^ 2 > 0 := by
  apply div_pos
  · linarith [sq_nonneg y]
  · positivity

/-- Zero is a left identity for SPB. -/
theorem spb_zero_left (x : ℝ) : spb 0 x = x := by simp [spb]

/-- Zero is a right identity for SPB. -/
theorem spb_zero_right (x : ℝ) : spb x 0 = x := by simp [spb]

/-- The tangent addition formula in SPB form. -/
theorem tan_add_eq_spb (x y : ℝ) (hx : Real.cos x ≠ 0) (hy : Real.cos y ≠ 0) :
    Real.tan (x + y) = spb (Real.tan x) (Real.tan y) := by
  have hd : 1 - Real.tan x * Real.tan y
      = (Real.cos x * Real.cos y - Real.sin x * Real.sin y) / (Real.cos x * Real.cos y) := by
    rw [Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
    field_simp
  by_cases h : Real.cos (x + y) = 0
  · have h0 : Real.cos x * Real.cos y - Real.sin x * Real.sin y = 0 := by
      rw [← Real.cos_add]; exact h
    unfold spb
    rw [hd, h0, zero_div, div_zero, Real.tan_eq_sin_div_cos, h, div_zero]
  · unfold spb
    rw [Real.tan_eq_sin_div_cos (x + y), Real.sin_add, Real.cos_add,
        Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
    rw [Real.cos_add] at h
    field_simp

/-- spb(1, 0) = 1 (identity). -/
theorem spb_tower_1_0 : spb 1 0 = 1 := spb_zero_right 1

/-- spb(0, 1) = 1. -/
theorem spb_tower_0_1 : spb 0 1 = 1 := spb_zero_left 1

/-- The double-angle connection: spb(tan θ, tan θ) = tan(2θ). -/
theorem spb_tan_double (θ : ℝ) (hc : Real.cos θ ≠ 0) :
    spb (Real.tan θ) (Real.tan θ) = Real.tan (2 * θ) := by
  rw [show 2 * θ = θ + θ from by ring]
  exact (tan_add_eq_spb θ θ hc hc).symm

end