/-
# The complete classification of maps between arbitrary 1-types

This file assembles the two remaining pieces of the classification of maps of homotopy
1-types (groupoids), with **no connectedness assumptions on either side**:

* `mapsFromSigmaEquiv` : homotopy classes of maps out of a disjoint union are families of
  homotopy classes of maps out of the summands,
  `[⊔ᵢ Cᵢ, D] ≃ ∏ᵢ [Cᵢ, D]`;
* `totalEquiv` : homotopy classes of maps out of a *connected* 1-type are a choice of
  connected component of the target together with a conjugacy class of homomorphisms into
  the fundamental group of that component (the total form of
  `FundamentalGroupMapsDisc.fibreEquiv`);
* `mapsClassification` : combining the two,

  `[⊔ᵢ K(Gᵢ,1), D] ≃ ∏ᵢ (Σ q ∈ π₀ D, Hom(Gᵢ, π₁(D,q)) / conjugation)`.

Since every 1-type is the disjoint union of its connected components (proved in
`Catalog/Bridges/FundamentalGroupPi0Decomposition.lean`), this is the complete answer to
"what are the maps between two homotopy 1-types, up to homotopy?", purely in terms of
`π₀` and the fundamental groups.
-/
import Mathlib
import Catalog.Bridges.FundamentalGroupMapsDisconnectedTarget
import Catalog.Bridges.FundamentalGroupPi0Gluing

open CategoryTheory
open FundamentalGroupCompleteInvariant (ConnectedAt)
open FundamentalGroupK1
open FundamentalGroupK1Deep (Components isoSetoid)
open FundamentalGroupMapsDisc (toComponent fibreEquiv)

namespace FundamentalGroupMapsAll

universe w v u u'

/-! ## Maps out of a disjoint union -/

section Coproduct

variable {ι : Type w} {C : ι → Type u} [∀ i, Groupoid.{v} (C i)]
  {D : Type u} [Groupoid.{v} D]

/-- Restriction of a homotopy class of maps out of a coproduct to the summands. -/
def restrictClasses :
    Quotient (natIsoSetoid (Σ i, C i) D) → ∀ i, Quotient (natIsoSetoid (C i) D) :=
  Quotient.lift (fun F i => Quotient.mk (natIsoSetoid (C i) D) (Sigma.incl i ⋙ F))
    (by
      rintro F G ⟨e⟩
      funext i
      exact Quotient.sound ⟨Functor.isoWhiskerLeft (Sigma.incl i) e⟩)

/-- Assembling a family of homotopy classes into a homotopy class of maps out of the
coproduct. -/
noncomputable def assembleClasses :
    (∀ i, Quotient (natIsoSetoid (C i) D)) → Quotient (natIsoSetoid (Σ i, C i) D) :=
  fun f => Quotient.mk (natIsoSetoid (Σ i, C i) D) (Sigma.desc fun i => Quotient.out (f i))

/-- **Maps out of a disjoint union of 1-types are families of maps out of the pieces.** -/
noncomputable def mapsFromSigmaEquiv :
    Quotient (natIsoSetoid (Σ i, C i) D) ≃ ∀ i, Quotient (natIsoSetoid (C i) D) where
  toFun := restrictClasses
  invFun := assembleClasses
  left_inv q := by
    induction q using Quotient.ind with
    | _ F =>
      refine Quotient.sound ⟨(Sigma.descUniq _ F fun i => ?_).symm⟩
      have hrel : (natIsoSetoid (C i) D).r
          (Quotient.out (Quotient.mk (natIsoSetoid (C i) D) (Sigma.incl i ⋙ F)))
          (Sigma.incl i ⋙ F) :=
        Quotient.exact (Quotient.out_eq _)
      exact hrel.some.symm
  right_inv f := by
    funext i
    show Quotient.mk (natIsoSetoid (C i) D)
        (Sigma.incl i ⋙ Sigma.desc fun j => Quotient.out (f j)) = f i
    have h1 : Quotient.mk (natIsoSetoid (C i) D)
          (Sigma.incl i ⋙ Sigma.desc fun j => Quotient.out (f j))
        = Quotient.mk (natIsoSetoid (C i) D) (Quotient.out (f i)) :=
      Quotient.sound (Nonempty.intro (Sigma.inclDesc _ i))
    rw [h1, Quotient.out_eq]

end Coproduct

/-! ## Maps out of a connected 1-type, in total form -/

section Connected

variable {C : Type u} [Groupoid.{v} C] {c : C} {D : Type u'} [Groupoid.{v} D]

/-- **Maps out of a `K(G,1)` into an arbitrary 1-type**: a homotopy class is exactly a
component `q` of the target together with a conjugacy class of homomorphisms
`G → π₁(D, q)`. -/
noncomputable def totalEquiv (hC : ConnectedAt C c) :
    Quotient (natIsoSetoid C D) ≃
      Σ q : Components D, Quotient (conjSetoid (Aut c) (Aut (Quotient.out q))) :=
  (Equiv.sigmaFiberEquiv (toComponent (D := D) c)).symm.trans
    (Equiv.sigmaCongrRight fun q =>
      (Equiv.subtypeEquivRight (fun _ => by rw [Quotient.out_eq])).trans
        (fibreEquiv hC (Quotient.out q)))

end Connected

/-! ## The complete classification -/

section Complete

variable {ι : Type w} {C : ι → Type u} [∀ i, Groupoid.{v} (C i)] {c : ∀ i, C i}
  {D : Type u} [Groupoid.{v} D]

/-- **The complete classification of maps of homotopy 1-types.**  For a 1-type presented as
a disjoint union of connected pieces `K(Gᵢ,1)` and an arbitrary 1-type `D`, the homotopy
classes of maps are families indexed by `i` of a choice of connected component `q` of `D`
together with a conjugacy class of homomorphisms `Gᵢ → π₁(D,q)`. -/
noncomputable def mapsClassification (hC : ∀ i, ConnectedAt (C i) (c i)) :
    Quotient (natIsoSetoid (Σ i, C i) D) ≃
      ∀ i, Σ q : Components D, Quotient (conjSetoid (Aut (c i)) (Aut (Quotient.out q))) :=
  mapsFromSigmaEquiv.trans (Equiv.piCongrRight fun i => totalEquiv (hC i))

end Complete

end FundamentalGroupMapsAll