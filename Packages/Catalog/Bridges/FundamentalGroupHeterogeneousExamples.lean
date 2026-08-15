/-
# Two concrete disjoint unions: a rigid one and a symmetric one

`Catalog/Bridges/FundamentalGroupHeterogeneousWreath.lean` computes the homotopy
self-equivalence group of an arbitrary disjoint union `⊔ᵢ Cᵢ` of connected 1-types: it is
an extension of the group of permutations of the components preserving their homotopy type
by `∏ᵢ Out(π₁ Cᵢ)`.  This file exhibits the two extreme behaviours of that extension on
concrete examples.

* `twoPieces` is the disjoint union `K(ℤ,1) ⊔ K(ℤ/3,1)` (a circle and an infinite lens
  space).  Its two components are **not** homotopy equivalent (`twoPieces_pairwise`), so no
  self-equivalence can interchange them (`twoPieces_perm_trivial`) and
  `card_hAut_twoPieces` : it has exactly `2 · 2 = 4` homotopy classes of
  self-homotopy-equivalences, namely `Out(ℤ) × Out(ℤ/3) = ±1 × (ℤ/3)ˣ`.
* For a *constant* family the opposite happens: `perm_surjective_of_constant` shows every
  permutation of the components is realised by a self-equivalence.
-/
import Mathlib
import Bridges.FundamentalGroupHeterogeneousWreath
import Bridges.FundamentalGroupCyclicSelfEquivalences
open CategoryTheory
open FundamentalGroupCompleteInvariant (ConnectedAt)
open FundamentalGroupOut
open FundamentalGroupHetero

namespace FundamentalGroupHeteroExamples

/-! ## `K(ℤ,1) ⊔ K(ℤ/3,1)` -/

/-- The two-component 1-type `K(ℤ,1) ⊔ K(ℤ/3,1)`, as a family indexed by `Bool`. -/
def twoPieces : Bool → Type
  | false => CircleModel
  | true => FundamentalGroupCyclic.CyclicModel 3

instance instGroupoidTwoPieces : ∀ b, Groupoid (twoPieces b)
  | false => inferInstanceAs (Groupoid CircleModel)
  | true => inferInstanceAs (Groupoid (FundamentalGroupCyclic.CyclicModel 3))

/-- The chosen basepoints of the two components. -/
def twoBase : ∀ b, twoPieces b
  | false => SingleObj.star (Multiplicative ℤ)
  | true => SingleObj.star (Multiplicative (ZMod 3))

theorem twoPieces_connected : ∀ b, ConnectedAt (twoPieces b) (twoBase b)
  | false => singleObj_connected (Multiplicative ℤ)
  | true => singleObj_connected (Multiplicative (ZMod 3))

/-- The vertex group of the first component is `ℤ`. -/
noncomputable def twoAutFalse : Aut (twoBase false) ≃* Multiplicative ℤ :=
  singleObjAut (Multiplicative ℤ)

/-- The vertex group of the second component is `ℤ/3`. -/
noncomputable def twoAutTrue : Aut (twoBase true) ≃* Multiplicative (ZMod 3) :=
  singleObjAut (Multiplicative (ZMod 3))

/-- An equivalence between the two components would identify `ℤ` with `ℤ/3`. -/
theorem no_equivalence_false_true : ¬ Nonempty (twoPieces false ≌ twoPieces true) := by
  rintro ⟨E⟩
  obtain ⟨w⟩ := FundamentalGroupCompleteInvariant.aut_mulEquiv_of_groupoid_equivalence E
    (twoBase false)
  have e : Multiplicative ℤ ≃ Multiplicative (ZMod 3) :=
    (twoAutFalse.symm.trans (w.trans twoAutTrue)).toEquiv
  haveI : Infinite (Multiplicative (ZMod 3)) := (Equiv.infinite_iff e).mp inferInstance
  exact not_finite (Multiplicative (ZMod 3))

/-- **The two components have different homotopy types.** -/
theorem twoPieces_pairwise (b b' : Bool) (h : Nonempty (twoPieces b ≌ twoPieces b')) :
    b = b' := by
  match b, b' with
  | false, false => rfl
  | true, true => rfl
  | false, true => exact absurd h no_equivalence_false_true
  | true, false =>
    exact absurd (h.map CategoryTheory.Equivalence.symm) no_equivalence_false_true

/-- **No self-equivalence of `K(ℤ,1) ⊔ K(ℤ/3,1)` interchanges the two components.** -/
theorem twoPieces_perm_trivial (u : (HEnd (Σ b, twoPieces b))ˣ) :
    hAutSigmaToPerm twoPieces_connected u = 1 :=
  hAutSigmaToPerm_eq_one_of_pairwise twoPieces_connected twoPieces_pairwise u

theorem card_out_false : Nat.card (OutAut (Aut (twoBase false))) = 2 := by
  show Nat.card (OutAut (Aut (SingleObj.star (Multiplicative ℤ)))) = 2
  rw [← card_hEnd_units (C := CircleModel) (singleObj_connected (Multiplicative ℤ))]
  exact card_hEnd_units_circleModel

theorem card_out_true : Nat.card (OutAut (Aut (twoBase true))) = 2 := by
  show Nat.card (OutAut (Aut (SingleObj.star (Multiplicative (ZMod 3))))) = 2
  rw [← card_hEnd_units (C := FundamentalGroupCyclic.CyclicModel 3)
    (singleObj_connected (Multiplicative (ZMod 3)))]
  rw [FundamentalGroupCyclic.card_hEnd_units_cyclicModel 3]
  decide

/-- **`K(ℤ,1) ⊔ K(ℤ/3,1)` has exactly four homotopy classes of self-homotopy-equivalences**
— the four pairs `(±1, ±1) ∈ Out(ℤ) × Out(ℤ/3)`, with no relabelling of the components. -/
theorem card_hAut_twoPieces : Nat.card ((HEnd (Σ b, twoPieces b))ˣ) = 4 := by
  rw [card_hAut_of_pairwise twoPieces_connected twoPieces_pairwise, Fintype.prod_bool,
    card_out_false, card_out_true]
  norm_num

/-! ## A constant family: every permutation of the components is realised -/

section Constant

universe w v u

variable {ι : Type w} {D : Type u} [Groupoid.{v} D] {d : D}

/-- **For a disjoint union of copies of one 1-type, every permutation of the components
comes from a self-homotopy-equivalence.**  This is the opposite extreme to
`twoPieces_perm_trivial`. -/
theorem perm_surjective_of_constant (hD : ConnectedAt D d) (σ : Equiv.Perm ι) :
    ∃ u : (HEnd (Σ _ : ι, D))ˣ,
      hAutSigmaToPerm (C := fun _ : ι => D) (c := fun _ => d) (fun _ => hD) u = σ :=
  (exists_hAut_perm_iff (C := fun _ : ι => D) (c := fun _ => d) (fun _ => hD) σ).2
    fun _ => ⟨CategoryTheory.Equivalence.refl⟩

end Constant

end FundamentalGroupHeteroExamples