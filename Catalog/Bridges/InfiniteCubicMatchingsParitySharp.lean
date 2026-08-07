/-
# Sharpness of the parity lemma in the infinite setting

The parity lemma `PerfectMatching.card_inter_cutEdges_odd` says that a perfect matching meets
every edge cut of odd size **with a finite side** in an odd number of edges.  In finite graphs
the finiteness assumption is vacuous.  Here we prove that in infinite graphs it cannot be
dropped: the infinite ladder has an edge cut of size `3` (odd), both sides of which are
infinite, that is *disjoint* from a perfect matching.

This is the fundamental new phenomenon of the infinite theory: parity arguments are only
available for cuts with a finite side, which is why `IsOddCut` is defined via a `Finset`.
-/
import Bridges.InfiniteCubicMatchingsLadder

namespace Bridges.InfiniteCubicMatchings

namespace Ladder

/-- The vertex set consisting of all columns `≤ 0` together with the single extra vertex
`(1, false)`.  Both this set and its complement are infinite, and its edge cut has three
edges. -/
def leftPlus : Set (ℤ × Bool) := {p | p.1 ≤ 0 ∨ p = (1, false)}

/-- The partner map of the "shifted rails" matching: bottom vertices use the rails leaving
even columns, top vertices use the rails leaving odd columns. -/
def shiftedPartner : ℤ × Bool → ℤ × Bool
  | (n, false) => if n % 2 = 0 then (n + 1, false) else (n - 1, false)
  | (n, true) => if n % 2 = 0 then (n - 1, true) else (n + 1, true)

/-- The perfect matching of the ladder using the "even" rails on the bottom rail and the
"odd" rails on the top rail. -/
def shifted : PerfectMatching ladder where
  partner := shiftedPartner
  isAdj p := by
    obtain ⟨n, b⟩ := p
    cases b
    · by_cases h : n % 2 = 0
      · simp only [shiftedPartner, if_pos h]
        exact adj_rail n false
      · simp only [shiftedPartner, if_neg h]
        simpa using (adj_rail (n - 1) false).symm
    · by_cases h : n % 2 = 0
      · simp only [shiftedPartner, if_pos h]
        simpa using (adj_rail (n - 1) true).symm
      · simp only [shiftedPartner, if_neg h]
        exact adj_rail n true
  invol p := by
    obtain ⟨n, b⟩ := p
    cases b
    · by_cases h : n % 2 = 0
      · simp only [shiftedPartner, if_pos h]
        rw [if_neg (show ¬ ((n + 1) % 2 = 0) by omega)]
        simp
      · simp only [shiftedPartner, if_neg h]
        rw [if_pos (show (n - 1) % 2 = 0 by omega)]
        simp
    · by_cases h : n % 2 = 0
      · simp only [shiftedPartner, if_pos h]
        rw [if_neg (show ¬ ((n - 1) % 2 = 0) by omega)]
        simp
      · simp only [shiftedPartner, if_neg h]
        rw [if_pos (show (n + 1) % 2 = 0 by omega)]
        simp

/-- The three edges of the cut of `leftPlus`. -/
theorem cutEdgesSet_leftPlus :
    cutEdgesSet ladder leftPlus =
      {s(((0 : ℤ), true), ((1 : ℤ), true)), s(((1 : ℤ), false), ((1 : ℤ), true)),
        s(((1 : ℤ), false), ((2 : ℤ), false))} := by
  ext e
  constructor
  · rintro ⟨hE, ⟨n, b⟩, ⟨m, c⟩, rfl, hu, hw⟩
    have hadj : ladder.Adj ((n, b) : ℤ × Bool) ((m, c) : ℤ × Bool) := by simpa using hE
    simp only [leftPlus, Set.mem_setOf_eq, Prod.mk.injEq, not_or, not_and] at hu hw
    obtain ⟨hw1, hw2⟩ := hw
    have hm1 : 1 ≤ m := by omega
    rcases hu with hn | hn
    · -- the `n ≤ 0` side
      rcases hadj with ⟨h1, h2⟩ | ⟨h1, h2⟩
      · simp only at h1
        omega
      · simp only at h1 h2
        rcases h2 with h2 | h2
        · have hm : m = 1 := by omega
          have hn0 : n = 0 := by omega
          subst hm; subst hn0
          have hc : c = true := by
            cases c
            · exact absurd rfl (hw2 rfl)
            · rfl
          subst hc
          simp [h1]
        · omega
    · -- the extra vertex `(1, false)`
      obtain ⟨hn1, hb⟩ := hn
      subst hn1; subst hb
      rcases hadj with ⟨h1, h2⟩ | ⟨h1, h2⟩
      · simp only at h1 h2
        subst h1
        have hc : c = true := by
          cases c
          · exact absurd rfl h2
          · rfl
        subst hc
        simp
      · simp only at h1 h2
        subst h1
        rcases h2 with h2 | h2
        · subst h2
          simp
        · omega
  · intro he
    have h0 : ¬ ((1 : ℤ), true) ∈ leftPlus := by simp [leftPlus]
    have h2 : ¬ ((2 : ℤ), false) ∈ leftPlus := by simp [leftPlus]
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at he
    rcases he with rfl | rfl | rfl
    · exact ⟨by simpa using adj_rail (0 : ℤ) true, (0, true), (1, true), rfl,
        by simp [leftPlus], h0⟩
    · exact ⟨by simpa using adj_rung (1 : ℤ) false, (1, false), (1, true), rfl,
        by simp [leftPlus], h0⟩
    · exact ⟨by simpa using adj_rail (1 : ℤ) false, (1, false), (2, false), rfl,
        by simp [leftPlus], h2⟩

theorem ncard_cutEdgesSet_leftPlus : (cutEdgesSet ladder leftPlus).ncard = 3 := by
  rw [cutEdgesSet_leftPlus]
  rw [Set.ncard_insert_of_notMem (by simp) (Set.toFinite _),
    Set.ncard_pair (by simp)]

theorem shifted_disjoint_cut : shifted.edges ∩ cutEdgesSet ladder leftPlus = ∅ := by
  rw [cutEdgesSet_leftPlus, Set.eq_empty_iff_forall_notMem]
  rintro e ⟨hM, he⟩
  simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at he
  rcases he with rfl | rfl | rfl <;>
    rw [PerfectMatching.mem_edges] at hM <;> revert hM <;>
      simp only [shifted, shiftedPartner] <;> norm_num

theorem leftPlus_infinite : leftPlus.Infinite := by
  apply Set.infinite_of_injective_forall_mem (f := fun n : ℕ => ((-(n : ℤ), false)))
  · intro a b hab
    simp only [Prod.mk.injEq, neg_inj, Nat.cast_inj] at hab
    exact hab.1
  · intro n
    simp only [leftPlus, Set.mem_setOf_eq]
    left
    simp

theorem leftPlus_compl_infinite : leftPlusᶜ.Infinite := by
  apply Set.infinite_of_injective_forall_mem (f := fun n : ℕ => (((n : ℤ) + 1, true)))
  · intro a b hab
    simp only [Prod.mk.injEq, add_left_inj, Nat.cast_inj] at hab
    exact hab.1
  · intro n
    simp only [leftPlus, Set.mem_compl_iff, Set.mem_setOf_eq, not_or, Prod.mk.injEq]
    constructor
    · simp only [not_le]
      positivity
    · simp

/-- **Sharpness of the parity lemma.**  There is an infinite cubic bridgeless graph with an
edge cut of odd size whose two sides are both infinite and which is disjoint from a perfect
matching.  Consequently the parity lemma
`PerfectMatching.card_inter_cutEdges_odd` genuinely requires a *finite* side. -/
theorem parity_fails_for_cuts_with_two_infinite_sides :
    ∃ (S : Set (ℤ × Bool)) (M : PerfectMatching ladder),
      S.Infinite ∧ Sᶜ.Infinite ∧ Odd (cutEdgesSet ladder S).ncard ∧
        M.edges ∩ cutEdgesSet ladder S = ∅ :=
  ⟨leftPlus, shifted, leftPlus_infinite, leftPlus_compl_infinite,
    by rw [ncard_cutEdgesSet_leftPlus]; exact ⟨1, rfl⟩, shifted_disjoint_cut⟩

end Ladder

end Bridges.InfiniteCubicMatchings