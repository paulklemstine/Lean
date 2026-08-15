/-
# Self-equivalences of a totally disconnected 1-type: the symmetric group on `π₀`

`Catalog/Bridges/FundamentalGroupOuterAutomorphisms.lean` computes the group of homotopy
classes of self-homotopy-equivalences of a *connected* 1-type `K(G,1)`: it is `Out G`.
This file settles the opposite extreme, a **totally disconnected** 1-type (a discrete
groupoid, all of whose fundamental groups are trivial).  There the answer is purely
combinatorial:

* `hEndDiscreteMulEquivEnd` : the monoid of homotopy classes of self-maps of `Discrete α`
  is the full transformation monoid `Function.End α` of `π₀ = α`;
* `hEndDiscreteUnitsMulEquivPerm` : consequently the group of homotopy classes of
  self-homotopy-equivalences is the **symmetric group** `Equiv.Perm α` of `π₀`;
* `autId_discrete_subsingleton` : there are no nontrivial self-homotopies of the identity,
  matching the fact that all vertex groups (hence their centres) are trivial.

Combined with the connected case this exhibits the two extremes of the general answer:
`π₀` contributes permutations, each vertex group contributes its outer automorphisms.
-/
import Mathlib
import Bridges.FundamentalGroupOuterAutomorphisms
open CategoryTheory
open FundamentalGroupOut

namespace FundamentalGroupPi0SelfEquiv

universe u

variable (α : Type u)

/-- The underlying self-map of `π₀ = α` of an endofunctor of the discrete 1-type. -/
def objMap (F : Discrete α ⥤ Discrete α) : Function.End α := fun a => (F.obj ⟨a⟩).as

/-- Naturally isomorphic endofunctors of a discrete category agree on objects. -/
theorem objMap_eq_of_natIso {F G : Discrete α ⥤ Discrete α} (e : F ≅ G) :
    objMap α F = objMap α G := by
  funext a
  exact Discrete.eq_of_hom (e.hom.app ⟨a⟩)

/-- **Homotopy classes of self-maps of a totally disconnected 1-type are exactly the
self-maps of `π₀`.** -/
def hEndDiscreteMulEquivEnd : HEnd (Discrete α) ≃* Function.End α where
  toFun := Quotient.lift (objMap α) (by rintro F G ⟨e⟩; exact objMap_eq_of_natIso α e)
  invFun f := HEnd.mk (Discrete α) (Discrete.functor fun a => (⟨f a⟩ : Discrete α))
  left_inv q := by
    induction q using HEnd.ind with
    | _ F =>
      refine HEnd.mk_eq_mk.2 ⟨(Discrete.natIso fun i => eqToIso ?_).symm⟩
      rcases i with ⟨a⟩
      rfl
  right_inv f := rfl
  map_mul' a b := by
    induction a using HEnd.ind with
    | _ F =>
      induction b using HEnd.ind with
      | _ G => rfl

@[simp] theorem hEndDiscreteMulEquivEnd_mk (F : Discrete α ⥤ Discrete α) :
    hEndDiscreteMulEquivEnd α (HEnd.mk (Discrete α) F) = objMap α F := rfl

/-- **The homotopy self-equivalence group of a totally disconnected 1-type is the symmetric
group of its set of components.** -/
def hEndDiscreteUnitsMulEquivPerm : (HEnd (Discrete α))ˣ ≃* Equiv.Perm α :=
  (Units.mapEquiv (hEndDiscreteMulEquivEnd α)).trans Equiv.Perm.equivUnitsEnd.symm

/-- The number of homotopy classes of self-homotopy-equivalences of a totally disconnected
1-type is the number of permutations of `π₀`. -/
theorem card_hEndDiscrete_units :
    Nat.card ((HEnd (Discrete α))ˣ) = Nat.card (Equiv.Perm α) :=
  Nat.card_congr (hEndDiscreteUnitsMulEquivPerm α).toEquiv

/-- Invertibility in the full transformation monoid is bijectivity. -/
theorem isUnit_end_iff (f : Function.End α) : IsUnit f ↔ Function.Bijective f := by
  constructor
  · rintro ⟨u, rfl⟩
    refine ⟨fun x y hxy => ?_, fun b => ⟨(u⁻¹ : (Function.End α)ˣ).val b, congrFun u.val_inv b⟩⟩
    have hx : (u⁻¹ : (Function.End α)ˣ).val (u.val x) = x := congrFun u.inv_val x
    have hy : (u⁻¹ : (Function.End α)ˣ).val (u.val y) = y := congrFun u.inv_val y
    rw [← hx, ← hy]
    exact congrArg _ hxy
  · intro h
    exact ⟨Equiv.Perm.equivUnitsEnd (Equiv.ofBijective f h), rfl⟩

/-- A self-map of a discrete 1-type is a homotopy equivalence exactly when the induced
self-map of `π₀` is bijective. -/
theorem isEquivalence_discrete_iff_bijective (F : Discrete α ⥤ Discrete α) :
    F.IsEquivalence ↔ Function.Bijective (objMap α F) := by
  rw [← isUnit_hEnd_mk_iff, ← isUnit_end_iff]
  constructor
  · intro h
    exact h.map (hEndDiscreteMulEquivEnd α)
  · intro h
    rw [show HEnd.mk (Discrete α) F = (hEndDiscreteMulEquivEnd α).symm (objMap α F) from
      ((hEndDiscreteMulEquivEnd α).symm_apply_apply _).symm]
    exact h.map (hEndDiscreteMulEquivEnd α).symm

/-- A discrete 1-type admits no nontrivial self-homotopies of the identity: its vertex
groups, hence their centres, are trivial. -/
theorem autId_discrete_subsingleton : Subsingleton (Aut (𝟭 (Discrete α))) := by
  constructor
  intro x y
  ext i
  apply Subsingleton.elim

end FundamentalGroupPi0SelfEquiv