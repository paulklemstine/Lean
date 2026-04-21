/-! # CatalogBuild.Pythagorean.Berggren.BerggrenWellFounded

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 28
-/

import Mathlib

/-- [Section: ## Inverse Maps] -/
def invA' (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)


/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenWellFounded
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 28] -/
def invB' (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)


def invC' (a b c : ℤ) : ℤ × ℤ × ℤ := (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)



/-- [Section: ## Forward-Inverse Cancellation] -/
theorem step_inv_A (a b c : ℤ) :
    let t := applyStep .A (a, b, c); invA' t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [applyStep, invA']; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring



theorem step_inv_B (a b c : ℤ) :
    let t := applyStep .B (a, b, c); invB' t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [applyStep, invB']; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring



theorem step_inv_C (a b c : ℤ) :
    let t := applyStep .C (a, b, c); invC' t.1 t.2.1 t.2.2 = (a, b, c) := by
  simp only [applyStep, invC']; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring



theorem inv_step_A (a b c : ℤ) :
    let t := invA' a b c; applyStep .A (t.1, t.2.1, t.2.2) = (a, b, c) := by
  simp only [invA', applyStep]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring



theorem inv_step_B (a b c : ℤ) :
    let t := invB' a b c; applyStep .B (t.1, t.2.1, t.2.2) = (a, b, c) := by
  simp only [invB', applyStep]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring



theorem inv_step_C (a b c : ℤ) :
    let t := invC' a b c; applyStep .C (t.1, t.2.1, t.2.2) = (a, b, c) := by
  simp only [invC', applyStep]; refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring



/-- [Section: ## Inverse Maps Preserve Pythagorean Property] -/
theorem invA'_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (invA' a b c).1^2 + (invA' a b c).2.1^2 = (invA' a b c).2.2^2 := by
  simp only [invA']; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]



theorem invB'_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (invB' a b c).1^2 + (invB' a b c).2.1^2 = (invB' a b c).2.2^2 := by
  simp only [invB']; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]



theorem invC'_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (invC' a b c).1^2 + (invC' a b c).2.1^2 = (invC' a b c).2.2^2 := by
  simp only [invC']; nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c]



/-- Parent hypotenuse is strictly less than c -/
theorem parent_hyp_lt' (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (h : a^2 + b^2 = c^2) :
    -2*a - 2*b + 3*c < c := by
  nlinarith [sq_nonneg (a + b - c)]



/-- When σ₁ < 0, invC gives positive second component -/
theorem sigma1_neg_invC_pos (a b c : ℤ) (h : a^2 + b^2 = c^2)
    (ha : 0 < a) (hb : 0 < b) (hs : a + 2*b - 2*c < 0) :
    0 < 2*a + b - 2*c := by
  by_contra hle
  push_neg at hle
  nlinarith [sq_nonneg (a + 2*b - 2*c), sq_nonneg (2*a + b - 2*c)]



/-- Main descent: every PPT with a,b,c > 0 has a Pythagorean parent
with positive hypotenuse strictly smaller than c -/
theorem descent_exists_parent (a b c : ℤ) (h : a^2 + b^2 = c^2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    ∃ (a' b' c' : ℤ),
      a'^2 + b'^2 = c'^2 ∧
      0 < c' ∧ c' < c := by
  exact ⟨(invA' a b c).1, (invA' a b c).2.1, (invA' a b c).2.2,
    invA'_pyth a b c h,
    parent_hyp_pos' a b c h ha hb hc,
    by have := parent_hyp_lt' a b c ha hb h; simp only [invA'] at *; linarith⟩



/-- [Section: ## Root Classification] -/
theorem root_class' (a b c : ℤ) (h : a^2 + b^2 = c^2)
    (ha : 0 < a) (hb : 0 < b) (hc5 : c = 5)
    (hcop : Int.gcd a b = 1) :
    (a = 3 ∧ b = 4) ∨ (a = 4 ∧ b = 3) := by
  subst hc5
  have ha5 : a ≤ 4 := by nlinarith [sq_nonneg (a - 5)]
  have hb5 : b ≤ 4 := by nlinarith [sq_nonneg (b - 5)]
  interval_cases a <;> interval_cases b <;> simp_all



/-- [Section: ## Path Verification] -/
theorem path_to_345 : applyPath [] = (3, 4, 5) := rfl


theorem path_to_51213 : applyPath [.A] = (5, 12, 13) := by native_decide


theorem path_to_202129 : applyPath [.B] = (21, 20, 29) := by native_decide


theorem path_to_15817 : applyPath [.C] = (15, 8, 17) := by native_decide


theorem path_to_72425 : applyPath [.A, .A] = (7, 24, 25) := by native_decide


theorem path_to_554873 : applyPath [.A, .B] = (55, 48, 73) := by native_decide


theorem path_to_452853 : applyPath [.A, .C] = (45, 28, 53) := by native_decide



/-- [Section: ## Descent Traces] -/
theorem descent_51213 : invA' 5 12 13 = (3, 4, 5) := by simp [invA']


theorem descent_202129 : invB' 21 20 29 = (3, 4, 5) := by simp [invB']


theorem descent_15817 : invC' 15 8 17 = (3, 4, 5) := by simp [invC']


theorem descent_72425 : invA' 7 24 25 = (5, 12, 13) := by simp [invA']



/-- Two-step descent from (7,24,25) to root -/
theorem descent_72425_root :
    let t₁ := invA' 7 24 25
    invA' t₁.1 t₁.2.1 t₁.2.2 = (3, 4, 5) := by simp [invA']


