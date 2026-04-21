/-! # CatalogBuild.Pythagorean.Berggren.BerggrenFreeSemigroupV13

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 16
-/

import Mathlib

/-- [Section: ## Definitions] -/
def fwdB1S (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def fwdB2S (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def fwdB3S (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


/-- [Section: ## Forward maps strictly increase hypotenuse] -/
theorem fwdB1_hyp_increase (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    c < (fwdB1S a b c).2.2 := by
  exact show c < 2*a - 2*b + 3*c by nlinarith;


theorem fwdB2_hyp_increase (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < (fwdB2S a b c).2.2 := by
  simp [fwdB2S]; linarith


theorem fwdB3_hyp_increase (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    c < (fwdB3S a b c).2.2 := by
  exact show c < -2 * a + 2 * b + 3 * c by nlinarith;


/-- [Section: ## Forward maps produce PPTs] -/
theorem fwdB1_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (fwdB1S a b c).1 ^ 2 + (fwdB1S a b c).2.1 ^ 2 = (fwdB1S a b c).2.2 ^ 2 := by
  simp [fwdB1S]; nlinarith


theorem fwdB2_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (fwdB2S a b c).1 ^ 2 + (fwdB2S a b c).2.1 ^ 2 = (fwdB2S a b c).2.2 ^ 2 := by
  simp [fwdB2S]; nlinarith


theorem fwdB3_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (fwdB3S a b c).1 ^ 2 + (fwdB3S a b c).2.1 ^ 2 = (fwdB3S a b c).2.2 ^ 2 := by
  simp [fwdB3S]; nlinarith


/-- [Section: ## Forward maps are injective] -/
theorem fwdB1_injective (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h : fwdB1S a₁ b₁ c₁ = fwdB1S a₂ b₂ c₂) :
    a₁ = a₂ ∧ b₁ = b₂ ∧ c₁ = c₂ := by
  simp only [fwdB1S, Prod.mk.injEq] at h; omega


theorem fwdB2_injective (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h : fwdB2S a₁ b₁ c₁ = fwdB2S a₂ b₂ c₂) :
    a₁ = a₂ ∧ b₁ = b₂ ∧ c₁ = c₂ := by
  simp only [fwdB2S, Prod.mk.injEq] at h; omega


theorem fwdB3_injective (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h : fwdB3S a₁ b₁ c₁ = fwdB3S a₂ b₂ c₂) :
    a₁ = a₂ ∧ b₁ = b₂ ∧ c₁ = c₂ := by
  simp only [fwdB3S, Prod.mk.injEq] at h; omega


/-- [Section: ## Different branches produce different triples] -/
theorem branches_distinct_12 (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (_h : a ^ 2 + b ^ 2 = c ^ 2) :
    fwdB1S a b c ≠ fwdB2S a b c := by
  simp only [fwdB1S, fwdB2S, ne_eq, Prod.mk.injEq, not_and]; omega


theorem branches_distinct_13 (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (_h : a ^ 2 + b ^ 2 = c ^ 2) :
    fwdB1S a b c ≠ fwdB3S a b c := by
  simp only [fwdB1S, fwdB3S, ne_eq, Prod.mk.injEq, not_and]; omega


theorem branches_distinct_23 (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (_h : a ^ 2 + b ^ 2 = c ^ 2) :
    fwdB2S a b c ≠ fwdB3S a b c := by
  simp only [fwdB2S, fwdB3S, ne_eq, Prod.mk.injEq, not_and]; omega


/-- The hypotenuse strictly increases along any path, so no cycle is possible -/
theorem tree_acyclic (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a, b, c) ≠ fwdB1S a b c ∧
    (a, b, c) ≠ fwdB2S a b c ∧
    (a, b, c) ≠ fwdB3S a b c := by
  refine ⟨?_, ?_, ?_⟩ <;> (intro heq; simp only [fwdB1S, fwdB2S, fwdB3S, Prod.mk.injEq] at heq; omega)
