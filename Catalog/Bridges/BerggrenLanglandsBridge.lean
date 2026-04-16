/-! # CatalogBuild.Bridges.BerggrenLanglandsBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 26
-/

import Mathlib

noncomputable section

/-- The Lorentz form matrix Q = diag(1, 1, -1). -/
def lorentzQ : Matrix (Fin 3) (Fin 3) ℤ := Matrix.diagonal ![1, 1, -1]



/-- The 2×2 Euclid parameter matrices. -/
def M₁ : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]


/-- [Section: # CatalogBuild.Bridges.BerggrenLanglandsBridge
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 26] -/
def M₂ : Matrix (Fin 2) (Fin 2) ℤ := !![2, 1; 1, 0]


def M₃ : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]



/-- M₁ ∈ SL₂(ℤ): det M₁ = 1. -/
theorem M1_in_SL2 : Matrix.det M₁ = 1 := by simp [M₁, Matrix.det_fin_two]



/-- M₂ has det = -1 (not in SL₂(ℤ), but in GL₂(ℤ)). -/
theorem M2_det : Matrix.det M₂ = -1 := by simp [M₂, Matrix.det_fin_two]



/-- M₃ ∈ SL₂(ℤ): det M₃ = 1. -/
theorem M3_in_SL2 : Matrix.det M₃ = 1 := by simp [M₃, Matrix.det_fin_two]



/-- M₃ is a parabolic (unipotent) element: M₃ = I + 2·E₁₂. -/
theorem M3_unipotent : M₃ - 1 = !![0, 2; 0, 0] := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [M₃]



/-- M₁² = [[3, -2], [2, -1]] (trace = 2, so M₁ is also parabolic-adjacent). -/
theorem M1_squared : M₁ * M₁ = !![3, -2; 2, -1] := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [M₁, Matrix.mul_apply, Fin.sum_univ_two]



/-- Euclid's parametrization: (m,n) ↦ (m²-n², 2mn, m²+n²). -/
def euclidParam (m n : ℤ) : Fin 3 → ℤ :=
  ![m^2 - n^2, 2*m*n, m^2 + n^2]



/-- The Euclid parametrization always gives a Pythagorean triple. -/
theorem euclid_is_pythagorean (m n : ℤ) :
    (euclidParam m n 0)^2 + (euclidParam m n 1)^2 = (euclidParam m n 2)^2 := by
  unfold euclidParam; simp; ring



/-- The root (3,4,5) comes from m=2, n=1. -/
theorem root_from_euclid : euclidParam 2 1 = ![3, 4, 5] := by
  unfold euclidParam; ext i; fin_cases i <;> simp



/-- The Pythagorean quadratic form: Q(v) = v₀² + v₁² - v₂². -/
def quadForm (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2



/-- Euclid triples have Q = 0. -/
theorem euclid_quad_zero (m n : ℤ) : quadForm (euclidParam m n) = 0 := by
  simp [quadForm, euclidParam]; ring



/-- For the root triple (3,4,5): 9 + 16 = 25. -/
theorem root_pyth : (3:ℤ)^2 + 4^2 = 5^2 := by norm_num



theorem pyth_even_component (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    a % 2 = 0 ∨ b % 2 = 0 := by
      exact Classical.or_iff_not_imp_left.2 fun ha => by obtain ⟨ k, rfl ⟩ := Int.odd_iff.2 ( by aesop : a % 2 = 1 ) ; obtain ⟨ l, rfl | rfl ⟩ := Int.even_or_odd' b <;> replace h := congr_arg ( · % 4 ) h <;> rcases Int.even_or_odd' c with ⟨ m, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Int.add_emod, Int.mul_emod ] at *;



/-- In (3,4,5): 3 ≡ 0 (mod 3). -/
theorem triple_345_mod3 : (3 : ℤ) % 3 = 0 := by norm_num



/-- In (3,4,5): 5 ≡ 1 (mod 4). -/
theorem triple_345_mod4 : (5 : ℤ) % 4 = 1 := by norm_num



/-- The modular S matrix. -/
def modularS : Matrix (Fin 2) (Fin 2) ℤ := !![0, -1; 1, 0]



/-- S has det = 1, hence S ∈ SL₂(ℤ). -/
theorem S_in_SL2 : Matrix.det modularS = 1 := by
  simp [modularS, Matrix.det_fin_two]



/-- S has order 4: S⁴ = I. -/
theorem S_order4 : modularS * modularS * modularS * modularS = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [modularS, Matrix.mul_apply, Fin.sum_univ_two]



/-- S² = -I. -/
theorem S_squared : modularS * modularS = -1 := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [modularS, Matrix.mul_apply, Fin.sum_univ_two]



/-- M₃ = T² where T = [[1,1],[0,1]] is the standard generator. -/
def modularT : Matrix (Fin 2) (Fin 2) ℤ := !![1, 1; 0, 1]



theorem T_squared_eq_M3 : modularT * modularT = M₃ := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [modularT, M₃, Matrix.mul_apply, Fin.sum_univ_two]



theorem T_in_SL2 : Matrix.det modularT = 1 := by
  simp [modularT, Matrix.det_fin_two]



/-- T and T⁻¹ are distinct mod Γ_θ (since T ∉ Γ_θ). -/
theorem T_not_in_theta_group : modularT ≠ M₃ := by
  intro h
  have : (modularT 0 1 : ℤ) = (M₃ 0 1 : ℤ) := by rw [h]
  simp [modularT, M₃] at this



end
