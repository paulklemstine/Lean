/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic
-/
import Mathlib
import Geometry.KnotTheory.Defs

/-!
# The graded Euler state sum underlying Khovanov homology

This file formalizes the decategorification calculation for an arbitrary link
diagram.  A Khovanov generator consists of a smoothing state together with a
choice of one of the two quantum basis vectors on every resulting circle.  The
main theorem proves that the graded Euler sum of these generators is the
corresponding Jones state sum.
-/

namespace Knot.Khovanov

open Finset LaurentPolynomial

/-- A Khovanov cube generator is a smoothing state and a binary enhancement of
all circles in that smoothing.  `true` denotes the basis vector of degree `1`
and `false` the basis vector of degree `-1`. -/
abbrev Generator {n : ℕ} (D : Knot.LinkDiagram n) :=
  Σ s : Knot.KState n, Fin (D.loops s) → Bool

/-- The quantum degree contributed by the circle labels of an enhancement. -/
def enhancementDegree {m : ℕ} (e : Fin m → Bool) : ℤ :=
  ∑ i, if e i then 1 else -1

/-- The homological degree of a cube generator is its number of `B`-smoothings. -/
def homologicalDegree {n : ℕ} {D : Knot.LinkDiagram n} (g : Generator D) : ℕ :=
  Knot.numB g.1

/-- The quantum degree is the smoothing shift plus the degrees of all enhanced
circles. -/
def quantumDegree {n : ℕ} {D : Knot.LinkDiagram n} (g : Generator D) : ℤ :=
  (Knot.numA g.1 : ℤ) - (Knot.numB g.1 : ℤ) + enhancementDegree g.2

/-- The graded Euler sum of the Khovanov cube generators. -/
noncomputable def gradedEulerCharacteristic {n : ℕ} (D : Knot.LinkDiagram n) :
    LaurentPolynomial ℤ :=
  ∑ g : Generator D, (-1 : LaurentPolynomial ℤ) ^ homologicalDegree g * T (quantumDegree g)

/-- The Jones state sum in the normalization naturally produced by the
Khovanov cube: each smoothing circle contributes `q + q⁻¹`. -/
noncomputable def jonesStateSum {n : ℕ} (D : Knot.LinkDiagram n) :
    LaurentPolynomial ℤ :=
  ∑ s : Knot.KState n,
    (-1 : LaurentPolynomial ℤ) ^ Knot.numB s *
      T ((Knot.numA s : ℤ) - (Knot.numB s : ℤ)) *
      (T 1 + T (-1)) ^ D.loops s

/-- Splitting off the label of the first circle identifies enhancements of
`m + 1` circles with a label and an enhancement of `m` circles. -/
def enhancementSuccEquiv (m : ℕ) :
    (Fin (m + 1) → Bool) ≃ Bool × (Fin m → Bool) where
  toFun e := (e 0, fun i => e i.succ)
  invFun p := Fin.cons p.1 p.2
  left_inv e := by
    funext i
    refine Fin.cases ?_ (fun j => ?_) i
    · rfl
    · rfl
  right_inv p := by
    cases p
    rfl

/-- The enhancement degree splits into the degree of the first circle and the
degree of the remaining circles. -/
theorem enhancementDegree_cons {m : ℕ} (b : Bool) (e : Fin m → Bool) :
    enhancementDegree (Fin.cons b e) =
      (if b then 1 else -1) + enhancementDegree e := by
  simp [enhancementDegree, Fin.sum_univ_succ]

/-- Summing the quantum monomial over all binary enhancements of `m` circles
produces the `m`-th power of the quantum dimension `q + q⁻¹`. -/
theorem enhancement_state_sum (m : ℕ) :
    ∑ e : Fin m → Bool, T (enhancementDegree e) =
      (T 1 + T (-1) : LaurentPolynomial ℤ) ^ m := by
  induction m with
  | zero => simp [enhancementDegree]
  | succ m ih =>
      rw [Fintype.sum_equiv (enhancementSuccEquiv m)
        (fun e => T (enhancementDegree e))
        (fun p => T ((if p.1 then 1 else -1) + enhancementDegree p.2))]
      · rw [Fintype.sum_prod_type]
        simp only [T_add, Fintype.sum_bool, if_true,
          Bool.false_eq_true, if_false]
        rw [← Finset.mul_sum, ← Finset.mul_sum, ih, pow_succ']
        ring
      · intro e
        rw [← enhancementDegree_cons]
        exact congrArg (fun x => T (enhancementDegree x))
          ((enhancementSuccEquiv m).left_inv e).symm

/-- For every combinatorial link diagram, the graded Euler characteristic of
its Khovanov cube generators equals its Jones state sum.  This is the finite
state-sum identity at the heart of Khovanov categorification. -/
theorem gradedEulerCharacteristic_eq_jonesStateSum {n : ℕ}
    (D : Knot.LinkDiagram n) :
    gradedEulerCharacteristic D = jonesStateSum D := by
  unfold gradedEulerCharacteristic jonesStateSum
  rw [Fintype.sum_sigma]
  apply Finset.sum_congr rfl
  intro s _
  simp only [homologicalDegree, quantumDegree, T_add]
  rw [← Finset.mul_sum, ← Finset.mul_sum, enhancement_state_sum]
  ring

/-- The writhe-normalized graded Euler characteristic of an oriented diagram. -/
noncomputable def orientedGradedEulerCharacteristic {n : ℕ}
    (D : Knot.OrientedLinkDiagram n) : LaurentPolynomial ℤ :=
  T (-3 * D.writhe) * gradedEulerCharacteristic D.toLinkDiagram

/-- The writhe-normalized Jones state sum of an oriented diagram. -/
noncomputable def orientedJonesStateSum {n : ℕ}
    (D : Knot.OrientedLinkDiagram n) : LaurentPolynomial ℤ :=
  T (-3 * D.writhe) * jonesStateSum D.toLinkDiagram

/-- For every oriented combinatorial link diagram, the writhe-normalized graded
Euler characteristic of its Khovanov cube equals its normalized Jones state
sum. -/
theorem orientedGradedEulerCharacteristic_eq_orientedJonesStateSum {n : ℕ}
    (D : Knot.OrientedLinkDiagram n) :
    orientedGradedEulerCharacteristic D = orientedJonesStateSum D := by
  unfold orientedGradedEulerCharacteristic orientedJonesStateSum
  rw [gradedEulerCharacteristic_eq_jonesStateSum]

/-- The zero-crossing unknot has graded Euler characteristic `q + q⁻¹`. -/
theorem gradedEulerCharacteristic_unknot :
    gradedEulerCharacteristic Knot.unknotDiagram = T 1 + T (-1) := by
  rw [gradedEulerCharacteristic_eq_jonesStateSum]
  simp [jonesStateSum, Knot.unknotDiagram, Knot.numA, Knot.numB]

end Knot.Khovanov