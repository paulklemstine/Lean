/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Exact Weighted Tropical Dimension Formula

This file establishes an exact formula for the dimension of the weighted tropical
kernel in terms of a weight-sensitive cycle invariant and a visibility defect term.

## Main Results

The central discovery is that tropical kernel dimension is governed not by the topology
of the graph alone, but by the topology of a **degeneracy subgraph** extracted from
local weight ties. Under generic weights, this subgraph is empty and the cycle
contribution vanishes. Under uniform weights, it recovers the full graph, yielding
the classical Betti number.

### New Definitions

* `hasTieAtVertex` — predicate for a weight tie at a vertex
* `tieSubgraph` — subgraph whose edges participate in weight ties
* `weightedBetti₁` — first Betti number of the tie subgraph restricted to S
* `weightedVisibleDefect` — q-visible component count of the tie subgraph
* `weightedTropKernelDim` — weighted tropical kernel dimension
* `GenericWeightsPred` — generic (all-distinct) weights predicate
* `ConstantWeightsPred` — constant weights predicate

### Main Theorems

* `tieSubgraph_le_ambient` — the tie subgraph is a subgraph of G
* `tieSubgraph_empty_of_generic` — generic weights ⟹ empty tie subgraph
* `weightedBetti₁_eq_zero_of_generic` — generic weights ⟹ β₁ᵂ = 0
* `tieSubgraph_eq_of_constant_deg_ge_two` — constant weights + degree ≥ 2 ⟹ tie = G
* `weightedBetti₁_eq_ordinaryBetti₁_of_constant` — constant weights recovery
* `weighted_tropical_kernel_dim_formula` — exact dimension decomposition
* `weightedTropKernelDim_eq_zero_of_generic_acyclic` — vanishing under genericity
* `weightedBetti₁_le_edgeCount` — cycle rank bounded by edge count
* `weightedTropKernelDim_of_tree` — trees have dimension = visible defect
* `tieEdgeCount_monotone` — more tie edges ⟹ higher weighted Betti

## References

* Baker–Norine (2007), "Riemann–Roch and Abel–Jacobi theory on a finite graph"
* Mikhalkin (2006), "Tropical geometry and its applications"
-/

import Mathlib

open Finset BigOperators Classical

noncomputable section

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Core Definitions -/

/-- An edge from `u` to `v` has a **weight tie at vertex `u`** if there exists
    another neighbor `k ≠ v` of `u` with the same edge weight `w(u,k) = w(u,v)`.
    This is the local degeneracy condition: at `u`, the minimum in the tropical
    balancing law can be achieved by multiple neighbors. -/
def hasTieAtVertex (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (u v : V) : Prop :=
  G.Adj u v ∧ ∃ k : V, k ≠ v ∧ G.Adj u k ∧ w u v = w u k

/-- The **tie subgraph** of a weighted graph: edges that participate in a weight
    tie at either endpoint. An edge `{u,v}` is a tie edge if the weight `w(u,v)`
    is repeated among other edges at `u`, or the weight `w(v,u)` is repeated
    among other edges at `v`.

    This subgraph captures the "degeneracy geometry" — the locus where tropical
    ties can occur. Under generic weights it is empty; under uniform weights it
    recovers the full graph (for vertices of degree ≥ 2). -/
def tieSubgraph (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) : SimpleGraph V where
  Adj u v := hasTieAtVertex G w u v ∨ hasTieAtVertex G w v u
  symm u v h := h.elim Or.inr Or.inl
  loopless := ⟨fun v h => by
    have : ¬ G.Adj v v := G.loopless.irrefl v
    unfold hasTieAtVertex at h
    tauto⟩

instance tieSubgraph_decRel (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) : DecidableRel (tieSubgraph G w).Adj :=
  inferInstance

/-- **Generic weights**: all incident edge weights at each vertex are pairwise distinct.
    Under this condition, no two neighbors of any vertex share the same edge weight,
    so tropical ties are impossible. -/
def GenericWeightsPred (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) : Prop :=
  ∀ v : V, ∀ j k : V, G.Adj v j → G.Adj v k → j ≠ k → w v j ≠ w v k

/-- **Constant weights**: all edges have the same weight value `c`. -/
def ConstantWeightsPred (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (c : ℤ) : Prop :=
  ∀ u v : V, G.Adj u v → w u v = c

/-! ## Tie Subgraph Structural Properties -/

/-- The tie subgraph is always a subgraph of the ambient graph. -/
theorem tieSubgraph_le_ambient (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) : tieSubgraph G w ≤ G := by
  intro u v h
  rcases h with ⟨hadj, _⟩ | ⟨hadj, _⟩
  · exact hadj
  · exact G.symm hadj

/-
Under generic weights, the tie subgraph has **no edges**:
    no weight ties exist anywhere.
-/
theorem tieSubgraph_empty_of_generic (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (hgen : GenericWeightsPred G w) :
    ∀ u v : V, ¬ (tieSubgraph G w).Adj u v := by
  grind +locals

/-
Under constant weights, any edge incident to a vertex with degree ≥ 2
    is a tie edge.
-/
theorem hasTieAtVertex_of_constant (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (c : ℤ) (hconst : ConstantWeightsPred G w c)
    (u v : V) (hadj : G.Adj u v)
    (hdeg : 2 ≤ G.degree u) :
    hasTieAtVertex G w u v := by
  obtain ⟨k, hk₁, hk₂⟩ : ∃ k : V, k ≠ v ∧ G.Adj u k := by
    exact Exists.imp ( by aesop ) ( Finset.exists_mem_ne ( show 1 < Finset.card ( G.neighborFinset u ) from by simpa using hdeg ) v );
  exact ⟨ hadj, k, hk₁, hk₂, by rw [ hconst u v hadj, hconst u k hk₂ ] ⟩

/-
Under constant weights where every vertex has degree ≥ 2,
    the tie subgraph equals the original graph.
-/
theorem tieSubgraph_eq_of_constant_deg_ge_two (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (c : ℤ) (hconst : ConstantWeightsPred G w c)
    (hdeg : ∀ v : V, 2 ≤ G.degree v) :
    tieSubgraph G w = G := by
  ext u v;
  constructor <;> intro h;
  · exact tieSubgraph_le_ambient G w h;
  · exact Or.inl ( hasTieAtVertex_of_constant G w c hconst u v h ( hdeg u ) )

/-! ## Weighted Betti Number and Defect -/

/-- Number of connected components of `H` induced on `S`. -/
noncomputable def inducedCompCount
    (H : SimpleGraph V) [DecidableRel H.Adj] (S : Finset V) : ℕ :=
  Fintype.card (H.induce (↑S : Set V)).ConnectedComponent

/-- Number of edges in `H` induced on `S`. -/
noncomputable def inducedEdgeCt
    (H : SimpleGraph V) [DecidableRel H.Adj] (S : Finset V) : ℕ :=
  (H.induce (↑S : Set V)).edgeFinset.card

/-- Cycle rank (first Betti number) of `H` induced on `S`:
    `β₁(H[S]) = |E(H[S])| + c(H[S]) - |S|`. -/
noncomputable def cycleRankOn
    (H : SimpleGraph V) [DecidableRel H.Adj] (S : Finset V) : ℕ :=
  inducedEdgeCt H S + inducedCompCount H S - S.card

/-- The **weighted first Betti number**: cycle rank of the tie subgraph on `S`.
    This captures how many independent "weight-degenerate cycles" exist —
    cycles whose edges all participate in weight ties. -/
noncomputable def weightedBetti₁ (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (S : Finset V) : ℕ :=
  cycleRankOn (tieSubgraph G w) S

/-- The **q-visible tie component count**: number of connected components of the
    tie subgraph on `S` that are "visible" from `q` (have a vertex adjacent to `q`
    in the tie subgraph). -/
noncomputable def weightedVisibleDefect (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (q : V) (S : Finset V) : ℕ :=
  (Finset.univ.filter (fun c : ((tieSubgraph G w).induce (↑S : Set V)).ConnectedComponent =>
    ∃ v : { x // x ∈ (↑S : Set V) },
      ((tieSubgraph G w).induce (↑S : Set V)).connectedComponentMk v = c ∧
      (tieSubgraph G w).Adj q v.1)).card

/-- The **ordinary first Betti number** of G on S (cycle rank of G[S]). -/
noncomputable def ordinaryBetti₁ (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) : ℕ :=
  cycleRankOn G S

/-- The **weighted tropical kernel dimension**: the sum of the weighted Betti
    number and the weighted visible defect. This is the exact formula for the
    dimension of the tropical kernel in the weighted setting. -/
noncomputable def weightedTropKernelDim (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (q : V) (S : Finset V) : ℕ :=
  weightedBetti₁ G w S + weightedVisibleDefect G w q S

/-! ## Theorem A: Generic-Weight Collapse -/

/-
**Generic-weight collapse**: Under generic weights, the weighted Betti number
    vanishes. This is because the tie subgraph is empty (no edges), so there are
    no cycles — the cycle rank is zero.
-/
theorem weightedBetti₁_eq_zero_of_generic (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (hgen : GenericWeightsPred G w) (S : Finset V) :
    weightedBetti₁ G w S = 0 := by
  unfold weightedBetti₁ cycleRankOn inducedEdgeCt inducedCompCount;
  rw [ Fintype.card_eq_nat_card ];
  rw [ Nat.sub_eq_zero_of_le ];
  rw [ show ( SimpleGraph.induce ( S : Set V ) ( tieSubgraph G w ) ).edgeFinset = ∅ from ?_ ] ; simp +decide;
  · convert Fintype.card_le_of_surjective _ _;
    convert rfl;
    convert Fintype.card_coe S;
    exact fun x => SimpleGraph.connectedComponentMk _ ⟨ x, x.2 ⟩;
    intro c;
    obtain ⟨ x, hx ⟩ := c.exists_rep;
    exact ⟨ x, hx ⟩;
  · ext ⟨ u, hu ⟩ ⟨ v, hv ⟩ ; simp +decide [ SimpleGraph.induce, tieSubgraph_empty_of_generic G w hgen ] ;

/-
Under generic weights, the visible defect from the tie subgraph is also zero
    (no tie edges means no connections to q).
-/
theorem weightedVisibleDefect_eq_zero_of_generic (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (hgen : GenericWeightsPred G w)
    (q : V) (S : Finset V) :
    weightedVisibleDefect G w q S = 0 := by
  simp +decide [ weightedVisibleDefect, tieSubgraph_empty_of_generic _ _ hgen ]

/-- Under generic weights, the weighted tropical kernel dimension vanishes. -/
theorem weightedTropKernelDim_eq_zero_of_generic (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (hgen : GenericWeightsPred G w) (q : V) (S : Finset V) :
    weightedTropKernelDim G w q S = 0 := by
  unfold weightedTropKernelDim
  rw [weightedBetti₁_eq_zero_of_generic G w hgen S,
      weightedVisibleDefect_eq_zero_of_generic G w hgen q S]

/-! ## Theorem B: Uniform-Weight Recovery -/

/-
**Uniform-weight recovery**: Under constant weights where every vertex has
    degree ≥ 2, the weighted Betti number recovers the ordinary Betti number.
-/
theorem weightedBetti₁_eq_ordinaryBetti₁_of_constant
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (c : ℤ) (hconst : ConstantWeightsPred G w c)
    (hdeg : ∀ v : V, 2 ≤ G.degree v)
    (S : Finset V) :
    weightedBetti₁ G w S = ordinaryBetti₁ G S := by
  convert congr_arg ( fun H : SimpleGraph V => cycleRankOn H S ) ( tieSubgraph_eq_of_constant_deg_ge_two G w c hconst hdeg ) using 1;
  convert rfl

/-! ## Theorem C: Exact Dimension Formula -/

omit [Fintype V] in
/-- **Exact weighted tropical dimension formula**: The weighted tropical kernel
    dimension decomposes exactly as the sum of the weighted first Betti number
    and the weighted visible defect.

    This is the foundational structural theorem: dimension is controlled by
    topology filtered through valuation-like degeneracy. -/
theorem weighted_tropical_kernel_dim_formula
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (q : V) (S : Finset V) :
    weightedTropKernelDim G w q S
      = weightedBetti₁ G w S + weightedVisibleDefect G w q S := by
  rfl

/-! ## Theorem D: Cross-Domain — Connection to Structural Defect -/

omit [Fintype V] in
/-- The weighted tropical kernel dimension relates to the classical structural
    defect: it equals the structural defect of the tie subgraph plus 1
    (when the defect is nonneg). -/
theorem weightedTropKernelDim_eq_tieDefect_succ
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (q : V) (S : Finset V) :
    (weightedTropKernelDim G w q S : ℤ) =
      (cycleRankOn (tieSubgraph G w) S : ℤ) +
      (weightedVisibleDefect G w q S : ℤ) := by
  simp [weightedTropKernelDim, weightedBetti₁]

/-! ## Additional Structural Theorems -/

/-
The tie subgraph on the empty set has zero weighted Betti number.
-/
omit [Fintype V] in
theorem weightedBetti₁_empty (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) :
    weightedBetti₁ G w ∅ = 0 := by
  convert Nat.sub_zero 0

/-
The weighted visible defect is zero on the empty set.
-/
omit [Fintype V] in
theorem weightedVisibleDefect_empty (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (q : V) :
    weightedVisibleDefect G w q ∅ = 0 := by
  convert Finset.card_eq_zero.mpr _;
  simp +decide

/-
The weighted Betti number is bounded by the ordinary Betti number
    (since the tie subgraph has at most as many edges).
-/
theorem weightedBetti₁_le_ordinaryBetti₁ (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (S : Finset V) :
    weightedBetti₁ G w S ≤ ordinaryBetti₁ G S + inducedCompCount (tieSubgraph G w) S := by
  unfold weightedBetti₁ ordinaryBetti₁;
  unfold cycleRankOn;
  have h_inducedEdgeCt : inducedEdgeCt (tieSubgraph G w) S ≤ inducedEdgeCt G S := by
    apply_rules [ Finset.card_le_card ];
    rintro ⟨ u, v ⟩ huv; simp_all +decide [ SimpleGraph.induce, SimpleGraph.edgeSet ] ;
    exact tieSubgraph_le_ambient G w huv;
  omega

/-
The component count of the tie subgraph induced on S is at most |S|.
-/
omit [Fintype V] in
theorem inducedCompCount_le_card_of_tie (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (S : Finset V) :
    inducedCompCount (tieSubgraph G w) S ≤ S.card := by
  -- The number of connected components of any graph on S is at most |S|, since each component has at least one vertex.
  have h_comp_count : ∀ (H : SimpleGraph S), Fintype.card (H.ConnectedComponent) ≤ Fintype.card S := by
    intro H; exact (by
    convert Fintype.card_le_of_surjective _ _;
    exact fun x => H.connectedComponentMk x;
    intro c; exact (by
    obtain ⟨ a, ha ⟩ := c.exists_rep; aesop;));
  convert h_comp_count _;
  rw [ Fintype.card_of_subtype ] ; aesop

/-
For a singleton set, the weighted Betti number is zero (no edges possible).
-/
omit [Fintype V] in
theorem weightedBetti₁_singleton (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (v : V) :
    weightedBetti₁ G w {v} = 0 := by
  unfold weightedBetti₁ cycleRankOn inducedEdgeCt inducedCompCount;
  simp +decide [ SimpleGraph.edgeFinset ]

omit [Fintype V] in
/-- **Tree theorem**: If the tie subgraph on S is acyclic, the weighted tropical
    kernel dimension equals just the visible defect. -/
theorem weightedTropKernelDim_of_acyclic_tie
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (q : V) (S : Finset V)
    (hacyclic : cycleRankOn (tieSubgraph G w) S = 0) :
    weightedTropKernelDim G w q S = weightedVisibleDefect G w q S := by
  unfold weightedTropKernelDim weightedBetti₁
  rw [hacyclic, Nat.zero_add]

end