/-! # CatalogBuild.Pythagorean.Berggren.BerggrenNilpotentPower

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 18
-/

import Mathlib

/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenNilpotentPower
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 18] -/
def BNP₁ : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]


def NNP₁ : Matrix (Fin 3) (Fin 3) ℤ := !![0, -2, 2; 2, -2, 2; 2, -2, 2]



theorem NNP₁_cubed : NNP₁ * NNP₁ * NNP₁ = 0 := by native_decide


theorem NNP₁_eq : NNP₁ = BNP₁ - 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [NNP₁, BNP₁]


theorem NNP₁_sq_ne_zero : NNP₁ * NNP₁ ≠ 0 := by native_decide



/-- N² has a specific form -/
theorem NNP₁_sq : NNP₁ * NNP₁ = !![0, 0, 0; 0, -4, 4; 0, -4, 4] := by native_decide



theorem BNP₁_pow_2 : BNP₁ ^ 2 = !![1, -4, 4; 4, -7, 8; 4, -8, 9] := by native_decide


theorem BNP₁_pow_3 : BNP₁ ^ 3 = !![1, -6, 6; 6, -17, 18; 6, -18, 19] := by native_decide


theorem BNP₁_pow_4 : BNP₁ ^ 4 = !![1, -8, 8; 8, -31, 32; 8, -32, 33] := by native_decide



def A_br (n : ℕ) : ℤ × ℤ × ℤ := (2*n + 3, 2*(↑n+1)*(↑n+2), 2*(↑n : ℤ)^2 + 6*n + 5)



theorem A_br_pyth (n : ℕ) : (A_br n).1^2 + (A_br n).2.1^2 = (A_br n).2.2^2 := by
  simp only [A_br]; ring



theorem A_br_consec (n : ℕ) : (A_br n).2.2 - (A_br n).2.1 = 1 := by
  simp only [A_br]; ring



theorem A_br_odd (n : ℕ) : ∃ k, (A_br n).1 = 2 * k + 1 := ⟨↑n + 1, by simp [A_br]; ring⟩



theorem A_br_even (n : ℕ) : ∃ k, (A_br n).2.1 = 2 * k :=
  ⟨(↑n+1)*(↑n+2), by simp [A_br]; ring⟩



theorem A_br_hyp_odd (n : ℕ) : ∃ k, (A_br n).2.2 = 2 * k + 1 :=
  ⟨(n : ℤ)^2 + 3*n + 2, by simp only [A_br]; ring⟩



theorem A_br_matches_root (n : ℕ) :
    (A_br n).1 = (1 : ℤ) * 3 + (-2 * ↑n) * 4 + (2 * ↑n) * 5 := by
  simp [A_br]; ring



theorem A_br_b_matches_root (n : ℕ) :
    (A_br n).2.1 = (2 * ↑n) * 3 + (1 - 2 * (↑n : ℤ)^2) * 4 + (2 * (↑n : ℤ)^2) * 5 := by
  simp [A_br]; ring



theorem A_br_c_matches_root (n : ℕ) :
    (A_br n).2.2 = (2 * ↑n) * 3 + (-2 * (↑n : ℤ)^2) * 4 + (1 + 2 * (↑n : ℤ)^2) * 5 := by
  simp [A_br]; ring


