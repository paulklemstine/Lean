/-
  # Explicit Hadamard Matrices and Counterexamples

  Provides concrete small-order Hadamard matrices and
  disproves false generalizations about Hadamard matrices.
-/
import Algebra.Hadamard.Basic

open Matrix Finset BigOperators

/-! ## Explicit Hadamard matrix of order 4 -/

/-- An explicit 4×4 Hadamard matrix. -/
def H4 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1,  1,  1,  1;
     1, -1,  1, -1;
     1,  1, -1, -1;
     1, -1, -1,  1]

/-
H4 is a Hadamard matrix (verified by computation).
-/
theorem isHadamard_H4 : IsHadamard H4 := by
  constructor <;> native_decide

/-- Order 4 is a Hadamard order. -/
theorem hadamardOrder_four : HadamardOrder 4 :=
  ⟨H4, isHadamard_H4⟩

/-! ## Counterexamples -/

/-
Not every Hadamard matrix is symmetric.
-/
theorem not_every_hadamard_symmetric :
    ¬ ∀ (n : ℕ) (H : Matrix (Fin n) (Fin n) ℤ), IsHadamard H → H.transpose = H := by
      push_neg;
      use 2;
      -- Consider the matrix $H = \begin{pmatrix} 1 & 1 \\ -1 & 1 \end{pmatrix}$.
      use !![1, 1; -1, 1];
      simp +decide [ IsHadamard ]