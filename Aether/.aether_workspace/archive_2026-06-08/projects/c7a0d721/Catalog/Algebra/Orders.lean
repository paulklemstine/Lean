/-
  # Certified Hadamard Orders

  Proves existence of Hadamard matrices for specific orders beyond powers of 2,
  building infinite families via Kronecker closure.
-/
import Algebra.Hadamard.Sylvester
import Algebra.Hadamard.Kronecker

open Matrix Finset BigOperators

/-! ## Explicit Hadamard matrix of order 12 (Paley-type)

This is the smallest Hadamard order not a power of 2.
The matrix is constructed from the Paley construction using
quadratic residues modulo 11. -/

/-- An explicit 12×12 Hadamard matrix (Paley construction from QR mod 11). -/
def H12 : Matrix (Fin 12) (Fin 12) ℤ :=
  !![1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1;
     1, -1,  1, -1,  1,  1,  1, -1, -1, -1,  1, -1;
     1, -1, -1,  1, -1,  1,  1,  1, -1, -1, -1,  1;
     1,  1, -1, -1,  1, -1,  1,  1,  1, -1, -1, -1;
     1, -1,  1, -1, -1,  1, -1,  1,  1,  1, -1, -1;
     1, -1, -1,  1, -1, -1,  1, -1,  1,  1,  1, -1;
     1, -1, -1, -1,  1, -1, -1,  1, -1,  1,  1,  1;
     1,  1, -1, -1, -1,  1, -1, -1,  1, -1,  1,  1;
     1,  1,  1, -1, -1, -1,  1, -1, -1,  1, -1,  1;
     1,  1,  1,  1, -1, -1, -1,  1, -1, -1,  1, -1;
     1, -1,  1,  1,  1, -1, -1, -1,  1, -1, -1,  1;
     1,  1, -1,  1,  1,  1, -1, -1, -1,  1, -1, -1]

/-
H12 is a Hadamard matrix.
-/
theorem isHadamard_H12 : IsHadamard H12 := by
  exact ⟨ by native_decide, by native_decide ⟩

/-- Order 12 is a Hadamard order. -/
theorem hadamardOrder_twelve : HadamardOrder 12 :=
  ⟨H12, isHadamard_H12⟩

/-! ## Infinite families via Kronecker closure -/

/-- Every order of the form 2^a * 12^b is a Hadamard order. -/
theorem hadamardOrder_pow_two_mul_pow_twelve (a b : ℕ) :
    HadamardOrder (2 ^ a * 12 ^ b) := by
  induction b with
  | zero =>
    simp
    exact hadamardOrder_pow_two a
  | succ b ih =>
    rw [pow_succ, ← mul_assoc]
    exact hadamardOrder_mul ih hadamardOrder_twelve

/-- Order 4 is a Hadamard order (corollary of Sylvester). -/
theorem hadamardOrder_four' : HadamardOrder 4 := by
  have := hadamardOrder_pow_two 2
  norm_num at this
  exact this

/-- Order 8 is a Hadamard order. -/
theorem hadamardOrder_eight : HadamardOrder 8 := by
  have := hadamardOrder_pow_two 3
  norm_num at this
  exact this

/-- Order 16 is a Hadamard order. -/
theorem hadamardOrder_sixteen : HadamardOrder 16 := by
  have := hadamardOrder_pow_two 4
  norm_num at this
  exact this

/-- Order 24 is a Hadamard order (= 2 * 12). -/
theorem hadamardOrder_twentyfour : HadamardOrder 24 := by
  have := hadamardOrder_mul (hadamardOrder_pow_two 1) hadamardOrder_twelve
  norm_num at this
  exact this

/-- Order 48 is a Hadamard order (= 4 * 12). -/
theorem hadamardOrder_fortyeight : HadamardOrder 48 := by
  have := hadamardOrder_mul (hadamardOrder_pow_two 2) hadamardOrder_twelve
  norm_num at this
  exact this