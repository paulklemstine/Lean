import Mathlib

/-!
# Berggren Parent Descent (Direction #1 Prerequisites)

We formalize key lemmas toward Berggren completeness:
1. Each inverse map preserves the Pythagorean property
2. The valid parent has strictly smaller hypotenuse
3. Forward-inverse cancellation

This file establishes the infrastructure for the completeness proof.
-/

/-! ## §1. Definitions -/

def IsPT' (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- Berggren child transformations -/
def chA' (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
def chB' (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
def chC' (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- Inverse (parent) transformations -/
def pA' (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)
def pB' (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)
def pC' (a b c : ℤ) : ℤ × ℤ × ℤ := (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-! ## §2. Forward-Inverse Cancellation -/

theorem chA_pA_cancel' (a b c : ℤ) :
    pA' (chA' a b c).1 (chA' a b c).2.1 (chA' a b c).2.2 = (a, b, c) := by
  simp only [chA', pA']; ext <;> ring

theorem pA_chA_cancel' (a b c : ℤ) :
    chA' (pA' a b c).1 (pA' a b c).2.1 (pA' a b c).2.2 = (a, b, c) := by
  simp only [chA', pA']; ext <;> ring

theorem chB_pB_cancel' (a b c : ℤ) :
    pB' (chB' a b c).1 (chB' a b c).2.1 (chB' a b c).2.2 = (a, b, c) := by
  simp only [chB', pB']; ext <;> ring

theorem pB_chB_cancel' (a b c : ℤ) :
    chB' (pB' a b c).1 (pB' a b c).2.1 (pB' a b c).2.2 = (a, b, c) := by
  simp only [chB', pB']; ext <;> ring

theorem chC_pC_cancel' (a b c : ℤ) :
    pC' (chC' a b c).1 (chC' a b c).2.1 (chC' a b c).2.2 = (a, b, c) := by
  simp only [chC', pC']; ext <;> ring

theorem pC_chC_cancel' (a b c : ℤ) :
    chC' (pC' a b c).1 (pC' a b c).2.1 (pC' a b c).2.2 = (a, b, c) := by
  simp only [chC', pC']; ext <;> ring

/-! ## §3. Inverse Maps Preserve Pythagorean Property -/

theorem pA_pyth' (a b c : ℤ) (h : IsPT' a b c) :
    IsPT' (pA' a b c).1 (pA' a b c).2.1 (pA' a b c).2.2 := by
  unfold IsPT' pA' at *; nlinarith

theorem pB_pyth' (a b c : ℤ) (h : IsPT' a b c) :
    IsPT' (pB' a b c).1 (pB' a b c).2.1 (pB' a b c).2.2 := by
  unfold IsPT' pB' at *; nlinarith

theorem pC_pyth' (a b c : ℤ) (h : IsPT' a b c) :
    IsPT' (pC' a b c).1 (pC' a b c).2.1 (pC' a b c).2.2 := by
  unfold IsPT' pC' at *; nlinarith

/-! ## §4. Child preserves Pythagorean property -/

theorem chA_pyth' (a b c : ℤ) (h : IsPT' a b c) :
    IsPT' (chA' a b c).1 (chA' a b c).2.1 (chA' a b c).2.2 := by
  unfold IsPT' chA' at *; nlinarith

theorem chB_pyth' (a b c : ℤ) (h : IsPT' a b c) :
    IsPT' (chB' a b c).1 (chB' a b c).2.1 (chB' a b c).2.2 := by
  unfold IsPT' chB' at *; nlinarith

theorem chC_pyth' (a b c : ℤ) (h : IsPT' a b c) :
    IsPT' (chC' a b c).1 (chC' a b c).2.1 (chC' a b c).2.2 := by
  unfold IsPT' chC' at *; nlinarith

/-! ## §5. Hypotenuse Growth for Children -/

theorem chA_hyp_growth' (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : a < c) (hbc : b < c) :
    c < (chA' a b c).2.2 := by
  unfold chA'; nlinarith

theorem chB_hyp_growth' (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : a < c) (hbc : b < c) :
    c < (chB' a b c).2.2 := by
  unfold chB'; nlinarith

theorem chC_hyp_growth' (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : a < c) (hbc : b < c) :
    c < (chC' a b c).2.2 := by
  unfold chC'; nlinarith

/-! ## §6. Parent Hypotenuse Properties -/

/-- All parent hypotenuses have the same value: c' = 3c - 2a - 2b -/
theorem parent_hyp_uniform' (a b c : ℤ) :
    (pA' a b c).2.2 = (pB' a b c).2.2 ∧ (pB' a b c).2.2 = (pC' a b c).2.2 := by
  unfold pA' pB' pC'; constructor <;> ring

/-
For Pythagorean triples with a,b > 0, the parent hypotenuse is < c.
    Key fact: a² + b² = c² and a,b > 0 imply a + b > c (triangle inequality)
    and 2(a+b) < 3c (from Cauchy-Schwarz: (a+b)² ≤ 2c²).
-/
theorem parent_hyp_descent' (a b c : ℤ) (h : IsPT' a b c) (ha : 0 < a) (hb : 0 < b)
    (hc : 0 < c) :
    (pA' a b c).2.2 < c := by
      unfold IsPT' at *;
      unfold pA';
      nlinarith [ mul_pos ha hb ]

/-
The parent hypotenuse is positive: 3c > 2(a+b).
    Proof: (2a+2b)² = 4(a²+b²) + 8ab = 4c² + 8ab ≤ 4c² + 4c² = 8c² < 9c²
    (using AM-GM: 2ab ≤ a²+b² = c²). So 2(a+b) < 3c.
-/
theorem parent_hyp_pos' (a b c : ℤ) (h : IsPT' a b c) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < (pA' a b c).2.2 := by
      -- We need 0 < (pA..).2 snd.2.
      unfold pA';
      nlinarith [ sq_nonneg ( a - b ), h.symm ]

/-! ## §7. Specific Descent Computations -/

/-- Descent from (5,12,13): parentA gives (3,4,5) ✓ -/
example : pA' 5 12 13 = (3, 4, 5) := by native_decide

/-- Descent from (21,20,29): parentB gives (3,4,5) ✓ -/
example : pB' 21 20 29 = (3, 4, 5) := by native_decide

/-- Descent from (15,8,17): parentC gives (3,4,5) ✓ -/
example : pC' 15 8 17 = (3, 4, 5) := by native_decide

/-- Multi-step descent: (7,24,25) → (5,12,13) → (3,4,5) -/
example : pA' 7 24 25 = (5, 12, 13) := by native_decide
example : pA' 5 12 13 = (3, 4, 5) := by native_decide

/-- Descent from (119,120,169): two B-steps back to root -/
example : pB' 119 120 169 = (21, 20, 29) := by native_decide
example : pB' 21 20 29 = (3, 4, 5) := by native_decide

/-! ## §8. Branch Injectivity -/

theorem branches_distinct_at_root' :
    chA' 3 4 5 ≠ chB' 3 4 5 ∧ chA' 3 4 5 ≠ chC' 3 4 5 ∧ chB' 3 4 5 ≠ chC' 3 4 5 := by
  native_decide

theorem root_children' :
    chA' 3 4 5 = (5, 12, 13) ∧ chB' 3 4 5 = (21, 20, 29) ∧ chC' 3 4 5 = (15, 8, 17) := by
  native_decide

/-! ## §9. Depth-2 Descent Verifications -/

example : pA' 7 24 25 = (5, 12, 13) := by native_decide
example : pB' 55 48 73 = (5, 12, 13) := by native_decide
example : pC' 45 28 53 = (5, 12, 13) := by native_decide