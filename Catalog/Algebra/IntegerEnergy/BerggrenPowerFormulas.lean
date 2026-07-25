import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.BerggrenPowerFormulas

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 15
-/

/-- Berggren matrix B₁ -/
def BPF₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- The nilpotent part N₁ = B₁ - I -/
def NPF₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![0, -2, 2; 2, -2, 2; 2, -2, 2]

/-- N₁² (computed) -/
def NPF₁sq : Matrix (Fin 3) (Fin 3) ℤ :=
  !![0, 0, 0; 0, -4, 4; 0, -4, 4]

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenPowerFormulas
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 15] -/
theorem NPF₁_eq_B₁_sub_I : NPF₁ = BPF₁ - 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [NPF₁, BPF₁]

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenPowerFormulas
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 15] -/
theorem NPF₁_sq_eq : NPF₁ * NPF₁ = NPF₁sq := by native_decide

theorem NPF₁_sq_ne_zero : NPF₁ * NPF₁ ≠ 0 := by native_decide

theorem NPF₁_cubed_eq_zero : NPF₁ * NPF₁ * NPF₁ = 0 := by native_decide

theorem A_triple_pythagorean (n : ℕ) :
    (A_triple n).1 ^ 2 + (A_triple n).2.1 ^ 2 = (A_triple n).2.2 ^ 2 := by
  simp only [A_triple]; ring

theorem A_triple_1 : A_triple 1 = (5, 12, 13) := by simp [A_triple]

theorem A_triple_2 : A_triple 2 = (7, 24, 25) := by simp [A_triple]

theorem A_triple_3 : A_triple 3 = (9, 40, 41) := by simp [A_triple]

theorem A_hyp_growth (n : ℕ) : (A_triple n).2.2 < (A_triple (n + 1)).2.2 := by
  simp only [A_triple]; push_cast; nlinarith [n.zero_le]

theorem A_hyp_pos (n : ℕ) : 0 < (A_triple n).2.2 := by
  simp only [A_triple]; positivity

theorem A_first_pos (n : ℕ) : 0 < (A_triple n).1 := by
  simp only [A_triple]; omega

theorem A_second_pos (n : ℕ) : 0 < (A_triple n).2.1 := by
  simp only [A_triple]; positivity

