/-
# The action of the homotopy self-equivalence group on `π₀`

For a connected 1-type the group of homotopy classes of self-homotopy-equivalences is
`Out(π₁)` (`FundamentalGroupOuterAutomorphisms.lean`); for a totally disconnected one it is
`Sym(π₀)` (`FundamentalGroupSelfEquivalencesPi0.lean`).  In general the two contributions
are linked by an action of `hAut(C)` on `π₀ C`, which this file constructs:

* `hEndToEndComponents` : a monoid homomorphism from homotopy classes of self-maps to
  self-maps of `π₀`;
* `hAutToPermComponents` : the induced group homomorphism `hAut(C) →* Sym(π₀ C)`;
* `hAutToPermComponents_trivial_of_connected` : the action is trivial for a connected
  1-type, so all of `hAut` is then "internal" (and equals `Out(π₁)`);
* `sigmaDiagonal`, `sigmaDiagonal_injective` : conversely the self-maps of the pieces of a
  disjoint union assemble into self-maps of the union, and this assembly is an injective
  monoid homomorphism.

Together these are the two halves of the conjectural wreath-product description of
`hAut` of a general 1-type.
-/
import Mathlib
import Bridges.FundamentalGroupOuterAutomorphisms
import Bridges.FundamentalGroupPi0Gluing
open CategoryTheory
open FundamentalGroupCompleteInvariant (ConnectedAt)
open FundamentalGroupK1
open FundamentalGroupK1Deep (Components isoSetoid mapComponents
  subsingleton_components_of_connectedAt)
open FundamentalGroupOut

namespace FundamentalGroupPi0Action

universe w v u

/-! ## The action on `π₀` -/

section Action

variable (C : Type u) [Category.{v} C]

/-- The monoid homomorphism sending a homotopy class of self-maps of a 1-type to the
induced self-map of its set of connected components. -/
def hEndToEndComponents : HEnd C →* Function.End (Components C) where
  toFun := Quotient.lift (fun F : C ⥤ C => (mapComponents F : Function.End (Components C)))
    (by
      rintro F G ⟨e⟩
      funext p
      induction p using Quotient.ind with
      | _ X => exact Quotient.sound ⟨e.app X⟩)
  map_one' := by
    funext p
    induction p using Quotient.ind with
    | _ X => rfl
  map_mul' a b := by
    induction a using HEnd.ind with
    | _ F =>
      induction b using HEnd.ind with
      | _ G =>
        funext p
        induction p using Quotient.ind with
        | _ X => rfl

@[simp] theorem hEndToEndComponents_mk (F : C ⥤ C) (X : C) :
    hEndToEndComponents C (HEnd.mk C F) (Quotient.mk (isoSetoid C) X) =
      Quotient.mk (isoSetoid C) (F.obj X) := rfl

/-- **The action of the homotopy self-equivalence group on `π₀`.** -/
def hAutToPermComponents : (HEnd C)ˣ →* Equiv.Perm (Components C) :=
  (Equiv.Perm.equivUnitsEnd.symm : (Function.End (Components C))ˣ ≃* Equiv.Perm _).toMonoidHom.comp
    (Units.map (hEndToEndComponents C))

@[simp] theorem hAutToPermComponents_apply (u : (HEnd C)ˣ) (p : Components C) :
    hAutToPermComponents C u p = hEndToEndComponents C (u : HEnd C) p := rfl

end Action

/-! ## The action is trivial on a connected 1-type -/

section Connected

variable {C : Type u} [Groupoid.{v} C] {c : C}

/-- On a connected 1-type the action on `π₀` is trivial: `π₀` is a point, so the whole
homotopy self-equivalence group is `Out(π₁)`. -/
theorem hAutToPermComponents_trivial_of_connected (hC : ConnectedAt C c)
    (u : (HEnd C)ˣ) : hAutToPermComponents C u = 1 := by
  haveI := subsingleton_components_of_connectedAt hC
  exact Equiv.ext fun p => Subsingleton.elim _ _

end Connected

/-! ## Self-equivalences of the pieces of a disjoint union -/

section Diagonal

open FundamentalGroupPi0 (sigmaGroupoid)

variable {ι : Type w} {C : ι → Type u} [∀ i, Groupoid.{v} (C i)]

/-- The canonical representative of a homotopy class represents it. -/
theorem hEnd_mk_out {D : Type u} [Category.{v} D] (q : HEnd D) :
    HEnd.mk D (Quotient.out q) = q := Quotient.out_eq q

/-- A family of self-maps of the pieces of a disjoint union assembles into a self-map of
the disjoint union; on homotopy classes this is a monoid homomorphism. -/
noncomputable def sigmaDiagonal : (∀ i, HEnd (C i)) →* HEnd (Σ i, C i) where
  toFun f := HEnd.mk (Σ i, C i)
    (Sigma.desc fun i => Quotient.out (f i) ⋙ Sigma.incl i)
  map_one' := by
    refine HEnd.mk_eq_mk.2 ⟨Sigma.natIso fun i => ?_⟩
    have key : HEnd.mk (C i) (Quotient.out ((1 : ∀ i, HEnd (C i)) i))
        = HEnd.mk (C i) (𝟭 (C i)) := by
      rw [hEnd_mk_out]
      rfl
    have α : Quotient.out ((1 : ∀ i, HEnd (C i)) i) ≅ 𝟭 (C i) := (HEnd.mk_eq_mk.1 key).some
    exact (Sigma.inclDesc _ i).trans (Functor.isoWhiskerRight α (Sigma.incl i))
  map_mul' f g := by
    refine HEnd.mk_eq_mk.2 ⟨Sigma.natIso fun i => ?_⟩
    have key : HEnd.mk (C i) (Quotient.out (f i * g i))
        = HEnd.mk (C i) (Quotient.out (g i) ⋙ Quotient.out (f i)) := by
      rw [hEnd_mk_out, ← HEnd.mk_mul, hEnd_mk_out, hEnd_mk_out]
    have α : Quotient.out (f i * g i) ≅ Quotient.out (g i) ⋙ Quotient.out (f i) :=
      (HEnd.mk_eq_mk.1 key).some
    refine (Sigma.inclDesc _ i).trans
      ((Functor.isoWhiskerRight α (Sigma.incl i)).trans ?_)
    refine (Functor.isoWhiskerLeft (Quotient.out (g i))
      (Sigma.inclDesc (fun j => Quotient.out (f j) ⋙ Sigma.incl j) i)).symm.trans ?_
    exact (Functor.isoWhiskerRight
      (Sigma.inclDesc (fun j => Quotient.out (g j) ⋙ Sigma.incl j) i)
      (Sigma.desc fun j => Quotient.out (f j) ⋙ Sigma.incl j)).symm


/-- **The self-equivalences of the pieces embed into those of the disjoint union.**  The
assembly map on homotopy classes is injective. -/
theorem sigmaDiagonal_injective : Function.Injective (sigmaDiagonal (C := C)) := by
  intro f g h
  funext i
  obtain ⟨β⟩ := HEnd.mk_eq_mk.1 h
  have hβ : (Quotient.out (f i) ⋙ Sigma.incl i) ≅ (Quotient.out (g i) ⋙ Sigma.incl i) :=
    ((Sigma.inclDesc (fun j => Quotient.out (f j) ⋙ Sigma.incl j) i).symm.trans
      (Functor.isoWhiskerLeft (Sigma.incl i) β)).trans
      (Sigma.inclDesc (fun j => Quotient.out (g j) ⋙ Sigma.incl j) i)
  rw [← hEnd_mk_out (f i), ← hEnd_mk_out (g i)]
  exact HEnd.mk_eq_mk.2 ⟨Functor.fullyFaithfulCancelRight (Sigma.incl i) hβ⟩

end Diagonal

end FundamentalGroupPi0Action