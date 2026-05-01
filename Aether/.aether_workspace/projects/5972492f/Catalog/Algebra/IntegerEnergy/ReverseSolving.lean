import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.ReverseSolving

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 22
-/

/-- The three Berggren matrices as functions on ℤ³. -/
def berggrenB1 (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- [Section: ## Part I: Berggren Matrices and Inverse Transforms] -/
def berggrenB2 (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggrenB3 (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- A Pythagorean triple is (a, b, c) with a² + b² = c². -/
def IsPythTriple' (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- [Section: ## Part IV: Universal Parent Hypotenuse Formula] -/
theorem universal_parent_hyp_B1 (a b c : ℤ) :
    (invB1 a b c).2.2 = 3*c - 2*a - 2*b := by unfold invB1; ring

theorem universal_parent_hyp_B2 (a b c : ℤ) :
    (invB2 a b c).2.2 = 3*c - 2*a - 2*b := by unfold invB2; ring

theorem universal_parent_hyp_B3 (a b c : ℤ) :
    (invB3 a b c).2.2 = 3*c - 2*a - 2*b := by unfold invB3; ring

/-- For a PPT with positive legs, a + b > c. -/
theorem ppt_sum_gt_hyp (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : IsPythTriple' a b c) : a + b > c := by
  unfold IsPythTriple' at hpyth
  nlinarith [sq_nonneg (a - b), sq_nonneg a, sq_nonneg b, sq_abs (a + b)]

/-- Hypotenuse decreases during descent. -/
theorem descent_hyp_decreases (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : IsPythTriple' a b c) :
    3 * c - 2 * (a + b) < c := by
  have := ppt_sum_gt_hyp a b c ha hb hpyth
  linarith

/-- Any fixed point of B₂ has a = b. -/
theorem B2_fixed_point_ab_eq (a b c : ℤ)
    (h1 : a + 2*b + 2*c = a)
    (h2 : 2*a + b + 2*c = b) :
    a = b := by linarith

/-- For B₂, the fixed-point system reduces: a = b and b + c = 0. -/
theorem B2_fixed_point_system (a b c : ℤ)
    (h1 : a + 2*b + 2*c = a)
    (h2 : 2*a + b + 2*c = b)
    (_h3 : 2*a + 2*b + 3*c = c) :
    a = b ∧ b + c = 0 := ⟨by linarith, by linarith⟩

/-- The only integer fixed point of B₂ is (0, 0, 0). -/
theorem B2_fixed_point_trivial (a b c : ℤ)
    (h1 : a + 2*b + 2*c = a)
    (h2 : 2*a + b + 2*c = b)
    (h3 : 2*a + 2*b + 3*c = c) :
    a = 0 ∧ b = 0 ∧ c = 0 := by
  have hab : a = b := by linarith
  have hbc : b + c = 0 := by linarith
  have hb : b = 0 := by nlinarith
  exact ⟨by linarith, hb, by linarith⟩

/-- Fixed points of B₂² also satisfy a = b. -/
theorem B2sq_fixed_point_ab_eq (a b c : ℤ)
    (h1 : 9*a + 16*b + 18*c = a)
    (h2 : 16*a + 9*b + 18*c = b) :
    a = b := by linarith

/-- [Section: ## Part VII: Fixed Points of B₂²] -/
theorem B2sq_fixed_point_trivial (a b c : ℤ)
    (h1 : 9*a + 16*b + 18*c = a)
    (h2 : 16*a + 9*b + 18*c = b)
    (h3 : 18*a + 18*b + 21*c = c) :
    a = 0 ∧ b = 0 ∧ c = 0 := by
  omega

/-- The branch discriminant for B₁⁻¹. -/
theorem branch1_discriminant (a b c : ℤ) :
    (invB1 a b c).2.1 = 2*c - 2*a - b := by unfold invB1; ring

/-- The branch discriminant for B₂⁻¹. -/
theorem branch2_discriminant (a b c : ℤ) :
    (invB2 a b c).2.1 = 2*a + b - 2*c := by unfold invB2; ring

/-- B₁⁻¹ and B₂⁻¹ second components are negations. -/
theorem branch12_exclusive (a b c : ℤ) :
    (invB1 a b c).2.1 + (invB2 a b c).2.1 = 0 := by unfold invB1 invB2; ring

/-- The first components of B₁⁻¹ and B₂⁻¹ are identical. -/
theorem branch12_first_eq (a b c : ℤ) :
    (invB1 a b c).1 = (invB2 a b c).1 := by unfold invB1 invB2; ring

/-- The sign of (2a + b - 2c) determines the branch choice. -/
theorem branch_choice_criterion (a b c : ℤ) (hne : 2*a + b ≠ 2*c) :
    (0 < 2*a + b - 2*c) ∨ (0 < 2*c - 2*a - b) := by omega

/-- B₁ ∘ B₁⁻¹ = Id -/
theorem B1_comp_invB1 (a b c : ℤ) :
    berggrenB1 (invB1 a b c).1 (invB1 a b c).2.1 (invB1 a b c).2.2 = (a, b, c) := by
  unfold berggrenB1 invB1; simp; exact ⟨by ring, by ring, by ring⟩

/-- B₂ ∘ B₂⁻¹ = Id -/
theorem B2_comp_invB2 (a b c : ℤ) :
    berggrenB2 (invB2 a b c).1 (invB2 a b c).2.1 (invB2 a b c).2.2 = (a, b, c) := by
  unfold berggrenB2 invB2; simp; exact ⟨by ring, by ring, by ring⟩

/-- B₃ ∘ B₃⁻¹ = Id -/
theorem B3_comp_invB3 (a b c : ℤ) :
    berggrenB3 (invB3 a b c).1 (invB3 a b c).2.1 (invB3 a b c).2.2 = (a, b, c) := by
  unfold berggrenB3 invB3; simp; exact ⟨by ring, by ring, by ring⟩