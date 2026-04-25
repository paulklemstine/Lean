/-! # CatalogBuild.Pythagorean.Berggren.BerggrenRootUniqueness

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 4
-/

import Mathlib

/-- [Section: ## Main result] -/
theorem ppt_hyp_ge_5 (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hcop : Int.gcd a b = 1) : 5 ≤ c := by
  contrapose! hcop; interval_cases c <;> ( ( have : a ≤ 4 := Int.le_of_lt_add_one ( by nlinarith only [ h, ha, hb ] ) ; have : b ≤ 4 := Int.le_of_lt_add_one ( by nlinarith only [ h, ha, hb ] ) ; interval_cases a <;> interval_cases b <;> norm_num at *; ) )


/-- The unique PPT with c = 5 (up to leg swap) -/
theorem ppt_c5_unique (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hc5 : c = 5)
    (hcop : Int.gcd a b = 1) :
    (a = 3 ∧ b = 4) ∨ (a = 4 ∧ b = 3) := by
  subst hc5
  have ha5 : a ≤ 4 := by nlinarith [sq_nonneg (a - 5)]
  have hb5 : b ≤ 4 := by nlinarith [sq_nonneg (b - 5)]
  interval_cases a <;> interval_cases b <;> simp_all


/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenRootUniqueness
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 4] -/
theorem root_unique (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hcop : Int.gcd a b = 1) (hle : c ≤ 5) :
    (a = 3 ∧ b = 4 ∧ c = 5) ∨ (a = 4 ∧ b = 3 ∧ c = 5) := by
  interval_cases c <;> ( have : a ≤ 5 := Int.le_of_lt_add_one ( by nlinarith only [ h, hb ] ) ; ( have : b ≤ 5 := Int.le_of_lt_add_one ( by nlinarith only [ h, ha ] ) ; interval_cases a <;> interval_cases b <;> simp_all +decide only; ) )


theorem minimal_ppt : ∀ a b c : ℤ,
    a ^ 2 + b ^ 2 = c ^ 2 → 0 < a → 0 < b → 0 < c →
    Int.gcd a b = 1 → c < 5 → False := by
  intro a b c; intros h₁ h₂ h₃ h₄ h₅ h₆; interval_cases c <;> ( have := ( show a ≤ 4 by nlinarith ) ; ( have := ( show b ≤ 4 by nlinarith ) ; interval_cases a <;> interval_cases b <;> trivial; ) ) ;

