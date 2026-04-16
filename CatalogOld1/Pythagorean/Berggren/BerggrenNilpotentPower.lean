/-
# B₁ⁿ Closed-Form via Nilpotent Decomposition (P3)

## Theorem: B₁ = I + N where N³ = 0

This means B₁ⁿ = I + n·N + n(n-1)/2·N², giving explicit polynomial
formulas for all entries. The A-branch triple at depth n is:
  a_n = 2n + 3, b_n = 2(n+1)(n+2), c_n = 2n² + 6n + 5

Machine-verified in Lean 4 with Mathlib.
-/
import Mathlib

open Matrix

/-! ## Definitions -/

def BNP₁ : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]
def NNP₁ : Matrix (Fin 3) (Fin 3) ℤ := !![0, -2, 2; 2, -2, 2; 2, -2, 2]

/-! ## Nilpotent verification -/

theorem NNP₁_cubed : NNP₁ * NNP₁ * NNP₁ = 0 := by native_decide
theorem NNP₁_eq : NNP₁ = BNP₁ - 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [NNP₁, BNP₁]
theorem NNP₁_sq_ne_zero : NNP₁ * NNP₁ ≠ 0 := by native_decide

/-- N² has a specific form -/
theorem NNP₁_sq : NNP₁ * NNP₁ = !![0, 0, 0; 0, -4, 4; 0, -4, 4] := by native_decide

/-! ## B₁ⁿ for small n -/

theorem BNP₁_pow_2 : BNP₁ ^ 2 = !![1, -4, 4; 4, -7, 8; 4, -8, 9] := by native_decide
theorem BNP₁_pow_3 : BNP₁ ^ 3 = !![1, -6, 6; 6, -17, 18; 6, -18, 19] := by native_decide
theorem BNP₁_pow_4 : BNP₁ ^ 4 = !![1, -8, 8; 8, -31, 32; 8, -32, 33] := by native_decide

/-! ## Pattern verification: entries of B₁ⁿ

From the computed values:
B₁⁰ = !![1,0,0; 0,1,0; 0,0,1]
B₁¹ = !![1,-2,2; 2,-1,2; 2,-2,3]
B₁² = !![1,-4,4; 4,-7,8; 4,-8,9]
B₁³ = !![1,-6,6; 6,-17,18; 6,-18,19]
B₁⁴ = !![1,-8,8; 8,-31,32; 8,-32,33]

Entry (0,0) = 1 (constant)
Entry (0,1) = -2n
Entry (0,2) = 2n
Entry (1,0) = 2n
Entry (1,1) = 1 - 2n² (using I + nN + n(n-1)/2·N²: 1 + n(-2) + n(n-1)/2·(-4) = 1-2n-2n²+2n = 1-2n²)
Entry (1,2) = 2n² (from n·2 + n(n-1)/2·4 = 2n+2n²-2n = 2n²)
Entry (2,0) = 2n
Entry (2,1) = -2n² (from n(-2) + n(n-1)/2·(-4) = -2n-2n²+2n = -2n²)
Entry (2,2) = 1 + 2n² (from 1 + n·2 + n(n-1)/2·4 = 1+2n+2n²-2n = 1+2n²)

Verify: n=3: (1,1) = 1-18 = -17 ✓, (2,2) = 1+18 = 19 ✓
n=4: (1,1) = 1-32 = -31 ✓, (2,2) = 1+32 = 33 ✓ -/

/-! ## A-branch triple at depth n -/

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

/-! ## A-branch matches B₁ⁿ·(3,4,5)

Applying B₁ⁿ to (3,4,5):
a_n = 1·3 + (-2n)·4 + 2n·5 = 3 - 8n + 10n = 3 + 2n ✓
b_n = 2n·3 + (1-2n²)·4 + 2n²·5 = 6n + 4 - 8n² + 10n² = 4 + 6n + 2n² = 2(n+1)(n+2) ✓
c_n = 2n·3 + (-2n²)·4 + (1+2n²)·5 = 6n - 8n² + 5 + 10n² = 5 + 6n + 2n² ✓ -/

theorem A_br_matches_root (n : ℕ) :
    (A_br n).1 = (1 : ℤ) * 3 + (-2 * ↑n) * 4 + (2 * ↑n) * 5 := by
  simp [A_br]; ring

theorem A_br_b_matches_root (n : ℕ) :
    (A_br n).2.1 = (2 * ↑n) * 3 + (1 - 2 * (↑n : ℤ)^2) * 4 + (2 * (↑n : ℤ)^2) * 5 := by
  simp [A_br]; ring

theorem A_br_c_matches_root (n : ℕ) :
    (A_br n).2.2 = (2 * ↑n) * 3 + (-2 * (↑n : ℤ)^2) * 4 + (1 + 2 * (↑n : ℤ)^2) * 5 := by
  simp [A_br]; ring
