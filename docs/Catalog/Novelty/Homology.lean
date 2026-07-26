/-
# Homotopy / homology obstruction toolkit

This file packages the algebraic-topological invariant that detects the
obstruction in the line-transversal classification.

The geometric obstruction to the transversal space having the homotopy type of a
sphere lives in the *first homology group of the configuration space*.  In Mathlib
the available homotopy invariant at this level is the **fundamental groupoid**,
whose abelianization is exactly the first homology group `H₁` (Hurewicz).  The key
fact we re-export is that a homotopy equivalence induces an *equivalence of
fundamental groupoids*; consequently any homotopy invariant computed from the
fundamental groupoid (in particular `H₁`) agrees on homotopy-equivalent spaces.

We use this in `FINAL.LineTransversal` to phrase the obstruction: if the
transversal space had the homotopy type of the sphere, its fundamental groupoid —
and hence its first homology group — would coincide with that of the sphere.
-/
import Mathlib
import Mathlib.AlgebraicTopology.FundamentalGroupoid.InducedMaps

open scoped ContinuousMap
open CategoryTheory

namespace FINAL.Homology

variable {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]

/-- The fundamental groupoid of a topological space, as the value of Mathlib's
fundamental-groupoid functor.  Its abelianization is the first singular homology
group `H₁`. -/
noncomputable abbrev fundamentalGroupoidObj (X : Type*) [TopologicalSpace X] :=
  FundamentalGroupoid.fundamentalGroupoidFunctor.obj ⟨X⟩

/-- **Homotopy invariance of the fundamental groupoid.**
A homotopy equivalence `X ≃ₕ Y` induces an equivalence of fundamental groupoids.
Since the first homology group is the abelianization of the fundamental groupoid's
automorphism group, homotopy-equivalent spaces have isomorphic `H₁`. -/
theorem fundamentalGroupoid_equiv_of_homotopyEquiv (e : X ≃ₕ Y) :
    Nonempty (fundamentalGroupoidObj X ≌ fundamentalGroupoidObj Y) :=
  ⟨FundamentalGroupoidFunctor.equivOfHomotopyEquiv e⟩

end FINAL.Homology