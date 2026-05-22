/-
# Frankl's Conjecture: Bounded Family Size Results

This file proves Frankl's conjecture for union-closed families
of bounded cardinality, using structural arguments about the
universe element and abundance counting.
-/
import Mathlib
import Speculative.Frankl.Defs

open Finset

/-! ## Structural lemma: elements in non-top sets have abundance ≥ 2 -/

/-
If s and M are distinct members of F both containing x, then
    x appears in at least 2 sets.
-/
theorem abundance_ge_two_of_nonempty_nontop {α : Type*} [DecidableEq α]
    (F : Finset (Finset α))
    (s : Finset α) (hs : s ∈ F)
    (M : Finset α) (hM : M ∈ F) (hne : s ≠ M)
    (x : α) (hx : x ∈ s) (hxM : x ∈ M) :
    2 ≤ (F.filter (x ∈ ·)).card := by
  exact Finset.one_lt_card.2 ⟨ s, by aesop, M, by aesop ⟩

/-! ## Coabundance -/

/-- The number of sets NOT containing x. -/
def coabundance {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) (x : α) : ℕ :=
  (F.filter (x ∉ ·)).card

/-- Abundance and coabundance partition the family. -/
theorem abundance_add_coabundance {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) (x : α) :
    abundance F x + coabundance F x = F.card := by
  unfold abundance coabundance
  rw [Finset.card_filter_add_card_filter_not]

/-- Frankl's property ↔ some element has coabundance ≤ half the family size. -/
theorem franklProperty_iff_coabundance {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) :
    FranklProperty F ↔ ∃ x, 2 * coabundance F x ≤ F.card := by
  constructor
  · rintro ⟨x, hx⟩
    exact ⟨x, by linarith [abundance_add_coabundance F x]⟩
  · rintro ⟨x, hx⟩
    exact ⟨x, by linarith [abundance_add_coabundance F x]⟩

/-! ## Union map lemma -/

/-
For any set s in a union-closed family F and any x ∈ s, the union map
    t ↦ s ∪ t sends sets not containing x to sets containing x.
    This is the key structural lemma for bounding abundance.
-/
theorem union_map_image_subset {α : Type*} [DecidableEq α]
    (F : Finset (Finset α))
    (hUC : UnionClosed F)
    (s : Finset α) (hs : s ∈ F) (x : α) (hx : x ∈ s) :
    (F.filter (x ∉ ·)).image (s ∪ ·) ⊆ F.filter (x ∈ ·) := by
  intro y hy; aesop

/-
The union map gives a lower bound: the number of sets containing x
    is at least the number of distinct unions s ∪ t for t not containing x.
-/
theorem abundance_ge_image_card {α : Type*} [DecidableEq α]
    (F : Finset (Finset α))
    (hUC : UnionClosed F)
    (s : Finset α) (hs : s ∈ F) (x : α) (hx : x ∈ s) :
    ((F.filter (x ∉ ·)).image (s ∪ ·)).card ≤ abundance F x := by
  convert Finset.card_le_card ( union_map_image_subset F hUC s hs x hx ) using 1

/-! ## Bounded family size: ≤ 4 -/

/-
Union-closed families with at most 4 sets and a nonempty member
    satisfy Frankl's property.
-/
theorem frankl_card_le_four {α : Type*} [DecidableEq α]
    (F : Finset (Finset α))
    (hUC : UnionClosed F)
    (hne : F.Nonempty)
    (hnonempty : ∃ s ∈ F, s.Nonempty)
    (hcard : F.card ≤ 4) :
    FranklProperty F := by
  -- Let M = familyUniverse F ∈ F (by unionClosed_contains_universe). From hnonempty, get s₀ ∈ F with s₀.Nonempty. Get x₀ ∈ s₀.
  obtain ⟨M, hM⟩ : ∃ M : Finset α, M = familyUniverse F ∧ M ∈ F := by
    exact ⟨ _, rfl, unionClosed_contains_universe F hUC hne ⟩
  obtain ⟨s₀, hs₀, hs₀_nonempty⟩ : ∃ s₀ ∈ F, s₀.Nonempty := hnonempty
  obtain ⟨x₀, hx₀⟩ : ∃ x₀, x₀ ∈ s₀ := by
    exact hs₀_nonempty;
  -- Case 1: s₀ ≠ M. Then x₀ ∈ s₀ and x₀ ∈ M (since s₀ ⊆ familyUniverse F = M by subset_familyUniverse). So abundance(x₀) ≥ 2 by abundance_ge_two_of_nonempty_nontop. Since F.card ≤ 4, 2*2 = 4 ≥ F.card.
  by_cases h_case1 : s₀ ≠ M;
  · have h_abundance_x₀ : 2 ≤ (F.filter (x₀ ∈ ·)).card := by
      apply abundance_ge_two_of_nonempty_nontop F s₀ hs₀ M hM.right h_case1 x₀ hx₀;
      exact hM.1.symm ▸ Finset.mem_biUnion.mpr ⟨ s₀, hs₀, hx₀ ⟩;
    exact ⟨ x₀, by linarith! ⟩;
  · -- If F.card ≤ 1, use frankl_card_one_of_nonempty_member.
    by_cases h_card1 : F.card ≤ 1;
    · exact frankl_card_one_of_nonempty_member F ( le_antisymm h_card1 ( Finset.card_pos.mpr hne ) ) ⟨ s₀, hs₀, hs₀_nonempty ⟩;
    · -- If all t ≠ M in F are empty: since F has no duplicates, F ⊆ {∅, M}, card ≤ 2, and any x ∈ M has abundance ≥ 1, 2*1 = 2 ≥ F.card.
      by_cases h_empty : ∀ t ∈ F, t = M ∨ t = ∅;
      · have h_card2 : F.card ≤ 2 := by
          exact le_trans ( Finset.card_le_card ( show F ⊆ { M, ∅ } by intros t ht; simpa using h_empty t ht ) ) ( Finset.card_insert_le _ _ );
        grind +suggestions;
      · -- If there exists t ∈ F with t ≠ M and t.Nonempty, pick y ∈ t. y ∈ t and y ∈ M, t ≠ M, abundance(y) ≥ 2, done.
        obtain ⟨t, ht, ht_ne_M, ht_nonempty⟩ : ∃ t ∈ F, t ≠ M ∧ t.Nonempty := by
          grind;
        obtain ⟨y, hy⟩ : ∃ y, y ∈ t := ht_nonempty
        have hy_in_M : y ∈ M := by
          exact hM.1.symm ▸ Finset.mem_biUnion.mpr ⟨ t, ht, hy ⟩
        have hy_abundance : 2 ≤ abundance F y := by
          apply abundance_ge_two_of_nonempty_nontop F t ht M hM.right ht_ne_M y hy hy_in_M
        use y
        linarith [abundance_le_card F y]