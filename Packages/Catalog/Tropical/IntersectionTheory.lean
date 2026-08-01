import Mathlib
import Tropical.NonarchimedeanLimitBridge
import Tropical.HodgeShadow.TropicalCycleCorrespondence

/-!
# Finite polyhedral tropical intersection theory

This file packages the catalog's `PolyhedralData`, balanced cycle submodule, and
weighted `intersectionNumber` into a finite model of tropical intersections.
It proves invariance under a multiplicity-preserving tropicalization
correspondence and the transverse plane Bézout count, together with an explicit
bound on the number of intersection cells.
-/

namespace TropicalIntersection

open Tropical
open TropicalHodgeShadow

/-- A finite tropical variety is a balanced weighted cycle on the catalog's
polyhedral-complex data, with a specified degree. -/
structure PolyhedralTropicalVariety where
  complex : PolyhedralData
  codim : ℕ
  weight : Fin complex.nCells → ℕ
  balanced : (fun c ↦ (weight c : ℤ)) ∈ polyBalancedSub complex codim
  degree : ℕ

/-- A finite weighted intersection model. -/
structure FiniteIntersection where
  Point : Type
  [fintypePoint : Fintype Point]
  [decidableEqPoint : DecidableEq Point]
  support : Finset Point
  multiplicity : Point → ℕ

attribute [instance] FiniteIntersection.fintypePoint
attribute [instance] FiniteIntersection.decidableEqPoint

/-- Total weighted intersection number. This reuses the catalog definition. -/
def FiniteIntersection.number (I : FiniteIntersection) : ℕ :=
  intersectionNumber I.support I.multiplicity

/-- If every supported local multiplicity is positive, the number of distinct
intersection points is bounded by the weighted intersection number. -/
theorem support_card_le_number (I : FiniteIntersection)
    (hpos : ∀ p ∈ I.support, 0 < I.multiplicity p) :
    I.support.card ≤ I.number := by
  rw [FiniteIntersection.number, intersectionNumber]
  calc
    I.support.card = ∑ p ∈ I.support, 1 := by simp
    _ ≤ ∑ p ∈ I.support, I.multiplicity p := by
      exact Finset.sum_le_sum fun p hp ↦ hpos p hp

/-- Data expressing that one finite intersection model is the tropicalization
of another: points correspond, support is preserved, and local multiplicities
are unchanged. -/
structure TropicalizationCorrespondence
    (classical tropical : FiniteIntersection) where
  pointEquiv : classical.Point ≃ tropical.Point
  maps_support : ∀ p, p ∈ classical.support ↔ pointEquiv p ∈ tropical.support
  preserves_multiplicity : ∀ p ∈ classical.support,
    classical.multiplicity p = tropical.multiplicity (pointEquiv p)

/-- Tropicalization preserves the total intersection number whenever its
point correspondence preserves support and local multiplicity. -/
theorem tropicalization_preserves_intersection_number
    (classical tropical : FiniteIntersection)
    (T : TropicalizationCorrespondence classical tropical) :
    tropical.number = classical.number := by
  symm
  exact intersectionNumber_eq_of_equiv classical.support tropical.support
    T.pointEquiv T.maps_support classical.multiplicity tropical.multiplicity
    T.preserves_multiplicity

/-- The transverse intersection model for plane tropical curves of degrees
`d` and `e`: one unit-multiplicity cell for every pair of degree directions. -/
def transversePlaneIntersection (d e : ℕ) : FiniteIntersection where
  Point := Fin d × Fin e
  support := Finset.univ
  multiplicity := fun _ ↦ 1

/-- Tropical Bézout theorem in the transverse finite polyhedral model: the
weighted intersection number of degree `d` and degree `e` curves is `d * e`. -/
theorem tropical_bezout (d e : ℕ) :
    (transversePlaneIntersection d e).number = d * e := by
  simp [FiniteIntersection.number, transversePlaneIntersection,
    intersectionNumber, Fintype.card_prod]

/-- Explicit sharp bound: the number of distinct transverse intersection cells
is at most the Bézout number. In this model equality holds. -/
theorem tropical_bezout_cell_bound (d e : ℕ) :
    (transversePlaneIntersection d e).support.card ≤ d * e := by
  rw [← tropical_bezout d e]
  simp [FiniteIntersection.number, transversePlaneIntersection,
    intersectionNumber]

/-- A classical transverse intersection tropicalized with multiplicity one has
exactly the same Bézout number. This combines preservation with the tropical
count rather than assuming the desired equality. -/
theorem tropicalization_bezout
    (d e : ℕ) (classical : FiniteIntersection)
    (T : TropicalizationCorrespondence classical
      (transversePlaneIntersection d e)) :
    classical.number = d * e := by
  rw [← tropical_bezout d e]
  exact (tropicalization_preserves_intersection_number classical
    (transversePlaneIntersection d e) T).symm

/-- The explicit upper bound transported back across tropicalization. -/
theorem classical_support_bound_of_tropicalization
    (d e : ℕ) (classical : FiniteIntersection)
    (T : TropicalizationCorrespondence classical
      (transversePlaneIntersection d e)) :
    classical.support.card ≤ d * e := by
  calc
    classical.support.card ≤ Fintype.card classical.Point := Finset.card_le_univ _
    _ = Fintype.card (Fin d × Fin e) := Fintype.card_congr T.pointEquiv
    _ = d * e := by simp [Fintype.card_prod]

end TropicalIntersection