/-
Copyright (c) 2025. All rights reserved.

# Jacobian Conjecture: Basic Lemmas

Fundamental properties of the Jacobian matrix and polynomial map infrastructure.

## Keywords
Jacobian matrix, polynomial map, partial derivative, composition
-/

import Mathlib
import Algebra.Jacobian.Defs

namespace JacobianConjecture

open MvPolynomial Matrix

variable {K : Type*} [CommRing K] {n : ℕ}

/-! ### Jacobian of the identity map -/

/-
The Jacobian matrix of the identity map is the identity matrix.
-/
theorem jacobianMatrix_id :
    jacobianMatrix (polyMapId : Fin n → MvPolynomial (Fin n) K) = 1 := by
  ext i j; simp +decide [ jacobianMatrix, polyMapId ] ;
  by_cases hij : i = j <;> simp +decide [ hij, Pi.single_apply, Matrix.one_apply ]

/-
The Jacobian determinant of the identity map is 1.
-/
theorem jacobianDet_id :
    jacobianDet (polyMapId : Fin n → MvPolynomial (Fin n) K) = 1 := by
  unfold jacobianDet;
  convert Matrix.det_one;
  convert jacobianMatrix_id;
  infer_instance

/-! ### Composition with identity -/

/-
Composing with identity on the right is the identity.
-/
theorem polyMapComp_id_right (F : Fin n → MvPolynomial (Fin n) K) :
    polyMapComp F polyMapId = F := by
  exact funext fun i => by unfold polyMapComp polyMapId; simp +decide [ MvPolynomial.bind₁_X_right ] ;

/-
Composing with identity on the left is the identity.
-/
theorem polyMapComp_id_left (F : Fin n → MvPolynomial (Fin n) K) :
    polyMapComp polyMapId F = F := by
  exact funext fun i => by simp +decide [ polyMapComp, polyMapId ] ;

/-
bind₁ of X is the identity.
-/
theorem bind1_X_eq_id (p : MvPolynomial (Fin n) K) :
    MvPolynomial.bind₁ (fun i => (X i : MvPolynomial (Fin n) K)) p = p := by
  aesop

end JacobianConjecture