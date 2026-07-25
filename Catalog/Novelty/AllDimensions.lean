/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib

/-!
# The mega-sphere: a product of algebraic spheres in every finite dimension

There is no canonical inverse system containing one sphere of every dimension: an inverse
limit requires specified bonding maps, and no such maps occur in the prompt.  This file gives
a precise and unconditional construction instead.  Regard the spheres as a discrete diagram in
`Type`; its limit is their product.  Thus one object has a jointly faithful projection to every
sphere, with the expected universal property.

The spheres here are algebraic unit spheres: tuples of reals whose sum of squared coordinates is
one.  We also prove an equivariant universal property for antipodal maps, fixed-point-freeness of
the simultaneous antipodal action, and a splitting into the zero-sphere and the positive-dimensional
tail.
-/

open scoped BigOperators
open CategoryTheory
open CategoryTheory.Limits

namespace MegaSphere

/-- The algebraic unit `n`-sphere in `ℝⁿ⁺¹`. -/
def AlgebraicSphere (n : ℕ) :=
  {x : Fin (n + 1) → ℝ // ∑ i, (x i) ^ 2 = 1}

/-- The single object carrying points in all finite-dimensional spheres simultaneously. -/
def AllSpheres := (n : ℕ) → AlgebraicSphere n

/-- Projection to the sphere of dimension `n`. -/
def project (n : ℕ) (x : AllSpheres) : AlgebraicSphere n := x n

/-- A canonical point on every algebraic sphere. -/
def north (n : ℕ) : AlgebraicSphere n :=
  ⟨fun i => if i = 0 then 1 else 0, by
    classical
    rw [Fin.sum_univ_succ]
    simp⟩

/-- The mega-sphere is inhabited by choosing the north pole in every dimension. -/
def allNorth : AllSpheres := fun n => north n

/-
The family of all projections is jointly injective.
-/
theorem project_jointly_injective {x y : AllSpheres}
    (h : ∀ n, project n x = project n y) : x = y := by
  exact funext h

/-
Maps into the mega-sphere are exactly dimension-indexed families of maps into spheres.
This is the elementwise universal property of the product.
-/
def mapFamilyEquiv (X : Type) :
    (X → AllSpheres) ≃ ((n : ℕ) → X → AlgebraicSphere n) where
  toFun f n x := project n (f x)
  invFun g x n := g n x
  left_inv f := by
    exact funext fun x => funext fun n => rfl
  right_inv g := by
    exact funext fun n => funext fun x => rfl

/-- The diagram containing one sphere in each dimension and no nonidentity arrows. -/
def sphereDiagram : Discrete ℕ ⥤ Type := Discrete.functor AlgebraicSphere

/-- The cone whose legs are all coordinate projections. -/
def allSpheresCone : Cone sphereDiagram :=
  Cone.mk AllSpheres
    { app := fun n => project n.as
      naturality := by
        rintro ⟨i⟩ ⟨j⟩ f
        have h : i = j := Discrete.eq_of_hom f
        subst j
        simp }

/-- **Existence theorem for the mega-sphere.**  The simultaneous projection cone is a limit
of the discrete diagram of all algebraic spheres in `Type`. -/
def allSpheresConeIsLimit : IsLimit allSpheresCone where
  lift s x n := s.π.app ⟨n⟩ x
  fac s n := by
    funext x
    rfl
  uniq s m h := by
    funext x n
    have hn := congrFun (h ⟨n⟩) x
    exact hn

/-- Antipodal involution on an algebraic sphere. -/
def antipode {n : ℕ} (x : AlgebraicSphere n) : AlgebraicSphere n :=
  ⟨fun i => -x.1 i, by simpa using x.2⟩

/-- Simultaneous antipodal involution on all sphere coordinates. -/
def allAntipode (x : AllSpheres) : AllSpheres := fun n => antipode (x n)

@[simp] theorem antipode_involutive {n : ℕ} (x : AlgebraicSphere n) :
    antipode (antipode x) = x := by
  exact Subtype.ext <| funext fun i => neg_neg _

@[simp] theorem allAntipode_involutive (x : AllSpheres) :
    allAntipode (allAntipode x) = x := by
  exact funext fun n => Subtype.ext <| funext fun i => neg_neg _

/-
Every projection intertwines the simultaneous and ordinary antipodal maps.
-/
theorem project_antipode (n : ℕ) (x : AllSpheres) :
    project n (allAntipode x) = antipode (project n x) := by
  rfl

/-
No point of any real algebraic sphere is fixed by its antipodal map.
-/
theorem antipode_ne_self {n : ℕ} (x : AlgebraicSphere n) : antipode x ≠ x := by
  intro h
  have hsum : ∑ i, (x.val i) ^ 2 = 0 := by
    convert congr_arg (fun y : AlgebraicSphere n => ∑ i, (y.val i) ^ 2) h using 1
    · rw [h]
    · have hv := congr_arg Subtype.val h
      norm_num [funext_iff] at hv
      exact Eq.symm (Finset.sum_eq_zero fun i _ => by
        have hi := hv i
        norm_num [antipode] at hi
        nlinarith)
  linarith [x.2, hsum]

/-
Consequently, the simultaneous antipodal action on the mega-sphere is free.
-/
theorem allAntipode_ne_self (x : AllSpheres) : allAntipode x ≠ x := by
  intro h
  apply antipode_ne_self (x 0)
  exact congrFun h 0

/-
Equivariant maps into the mega-sphere are assembled coordinatewise from equivariant maps.
-/
theorem assemble_equivariant {X : Type} (a : X → X)
    (f : (n : ℕ) → X → AlgebraicSphere n)
    (hf : ∀ n x, f n (a x) = antipode (f n x)) :
    ∀ x, (fun n => f n (a x)) = allAntipode (fun n => f n x) := by
  intro x
  funext n
  exact hf n x

/-
Splitting off dimension zero identifies the mega-sphere with `S⁰` times its positive tail.
-/
def zeroTailEquiv :
    AllSpheres ≃ AlgebraicSphere 0 × ((n : ℕ) → AlgebraicSphere (n + 1)) where
  toFun x := (x 0, fun n => x (n + 1))
  invFun p
    | 0 => p.1
    | n + 1 => p.2 n
  left_inv x := by
    exact funext fun n => by cases n <;> rfl
  right_inv p := by
    exact Prod.ext rfl (funext fun n => rfl)

/-- Changing exactly one spherical coordinate has exactly the advertised effect on every
projection. -/
def replaceCoordinate (x : AllSpheres) (n : ℕ) (z : AlgebraicSphere n) : AllSpheres :=
  fun m => if h : m = n then h ▸ z else x m

@[simp] theorem project_replace_same (x : AllSpheres) (n : ℕ) (z : AlgebraicSphere n) :
    project n (replaceCoordinate x n z) = z := by
  simp [project, replaceCoordinate]

@[simp] theorem project_replace_other (x : AllSpheres) {m n : ℕ} (h : m ≠ n)
    (z : AlgebraicSphere n) : project m (replaceCoordinate x n z) = project m x := by
  simp [project, replaceCoordinate, h]

/-- Every finite-dimensional sphere is genuinely recovered as a quotient coordinate: its
projection from the mega-sphere is surjective. -/
theorem project_surjective (n : ℕ) : Function.Surjective (project n) := by
  intro z
  exact ⟨replaceCoordinate allNorth n z, project_replace_same allNorth n z⟩

/-- Coordinates can be prescribed independently at any two distinct dimensions. -/
theorem two_coordinates_surjective {m n : ℕ} (h : m ≠ n) :
    Function.Surjective (fun x : AllSpheres => (project m x, project n x)) := by
  intro p
  let x := replaceCoordinate (replaceCoordinate allNorth m p.1) n p.2
  refine ⟨x, ?_⟩
  apply Prod.ext
  · exact project_replace_other (replaceCoordinate allNorth m p.1) h p.2
      |>.trans (project_replace_same allNorth m p.1)
  · exact project_replace_same (replaceCoordinate allNorth m p.1) n p.2

end MegaSphere