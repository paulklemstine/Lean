/-
# `π₀` together with the vertex groups is a complete invariant of 1-types

This file settles conjecture **N2** of `FUTURE_DIRECTIONS.md` for 1-types presented as
disjoint unions of connected pieces, i.e. for the sigma (coproduct) of a family of
connected groupoids.  The previous cycles proved:

* connected groupoids are classified by the vertex group of a basepoint
  (`connectedGroupoids_equivalent_iff_aut_mulEquiv`);
* discrete groupoids are classified by `π₀`
  (`discrete_equivalence_iff_nonempty_equiv`).

Here the two are glued: for families of connected groupoids `C : ι → Type u` and
`D : κ → Type u`, the coproducts `Σ i, C i` and `Σ j, D j` are equivalent **iff** there is
a bijection `e : ι ≃ κ` of their component sets matching the vertex groups,
`Aut (c i) ≃* Aut (d (e i))` (`sigma_equivalence_iff`).  Since `ι` is canonically the set
of connected components (`componentsSigmaEquiv`), this says exactly that the pair
(`π₀`, the family of fundamental groups of the components) is a complete invariant of
such a 1-type.
-/
import Mathlib
import Bridges.FundamentalGroupK1Deepening
open CategoryTheory
open FundamentalGroupCompleteInvariant (ConnectedAt
  connectedGroupoids_equivalent_of_aut_mulEquiv connectedGroupoids_equivalent_iff_aut_mulEquiv)
open FundamentalGroupK1Deep (Components isoSetoid mapComponents componentsEquivOfEquivalence)

namespace FundamentalGroupPi0

universe w w' v u

/-! ## The coproduct of a family of groupoids -/

section SigmaGroupoid

variable {ι : Type w} {C : ι → Type u} [∀ i, Groupoid.{v} (C i)]

/-- The disjoint union of a family of groupoids is a groupoid. -/
instance sigmaGroupoid : Groupoid (Σ i, C i) :=
  { CategoryTheory.Sigma.sigma with
    inv := fun {X Y} f => match X, Y, f with
      | _, _, Sigma.SigmaHom.mk g => Sigma.SigmaHom.mk (Groupoid.inv g)
    inv_comp := by
      rintro ⟨i, X⟩ ⟨_, _⟩ ⟨f⟩; exact congrArg Sigma.SigmaHom.mk (Groupoid.inv_comp f)
    comp_inv := by
      rintro ⟨i, X⟩ ⟨_, _⟩ ⟨f⟩; exact congrArg Sigma.SigmaHom.mk (Groupoid.comp_inv f) }

/-- Objects of the coproduct lying in different summands are never isomorphic. -/
theorem fst_eq_of_iso {X Y : Σ i, C i} (f : X ≅ Y) : X.1 = Y.1 := by
  obtain ⟨g⟩ := f.hom
  rfl

/-- An isomorphism inside one summand gives an isomorphism in the coproduct. -/
@[simps]
def sigmaIso {i : ι} {X Y : C i} (f : X ≅ Y) : (⟨i, X⟩ : Σ i, C i) ≅ ⟨i, Y⟩ where
  hom := Sigma.SigmaHom.mk f.hom
  inv := Sigma.SigmaHom.mk f.inv
  hom_inv_id := congrArg Sigma.SigmaHom.mk f.hom_inv_id
  inv_hom_id := congrArg Sigma.SigmaHom.mk f.inv_hom_id

/-- The inclusion of a summand identifies vertex groups: `Aut X ≃* Aut ⟨i, X⟩`. -/
noncomputable def autSigmaMulEquiv (i : ι) (X : C i) :
    Aut X ≃* Aut (⟨i, X⟩ : Σ i, C i) :=
  (Functor.FullyFaithful.ofFullyFaithful (Sigma.incl i :
    C i ⥤ Σ i, C i)).autMulEquivOfFullyFaithful X

end SigmaGroupoid

/-! ## `π₀` of a coproduct of connected groupoids -/

section Components

variable {ι : Type w} {C : ι → Type u} [∀ i, Groupoid.{v} (C i)]
variable (c : ∀ i, C i)

/-- Every object of a coproduct of connected groupoids is isomorphic to the chosen
basepoint of its summand. -/
theorem iso_basepoint (hC : ∀ i, ConnectedAt (C i) (c i)) (X : Σ i, C i) :
    Nonempty ((⟨X.1, c X.1⟩ : Σ i, C i) ≅ X) := by
  exact ⟨sigmaIso (FundamentalGroupK1.basePath (hC X.1) X.2)⟩

/-- Every object of a coproduct of connected groupoids lies in the component of the
basepoint of its summand. -/
theorem mk_basepoint (hC : ∀ i, ConnectedAt (C i) (c i)) (X : Σ i, C i) :
    Quotient.mk (isoSetoid (Σ i, C i)) ⟨X.1, c X.1⟩ =
      Quotient.mk (isoSetoid (Σ i, C i)) X :=
  Quotient.sound (iso_basepoint c hC X)

/-- **`π₀` of a disjoint union of connected 1-types is the indexing set.** -/
def componentsSigmaEquiv (hC : ∀ i, ConnectedAt (C i) (c i)) :
    Components (Σ i, C i) ≃ ι where
  toFun := Quotient.lift (fun X => X.1) (fun _ _ ⟨f⟩ => fst_eq_of_iso f)
  invFun i := Quotient.mk _ ⟨i, c i⟩
  left_inv := by
    intro q
    induction q using Quotient.ind with
    | _ X => exact mk_basepoint c hC X
  right_inv _ := rfl

end Components

/-! ## Gluing equivalences over a bijection of component sets -/

section Gluing

variable {ι : Type w} {κ : Type w'} {C : ι → Type u} [∀ i, Groupoid.{v} (C i)]
  {D : κ → Type u} [∀ j, Groupoid.{v} (D j)]

/-- A family of functors indexed compatibly with a reindexing `e : ι → κ` assembles into a
functor of coproducts. -/
def sigmaDesc (e : ι → κ) (F : ∀ i, C i ⥤ D (e i)) : (Σ i, C i) ⥤ (Σ j, D j) :=
  Sigma.desc fun i => F i ⋙ Sigma.incl (e i)

@[simp] theorem sigmaDesc_obj (e : ι → κ) (F : ∀ i, C i ⥤ D (e i)) (i : ι) (X : C i) :
    (sigmaDesc e F).obj ⟨i, X⟩ = ⟨e i, (F i).obj X⟩ := rfl

@[simp] theorem sigmaDesc_map (e : ι → κ) (F : ∀ i, C i ⥤ D (e i)) {i : ι} {X Y : C i}
    (f : X ⟶ Y) :
    (sigmaDesc e F).map (Sigma.SigmaHom.mk f) = Sigma.SigmaHom.mk ((F i).map f) := rfl

theorem sigmaDesc_faithful {e : ι → κ} (F : ∀ i, C i ⥤ D (e i)) (hF : ∀ i, (F i).Faithful) :
    (sigmaDesc e F).Faithful := by
  refine { map_injective := ?_ }
  rintro ⟨i, X⟩ ⟨j, Y⟩ f g hfg
  have hij : i = j := match f with
    | Sigma.SigmaHom.mk _ => rfl
  subst hij
  rcases f with ⟨f'⟩; rcases g with ⟨g'⟩
  simp only [sigmaDesc_map] at hfg
  rw [Sigma.SigmaHom.mk.injEq] at hfg
  exact congrArg Sigma.SigmaHom.mk (hF i |>.map_injective hfg)

theorem sigmaDesc_full {e : ι → κ} (he : Function.Injective e) (F : ∀ i, C i ⥤ D (e i))
    (hF : ∀ i, (F i).Full) : (sigmaDesc e F).Full := by
  refine { map_surjective := fun {X Y} g => ?_ }
  obtain ⟨i, X⟩ := X
  obtain ⟨j, Y⟩ := Y
  have heq : e i = e j := by
    have aux : ∀ a b : Σ k, D k, (a ⟶ b) → a.1 = b.1 := @fun a b f => by
      match f with
      | Sigma.SigmaHom.mk _ => rfl
    exact aux _ _ g
  have hij : i = j := he heq
  subst hij
  match g with
  | Sigma.SigmaHom.mk g' =>
    obtain ⟨f', hf'⟩ := (hF i).map_surjective g'
    exact ⟨Sigma.SigmaHom.mk f', by rw [sigmaDesc_map, hf']⟩

theorem sigmaDesc_essSurj {e : ι → κ} (he : Function.Surjective e) (F : ∀ i, C i ⥤ D (e i))
    (hF : ∀ i, (F i).EssSurj) : (sigmaDesc e F).EssSurj := by
  refine ⟨fun ⟨j, Y⟩ => ?_⟩
  obtain ⟨i, hi⟩ := he j
  subst hi
  obtain ⟨X, ⟨iso⟩⟩ := (hF i).mem_essImage Y
  exact ⟨⟨i, X⟩, ⟨sigmaIso iso⟩⟩

/-- **Gluing.**  A bijection of indexing sets together with equivalences of the
corresponding summands gives an equivalence of the coproducts. -/
noncomputable def sigmaEquivalence (e : ι ≃ κ) (F : ∀ i, C i ≌ D (e i)) :
    (Σ i, C i) ≌ (Σ j, D j) := by
  haveI := sigmaDesc_full e.injective (fun i => (F i).functor) (fun i => inferInstance)
  haveI := sigmaDesc_faithful (fun i => (F i).functor) (fun i => inferInstance)
  haveI := sigmaDesc_essSurj e.surjective (fun i => (F i).functor) (fun i => inferInstance)
  haveI : (sigmaDesc (e : ι → κ) fun i => (F i).functor).IsEquivalence :=
    ⟨inferInstance, inferInstance, inferInstance⟩
  exact (sigmaDesc (e : ι → κ) fun i => (F i).functor).asEquivalence

end Gluing

/-! ## The classification of 1-types by `π₀` and the vertex groups -/

section Classification

variable {ι : Type w} {κ : Type w'} {C : ι → Type u} [∀ i, Groupoid.{v} (C i)]
  {D : κ → Type u} [∀ j, Groupoid.{v} (D j)]

/-- An equivalence of coproducts of connected groupoids induces a bijection of the
indexing sets, given by the summand in which a basepoint lands. -/
def indexEquivOfEquivalence (c : ∀ i, C i) (d : ∀ j, D j)
    (hC : ∀ i, ConnectedAt (C i) (c i)) (hD : ∀ j, ConnectedAt (D j) (d j))
    (E : (Σ i, C i) ≌ (Σ j, D j)) : ι ≃ κ :=
  (componentsSigmaEquiv c hC).symm.trans
    ((componentsEquivOfEquivalence E).trans (componentsSigmaEquiv d hD))

theorem indexEquivOfEquivalence_apply (c : ∀ i, C i) (d : ∀ j, D j)
    (hC : ∀ i, ConnectedAt (C i) (c i)) (hD : ∀ j, ConnectedAt (D j) (d j))
    (E : (Σ i, C i) ≌ (Σ j, D j)) (i : ι) :
    indexEquivOfEquivalence c d hC hD E i = (E.functor.obj ⟨i, c i⟩).1 := rfl

/-- An equivalence of coproducts of connected groupoids matches up the vertex groups of
the corresponding components. -/
theorem aut_mulEquiv_of_equivalence (c : ∀ i, C i) (d : ∀ j, D j)
    (hC : ∀ i, ConnectedAt (C i) (c i)) (hD : ∀ j, ConnectedAt (D j) (d j))
    (E : (Σ i, C i) ≌ (Σ j, D j)) (i : ι) :
    Nonempty (Aut (c i) ≃* Aut (d (indexEquivOfEquivalence c d hC hD E i))) := by
  -- Let j be the component where ⟨i, c i⟩ maps to
  let j := (E.functor.obj ⟨i, c i⟩).1
  -- indexEquivOfEquivalence c d hC hD E i = j
  have h_idx : indexEquivOfEquivalence c d hC hD E i = j := rfl
  rw [h_idx]
  -- We have an isomorphism f : ⟨j, d j⟩ ≅ E.functor.obj ⟨i, c i⟩ since D j is connected at d j
  have h_iso : Nonempty ((⟨j, d j⟩ : Σ j, D j) ≅ E.functor.obj ⟨i, c i⟩) :=
    iso_basepoint (c := d) hD (E.functor.obj ⟨i, c i⟩)
  obtain ⟨iso⟩ := h_iso
  exact ⟨(autSigmaMulEquiv i (c i)).trans
    ((FundamentalGroupCompleteInvariant.aut_mulEquiv_of_groupoid_equivalence E _).some.trans
    ((Aut.autMulEquivOfIso iso).symm.trans (autSigmaMulEquiv j (d j)).symm))⟩

/-- **`π₀` plus the vertex groups is a complete invariant of 1-types.**  Two disjoint
unions of connected groupoids (models of arbitrary homotopy 1-types with chosen
component basepoints) are equivalent exactly when there is a bijection of their sets of
connected components under which the corresponding fundamental groups are isomorphic. -/
theorem sigma_equivalence_iff (c : ∀ i, C i) (d : ∀ j, D j)
    (hC : ∀ i, ConnectedAt (C i) (c i)) (hD : ∀ j, ConnectedAt (D j) (d j)) :
    Nonempty ((Σ i, C i) ≌ (Σ j, D j)) ↔
      ∃ e : ι ≃ κ, ∀ i, Nonempty (Aut (c i) ≃* Aut (d (e i))) := by
  constructor
  · -- Forward direction: equivalence implies bijection with isomorphic vertex groups
    rintro ⟨E⟩
    exact ⟨indexEquivOfEquivalence c d hC hD E,
      fun i => aut_mulEquiv_of_equivalence c d hC hD E i⟩
  · -- Backward direction: bijection with isomorphic vertex groups implies equivalence
    rintro ⟨e, h⟩
    let F : ∀ i, C i ≌ D (e i) := fun i =>
      (connectedGroupoids_equivalent_of_aut_mulEquiv (c i) (d (e i)) (hC i) (hD (e i))
        (h i).some).some
    exact ⟨sigmaEquivalence e F⟩

end Classification

end FundamentalGroupPi0