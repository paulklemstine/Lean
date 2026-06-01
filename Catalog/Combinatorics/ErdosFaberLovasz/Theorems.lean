/-
# Erdős–Faber–Lovász Conjecture: Theorems

This file proves several structural results about EFL systems:

1. The incidence count of any EFL system equals k².
2. The Fisher-type pair-sharing inequality.
3. Degree bound: every vertex has degree ≤ k.
4. High-degree vertex bound: at most k(k-1)/2 vertices have degree ≥ 2.
5. EFL base case (k = 0).
-/
import Mathlib
import Combinatorics.ErdosFaberLovasz.Defs

open Finset Function

namespace EFL

/-! ## Theorem 1: Incidence Count = k²

The total number of vertex-edge incidences in an EFL system with parameter k is k².
This follows directly from k-uniformity: each of the k edges has exactly k vertices. -/

/-
The incidence count of an EFL system with parameter k is exactly k².
-/
theorem incidence_count_eq_sq {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) : S.incidenceCount = S.k ^ 2 := by
  convert Finset.sum_congr rfl fun i _ => S.uniform i using 1 ; simp +decide [ sq ]

/-! ## Theorem 2: Pair-Sharing Bound (Fisher-type inequality)

In an EFL system, the total pairwise intersection size
(summing |eᵢ ∩ eⱼ| over ordered pairs i ≠ j) is at most k*(k-1).
This follows from linearity: each term |eᵢ ∩ eⱼ| ≤ 1,
and there are k*(k-1) ordered pairs. -/

/-
The total pairwise intersection size is bounded by k*(k-1).
-/
theorem pairwise_intersection_sum_bound {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) :
    (∑ i : Fin S.k, (Finset.univ.filter (fun j => j ≠ i)).sum
      (fun j => (S.edges i ∩ S.edges j).card))
      ≤ S.k * (S.k - 1) := by
  convert Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => S.linear i j _;
  · simp +decide [ Finset.filter_ne' ];
  · aesop

/-! ## Theorem 3: EFL Base Case (k = 0) -/

/-
Any EFL system with k = 0 is trivially colorable (there are no edges to color).
-/
theorem efl_zero {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) (hk : S.k = 0) : S.IsKColorable := by
  use fun _ => 0;
  simp +decide [ hk, System.IsStrongColoring, System.vertexSet ];
  cases S ; aesop

/-! ## Theorem 4: Degree Bound

The degree of any vertex in an EFL system is at most k.
If a vertex v appears in d edges, those d edges pairwise intersect at v,
and by linearity each pair shares at most 1 vertex. The d edges each have
k elements, and v is in all of them, so we use the structure of linear k-uniform
families. In fact, degree ≤ k follows because there are only k edges total. -/

/-
The degree of any vertex in an EFL system is at most k.
-/
theorem degree_le_k {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) (v : V) : S.degree v ≤ S.k := by
  exact le_trans ( Finset.card_le_univ _ ) ( by simp +decide )

/-! ## Theorem 5: High-Degree Vertex Bound

The number of vertices with degree ≥ 2 in an EFL system is at most k*(k-1)/2.
Each such vertex accounts for at least one pair of edges sharing a vertex,
and by linearity, each pair of edges shares at most 1 vertex. Hence the
number of sharing vertices is bounded by the number of edge pairs. -/

/-- The set of vertices with degree ≥ 2, which are shared between multiple edges. -/
def System.highDegreeVertices {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) : Finset V :=
  Finset.univ.filter (fun v => 2 ≤ S.degree v)

/-
Each vertex of degree ≥ 2 gives rise to a pair of edges sharing that vertex.
    Since the hypergraph is linear, each edge pair shares at most one vertex.
    Hence, the number of high-degree vertices is bounded by the number of edge pairs.
-/
theorem high_degree_vertex_bound {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) :
    S.highDegreeVertices.card ≤ S.k * (S.k - 1) / 2 := by
  -- By definition of $highDegreeVertices$, we know that each vertex in this set is contained in at least two edges.
  have h_high_degree_vertices : ∀ v ∈ S.highDegreeVertices, (Finset.univ.filter (fun i => v ∈ S.edges i)).card ≥ 2 := by
    -- By definition of `highDegreeVertices`, if `v` is in this set, then `2 ≤ S.degree v`.
    intros v hv
    rw [System.highDegreeVertices] at hv
    aesop;
  -- Consider the set of pairs {(v, {i,j}) | v ∈ edges i edges j, i < j}. For each high-degree vertex v, there's at least one such pair.
  have h_pairs : (S.highDegreeVertices.biUnion (fun v => Finset.powersetCard 2 (Finset.univ.filter (fun i => v ∈ S.edges i)))).card ≤ Nat.choose S.k 2 := by
    exact le_trans ( Finset.card_le_card <| Finset.biUnion_subset.mpr fun v hv => Finset.powersetCard_mono <| Finset.subset_univ _ ) <| by simp +decide [ Nat.choose_two_right ] ;
  rw [ Finset.card_biUnion ] at h_pairs;
  · simp_all +decide [ Nat.choose_two_right ];
    refine' le_trans _ h_pairs;
    exact le_trans ( by norm_num ) ( Finset.sum_le_sum fun x hx => Nat.div_pos ( by nlinarith only [ h_high_degree_vertices x hx, Nat.sub_add_cancel ( by linarith only [ h_high_degree_vertices x hx ] : 1 ≤ Finset.card ( Finset.filter ( fun i => x ∈ S.edges i ) Finset.univ ) ) ] ) zero_lt_two );
  · intros v hv w hw hvw;
    simp +decide [ Finset.disjoint_left ];
    intro a ha₁ ha₂ ha; have := Finset.card_eq_two.mp ha₂; obtain ⟨ i, j, hij, rfl ⟩ := this; simp_all +decide [ Finset.subset_iff ] ;
    have := S.linear i j hij; simp_all +decide [ Finset.card_le_one ] ;
    exact hvw ( this _ ha₁.1 ha₁.2 _ ha.1 ha.2 )

/-! ## Key Structural Lemma: Edges of an EFL system are distinct for k ≥ 2

For k ≥ 2, any two edges indexed by different indices must be different sets.
This follows because if edges i = edges j, then |edges i ∩ edges j| = k ≥ 2,
contradicting linearity. -/

/-
For k ≥ 2, distinct indices give distinct edges.
-/
theorem edges_injective_of_k_ge_two {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) (hk : 2 ≤ S.k) : Injective S.edges := by
  intro i j hij;
  have := S.linear i j;
  by_cases h : i = j <;> simp_all +decide [ Finset.inter_self ];
  linarith [ S.uniform j ]

/-! ## The EFL Conjecture Statement -/

/-- **Erdős–Faber–Lovász Conjecture**: Every EFL system with parameter k
    admits a strong coloring with k colors.

    This was proved for sufficiently large k by Kang–Kelly–Kühn–Methuku–Osthus (2021).
    The full conjecture for all k remains formally unverified. -/
theorem efl_conjecture {V : Type*} [DecidableEq V] [Fintype V]
    (S : System V) : S.IsKColorable := by
  sorry

end EFL