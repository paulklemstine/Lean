import Mathlib

/-!
# Matrix Encoding of Continued Fraction Digits

This file formalizes the correspondence between continued fraction digit words
and products of matrices in SL₂(ℤ). Each partial quotient `a` corresponds to
the matrix `[[0, 1], [1, a]]`, and a digit word `[a₁, …, aₖ]` maps to the
product of these matrices. We prove that for positive digit words, the
determinant of the word matrix alternates between +1 and -1 (specifically,
`det(wordMatrix w) = (-1)^(length w)`).

## Main definitions

- `cfMatrix a` : the 2×2 matrix `[[0, 1], [1, a]]` for digit `a`
- `wordMatrix w` : the product of `cfMatrix` over a digit word `w`

## Main results

- `cfMatrix_det` : `det (cfMatrix a) = -1`
- `wordMatrix_det` : `det (wordMatrix w) = (-1)^(length w)`
- `wordMatrix_append` : `wordMatrix (u ++ v) = wordMatrix u * wordMatrix v`
-/

namespace ContinuedFractions

open Matrix

/-- The continued fraction matrix for a single digit `a`:
    `[[0, 1], [1, a]]`. This encodes the Möbius transformation
    `x ↦ 1/(a + x)` which is the inverse branch of the Gauss map
    corresponding to digit `a`. -/
def cfMatrix (a : ℤ) : Matrix (Fin 2) (Fin 2) ℤ := !![0, 1; 1, a]

/-- The word matrix for a sequence of digits: the product of individual
    digit matrices. For `w = [a₁, …, aₖ]`, this is
    `cfMatrix a₁ * cfMatrix a₂ * ⋯ * cfMatrix aₖ`.
    The empty word gives the identity matrix. -/
def wordMatrix : List ℤ → Matrix (Fin 2) (Fin 2) ℤ
  | [] => 1
  | a :: w => cfMatrix a * wordMatrix w

/-
The determinant of a single digit matrix is -1.
-/
theorem cfMatrix_det (a : ℤ) : Matrix.det (cfMatrix a) = -1 := by
  -- Expand cfMatrix, compute the 2x2 determinant directly: 0*a - 1*1 = -1. Use simp/decide/native_decide on the Fin 2 matrix.
  simp [cfMatrix, Matrix.det_fin_two]

/-- Word matrix respects list cons. -/
theorem wordMatrix_cons (a : ℤ) (w : List ℤ) :
    wordMatrix (a :: w) = cfMatrix a * wordMatrix w := rfl

/-- The empty word gives the identity matrix. -/
theorem wordMatrix_nil : wordMatrix [] = 1 := rfl

/-
Word matrix respects list append: `wordMatrix (u ++ v) = wordMatrix u * wordMatrix v`.
-/
theorem wordMatrix_append (u v : List ℤ) :
    wordMatrix (u ++ v) = wordMatrix u * wordMatrix v := by
  induction' u with a u ihdecide;
  · cases v <;> simp +decide [ wordMatrix ];
  · -- By definition of wordMatrix, we have wordMatrix (a :: u ++ v) = cfMatrix a * wordMatrix (u ++ v).
    rw [List.cons_append, wordMatrix_cons, ihdecide];
    rw [ ← Matrix.mul_assoc, wordMatrix_cons ]

/-
The determinant of a word matrix is `(-1)^(length w)`.
    This is the key algebraic fact: continued fraction matrix products
    have determinant ±1, alternating with word length.
-/
theorem wordMatrix_det (w : List ℤ) :
    Matrix.det (wordMatrix w) = (-1) ^ w.length := by
  induction w <;> simp_all +decide [ List.length ];
  rw [ wordMatrix_cons, Matrix.det_mul, cfMatrix_det, ‹Matrix.det ( wordMatrix _ ) = _› ] ; ring

/-
For a single-digit word, the word matrix equals the digit matrix.
-/
theorem wordMatrix_singleton (a : ℤ) :
    wordMatrix [a] = cfMatrix a := by
  -- By definition of `wordMatrix`, we have `wordMatrix [a] = cfMatrix a * wordMatrix []`.
  rw [wordMatrix];
  exact wordMatrix_nil ▸ mul_one _

/-
The (0,0) entry of `cfMatrix a` is 0.
-/
theorem cfMatrix_entry_00 (a : ℤ) : cfMatrix a 0 0 = 0 := by
  rfl

/-
The (0,1) entry of `cfMatrix a` is 1.
-/
theorem cfMatrix_entry_01 (a : ℤ) : cfMatrix a 0 1 = 1 := by
  rfl

/-
The (1,0) entry of `cfMatrix a` is 1.
-/
theorem cfMatrix_entry_10 (a : ℤ) : cfMatrix a 1 0 = 1 := by
  rfl

/-
The (1,1) entry of `cfMatrix a` is `a`.
-/
theorem cfMatrix_entry_11 (a : ℤ) : cfMatrix a 1 1 = a := by
  rfl

/-
Word matrices of positive digit lists are invertible (have unit determinant up to sign).
-/
theorem wordMatrix_det_ne_zero (w : List ℤ) :
    Matrix.det (wordMatrix w) ≠ 0 := by
  rw [ wordMatrix_det ] ; norm_num;

/-
The product of two word matrices corresponds to concatenation.
-/
theorem wordMatrix_det_append (u v : List ℤ) :
    Matrix.det (wordMatrix (u ++ v)) =
      Matrix.det (wordMatrix u) * Matrix.det (wordMatrix v) := by
  rw [ wordMatrix_append, Matrix.det_mul ]

end ContinuedFractions