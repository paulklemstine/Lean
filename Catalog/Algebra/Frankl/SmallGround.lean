/-
# Frankl's Conjecture for Small Ground Sets

This file proves Frankl's conjecture for union-closed families whose
ground set has cardinality at most 3 (when the ground is nonempty).

## Main Results

* `frankl_ground_card_le_one` - one-element ground case
* `frankl_ground_card_le_two` - two-element ground case
* `frankl_ground_card_le_three` - three-element ground case (Theorem A)
-/

import Algebra.Frankl.AverageCriterion

open Finset BigOperators

namespace UnionClosedFamily

variable {α : Type*} [DecidableEq α]

/-
**Key lemma for small ground cases.** If the family contains a singleton
{a}, then a appears in every set that contains a (trivially), and union-closure
forces a to appear in many sets. In fact, for any s ∈ F containing a, we have
{a} ∪ s = s ∈ F. More usefully, for any s ∈ F, the set s ∪ {a} ∈ F, so
every set "generates" a set containing a. This gives freq(a) ≥ |F|/2 when
|F| counts are appropriately paired.
-/
theorem frankl_of_singleton_in_sets (F : UnionClosedFamily α) (a : α)
    (ha : {a} ∈ F.sets) : 2 * F.elemFreq a ≥ F.sets.card := by
  -- Define the injection: for each set s ∈ F.sets with a ∉ s, map s ↦ s ∪ {a}.
  have h_inj : Finset.card (Finset.image (fun s => s ∪ {a}) (F.sets.filter (fun s => a ∉ s))) ≤ Finset.card (F.sets.filter (fun s => a ∈ s)) := by
    refine Finset.card_le_card ?_;
    grind +suggestions;
  rw [ Finset.card_image_of_injOn ] at h_inj;
  · linarith! [ show F.elemFreq a = ( F.sets.filter ( fun s => a ∈ s ) ).card from rfl, show ( F.sets.filter ( fun s => a ∉ s ) ).card + ( F.sets.filter ( fun s => a ∈ s ) ).card = F.sets.card from by rw [ Finset.card_filter, Finset.card_filter ] ; rw [ ← Finset.sum_add_distrib ] ; exact Finset.card_eq_sum_ones F.sets ▸ Finset.sum_congr rfl fun _ _ => by by_cases h : a ∈ ‹Finset α› <;> simp +decide [ h ] ];
  · intro s hs t ht; simp_all +decide [ Finset.ext_iff ] ;
    grind

/-
Frankl's conjecture for ground set of size at most 1.
If there's exactly one ground element a, every nonempty set contains a,
so freq(a) = |F| (or |F| - 1 if ∅ ∈ F), which is ≥ |F|/2.
-/
theorem frankl_ground_card_le_one (F : UnionClosedFamily α)
    (hg : F.ground.Nonempty)
    (h : F.ground.card ≤ 1) : F.HasFranklWitness := by
  -- Since there's exactly one ground element a, every nonempty set contains a.
  obtain ⟨a, ha⟩ : ∃ a, F.ground = {a} := by
    exact Finset.card_eq_one.mp ( le_antisymm h ( Finset.card_pos.mpr hg ) );
  -- Since there's exactly one ground element a, every nonempty set contains a. Thus, {a} is in F.sets.
  have h_singleton_in_sets : {a} ∈ F.sets := by
    obtain ⟨ s, hs ⟩ := F.mem_ground_iff a |>.1 ( ha.symm ▸ by simp +decide );
    have := F.subset_ground s hs.1; aesop;
  exact ⟨ a, frankl_of_singleton_in_sets F a h_singleton_in_sets ⟩

/-
Frankl's conjecture for ground set of size at most 2.
-/
theorem frankl_ground_card_le_two (F : UnionClosedFamily α)
    (hg : F.ground.Nonempty)
    (h : F.ground.card ≤ 2) : F.HasFranklWitness := by
  by_cases ha : ∃ a, { a } ∈ F.sets <;> by_cases hb : ∃ b, { b } ∈ F.sets <;> simp_all +decide [ F.union_closed ];
  · exact ⟨ hb.choose, frankl_of_singleton_in_sets F hb.choose hb.choose_spec ⟩;
  · -- Since there are no singletons in F, every set in F is either empty or the entire ground set.
    have h_sets : ∀ s ∈ F.sets, s = ∅ ∨ s = F.ground := by
      intro s hs; have := Finset.card_le_card ( F.subset_ground s hs ) ; interval_cases _ : Finset.card ( F.ground ) <;> simp_all +decide ;
      · interval_cases _ : #s <;> simp_all +decide [ Finset.card_eq_one ];
        grind;
      · interval_cases _ : #s <;> simp_all +decide [ Finset.eq_empty_iff_forall_notMem ];
        · rw [ Finset.card_eq_one ] at * ; aesop;
        · exact Or.inr ( Finset.eq_of_subset_of_card_le ( F.subset_ground s hs ) ( by aesop ) );
    -- Since F is nonempty and contains the entire ground set, it must have at least one set containing the entire ground set.
    obtain ⟨s, hs⟩ : ∃ s ∈ F.sets, s = F.ground := by
      obtain ⟨ s, hs ⟩ := hg;
      obtain ⟨ t, ht, hst ⟩ := F.mem_ground_iff s |>.1 hs; specialize h_sets t ht; aesop;
    -- Since F is nonempty and contains the entire ground set, it must have at least one set containing the entire ground set. Therefore, the frequency of any element in the ground set is at least half the number of sets in F.
    have h_freq : ∀ a ∈ F.ground, F.elemFreq a ≥ 1 := by
      exact fun a ha => Finset.card_pos.mpr ⟨ s, Finset.mem_filter.mpr ⟨ hs.1, hs.2.symm ▸ ha ⟩ ⟩;
    have h_card : F.sets.card ≤ 2 := by
      exact le_trans ( Finset.card_le_card ( show F.sets ⊆ { ∅, F.ground } by intros x hx; simpa using h_sets x hx ) ) ( Finset.card_insert_le _ _ ) |> le_trans <| by aesop;
    exact ⟨ Classical.choose hg, by linarith [ h_freq _ ( Classical.choose_spec hg ), F.elemFreq_le_card ( Classical.choose hg ) ] ⟩

/-
**Frankl's conjecture for ground sets of cardinality at most 3.**

This is the first nontrivial exact case of Frankl's conjecture.
When the ground has at most 3 elements, union-closure constrains the
family enough that some element must appear in at least half the sets.
-/
theorem frankl_ground_card_le_three (F : UnionClosedFamily α)
    (hg : F.ground.Nonempty)
    (h : F.ground.card ≤ 3) : F.HasFranklWitness := by
  interval_cases _ : #F.ground <;> simp_all +decide [ frankl_ground_card_le_two ];
  by_cases h : ∃ a ∈ F.ground, F.elemFreq a * 2 ≥ F.sets.card <;> simp_all +decide [ UnionClosedFamily.HasFranklWitness ];
  · exact ⟨ h.choose, by linarith [ h.choose_spec.2 ] ⟩;
  · -- Since every element in the ground set has frequency less than half the number of sets, the total incidence is less than $3 \times \frac{|F|}{2} = \frac{3|F|}{2}$.
    have h_total_incidence : F.totalIncidence < 3 * F.sets.card / 2 := by
      grind +suggestions;
    -- Since every nonempty set in F has at least 2 elements, the total incidence is at least 2 times the number of nonempty sets.
    have h_total_incidence_ge : F.totalIncidence ≥ 2 * (F.sets.card - (if ∅ ∈ F.sets then 1 else 0)) := by
      have h_total_incidence_ge : ∀ s ∈ F.sets, s ≠ ∅ → s.card ≥ 2 := by
        intro s hs hs_ne_empty
        by_contra h_contra
        have h_singleton : ∃ a, s = {a} := by
          exact Finset.card_eq_one.mp ( by linarith [ Finset.card_pos.mpr ( Finset.nonempty_of_ne_empty hs_ne_empty ) ] );
        obtain ⟨ a, rfl ⟩ := h_singleton;
        exact absurd ( h a ( by exact F.mem_ground_iff a |>.2 ⟨ _, hs, by simp +decide ⟩ ) ) ( by linarith [ frankl_of_singleton_in_sets F a hs ] );
      have h_total_incidence_ge : ∑ s ∈ F.sets, s.card ≥ ∑ s ∈ F.sets, if s = ∅ then 0 else 2 := by
        exact Finset.sum_le_sum fun s hs => by aesop;
      simp_all +decide [ Finset.sum_ite, Finset.filter_ne' ] ; ring_nf at * ; aesop;
    rcases k : F.sets.card with ( _ | _ | _ | k ) <;> simp_all +arith +decide [ Nat.mul_succ ];
    · obtain ⟨ s, hs ⟩ := F.sets.card_eq_one.mp k; simp_all +decide [ UnionClosedFamily.elemFreq ] ;
      simp_all +decide [ UnionClosedFamily.ground ];
      exact False.elim ( h _ ( Classical.choose_spec hg ) );
    · obtain ⟨ a, ha ⟩ := hg;
      exact ⟨ a, Finset.card_pos.mpr ⟨ Classical.choose ( F.mem_ground_iff a |>.1 ha ), Finset.mem_filter.mpr ⟨ Classical.choose_spec ( F.mem_ground_iff a |>.1 ha ) |>.1, Classical.choose_spec ( F.mem_ground_iff a |>.1 ha ) |>.2 ⟩ ⟩ ⟩;
    · split_ifs at h_total_incidence_ge <;> omega

end UnionClosedFamily