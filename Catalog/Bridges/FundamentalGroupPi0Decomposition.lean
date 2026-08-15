/-
# Every 1-type is the disjoint union of its connected components

This file completes the classification of homotopy 1-types begun in
`Catalog/Bridges/FundamentalGroupCompleteInvariant.lean` (connected 1-types are classified
by the fundamental group of a basepoint) and continued in
`Catalog/Bridges/FundamentalGroupPi0Gluing.lean` (a coproduct of connected groupoids is
classified by the indexing set together with the vertex groups).

The missing gluing step is proved here: an arbitrary groupoid `C` is equivalent to the
coproduct, over its set of connected components `π₀ C`, of the full subcategories on the
individual components (`sigmaComponentsEquivalence`).  Combining this with the coproduct
classification yields the complete invariant for **arbitrary** homotopy 1-types
(`groupoid_equivalence_iff_pi0_aut`): two groupoids are equivalent exactly when there is a
bijection of their sets of connected components matching the fundamental groups of the
corresponding components.  This settles conjecture N2 of `FUTURE_DIRECTIONS.md`.
-/
import Mathlib
import Bridges.FundamentalGroupPi0Gluing
open CategoryTheory
open FundamentalGroupCompleteInvariant (ConnectedAt)
open FundamentalGroupK1Deep (Components isoSetoid)
open FundamentalGroupPi0 (sigmaGroupoid sigma_equivalence_iff)

namespace FundamentalGroupPi0

universe v u

section Decomposition

variable {C : Type u} [Groupoid.{v} C]

/-- The objects lying in a fixed connected component, as a full subcategory of `C`. -/
def ComponentObj (p : Components C) : Type u :=
  {X : C // Quotient.mk (isoSetoid C) X = p}

instance groupoidComponentObj (p : Components C) : Groupoid.{v} (ComponentObj p) :=
  inferInstanceAs (Groupoid (InducedCategory C (fun X : ComponentObj p => X.1)))

/-- The inclusion of a connected component into the ambient groupoid. -/
def componentIncl (p : Components C) : ComponentObj p ⥤ C :=
  inducedFunctor (fun X : ComponentObj p => X.1)

/-- The inclusion of a component is fully faithful. -/
def componentInclFullyFaithful (p : Components C) : (componentIncl p).FullyFaithful :=
  fullyFaithfulInducedFunctor (fun X : ComponentObj p => X.1)

/-- The chosen basepoint of a component. -/
noncomputable def componentBase (p : Components C) : ComponentObj p :=
  ⟨Quotient.out p, Quotient.out_eq p⟩

/-- Objects with the same class in `π₀` are isomorphic. -/
theorem nonempty_iso_of_mk_eq {X Y : C}
    (h : Quotient.mk (isoSetoid C) X = Quotient.mk (isoSetoid C) Y) : Nonempty (X ≅ Y) :=
  Quotient.exact h

/-- Any two objects of a fixed component are isomorphic inside that component. -/
theorem componentObj_iso (p : Components C) (X Y : ComponentObj p) : Nonempty (X ≅ Y) := by
  have heq : Quotient.mk (isoSetoid C) X.1 = Quotient.mk (isoSetoid C) Y.1 := by
    rw [X.2, Y.2]
  obtain ⟨e⟩ := nonempty_iso_of_mk_eq heq
  exact ⟨(componentInclFullyFaithful p).preimageIso e⟩

/-- Each component is a connected groupoid: a model of a `K(G,1)`. -/
theorem componentObj_connectedAt (p : Components C) :
    ConnectedAt (ComponentObj p) (componentBase p) :=
  fun X => componentObj_iso p (componentBase p) X

/-- The vertex group of a component is the automorphism group, computed in `C`, of the
chosen representative object. -/
noncomputable def autComponentMulEquiv (p : Components C) :
    Aut (componentBase p) ≃* Aut (Quotient.out p : C) :=
  (componentInclFullyFaithful p).autMulEquivOfFullyFaithful (componentBase p)

/-- The functor assembling the components of `C` back into `C`. -/
def assembleComponents : (Σ p : Components C, ComponentObj p) ⥤ C :=
  Sigma.desc componentIncl

@[simp] theorem assembleComponents_obj (p : Components C) (X : ComponentObj p) :
    (assembleComponents (C := C)).obj ⟨p, X⟩ = X.1 := rfl

theorem assembleComponents_faithful : (assembleComponents (C := C)).Faithful := by
  refine { map_injective := ?_ }
  rintro ⟨p, X⟩ ⟨q, Y⟩ f g hfg
  have hpq : p = q := match f with | Sigma.SigmaHom.mk _ => rfl
  subst hpq
  rcases f with ⟨f'⟩; rcases g with ⟨g'⟩
  have hfg' : (componentIncl p).map f' = (componentIncl p).map g' := hfg
  exact congrArg Sigma.SigmaHom.mk ((componentInclFullyFaithful p).map_injective hfg')

theorem assembleComponents_full : (assembleComponents (C := C)).Full := by
  refine { map_surjective := fun {X Y} g => ?_ }
  obtain ⟨p, X'⟩ := X
  obtain ⟨q, Y'⟩ := Y
  -- In a groupoid, every morphism is an iso, so p = q
  have hpq : p = q := by
    have hiso : X'.1 ≅ Y'.1 := ⟨g, Groupoid.inv g, Groupoid.comp_inv g, Groupoid.inv_comp g⟩
    have heq : Quotient.mk (isoSetoid C) X'.1 = Quotient.mk (isoSetoid C) Y'.1 :=
      Quotient.sound ⟨hiso⟩
    rw [← X'.2, heq, Y'.2]
  subst hpq
  -- Now p = q, so g is a morphism in the same component
  -- componentIncl p is fully faithful
  have hf := componentInclFullyFaithful p
  obtain ⟨f', hf'⟩ := hf.map_surjective g
  use Sigma.SigmaHom.mk f'
  simp [assembleComponents] at hf' ⊢
  exact hf'

theorem assembleComponents_essSurj : (assembleComponents (C := C)).EssSurj := by
  refine ⟨fun X => ?_⟩
  exact ⟨⟨Quotient.mk (isoSetoid C) X, ⟨X, rfl⟩⟩, ⟨Iso.refl X⟩⟩

/-- **Decomposition into components.**  Every 1-type is the disjoint union of its connected
components, each of which is a `K(G,1)`. -/
noncomputable def sigmaComponentsEquivalence :
    (Σ p : Components C, ComponentObj p) ≌ C := by
  haveI := assembleComponents_faithful (C := C)
  haveI := assembleComponents_full (C := C)
  haveI := assembleComponents_essSurj (C := C)
  haveI : (assembleComponents (C := C)).IsEquivalence :=
    ⟨inferInstance, inferInstance, inferInstance⟩
  exact (assembleComponents (C := C)).asEquivalence

end Decomposition

/-! ## The complete invariant of an arbitrary homotopy 1-type -/

section Complete

variable {C : Type u} [Groupoid.{v} C] {D : Type u} [Groupoid.{v} D]

/-- **`π₀` together with the fundamental groups of the components is a complete invariant
of homotopy 1-types.**  Two groupoids are equivalent exactly when there is a bijection
between their sets of connected components under which the fundamental groups of
corresponding components are isomorphic. -/
theorem groupoid_equivalence_iff_pi0_aut :
    Nonempty (C ≌ D) ↔
      ∃ e : Components C ≃ Components D,
        ∀ p : Components C,
          Nonempty (Aut (Quotient.out p : C) ≃* Aut (Quotient.out (e p) : D)) := by
  -- C ≌ (Σ p : Components C, ComponentObj p) via sigmaComponentsEquivalence.symm
  -- D ≌ (Σ q : Components D, ComponentObj q) via sigmaComponentsEquivalence.symm
  let equivC : C ≌ (Σ p : Components C, ComponentObj p) := sigmaComponentsEquivalence.symm
  let equivD : D ≌ (Σ q : Components D, ComponentObj q) := sigmaComponentsEquivalence.symm
  -- Convert to equivalence of coproducts
  have h1 : Nonempty (C ≌ D) ↔
      Nonempty ((Σ p : Components C, ComponentObj p) ≌
        (Σ q : Components D, ComponentObj q)) := by
    constructor
    · rintro ⟨E⟩
      exact ⟨equivC.symm.trans (E.trans equivD)⟩
    · rintro ⟨E⟩
      exact ⟨equivC.trans (E.trans equivD.symm)⟩
  rw [h1]
  -- Now apply sigma_equivalence_iff
  have h2 : Nonempty ((Σ p : Components C, ComponentObj p) ≌
        (Σ q : Components D, ComponentObj q)) ↔
      ∃ e : Components C ≃ Components D,
        ∀ p : Components C,
          Nonempty (Aut (componentBase p) ≃* Aut (componentBase (e p))) :=
    sigma_equivalence_iff componentBase componentBase componentObj_connectedAt
      componentObj_connectedAt
  rw [h2]
  -- Now convert Aut (componentBase p) to Aut (Quotient.out p)
  constructor
  · rintro ⟨e, he⟩
    exact ⟨e, fun p => ⟨(autComponentMulEquiv p).symm.trans
      ((he p).some.trans (autComponentMulEquiv (e p)))⟩⟩
  · rintro ⟨e, he⟩
    exact ⟨e, fun p => ⟨(autComponentMulEquiv p).trans
      ((he p).some.trans (autComponentMulEquiv (e p)).symm)⟩⟩

end Complete

end FundamentalGroupPi0