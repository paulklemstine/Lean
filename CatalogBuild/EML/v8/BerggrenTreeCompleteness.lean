/-! # CatalogBuild.EML.v8.BerggrenTreeCompleteness

Auto-generated from theorem catalog database.
Domain: EML/v8
Declarations: 23
-/

import Mathlib

/-- [Section: ## §1. Definitions] -/
structure PPT_v8 where
  a : ℤ
  b : ℤ
  c : ℤ
  ha : 0 < a
  hb : 0 < b
  hc : 0 < c
  pyth : a ^ 2 + b ^ 2 = c ^ 2
  coprime : Int.gcd a b = 1


/-- [Section: ## §2. Berggren Transforms] -/
def childA_v8 (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def childB_v8 (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def childC_v8 (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


def parentA_v8 (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

def parentB_v8 (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

def parentC_v8 (a b c : ℤ) : ℤ × ℤ × ℤ := (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)


/-- [Section: ## §3. Parent Hypotenuse Properties] -/
theorem parent_hyp_shared (a b c : ℤ) :
    (parentA_v8 a b c).2.2 = -2*a - 2*b + 3*c ∧
    (parentB_v8 a b c).2.2 = -2*a - 2*b + 3*c ∧
    (parentC_v8 a b c).2.2 = -2*a - 2*b + 3*c := by
  unfold parentA_v8 parentB_v8 parentC_v8; exact ⟨rfl, rfl, rfl⟩


theorem parent_hyp_pos_v8 (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < -2*a - 2*b + 3*c := by
  nlinarith [sq_nonneg (a - b), mul_pos ha hb]


theorem parent_hyp_lt_v8 (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) :
    -2*a - 2*b + 3*c < c := by
  nlinarith [mul_pos ha hb]


/-- [Section: ## §4. Forward-Inverse Cancellation] -/
theorem childA_parentA_cancel (a b c : ℤ) :
    parentA_v8 (childA_v8 a b c).1 (childA_v8 a b c).2.1 (childA_v8 a b c).2.2 = (a, b, c) := by
  simp only [childA_v8, parentA_v8]; ext <;> ring


theorem childB_parentB_cancel (a b c : ℤ) :
    parentB_v8 (childB_v8 a b c).1 (childB_v8 a b c).2.1 (childB_v8 a b c).2.2 = (a, b, c) := by
  simp only [childB_v8, parentB_v8]; ext <;> ring


theorem childC_parentC_cancel (a b c : ℤ) :
    parentC_v8 (childC_v8 a b c).1 (childC_v8 a b c).2.1 (childC_v8 a b c).2.2 = (a, b, c) := by
  simp only [childC_v8, parentC_v8]; ext <;> ring


/-- [Section: ## §5. Sign Analysis] -/
def sigQ1_v8 (a b c : ℤ) : ℤ := a + 2*b - 2*c

def sigQ2_v8 (a b c : ℤ) : ℤ := 2*a + b - 2*c


theorem not_both_nonpos_v8 (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) :
    ¬(sigQ1_v8 a b c ≤ 0 ∧ sigQ2_v8 a b c ≤ 0) := by
  unfold sigQ1_v8 sigQ2_v8
  intro ⟨h1, h2⟩
  nlinarith [sq_nonneg (a - b), mul_pos ha hb]


/-- [Section: ## §6. Root Identification] -/
theorem root_is_ppt_v8 : (3 : ℤ) ^ 2 + 4 ^ 2 = 5 ^ 2 := by norm_num

theorem root_coprime_v8 : Int.gcd 3 4 = 1 := by native_decide


theorem c_eq_5_classification (a b : ℤ) (h : a ^ 2 + b ^ 2 = 5 ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hcop : Int.gcd a b = 1) :
    (a = 3 ∧ b = 4) ∨ (a = 4 ∧ b = 3) := by
  have hab : a ^ 2 + b ^ 2 = 25 := by linarith
  have ha5 : a ≤ 4 := by nlinarith [sq_nonneg b]
  have hb5 : b ≤ 4 := by nlinarith [sq_nonneg a]
  interval_cases a <;> interval_cases b <;> simp_all


/-- [Section: ## §7. Hypotenuse Growth for Children] -/
theorem childA_hyp_growth_v8 (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hac : a < c) (hbc : b < c) :
    c < (childA_v8 a b c).2.2 := by
  unfold childA_v8; nlinarith


theorem childB_hyp_growth_v8 (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hac : a < c) (hbc : b < c) :
    c < (childB_v8 a b c).2.2 := by
  unfold childB_v8; nlinarith


theorem childC_hyp_growth_v8 (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hac : a < c) (hbc : b < c) :
    c < (childC_v8 a b c).2.2 := by
  unfold childC_v8; nlinarith


/-- [Section: ## §9. Branch Injectivity] -/
theorem branches_injective_v8 :
    childA_v8 3 4 5 ≠ childB_v8 3 4 5 ∧
    childA_v8 3 4 5 ≠ childC_v8 3 4 5 ∧
    childB_v8 3 4 5 ≠ childC_v8 3 4 5 := by
  unfold childA_v8 childB_v8 childC_v8
  refine ⟨by decide, by decide, by decide⟩

