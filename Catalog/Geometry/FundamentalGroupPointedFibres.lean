/-
# Forgetting the basepoint: the fibres of `[X,Y]_* → [X,Y]`

`Catalog/Geometry/FundamentalGroupPointedMaps.lean` proves the *pointed* classification of
maps of connected homotopy 1-types,

  `[(K(G,1),*), (K(H,1),*)]_* ≃ Hom(G,H)`   (`ptdClassificationEquiv`),

with no quotient by conjugation, whereas the unpointed classification of
`Catalog/Bridges/FundamentalGroupK1Classification.lean` is
`[K(G,1), K(H,1)] ≃ Hom(G,H)/conj`.  This file compares the two and settles the counting
half of conjecture **N3** of `FUTURE_DIRECTIONS.md`:

* `forgetBase` — the map "forget the basepoint" from pointed to unpointed homotopy classes;
* `forgetBase_eq_iff_conj` — two pointed classes have the same image exactly when the
  induced homomorphisms are conjugate;
* `card_ptd_fibre` — **the fibre count**: over the unpointed class of a map inducing `φ`
  the fibre has exactly `[H : C_H(φ(G))]` elements, the index of the centraliser of the
  image, uniformly in the basepoint;
* `forgetBase_injective_of_commutative` — for abelian target fundamental group the pointed
  and unpointed classifications agree;
* `ptdAutEquiv` — **the pointed self-equivalence group is `Aut G`, not `Out G`**: pointed
  homotopy classes of pointed self-homotopy-equivalences of a `K(G,1)` are exactly the
  automorphisms of `G` (compare `outAut_mulEquiv_hEnd_units` of
  `Catalog/Bridges/FundamentalGroupOuterAutomorphisms.lean`, which computes the unpointed
  answer `Out G`);
* `card_ptd_fibre_id` — the two are reconciled quantitatively: the fibre of
  `Aut G ↠ Out G` over the identity class has `[G : Z(G)] = |Inn G|` elements.
-/
import Mathlib
import Geometry.FundamentalGroupPointedMaps
import Bridges.FundamentalGroupMapsDisconnectedTarget

open CategoryTheory
open FundamentalGroupCompleteInvariant (ConnectedAt)
open FundamentalGroupK1
open FundamentalGroupK1Deep (card_homs_natIso_realize natIso_realize_iff_mem_orbit)
open FundamentalGroupMapsDisc (inducedHomOf inducedHomOf_conj_of_natIso)

namespace FundamentalGroupPointed

open PtdMap

universe v u v' u'

section Forget

variable {C : Type u} [Groupoid.{v} C] {c : C} {D : Type u'} [Groupoid.{v'} D] {d : D}

/-- Forgetting the basepoint: a pointed homotopy class of pointed maps has an underlying
unpointed homotopy class. -/
def forgetBase : Quotient (ptdSetoid C c D d) → Quotient (natIsoSetoid C D) :=
  Quotient.lift (fun P => Quotient.mk (natIsoSetoid C D) P.functor)
    (by rintro P Q ⟨α, -⟩; exact Quotient.sound ⟨α⟩)

@[simp] theorem forgetBase_mk (P : PtdMap C c D d) :
    forgetBase (Quotient.mk (ptdSetoid C c D d) P)
      = Quotient.mk (natIsoSetoid C D) P.functor := rfl

/-- The pointed induced homomorphism is the path-dependent induced homomorphism of
`FundamentalGroupMapsDisc`, for the reversed chosen path. -/
theorem ptdHom_eq_inducedHomOf (P : PtdMap C c D d) :
    P.ptdHom = inducedHomOf P.functor c P.path.symm := rfl

/-- Maps that are homotopic without regard to basepoints induce conjugate homomorphisms. -/
theorem ptdHom_conj_of_natIso {P Q : PtdMap C c D d} (α : P.functor ≅ Q.functor) :
    ∃ u : Aut d, ∀ a : Aut c, Q.ptdHom a = u * P.ptdHom a * u⁻¹ :=
  inducedHomOf_conj_of_natIso α P.path.symm Q.path.symm

/-- **The fibres of `forgetBase` are the conjugation orbits.**  Two pointed classes become
equal after forgetting the basepoint exactly when the two induced homomorphisms of
fundamental groups are conjugate. -/
theorem forgetBase_eq_iff_conj (hC : ConnectedAt C c) (P Q : PtdMap C c D d) :
    forgetBase (Quotient.mk _ P) = forgetBase (Quotient.mk _ Q) ↔
      ∃ u : Aut d, ∀ a : Aut c, Q.ptdHom a = u * P.ptdHom a * u⁻¹ := by
  constructor
  · intro h
    obtain ⟨α⟩ := Quotient.exact h
    exact ptdHom_conj_of_natIso α
  · rintro ⟨u, hu⟩
    have hP : Nonempty (P.functor ≅ realize hC d P.ptdHom) := by
      obtain ⟨α, -⟩ := ptdHomotopic_of_ptdHom_eq (P := P) (Q := ptdRealize hC d P.ptdHom) hC
        (by simp)
      exact ⟨α⟩
    have hQ : Nonempty (Q.functor ≅ realize hC d Q.ptdHom) := by
      obtain ⟨α, -⟩ := ptdHomotopic_of_ptdHom_eq (P := Q) (Q := ptdRealize hC d Q.ptdHom) hC
        (by simp)
      exact ⟨α⟩
    obtain ⟨w⟩ := (realize_natIso_iff_conj hC d P.ptdHom Q.ptdHom).2 ⟨u, hu⟩
    exact Quotient.sound ⟨hP.some.trans (w.trans hQ.some.symm)⟩

/-- Every pointed map is pointed-homotopic to the canonical realization of its induced
homomorphism, so `forgetBase` hits exactly the classes of realizations. -/
theorem forgetBase_ptdRealize (hC : ConnectedAt C c) (φ : Aut c →* Aut d) :
    forgetBase (Quotient.mk (ptdSetoid C c D d) (ptdRealize hC d φ))
      = Quotient.mk (natIsoSetoid C D) (realize hC d φ) := rfl

/-- **The fibres of the pointed-to-unpointed comparison map, uniformly in the basepoint.**
The pointed homotopy classes lying over the unpointed class of a map inducing `φ` are in
bijection with the conjugation orbit of `φ`, hence there are exactly
`[H : C_H(φ(G))]` of them. -/
theorem card_ptd_fibre (hC : ConnectedAt C c) (φ : Aut c →* Aut d) :
    Nat.card {x : _root_.Quotient (ptdSetoid C c D d) //
        forgetBase x = Quotient.mk (natIsoSetoid C D) (realize hC d φ)}
      = (Subgroup.centralizer (Set.range φ)).index := by
  have key : ∀ x : Quotient (ptdSetoid C c D d),
      (forgetBase x = Quotient.mk (natIsoSetoid C D) (realize hC d φ)) ↔
        Nonempty (realize hC d φ ≅ realize hC d (ptdClassificationEquiv hC d x)) := by
    intro x
    induction x using Quotient.ind with
    | _ P =>
      have hP : Nonempty (P.functor ≅ realize hC d P.ptdHom) := by
        obtain ⟨α, -⟩ := ptdHomotopic_of_ptdHom_eq (P := P) (Q := ptdRealize hC d P.ptdHom) hC
          (by simp)
        exact ⟨α⟩
      constructor
      · intro h
        obtain ⟨α⟩ := Quotient.exact h
        exact ⟨(α.symm.trans hP.some)⟩
      · rintro ⟨α⟩
        exact Quotient.sound ⟨hP.some.trans α.symm⟩
  have e1 : {x : Quotient (ptdSetoid C c D d) //
        forgetBase x = Quotient.mk (natIsoSetoid C D) (realize hC d φ)}
      ≃ {ψ : Aut c →* Aut d // Nonempty (realize hC d φ ≅ realize hC d ψ)} :=
    (ptdClassificationEquiv hC d).subtypeEquiv key
  rw [Nat.card_congr e1]
  exact card_homs_natIso_realize hC φ

/-- **For abelian fundamental group of the target the basepoint is irrelevant.**  Forgetting
the basepoint is injective on pointed homotopy classes as soon as the vertex group of the
target is commutative, since then conjugation is trivial. -/
theorem forgetBase_injective_of_commutative (hC : ConnectedAt C c)
    (hcomm : ∀ u v : Aut d, u * v = v * u) :
    Function.Injective (forgetBase : Quotient (ptdSetoid C c D d) → _) := by
  intro x y hxy
  induction x using Quotient.ind with
  | _ P =>
    induction y using Quotient.ind with
    | _ Q =>
      obtain ⟨u, hu⟩ := (forgetBase_eq_iff_conj hC P Q).1 hxy
      refine Quotient.sound (ptdHomotopic_of_ptdHom_eq hC ?_)
      ext a
      rw [hu a, hcomm u (P.ptdHom a), mul_assoc, mul_inv_cancel, mul_one]

end Forget

/-! ## Pointed self-equivalences: `Aut G` instead of `Out G` -/

section SelfEquivalences

variable {C : Type u} [Groupoid.{v} C] {c : C}

/-- A pointed map whose underlying functor is an equivalence. -/
def IsPtdEquivClass : Quotient (ptdSetoid C c C c) → Prop :=
  Quotient.lift (fun P => P.functor.IsEquivalence)
    (by
      rintro P Q ⟨α, -⟩
      refine propext ⟨fun h => ?_, fun h => ?_⟩
      · exact Functor.isEquivalence_of_iso α
      · exact Functor.isEquivalence_of_iso α.symm)

@[simp] theorem isPtdEquivClass_mk (P : PtdMap C c C c) :
    IsPtdEquivClass (Quotient.mk (ptdSetoid C c C c) P) = P.functor.IsEquivalence := rfl

/-- Connectedness is inherited by the image of the basepoint under a pointed self-map. -/
theorem connectedAt_of_ptdMap (hC : ConnectedAt C c) (P : PtdMap C c C c) :
    ConnectedAt C (P.functor.obj c) := fun X => ⟨P.path ≪≫ basePath hC X⟩

/-- **Pointed Whitehead theorem.**  A pointed self-map of a connected 1-type is a homotopy
equivalence exactly when the induced endomorphism of the fundamental group is bijective. -/
theorem isEquivalence_iff_bijective_ptdHom (hC : ConnectedAt C c) (P : PtdMap C c C c) :
    P.functor.IsEquivalence ↔ Function.Bijective P.ptdHom := by
  have hcomp : (P.ptdHom : Aut c → Aut c)
      = (Aut.autMulEquivOfIso P.path) ∘ (P.functor.mapAut c) := rfl
  constructor
  · intro h
    rw [hcomp]
    exact (Aut.autMulEquivOfIso P.path).bijective.comp
      (bijective_mapAut_of_isEquivalence P.functor c)
  · intro h
    rw [hcomp] at h
    have hmap : Function.Bijective (P.functor.mapAut c) := by
      have := (Aut.autMulEquivOfIso P.path).symm.bijective.comp h
      simpa [Function.comp_def] using this
    exact isEquivalence_of_bijective_mapAut P.functor hC (connectedAt_of_ptdMap hC P) hmap

/-- Bijective endomorphisms of a group are the same thing as its automorphisms. -/
noncomputable def bijectiveEndEquivMulAut (G : Type*) [Group G] :
    {φ : G →* G // Function.Bijective φ} ≃ MulAut G where
  toFun φ := MulEquiv.ofBijective φ.1 φ.2
  invFun e := ⟨e.toMonoidHom, e.bijective⟩
  left_inv _ := rfl
  right_inv _ := by ext; rfl

/-- **The pointed self-equivalence group of a `K(G,1)` is `Aut G`.**  Pointed homotopy
classes of pointed self-homotopy-equivalences of a connected 1-type are in bijection with
the automorphism group of its fundamental group — in contrast with the unpointed answer
`Out G = Aut G / Inn G`. -/
noncomputable def ptdAutEquiv (hC : ConnectedAt C c) :
    {x : Quotient (ptdSetoid C c C c) // IsPtdEquivClass x} ≃ MulAut (Aut c) :=
  ((ptdClassificationEquiv hC c).subtypeEquiv (by
      intro x
      induction x using Quotient.ind with
      | _ P => exact isEquivalence_iff_bijective_ptdHom hC P)).trans
    (bijectiveEndEquivMulAut (Aut c))

/-- The number of pointed self-equivalence classes is the order of `Aut G`. -/
theorem card_ptdAut (hC : ConnectedAt C c) :
    Nat.card {x : _root_.Quotient (ptdSetoid C c C c) // IsPtdEquivClass x}
      = Nat.card (MulAut (Aut c)) :=
  Nat.card_congr (ptdAutEquiv hC)

/-- The identity map represents the same unpointed class as the realization of the identity
homomorphism. -/
theorem forgetBase_id (hC : ConnectedAt C c) :
    forgetBase (Quotient.mk (ptdSetoid C c C c) (PtdMap.id C c))
      = Quotient.mk (natIsoSetoid C C) (realize hC c (MonoidHom.id (Aut c))) := by
  have h : Quotient.mk (ptdSetoid C c C c) (PtdMap.id C c)
      = Quotient.mk (ptdSetoid C c C c) (ptdRealize hC c (MonoidHom.id (Aut c))) :=
    Quotient.sound (ptdHomotopic_of_ptdHom_eq hC (by rw [ptdHom_id, ptdHom_ptdRealize]))
  rw [h]
  rfl

/-- **The pointed and unpointed pictures reconciled.**  The pointed classes lying over the
unpointed class of the identity are exactly the inner automorphisms: there are `[G : Z(G)]`
of them, the size of the kernel `Inn G` of `Aut G ↠ Out G`. -/
theorem card_ptd_fibre_id (hC : ConnectedAt C c) :
    Nat.card {x : _root_.Quotient (ptdSetoid C c C c) //
        forgetBase x = forgetBase (Quotient.mk (ptdSetoid C c C c) (PtdMap.id C c))}
      = (Subgroup.center (Aut c)).index := by
  rw [forgetBase_id hC]
  rw [card_ptd_fibre hC (MonoidHom.id (Aut c))]
  congr 1
  simp [Subgroup.centralizer_univ]

end SelfEquivalences

end FundamentalGroupPointed