/-
# Property B, the extremal function `m(k)`: packaging and the exact values `m(1)=1`, `m(2)=3`

This file continues the probabilistic-method development around **Property B** (Erdős 1963,
two-colourability of sparse hypergraphs).  The previous cycle established the general lower
bound `2^{k-1} ≤ m(k)` and a concrete non-2-colourable witness for `k = 2` (the triangle),
pinning down `m(2) ≤ 3`.

Here we go further and *package the extremal function `m(k)` itself* as an explicit natural
number and determine its first two exact values:

* `PropertyBExtremal.m` — the Erdős extremal function, defined as the least number of edges of
  a non-2-colourable `k`-uniform hypergraph (an infimum over all vertex counts `N`).
* `PropertyBExtremal.m_ge` — the general lower bound `2^{k-1} ≤ m(k)` (for `k ≥ 1`, whenever the
  configuration set is nonempty), re-packaged from the union-bound theorem.
* `PropertyBExtremal.two_colorable_of_card_le_two` — **the sharp lower bound machinery for
  `k = 2`**: *every* graph (`2`-uniform hypergraph) with at most `2` edges is `2`-colourable.
  This is genuinely new content (a "every 2-edge graph is bipartite" argument), and it is what
  upgrades `m(2) ≥ 2` to the sharp `m(2) ≥ 3`.
* `PropertyBExtremal.m_one` and `PropertyBExtremal.m_two` — the exact values `m(1) = 1` and
  `m(2) = 3`, obtained by combining the lower bounds with explicit extremal witnesses (a single
  vertex-edge for `k = 1`, the triangle for `k = 2`).

The foundational counting lemmas and the union-bound theorem
(`card_filter_superset`, `card_filter_disjoint`, `exists_proper_two_coloring`) are reproduced here
so that the file is self-contained; the new mathematics is the sharp `k = 2` lower bound and the
packaging of `m(k)` as an extremal number with its exact small values.
-/

import Mathlib

open scoped Classical
open Finset

namespace PropertyBExtremal

/-! ## Boolean-lattice counting lemmas (foundation) -/

/-- Interval cardinality: the number of subsets of a ground set `Gr` that contain a fixed
`S ⊆ Gr` is `2 ^ (|Gr| − |S|)`. -/
lemma card_filter_superset {α : Type*} [DecidableEq α] (Gr S : Finset α) (h : S ⊆ Gr) :
    (Gr.powerset.filter (fun A => S ⊆ A)).card = 2 ^ (Gr.card - S.card) := by
  rw [show (2:ℕ)^(Gr.card - S.card) = ((Gr \ S).powerset).card by
        rw [Finset.card_powerset, Finset.card_sdiff_of_subset h]]
  apply Finset.card_bij (fun A _ => A \ S)
  · intro A hA
    simp only [Finset.mem_filter, Finset.mem_powerset] at hA
    simp only [Finset.mem_powerset]
    exact Finset.sdiff_subset_sdiff hA.1 (le_refl S)
  · intro A hA B hB heq
    simp only [Finset.mem_filter, Finset.mem_powerset] at hA hB
    have : (A \ S) ∪ S = (B \ S) ∪ S := by rw [heq]
    rwa [Finset.sdiff_union_of_subset hA.2, Finset.sdiff_union_of_subset hB.2] at this
  · intro B hB
    simp only [Finset.mem_powerset] at hB
    refine ⟨B ∪ S, ?_, ?_⟩
    · simp only [Finset.mem_filter, Finset.mem_powerset]
      refine ⟨Finset.union_subset (hB.trans (Finset.sdiff_subset)) h, Finset.subset_union_right⟩
    · rw [Finset.union_sdiff_right]
      apply Finset.sdiff_eq_self_of_disjoint
      exact (Finset.disjoint_left.2 (fun x hxB hxS => ((Finset.mem_sdiff.1 (hB hxB)).2) hxS))

/-- The number of subsets of `Gr` disjoint from a fixed `S ⊆ Gr` is also `2 ^ (|Gr| − |S|)`
(complement involution `A ↦ Gr \ A`). -/
lemma card_filter_disjoint {α : Type*} [DecidableEq α] (Gr S : Finset α) (h : S ⊆ Gr) :
    (Gr.powerset.filter (fun A => Disjoint S A)).card = 2 ^ (Gr.card - S.card) := by
  rw [← card_filter_superset Gr S h]
  apply Finset.card_bij (fun A _ => Gr \ A)
  · intro A hA
    simp only [Finset.mem_filter, Finset.mem_powerset] at hA ⊢
    refine ⟨Finset.sdiff_subset, ?_⟩
    intro x hxS
    rw [Finset.mem_sdiff]
    exact ⟨h hxS, fun hxA => (Finset.disjoint_left.1 hA.2) hxS hxA⟩
  · intro A hA B hB heq
    simp only [Finset.mem_filter, Finset.mem_powerset] at hA hB
    have : Gr \ (Gr \ A) = Gr \ (Gr \ B) := by rw [heq]
    rwa [Finset.sdiff_sdiff_eq_self hA.1, Finset.sdiff_sdiff_eq_self hB.1] at this
  · intro B hB
    simp only [Finset.mem_filter, Finset.mem_powerset] at hB
    refine ⟨Gr \ B, ?_, ?_⟩
    · simp only [Finset.mem_filter, Finset.mem_powerset]
      refine ⟨Finset.sdiff_subset, ?_⟩
      rw [Finset.disjoint_right]
      intro x hx
      rw [Finset.mem_sdiff] at hx
      exact fun hxS => hx.2 (hB.2 hxS)
    · rw [Finset.sdiff_sdiff_eq_self hB.1]

/-! ## The union bound: existence of a proper 2-colouring (foundation) -/

/-- **Property B (sharp form).** Let `H` be a hypergraph on `Fin N` in which every edge has at
least `k ≥ 1` vertices.  If `H` has fewer than `2^{k-1}` edges, then there is a 2-colouring
`R ⊆ Fin N` (red vertices) making no edge monochromatic: every edge has both a red and a blue
vertex. -/
theorem exists_proper_two_coloring (N k : ℕ) (hk : 1 ≤ k)
    (H : Finset (Finset (Fin N)))
    (hedge : ∀ e ∈ H, k ≤ e.card)
    (hcard : H.card < 2 ^ (k - 1)) :
    ∃ R : Finset (Fin N), ∀ e ∈ H, ¬ (e ⊆ R) ∧ ¬ Disjoint e R := by
  by_contra h_no_coloring;
  have h_total_bad : Finset.card (Finset.biUnion H (fun e => Finset.filter (fun R => e ⊆ R) (Finset.powerset (Finset.univ : Finset (Fin N))) ∪ Finset.filter (fun R => Disjoint e R) (Finset.powerset (Finset.univ : Finset (Fin N))))) < 2 ^ N := by
    have h_bad_colorings_per_edge : ∀ e ∈ H, Finset.card (Finset.filter (fun R => e ⊆ R) (Finset.powerset (Finset.univ : Finset (Fin N))) ∪ Finset.filter (fun R => Disjoint e R) (Finset.powerset (Finset.univ : Finset (Fin N)))) ≤ 2 ^ (N - k + 1) := by
      intros e he
      have h_bad_colorings_per_edge : Finset.card (Finset.filter (fun R => e ⊆ R) (Finset.powerset (Finset.univ : Finset (Fin N)))) ≤ 2 ^ (N - k) ∧ Finset.card (Finset.filter (fun R => Disjoint e R) (Finset.powerset (Finset.univ : Finset (Fin N)))) ≤ 2 ^ (N - k) := by
        constructor;
        · have h_filter_superset : (Finset.filter (fun R => e ⊆ R) (Finset.powerset (Finset.univ : Finset (Fin N)))).card = 2 ^ (N - e.card) := by
            convert card_filter_superset ( Finset.univ : Finset ( Fin N ) ) e ( Finset.subset_univ e ) using 1;
            rw [ Finset.card_fin ];
          exact h_filter_superset.symm ▸ pow_le_pow_right₀ ( by decide ) ( Nat.sub_le_sub_left ( hedge e he ) _ );
        · have := card_filter_disjoint ( Finset.univ : Finset ( Fin N ) ) e ( Finset.subset_univ e );
          exact this.le.trans ( pow_le_pow_right₀ ( by decide ) ( Nat.sub_le_sub_left ( hedge e he ) _ ) ) |> le_trans <| by simp +decide ;
      exact le_trans ( Finset.card_union_le _ _ ) ( by rw [ pow_succ' ] ; linarith );
    refine' lt_of_le_of_lt ( Finset.card_biUnion_le ) _;
    refine' lt_of_le_of_lt ( Finset.sum_le_sum h_bad_colorings_per_edge ) _ ; norm_num [ pow_add ] at *;
    rcases k with ( _ | k ) <;> simp_all +decide;
    by_cases hN : N ≥ k + 1;
    · convert mul_lt_mul_of_pos_right hcard ( show 0 < 2 ^ ( N - ( k + 1 ) ) * 2 by positivity ) using 1 ; rw [ show 2 ^ N = 2 ^ ( k + 1 ) * 2 ^ ( N - ( k + 1 ) ) by rw [ ← pow_add, Nat.add_sub_of_le hN ] ] ; ring;
    · exact absurd ( h_no_coloring ∅ ) ( by rintro ⟨ e, he, he' ⟩ ; specialize hedge e he; linarith [ show Finset.card e ≤ N from le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ] );
  convert h_total_bad.ne ?_;
  rw [ show ( Finset.biUnion H fun e => Finset.filter ( fun R => e ⊆ R ) ( Finset.powerset Finset.univ ) ∪ Finset.filter ( fun R => Disjoint e R ) ( Finset.powerset Finset.univ ) ) = Finset.powerset Finset.univ from ?_ ];
  · simp +decide [ Finset.card_univ ];
  · ext R; simp;
    exact not_forall_not.mp fun h => h_no_coloring ⟨ R, fun e he => by specialize h e; aesop ⟩

/-- A single edge of size `≥ 2` is 2-colourable (Property B with `k = 2`, `m = 1 < 2`). -/
theorem single_edge_two_colorable (N : ℕ) (e : Finset (Fin N)) (he : 2 ≤ e.card) :
    ∃ R : Finset (Fin N), ¬ (e ⊆ R) ∧ ¬ Disjoint e R := by
  obtain ⟨R, hR⟩ := exists_proper_two_coloring N 2 (by norm_num) {e}
    (by intro x hx; simp only [Finset.mem_singleton] at hx; subst hx; exact he)
    (by simp)
  exact ⟨R, hR e (by simp)⟩

/-! ## Non-2-colourability and the extremal function -/

/-- A hypergraph on `Fin N` is *not 2-colourable* if every red/blue colouring (encoded by the
red set `R`) leaves at least one monochromatic edge (entirely red or entirely blue). -/
def IsNonTwoColorable {N : ℕ} (H : Finset (Finset (Fin N))) : Prop :=
  ∀ R : Finset (Fin N), ∃ e ∈ H, e ⊆ R ∨ Disjoint e R

/-- Any hypergraph on `Fin N` whose edges each have at least `k ≥ 1` vertices and which is *not*
2-colourable must have at least `2^{k-1}` edges. -/
theorem card_ge_of_nonTwoColorable (N k : ℕ) (hk : 1 ≤ k)
    (H : Finset (Finset (Fin N)))
    (hedge : ∀ e ∈ H, k ≤ e.card)
    (hnon : IsNonTwoColorable H) :
    2 ^ (k - 1) ≤ H.card := by
  by_contra h
  push_neg at h
  obtain ⟨R, hR⟩ := exists_proper_two_coloring N k hk H hedge h
  obtain ⟨e, he, hmono⟩ := hnon R
  rcases hmono with h1 | h1
  · exact (hR e he).1 h1
  · exact (hR e he).2 h1

/-- The set of edge-counts realised by non-2-colourable `k`-uniform hypergraphs (over all vertex
counts `N`). -/
def mSet (k : ℕ) : Set ℕ :=
  {c | ∃ (N : ℕ) (H : Finset (Finset (Fin N))),
        (∀ e ∈ H, e.card = k) ∧ H.card = c ∧ IsNonTwoColorable H}

/-- **Erdős's extremal function `m(k)`**: the least number of edges of a non-2-colourable
`k`-uniform hypergraph. -/
noncomputable def m (k : ℕ) : ℕ := sInf (mSet k)

/-- Every realised edge-count of a non-2-colourable `k`-uniform hypergraph is at least `2^{k-1}`
(`k ≥ 1`). -/
theorem mSet_ge (k : ℕ) (hk : 1 ≤ k) : ∀ c ∈ mSet k, 2 ^ (k - 1) ≤ c := by
  rintro c ⟨N, H, huniform, hcard, hnon⟩
  have := card_ge_of_nonTwoColorable N k hk H (fun e he => (huniform e he).ge) hnon
  omega

/-- The general lower bound `2^{k-1} ≤ m(k)` (for `k ≥ 1`), valid whenever a non-2-colourable
`k`-uniform hypergraph exists. -/
theorem m_ge (k : ℕ) (hk : 1 ≤ k) (hne : (mSet k).Nonempty) : 2 ^ (k - 1) ≤ m k :=
  le_csInf hne (mSet_ge k hk)

/-! ## `m(1) = 1` -/

/-- The single-vertex hypergraph `{{0}}` on `Fin 1` is non-2-colourable (its one edge is
monochromatic under both colourings), witnessing `1 ∈ mSet 1`. -/
theorem one_mem_mSet_one : (1 : ℕ) ∈ mSet 1 := by
  refine ⟨1, {{0}}, ?_, ?_, ?_⟩
  · decide
  · decide
  · show ∀ R : Finset (Fin 1), ∃ e ∈ ({{0}} : Finset (Finset (Fin 1))), e ⊆ R ∨ Disjoint e R
    decide

/-- `m(1) = 1`: a single vertex-edge is the sparsest non-2-colourable `1`-uniform hypergraph. -/
theorem m_one : m 1 = 1 := by
  have hle : m 1 ≤ 1 := Nat.sInf_le one_mem_mSet_one
  have hge : 1 ≤ m 1 := by
    have := m_ge 1 (le_refl 1) ⟨1, one_mem_mSet_one⟩
    simpa using this
  omega

/-! ## The sharp lower bound for `k = 2`: every graph with ≤ 2 edges is 2-colourable -/

/-
**Sharp lower-bound machinery (`k = 2`).** Every graph (`2`-uniform hypergraph) with at most
`2` edges is `2`-colourable: there is a red set meeting and missing every edge.

This is the "every 2-edge graph is bipartite" step.  Two distinct `2`-element edges span at most
`4` vertices and cannot form a cycle (which needs `≥ 3` edges), so the graph is a forest and hence
`2`-colourable.
-/
theorem two_colorable_of_card_le_two (N : ℕ) (H : Finset (Finset (Fin N)))
    (huniform : ∀ e ∈ H, e.card = 2) (hcard : H.card ≤ 2) :
    ∃ R : Finset (Fin N), ∀ e ∈ H, ¬ (e ⊆ R) ∧ ¬ Disjoint e R := by
  interval_cases _ : #H;
  · aesop;
  · rw [ Finset.card_eq_one ] at *;
    rcases ‹∃ a, H = { a } › with ⟨ a, rfl ⟩ ; simp_all +decide [ Finset.subset_iff ];
    rcases Finset.card_eq_two.mp huniform with ⟨ x, y, hxy ⟩ ; use { x } ; aesop;
  · obtain ⟨ e1, e2, he1, he2 ⟩ := Finset.card_eq_two.mp ‹_›;
    by_cases h_inter : (e1 ∩ e2).Nonempty;
    · obtain ⟨ v, hv ⟩ := h_inter; use { v } ; simp_all +decide [ Finset.disjoint_left ] ;
      aesop;
    · obtain ⟨ a1, ha1 ⟩ := Finset.card_eq_two.mp ( huniform e1 ( by simp +decide [ he2 ] ) ) ; obtain ⟨ a2, ha2 ⟩ := Finset.card_eq_two.mp ( huniform e2 ( by simp +decide [ he2 ] ) ) ; simp_all +decide [ Finset.Nonempty ] ;
      obtain ⟨ b1, hb1, rfl ⟩ := ha1; obtain ⟨ b2, hb2, rfl ⟩ := ha2; use { a1, a2 } ; simp_all +decide [ Finset.subset_iff, Finset.disjoint_left ] ;
      grobner

/-- Contrapositive packaging: a graph (`2`-uniform hypergraph) with at most `2` edges is *not*
non-2-colourable. -/
theorem not_nonTwoColorable_of_card_le_two (N : ℕ) (H : Finset (Finset (Fin N)))
    (huniform : ∀ e ∈ H, e.card = 2) (hcard : H.card ≤ 2) :
    ¬ IsNonTwoColorable H := by
  intro hnon
  obtain ⟨R, hR⟩ := two_colorable_of_card_le_two N H huniform hcard
  obtain ⟨e, he, hmono⟩ := hnon R
  rcases hmono with h1 | h1
  · exact (hR e he).1 h1
  · exact (hR e he).2 h1

/-- Consequently, every realised edge-count in `mSet 2` is at least `3`. -/
theorem mSet_two_ge_three : ∀ c ∈ mSet 2, 3 ≤ c := by
  rintro c ⟨N, H, huniform, hcard, hnon⟩
  by_contra h
  push_neg at h
  exact not_nonTwoColorable_of_card_le_two N H huniform (by omega) hnon

/-! ## `m(2) = 3` (the triangle is the sparsest non-2-colourable graph) -/

/-- The triangle: the complete graph on `Fin 3`, with edge set `{{0,1},{1,2},{0,2}}`. -/
def triangleGraph : Finset (Finset (Fin 3)) := {{0, 1}, {1, 2}, {0, 2}}

/-- The triangle has exactly `3` edges. -/
theorem triangleGraph_card : triangleGraph.card = 3 := decide_eq_true_eq.mp rfl

/-- The triangle is `2`-uniform. -/
theorem triangleGraph_two_uniform : ∀ e ∈ triangleGraph, e.card = 2 :=
  decide_eq_true_eq.mp rfl

/-- The triangle is **not** 2-colourable (finite check over the `2^3` colourings). -/
theorem triangleGraph_nonTwoColorable : IsNonTwoColorable triangleGraph := by
  show ∀ R : Finset (Fin 3), ∃ e ∈ triangleGraph, e ⊆ R ∨ Disjoint e R
  exact decide_eq_true_eq.mp rfl

/-- The triangle witnesses `3 ∈ mSet 2`. -/
theorem three_mem_mSet_two : (3 : ℕ) ∈ mSet 2 :=
  ⟨3, triangleGraph, triangleGraph_two_uniform, triangleGraph_card, triangleGraph_nonTwoColorable⟩

/-- **`m(2) = 3`.** The triangle is the sparsest non-2-colourable graph: the lower bound
`mSet_two_ge_three` rules out `≤ 2` edges, and the triangle realises `3`. -/
theorem m_two : m 2 = 3 := by
  have hle : m 2 ≤ 3 := Nat.sInf_le three_mem_mSet_two
  have hge : 3 ≤ m 2 := le_csInf ⟨3, three_mem_mSet_two⟩ mSet_two_ge_three
  omega

end PropertyBExtremal