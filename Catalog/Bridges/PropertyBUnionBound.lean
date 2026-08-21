/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Bridge: hypergraph 2-colourability (property B) by the same counting engine

Erdős (1963): every `k`-uniform hypergraph with fewer than `2^{k-1}` edges is 2-colourable.
The textbook proof colours the vertices at random; the proof here is the *same* argument with
the probability replaced by cardinalities of `Finset`s — and, crucially, it reuses verbatim the
two counting lemmas `card_filter_superset` and `card_filter_disjoint` proved for the Ramsey
bound in `Bridges/ErdosProbabilisticRamsey.lean`.  That reuse is the point: the "probabilistic
method" here is one single counting engine applied to two different extremal problems.

## Main results

* `card_bad_colourings_le` : union bound — at most `#H · 2 · 2 ^ (card V - k)` colourings make
  some edge monochromatic.
* `exists_proper_two_colouring` : if `#H < 2 ^ (k-1)` then a proper 2-colouring exists.
* `property_B_sharp_example` : the bound is not vacuous and is attained in spirit — for `k = 1`
  the hypothesis `#H < 1` is exactly what is needed, since a single singleton edge is
  monochromatic under every colouring.

## Catalog connections
* `Bridges/ErdosProbabilisticRamsey.lean` : source of the counting lemmas used here.
-/
import Mathlib
import Bridges.ErdosProbabilisticRamsey

open Finset

namespace PropertyBUnionBound

open ErdosProbabilisticRamsey (card_filter_superset card_filter_disjoint)

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- A colouring `S ⊆ V` (the "red" vertices) makes the edge `E` monochromatic when `E` is
entirely red or entirely blue. -/
def MonoEdge (S E : Finset V) : Prop := E ⊆ S ∨ Disjoint S E

instance (S E : Finset V) : Decidable (MonoEdge S E) := by unfold MonoEdge; infer_instance

/-- The colourings that make some edge of `H` monochromatic. -/
def badColourings (H : Finset (Finset V)) : Finset (Finset V) :=
  (univ : Finset V).powerset.filter (fun S => ∃ E ∈ H, MonoEdge S E)

/-- **Union bound.**  At most `#H · (2 · 2 ^ (card V - k))` colourings make some `k`-element edge
monochromatic. -/
theorem card_bad_colourings_le (H : Finset (Finset V)) (k : ℕ) (hk : ∀ E ∈ H, #E = k) :
    #(badColourings H) ≤ #H * (2 * 2 ^ (Fintype.card V - k)) := by
  classical
  have hsub : badColourings H ⊆ H.biUnion
      (fun E => (univ : Finset V).powerset.filter (fun S => MonoEdge S E)) := by
    intro S hS
    simp only [badColourings, mem_filter, mem_powerset] at hS
    obtain ⟨E, hE, hmono⟩ := hS.2
    exact mem_biUnion.2 ⟨E, hE, by simp only [mem_filter, mem_powerset]; exact ⟨hS.1, hmono⟩⟩
  have hone : ∀ E ∈ H, #((univ : Finset V).powerset.filter (fun S => MonoEdge S E)) ≤
      2 * 2 ^ (Fintype.card V - k) := by
    intro E hE
    have hEsub : E ⊆ (univ : Finset V) := subset_univ E
    have hsplit : (univ : Finset V).powerset.filter (fun S => MonoEdge S E) ⊆
        (univ : Finset V).powerset.filter (fun S => E ⊆ S) ∪
          (univ : Finset V).powerset.filter (fun S => Disjoint S E) := by
      intro S hS
      simp only [mem_filter, mem_powerset, MonoEdge] at hS
      rcases hS.2 with h | h
      · exact mem_union_left _ (by simp only [mem_filter, mem_powerset]; exact ⟨hS.1, h⟩)
      · exact mem_union_right _ (by simp only [mem_filter, mem_powerset]; exact ⟨hS.1, h⟩)
    calc #((univ : Finset V).powerset.filter (fun S => MonoEdge S E)) ≤ _ := card_le_card hsplit
      _ ≤ #((univ : Finset V).powerset.filter (fun S => E ⊆ S)) +
          #((univ : Finset V).powerset.filter (fun S => Disjoint S E)) := card_union_le _ _
      _ = 2 * 2 ^ (Fintype.card V - k) := by
          rw [card_filter_superset _ _ hEsub, card_filter_disjoint _ _ hEsub, card_univ, hk E hE]
          ring
  calc #(badColourings H) ≤ #(H.biUnion
        (fun E => (univ : Finset V).powerset.filter (fun S => MonoEdge S E))) := card_le_card hsub
    _ ≤ ∑ E ∈ H, #((univ : Finset V).powerset.filter (fun S => MonoEdge S E)) := card_biUnion_le
    _ ≤ ∑ _E ∈ H, 2 * 2 ^ (Fintype.card V - k) := sum_le_sum hone
    _ = #H * (2 * 2 ^ (Fintype.card V - k)) := by rw [sum_const, smul_eq_mul]

/-- **Erdős' property B theorem.**  A `k`-uniform hypergraph with fewer than `2 ^ (k-1)` edges
admits a 2-colouring of its vertices with no monochromatic edge. -/
theorem exists_proper_two_colouring (H : Finset (Finset V)) (k : ℕ)
    (hk : ∀ E ∈ H, #E = k) (hcard : #H < 2 ^ (k - 1)) :
    ∃ S : Finset V, ∀ E ∈ H, ¬ MonoEdge S E := by
  classical
  rcases H.eq_empty_or_nonempty with hH | ⟨E₀, hE₀⟩
  · exact ⟨∅, by simp [hH]⟩
  · -- a nonempty hypergraph forces `1 ≤ k ≤ card V`
    have hkle : k ≤ Fintype.card V := by
      have : #E₀ ≤ Fintype.card V := by
        simpa using card_le_card (subset_univ E₀)
      rwa [hk E₀ hE₀] at this
    have hk1 : 1 ≤ k := by
      rcases Nat.eq_zero_or_pos k with hk0 | hk0
      · exfalso
        rw [hk0] at hcard
        simp only [Nat.zero_sub, pow_zero] at hcard
        have : 0 < #H := card_pos.2 ⟨E₀, hE₀⟩
        omega
      · exact hk0
    have hbad : #(badColourings H) < 2 ^ (Fintype.card V) := by
      have h1 := card_bad_colourings_le H k hk
      have h2 : #H * (2 * 2 ^ (Fintype.card V - k)) <
          2 ^ (k - 1) * (2 * 2 ^ (Fintype.card V - k)) := by
        refine Nat.mul_lt_mul_of_lt_of_le hcard (le_refl _) ?_
        positivity
      have h3 : 2 ^ (k - 1) * (2 * 2 ^ (Fintype.card V - k)) = 2 ^ (Fintype.card V) := by
        rw [← pow_succ', ← pow_add]
        congr 1
        omega
      omega
    have hsubset : badColourings H ⊆ (univ : Finset V).powerset := filter_subset _ _
    have hne : badColourings H ≠ (univ : Finset V).powerset := by
      intro hEq
      rw [hEq, card_powerset, card_univ] at hbad
      exact lt_irrefl _ hbad
    obtain ⟨S, hS, hSbad⟩ : ∃ S ∈ (univ : Finset V).powerset, S ∉ badColourings H := by
      by_contra hcon
      push_neg at hcon
      exact hne (Finset.Subset.antisymm hsubset hcon)
    refine ⟨S, fun E hE hmono => hSbad ?_⟩
    simp only [badColourings, mem_filter, mem_powerset]
    exact ⟨mem_powerset.1 hS, E, hE, hmono⟩

omit [Fintype V] in
/-- Sharpness sanity check at `k = 1`: a hypergraph consisting of one singleton edge has
`#H = 1 = 2 ^ (1-1)`, and indeed *every* colouring makes that edge monochromatic, so the
strict inequality `#H < 2 ^ (k-1)` in `exists_proper_two_colouring` cannot be weakened to `≤`. -/
theorem property_B_sharp_example (v : V) :
    ∀ S : Finset V, MonoEdge S ({v} : Finset V) := by
  intro S
  by_cases hv : v ∈ S
  · exact Or.inl (by simpa using hv)
  · exact Or.inr (by simpa [Finset.disjoint_singleton_right] using hv)

end PropertyBUnionBound