import Mathlib

/-!
# Advanced SPB Theorems

New results from the SPB research program:

1. **Sub-luminal closure**: explicit bound on composed velocities
2. **SPB fixed point theorem**: characterizing fixed points of spb(·, a)
3. **SPB and the Möbius group**
4. **Arctangent addition formula**
5. **Algebraic identities**
-/

noncomputable section

open Real

/-! ## Core Definitions -/

def spb_adv (x y : ℝ) : ℝ := (x + y) / (1 - x * y)
def spbH_adv (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-! ## Sub-luminal Closure with Explicit Bound -/

/-
The denominator 1 + v₁v₂ > 0 when both velocities are sub-luminal.
-/
theorem spbH_denom_pos (v₁ v₂ : ℝ) (h1 : |v₁| < 1) (h2 : |v₂| < 1) :
    1 + v₁ * v₂ > 0 := by
  nlinarith [ abs_lt.mp h1, abs_lt.mp h2 ]

/-
If v₁, v₂ ∈ (-1,1), then |spbH(v₁,v₂)| < 1.
-/
theorem spbH_subluminal (v₁ v₂ : ℝ) (h1 : |v₁| < 1) (h2 : |v₂| < 1) :
    |spbH_adv v₁ v₂| < 1 := by
  exact abs_lt.mpr ⟨ by rw [ spbH_adv ] ; rw [ lt_div_iff₀ ] <;> cases abs_cases v₁ <;> cases abs_cases v₂ <;> push_cast [ * ] at * <;> nlinarith, by rw [ spbH_adv ] ; rw [ div_lt_iff₀ ] <;> cases abs_cases v₁ <;> cases abs_cases v₂ <;> push_cast [ * ] at * <;> nlinarith ⟩

/-- Speed of light invariance: spbH(1, v) = 1 when 1 + v ≠ 0. -/
theorem spbH_light_invariance (v : ℝ) (hv : 1 + v ≠ 0) :
    spbH_adv 1 v = 1 := by
  simp only [spbH_adv]
  have h : 1 + 1 * v = 1 + v := by ring
  rw [h]; linarith [div_self hv]

/-! ## SPB Fixed Points -/

/-
When a ≠ 0, there are no real fixed points of x ↦ spb(x, a).
-/
theorem spb_no_real_fixed_point (a x : ℝ) (ha : a ≠ 0) (hd : 1 - x * a ≠ 0) :
    spb_adv x a ≠ x := by
  unfold spb_adv;
  cases lt_or_gt_of_ne ha <;> cases lt_or_gt_of_ne hd <;> rw [ Ne, div_eq_iff hd ] <;> nlinarith [ sq_nonneg x ]

/-- When a = 0, every point is a fixed point. -/
theorem spb_fixed_trivial (x : ℝ) : spb_adv x 0 = x := by
  simp [spb_adv]

/-! ## SPB Generates Möbius Group -/

/-- For fixed a, the map x ↦ spb(x, a) is a Möbius transformation. -/
theorem spb_as_mobius (a x : ℝ) :
    spb_adv x a = (1 * x + a) / ((-a) * x + 1) := by
  simp [spb_adv]; ring

/-! ## SPB and Arctangent -/

/-
arctan(spb(x,y)) = arctan(x) + arctan(y), when 1 - xy > 0.
-/
theorem arctan_spb (x y : ℝ) (h : 1 - x * y > 0) :
    arctan (spb_adv x y) = arctan x + arctan y := by
  grind +suggestions

/-! ## SPB Monotonicity -/

/-- The partial derivative (1+y²)/(1-xy)² is always positive. -/
theorem spb_deriv_pos (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 + y ^ 2) / (1 - x * y) ^ 2 > 0 := by
  apply div_pos
  · linarith [sq_nonneg y]
  · positivity

/-! ## Double Angle Formulas -/

/-- spb(x, x) = 2x/(1-x²). -/
theorem spb_self_eq (x : ℝ) : spb_adv x x = 2 * x / (1 - x * x) := by
  unfold spb_adv; ring

/-- spbH(x, x) = 2x/(1+x²). -/
theorem spbH_self_eq (x : ℝ) : spbH_adv x x = 2 * x / (1 + x * x) := by
  unfold spbH_adv; ring

/-! ## Algebraic Identities -/

/-
SPB product rule: spb(x,y) · spb(x,-y) = (x² - y²)/(1 - x²y²).
-/
theorem spb_product_identity (x y : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 + x * y ≠ 0) :
    spb_adv x y * spb_adv x (-y) = (x ^ 2 - y ^ 2) / (1 - x ^ 2 * y ^ 2) := by
  unfold spb_adv; rw [ div_mul_div_comm ] ; ring;

/-
SPB difference identity: spb(x,y) - spb(x,-y).
-/
theorem spb_difference_identity (x y : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 + x * y ≠ 0) :
    spb_adv x y - spb_adv x (-y) = 2 * y * (1 + x ^ 2) / (1 - x ^ 2 * y ^ 2) := by
  unfold spb_adv;
  grind

end