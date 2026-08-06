/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license.

# Exact candidate counts: the combinatorial baseline for reuse

The composition conjecture rests on a combinatorial claim: *independent*
candidate populations multiply.  This file proves that claim exactly, for the
population of usable sub-libraries -- the dependency-closed subsets of a
library.

* `closedSubsets_mul_of_split` : if a library splits into two parts with no
  dependencies across the split, the number of usable sub-libraries is the
  **product** of the two counts (a bijection, not an estimate);
* `card_closedSubsets_independent` : `n` mutually independent declarations admit
  exactly `2 ^ n` usable sub-libraries -- the exact exponential baseline;
* `card_closedSubsets_chain` : a maximally dependent library (a chain) admits
  exactly `n + 1`;
* `chain_lt_independent` : hence dependency density strictly collapses the
  candidate population as soon as `n ≥ 2`, quantifying the trade-off behind the
  multiplicative-reuse phase transition.
-/

import Catalog.Pythagorean.TheoryFitness.Core

namespace TheoryFitness

open Finset

/-- The usable sub-libraries of `U`: subsets closed under direct
dependencies. -/
def closedSubsets (deps : ℕ → Finset ℕ) (U : Finset ℕ) : Finset (Finset ℕ) :=
  U.powerset.filter (fun s => ∀ i ∈ s, deps i ⊆ s)

theorem mem_closedSubsets {deps : ℕ → Finset ℕ} {U s : Finset ℕ} :
    s ∈ closedSubsets deps U ↔ s ⊆ U ∧ DepClosed deps s := by
  simp [closedSubsets, DepClosed, mem_filter, mem_powerset]

/-! ## Independent parts multiply -/

/-- **Exact multiplicativity.**  When a library splits into two parts with no
dependency crossing the split, the usable sub-libraries of the whole are exactly
the pairs of usable sub-libraries of the parts. -/
theorem closedSubsets_mul_of_split (deps : ℕ → Finset ℕ) (A B : Finset ℕ)
    (hAB : Disjoint A B) (hA : ∀ i ∈ A, deps i ⊆ A) (hB : ∀ i ∈ B, deps i ⊆ B) :
    (closedSubsets deps (A ∪ B)).card
      = (closedSubsets deps A).card * (closedSubsets deps B).card := by
  rw [← card_product]
  apply Finset.card_bij' (i := fun s _ => (s ∩ A, s ∩ B))
    (j := fun p _ => p.1 ∪ p.2)
  · -- the projection lands in the product
    intro s hs
    rw [mem_closedSubsets] at hs
    obtain ⟨hsub, hcl⟩ := hs
    rw [mem_product]
    constructor
    · rw [mem_closedSubsets]
      refine ⟨inter_subset_right, ?_⟩
      intro i hi
      rw [mem_inter] at hi
      exact subset_inter (hcl i hi.1) (hA i hi.2)
    · rw [mem_closedSubsets]
      refine ⟨inter_subset_right, ?_⟩
      intro i hi
      rw [mem_inter] at hi
      exact subset_inter (hcl i hi.1) (hB i hi.2)
  · -- the union of two usable parts is usable
    intro p hp
    rw [mem_product, mem_closedSubsets, mem_closedSubsets] at hp
    obtain ⟨⟨h1sub, h1cl⟩, ⟨h2sub, h2cl⟩⟩ := hp
    rw [mem_closedSubsets]
    exact ⟨union_subset_union h1sub h2sub, depClosed_union deps h1cl h2cl⟩
  · -- left inverse
    intro s hs
    rw [mem_closedSubsets] at hs
    rw [← inter_union_distrib_left, inter_eq_left.2 hs.1]
  · -- right inverse
    intro p hp
    rw [mem_product, mem_closedSubsets, mem_closedSubsets] at hp
    obtain ⟨⟨h1sub, -⟩, ⟨h2sub, -⟩⟩ := hp
    have hp2A : p.2 ∩ A = ∅ := by
      rw [← subset_empty]
      intro x hx
      rw [mem_inter] at hx
      exact absurd (mem_inter.2 ⟨hx.2, h2sub hx.1⟩)
        (by simpa using (disjoint_left.1 hAB (hx.2)) (h2sub hx.1))
    have hp1B : p.1 ∩ B = ∅ := by
      rw [← subset_empty]
      intro x hx
      rw [mem_inter] at hx
      exact absurd hx.2 (disjoint_left.1 hAB (h1sub hx.1))
    have e1 : (p.1 ∪ p.2) ∩ A = p.1 := by
      rw [union_inter_distrib_right, hp2A, union_empty, inter_eq_left.2 h1sub]
    have e2 : (p.1 ∪ p.2) ∩ B = p.2 := by
      rw [union_inter_distrib_right, hp1B, empty_union, inter_eq_left.2 h2sub]
    rw [e1, e2]

/-! ## The exact exponential baseline -/

/-- Mutually independent declarations: no dependencies at all. -/
def noDeps : ℕ → Finset ℕ := fun _ => ∅

/-- **Exact exponential count.**  A library of `n` mutually independent
declarations has exactly `2 ^ n` usable sub-libraries. -/
theorem card_closedSubsets_independent (U : Finset ℕ) :
    (closedSubsets noDeps U).card = 2 ^ U.card := by
  have : closedSubsets noDeps U = U.powerset := by
    apply filter_true_of_mem
    intro s _ i _
    simp [noDeps]
  rw [this, card_powerset]

/-! ## The maximally dependent baseline: a chain -/

/-- A chain library: declaration `i` depends on declaration `i - 1`. -/
def chainDeps : ℕ → Finset ℕ := fun i => if i = 0 then ∅ else {i - 1}

theorem chainDeps_closed_range (n : ℕ) : DepClosed chainDeps (range n) := by
  intro i hi
  rw [mem_range] at hi
  intro j hj
  simp only [chainDeps] at hj
  by_cases h : i = 0
  · simp [h] at hj
  · simp only [h, if_false, mem_singleton] at hj
    rw [mem_range]
    omega

/-- Dependency-closed subsets of a chain are downward closed. -/
theorem chain_downward {s : Finset ℕ} (hcl : DepClosed chainDeps s) :
    ∀ d i, i ∈ s → i - d ∈ s := by
  intro d
  induction d with
  | zero => intro i hi; simpa using hi
  | succ d ih =>
      intro i hi
      have h := ih i hi
      by_cases h0 : i - d = 0
      · have : i - (d + 1) = 0 := by omega
        rw [this, ← h0]
        exact h
      · have hmem : (i - d) - 1 ∈ s := by
          have := hcl (i - d) h
          simp only [chainDeps, h0, if_false] at this
          exact this (mem_singleton_self _)
        have : i - (d + 1) = (i - d) - 1 := by omega
        rw [this]
        exact hmem

/-- A dependency-closed subset of a chain is an initial segment. -/
theorem chain_closed_eq_range {s : Finset ℕ} (hcl : DepClosed chainDeps s) :
    ∃ k, s = range k := by
  rcases s.eq_empty_or_nonempty with rfl | hne
  · exact ⟨0, by simp⟩
  · refine ⟨s.max' hne + 1, ?_⟩
    apply Subset.antisymm
    · intro i hi
      rw [mem_range]
      exact Nat.lt_succ_of_le (le_max' s i hi)
    · intro j hj
      rw [mem_range] at hj
      have hle : j ≤ s.max' hne := by omega
      have := chain_downward hcl (s.max' hne - j) (s.max' hne) (max'_mem s hne)
      have heq : s.max' hne - (s.max' hne - j) = j := by omega
      rwa [heq] at this

/-- **Exact linear count.**  A maximally dependent library of `n` declarations
has exactly `n + 1` usable sub-libraries. -/
theorem card_closedSubsets_chain (n : ℕ) :
    (closedSubsets chainDeps (range n)).card = n + 1 := by
  have hset : closedSubsets chainDeps (range n) = (range (n + 1)).image range := by
    apply Subset.antisymm
    · intro s hs
      rw [mem_closedSubsets] at hs
      obtain ⟨hsub, hcl⟩ := hs
      obtain ⟨k, rfl⟩ := chain_closed_eq_range hcl
      have hkn : k ≤ n := by
        by_contra hk
        push_neg at hk
        have : n ∈ range k := mem_range.2 hk
        have := hsub this
        rw [mem_range] at this
        omega
      exact mem_image.2 ⟨k, mem_range.2 (by omega), rfl⟩
    · intro s hs
      obtain ⟨k, hk, rfl⟩ := mem_image.1 hs
      rw [mem_range] at hk
      rw [mem_closedSubsets]
      refine ⟨?_, chainDeps_closed_range k⟩
      intro i hi
      rw [mem_range] at hi ⊢
      omega
  have hinj : Function.Injective (range : ℕ → Finset ℕ) := by
    intro a b h
    have := congrArg card h
    simpa using this
  rw [hset, card_image_of_injective _ hinj, card_range]

/-- **Dependency density collapses the candidate population.**  From two
declarations on, the maximally dependent library has strictly fewer usable
sub-libraries than the independent one; the gap is exponential. -/
theorem chain_lt_independent (n : ℕ) (hn : 2 ≤ n) :
    (closedSubsets chainDeps (range n)).card
      < (closedSubsets noDeps (range n)).card := by
  rw [card_closedSubsets_chain, card_closedSubsets_independent, card_range]
  induction n with
  | zero => omega
  | succ m ih =>
      rcases Nat.lt_or_ge m 2 with hm | hm
      · interval_cases m
        · omega
        · norm_num
      · have := ih (by omega)
        have h2 : 2 ^ m + 2 ^ m = 2 ^ (m + 1) := by ring
        omega

end TheoryFitness