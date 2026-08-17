/-
# Abelian fundamental groups, and a covering that the fundamental group cannot see

This file completes the covering-space thread of the catalog
(`Bridges/FundamentalGroupCoveringGalois.lean`,
`Bridges/FundamentalGroupCoveringDeck.lean`) with two kinds of results.

**Abelian base.**  If `π₁ = G` is abelian, conjugacy of subgroups is equality, so the
Galois correspondence becomes a bijection with the subgroup lattice itself: every
covering is regular and the deck group of the covering classified by `H` is `G ⧸ H`
(`deckAbelianMulEquiv`, `nonempty_gEquiv_iff_stabilizer_eq_of_comm`).

**A limitation of the fundamental group.**  The catalog already knows that the
fundamental group is a *complete* invariant of connected homotopy `1`-types.  Here we
show that it is *not* a complete invariant of coverings: over the Klein four group
`V = ℤ/2 × ℤ/2` (the fundamental group of the `2`-torus mod squares, or simply the
`K(V,1)`) the two double coverings classified by the two coordinate subgroups have

* equivalent total `1`-types (`kleinCoverings_groupoid_equivalent`), hence isomorphic
  fundamental groups (both `ℤ/2`),
* the same number of sheets (`kleinCoverings_index`), yet
* they are not isomorphic as coverings (`kleinCoverings_not_isomorphic`).

So the homotopy type of the total space, together with the number of sheets, does not
determine a covering: the extra datum is the *position* of the subgroup inside `π₁`.
-/
import Mathlib
import Bridges.FundamentalGroupCoveringGalois
import Bridges.FundamentalGroupCoveringDeck

open CategoryTheory MulAction
open FundamentalGroupCompleteInvariant (ConnectedAt)

namespace FundamentalGroupCovering

universe u

/-! ## Coverings of a `K(G,1)` with abelian fundamental group -/

section Abelian

variable {G : Type u} [Group G] {X Y : Type u} [MulAction G X] [MulAction G Y]

/-- In a commutative group conjugation acts trivially on subgroups. -/
theorem map_conj_eq_of_comm (hcomm : ∀ x y : G, x * y = y * x) (K : Subgroup G) (g : G) :
    K.map (MulAut.conj g).toMonoidHom = K := by
  ext a
  simp only [Subgroup.mem_map, MulEquiv.coe_toMonoidHom, MulAut.conj_apply]
  constructor
  · rintro ⟨b, hb, rfl⟩
    have : g * b * g⁻¹ = b := by
      rw [hcomm g b, mul_assoc, mul_inv_cancel, mul_one]
    rwa [this]
  · intro ha
    exact ⟨a, ha, by rw [hcomm g a, mul_assoc, mul_inv_cancel, mul_one]⟩

/-- **Over an abelian `K(G,1)` two connected coverings are isomorphic exactly when their
subgroups are equal**: the Galois correspondence is a bijection with the subgroup
lattice, with no conjugacy ambiguity. -/
theorem nonempty_gEquiv_iff_stabilizer_eq_of_comm (hcomm : ∀ x y : G, x * y = y * x)
    [IsPretransitive G X] [IsPretransitive G Y] (x : X) (y : Y) :
    Nonempty (GEquiv G X Y) ↔ stabilizer G y = stabilizer G x := by
  rw [nonempty_gEquiv_iff_isConj x y]
  constructor
  · rintro ⟨g, hg⟩
    rwa [map_conj_eq_of_comm hcomm] at hg
  · intro h
    exact ⟨1, by rw [map_conj_eq_of_comm hcomm, h]⟩

variable (H : Subgroup G)

/-- For a commutative group every subgroup is its own normaliser. -/
theorem normalizer_eq_top_of_comm (hcomm : ∀ x y : G, x * y = y * x) :
    H.normalizer = ⊤ := by
  rw [Subgroup.normalizer_eq_top_iff]
  exact ⟨fun n hn g => by
    have : g * n * g⁻¹ = n := by rw [hcomm g n, mul_assoc, mul_inv_cancel, mul_one]
    rwa [this]⟩

/-- Every covering of an abelian `K(G,1)` is regular. -/
theorem deck_transitive_of_comm (hcomm : ∀ x y : G, x * y = y * x) :
    ∀ p q : G ⧸ H, ∃ f ∈ DeckSubgroup G (G ⧸ H), f p = q := by
  rw [deck_transitive_iff_normal]
  exact Subgroup.normalizer_eq_top_iff.mp (normalizer_eq_top_of_comm H hcomm)

end Abelian

/-! ## The deck group of a regular covering -/

section Regular

variable {G : Type u} [Group G] (H : Subgroup G) [H.Normal]

/-- For a normal subgroup the whole group lies in the normaliser. -/
def toNormalizerOfNormal : G →* H.normalizer where
  toFun g := ⟨g, by rw [Subgroup.normalizer_eq_top_iff.mpr (inferInstance : H.Normal)]; trivial⟩
  map_one' := rfl
  map_mul' _ _ := rfl

/-- The deck homomorphism of a regular covering, defined on all of `G`. -/
def deckHomOfNormal : G →* DeckSubgroup G (G ⧸ H) :=
  (deckHom H).comp (toNormalizerOfNormal H)

theorem deckHomOfNormal_surjective : Function.Surjective (deckHomOfNormal H) := by
  intro f
  obtain ⟨n, hn⟩ := deckHom_surjective H f
  refine ⟨(n : G), ?_⟩
  show (deckHom H) ((toNormalizerOfNormal H) (n : G)) = f
  rw [show ((toNormalizerOfNormal H) (n : G)) = n from Subtype.ext rfl]
  exact hn

theorem deckHomOfNormal_ker : (deckHomOfNormal H).ker = H := by
  ext g
  constructor
  · intro hg
    have hg' : (toNormalizerOfNormal H) g ∈ (deckHom H).ker := hg
    rw [deckHom_ker] at hg'
    exact Subgroup.mem_subgroupOf.mp hg'
  · intro hg
    have hg' : (toNormalizerOfNormal H) g ∈ H.subgroupOf H.normalizer :=
      Subgroup.mem_subgroupOf.mpr hg
    rw [← deckHom_ker] at hg'
    exact hg'

/-- **The deck group of a regular covering is the quotient `π₁ / H`.**  Together with
`deck_transitive_iff_normal` this is the classical statement that a covering is regular
precisely when it is a principal bundle for the quotient group. -/
noncomputable def deckRegularMulEquiv : (G ⧸ H) ≃* DeckSubgroup G (G ⧸ H) :=
  (QuotientGroup.quotientMulEquivOfEq (deckHomOfNormal_ker H).symm).trans
    (QuotientGroup.quotientKerEquivOfSurjective (deckHomOfNormal H)
      (deckHomOfNormal_surjective H))

end Regular

/-! ## The Klein four group: two double coverings the fundamental group cannot tell apart -/

section Klein

/-- The cyclic group of order two, written multiplicatively. -/
abbrev C2 : Type := Multiplicative (ZMod 2)

/-- The Klein four group as the fundamental group of the base `K(V,1)`. -/
abbrev V : Type := C2 × C2

theorem V_comm : ∀ x y : V, x * y = y * x := fun x y => mul_comm x y

/-- The first coordinate subgroup of the Klein four group. -/
def Hfst : Subgroup V := (⊤ : Subgroup C2).prod ⊥

/-- The second coordinate subgroup of the Klein four group. -/
def Hsnd : Subgroup V := (⊥ : Subgroup C2).prod ⊤

theorem card_C2 : Nat.card C2 = 2 := by
  simp [Nat.card_eq_fintype_card]

theorem index_Hfst : Hfst.index = 2 := by
  rw [Hfst, Subgroup.index_prod, Subgroup.index_top, Subgroup.index_bot, card_C2, one_mul]

theorem index_Hsnd : Hsnd.index = 2 := by
  rw [Hsnd, Subgroup.index_prod, Subgroup.index_top, Subgroup.index_bot, card_C2, mul_one]

/-- **Both coverings are double coverings.** -/
theorem kleinCoverings_index : Hfst.index = 2 ∧ Hsnd.index = 2 :=
  ⟨index_Hfst, index_Hsnd⟩

theorem Hfst_ne_Hsnd : Hfst ≠ Hsnd := by
  intro h
  have hmem : ((Multiplicative.ofAdd (1 : ZMod 2), 1) : V) ∈ Hfst := by
    constructor
    · trivial
    · exact Subgroup.mem_bot.mpr rfl
  rw [h] at hmem
  have : (Multiplicative.ofAdd (1 : ZMod 2)) = 1 := Subgroup.mem_bot.mp hmem.1
  exact absurd this (by decide)

/-- Swapping the coordinates of the Klein four group carries one coordinate subgroup onto
the other. -/
theorem map_prodComm_Hfst :
    Subgroup.map (MulEquiv.prodComm (M := C2) (N := C2)).toMonoidHom Hfst = Hsnd := by
  ext ⟨a, b⟩
  constructor
  · rintro ⟨⟨c, d⟩, hcd, heq⟩
    have hd : d = 1 := Subgroup.mem_bot.mp (Subgroup.mem_prod.mp hcd).2
    have heq' : ((d, c) : V) = (a, b) := heq
    have ha : d = a := congrArg Prod.fst heq'
    refine Subgroup.mem_prod.mpr ⟨?_, trivial⟩
    show a ∈ (⊥ : Subgroup C2)
    rw [← ha, hd]
    exact Subgroup.mem_bot.mpr rfl
  · intro hab
    have ha : a = 1 := Subgroup.mem_bot.mp (Subgroup.mem_prod.mp hab).1
    refine ⟨(b, a), Subgroup.mem_prod.mpr ⟨trivial, ?_⟩, ?_⟩
    · show a ∈ (⊥ : Subgroup C2)
      rw [ha]
      exact Subgroup.mem_bot.mpr rfl
    · show ((a, b) : V) = (a, b)
      rfl

/-- The two subgroups are abstractly isomorphic: both are cyclic of order two. -/
noncomputable def hfstMulEquivHsnd : Hfst ≃* Hsnd :=
  ((MulEquiv.prodComm (M := C2) (N := C2)).subgroupMap Hfst).trans
    (MulEquiv.subgroupCongr map_prodComm_Hfst)

/-- The fundamental group of each of the two coverings is the corresponding coordinate
subgroup. -/
noncomputable def autCoveringMulEquiv (H : Subgroup V) :
    Aut (ActionCategory.objEquiv V (V ⧸ H) ((1 : V) : V ⧸ H)) ≃* H :=
  (autMulEquivStabilizer (G := V) (X := V ⧸ H) (((1 : V) : V ⧸ H))).trans
    (MulEquiv.subgroupCongr (MulAction.stabilizer_quotient H))

/-- **The two double coverings have equivalent total `1`-types**: their fundamental
groups are isomorphic (both of order two) and both are connected, so as homotopy
`1`-types they cannot be distinguished. -/
theorem kleinCoverings_groupoid_equivalent :
    Nonempty (ActionCategory V (V ⧸ Hfst) ≌ ActionCategory V (V ⧸ Hsnd)) :=
  FundamentalGroupCompleteInvariant.connectedGroupoids_equivalent_of_aut_mulEquiv
    (ActionCategory.objEquiv V (V ⧸ Hfst) ((1 : V) : V ⧸ Hfst))
    (ActionCategory.objEquiv V (V ⧸ Hsnd) ((1 : V) : V ⧸ Hsnd))
    (connectedAt_actionCategory _) (connectedAt_actionCategory _)
    (((autCoveringMulEquiv Hfst).trans hfstMulEquivHsnd).trans (autCoveringMulEquiv Hsnd).symm)

/-- **But the two coverings are not isomorphic as coverings.**  Over an abelian base
isomorphic coverings have equal subgroups, and the two coordinate subgroups differ. -/
theorem kleinCoverings_not_isomorphic :
    ¬ Nonempty (GEquiv V (V ⧸ Hfst) (V ⧸ Hsnd)) := by
  intro h
  rw [nonempty_gEquiv_iff_stabilizer_eq_of_comm V_comm
      (((1 : V) : V ⧸ Hfst)) (((1 : V) : V ⧸ Hsnd))] at h
  rw [MulAction.stabilizer_quotient, MulAction.stabilizer_quotient] at h
  exact Hfst_ne_Hsnd h.symm

/-- **The fundamental group is not a complete invariant of coverings.**  Two double
coverings of the same `K(V,1)` may have equivalent total `1`-types — hence isomorphic
fundamental groups — and the same number of sheets, and still be non-isomorphic as
coverings.  What the fundamental group of the total space forgets is the position of the
subgroup inside `π₁` of the base. -/
theorem fundamentalGroup_not_complete_invariant_for_coverings :
    Nonempty (ActionCategory V (V ⧸ Hfst) ≌ ActionCategory V (V ⧸ Hsnd)) ∧
      Hfst.index = Hsnd.index ∧
      ¬ Nonempty (GEquiv V (V ⧸ Hfst) (V ⧸ Hsnd)) :=
  ⟨kleinCoverings_groupoid_equivalent, by rw [index_Hfst, index_Hsnd],
    kleinCoverings_not_isomorphic⟩

end Klein

end FundamentalGroupCovering