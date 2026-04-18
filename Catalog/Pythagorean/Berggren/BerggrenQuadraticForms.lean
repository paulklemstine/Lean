/-
# Berggren and Quadratic Forms (V15 - Direction 84 NEW)

The Lorentz form Q = diag(1,1,-1) connects to quadratic form theory.

Machine-verified in Lean 4 with Mathlib.
-/
import Mathlib

open Matrix

/-! ## Section 1: The Lorentz Quadratic Form -/

def lorentzForm (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2

theorem ppt_iff_lorentz_zero (a b c : ℤ) :
    a ^ 2 + b ^ 2 = c ^ 2 ↔ lorentzForm a b c = 0 := by
  simp [lorentzForm]; omega

theorem lorentzForm_positive : lorentzForm 1 0 0 = 1 := by simp [lorentzForm]
theorem lorentzForm_negative : lorentzForm 0 0 1 = -1 := by simp [lorentzForm]

theorem lorentz_discriminant :
    det (!![1, 0, 0; 0, 1, 0; 0, 0, (-1 : ℤ)]) = -1 := by native_decide

/-! ## Section 2: Berggren Steps Preserve Q -/

theorem stepA_preserves_form (a b c : ℤ) :
    lorentzForm (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c) = lorentzForm a b c := by
  simp only [lorentzForm]; ring

theorem stepB_preserves_form (a b c : ℤ) :
    lorentzForm (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) = lorentzForm a b c := by
  simp only [lorentzForm]; ring

theorem stepC_preserves_form (a b c : ℤ) :
    lorentzForm (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c) = lorentzForm a b c := by
  simp only [lorentzForm]; ring

/-! ## Section 3: The Norm Form -/

def normForm (a b : ℤ) : ℤ := a ^ 2 + b ^ 2

theorem normForm_nonneg (a b : ℤ) : 0 ≤ normForm a b := by
  simp [normForm]; positivity

theorem normForm_mul (a b c d : ℤ) :
    normForm a b * normForm c d = normForm (a*c - b*d) (a*d + b*c) := by
  simp [normForm]; ring

theorem ppt_iff_norm_square (a b c : ℤ) :
    a ^ 2 + b ^ 2 = c ^ 2 ↔ normForm a b = c ^ 2 := by simp [normForm]

/-! ## Section 4: Parity Invariants -/

theorem ppt_a_mod4 (a : ℤ) (ha_odd : a % 2 = 1) :
    a % 4 = 1 ∨ a % 4 = 3 := by omega

/-! ## Section 5: The Deficit Invariant -/

def hypLegDiff (b c : ℤ) : ℤ := c - b

theorem root_deficit : hypLegDiff 4 5 = 1 := by simp [hypLegDiff]

theorem stepA_deficit (a b c : ℤ) :
    hypLegDiff (2*a - b + 2*c) (2*a - 2*b + 3*c) = c - b := by
  simp [hypLegDiff]; ring

theorem A_branch_deficit_invariant (a b c : ℤ) (h : hypLegDiff b c = 1) :
    hypLegDiff (2*a - b + 2*c) (2*a - 2*b + 3*c) = 1 := by
  simp [hypLegDiff] at *; linarith

theorem stepB_deficit (a b c : ℤ) :
    hypLegDiff (2*a + b + 2*c) (2*a + 2*b + 3*c) = c + b := by
  simp [hypLegDiff]; ring

theorem stepC_deficit (a b c : ℤ) :
    hypLegDiff (-2*a + b + 2*c) (-2*a + 2*b + 3*c) = c + b := by
  simp [hypLegDiff]; ring

/-! ## Section 6: Similarity Classes -/

def pptSimilar (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ) : Prop :=
  a₁ * b₂ = a₂ * b₁ ∧ a₁ * c₂ = a₂ * c₁

theorem pptSimilar_refl (a b c : ℤ) : pptSimilar a b c a b c := by simp [pptSimilar]

theorem root_not_similar_depth1A : ¬ pptSimilar 3 4 5 5 12 13 := by
  intro ⟨h1, _⟩; simp [pptSimilar] at h1

/-! ## Section 7: Perimeter -/

def perimeter (a b c : ℤ) : ℤ := a + b + c

theorem root_perimeter : perimeter 3 4 5 = 12 := by simp [perimeter]

theorem stepA_perimeter (a b c : ℤ) :
    perimeter (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c) = 5*a - 5*b + 7*c := by
  simp [perimeter]; ring

theorem stepB_perimeter (a b c : ℤ) :
    perimeter (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) = 5*a + 5*b + 7*c := by
  simp [perimeter]; ring

theorem stepC_perimeter (a b c : ℤ) :
    perimeter (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c) = -5*a + 5*b + 7*c := by
  simp [perimeter]; ring

theorem perimeter_growth_B (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    perimeter a b c < perimeter (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) := by
  unfold perimeter; linarith

/-! ## Section 8: Matrix Entries -/

theorem berggren_entries_bounded :
    ∀ i j : Fin 3,
    |(!![1, -2, 2; 2, -1, 2; 2, -2, 3] : Matrix (Fin 3) (Fin 3) ℤ) i j| ≤ 3 := by decide

/-! ## Section 9: Leg Difference and Sum Identities -/

/-- (a-b)² + 2ab = a² + b² = c² for PPTs -/
theorem ppt_leg_diff_identity (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (a - b)^2 + 2 * a * b = c^2 := by nlinarith

/-- (a+b)² - 2ab = a² + b² = c² for PPTs -/
theorem ppt_leg_sum_identity (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (a + b)^2 - 2 * a * b = c^2 := by nlinarith
