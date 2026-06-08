/-
# Proof-Theoretic Topology: Core Theorems

This file proves the main theorems establishing the mathematical foundations of
proof-theoretic topology: monotonicity of threshold graph filtrations, the triangle
inequality for symmetric difference, collapse and fragmentation phase theorems,
and the emergence of nontrivial cycle rank in intermediate regimes.

## Main Results

* `symmDiffCard_symm` — symmetric difference cardinality is symmetric
* `symmDiffCard_triangle` — triangle inequality for symmetric difference
* `semanticDist_symm` — semantic distance is symmetric
* `semanticGraph_mono` — threshold graph filtration is monotone
* `semanticDist_le_twice_of_common_core` — common-core bound on pairwise distance
* `semanticGraph_complete_of_common_core` — high-threshold collapse to complete graph
* `disconnected_of_cluster_separation` — low-threshold fragmentation
* `graphCycleRank_pos_of_connected_many_edges` — positive cycle rank from edge surplus
* `exists_intermediate_cycle_phase` — existence of intermediate topological regime
-/

import Mathlib
import Speculative.ProofTheoreticTopology.Defs

open Finset

/-! ## Properties of Symmetric Difference Cardinality -/

/-- The symmetric difference cardinality is symmetric: `|A Δ B| = |B Δ A|`. -/
theorem symmDiffCard_symm {β : Type*} [DecidableEq β] (A B : Finset β) :
    symmDiffCard A B = symmDiffCard B A := by
  simp [symmDiffCard, add_comm]

/-
Triangle inequality for symmetric difference cardinality:
`|A Δ C| ≤ |A Δ B| + |B Δ C|`.
This is the key metric-like property enabling the common-core theorem.
-/
theorem symmDiffCard_triangle {β : Type*} [DecidableEq β]
    (A B C : Finset β) :
    symmDiffCard A C ≤ symmDiffCard A B + symmDiffCard B C := by
  unfold symmDiffCard;
  have h_card_le : (A \ C).card ≤ (A \ B).card + (B \ C).card := by
    exact le_trans ( Finset.card_le_card fun x hx => by by_cases h : x ∈ B <;> aesop ) ( Finset.card_union_le _ _ );
  grind

/-! ## Properties of Semantic Distance -/

/-- Semantic distance is symmetric. -/
theorem semanticDist_symm {α β : Type*} [DecidableEq β]
    (S : α → Finset β) (x y : α) :
    semanticDist S x y = semanticDist S y x := by
  exact symmDiffCard_symm (S x) (S y)

/-! ## Theorem 1: Monotonicity of Semantic Threshold Graphs -/

/-- **Monotonicity of semantic threshold graphs.**
If ε ≤ ε', then every edge in the threshold graph at ε is also an edge at ε'.
This establishes that the family `(semanticGraph S ε)_{ε ∈ ℕ}` forms a
monotone filtration of simple graphs, which is the prerequisite for any
persistent-topology analysis. -/
theorem semanticGraph_mono
    {α β : Type*} [DecidableEq α] [DecidableEq β]
    (S : α → Finset β) {ε ε' : ℕ} (h : ε ≤ ε') :
    ∀ ⦃x y : α⦄, (semanticGraph S ε).Adj x y → (semanticGraph S ε').Adj x y := by
  intro x y ⟨hne, hdist⟩
  exact ⟨hne, le_trans hdist h⟩

/-! ## Theorem 2: Common-Core Collapse -/

/-- **Common-core distance bound.** If every element's feature set
has symmetric difference at most `r` from a common core `C`, then
the pairwise semantic distance is at most `2 * r`. This is proved
via the triangle inequality through `C`. -/
theorem semanticDist_le_twice_of_common_core
    {α β : Type*} [DecidableEq β]
    (S : α → Finset β) (C : Finset β) (r : ℕ)
    (hball : ∀ x, symmDiffCard (S x) C ≤ r) :
    ∀ x y, semanticDist S x y ≤ 2 * r := by
  intro x y
  calc semanticDist S x y
      = symmDiffCard (S x) (S y) := rfl
    _ ≤ symmDiffCard (S x) C + symmDiffCard C (S y) := symmDiffCard_triangle _ _ _
    _ = symmDiffCard (S x) C + symmDiffCard (S y) C := by rw [symmDiffCard_symm C (S y)]
    _ ≤ r + r := add_le_add (hball x) (hball y)
    _ = 2 * r := by ring

/-- **Complete graph from common core.** Under the common-core hypothesis,
the threshold graph at `2r` is complete: every pair of distinct elements is adjacent.
This is the "high-similarity phase" — when all statements share a common semantic core,
the filtration collapses to the complete graph. -/
theorem semanticGraph_complete_of_common_core
    {α β : Type*} [Fintype α] [DecidableEq α] [DecidableEq β]
    (S : α → Finset β) (C : Finset β) (r : ℕ)
    (hball : ∀ x, symmDiffCard (S x) C ≤ r) :
    ∀ x y, x ≠ y → (semanticGraph S (2 * r)).Adj x y := by
  intro x y hxy
  exact ⟨hxy, semanticDist_le_twice_of_common_core S C r hball x y⟩

/-! ## Theorem 3: Cluster Separation and Disconnected Phase -/

/-
**Disconnected phase from cluster separation.**
If the statement family splits into two nonempty clusters `A` and `B` with
all cross-cluster distances exceeding `R`, then the threshold graph at any
`ε < R` is disconnected. This establishes the "fragmented phase" at low
thresholds, the mathematical counterpart of semantic incommensurability
between distinct doctrinal clusters.
-/
theorem disconnected_of_cluster_separation
    {α β : Type*} [Fintype α] [DecidableEq α] [DecidableEq β]
    (S : α → Finset β) (A B : Finset α) (R ε : ℕ)
    (hcover : ∀ x : α, x ∈ A ∨ x ∈ B)
    (hdisj : Disjoint A B)
    (hsep : ∀ a b, a ∈ A → b ∈ B → R ≤ semanticDist S a b)
    (hε : ε < R)
    (hA : A.Nonempty) (hB : B.Nonempty) :
    ¬ (semanticGraph S ε).Connected := by
  obtain ⟨ a, ha ⟩ := hA;
  obtain ⟨ b, hb ⟩ := hB;
  intro h
  obtain ⟨p, hp⟩ : ∃ p : SimpleGraph.Walk (semanticGraph S ε) a b, True := by
    have := h a b; aesop;
  induction p <;> simp_all +decide;
  · exact Finset.disjoint_left.mp hdisj ha hb;
  · rename_i u v w hu hv hw ih;
    cases hcover w <;> simp_all +decide [ Finset.disjoint_left ];
    exact not_lt_of_ge ( hsep _ _ ha ‹_› ) ( lt_of_le_of_lt ( by simpa using hv.2 ) hε )

/-! ## Theorem 4: Positive Cycle Rank from Edge Surplus -/

/-
**Positive cycle rank from edge surplus.**
If a connected graph on a finite type has at least as many edges as vertices,
then its cycle rank (cyclomatic number) is positive. Since the cycle rank equals
`|E| - |V| + c` and a connected graph has `c = 1`, we get `|E| - |V| + 1 > 0`.
This certifies a nontrivial 1-cycle in the graph realization, providing a rigorous
topological order parameter.
-/
theorem graphCycleRank_pos_of_connected_many_edges
    {α : Type*} [Fintype α] [DecidableEq α]
    (G : SimpleGraph α) [DecidableRel G.Adj]
    (hconn : G.Connected)
    (hedge : Fintype.card α ≤ G.edgeFinset.card) :
    0 < graphCycleRank G := by
  -- Since G is connected, it has exactly one connected component.
  have h_connected_components : Fintype.card G.ConnectedComponent = 1 := by
    rw [ Fintype.card_eq_one_iff ];
    obtain ⟨x, hx⟩ : ∃ x : α, ∀ y : α, G.Reachable x y := by
      cases isEmpty_or_nonempty α <;> simp_all +decide [ SimpleGraph.connected_iff_exists_forall_reachable ];
    refine' ⟨ G.connectedComponentMk x, _ ⟩;
    rintro ⟨ y ⟩;
    exact Quot.sound ( hx y |> fun h => h.symm )
  simp_all +decide [ graphCycleRank ]

/-! ## Theorem 5: Intermediate Topological Regime -/

/-- **Intermediate cycle phase theorem.**
Given a semantic graph filtration that is disconnected at low threshold `ε₀`
and complete at high threshold `ε₁`, if there exists an intermediate threshold
where the graph is connected with at least `|V|` edges, then there exists a
threshold with positive cycle rank. This is the precise finite prototype of
the "topological complexity appears between fragmentation and saturation" principle. -/
theorem exists_intermediate_cycle_phase
    {α β : Type*} [Fintype α] [DecidableEq α] [DecidableEq β] [Nonempty α]
    (S : α → Finset β) {ε₀ ε₁ : ℕ}
    (_hlt : ε₀ < ε₁)
    (_hdisc : ¬ (semanticGraph S ε₀).Connected)
    (_hcomplete : ∀ x y, x ≠ y → (semanticGraph S ε₁).Adj x y)
    (hedge_growth : ∃ ε, ε₀ < ε ∧ ε ≤ ε₁ ∧
      (semanticGraph S ε).Connected ∧
      Fintype.card α ≤ (semanticGraph S ε).edgeFinset.card) :
    ∃ ε, ε₀ < ε ∧ ε ≤ ε₁ ∧
      0 < graphCycleRank (semanticGraph S ε) := by
  rcases hedge_growth with ⟨ε, h0, h1, hconn, hcard⟩
  exact ⟨ε, h0, h1, graphCycleRank_pos_of_connected_many_edges _ hconn hcard⟩

/-! ## Verified Transition Profile Scanner -/

/-- Compute the transition profile for a given set of thresholds.
Returns a list of tuples `(ε, edgeCount, cycleRankBound)` where
cycleRankBound is the cycle rank. This is the computational core
of the topological diagnostic pipeline. -/
noncomputable def transitionProfile {α β : Type*} [Fintype α] [DecidableEq α] [DecidableEq β]
    (S : α → Finset β) (thresholds : List ℕ) :
    List (ℕ × ℕ × ℤ) :=
  thresholds.map fun ε =>
    let G := semanticGraph S ε
    (ε, G.edgeFinset.card, graphCycleRank G)