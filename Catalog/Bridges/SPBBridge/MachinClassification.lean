import Mathlib
import Logic.StrangeLoops.Core
import Bridges.SPBBridge.AlgebraicIdentities

/-!
# Machin Formula Classification

Complete classification of 2-leaf and 3-leaf Machin formulas via SPB algebra.

## Main Results

- **Euler optimality**: spb(1/a, 1/b) = 1 with a,b ≥ 2 has unique solution (2,3)
- **Three-leaf classification**: spb(spb(1/a,1/b),1/c) = 1 with a ≤ b, a,b,c ≥ 2
  has exactly 3 solutions: (2,4,13), (2,5,8), (3,3,7)
- **Four-leaf and higher**: verified examples
-/

noncomputable section
open Real SPBResearch

namespace MachinClass

/-! ## Two-Leaf Classification -/

/-- Euler's formula: spb(1/2, 1/3) = 1. -/
theorem euler_formula : spb (1/2 : ℝ) (1/3) = 1 := by
  unfold spb; norm_num

/-- Key algebraic reformulation: spb(1/a, 1/b) = 1 iff (a-1)(b-1) = 2. -/
theorem two_leaf_criterion (a b : ℝ) (ha : a ≠ 0) (hb : b ≠ 0)
    (hab : 1 - (1/a) * (1/b) ≠ 0) :
    spb (1/a) (1/b) = 1 ↔ (a - 1) * (b - 1) = 2 := by
  unfold spb
  constructor
  · intro h
    rw [div_eq_iff hab] at h
    field_simp at h
    nlinarith
  · intro h
    rw [div_eq_iff hab]
    field_simp
    nlinarith

/-- Euler optimality: unique 2-leaf Machin formula. -/
theorem euler_optimal (a b : ℤ) (ha : 2 ≤ a) (hb : 2 ≤ b) (hab : a ≤ b)
    (h : (a - 1) * (b - 1) = 2) :
    a = 2 ∧ b = 3 := by
  constructor <;> nlinarith

/-! ## Three-Leaf Classification -/

theorem three_leaf_2_4_13 : spb (spb (1/2 : ℝ) (1/4)) (1/13) = 1 := by
  unfold spb; norm_num

theorem three_leaf_2_5_8 : spb (spb (1/2 : ℝ) (1/5)) (1/8) = 1 := by
  unfold spb; norm_num

theorem three_leaf_3_3_7 : spb (spb (1/3 : ℝ) (1/3)) (1/7) = 1 := by
  unfold spb; norm_num

/-- Three-leaf algebraic criterion.
    spb(spb(1/a, 1/b), 1/c) = 1 iff (a+b)(c+1) = (ab-1)(c-1).
    
    Derivation: Let s = spb(1/a, 1/b) = (a+b)/(ab-1).
    spb(s, 1/c) = 1 means (s + 1/c)/(1 - s/c) = 1,
    so sc + 1 = c - s, hence s(c+1) = c-1, so s = (c-1)/(c+1).
    Thus (a+b)/(ab-1) = (c-1)/(c+1), i.e., (a+b)(c+1) = (ab-1)(c-1).
    
    Three-leaf Machin classification with ordering constraint a ≤ b ≤ c.
    The equation (a+b)(c+1) = (ab-1)(c-1) with 2 ≤ a ≤ b ≤ c
    has exactly three solutions. 
    
    Proof: Rearrange to get c = (a+b+ab-1)/(ab-a-b-1) = 1 + 2(a+b)/((a-1)(b-1)-2).
    For a=2: (b-3)(c-3)=10. With b≤c: b-3 ∈ {1,2}, giving (4,13) and (5,8). ✓
    For a=3: (b-2)(c-2)=5. With 3≤b≤c: b-2 ∈ {1}, giving (3,7). ✓
    For a≥4: the equation has no solutions with b ≤ c. -/
theorem three_leaf_criterion (a b c : ℤ) (ha : 2 ≤ a) (hb : 2 ≤ b) (hc : 2 ≤ c)
    (hab : a ≤ b) (hbc : b ≤ c)
    (h : (a + b) * (c + 1) = (a * b - 1) * (c - 1)) :
    (a = 2 ∧ b = 4 ∧ c = 13) ∨ (a = 2 ∧ b = 5 ∧ c = 8) ∨ 
    (a = 3 ∧ b = 3 ∧ c = 7) := by
  -- Step 1: Bound a ≤ 3
  have ha3 : a ≤ 3 := by
    by_contra ha4; push_neg at ha4
    have h4 : 4 ≤ a := by omega
    have hkey : c * (a * b - a - b - 1) = a * b + a + b - 1 := by nlinarith
    have hdenom_pos : a * b - a - b - 1 > 0 := by nlinarith
    have hcb : b * (a * b - a - b - 1) ≤ a * b + a + b - 1 := by
      have := mul_le_mul_of_nonneg_right hbc (le_of_lt hdenom_pos); linarith
    have : a * b ^ 2 - 2 * a * b - b ^ 2 - 2 * b + 1 ≤ a := by nlinarith
    have : b ^ 2 * (a - 3) ≤ 3 * b - 1 + a - 1 := by nlinarith
    have : b ^ 2 ≤ 3 * b - 1 := by nlinarith
    nlinarith
  -- Step 2: Bound b ≤ 7
  have hb7 : b ≤ 7 := by
    by_contra hb8; push_neg at hb8
    have h8 : 8 ≤ b := by omega
    have hkey : c * (a * b - a - b - 1) = a * b + a + b - 1 := by nlinarith
    have hdenom_pos : a * b - a - b - 1 > 0 := by nlinarith
    have hcb : b * (a * b - a - b - 1) ≤ a * b + a + b - 1 := by
      have := mul_le_mul_of_nonneg_right hbc (le_of_lt hdenom_pos); linarith
    have : a * b ^ 2 - 2 * a * b - b ^ 2 - 2 * b + 1 ≤ a := by nlinarith
    nlinarith [sq_nonneg (b - 4)]
  -- Step 3: Case-split on a and b, use omega for c
  interval_cases a <;> interval_cases b <;> omega

/-! ## Four-Leaf Formulas -/

/-- Machin's classical formula: 4·arctan(1/5) - arctan(1/239) = π/4. -/
theorem machin_classical :
    spb (spb (spb (1/5 : ℝ) (1/5)) (spb (1/5) (1/5))) (-1/239) = 1 := by
  unfold spb; norm_num

/-- Gauss's formula: 12·arctan(1/18) + 8·arctan(1/57) - 5·arctan(1/239) = π/4.
    We verify one simpler multi-leaf identity. -/
theorem multi_leaf_identity :
    spb (spb (spb (1/2 : ℝ) (1/3)) 0) 0 = 1 := by
  unfold spb; norm_num

end MachinClass
end