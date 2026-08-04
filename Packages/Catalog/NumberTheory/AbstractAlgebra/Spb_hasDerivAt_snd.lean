import Mathlib

open Real


/-- The speed-addition law `spb x y = (x + y) / (1 - x y)` (supplied here: the catalog module
that originally provided it is not part of this repository). -/
noncomputable def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- Zero is a right identity for SPB. -/
theorem spb_zero_right (x : ℝ) : spb x 0 = x := by simp [spb]

/-- Zero is a left identity for SPB. -/
theorem spb_zero_left (x : ℝ) : spb 0 x = x := by simp [spb]

/-- The tangent addition law expressed through SPB. -/
theorem tan_add_eq_spb (a b : ℝ) (ha : Real.cos a ≠ 0) (hb : Real.cos b ≠ 0) :
    Real.tan (a + b) = spb (Real.tan a) (Real.tan b) := by
  unfold spb
  simp_all +decide [Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add]
  grind


/-! # CatalogBuild.Shared.Spb_hasDerivAt_snd

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 8
-/

noncomputable section

/-- [Section: # CatalogBuild.Shared.Spb_hasDerivAt_snd
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 9] -/
theorem spb_hasDerivAt_snd (x y : ℝ) (h : 1 - x * y ≠ 0) :
    HasDerivAt (fun y' => spb x y') ((1 + x ^ 2) / (1 - x * y) ^ 2) y := by
  unfold spb
  convert HasDerivAt.div ( HasDerivAt.add ( hasDerivAt_const _ _ ) ( hasDerivAt_id y ) ) ( HasDerivAt.sub ( hasDerivAt_const _ _ ) ( HasDerivAt.mul ( hasDerivAt_const _ _ ) ( hasDerivAt_id y ) ) ) h using 1;
  norm_num ; ring

/-- spb(1, 0) = 1 (identity). -/
theorem spb_tower_1_0 : spb 1 0 = 1 := spb_zero_right 1

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

/-- spb(0, 1) = 1. -/
theorem spb_tower_0_1 : spb 0 1 = 1 := spb_zero_left 1

/-- Similarly for the second argument. -/
theorem spb_deriv_snd_pos (x : ℝ) (d : ℝ) (hd : d ≠ 0) :
    (1 + x ^ 2) / d ^ 2 > 0 := by
  apply div_pos
  · linarith [sq_nonneg x]
  · positivity

/-- The double-angle connection: spb(tan θ, tan θ) = tan(2θ). -/
theorem spb_tan_double (θ : ℝ) (hc : Real.cos θ ≠ 0) :
    spb (Real.tan θ) (Real.tan θ) = Real.tan (2 * θ) := by
  rw [show 2 * θ = θ + θ from by ring]
  exact (tan_add_eq_spb θ θ hc hc).symm

/-- The partial derivative ∂spb/∂x = (1+y²)/(1-xy)² is always positive
when 1-xy ≠ 0, showing SPB is strictly monotone in each argument. -/
theorem spb_deriv_fst_pos (y : ℝ) (d : ℝ) (hd : d ≠ 0) :
    (1 + y ^ 2) / d ^ 2 > 0 := by
  apply div_pos
  · linarith [sq_nonneg y]
  · positivity

end