/-
  # Structural Cases of Frankl's Conjecture

  This module proves Frankl's conjecture for specific structural classes
  of union-closed families.

  ## Main results

  * `Frankl.frankl_of_all_nonempty_contain_fixed` — families where all
    nonempty members share a common element
  * `Frankl.frankl_of_singleton_mem` — families containing a singleton
  * `Frankl.frankl_of_card_le_two` — families with at most 2 members
-/
import Mathlib
import Speculative.Frankl.Defs

namespace Frankl

open Finset

variable {α : Type*} [Fintype α] [DecidableEq α]

/-
If every nonempty member of `F` contains a fixed element `a`, and `F`
    contains the empty set and at least one nonempty member, then `a` is
    a Frankl witness.

    Proof: the sets not containing `a` are exactly `{∅}`, so `a` appears
    in all but one member of `F`.
-/
theorem frankl_of_all_nonempty_contain_fixed
    (F : Finset (Finset α)) (a : α)
    (h_empty : ∅ ∈ F)
    (h_fixed : ∀ s ∈ F, s ≠ ∅ → a ∈ s)
    (h_nontrivial : ∃ s ∈ F, s.Nonempty) :
    IsFranklWitness F a := by
  -- By definition of `IsFranklWitness`, we need to show that `2 * elemFreq F a ≥ F.card`.
  unfold IsFranklWitness;
  -- The sets not containing `a` are exactly `{∅}`, so `elemFreq F a = F.card - 1`.
  have h_elemFreq : elemFreq F a = F.card - 1 := by
    unfold elemFreq;
    rw [ show { s ∈ F | a ∈ s } = F \ { ∅ } from ?_, Finset.card_sdiff ] <;> aesop;
  grind +suggestions

/-
If a singleton `{a}` belongs to a union-closed family, then `a`
    appears in at least half the members.

    Proof: for every `s ∈ F`, we have `s ∪ {a} ∈ F` by union-closure,
    and `a ∈ s ∪ {a}`. The map `s ↦ s ∪ {a}` is injective on `F`,
    so the sets containing `a` are at least as many as those not.
-/
theorem frankl_of_singleton_mem
    (F : Finset (Finset α))
    (hUC : IsUnionClosedFamily F)
    (a : α) (ha : ({a} : Finset α) ∈ F) :
    IsFranklWitness F a := by
  -- Consider the partition of F into sets containing a and sets not containing a.
  set contains_a := Finset.filter (fun s => a ∈ s) F
  set not_contains_a := Finset.filter (fun s => a ∉ s) F
  have h_partition : F = contains_a ∪ not_contains_a := by
    grind;
  -- For any set $s \in \text{not_contains_a}$, $s \cup \{a\} \in \text{contains_a}$ and $s \cup \{a\} \neq s$ (since $a \notin s$ but $a \in s \cup \{a\}$).
  have h_inj : Finset.card not_contains_a ≤ Finset.card contains_a := by
    have h_inj : Finset.card (Finset.image (fun s => s ∪ {a}) not_contains_a) ≤ Finset.card contains_a := by
      refine Finset.card_le_card ?_;
      simp +contextual [ Finset.subset_iff, hUC.2 ];
      simp +contextual [ contains_a, not_contains_a, hUC.2 ];
      exact fun s hs hs' => by simpa [ hs' ] using hUC.2 _ hs _ ha;
    rwa [ Finset.card_image_of_injOn ] at h_inj;
    intro s hs t ht; simp +contextual [ Finset.ext_iff ] at *;
    grind;
  -- Since $contains_a$ and $not_contains_a$ are disjoint and their union is $F$, we have $F.card = contains_a.card + not_contains_a.card$.
  have h_card : F.card = contains_a.card + not_contains_a.card := by
    rw [ ← Finset.card_union_of_disjoint ( Finset.disjoint_filter.mpr fun _ _ _ => by tauto ), ← h_partition ];
  exact show 2 * contains_a.card ≥ F.card from by linarith;

/-
Frankl holds for families with at most 2 members.
-/
theorem frankl_of_card_le_two
    (F : Finset (Finset α))
    (hUC : IsUnionClosedFamily F)
    (hne : ∃ A ∈ F, A.Nonempty)
    (hcard : F.card ≤ 2) :
    ∃ a : α, IsFranklWitness F a := by
  interval_cases _ : F.card;
  · aesop;
  · exact absurd ( hUC.1 ) ( by rw [ Finset.card_eq_one ] at *; aesop );
  · -- Since F has exactly 2 members, let's denote them as ∅ and A.
    obtain ⟨A, hA⟩ : ∃ A ∈ F, A.Nonempty ∧ F = {∅, A} := by
      rw [ Finset.card_eq_two ] at *;
      cases hUC ; aesop;
    obtain ⟨ a, ha ⟩ := hA.2.1; use a; unfold IsFranklWitness; simp_all +decide ;
    exact Finset.card_pos.mpr ⟨ A, by aesop ⟩

end Frankl