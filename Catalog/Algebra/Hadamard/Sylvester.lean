/-
  # Sylvester Construction for Hadamard Matrices

  Defines the recursive Sylvester/Walsh-Hadamard matrices and proves they are Hadamard,
  giving the canonical infinite family of orders 2^k.
-/
import Algebra.Hadamard.Basic
import Algebra.Hadamard.Kronecker

open Matrix Finset BigOperators

/-! ## Hadamard matrix of order 2 -/

/-- The canonical 2×2 Hadamard matrix [[1,1],[1,-1]]. -/
def H2 : Matrix (Fin 2) (Fin 2) ℤ := !![1, 1; 1, -1]

theorem isHadamard_H2 : IsHadamard H2 := by
  exact ⟨ fun i j => by fin_cases i <;> fin_cases j <;> decide, by native_decide ⟩

/-! ## Every power of 2 is a Hadamard order -/

/-- Every power of 2 is a Hadamard order, by iterated Kronecker product. -/
theorem hadamardOrder_pow_two (k : ℕ) : HadamardOrder (2 ^ k) := by
  induction k with
  | zero => exact hadamardOrder_one
  | succ k ih =>
    rw [pow_succ]
    exact hadamardOrder_mul ih ⟨H2, isHadamard_H2⟩