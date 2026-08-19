/-
# The fibre sizes `1, 3, 6` for `K(S₃,1)`, and the abelian case

Conjecture **N3** of `FUTURE_DIRECTIONS.md` predicts that the fibres of the forgetful map
from *pointed* to *unpointed* homotopy classes of maps of 1-types have size the index of the
centraliser of the image, and offers `G = H = S₃` (orbit sizes `1, 3, 6`) as the decisive
finite test.  `Catalog/Geometry/FundamentalGroupPointedFibres.lean` proves the general
counting theorem (`card_ptd_fibre`); this file carries out that test.

Working with the one-object model `K(S₃,1) = SingleObj (Equiv.Perm (Fin 3))`:

* `card_ptd_fibre_trivial_perm` — over the class of the constant map there is exactly
  **one** pointed class (the centraliser of the trivial image is everything);
* `card_ptd_fibre_signSwap_perm` — over the class of a map with image of order `2` there
  are exactly **three** pointed classes;
* `card_ptd_fibre_id_perm` — over the class of the identity there are exactly **six**
  pointed classes, i.e. `[S₃ : Z(S₃)] = 6`: the identity map of `K(S₃,1)` has six
  genuinely different pointed self-homotopy-equivalence classes, all homotopic once
  basepoints are forgotten.

The three numbers `1, 3, 6` are exactly the orbit sizes of the conjugation action of `S₃` on
`Hom(S₃,S₃)` recorded in `ComputationalEvidence.md`, so the pointed classification is
*strictly finer* than the unpointed one.

Finally `forgetBase_injective_cyclic` shows the opposite extreme: for an abelian fundamental
group (e.g. `K(ℤ/n,1)`) the pointed and unpointed classifications coincide.
-/
import Mathlib
import Geometry.FundamentalGroupPointedFibres
import Bridges.FundamentalGroupOuterAutomorphisms

open CategoryTheory
open FundamentalGroupCompleteInvariant (ConnectedAt)
open FundamentalGroupK1
open FundamentalGroupOut (singleObj_connected singleObjAut singleObjAut_comm)

namespace FundamentalGroupPointed

open PtdMap

/-! ## Transporting centraliser indices along an isomorphism -/

section Transport

/-- The centraliser of the image of a set under an isomorphism is the image of the
centraliser. -/
theorem centralizer_image_map {G H : Type*} [Group G] [Group H] (e : G ≃* H) (S : Set G) :
    Subgroup.centralizer (e '' S) = (Subgroup.centralizer S).map e := by
  ext y
  simp only [Subgroup.mem_centralizer_iff, Subgroup.mem_map, Set.mem_image]
  constructor
  · intro h
    refine ⟨e.symm y, ?_, by simp⟩
    intro s hs
    have h2 := h (e s) ⟨s, hs, rfl⟩
    have h3 := congrArg e.symm h2
    simpa using h3
  · rintro ⟨x, hx, rfl⟩ - ⟨s, hs, rfl⟩
    have h4 : e (s * x) = e (x * s) := by rw [hx s hs]
    simpa using h4

/-- Centraliser indices are invariant under transporting a homomorphism along an
isomorphism of the target. -/
theorem index_centralizer_range_comp {K G H : Type*} [Group K] [Group G] [Group H]
    (e : G ≃* H) (φ : K →* G) :
    (Subgroup.centralizer (Set.range (e.toMonoidHom.comp φ))).index
      = (Subgroup.centralizer (Set.range φ)).index := by
  have hr : Set.range (e.toMonoidHom.comp φ) = e '' Set.range φ := by
    ext y; simp [Set.mem_range, Set.mem_image]
  rw [hr, centralizer_image_map, Subgroup.index_map_equiv]

/-- Precomposition with an isomorphism does not change the image of a homomorphism. -/
theorem range_comp_mulEquiv {K G H : Type*} [Group K] [Group G] [Group H]
    (φ : G →* H) (e : K ≃* G) : Set.range (φ.comp e.toMonoidHom) = Set.range φ := by
  ext y
  constructor
  · rintro ⟨k, rfl⟩; exact ⟨e k, rfl⟩
  · rintro ⟨g, rfl⟩; exact ⟨e.symm g, by simp⟩

end Transport

/-! ## The model `K(S₃,1)` -/

section Perm3

/-- The transposition `(0 1)` of `Fin 3`. -/
def tau : Equiv.Perm (Fin 3) := Equiv.swap 0 1

/-- A homomorphism `S₃ → S₃` with image of order two: the sign, valued in `{1, τ}`. -/
def signSwap : Equiv.Perm (Fin 3) →* Equiv.Perm (Fin 3) where
  toFun g := if Equiv.Perm.sign g = 1 then 1 else tau
  map_one' := by decide
  map_mul' := by decide

/-- The one-object model of `K(S₃,1)`. -/
abbrev PermModel : Type := SingleObj (Equiv.Perm (Fin 3))

/-- Its basepoint. -/
abbrev permStar : PermModel := SingleObj.star (Equiv.Perm (Fin 3))

theorem permModel_connected : ConnectedAt PermModel permStar :=
  singleObj_connected (Equiv.Perm (Fin 3))

/-- The fundamental group of the model is `S₃`. -/
noncomputable abbrev permAut : Aut permStar ≃* Equiv.Perm (Fin 3) :=
  singleObjAut (Equiv.Perm (Fin 3))

/-- The centre of `S₃` is trivial. -/
theorem center_perm3 : Subgroup.center (Equiv.Perm (Fin 3)) = ⊥ := by
  rw [Subgroup.eq_bot_iff_forall]
  decide

/-- Hence the fundamental group of the model has trivial centre. -/
theorem center_autPermStar : Subgroup.center (Aut permStar) = ⊥ := by
  rw [Subgroup.eq_bot_iff_forall]
  intro x hx
  have hmem : permAut x ∈ Subgroup.center (Equiv.Perm (Fin 3)) := by
    rw [Subgroup.mem_center_iff]
    intro g
    have hcomm := (Subgroup.mem_center_iff.1 hx) (permAut.symm g)
    have := congrArg permAut hcomm
    simpa using this
  rw [center_perm3, Subgroup.mem_bot] at hmem
  exact permAut.injective (by simpa using hmem)

theorem card_autPermStar : Nat.card (Aut permStar) = 6 := by
  rw [Nat.card_congr permAut.toEquiv, Nat.card_eq_fintype_card, Fintype.card_perm]
  decide

/-- **Six pointed classes over the class of the identity.**  All six differ by an inner
automorphism of `S₃` (the centre of `S₃` being trivial) and become equal after forgetting
the basepoint, so the pointed classification is strictly finer than the unpointed one. -/
theorem card_ptd_fibre_id_perm :
    Nat.card {x : _root_.Quotient (ptdSetoid PermModel permStar PermModel permStar) //
        forgetBase x = forgetBase (Quotient.mk _ (PtdMap.id PermModel permStar))} = 6 := by
  rw [card_ptd_fibre_id permModel_connected, center_autPermStar, Subgroup.index_bot,
    card_autPermStar]

/-- **One pointed class over the class of the constant map.**  The centraliser of the
trivial image is the whole group, of index one. -/
theorem card_ptd_fibre_trivial_perm :
    Nat.card {x : _root_.Quotient (ptdSetoid PermModel permStar PermModel permStar) //
        forgetBase x = Quotient.mk (natIsoSetoid PermModel PermModel)
          (realize permModel_connected permStar (1 : Aut permStar →* Aut permStar))} = 1 := by
  rw [card_ptd_fibre permModel_connected (1 : Aut permStar →* Aut permStar)]
  have hrange : Set.range (1 : Aut permStar →* Aut permStar) = {1} := by
    ext y; simp [Set.mem_range, eq_comm]
  rw [hrange]
  have htop : Subgroup.centralizer ({1} : Set (Aut permStar)) = ⊤ := by
    ext x
    simp [Subgroup.mem_centralizer_iff]
  rw [htop, Subgroup.index_top]

/-- The order-two homomorphism of `S₃`, transported to the fundamental group of the
model. -/
noncomputable def signSwapAut : Aut permStar →* Aut permStar :=
  permAut.symm.toMonoidHom.comp (signSwap.comp permAut.toMonoidHom)

/-- Membership in the centraliser of `{1, τ}` is decidable, so its order can be computed. -/
instance decMemCentTau :
    DecidablePred (· ∈ Subgroup.centralizer ({1, tau} : Set (Equiv.Perm (Fin 3)))) :=
  fun x => decidable_of_iff (∀ g ∈ ({1, tau} : Set (Equiv.Perm (Fin 3))), g * x = x * g)
    (by simp [Subgroup.mem_centralizer_iff])

/-- The centraliser of `{1, τ}` in `S₃` has exactly two elements. -/
theorem card_centralizer_tau :
    Nat.card (Subgroup.centralizer ({1, tau} : Set (Equiv.Perm (Fin 3)))) = 2 := by
  rw [Nat.card_eq_fintype_card]
  decide

theorem index_centralizer_tau :
    (Subgroup.centralizer ({1, tau} : Set (Equiv.Perm (Fin 3)))).index = 3 := by
  have hprod := Subgroup.card_mul_index
    (Subgroup.centralizer ({1, tau} : Set (Equiv.Perm (Fin 3))))
  have hG : Nat.card (Equiv.Perm (Fin 3)) = 6 := by
    rw [Nat.card_eq_fintype_card, Fintype.card_perm]; decide
  rw [card_centralizer_tau, hG] at hprod
  omega

theorem range_signSwap : Set.range signSwap = ({1, tau} : Set (Equiv.Perm (Fin 3))) := by
  ext y
  simp only [Set.mem_range, Set.mem_insert_iff, Set.mem_singleton_iff]
  revert y
  decide

/-- **Three pointed classes over the class of a map with image of order two.** -/
theorem card_ptd_fibre_signSwap_perm :
    Nat.card {x : _root_.Quotient (ptdSetoid PermModel permStar PermModel permStar) //
        forgetBase x = Quotient.mk (natIsoSetoid PermModel PermModel)
          (realize permModel_connected permStar signSwapAut)} = 3 := by
  rw [card_ptd_fibre permModel_connected signSwapAut]
  rw [signSwapAut, index_centralizer_range_comp, range_comp_mulEquiv, range_signSwap,
    index_centralizer_tau]

end Perm3

/-! ## The abelian extreme: basepoints are irrelevant -/

section Abelian

variable (A : Type*) [CommGroup A]

/-- **For an abelian fundamental group the basepoint carries no information.**  For the
one-object model of `K(A,1)` with `A` abelian — e.g. `A = ℤ/n` — forgetting the basepoint is
injective on homotopy classes of maps, so the pointed and unpointed classifications agree.
Contrast `card_ptd_fibre_id_perm`, where the fibre has six elements. -/
theorem forgetBase_injective_cyclic {C : Type*} [Groupoid C] {c : C} (hC : ConnectedAt C c) :
    Function.Injective
      (forgetBase : _root_.Quotient (ptdSetoid C c (SingleObj A) (SingleObj.star A)) → _) :=
  forgetBase_injective_of_commutative hC (singleObjAut_comm A fun x y => mul_comm x y)

end Abelian

end FundamentalGroupPointed