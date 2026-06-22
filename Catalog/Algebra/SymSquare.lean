/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The symmetric square representation of 2×2 matrices

For a 2×2 matrix `M` we build the 3×3 matrix `sym2Hom M` describing the induced
action of `M` on the second symmetric power of the standard 2-dimensional module
(in the monomial basis `x^2, x*y, y^2`).  This is a multiplicative map
(a monoid homomorphism), and we compute its trace, determinant and characteristic
polynomial.

## Main results

* `sym2Hom_one` — `sym2Hom` sends the identity to the identity.
* `sym2Hom_mul` — `sym2Hom` is multiplicative.
* `sym2HomMonoidHom` — packaged monoid homomorphism.
* `sym2Hom_trace` — `tr (sym2Hom M) = (tr M)^2 - det M`.
* `sym2Hom_det` — `det (sym2Hom M) = (det M)^3`.
* `sym2Hom_charpoly_trace_det` — explicit characteristic polynomial.
* `sym2Hom_charpoly` — factorization of the characteristic polynomial in terms of
  the eigenvalues `α, β` of `M`.
-/
import Mathlib

open Matrix Polynomial

variable {R : Type*} [CommRing R]

namespace SymSquare

/-- The symmetric square of a 2×2 matrix, as a 3×3 matrix in the monomial basis
`x^2, x*y, y^2`. -/
def sym2Hom (M : Matrix (Fin 2) (Fin 2) R) : Matrix (Fin 3) (Fin 3) R :=
  !![M 0 0 ^ 2, 2 * M 0 0 * M 0 1, M 0 1 ^ 2;
     M 0 0 * M 1 0, M 0 0 * M 1 1 + M 0 1 * M 1 0, M 0 1 * M 1 1;
     M 1 0 ^ 2, 2 * M 1 0 * M 1 1, M 1 1 ^ 2]

theorem sym2Hom_one : sym2Hom (1 : Matrix (Fin 2) (Fin 2) R) = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;> simp +decide [sym2Hom]

theorem sym2Hom_mul (A B : Matrix (Fin 2) (Fin 2) R) :
    sym2Hom (A * B) = sym2Hom A * sym2Hom B := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp +decide [sym2Hom, Matrix.mul_apply, Fin.sum_univ_succ] <;> ring

/-- The symmetric square as a monoid homomorphism. -/
def sym2HomMonoidHom : Matrix (Fin 2) (Fin 2) R →* Matrix (Fin 3) (Fin 3) R where
  toFun := sym2Hom
  map_one' := sym2Hom_one
  map_mul' := sym2Hom_mul

theorem sym2Hom_trace (M : Matrix (Fin 2) (Fin 2) R) :
    (sym2Hom M).trace = M.trace ^ 2 - M.det := by
  simp only [Matrix.trace, Matrix.det_fin_two]
  simp +decide [sym2Hom, Fin.sum_univ_succ]
  ring

theorem sym2Hom_det (M : Matrix (Fin 2) (Fin 2) R) :
    (sym2Hom M).det = M.det ^ 3 := by
  unfold sym2Hom
  rw [Matrix.det_fin_two]
  simp +decide [Matrix.det_fin_three]
  ring

theorem sym2Hom_charpoly_trace_det (M : Matrix (Fin 2) (Fin 2) R) :
    Matrix.charpoly (sym2Hom M) =
      (X : Polynomial R) ^ 3 - C (M.trace ^ 2 - M.det) * (X : Polynomial R) ^ 2
        + C (M.det * (M.trace ^ 2 - M.det)) * (X : Polynomial R) - C (M.det ^ 3) := by
  simp +decide only [charpoly, trace_fin_two, det_fin_two]
  simp +decide [Matrix.det_fin_three, sym2Hom]
  rw [show (C 2 : Polynomial R) = 2 by rfl]
  ring

theorem sym2Hom_charpoly (M : Matrix (Fin 2) (Fin 2) R) (α β : R)
    (htr : α + β = M.trace) (hdet : α * β = M.det) :
    Matrix.charpoly (sym2Hom M) =
      ((X : Polynomial R) - C (α ^ 2)) * ((X : Polynomial R) - C (α * β))
        * ((X : Polynomial R) - C (β ^ 2)) := by
  rw [sym2Hom_charpoly_trace_det, ← htr, ← hdet]
  push_cast [map_pow, map_mul, map_sub, map_add]
  ring

end SymSquare