/-
# Nonabelian examples: a rigid `K(S₃,1)` and a `K(V,1)` with nonabelian `hAut`

`Catalog/Bridges/FundamentalGroupOuterAutomorphisms.lean` proves that the group of homotopy
classes of self-homotopy-equivalences of a `K(G,1)` is `Out G`, and
`Catalog/Bridges/FundamentalGroupWreathProduct.lean` extends this to disjoint unions of
copies of a `K(G,1)`, where the answer is the wreath product `Out(G) ≀ Sym(ι)`.  Both
theorems are only as useful as the outer automorphism groups one can compute, and the
previous cycles computed them only for abelian fundamental groups (cyclic groups, `ℤⁿ`).

This file supplies the first **nonabelian** examples (item 2 of `FUTURE_DIRECTIONS.md`).

* `symmetricGroupThree_forall_inner` : every automorphism of `S₃` is inner (a finite
  verification), hence `outAut_symmetricGroupThree_subsingleton` : `Out(S₃) = 1`;
* `hEnd_units_subsingleton_symmetricGroupThree` : **`K(S₃,1)` is homotopy rigid** — its
  fundamental group is nonabelian and nontrivial, yet the identity is its only
  self-homotopy-equivalence up to homotopy — and `autId_subsingleton_symmetricGroupThree`:
  it also has no nontrivial self-homotopy of the identity, since `Z(S₃) = 1`;
* `card_hAut_three_copies_symmetricGroupThree` : consequently a disjoint union of three
  copies of `K(S₃,1)` has exactly `3! = 6` homotopy classes of self-homotopy-equivalences,
  all coming from permuting the copies;
* `kleinFour` : for the Klein four group `V = (ℤ/2)²` the group `hAut(K(V,1)) ≅ Aut(V)` has
  order `6` and is **nonabelian** (`hAut_kleinFour_not_comm`), the first example in this
  development of a `K(G,1)` with nonabelian homotopy self-equivalence group; the disjoint
  union of two copies has `6² · 2 = 72` of them.
-/
import Mathlib
import Bridges.FundamentalGroupOuterAutomorphisms
import Bridges.FundamentalGroupWreathProduct
open CategoryTheory
open FundamentalGroupCompleteInvariant (ConnectedAt)
open FundamentalGroupOut
open FundamentalGroupWreath

namespace FundamentalGroupRigidity

/-! ## Transport of "every automorphism is inner" -/

section Transport

variable {G : Type*} [Group G] {H : Type*} [Group H]

/-- Having only inner automorphisms is invariant under isomorphism of groups. -/
theorem forall_inner_congr (e : G ≃* H)
    (h : ∀ f : MulAut H, ∃ y : H, ∀ b, f b = y * b * y⁻¹) :
    ∀ f : MulAut G, ∃ x : G, ∀ a, f a = x * a * x⁻¹ := by
  intro f
  obtain ⟨y, hy⟩ := h ((MulAut.congr e) f)
  refine ⟨e.symm y, fun a => ?_⟩
  have key : e (f a) = y * e a * y⁻¹ := by
    have h1 := hy (e a)
    simpa [MulAut.congr] using h1
  have h3 := congrArg e.symm key
  simpa using h3

/-- A group all of whose automorphisms are inner has trivial outer automorphism group. -/
theorem outAut_subsingleton_of_forall_inner
    (h : ∀ f : MulAut G, ∃ x : G, ∀ a, f a = x * a * x⁻¹) : Subsingleton (OutAut G) := by
  have htop : InnAut G = ⊤ := by
    ext e
    simp only [Subgroup.mem_top, iff_true]
    exact (mem_innAut_iff G e).2 (h e)
  refine ⟨fun a b => ?_⟩
  induction a using QuotientGroup.induction_on with
  | H a =>
    induction b using QuotientGroup.induction_on with
    | H b =>
      show (QuotientGroup.mk a : MulAut G ⧸ InnAut G) = QuotientGroup.mk b
      rw [QuotientGroup.eq, htop]
      exact Subgroup.mem_top _

end Transport

/-! ## `S₃` is complete: a homotopy rigid nonabelian `K(G,1)` -/

section SymmetricThree

/-- The algebraic model of `K(S₃,1)`. -/
abbrev SymmThreeModel : Type := SingleObj (Equiv.Perm (Fin 3))

set_option maxRecDepth 100000 in
set_option maxHeartbeats 2000000 in
/-- **Every automorphism of `S₃` is inner.**  (A finite verification over the `720`
bijections of the six-element group `S₃`.) -/
theorem symmetricGroupThree_forall_inner :
    ∀ f : MulAut (Equiv.Perm (Fin 3)), ∃ x : Equiv.Perm (Fin 3), ∀ a, f a = x * a * x⁻¹ := by
  decide

/-- **`Out(S₃) = 1`.** -/
theorem outAut_symmetricGroupThree_subsingleton :
    Subsingleton (OutAut (Equiv.Perm (Fin 3))) :=
  outAut_subsingleton_of_forall_inner symmetricGroupThree_forall_inner

/-- The fundamental group of the model of `K(S₃,1)` has only inner automorphisms. -/
theorem aut_symmThreeModel_forall_inner :
    ∀ f : MulAut (Aut (SingleObj.star (Equiv.Perm (Fin 3)))),
      ∃ x, ∀ a, f a = x * a * x⁻¹ :=
  forall_inner_congr (singleObjAut (Equiv.Perm (Fin 3))) symmetricGroupThree_forall_inner

/-- **`K(S₃,1)` is homotopy rigid**: the identity is its only self-homotopy-equivalence up
to homotopy, even though its fundamental group is nonabelian of order `6`. -/
theorem hEnd_units_subsingleton_symmetricGroupThree :
    Subsingleton ((HEnd SymmThreeModel)ˣ) :=
  hEnd_units_subsingleton_of_out_trivial (singleObj_connected _)
    (outAut_subsingleton_of_forall_inner aut_symmThreeModel_forall_inner)

/-- `K(S₃,1)` has exactly one homotopy class of self-homotopy-equivalences. -/
theorem card_hEnd_units_symmetricGroupThree :
    Nat.card ((HEnd SymmThreeModel)ˣ) = 1 := by
  haveI := hEnd_units_subsingleton_symmetricGroupThree
  haveI : Unique ((HEnd SymmThreeModel)ˣ) := uniqueOfSubsingleton 1
  exact Nat.card_unique

/-- The centre of `S₃` is trivial. -/
theorem center_symmetricGroupThree_subsingleton :
    Subsingleton (Subgroup.center (Equiv.Perm (Fin 3))) := by
  have h : ∀ z : Equiv.Perm (Fin 3), (∀ a, z * a = a * z) → z = 1 := by decide
  refine ⟨fun x y => ?_⟩
  have hx : (x : Equiv.Perm (Fin 3)) = 1 :=
    h x fun a => (Subgroup.mem_center_iff.1 x.2 a).symm
  have hy : (y : Equiv.Perm (Fin 3)) = 1 :=
    h y fun a => (Subgroup.mem_center_iff.1 y.2 a).symm
  exact Subtype.ext (hx.trans hy.symm)

/-- The centre of the fundamental group of the model of `K(S₃,1)` is trivial. -/
theorem center_aut_symmThreeModel_subsingleton :
    Subsingleton (Subgroup.center (Aut (SingleObj.star (Equiv.Perm (Fin 3))))) := by
  refine ⟨fun x y => ?_⟩
  have hcen : ∀ z : Subgroup.center (Aut (SingleObj.star (Equiv.Perm (Fin 3)))),
      (singleObjAut (Equiv.Perm (Fin 3)) (z : Aut (SingleObj.star (Equiv.Perm (Fin 3)))))
        ∈ Subgroup.center (Equiv.Perm (Fin 3)) := by
    intro z
    refine Subgroup.mem_center_iff.2 fun g => ?_
    have hz := Subgroup.mem_center_iff.1 z.2 ((singleObjAut (Equiv.Perm (Fin 3))).symm g)
    have h2 := congrArg (singleObjAut (Equiv.Perm (Fin 3))) hz
    simpa using h2
  haveI := center_symmetricGroupThree_subsingleton
  have hxy : (⟨_, hcen x⟩ : Subgroup.center (Equiv.Perm (Fin 3))) = ⟨_, hcen y⟩ :=
    Subsingleton.elim _ _
  exact Subtype.ext ((singleObjAut (Equiv.Perm (Fin 3))).injective (congrArg Subtype.val hxy))

/-- `K(S₃,1)` has no nontrivial self-homotopy of the identity either: the automorphism
2-group of `K(S₃,1)` is trivial (`π₀ = Out(S₃) = 1`, `π₁ = Z(S₃) = 1`). -/
theorem autId_subsingleton_symmetricGroupThree : Subsingleton (Aut (𝟭 SymmThreeModel)) := by
  haveI := center_aut_symmThreeModel_subsingleton
  exact (autId_mulEquiv_center (singleObj_connected (Equiv.Perm (Fin 3)))).toEquiv.subsingleton

/-- **A disjoint union of three copies of `K(S₃,1)` has exactly `6` homotopy classes of
self-homotopy-equivalences**, namely the permutations of the three copies: the rigidity of
each copy makes the wreath product `Out(S₃) ≀ S₃` collapse to `S₃`. -/
theorem card_hAut_three_copies_symmetricGroupThree :
    Nat.card ((HEnd (Discrete (Fin 3) × SymmThreeModel))ˣ) = 6 := by
  rw [card_hAut_sigma_of_card_hAut (singleObj_connected (Equiv.Perm (Fin 3))),
    card_hEnd_units_symmetricGroupThree]
  decide

/-- The whole automorphism 2-group of a disjoint union of three copies of `K(S₃,1)` is the
symmetric group `S₃` permuting the copies: `π₀ = S₃` (above) and `π₁ = 1`. -/
theorem autId_subsingleton_three_copies_symmetricGroupThree :
    Subsingleton (Aut (𝟭 (Discrete (Fin 3) × SymmThreeModel))) := by
  haveI := center_aut_symmThreeModel_subsingleton
  haveI : Subsingleton (Fin 3 → Subgroup.center (Aut (SingleObj.star (Equiv.Perm (Fin 3))))) :=
    Pi.instSubsingleton
  exact (autIdProdMulEquivPiCenter (ι := Fin 3)
    (singleObj_connected (Equiv.Perm (Fin 3)))).toEquiv.subsingleton

end SymmetricThree

/-! ## The Klein four group: a `K(G,1)` with nonabelian `hAut` -/

section KleinFour

/-- The Klein four group, written multiplicatively. -/
abbrev KleinFour : Type := Multiplicative (ZMod 2 × ZMod 2)

/-- The algebraic model of `K(V,1)` for the Klein four group `V`. -/
abbrev KleinModel : Type := SingleObj KleinFour

theorem kleinFour_comm (x y : KleinFour) : x * y = y * x := mul_comm x y

/-- `hAut(K(V,1)) ≅ Aut(V)` for the Klein four group `V`. -/
noncomputable def hEndUnitsKleinMulEquivMulAut : (HEnd KleinModel)ˣ ≃* MulAut KleinFour :=
  hEndUnitsSingleObjMulEquivMulAut KleinFour kleinFour_comm

set_option maxRecDepth 100000 in
/-- `Aut(V)` has six elements. -/
theorem card_mulAut_kleinFour : Nat.card (MulAut KleinFour) = 6 := by
  simp only [Nat.card_eq_fintype_card]
  decide

/-- **`K(V,1)` has exactly six homotopy classes of self-homotopy-equivalences.** -/
theorem card_hAut_kleinFour : Nat.card ((HEnd KleinModel)ˣ) = 6 := by
  rw [Nat.card_congr hEndUnitsKleinMulEquivMulAut.toEquiv, card_mulAut_kleinFour]

set_option maxRecDepth 100000 in
/-- `Aut(V)` is nonabelian (it is isomorphic to `S₃`). -/
theorem mulAut_kleinFour_not_comm : ¬ ∀ x y : MulAut KleinFour, x * y = y * x := by decide

/-- **The homotopy self-equivalence group of `K(V,1)` is nonabelian.**  Thus even an
abelian fundamental group can produce a nonabelian `hAut`. -/
theorem hAut_kleinFour_not_comm : ¬ ∀ x y : (HEnd KleinModel)ˣ, x * y = y * x := by
  intro h
  refine mulAut_kleinFour_not_comm fun a b => ?_
  have := h (hEndUnitsKleinMulEquivMulAut.symm a) (hEndUnitsKleinMulEquivMulAut.symm b)
  have h2 := congrArg hEndUnitsKleinMulEquivMulAut this
  simpa using h2

/-- A disjoint union of two copies of `K(V,1)` has `6² · 2 = 72` homotopy classes of
self-homotopy-equivalences. -/
theorem card_hAut_two_copies_kleinFour :
    Nat.card ((HEnd (Discrete (Fin 2) × KleinModel))ˣ) = 72 := by
  rw [card_hAut_sigma_of_card_hAut (singleObj_connected KleinFour), card_hAut_kleinFour]
  decide

end KleinFour

end FundamentalGroupRigidity