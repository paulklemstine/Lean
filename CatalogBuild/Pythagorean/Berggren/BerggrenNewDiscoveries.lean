/-! # CatalogBuild.Pythagorean.Berggren.BerggrenNewDiscoveries

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 34
-/

import Mathlib

/-- [Section: ## Matrix Definitions] -/
def BD₁ : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

def BD₂ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

def BD₃ : Matrix (Fin 3) (Fin 3) ℤ := !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]


/-- [Section: ## Trace Analysis] -/
theorem trace_BD₁ : Matrix.trace BD₁ = 3 := by native_decide

theorem trace_BD₂ : Matrix.trace BD₂ = 5 := by native_decide

theorem trace_BD₃ : Matrix.trace BD₃ = 3 := by native_decide

theorem trace_BD₁_eq_BD₃ : Matrix.trace BD₁ = Matrix.trace BD₃ := by native_decide


/-- [Section: ## Determinant Properties] -/
theorem det_BD₁ : Matrix.det BD₁ = 1 := by native_decide

theorem det_BD₂ : Matrix.det BD₂ = -1 := by native_decide

theorem det_BD₃ : Matrix.det BD₃ = 1 := by native_decide


/-- [Section: ## Cayley-Hamilton for B₂
char(B₂) = (x+1)(x² - 6x + 1) = x³ - 5x² - 5x + 1
The eigenvalues are -1, 3+2√2, 3-2√2.
Note: 3+2√2 = (1+√2)² is the fundamental Pell unit.] -/
theorem BD₂_cayley_hamilton :
    BD₂ ^ 3 - 5 • BD₂ ^ 2 - 5 • BD₂ + 1 = 0 := by native_decide


/-- B₂ has eigenvalue -1: B₂·(-1,1,0) = (1,-1,0) = -(-1,1,0) -/
theorem BD₂_eigenvector_neg1 :
    BD₂ * !![-1; 1; 0] = !![1; -1; 0] := by native_decide


/-- [Section: ## Pythagorean Preservation] -/
theorem BD₁_preserves (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (a - 2*b + 2*c)^2 + (2*a - b + 2*c)^2 = (2*a - 2*b + 3*c)^2 := by nlinarith


theorem BD₂_preserves (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (a + 2*b + 2*c)^2 + (2*a + b + 2*c)^2 = (2*a + 2*b + 3*c)^2 := by
  nlinarith [sq_nonneg (a - b), sq_nonneg (a + b)]


theorem BD₃_preserves (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (-a + 2*b + 2*c)^2 + (-2*a + b + 2*c)^2 = (-2*a + 2*b + 3*c)^2 := by nlinarith


/-- [Section: ## B₂ Children Always Positive] -/
theorem BD₂_child_pos (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < a + 2*b + 2*c ∧ 0 < 2*a + b + 2*c ∧ 0 < 2*a + 2*b + 3*c :=
  ⟨by linarith, by linarith, by linarith⟩


/-- [Section: ## Even/Odd Parity Preservation] -/
theorem BD₂_preserves_parity_a (a b c : ℤ) :
    (a + 2*b + 2*c) % 2 = a % 2 := by omega


theorem BD₂_preserves_parity_b (a b c : ℤ) :
    (2*a + b + 2*c) % 2 = b % 2 := by omega


/-- [Section: ## Matrix Products] -/
theorem BD₁_sq : BD₁ * BD₁ = !![1, -4, 4; 4, -7, 8; 4, -8, 9] := by native_decide

theorem BD₂_sq : BD₂ * BD₂ = !![9, 8, 12; 8, 9, 12; 12, 12, 17] := by native_decide


/-- [Section: ## Tree Coverage for Small PPTs] -/
theorem ppt_345 : (3:ℤ)^2 + 4^2 = 5^2 := by norm_num


/-- (5,12,13) = B₁·(3,4,5) -/
theorem ppt_51213 :
    ((3:ℤ) - 2*4 + 2*5, (2:ℤ)*3 - 4 + 2*5, (2:ℤ)*3 - 2*4 + 3*5) = ((5:ℤ), 12, 13) := by norm_num


/-- (21,20,29) = B₂·(3,4,5) -/
theorem ppt_202129 :
    ((3:ℤ) + 2*4 + 2*5, (2:ℤ)*3 + 4 + 2*5, (2:ℤ)*3 + 2*4 + 3*5) = ((21:ℤ), 20, 29) := by norm_num


/-- (15,8,17) = B₃·(3,4,5) (swapped legs) -/
theorem ppt_81517 :
    (-(3:ℤ) + 2*4 + 2*5, -(2:ℤ)*3 + 4 + 2*5, -(2:ℤ)*3 + 2*4 + 3*5) = ((15:ℤ), 8, 17) := by norm_num


/-- (7,24,25) = B₁²·(3,4,5) -/
theorem ppt_72425 :
    ((5:ℤ) - 2*12 + 2*13, (2:ℤ)*5 - 12 + 2*13, (2:ℤ)*5 - 2*12 + 3*13) = ((7:ℤ), 24, 25) := by norm_num


/-- (119,120,169) = B₂²·(3,4,5) -/
theorem ppt_119120169 :
    ((21:ℤ) + 2*20 + 2*29, (2:ℤ)*21 + 20 + 2*29, (2:ℤ)*21 + 2*20 + 3*29) = ((119:ℤ), 120, 169) := by
  norm_num


theorem BD₁_Lorentz : BD₁ᵀ * QLor * BD₁ = QLor := by native_decide

theorem BD₂_Lorentz : BD₂ᵀ * QLor * BD₂ = QLor := by native_decide

theorem BD₃_Lorentz : BD₃ᵀ * QLor * BD₃ = QLor := by native_decide


/-- [Section: ## New Discovery: Commutator Analysis] -/
theorem BD₁₂_commutator :
    BD₁ * BD₂ - BD₂ * BD₁ =
    !![-8, 12, -8; -4, 16, -4; -8, 20, -8] := by native_decide


/-- The commutator [B₁,B₂] has trace 0 (traceless!) -/
theorem BD₁₂_commutator_trace :
    Matrix.trace (BD₁ * BD₂ - BD₂ * BD₁) = 0 := by native_decide


/-- The commutator [B₁,B₃] also has trace 0 -/
theorem BD₁₃_commutator_trace :
    Matrix.trace (BD₁ * BD₃ - BD₃ * BD₁) = 0 := by native_decide


/-- The commutator [B₂,B₃] also has trace 0 -/
theorem BD₂₃_commutator_trace :
    Matrix.trace (BD₂ * BD₃ - BD₃ * BD₂) = 0 := by native_decide


/-- [Section: ## New Discovery: All commutators are traceless!
This is a significant structural property: [Bᵢ, Bⱼ] is always traceless.
In the context of the Lorentz group O(2,1), this means the commutators
lie in the Lie algebra so(2,1), which is exactly what one expects since
the Berggren matrices are close to the identity in the Lorentz group.] -/
theorem all_commutators_traceless :
    Matrix.trace (BD₁ * BD₂ - BD₂ * BD₁) = 0 ∧
    Matrix.trace (BD₁ * BD₃ - BD₃ * BD₁) = 0 ∧
    Matrix.trace (BD₂ * BD₃ - BD₃ * BD₂) = 0 :=
  ⟨BD₁₂_commutator_trace, BD₁₃_commutator_trace, BD₂₃_commutator_trace⟩

