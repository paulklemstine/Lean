import Mathlib
import Algebra.ContinuedFractions.MatrixEncoding

/-!
# Convergent Recurrences and Matrix Structure

This file develops the theory of continued fraction convergents through
their matrix encoding. The key insight is that the numerators `pₙ` and
denominators `qₙ` of convergents satisfy a three-term recurrence that
is exactly captured by the matrix product structure of `wordMatrix`.

## Main definitions

- `convergentP` : the numerator sequence of convergents (from word matrix)
- `convergentQ` : the denominator sequence of convergents (from word matrix)

## Main results

- `convergentP_nil`, `convergentQ_nil` : base cases
- `convergentP_singleton`, `convergentQ_singleton` : single digit
- `wordMatrix_two_correct` : explicit 2-digit word matrix
- `cfMatrix_mul_cfMatrix` : product of two digit matrices
- `convergent_det_identity` : `det(M_w) = (-1)^|w|`
-/

namespace ContinuedFractions

open Matrix

/-- The numerator of the convergent for a digit word, extracted from the
    word matrix: `p = M[0,1]` for the last convergent. -/
def convergentP (w : List ℤ) : ℤ := (wordMatrix w) 0 1

/-- The denominator of the convergent for a digit word, extracted from the
    word matrix: `q = M[1,1]` for the last convergent. -/
def convergentQ (w : List ℤ) : ℤ := (wordMatrix w) 1 1

/-
For an empty word, the convergent numerator is 0 (off-diagonal of identity).
-/
theorem convergentP_nil : convergentP [] = 0 := by
  native_decide +revert

/-
For an empty word, the convergent denominator is 1 (identity matrix).
-/
theorem convergentQ_nil : convergentQ [] = 1 := by
  rfl

/-
For a single digit `a`, the convergent numerator is `a`.
    This follows from `wordMatrix [a] = cfMatrix a = !![0,1;1,a]`,
    so `M[0,1] = a` (wait, M[0,1] = 1... let me recheck).
    Actually cfMatrix a = !![0,1;1,a], so (cfMatrix a) 0 1 = 1.
    So convergentP [a] = 1, not a. Let me fix.
-/
theorem convergentP_singleton (a : ℤ) : convergentP [a] = 1 := by
  exact cfMatrix_entry_01 a

/-
For a single digit `a`, the convergent denominator is `a`.
    From cfMatrix a = !![0,1;1,a], M[1,1] = a.
-/
theorem convergentQ_singleton (a : ℤ) : convergentQ [a] = a := by
  -- By definition of `convergentQ`, we have `convergentQ [a] = (wordMatrix [a]) 1 1`.
  simp [convergentQ, wordMatrix_singleton, cfMatrix]

/-
The word matrix for two digits `[a, b]`:
    `cfMatrix a * cfMatrix b = !![0,1;1,a] * !![0,1;1,b] = !![1, b; a, a*b+1]`.
-/
theorem wordMatrix_two (a b : ℤ) :
    wordMatrix [a, b] = !![1, b; a, a * b + 1] := by
  unfold wordMatrix;
  unfold cfMatrix wordMatrix;
  unfold cfMatrix wordMatrix; ext i j; fin_cases i <;> fin_cases j <;> norm_num [ Matrix.mul_apply ] ;
  ring

/-
The convergent P for [a,b] is b.
-/
theorem convergentP_two (a b : ℤ) : convergentP [a, b] = b := by
  exact congr_arg ( fun x : Matrix _ _ ℤ => x 0 1 ) ( wordMatrix_two a b )

/-
The convergent Q for [a,b] is a*b + 1.
-/
theorem convergentQ_two (a b : ℤ) : convergentQ [a, b] = a * b + 1 := by
  -- Use the explicit formula for `wordMatrix` for two digits, and extract the `1,1` entry.
  have h : wordMatrix [a, b] = Matrix.of ![![1, b], ![a, a * b + 1]] := wordMatrix_two a b
  simp [convergentQ, h]

/-
The product of two digit matrices.
-/
theorem cfMatrix_mul_cfMatrix (a b : ℤ) :
    cfMatrix a * cfMatrix b = !![1, b; a, a * b + 1] := by
  -- By definition of matrix multiplication, we can compute each entry of the product.
  ext i j; fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, cfMatrix];
  ring

/-- The determinant identity for convergents. -/
theorem convergent_det_identity (w : List ℤ) :
    Matrix.det (wordMatrix w) = (-1) ^ w.length :=
  wordMatrix_det w

/-
For positive digits, the denominator is positive.
-/
theorem convergentQ_pos_of_pos (a : ℤ) (ha : 0 < a) :
    0 < convergentQ [a] := by
  exact ha.trans_le ( by rw [ convergentQ_singleton ] )

/-- Existence of the rational convergent. -/
theorem convergent_fraction_exists (w : List ℤ) (_ : convergentQ w ≠ 0) :
    ∃ r : ℚ, r = (convergentP w : ℚ) / (convergentQ w : ℚ) :=
  ⟨_, rfl⟩

end ContinuedFractions