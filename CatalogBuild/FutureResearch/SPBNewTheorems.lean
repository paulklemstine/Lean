/-! # CatalogBuild.FutureResearch.SPBNewTheorems

Auto-generated from theorem catalog database.
Domain: FutureResearch
Declarations: 12
-/

import Mathlib

noncomputable section

theorem spb_neg_inv_auto (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) :
    spb (-1/x) (-1/y) = spb x y := by
  unfold spb; ring;
  grind

/-
Inversion is an anti-automorphism: spb(1/x, 1/y) = -spb(x, y).
-/

theorem spb_inv_anti (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) :
    spb (1/x) (1/y) = -spb x y := by
  unfold spb ; ring;
  grind

/-! ## Section 3: Cancellation Law -/

/-
Left cancellation: spb(spb(x, y), -y) = x.
-/

theorem spb_cancel (x y : ℝ) (h1 : 1 - x * y ≠ 0) :
    spb (spb x y) (-y) = x := by
  unfold SPBNew.spb;
  field_simp;
  rw [ div_eq_iff ] <;> cases lt_or_gt_of_ne h1 <;> nlinarith [ mul_self_nonneg y ]

/-! ## Section 4: No Fixed Points -/

/-
No fixed points: if a ≠ 0 and 1 - xa ≠ 0, then spb(x, a) ≠ x.
-/

theorem spb_norm_mult (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 + spb x y ^ 2) * (1 - x * y) ^ 2 = (1 + x ^ 2) * (1 + y ^ 2) := by
  unfold spb; field_simp; ring

/-! ## Section 6: Self-Composition Formulas -/

/-- spb(x, x) = 2x/(1-x²), the tangent double-angle formula. -/

theorem spb_conj_sum (x y : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 + x * y ≠ 0) :
    spb x y + spb x (-y) = 2 * x * (1 + y ^ 2) / ((1 - x * y) * (1 + x * y)) := by
  unfold spb
  have h3 : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
  rw [h3]; field_simp; ring

/-- spb(x, y) · spb(x, -y) = (x²-y²)/((1-xy)(1+xy)). -/

theorem spb_conj_prod (x y : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 + x * y ≠ 0) :
    spb x y * spb x (-y) = (x ^ 2 - y ^ 2) / ((1 - x * y) * (1 + x * y)) := by
  unfold spb
  have h3 : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
  rw [h3]; field_simp; ring

/-! ## Section 10: Einstein Velocity Bound -/

/-
If |u|, |v| < 1 then |spbH(u,v)| < 1.
-/

theorem einstein_velocity_bound (u v : ℝ) (hu : |u| < 1) (hv : |v| < 1) :
    |spbH u v| < 1 := by
  exact abs_lt.mpr ⟨ by rw [ spbH ] ; rw [ lt_div_iff₀ ] <;> cases abs_cases u <;> cases abs_cases v <;> nlinarith, by rw [ spbH ] ; rw [ div_lt_iff₀ ] <;> cases abs_cases u <;> cases abs_cases v <;> nlinarith ⟩

/-! ## Section 11: Tangent Addition Connection -/

/-- tan(α + β) = spb(tan α, tan β). -/

theorem cocycle_denom (x y z : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0) :
    (1 - x * y) * (1 - spb x y * z) = (1 - y * z) * (1 - x * spb y z) := by
  unfold spb; field_simp; ring

/-! ## Section 13: Derivative Positivity -/

/-- ∂spb/∂x = (1+y²)/(1-xy)² is always positive. -/

theorem spbIter_two (a : ℝ) : spbIter a 2 = 2 * a / (1 - a * a) := by
  simp [spbIter, spb]; ring

/-! ## Section 15: Cayley Transform -/

/-- The real Cayley transform: x ↦ ((1-x²)/(1+x²), 2x/(1+x²)). -/

def cayleyReal (x : ℝ) : ℝ × ℝ :=
  ((1 - x ^ 2) / (1 + x ^ 2), 2 * x / (1 + x ^ 2))

/-
The Cayley transform maps to the unit circle: the components square-sum to 1.
-/

theorem cayley_on_circle (x : ℝ) :
    (cayleyReal x).1 ^ 2 + (cayleyReal x).2 ^ 2 = 1 := by
  unfold cayleyReal; ring;
  -- Combine the fractions over a common denominator.
  field_simp
  ring

/-! ## Section 16: Double-Argument Functional Equation -/

/-- spb(x,x) · (1 - x²) = 2x (when we can clear the denominator). -/

theorem spb_double_clear (x : ℝ) (h : 1 - x ^ 2 ≠ 0) :
    spb x x * (1 - x ^ 2) = 2 * x := by
  have : spb x x = 2 * x / (1 - x ^ 2) := spb_double x
  rw [this, div_mul_cancel₀ _ h]


end
