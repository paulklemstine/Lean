/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Extracting a distinct-sums pair from two large sets

The union-bound argument of `Counting.lean` needs sumsets that are *as large as
possible*: from a pair `(A, B)` of large sets we want to extract subsets
`A' ⊆ A`, `B' ⊆ B` of a prescribed size `l` whose `l²` pairwise sums are all
distinct, so that `|A' + B'| = l²`.

The classical greedy argument does this as soon as `|A|, |B| ≥ l³ + l`: fix any
`l`-subset `A' ⊆ A`; then build `B'` one element at a time, at each step
avoiding the at most `l · l² ` "collision" values `a₂ + b₂ - a₁`
(`a₁, a₂ ∈ A'`, `b₂` already chosen) together with the ≤ `l` already chosen
elements.

## Main results

* `exists_distinctSums_snd_of_card` — greedy construction of `B'` for a fixed set
  `A'` of arbitrary size `u` (this general form is what the three-summand
  extraction of `Triple.lean` needs);
* `exists_distinctSums_snd` — the case `u = l` used for two summands;
* `exists_distinctSums_pair` — the two-sided extraction statement;
* `avoidsSumsets_of_no_distinctSums` — the reduction used later: if `S` contains
  no sumset `A' + B'` coming from a distinct-sums pair of `l`-sets, then `S`
  avoids **all** `k`-sumsets for `k = l³ + l`.
-/
import Bridges.DenseSumsetFree.Basic

open Finset Pointwise

namespace DenseSumsetFree

/-- **Greedy extraction, one-sided, general form.** If `A'` has `u` elements and
`B` has at least `u²·l + l` elements, then `B` contains an `l`-element subset `B'`
such that all `u·l` sums `a + b` (`a ∈ A'`, `b ∈ B'`) are distinct. -/
theorem exists_distinctSums_snd_of_card (A' B : Finset ℕ) (u l : ℕ)
    (hA' : A'.card = u) (hB : u * u * l + l ≤ B.card) :
    ∃ B' ⊆ B, B'.card = l ∧ DistinctSums A' B' := by
  classical
  suffices h : ∀ i ≤ l, ∃ B' ⊆ B, B'.card = i ∧ DistinctSums A' B' from h l le_rfl
  intro i
  induction i with
  | zero =>
    intro _
    exact ⟨∅, Finset.empty_subset _, rfl, by simp [DistinctSums]⟩
  | succ i ih =>
    intro hi
    obtain ⟨B', hB'sub, hB'card, hB'dist⟩ := ih (Nat.le_of_succ_le hi)
    -- the values that must be avoided when adding one more element
    set bad : Finset ℕ :=
      B' ∪ ((A' ×ˢ (A' ×ˢ B')).image (fun t : ℕ × ℕ × ℕ => t.2.1 + t.2.2 - t.1)) with hbad
    have hcard_bad : bad.card < B.card := by
      have h1 : bad.card ≤ B'.card +
          ((A' ×ˢ (A' ×ˢ B')).image (fun t : ℕ × ℕ × ℕ => t.2.1 + t.2.2 - t.1)).card :=
        Finset.card_union_le _ _
      have h2 : ((A' ×ˢ (A' ×ˢ B')).image
          (fun t : ℕ × ℕ × ℕ => t.2.1 + t.2.2 - t.1)).card ≤ u * (u * i) := by
        refine le_trans (Finset.card_image_le) ?_
        simp [Finset.card_product, hA', hB'card]
      have hil : i < l := hi
      have key : B'.card + u * (u * i) < u * u * l + l :=
        calc B'.card + u * (u * i) = (1 + u * u) * i := by rw [hB'card]; ring
          _ < (1 + u * u) * (i + 1) :=
              Nat.mul_lt_mul_of_pos_left (Nat.lt_succ_self i) (by omega)
          _ ≤ (1 + u * u) * l := Nat.mul_le_mul_left _ hil
          _ = u * u * l + l := by ring
      omega
    have hne : (B \ bad).Nonempty := by
      rw [← Finset.card_pos]
      have := Finset.le_card_sdiff bad B
      omega
    obtain ⟨b, hb⟩ := hne
    rw [Finset.mem_sdiff] at hb
    obtain ⟨hbB, hbbad⟩ := hb
    have hbB' : b ∉ B' := fun h => hbbad (Finset.mem_union_left _ h)
    have hbimg : ∀ a₁ ∈ A', ∀ a₂ ∈ A', ∀ b₂ ∈ B', a₁ + b ≠ a₂ + b₂ := by
      intro a₁ ha₁ a₂ ha₂ b₂ hb₂ heq
      refine hbbad (Finset.mem_union_right _ ?_)
      refine Finset.mem_image.2 ⟨(a₁, a₂, b₂), ?_, by dsimp only; omega⟩
      simp [Finset.mem_product, ha₁, ha₂, hb₂]
    refine ⟨insert b B', Finset.insert_subset hbB hB'sub, ?_, ?_⟩
    · rw [Finset.card_insert_of_notMem hbB', hB'card]
    · intro a₁ ha₁ b₁ hb₁ a₂ ha₂ b₂ hb₂ heq
      rcases Finset.mem_insert.1 hb₁ with rfl | hb₁' <;>
        rcases Finset.mem_insert.1 hb₂ with rfl | hb₂'
      · exact ⟨by omega, rfl⟩
      · exact absurd heq (hbimg a₁ ha₁ a₂ ha₂ b₂ hb₂')
      · exact absurd heq.symm (hbimg a₂ ha₂ a₁ ha₁ b₁ hb₁')
      · exact hB'dist a₁ ha₁ b₁ hb₁' a₂ ha₂ b₂ hb₂' heq

/-- **Greedy extraction, one-sided.** If `A'` has `l` elements and `B` has at
least `l³ + l` elements, then `B` contains an `l`-element subset `B'` such that
all `l²` sums `a + b` (`a ∈ A'`, `b ∈ B'`) are distinct. -/
theorem exists_distinctSums_snd (A' B : Finset ℕ) (l : ℕ)
    (hA' : A'.card = l) (hB : l ^ 3 + l ≤ B.card) :
    ∃ B' ⊆ B, B'.card = l ∧ DistinctSums A' B' :=
  exists_distinctSums_snd_of_card A' B l l hA' (by rw [show l * l * l = l ^ 3 by ring]; exact hB)

/-- **Greedy extraction, two-sided.** Any two sets of size at least `l³ + l`
contain `l`-element subsets whose `l²` pairwise sums are all distinct. -/
theorem exists_distinctSums_pair (A B : Finset ℕ) (l : ℕ)
    (hA : l ^ 3 + l ≤ A.card) (hB : l ^ 3 + l ≤ B.card) :
    ∃ A' ⊆ A, ∃ B' ⊆ B, A'.card = l ∧ B'.card = l ∧ DistinctSums A' B' := by
  obtain ⟨A', hA'sub, hA'card⟩ :=
    Finset.exists_subset_card_eq (le_trans (by omega) hA : l ≤ A.card)
  obtain ⟨B', hB'sub, hB'card, hdist⟩ := exists_distinctSums_snd A' B l hA'card hB
  exact ⟨A', hA'sub, B', hB'sub, hA'card, hB'card, hdist⟩

/-- **Reduction to distinct-sums pairs.** If a set `S` contains no sumset
`A' + B'` arising from a distinct-sums pair of `l`-element sets, then `S` avoids
all `k`-sumsets with `k = l³ + l`. -/
theorem avoidsSumsets_of_no_distinctSums {S : Finset ℕ} {l : ℕ}
    (h : ∀ A' B' : Finset ℕ, A'.card = l → B'.card = l → DistinctSums A' B' →
      ¬ A' + B' ⊆ S) :
    AvoidsSumsets S (l ^ 3 + l) := by
  intro A B hA hB hsub
  obtain ⟨A', hA'sub, B', hB'sub, hA'card, hB'card, hdist⟩ :=
    exists_distinctSums_pair A B l hA hB
  exact h A' B' hA'card hB'card hdist
    (Finset.Subset.trans (add_subset_add hA'sub hB'sub) hsub)

end DenseSumsetFree