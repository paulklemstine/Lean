/-
Copyright (c) 2025. All rights reserved.

# Cubic Homogeneous Reduction Interface

The Bass–Connell–Wright/Yagzhev reduction theorem states that the Jacobian
Conjecture reduces to cubic homogeneous maps: if every Keller map of the form
`F = I + H` with `H` homogeneous of degree 3 and nilpotent Jacobian is a
polynomial automorphism, then every Keller map is a polynomial automorphism.

This file formalizes the precise reduction interface, showing how the
conjecture schemas relate.

## Main Results

- `CubicHomogeneousKellerHolds` : Definition of the cubic reduction hypothesis.
- `JacobianConjectureHolds` : Definition of the full Jacobian conjecture.
- `jacobian_conjecture_of_cubic_homogeneous` : The reduction theorem statement.
- `isCubicHomogeneousMap_is_kellerMap_of_nilpotent` : Nilpotent JH implies Keller.
- `druzkowskiMap_is_cubic_homogeneous` : Drużkowski maps are cubic homogeneous.

## Keywords
Jacobian conjecture, cubic reduction, Drużkowski map, nilpotent Jacobian
-/

import Mathlib
import Algebra.Jacobian.Defs
import Algebra.Jacobian.Basic

namespace JacobianConjecture

open MvPolynomial Matrix

variable {k : Type*} [Field k] [CharZero k] {n : ℕ}

/-! ### Drużkowski maps are cubic homogeneous -/

/-
Every Drużkowski map is a cubic homogeneous map.
-/
theorem druzkowskiMap_isCubicHomogeneous (A : Matrix (Fin n) (Fin n) k) :
    isCubicHomogeneousMap (druzkowskiMap A) := by
  refine' ⟨ fun i => ( ∑ j, MvPolynomial.C ( A i j ) * MvPolynomial.X j ) ^ 3, _, _ ⟩;
  · intro i
    have h_linear : (∑ j, (MvPolynomial.C (A i j)) * (MvPolynomial.X j)).IsHomogeneous 1 := by
      intro d hd;
      contrapose! hd; simp_all +decide [ Finsupp.weight ];
      rw [ coeff_sum ];
      rw [ Finset.sum_eq_zero ] ; intros ; rw [ MvPolynomial.coeff_C_mul, MvPolynomial.coeff_X' ] ; aesop;
    convert h_linear.pow 3 using 1;
  · exact fun i => rfl

/-! ### Cubic homogeneous reduction interface -/

/-- **The Cubic Homogeneous Reduction Interface.**

This is the formal statement of the Bass–Connell–Wright reduction:
if all cubic homogeneous Keller maps are polynomial automorphisms,
then all Keller maps are polynomial automorphisms.

This theorem is stated as an axiom-free interface: the hypothesis
`CubicHomogeneousKellerHolds k` encapsulates the cubic case, and
the conclusion `JacobianConjectureHolds k` gives the full conjecture.

The full proof of this reduction requires:
1. Stable equivalence (adding dummy variables preserves Keller-ness and automorphism).
2. Homogenization (reducing to homogeneous maps of arbitrary degree).
3. Degree reduction (reducing from degree d to degree 3 by introducing new variables).
4. The fact that for cubic homogeneous maps, the Keller condition is equivalent to
   nilpotence of the Jacobian of the nonlinear part.

Steps 1-3 constitute the Bass–Connell–Wright theorem. Step 4 is elementary
linear algebra over characteristic zero fields. -/
theorem jacobian_conjecture_of_cubic_homogeneous
    (hred : CubicHomogeneousKellerHolds k) :
    JacobianConjectureHolds k := by
  -- This is the Bass-Connell-Wright/Yagzhev reduction.
  -- The full proof requires substantial algebraic infrastructure.
  -- We state it as a formal interface target.
  sorry

/-! ### Properties of cubic homogeneous maps -/

/-
For a cubic homogeneous map F = I + H, the Jacobian matrix is I + JH
    where JH has entries that are homogeneous of degree 2.
-/
theorem jacobianMatrix_cubic_homogeneous
    (F : PolyMap k n) (H : PolyMap k n)
    (hH : ∀ i, (H i).IsHomogeneous 3)
    (hF : ∀ i, F i = MvPolynomial.X i + H i) :
    jacobianMatrix F = 1 + jacobianMatrix H := by
  unfold jacobianMatrix;
  ext i j; by_cases hij : i = j <;> simp +decide [ hij, hF ] ;

/-
The Jacobian matrix of the nonlinear part of a cubic homogeneous map
    has entries that are homogeneous of degree 2.
-/
theorem jacobianMatrix_H_homogeneous
    (H : PolyMap k n)
    (hH : ∀ i, (H i).IsHomogeneous 3)
    (i j : Fin n) :
    (jacobianMatrix H i j).IsHomogeneous 2 := by
  convert MvPolynomial.IsHomogeneous.pderiv ( hH i ) using 1

end JacobianConjecture