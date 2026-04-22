import Mathlib

/-! # CatalogBuild.EML.AdvancedTheorems_2

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 13
-/

noncomputable section

/-- [Section: # CatalogBuild.EML.AdvancedTheorems_2
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 13] -/
def spb_adv (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- [Section: # CatalogBuild.EML.AdvancedTheorems_2
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 13] -/
def spbH_adv (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

theorem spbH_denom_pos (v₁ v₂ : ℝ) (h1 : |v₁| < 1) (h2 : |v₂| < 1) :
    1 + v₁ * v₂ > 0 := by
  nlinarith [ abs_lt.mp h1, abs_lt.mp h2 ]

theorem spbH_subluminal (v₁ v₂ : ℝ) (h1 : |v₁| < 1) (h2 : |v₂| < 1) :
    |spbH_adv v₁ v₂| < 1 := by
  exact abs_lt.mpr ⟨ by rw [ spbH_adv ] ; rw [ lt_div_iff₀ ] <;> cases abs_cases v₁ <;> cases abs_cases v₂ <;> push_cast [ * ] at * <;> nlinarith, by rw [ spbH_adv ] ; rw [ div_lt_iff₀ ] <;> cases abs_cases v₁ <;> cases abs_cases v₂ <;> push_cast [ * ] at * <;> nlinarith ⟩

/-- Speed of light invariance: spbH(1, v) = 1 when 1 + v ≠ 0. -/
theorem spbH_light_invariance (v : ℝ) (hv : 1 + v ≠ 0) :
    spbH_adv 1 v = 1 := by
  simp only [spbH_adv]
  have h : 1 + 1 * v = 1 + v := by ring
  rw [h]; linarith [div_self hv]

/-- When a = 0, every point is a fixed point. -/
theorem spb_fixed_trivial (x : ℝ) : spb_adv x 0 = x := by
  simp [spb_adv]

/-- For fixed a, the map x ↦ spb(x, a) is a Möbius transformation. -/
theorem spb_as_mobius (a x : ℝ) :
    spb_adv x a = (1 * x + a) / ((-a) * x + 1) := by
  simp [spb_adv]; ring

theorem arctan_spb (x y : ℝ) (h : 1 - x * y > 0) :
    arctan (spb_adv x y) = arctan x + arctan y := by
  grind +suggestions

/-- The partial derivative (1+y²)/(1-xy)² is always positive. -/
theorem spb_deriv_pos (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 + y ^ 2) / (1 - x * y) ^ 2 > 0 := by
  apply div_pos
  · linarith [sq_nonneg y]
  · positivity

/-- spb(x, x) = 2x/(1-x²). -/
theorem spb_self_eq (x : ℝ) : spb_adv x x = 2 * x / (1 - x * x) := by
  unfold spb_adv; ring

/-- spbH(x, x) = 2x/(1+x²). -/
theorem spbH_self_eq (x : ℝ) : spbH_adv x x = 2 * x / (1 + x * x) := by
  unfold spbH_adv; ring

theorem spb_product_identity (x y : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 + x * y ≠ 0) :
    spb_adv x y * spb_adv x (-y) = (x ^ 2 - y ^ 2) / (1 - x ^ 2 * y ^ 2) := by
  unfold spb_adv; rw [ div_mul_div_comm ] ; ring;

theorem spb_difference_identity (x y : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 + x * y ≠ 0) :
    spb_adv x y - spb_adv x (-y) = 2 * y * (1 + x ^ 2) / (1 - x ^ 2 * y ^ 2) := by
  unfold spb_adv;
  grind

end
