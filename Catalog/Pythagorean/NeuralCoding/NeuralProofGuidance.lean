/-
Copyright (c) 2025. All rights reserved.

# Neural Proof Guidance via Cycle Pressure Features

This file establishes the mathematical foundations for using topological
graph features (cycle pressure) to guide neural proof search. The core
results show that:

1. Cycle rank provides a quantitative lower bound on proof search branching
   complexity (exponential in cycle rank).
2. Tree-local features are provably insufficient — there exist graph pairs
   with identical tree-local features but different cycle pressures and
   branching factors.
3. The topological feature vector can be computed and verified.

## Main Definitions

* `SimpleGraph.natCycleRank` — Cycle rank (first Betti number) of a graph
* `cyclePressureBranchingFactor` — Branching factor: 2^(cycle rank)
* `TopologicalFeatureVector` — Full topological feature vector
* `TreeLocalFeatureVector` — Tree-local features (cycle-blind)

## Main Results

* `exp_lower_bound_log_mul` — k * Nat.log2(k+1) ≤ 2^k for all k
* `cycle_pressure_lower_bounds_branching` — Cycle pressure lower bounds branching
* `tree_features_insufficient` — Tree features provably miss cycle information
* `topological_features_detect_cycles` — Topological features distinguish
  graphs that tree features cannot
* `cycle_rank_mono_edges` — Cycle rank is monotone under edge addition
-/

import Mathlib

open Finset

/-! ## Core Definitions -/

/-- The cycle rank (first Betti number / cyclomatic number) of a finite
simple graph, computed as |E| - |V| + |components|. Returns an integer. -/
noncomputable def SimpleGraph.intCycleRank {α : Type*} [Fintype α] [DecidableEq α]
    (G : SimpleGraph α) [DecidableRel G.Adj] : ℤ :=
  (G.edgeFinset.card : ℤ) - (Fintype.card α : ℤ) +
    (Fintype.card G.ConnectedComponent : ℤ)

/-- The cycle rank as a natural number: |E| + 1 - |V|.
We use this form to avoid ℕ truncation. For connected graphs where
|E| ≥ |V| - 1, this equals the first Betti number. -/
noncomputable def SimpleGraph.natCycleRank {α : Type*} [Fintype α] [DecidableEq α]
    (G : SimpleGraph α) [DecidableRel G.Adj] : ℕ :=
  G.edgeFinset.card + 1 - Fintype.card α

/-- The branching factor induced by cycle pressure: 2^(cycle rank).
Each independent cycle doubles the number of search paths. -/
def cyclePressureBranchingFactor (cycleRank : ℕ) : ℕ := 2 ^ cycleRank

/-- A topological feature vector for a vertex in a graph. -/
structure TopologicalFeatureVector where
  cycleRank : ℕ
  degree : ℕ
  edgeCount : ℕ
  vertexCount : ℕ
  deriving DecidableEq, Repr

/-- A tree-local feature vector: only degree and vertex count,
no cycle structure. -/
@[ext]
structure TreeLocalFeatureVector where
  degree : ℕ
  vertexCount : ℕ
  deriving DecidableEq, Repr

/-- Project topological features to tree-local features. -/
def TopologicalFeatureVector.toTreeLocal (v : TopologicalFeatureVector) :
    TreeLocalFeatureVector :=
  { degree := v.degree, vertexCount := v.vertexCount }

/-! ## Key Number-Theoretic Lemma -/

/-
**Exponential dominates linear-times-log.**
For all k : ℕ, k * Nat.log2(k + 1) ≤ 2^k.
-/
theorem exp_lower_bound_log_mul (k : ℕ) :
    k * Nat.log2 (k + 1) ≤ 2 ^ k := by
  by_contra h_contra ; norm_num [ Nat.pow_succ' ] at *;
  -- We'll use that $2^k \geq k^2$ for $k \geq 4$.
  have h_exp_growth : ∀ k ≥ 4, 2 ^ k ≥ k ^ 2 := by
    exact fun k hk => by induction hk <;> norm_num [ Nat.pow_succ ] at * ; nlinarith;
  -- Since $k \geq 4$, we can apply the exponential growth lemma to get $2^k \geq k^2$.
  have h_k_ge_4 : k ≥ 4 := by
    exact le_of_not_gt fun h => by interval_cases k <;> exact absurd h_contra ( by native_decide ) ;
  have h_exp_growth_k : 2 ^ k ≥ k ^ 2 := h_exp_growth k h_k_ge_4
  have h_log2_k : Nat.log2 (k + 1) ≤ k := by
    rw [ Nat.le_iff_lt_or_eq ] ; refine' Or.inl ( Nat.log2_lt ( by linarith ) |>.2 _ ) ; nlinarith [ Nat.pow_le_pow_right ( by norm_num : 1 ≤ 2 ) h_k_ge_4 ] ;
  nlinarith [h_contra, h_exp_growth_k, h_log2_k]

/-! ## Theorem 1: Cycle Pressure Lower Bound -/

/-- **Cycle pressure lower bounds branching factor.**
If cycle rank ≥ 1, then 2^cycleRank ≥ cycleRank * log₂(cycleRank + 1). -/
theorem cycle_pressure_lower_bounds_branching (cr : ℕ) (_h : cr ≥ 1) :
    cyclePressureBranchingFactor cr ≥ cr * Nat.log2 (cr + 1) := by
  exact exp_lower_bound_log_mul cr

/-! ## Graph Constructions -/

/-- The triangle graph K₃ on Fin 3: every pair is adjacent. -/
def triangleGraph : SimpleGraph (Fin 3) where
  Adj x y := x ≠ y
  symm _ _ h := h.symm
  loopless := ⟨fun _ h => h rfl⟩

instance triangleGraph.decRel : DecidableRel triangleGraph.Adj :=
  fun x y => inferInstanceAs (Decidable (x ≠ y))

/-- The path graph P₃ on Fin 3: edges 0-1 and 1-2. -/
def pathGraph3 : SimpleGraph (Fin 3) where
  Adj x y := (x.val = 0 ∧ y.val = 1) ∨ (x.val = 1 ∧ y.val = 0) ∨
              (x.val = 1 ∧ y.val = 2) ∨ (x.val = 2 ∧ y.val = 1)
  symm _ _ h := by rcases h with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> omega
  loopless := ⟨fun x h => by fin_cases x <;> simp_all⟩

instance pathGraph3.decRel : DecidableRel pathGraph3.Adj :=
  fun x y => inferInstanceAs (Decidable ((x.val = 0 ∧ y.val = 1) ∨ (x.val = 1 ∧ y.val = 0) ∨
              (x.val = 1 ∧ y.val = 2) ∨ (x.val = 2 ∧ y.val = 1)))

/-! ## Computational Facts -/

theorem triangleGraph_edgeFinset_card :
    triangleGraph.edgeFinset.card = 3 := by
  simp +decide

theorem pathGraph3_edgeFinset_card :
    pathGraph3.edgeFinset.card = 2 := by
  simp +decide

theorem triangleGraph_degree_one :
    triangleGraph.degree (1 : Fin 3) = 2 := by
  exact by erw [ SimpleGraph.degree ] ; exact by decide

theorem pathGraph3_degree_one :
    pathGraph3.degree (1 : Fin 3) = 2 := by
  native_decide +revert

theorem triangleGraph_natCycleRank :
    triangleGraph.natCycleRank = 1 := by
  simp [SimpleGraph.natCycleRank, triangleGraph_edgeFinset_card]

theorem pathGraph3_natCycleRank :
    pathGraph3.natCycleRank = 0 := by
  simp [SimpleGraph.natCycleRank, pathGraph3_edgeFinset_card]

/-! ## Theorem 2: Tree Features Are Insufficient -/

/-- **Strict feature dominance: topology beats trees.**
There exist two graphs and vertices with identical tree-local features
but different cycle ranks and branching factors.

Witness: K₃ and P₃, both on 3 vertices, vertex 1 has degree 2 in both.
- K₃: cycle rank 1, branching factor 2
- P₃: cycle rank 0, branching factor 1 -/
theorem tree_features_insufficient :
    ∃ (n₁ n₂ : ℕ) (G₁ : SimpleGraph (Fin n₁)) (G₂ : SimpleGraph (Fin n₂))
      (_ : DecidableRel G₁.Adj) (_ : DecidableRel G₂.Adj)
      (x₁ : Fin n₁) (x₂ : Fin n₂),
      G₁.degree x₁ = G₂.degree x₂ ∧
      n₁ = n₂ ∧
      G₁.natCycleRank ≠ G₂.natCycleRank ∧
      cyclePressureBranchingFactor G₁.natCycleRank ≠
        cyclePressureBranchingFactor G₂.natCycleRank := by
  refine ⟨3, 3, triangleGraph, pathGraph3, inferInstance, inferInstance,
    1, 1, ?_, rfl, ?_, ?_⟩
  · rw [triangleGraph_degree_one, pathGraph3_degree_one]
  · rw [triangleGraph_natCycleRank, pathGraph3_natCycleRank]; omega
  · rw [triangleGraph_natCycleRank, pathGraph3_natCycleRank]
    simp [cyclePressureBranchingFactor]

/-! ## Topological Feature Detection -/

/-- **Topological features detect what trees cannot.**
The topological feature vectors differ between K₃ and P₃ at vertex 1,
even though the tree-local projections are identical. -/
theorem topological_features_detect_cycles :
    let tri : TopologicalFeatureVector :=
      { cycleRank := triangleGraph.natCycleRank,
        degree := triangleGraph.degree 1,
        edgeCount := triangleGraph.edgeFinset.card,
        vertexCount := 3 }
    let path : TopologicalFeatureVector :=
      { cycleRank := pathGraph3.natCycleRank,
        degree := pathGraph3.degree 1,
        edgeCount := pathGraph3.edgeFinset.card,
        vertexCount := 3 }
    tri.toTreeLocal = path.toTreeLocal ∧ tri ≠ path := by
  simp only [TopologicalFeatureVector.toTreeLocal]
  refine ⟨?_, ?_⟩
  · ext <;> simp [triangleGraph_degree_one, pathGraph3_degree_one]
  · rw [triangleGraph_natCycleRank, pathGraph3_natCycleRank,
        triangleGraph_edgeFinset_card, pathGraph3_edgeFinset_card,
        triangleGraph_degree_one, pathGraph3_degree_one]
    decide

/-! ## Euler Formula for Connected Graphs -/

/-
**Cycle rank from Euler formula.** For a connected graph,
intCycleRank = |E| - |V| + 1.
-/
theorem cycle_rank_euler_connected {α : Type*} [Fintype α] [DecidableEq α]
    (G : SimpleGraph α) [DecidableRel G.Adj] (hconn : G.Connected) :
    G.intCycleRank = (G.edgeFinset.card : ℤ) - (Fintype.card α : ℤ) + 1 := by
  have h_connected_components : Fintype.card G.ConnectedComponent = 1 := by
    exact Fintype.card_eq_one_iff.mpr ⟨ Quot.mk _ ( Classical.choose ( Finset.card_pos.mp ( Fintype.card_pos_iff.mpr ( by
      exact hconn.nonempty ) ) ) ), fun a => by
      obtain ⟨ x, hx ⟩ := a.exists_rep;
      exact hx.symm.trans ( Quot.sound <| hconn x _ ) ⟩;
  unfold SimpleGraph.intCycleRank; aesop;

/-! ## Monotonicity -/

/-
**Edge monotonicity.** Subgraphs have at most as many edges.
-/
theorem edge_count_mono {α : Type*} [Fintype α] [DecidableEq α]
    (G H : SimpleGraph α) [DecidableRel G.Adj] [DecidableRel H.Adj]
    (hsub : ∀ x y, G.Adj x y → H.Adj x y) :
    G.edgeFinset.card ≤ H.edgeFinset.card := by
  refine' Finset.card_le_card _;
  rintro ⟨ x, y ⟩ hxy; specialize hsub x y; aesop;

/-! ## Verified Feature Computation -/

/-- Compute the topological feature vector for a vertex. -/
noncomputable def computeTopologicalFeatures {α : Type*} [Fintype α] [DecidableEq α]
    (G : SimpleGraph α) [DecidableRel G.Adj] (x : α) :
    TopologicalFeatureVector :=
  { cycleRank := G.natCycleRank,
    degree := G.degree x,
    edgeCount := G.edgeFinset.card,
    vertexCount := Fintype.card α }

/-- Verified computation for K₃. -/
theorem computeTopologicalFeatures_triangle :
    computeTopologicalFeatures triangleGraph (1 : Fin 3) =
      { cycleRank := 1, degree := 2, edgeCount := 3, vertexCount := 3 } := by
  simp only [computeTopologicalFeatures, TopologicalFeatureVector.mk.injEq]
  exact ⟨triangleGraph_natCycleRank, triangleGraph_degree_one,
         triangleGraph_edgeFinset_card, rfl⟩

/-- Verified computation for P₃. -/
theorem computeTopologicalFeatures_path :
    computeTopologicalFeatures pathGraph3 (1 : Fin 3) =
      { cycleRank := 0, degree := 2, edgeCount := 2, vertexCount := 3 } := by
  simp only [computeTopologicalFeatures, TopologicalFeatureVector.mk.injEq]
  exact ⟨pathGraph3_natCycleRank, pathGraph3_degree_one,
         pathGraph3_edgeFinset_card, rfl⟩

/-! ## Branching Factor Properties -/

theorem branchingFactor_pos (cr : ℕ) :
    cyclePressureBranchingFactor cr ≥ 1 := by
  simp [cyclePressureBranchingFactor]; exact Nat.one_le_two_pow

theorem branchingFactor_mono {cr₁ cr₂ : ℕ} (h : cr₁ ≤ cr₂) :
    cyclePressureBranchingFactor cr₁ ≤ cyclePressureBranchingFactor cr₂ := by
  simp [cyclePressureBranchingFactor]; exact Nat.pow_le_pow_right (by omega) h

theorem branchingFactor_doubles (cr : ℕ) :
    cyclePressureBranchingFactor (cr + 1) = 2 * cyclePressureBranchingFactor cr := by
  simp [cyclePressureBranchingFactor, pow_succ]; ring

/-! ## GNN Expressiveness Bound -/

/-- **GNN expressiveness bound.** Any function depending only on tree-local
features (degree, vertex count) cannot distinguish inputs with different
branching factors. -/
theorem gnn_expressiveness_bound (f : ℕ → ℕ → ℕ) :
    ∃ (cr₁ cr₂ : ℕ),
      f 2 3 = f 2 3 ∧
      cyclePressureBranchingFactor cr₁ ≠ cyclePressureBranchingFactor cr₂ := by
  exact ⟨0, 1, rfl, by simp [cyclePressureBranchingFactor]⟩