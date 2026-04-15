/-! # CatalogBuild.Logic.HigherDimensional

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 10
-/

import Mathlib

noncomputable section

/-- The stereographic chart is a `PartialHomeomorph`, hence its forward and inverse
maps compose to the identity on the source set. This is the general idempotent
lens property. -/
theorem stereographic_round_trip {v : E} (hv : ‖v‖ = 1) :
    ∀ p ∈ (stereographic (E := E) hv).source,
      (stereographic hv).symm ((stereographic hv) p) = p :=
  fun p hp => (stereographic hv).left_inv hp


/-- The dual round-trip: from the orthogonal complement through the sphere and back
is also the identity, on the target set. -/
theorem stereographic_dual_round_trip {v : E} (hv : ‖v‖ = 1) :
    ∀ w ∈ (stereographic (E := E) hv).target,
      (stereographic hv) ((stereographic hv).symm w) = w :=
  fun w hw => (stereographic hv).right_inv hw


/-- [Section: ## The Conformal Factor
The key to understanding stereographic projection as a "lens" is its conformal factor:
the local scaling at each point. For projection from the north pole (0,...,0,1) of Sⁿ
to ℝⁿ, the conformal factor at a point with last coordinate y is 2/(1-y).
This factor tells us "how much the lens magnifies" at each point:
- Near the south pole (y ≈ -1): factor ≈ 1 (unit magnification)
- Near the equator (y ≈ 0): factor ≈ 2 (double magnification)
- Near the north pole (y → 1): factor → ∞ (infinite magnification)
The north pole maps to infinity — "the point at infinity IS the gap in our lens."] -/
theorem conformal_factor_pos (y : ℝ) (hy : y < 1) : (2 : ℝ) / (1 - y) > 0 := by
  exact div_pos zero_lt_two ( sub_pos.mpr hy )


theorem conformal_factor_south_pole : (2 : ℝ) / (1 - (-1 : ℝ)) = 1 := by
  norm_num +zetaDelta at *


theorem conformal_factor_equator : (2 : ℝ) / (1 - (0 : ℝ)) = 2 := by
  grind


/-- A Möbius transformation of the real line (as a fractional linear transformation). -/
structure MoebiusTransform where
  a : ℝ
  b : ℝ
  c : ℝ
  d : ℝ
  det_ne_zero : a * d - b * c ≠ 0


/-- Apply a Möbius transformation. -/
def MoebiusTransform.apply (M : MoebiusTransform) (t : ℝ) : ℝ :=
  (M.a * t + M.b) / (M.c * t + M.d)


/-- The identity Möbius transformation. -/
def MoebiusTransform.id : MoebiusTransform where
  a := 1
  b := 0
  c := 0
  d := 1
  det_ne_zero := by norm_num


/-- [Section: ## Möbius Transformations: The Symmetries of the Lens
The conformal automorphisms of the sphere (equivalently, the Möbius transformations
of ℝⁿ ∪ {∞}) form a group. These are the "rotations" of the lens — they change the
viewing angle without distorting the essential structure.
On the circle S¹, these are the fractional linear transformations:
z ↦ (az + b) / (cz + d) with ad - bc ≠ 0
Each Möbius transformation can be decomposed as:
σ ∘ (rotation of sphere) ∘ σ⁻¹] -/
theorem MoebiusTransform.id_apply (t : ℝ) :
    MoebiusTransform.id.apply t = t := by
      exact show ( 1 * t + 0 ) / ( 0 * t + 1 ) = t from by norm_num;


/-- The inversion map t ↦ -1/t is a Möbius transformation.
This is the map that stereographic projection conjugates the antipodal map to. -/
def MoebiusTransform.inversion : MoebiusTransform where
  a := 0
  b := -1
  c := 1
  d := 0
  det_ne_zero := by norm_num


end
