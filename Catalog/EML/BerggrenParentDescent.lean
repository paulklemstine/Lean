import Mathlib

/-! # CatalogBuild.EML.BerggrenParentDescent

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 27
-/

/-- [Section: # CatalogBuild.EML.BerggrenParentDescent
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 27] -/
def IsPT' (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- Berggren child transformations -/
def chA' (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- [Section: # CatalogBuild.EML.BerggrenParentDescent
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 27] -/
def chB' (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def chC' (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- Inverse (parent) transformations -/
def pA' (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

def pB' (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

def pC' (a b c : ℤ) : ℤ × ℤ × ℤ := (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

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

theorem pA_pyth' (a b c : ℤ) (h : IsPT' a b c) :
    IsPT' (pA' a b c).1 (pA' a b c).2.1 (pA' a b c).2.2 := by
  unfold IsPT' pA' at *; nlinarith

theorem pB_pyth' (a b c : ℤ) (h : IsPT' a b c) :
    IsPT' (pB' a b c).1 (pB' a b c).2.1 (pB' a b c).2.2 := by
  unfold IsPT' pB' at *; nlinarith

theorem pC_pyth' (a b c : ℤ) (h : IsPT' a b c) :
    IsPT' (pC' a b c).1 (pC' a b c).2.1 (pC' a b c).2.2 := by
  unfold IsPT' pC' at *; nlinarith

theorem chA_pyth' (a b c : ℤ) (h : IsPT' a b c) :
    IsPT' (chA' a b c).1 (chA' a b c).2.1 (chA' a b c).2.2 := by
  unfold IsPT' chA' at *; nlinarith

theorem chB_pyth' (a b c : ℤ) (h : IsPT' a b c) :
    IsPT' (chB' a b c).1 (chB' a b c).2.1 (chB' a b c).2.2 := by
  unfold IsPT' chB' at *; nlinarith

theorem chC_pyth' (a b c : ℤ) (h : IsPT' a b c) :
    IsPT' (chC' a b c).1 (chC' a b c).2.1 (chC' a b c).2.2 := by
  unfold IsPT' chC' at *; nlinarith

theorem chA_hyp_growth' (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : a < c) (hbc : b < c) :
    c < (chA' a b c).2.2 := by
  unfold chA'; nlinarith

theorem chB_hyp_growth' (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : a < c) (hbc : b < c) :
    c < (chB' a b c).2.2 := by
  unfold chB'; nlinarith

theorem chC_hyp_growth' (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : a < c) (hbc : b < c) :
    c < (chC' a b c).2.2 := by
  unfold chC'; nlinarith

/-- All parent hypotenuses have the same value: c' = 3c - 2a - 2b -/
theorem parent_hyp_uniform' (a b c : ℤ) :
    (pA' a b c).2.2 = (pB' a b c).2.2 ∧ (pB' a b c).2.2 = (pC' a b c).2.2 := by
  unfold pA' pB' pC'; constructor <;> ring

theorem parent_hyp_descent' (a b c : ℤ) (h : IsPT' a b c) (ha : 0 < a) (hb : 0 < b)
    (hc : 0 < c) :
    (pA' a b c).2.2 < c := by
      unfold IsPT' at *;
      unfold pA';
      nlinarith [ mul_pos ha hb ]

theorem parent_hyp_pos' (a b c : ℤ) (h : IsPT' a b c) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < (pA' a b c).2.2 := by
      -- We need 0 < (pA..).2 snd.2.
      unfold pA';
      nlinarith [ sq_nonneg ( a - b ), h.symm ]

/-- Descent from (119,120,169): two B-steps back to root -/
theorem branches_distinct_at_root' :
    chA' 3 4 5 ≠ chB' 3 4 5 ∧ chA' 3 4 5 ≠ chC' 3 4 5 ∧ chB' 3 4 5 ≠ chC' 3 4 5 := by
  native_decide

theorem root_children' :
    chA' 3 4 5 = (5, 12, 13) ∧ chB' 3 4 5 = (21, 20, 29) ∧ chC' 3 4 5 = (15, 8, 17) := by
  native_decide