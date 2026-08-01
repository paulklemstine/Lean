import Mathlib

/-!
# Strongly complete sets: structural results and a counterexample

This file formalizes the basic notions from *Strongly complete sets and a conjecture
of Erdős*.  It then tests the tempting strengthening “every complete set is strongly
complete”.  The statement is false: the set consisting of all even natural numbers
together with `1` is complete, but deleting `1` leaves a parity obstruction.

We also prove that strong completeness is unchanged by a finite perturbation.  This
isolates the robustness built into the paper's definition.
-/

namespace StronglyCompleteSets

/-- `n` is a sum of distinct elements of `A`.  Distinctness is encoded by a finset. -/
def IsSubsetSum (A : Set ℕ) (n : ℕ) : Prop :=
  ∃ s : Finset ℕ, (s : Set ℕ) ⊆ A ∧ ∑ a ∈ s, a = n

/-- Every sufficiently large natural number is a sum of distinct elements of `A`. -/
def Complete (A : Set ℕ) : Prop :=
  ∃ N : ℕ, ∀ n ≥ N, IsSubsetSum A n

/-- Deleting an arbitrary finite set leaves a complete set. -/
def StronglyComplete (A : Set ℕ) : Prop :=
  ∀ F : Set ℕ, F.Finite → Complete (A \ F)

/-- Strong completeness implies ordinary completeness. -/
theorem stronglyComplete_complete {A : Set ℕ} (hA : StronglyComplete A) : Complete A := by
  have := hA ∅ (Set.finite_empty)
  simpa [Set.diff_empty] using this

/-- Deleting finitely many elements from a strongly complete set preserves strong
completeness. -/
theorem stronglyComplete_diff_finite {A F : Set ℕ} (hA : StronglyComplete A)
    (hF : F.Finite) : StronglyComplete (A \ F) := by
  intro G hG
  have : (A \ F) \ G = A \ (F ∪ G) := by ext x; simp [and_assoc, not_or]
  rw [this]
  exact hA (F ∪ G) (hF.union hG)

/-- Adding finitely many elements cannot create strong completeness: if `A ∪ F` is
strongly complete and `F` is finite, then `A` was strongly complete already. -/
theorem stronglyComplete_of_union_finite {A F : Set ℕ}
    (h : StronglyComplete (A ∪ F)) (hF : F.Finite) : StronglyComplete A := by
  intro G hG
  have key := h (G ∪ F) (hG.union hF)
  have eq : (A ∪ F) \ (G ∪ F) = A \ (G ∪ F) := by ext x; simp [Set.mem_union, Set.mem_diff]; tauto
  rw [eq] at key
  obtain ⟨N, hN⟩ := key
  refine ⟨N, fun n hn => ?_⟩
  have := hN n hn
  obtain ⟨s, hs_sub, hs_sum⟩ := this
  exact ⟨s, hs_sub.trans (Set.diff_subset_diff le_rfl (Set.subset_union_left)), hs_sum⟩

/-- Strong completeness is invariant under finite symmetric difference. -/
theorem stronglyComplete_congr_finite {A B : Set ℕ}
    (hAB : ((A \ B) ∪ (B \ A)).Finite) : StronglyComplete A ↔ StronglyComplete B := by
  have hFA : (A \ B).Finite := hAB.subset (Set.subset_union_left)
  have hFB : (B \ A).Finite := hAB.subset (Set.subset_union_right)
  constructor
  · intro hA G hG
    -- Need to show B \ G is complete
    -- C = (A ∩ B) \ G is complete (since A is SC, A \ (G ∪ (A \ B)) is complete)
    -- C ⊆ B \ G, so B \ G is complete
    have hC_A : Complete ((A ∩ B) \ G) := by
      have : (A ∩ B) \ G = A \ (G ∪ (A \ B)) := by ext x; simp [Set.mem_inter_iff, Set.mem_diff]; tauto
      rw [this]
      exact hA (G ∪ (A \ B)) (hG.union hFA)
    -- C ⊆ B \ G
    have hsup : (A ∩ B) \ G ⊆ B \ G := by
      intro x hx
      simp only [Set.mem_diff, Set.mem_inter_iff] at hx ⊢
      exact ⟨hx.1.2, hx.2⟩
    -- Complete sets are preserved under superset
    obtain ⟨N, hN⟩ := hC_A
    exact ⟨N, fun n hn => by
      obtain ⟨s, hs, hs_sum⟩ := hN n hn
      exact ⟨s, hs.trans hsup, hs_sum⟩⟩
  · intro hB G hG
    -- Need to show A \ G is complete
    -- C = (A ∩ B) \ G is complete (since B is SC, B \ (G ∪ (B \ A)) is complete)
    -- C ⊆ A \ G, so A \ G is complete
    have hC_B : Complete ((A ∩ B) \ G) := by
      have : (A ∩ B) \ G = B \ (G ∪ (B \ A)) := by ext x; simp [Set.mem_inter_iff, Set.mem_diff]; tauto
      rw [this]
      exact hB (G ∪ (B \ A)) (hG.union hFB)
    -- C ⊆ A \ G
    have hsup : (A ∩ B) \ G ⊆ A \ G := by
      intro x hx
      simp only [Set.mem_diff, Set.mem_inter_iff] at hx ⊢
      exact ⟨hx.1.1, hx.2⟩
    -- Complete sets are preserved under superset
    obtain ⟨N, hN⟩ := hC_B
    refine ⟨N, ?_⟩
    intro n hn
    obtain ⟨s, hs, hs_sum⟩ := hN n hn
    exact ⟨s, hs.trans hsup, hs_sum⟩

/-- A concrete complete set with one indispensable odd element. -/
def evenWithOne : Set ℕ := {n | Even n} ∪ {1}

/-- `evenWithOne` is complete: an even number represents itself, while an odd number
at least three is `1 + (n-1)`. -/
theorem evenWithOne_complete : Complete evenWithOne := by
  use 0
  intro n _hn
  -- Case analysis: either n is even or n is odd
  by_cases heven : Even n
  · -- n is even: use singleton {n} (or empty set if n = 0)
    refine ⟨{n}, ?_, ?_⟩
    · simp [evenWithOne]; right; exact heven
    · simp
  · -- n is odd: use {1, n-1} where n-1 is even
    have hn_pos : n ≥ 1 := Nat.pos_of_ne_zero (fun h => heven (h.symm ▸ by decide))
    have hn1_even : Even (n - 1) := by
      rw [Nat.even_sub hn_pos]
      simp [heven]
    have hne : 1 ≠ n - 1 := by
      intro h
      have : n = 2 := by omega
      exact heven (this ▸ even_two)
    refine ⟨{1, n - 1}, ?_, ?_⟩
    · intro x hx
      rw [evenWithOne]
      simp only [Set.mem_union, Set.mem_setOf_eq, Set.mem_singleton_iff] at hx ⊢
      simp only [Finset.mem_coe, Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with rfl | rfl
      · right; rfl
      · left; exact hn1_even
    · rw [Finset.sum_pair hne]; simp [hn_pos]

/-- **Counterexample to a tempting conjecture:** completeness does not imply strong
completeness.  Deleting `1` from `evenWithOne` leaves only even summands. -/
theorem complete_not_stronglyComplete :
    Complete evenWithOne ∧ ¬ StronglyComplete evenWithOne := by
  refine ⟨evenWithOne_complete, ?_⟩
  intro h
  -- If evenWithOne were strongly complete, then evenWithOne \ {1} would be complete
  have h1 : Complete (evenWithOne \ {1}) := h {1} (Set.finite_singleton 1)
  -- But evenWithOne \ {1} contains only even numbers
  -- Any sum of even numbers is even, so no odd number can be represented
  obtain ⟨N, hN⟩ := h1
  -- Find an odd number >= N
  let m := 2 * N + 1
  have hm_odd : Odd m := ⟨N, rfl⟩
  have hm_ge : m ≥ N := by omega
  have hm3 : IsSubsetSum (evenWithOne \ {1}) m := hN m hm_ge
  obtain ⟨s, hs_sub, hs_sum⟩ := hm3
  -- Every element in s is even
  have hall_even : ∀ a ∈ s, Even a := by
    intro a ha
    have hmem : a ∈ evenWithOne \ {1} := hs_sub ha
    rw [Set.mem_diff] at hmem
    rcases hmem with ⟨hmem1, hmem2⟩
    simp [evenWithOne] at hmem1
    tauto
  -- Sum of even numbers is even
  have hsum_even : Even (∑ a ∈ s, a) := by
    apply Finset.even_sum
    exact hall_even
  rw [hs_sum] at hsum_even
  exact Nat.not_even_iff_odd.mpr hm_odd hsum_even

end StronglyCompleteSets