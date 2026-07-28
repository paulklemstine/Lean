import Mathlib

/-!
# An affine Jacobian–Weyl algebra bridge

The Jacobian and Dixmier conjectures are linked by a classical passage between
commutative polynomial maps and endomorphisms of Weyl algebras.  This file proves
a fully explicit degree-one instance of that connection.

For an affine polynomial map

`F(X,Y) = (aX + bY + c, dX + eY + f)`,

the commutative Jacobian determinant is `a*e - b*d`.  In every (possibly
noncommutative) rational algebra, replacing `X,Y` by elements `x,y` gives

`[F₁(x,y), F₀(x,y)] = (a*e - b*d) • [y,x]`.

Consequently, Jacobian determinant one transports the Weyl relation `[y,x]=1`.
This is a precise bridge from commutative algebraic geometry to noncommutative
ring theory: the same determinant controls preservation of both area and the
canonical Weyl commutator.
-/

open MvPolynomial

namespace JacobianConjecture.AffineWeylBridge

/-- The additive commutator `[x,y] = xy-yx` in a ring. -/
def commutator {A : Type*} [Ring A] (x y : A) : A := x * y - y * x

/-- A pair satisfying the first Weyl-algebra relation, in the orientation
`[y,x]=1`. -/
def IsWeylPair {A : Type*} [Ring A] (x y : A) : Prop :=
  commutator y x = 1

/-- Evaluation of an affine linear expression at two elements of a rational
algebra.  The ambient algebra need not be commutative. -/
def affineImage {A : Type*} [Ring A] [Algebra ℚ A]
    (a b c : ℚ) (x y : A) : A :=
  a • x + b • y + c • 1

/-- The two-variable affine polynomial map with coefficient matrix
`!![a,b; d,e]`. -/
noncomputable def affinePolynomialMap (a b c d e f : ℚ) :
    Fin 2 → MvPolynomial (Fin 2) ℚ
  | 0 => C a * X 0 + C b * X 1 + C c
  | 1 => C d * X 0 + C e * X 1 + C f

/-- The polynomial Jacobian matrix of a two-variable polynomial map. -/
noncomputable def polynomialJacobian
    (F : Fin 2 → MvPolynomial (Fin 2) ℚ) :
    Matrix (Fin 2) (Fin 2) (MvPolynomial (Fin 2) ℚ) :=
  Matrix.of fun i j => pderiv j (F i)

/-- The polynomial Jacobian determinant. -/
noncomputable def jacobianDeterminant
    (F : Fin 2 → MvPolynomial (Fin 2) ℚ) : MvPolynomial (Fin 2) ℚ :=
  (polynomialJacobian F).det

/-- The commutative calculation: the affine map's Jacobian determinant is its
ordinary coefficient determinant. -/
theorem affine_jacobianDeterminant (a b c d e f : ℚ) :
    jacobianDeterminant (affinePolynomialMap a b c d e f) = C (a * e - b * d) := by
  unfold jacobianDeterminant polynomialJacobian
  rw [Matrix.det_fin_two]
  simp only [Matrix.of_apply, affinePolynomialMap, map_add, pderiv_mul, pderiv_C,
    pderiv_X, Pi.single_apply, Fin.reduceEq, if_true, if_false, zero_mul, mul_zero,
    add_zero, mul_one, zero_add]
  rw [← map_mul, ← map_mul, ← map_sub]

/-- The noncommutative calculation: affine substitution scales the canonical
commutator by exactly the same determinant that occurs in the Jacobian. -/
theorem affine_commutator (A : Type*) [Ring A] [Algebra ℚ A]
    (x y : A) (a b c d e f : ℚ) :
    commutator (affineImage d e f x y) (affineImage a b c x y) =
      (a * e - b * d) • commutator y x := by
  simp only [commutator, affineImage, add_mul, mul_add, smul_mul_assoc, mul_smul_comm,
    one_mul, mul_one, sub_eq_add_neg, smul_add]
  module

/-- **Affine Jacobian–Weyl bridge.** If the commutative affine polynomial map
has Jacobian determinant one, then its substitution into any Weyl pair in any
rational algebra again satisfies the Weyl relation. -/
theorem jacobian_one_preserves_weyl_relation
    (A : Type*) [Ring A] [Algebra ℚ A]
    (x y : A) (a b c d e f : ℚ)
    (hWeyl : IsWeylPair x y)
    (hJac : jacobianDeterminant (affinePolynomialMap a b c d e f) = 1) :
    IsWeylPair (affineImage a b c x y) (affineImage d e f x y) := by
  have hdet : a * e - b * d = 1 := by
    have hconst : (C (a * e - b * d) : MvPolynomial (Fin 2) ℚ) = C (1 : ℚ) := by
      rw [← affine_jacobianDeterminant a b c d e f, hJac]
      rfl
    exact C_injective (Fin 2) ℚ hconst
  unfold IsWeylPair
  rw [affine_commutator, hdet, one_smul, hWeyl]

/-- A coefficient-level form of the bridge, useful independently of the
polynomial encoding. -/
theorem determinant_one_preserves_weyl_relation
    (A : Type*) [Ring A] [Algebra ℚ A]
    (x y : A) (a b c d e f : ℚ)
    (hWeyl : IsWeylPair x y) (hdet : a * e - b * d = 1) :
    IsWeylPair (affineImage a b c x y) (affineImage d e f x y) := by
  unfold IsWeylPair
  rw [affine_commutator, hdet, one_smul, hWeyl]

end JacobianConjecture.AffineWeylBridge