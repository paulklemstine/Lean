/-! # CatalogBuild.Pythagorean.Berggren.BerggrenPellStructure

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 15
-/

import Mathlib

/-- B₂ⁿ·(3,4,5) by iteration -/
def b2iter : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 =>
    let (a, b, c) := b2iter n
    (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)



/-- Companion Pell: hypotenuses of B₂ iterates -/
def cPell : ℕ → ℤ
  | 0 => 5
  | 1 => 29
  | n + 2 => 6 * cPell (n + 1) - cPell n



/-- [Section: ## Computational Checks] -/
theorem b2iter_vals :
    b2iter 0 = (3, 4, 5) ∧
    b2iter 1 = (21, 20, 29) ∧
    b2iter 2 = (119, 120, 169) ∧
    b2iter 3 = (697, 696, 985) ∧
    b2iter 4 = (4059, 4060, 5741) := by native_decide



/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenPellStructure
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 15] -/
theorem cPell_vals :
    cPell 0 = 5 ∧ cPell 1 = 29 ∧ cPell 2 = 169 ∧
    cPell 3 = 985 ∧ cPell 4 = 5741 := by native_decide



/-- [Section: ## Hypotenuses are Sums of Consecutive Pell Squares] -/
theorem pellSeq_vals :
    pellSeq 0 = 1 ∧ pellSeq 1 = 2 ∧ pellSeq 2 = 5 ∧
    pellSeq 3 = 12 ∧ pellSeq 4 = 29 ∧ pellSeq 5 = 70 := by native_decide



/-- B₂ hypotenuses = sum of consecutive Pell squares -/
theorem cPell_eq_pell_sum_sq :
    cPell 0 = pellSeq 0 ^ 2 + pellSeq 1 ^ 2 ∧
    cPell 1 = pellSeq 1 ^ 2 + pellSeq 2 ^ 2 ∧
    cPell 2 = pellSeq 2 ^ 2 + pellSeq 3 ^ 2 ∧
    cPell 3 = pellSeq 3 ^ 2 + pellSeq 4 ^ 2 ∧
    cPell 4 = pellSeq 4 ^ 2 + pellSeq 5 ^ 2 := by native_decide



/-- [Section: ## B₂ Leg Difference Alternation] -/
theorem b2_leg_diff : ∀ n, (b2iter n).1 - (b2iter n).2.1 = (-1)^(n+1) := by
  intro n
  induction n with
  | zero => native_decide
  | succ n ih =>
    simp only [b2iter]; set t := b2iter n
    have : (t.1 + 2*t.2.1 + 2*t.2.2) - (2*t.1 + t.2.1 + 2*t.2.2) = -(t.1 - t.2.1) := by ring
    rw [this, ih]; ring



/-- [Section: ## B₂ Pythagorean] -/
theorem b2_pyth : ∀ n, (b2iter n).1^2 + (b2iter n).2.1^2 = (b2iter n).2.2^2 := by
  intro n
  induction n with
  | zero => native_decide
  | succ n ih =>
    simp only [b2iter]; set t := b2iter n
    nlinarith [sq_nonneg t.1, sq_nonneg t.2.1, sq_nonneg (t.1 - t.2.1), sq_nonneg (t.1 + t.2.1)]



/-- [Section: ## B₂ Positivity] -/
theorem b2_pos : ∀ n, 0 < (b2iter n).1 ∧ 0 < (b2iter n).2.1 ∧ 0 < (b2iter n).2.2 := by
  intro n
  induction n with
  | zero => decide
  | succ n ih =>
    simp only [b2iter]; set t := b2iter n
    exact ⟨by linarith [ih.1, ih.2.1, ih.2.2],
           by linarith [ih.1, ih.2.1, ih.2.2],
           by linarith [ih.1, ih.2.1, ih.2.2]⟩



/-- [Section: ## Companion Pell mod 4] -/
theorem cPell_mod4 : ∀ n, cPell n % 4 = 1 := fun n => (cPell_mod4_aux n).1



/-- [Section: ## Companion Pell Positivity] -/
theorem cPell_pos : ∀ n, 0 < cPell n := fun n => (cPell_pos_aux n).1



/-- [Section: ## B₂ Determinant Pattern] -/
def BPS₂ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]



theorem det_BPS₂_pow :
    Matrix.det BPS₂ = -1 ∧
    Matrix.det (BPS₂ ^ 2) = 1 ∧
    Matrix.det (BPS₂ ^ 3) = -1 ∧
    Matrix.det (BPS₂ ^ 4) = 1 := by native_decide



/-- [Section: ## B₂ Parity Preservation] -/
theorem b2_parity_a : ∀ n, (b2iter n).1 % 2 = 1 := fun n => (b2_parity_aux n).1


theorem b2_parity_b : ∀ n, (b2iter n).2.1 % 2 = 0 := fun n => (b2_parity_aux n).2


