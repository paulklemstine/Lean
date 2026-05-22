/-
# Target A: Descartes Form Invariance

Each Apollonian generator preserves the Descartes quadratic form.
This is the algebraic bedrock of Apollonian dynamics.
-/

import Mathlib
import Algebra.Apollonian.Defs

open Matrix Finset BigOperators

/-! ## Generator-level invariance: Sᵢᵀ J Sᵢ = J -/

/-- Each Apollonian generator preserves the Descartes matrix under congruence. -/
theorem apollonian_generator_preserves_descartes (i : Fin 4) :
    (apollonianGen i)ᵀ * descartesMatrix * (apollonianGen i) = descartesMatrix := by
  fin_cases i <;> native_decide

/-! ## Generators are involutions: Sᵢ² = I -/

/-- Each Apollonian generator is an involution (self-inverse). -/
theorem apollonianGen_involutive (i : Fin 4) :
    apollonianGen i * apollonianGen i = 1 := by
  fin_cases i <;> native_decide

/-! ## Word-level invariance -/

/-- The word matrix equals the product of generator matrices. -/
theorem applyWord_eq_wordMatrix (w : List (Fin 4)) (v : Fin 4 → ℤ) :
    applyWord w v = (wordMatrix w).mulVec v := by
  induction w with
  | nil => simp [applyWord, wordMatrix]
  | cons i w ih =>
    simp only [applyWord, wordMatrix, applyGen]
    rw [ih]
    simp [mulVec_mulVec]

/-
Word matrices preserve the Descartes matrix.
-/
theorem wordMatrix_preserves_descartes (w : List (Fin 4)) :
    (wordMatrix w)ᵀ * descartesMatrix * (wordMatrix w) = descartesMatrix := by
  -- We proceed by induction on the length of the word `w`.
  induction' w with i w ih;
  · decide +kernel;
  · -- By definition of `wordMatrix`, we have `wordMatrix (i :: w) = apollonianGen i * wordMatrix w`.
    have h_wordMatrix : wordMatrix (i :: w) = apollonianGen i * wordMatrix w := by
      rfl;
    simp_all +decide [ Matrix.mul_assoc ];
    have := apollonian_generator_preserves_descartes i; simp_all +decide [ ← Matrix.mul_assoc ] ;

/-
The Descartes quadratic form is invariant under any word in the Apollonian generators.
-/
theorem apollonian_word_preserves_descartes (w : List (Fin 4)) (v : Fin 4 → ℤ) :
    descartesQ (applyWord w v) = descartesQ v := by
  -- By definition of `applyWord`, we have `applyWord w v = (wordMatrix w).mulVec v`.
  have h_applyWord : applyWord w v = (wordMatrix w).mulVec v := by
    exact applyWord_eq_wordMatrix w v;
  -- By definition of `descartesQ`, we have `descartesQ v = dotProduct v (descartesMatrix.mulVec v)`.
  unfold descartesQ;
  simp +decide only [h_applyWord, dotProduct_mulVec, vecMul_mulVec];
  have := wordMatrix_preserves_descartes w; simp_all +decide [ Matrix.mul_assoc, dotProduct ] ;

/-! ## The Descartes form as a matrix bilinear form -/

/-- The Descartes quadratic form equals the matrix form `vᵀ J v`. -/
theorem descartesQ_eq_matrix_form (v : Fin 4 → ℤ) :
    descartesQ v = dotProduct v (descartesMatrix.mulVec v) := by
  rfl