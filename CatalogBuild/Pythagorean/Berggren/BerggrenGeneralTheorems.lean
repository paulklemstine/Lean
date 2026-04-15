/-! # CatalogBuild.Pythagorean.Berggren.BerggrenGeneralTheorems

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 12
-/

import Mathlib

/-- [Section: ## Computational Checks] -/
theorem b2n_0 : b2n 0 = (3, 4, 5) := rfl

theorem b2n_1 : b2n 1 = (21, 20, 29) := by native_decide

theorem b2n_2 : b2n 2 = (119, 120, 169) := by native_decide

theorem b2n_3 : b2n 3 = (697, 696, 985) := by native_decide


/-- [Section: ## B₂ Component Positivity] -/
theorem b2n_all_pos : ∀ n : ℕ, 0 < (b2n n).1 ∧ 0 < (b2n n).2.1 ∧ 0 < (b2n n).2.2 := by
  intro n
  induction n with
  | zero => decide
  | succ n ih =>
    simp only [b2n]
    set t := b2n n with ht
    obtain ⟨ha, hb, hc⟩ := ih
    exact ⟨by nlinarith, by nlinarith, by nlinarith⟩


/-- [Section: ## Companion Pell Sequence] -/
theorem compPell_0 : compPell 0 = 5 := rfl

theorem compPell_1 : compPell 1 = 29 := rfl

theorem compPell_2 : compPell 2 = 169 := by native_decide

theorem compPell_3 : compPell 3 = 985 := by native_decide


/-- [Section: ## CompPell Positivity and Growth
We prove positivity and growth together by strong induction.] -/
theorem compPell_pos : ∀ n : ℕ, 0 < compPell n := fun n => (compPell_pos_growth n).1


theorem compPell_growth : ∀ n : ℕ, compPell n < compPell (n + 1) :=
  fun n => (compPell_pos_growth n).2


/-- [Section: ## B₂ hypotenuse growth] -/
theorem b2n_hyp_growth : ∀ n : ℕ, (b2n n).2.2 < (b2n (n+1)).2.2 := by
  intro n
  have h := b2n_all_pos n
  simp only [b2n]
  set t := b2n n with ht
  obtain ⟨ha, hb, hc⟩ := h
  nlinarith

