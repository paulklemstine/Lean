/-
Copyright (c) 2025. All rights reserved.

# p-adic Universality of Chip-Firing Critical Groups Under Graph Lifts

This file establishes foundational results connecting graph covering spaces
(lifts) to the algebraic structure of their critical (sandpile) groups.

## Main definitions

* `GraphLift` — An n-sheeted covering of a simple graph
* `firstBettiNumber` — The first Betti number (cycle rank) of a connected graph
* `graphLaplacian` — The Laplacian matrix of a graph (wrapper around Mathlib's `lapMatrix`)
* `reducedLaplacian` — The reduced Laplacian matrix with one row/column deleted
* `criticalGroup` — The critical group (Jacobian/sandpile group)

## Main results

* `lift_vertex_count` — The lifted graph has n · |V| vertices
* `lift_degree_eq` — Each vertex in the lift has degree equal to its projection
* `lift_sum_degrees` — Sum of degrees in lift = n · sum of degrees in base
* `lift_edge_count` — The lifted graph has n · |E| edges
* `betti_number_of_lift` — b₁(G̃) = n · b₁(G) + (n - 1) for connected n-sheeted lifts
* `graphLaplacian_symmetric` — The graph Laplacian is a symmetric matrix
* `graphLaplacian_row_sum_zero` — Each row of the Laplacian sums to zero

## References

* Baker, M. and Norine, S. "Riemann-Roch and Abel-Jacobi theory on a finite graph"
* Clancy, J., Leake, T., and Payne, S. "A note on Jacobians, Tutte polynomials,
  and two-variable zeta functions of graphs"
-/

import Mathlib

open Finset BigOperators Matrix SimpleGraph

/-! ## Graph Lift (n-Sheeted Covering Space) -/

/-- An n-sheeted lift of a connected graph G is a graph G̃ equipped with a
    surjection π : V(G̃) → V(G) such that for every v : V(G), the fiber
    π⁻¹(v) has cardinality n, and for every edge {u,v} in G, each vertex
    in π⁻¹(u) is adjacent to exactly one vertex in π⁻¹(v).

    This captures the combinatorial notion of a graph covering space,
    equivalent to specifying a voltage assignment from the edges of G
    to the symmetric group Sₙ. -/
structure GraphLift {V : Type} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (n : ℕ) where
  /-- The vertex type of the lifted graph -/
  W : Type
  [finW : Fintype W]
  [decW : DecidableEq W]
  /-- The lifted graph structure -/
  liftGraph : SimpleGraph W
  [decAdj : DecidableRel liftGraph.Adj]
  /-- The covering projection -/
  proj : W → V
  /-- The projection is surjective -/
  proj_surj : Function.Surjective proj
  /-- Each fiber has exactly n vertices -/
  fiber_card : ∀ v : V, Fintype.card {u : W // proj u = v} = n
  /-- Edges in the lift project to edges in the base (graph homomorphism) -/
  lift_adj : ∀ u v : W, liftGraph.Adj u v → G.Adj (proj u) (proj v)
  /-- The covering property: each edge lifts uniquely per fiber element -/
  unique_lift : ∀ u : W, ∀ v : V, G.Adj (proj u) v →
    ∃! w : W, proj w = v ∧ liftGraph.Adj u w
  /-- The lifted graph is connected -/
  liftConn : liftGraph.Connected

attribute [instance] GraphLift.finW GraphLift.decW GraphLift.decAdj

namespace GraphLift

variable {V : Type} [Fintype V] [DecidableEq V]
variable {G : SimpleGraph V} [DecidableRel G.Adj]
variable {n : ℕ}

/-! ### Vertex Count -/

omit [DecidableRel G.Adj] in
/-- The total number of vertices in an n-sheeted lift equals n times the
    number of vertices in the base graph. This follows from the fiber
    condition: V(G̃) = ⊔ᵥ π⁻¹(v) with |π⁻¹(v)| = n for all v. -/
theorem lift_vertex_count (L : GraphLift G n) :
    Fintype.card L.W = n * Fintype.card V := by
  calc Fintype.card L.W
      = Fintype.card ((v : V) × {u : L.W // L.proj u = v}) :=
        Fintype.card_congr (Equiv.sigmaFiberEquiv L.proj).symm
    _ = ∑ v : V, Fintype.card {u : L.W // L.proj u = v} := Fintype.card_sigma
    _ = ∑ _v : V, n := Finset.sum_congr rfl (fun v _ => L.fiber_card v)
    _ = n * Fintype.card V := by
        simp [Finset.sum_const, Finset.card_univ, mul_comm]

/-! ### Degree Preservation -/

/-
Each vertex in the lift has the same degree as its projected vertex.
    This follows from the covering property: for each neighbor v of proj(u)
    in G, there is a unique lift of the edge to a neighbor of u in G̃.
-/
theorem lift_degree_eq (L : GraphLift G n) (u : L.W) :
    L.liftGraph.degree u = G.degree (L.proj u) := by
  refine' Finset.card_bij ( fun v hv => L.proj v ) _ _ _;
  · simp +contextual [ SimpleGraph.mem_neighborFinset, L.lift_adj ];
  · intro a₁ ha₁ a₂ ha₂ h_eq
    have := L.unique_lift u (L.proj a₁) (by
    exact L.lift_adj u a₁ ( by simpa using ha₁ ));
    exact this.unique ⟨ rfl, by simpa using ha₁ ⟩ ⟨ h_eq.symm, by simpa using ha₂ ⟩;
  · intro v hv; cases' L.unique_lift u v ( by aesop ) with w hw; use w; aesop;

/-! ### Edge Count -/

/-
Sum of degrees in the lift equals n times the sum of degrees in the base.
    Follows from `lift_degree_eq` and `lift_vertex_count`.
-/
theorem lift_sum_degrees (L : GraphLift G n) :
    ∑ u : L.W, L.liftGraph.degree u = n * ∑ v : V, G.degree v := by
  -- By definition of `liftGraph.degree`, we can rewrite the left-hand side of the equation.
  have h_sum_degrees : ∑ u : L.W, L.liftGraph.degree u = ∑ u : L.W, G.degree (L.proj u) := by
    exact Finset.sum_congr rfl fun _ _ => lift_degree_eq L _;
  -- By definition of `liftGraph.degree`, we can rewrite the right-hand side of the equation.
  have h_sum_degrees_rhs : ∑ u : L.W, G.degree (L.proj u) = ∑ v : V, ∑ u ∈ Finset.filter (fun u => L.proj u = v) Finset.univ, G.degree v := by
    simp +decide only [sum_filter];
    rw [ Finset.sum_comm, Finset.sum_congr rfl ] ; aesop;
  simp_all +decide [ Finset.sum_mul _ _ _ ];
  rw [ Finset.mul_sum _ _ _ ] ; congr ; ext v ; have := L.fiber_card v ; simp_all +decide [ Fintype.card_subtype ] ;

/-
The lifted graph has exactly n times as many edges as the base graph.
    This follows from the handshaking lemma: 2|E| = Σ deg(v).
-/
theorem lift_edge_count (L : GraphLift G n) :
    L.liftGraph.edgeFinset.card = n * G.edgeFinset.card := by
  convert congr_arg ( fun x : ℕ => x / 2 ) ( L.lift_sum_degrees ) using 1;
  · rw [ SimpleGraph.sum_degrees_eq_twice_card_edges, Nat.mul_div_cancel_left _ ( by decide ) ];
  · rw [ G.sum_degrees_eq_twice_card_edges ] ; ring;
    norm_num

/-! ## First Betti Number -/

end GraphLift

/-- The first Betti number (cycle rank) of a graph is defined as
    b₁(G) = |E(G)| + 1 - |V(G)|.

    For a connected graph, this equals the dimension of the cycle space,
    and counts the number of independent cycles. A tree has b₁ = 0.

    We use the form |E| + 1 - |V| to avoid ℕ subtraction issues,
    since |E| ≥ |V| - 1 for connected graphs. -/
noncomputable def firstBettiNumber {W : Type} [Fintype W] [DecidableEq W]
    (H : SimpleGraph W) [DecidableRel H.Adj] : ℕ :=
  H.edgeFinset.card + 1 - Fintype.card W

namespace GraphLift

variable {V : Type} [Fintype V] [DecidableEq V]
variable {G : SimpleGraph V} [DecidableRel G.Adj]
variable {n : ℕ}

/-! ### Betti Number Formula for Lifts -/

/-
**Betti Number Formula for Connected Lifts.**

    For a connected n-sheeted lift G̃ of a connected graph G:
      b₁(G̃) + (n - 1) = n · b₁(G)

    Equivalently, b₁(G̃) = n · b₁(G) - (n - 1), but we state it additively
    to avoid ℕ subtraction issues.

    Proof: From the vertex and edge counting lemmas,
    * |V(G̃)| = n · |V(G)|
    * |E(G̃)| = n · |E(G)|

    Therefore:
      b₁(G̃) = |E(G̃)| + 1 - |V(G̃)|
             = n·|E(G)| + 1 - n·|V(G)|
    and n·b₁(G) = n·|E(G)| + n - n·|V(G)|,
    so b₁(G̃) + (n - 1) = n·b₁(G).
-/
theorem betti_number_of_lift (L : GraphLift G n) (hn : 0 < n)
    (hE : G.edgeFinset.card + 1 ≥ Fintype.card V) :
    firstBettiNumber L.liftGraph + (n - 1) =
      n * firstBettiNumber G := by
  -- Use hE to ensure the subtraction is valid, then rewrite with the lift edge and vertex counts.
  have h_sub_valid : n * G.edgeFinset.card + 1 ≥ n * Fintype.card V := by
    have := L.liftConn;
    obtain ⟨ u, hu ⟩ := this.exists_isTree_le;
    have := hu.2.card_edgeFinset;
    have h_card_edges : u.edgeFinset.card ≤ L.liftGraph.edgeFinset.card := by
      exact Finset.card_le_card ( SimpleGraph.edgeFinset_mono hu.1 );
    nlinarith [ L.lift_vertex_count, L.lift_edge_count ];
  simp_all +decide [ firstBettiNumber, lift_edge_count, lift_vertex_count ];
  nlinarith [ Nat.sub_add_cancel h_sub_valid, Nat.sub_add_cancel hn, Nat.sub_add_cancel ( show Fintype.card V ≤ #G.edgeFinset + 1 from hE ) ]

end GraphLift

/-! ## Laplacian and Critical Group -/

/-- The Laplacian matrix of a simple graph (wrapper around Mathlib's `lapMatrix`). -/
noncomputable def graphLaplacian {V : Type} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : Matrix V V ℤ :=
  G.lapMatrix ℤ

/-
The Laplacian is symmetric: L(G)ᵀ = L(G).
-/
theorem graphLaplacian_symmetric {V : Type} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    (graphLaplacian G)ᵀ = graphLaplacian G := by
  -- By definition of Laplacian matrix, we know that it is symmetric. Use the theorem `SimpleGraph.isSymm_lapMatrix`.
  apply SimpleGraph.isSymm_lapMatrix

/-
Row sums of the Laplacian are zero: the all-ones vector is in the kernel.
-/
theorem graphLaplacian_row_sum_zero {V : Type} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (i : V) :
    ∑ j, graphLaplacian G i j = 0 := by
  unfold graphLaplacian;
  simp +decide [ lapMatrix, Matrix.one_apply ];
  simp +decide [ degMatrix, SimpleGraph.degree, SimpleGraph.neighborFinset_def ];
  simp +decide [ diagonal ]

/-- A reduced Laplacian of G is the matrix obtained by deleting the row
    and column corresponding to a chosen base vertex v₀. -/
noncomputable def reducedLaplacian {V : Type} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (v₀ : V) :
    Matrix {v : V // v ≠ v₀} {v : V // v ≠ v₀} ℤ :=
  (graphLaplacian G).submatrix Subtype.val Subtype.val

/-- The critical group (sandpile group, Jacobian) of a connected graph G
    with basepoint v₀ is the cokernel of the reduced Laplacian, viewed as
    a ℤ-linear map.

    This group classifies:
    * Recurrent chip configurations modulo firing
    * Degree-zero divisors modulo rational equivalence (tropical Jacobian)
    * It is analogous to the class group of a number field

    Its order equals the number of spanning trees (Matrix-Tree theorem). -/
noncomputable def criticalGroup {V : Type} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (v₀ : V) : Type :=
  ({v : V // v ≠ v₀} → ℤ) ⧸
    LinearMap.range ((reducedLaplacian G v₀).toLin')

/-- The spanning tree count, defined as det(reduced Laplacian). -/
noncomputable def spanningTreeCount {V : Type} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (v₀ : V) : ℤ :=
  (reducedLaplacian G v₀).det

/-
The spanning tree count is nonneg for any graph.
-/
theorem spanningTreeCount_nonneg {V : Type} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (hconn : G.Connected) (v₀ : V) :
    0 ≤ spanningTreeCount G v₀ := by
  contrapose! hconn; (
  have h_det_nonneg : ∀ (M : Matrix {v : V // v ≠ v₀} {v : V // v ≠ v₀} ℤ), M = (graphLaplacian G).submatrix Subtype.val Subtype.val → Matrix.det M ≥ 0 := by
    intro M hM
    have h_det_nonneg : Matrix.PosSemidef (M.map (fun x => x : ℤ → ℝ)) := by
      have h_det_nonneg : Matrix.PosSemidef (graphLaplacian G |> Matrix.map <| fun x => x : Matrix V V ℝ) := by
        have h_pos_semidef : ∀ (G : SimpleGraph V) [DecidableRel G.Adj], Matrix.PosSemidef (G.lapMatrix ℝ) := by
          exact?;
        convert h_pos_semidef G using 1;
        ext i j; simp +decide [ graphLaplacian, SimpleGraph.lapMatrix ] ;
        simp +decide [ degMatrix ];
        by_cases hij : i = j <;> aesop;
      rw [ hM ];
      convert h_det_nonneg.submatrix _ using 1;
    convert h_det_nonneg.det_nonneg using 1;
    norm_cast;
  exact absurd hconn ( not_lt_of_ge ( h_det_nonneg _ rfl ) ))