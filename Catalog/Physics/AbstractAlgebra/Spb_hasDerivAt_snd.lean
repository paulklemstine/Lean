import Mathlib

/-! # CatalogBuild.Shared.Spb_hasDerivAt_snd

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 8
-/

open Real

noncomputable section

/-- The SPB (Stereographic Projection Bridge) operation.
(Repaired: this definition, together with `spb_zero_left`, `spb_zero_right` and
`tan_add_eq_spb`, was missing from the auto-generated file.) -/
def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

theorem spb_zero_left (x : ℝ) : spb 0 x = x := by simp [spb]

theorem spb_zero_right (x : ℝ) : spb x 0 = x := by simp [spb]

/-- The tangent addition formula is exactly the SPB operation. -/
theorem tan_add_eq_spb (a b : ℝ) (ha : cos a ≠ 0) (hb : cos b ≠ 0) :
    tan (a + b) = spb (tan a) (tan b) := by
  have ta : tan a = sin a / cos a := Real.tan_eq_sin_div_cos a
  have tb : tan b = sin b / cos b := Real.tan_eq_sin_div_cos b
  have h1 : tan a + tan b = sin (a + b) / (cos a * cos b) := by
    rw [ta, tb, Real.sin_add]; field_simp
  have h2 : 1 - tan a * tan b = cos (a + b) / (cos a * cos b) := by
    rw [ta, tb, Real.cos_add]; field_simp
  rw [spb, h1, h2, div_div_div_cancel_right₀ (mul_ne_zero ha hb), Real.tan_eq_sin_div_cos]


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