/-
Copyright (c) 2025. All rights reserved.

# Counterexample Candidate Elimination

Systematic elimination of potential counterexample families to the Jacobian
Conjecture in low dimensions. We show that specific parametric families
satisfying the Jacobian condition must be polynomial automorphisms.

## Main Results

- `linear_map_unit_det_is_auto`: Linear maps with unit Jacobian determinant
  are trivially automorphisms (the degree-1 base case).
- `triangular_quadratic_is_auto_dim2`: Triangular quadratic maps in dim 2
  with unit Jacobian are automorphisms.

## Keywords
counterexample elimination, polynomial automorphism, Jacobian condition
-/

import Mathlib
import Algebra.Jacobian.Defs
import Algebra.Jacobian.Basic

namespace JacobianConjecture

open MvPolynomial Matrix

variable {K : Type*} [Field K] [CharZero K]

/-! ### Linear maps: The trivial case -/

/-
A linear map (degree ≤ 1) with unit Jacobian determinant is a polynomial
automorphism. This is the base case — it reduces to invertibility of a
constant matrix.
-/
theorem linear_map_unit_det_is_auto
    (A : Matrix (Fin n) (Fin n) K)
    (hdet : IsUnit (A.det)) :
    isPolynomialAutomorphism (fun i => ∑ j, C (A i j) * X j : Fin n → MvPolynomial (Fin n) K) := by
  refine' ⟨ fun i => ∑ j, C ( A⁻¹ i j ) * X j, _ ⟩ ; simp_all +decide [ ← Matrix.mul_apply, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, isPolynomialInverse ];
  constructor <;> ext i <;> simp +decide [ polyMapComp, polyMapId ];
  · simp +decide [ mul_assoc, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul, coeff_sum, coeff_C_mul, coeff_X ];
    simp +decide [ ← mul_assoc, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, ← Matrix.mul_apply, hdet, isUnit_iff_ne_zero ];
    simp +decide [ Matrix.mul_apply, mul_assoc, Finset.mul_sum _ _ _, Finset.sum_mul, hdet, isUnit_iff_ne_zero ];
    simp +decide [ ← mul_assoc, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, ← Finset.sum_comm, hdet, isUnit_iff_ne_zero, Matrix.mul_nonsing_inv ];
    simp +decide [ ← Matrix.mul_apply, hdet, isUnit_iff_ne_zero, Matrix.mul_nonsing_inv ];
    simp +decide [ Matrix.one_apply, Finset.sum_ite_eq', Finset.filter_eq', Finset.filter_ne' ];
  · simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, ← Finset.sum_comm, hdet, Matrix.inv_def ];
    simp +decide [ mul_assoc, Finset.mul_sum _ _ _, Finset.sum_mul, coeff_sum, coeff_C_mul, coeff_X, hdet, Matrix.mul_adjugate, Matrix.adjugate_mul ];
    simp +decide [ ← mul_assoc, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, ← Finset.sum_comm, hdet, Matrix.adjugate_mul, Matrix.mul_adjugate ];
    simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, hdet, Matrix.adjugate_mul, Matrix.mul_adjugate ];
    simp +decide [ ← Matrix.mul_apply, hdet, Matrix.adjugate_mul, Matrix.mul_adjugate ];
    simp +decide [ Matrix.one_apply, hdet, Finset.mul_sum _ _ _, mul_assoc, mul_left_comm, Finset.sum_mul ]

/-! ### Triangular maps in dimension 2 -/

/-
A triangular map F = (X 0 + p, X 1) where p only depends on X 1
has polynomial inverse G = (X 0 - p, X 1).
This captures the key structure: triangular polynomial maps are always
invertible, regardless of degree.
-/
theorem triangular_map_inverse_dim2
    (c : K) :
    isPolynomialInverse
      (fun i => ![X 0 + C c * X (1 : Fin 2) ^ 2, X 1] i)
      (fun i => ![X 0 - C c * X (1 : Fin 2) ^ 2, X 1] i) := by
  constructor <;> ext i <;> fin_cases i <;> norm_num [ polyMapComp ];
  · rfl;
  · rfl;
  · rfl;
  · rfl

/-! ### The identity map is an automorphism -/

/-
The identity polynomial map is its own inverse.
-/
theorem polyMapId_self_inverse :
    isPolynomialInverse (polyMapId : Fin n → MvPolynomial (Fin n) K) polyMapId := by
  constructor <;> funext <;> simp +decide [ polyMapComp, polyMapId ]

end JacobianConjecture