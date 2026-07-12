/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Circuit Lower Bounds: Main Theorems

## Overview

This file proves the main bridge theorems connecting tropical matrix invariants
to circuit depth lower bounds. The central results establish that:

1. Layered circuit matrices have zero diagonal (tropical singularity)
2. Paths in layered matrices are strictly increasing (DAG property)
3. Path lengths are bounded by the matrix dimension
4. Path costs are controlled by edge weight bounds
5. The min-plus permanent equals zero for layered matrices
6. The min-plus permanent is bounded by the trace
7. Families with growing minimum edge weight have constrained depth

## The Bridge

The fundamental bridge theorem schema is:

  **tropical matrix invariant** ⟹ **depth lower bound**

Concretely: if all edges in a layered circuit matrix have weight ≥ w,
then any computation path of d steps incurs total cost ≥ w · d.
Contrapositive: bounded total cost implies bounded depth.

## Keywords

circuit lower bounds, tropical spectral theory, min-plus permanent,
idempotent linear algebra, structural complexity, depth lower bounds,
layered DAG semantics, assignment obstruction, formal verification
-/

import Mathlib
import Logic.Defs

namespace TropicalCircuit

/-! ## Layered Matrix Properties -/

/-
Layered matrices have zero diagonal: no self-loops in the DAG.
-/
theorem IsLayered.diag_eq_zero {n : ℕ} {M : Matrix (Fin n) (Fin n) ℕ}
    (hM : IsLayered M) (i : Fin n) : M i i = 0 := by
  exact Nat.eq_zero_of_not_pos fun hi => lt_irrefl i <| hM i i hi

/-
Layered matrices are strictly upper triangular: M i j = 0 when j ≤ i.
-/
theorem IsLayered.eq_zero_of_ge {n : ℕ} {M : Matrix (Fin n) (Fin n) ℕ}
    (hM : IsLayered M) {i j : Fin n} (hij : j ≤ i) : M i j = 0 := by
  exact Nat.eq_zero_of_not_pos fun h => not_lt_of_ge hij <| hM i j h

/-! ## Path Properties -/

/-
In a layered matrix, paths are strictly increasing: the Chain' relation
holds with (<) on the path vertices. This is the DAG property.
-/
theorem IsLayered.path_chain_lt {n : ℕ} {M : Matrix (Fin n) (Fin n) ℕ}
    (hM : IsLayered M) {p : List (Fin n)} (hp : IsPath M p) :
    p.Chain' (· < ·) := by
  induction p <;> simp_all +decide [ List.Chain' ];
  induction' ‹List ( Fin n ) › with a b ih <;> simp_all +decide [ IsPath ];
  exact hM _ _ hp.1

/-
A strictly increasing chain of elements of Fin n has length at most n.
This is a combinatorial pigeonhole argument.
-/
theorem chain_lt_length_le_of_fin {n : ℕ} {p : List (Fin n)}
    (hp : p.Chain' (· < ·)) : p.length ≤ n := by
  have := List.toFinset_card_of_nodup ( List.isChain_iff_pairwise.mp hp ).nodup;
  exact this ▸ le_trans ( Finset.card_le_univ _ ) ( by simpa )

/-- **Path Length Bound**. In a layered matrix of dimension n,
every admissible path has at most n vertices (hence at most n-1 edges).
This is the fundamental depth upper bound for layered circuits. -/
theorem path_length_le_n {n : ℕ} {M : Matrix (Fin n) (Fin n) ℕ}
    (hM : IsLayered M) {p : List (Fin n)} (hp : IsPath M p) :
    p.length ≤ n :=
  chain_lt_length_le_of_fin (hM.path_chain_lt hp)

/-! ## Path Cost Bounds -/

/-
pathEdges equals length - 1 for nonempty lists.
-/
theorem pathEdges_eq {α : Type*} (a : α) (rest : List α) :
    pathEdges (a :: rest) = rest.length := by
  induction' rest with b rest ihizing a <;> simp_all +arith +decide [ pathEdges ];
  cases rest <;> simp_all +arith +decide [ pathEdges ]

/-
Path cost is bounded above by maxWeight × number of edges.
-/
theorem pathCost_le_mul {n : ℕ} {M : Matrix (Fin n) (Fin n) ℕ}
    {W : ℕ} (hW : ∀ i j : Fin n, M i j ≤ W)
    {p : List (Fin n)} (hp : IsPath M p) :
    pathCost M p ≤ W * (p.length - 1) := by
  induction' p with a p ih;
  · rfl;
  · rcases p with ( _ | ⟨ b, p ⟩ ) <;> simp_all +decide [ Nat.mul_succ ];
    · rfl;
    · exact le_trans ( add_le_add ( hW _ _ ) ( ih <| by cases hp ; tauto ) ) ( by linarith )

/-
**Minimum Weight Lower Bound on Path Cost**. If every edge in the
support of M has weight at least w, then any admissible path of d+1
vertices has cost at least w · d. This is the core tropical obstruction:
expensive edges force high total computation cost.
-/
theorem pathCost_ge_minWeight_mul {n : ℕ} {M : Matrix (Fin n) (Fin n) ℕ}
    {w : ℕ} (hw : ∀ i j : Fin n, 0 < M i j → w ≤ M i j)
    {p : List (Fin n)} (hp : IsPath M p) :
    w * (p.length - 1) ≤ pathCost M p := by
  induction' p with a p ih;
  · grind;
  · rcases p with ( _ | ⟨ b, p ⟩ ) <;> simp_all +decide [ pathCost ];
    linarith [ hw a b ( hp.1 ), ih hp.2 ]

/-! ## Min-Plus Permanent Results -/

/-
The min-plus permanent is at most the cost of any specific permutation.
-/
theorem minPlusPerm_le_permCost {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ)
    (σ : Equiv.Perm (Fin n)) :
    minPlusPerm M ≤ permCost M σ := by
  exact Finset.inf'_le _ ( Finset.mem_univ _ )

/-
**Min-Plus Permanent ≤ Trace**. The min-plus permanent is at most the
trace (sum of diagonal entries), since the identity permutation achieves
that cost.
-/
theorem minPlusPerm_le_trace {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ) :
    minPlusPerm M ≤ ∑ i, M i i := by
  convert minPlusPerm_le_permCost M ( Equiv.refl ( Fin n ) ) using 1

/-
**Layered Zero Permanent**. For layered matrices, the min-plus permanent
is zero. This is because the identity permutation has cost zero (all
diagonal entries are zero by the layered condition).

This establishes that layered circuit matrices are "tropically singular":
there exists a zero-cost assignment. The interesting tropical obstructions
come from *restricted* permanents or from path cost analysis.
-/
theorem minPlusPerm_eq_zero_of_layered {n : ℕ} {M : Matrix (Fin n) (Fin n) ℕ}
    (hM : IsLayered M) : minPlusPerm M = 0 := by
  exact le_antisymm ( le_trans ( minPlusPerm_le_trace M ) ( by simp +decide [ IsLayered.diag_eq_zero hM ] ) ) bot_le

/-! ## Bridge Theorems -/

/-
**Tropical Bridge Theorem (Path Cost Version)**.
For layered circuit matrices where all edges have weight ≥ w,
any path of length d+1 has cost at least w · d.
Combined with the path length bound (≤ n), this gives:
- depth ≤ n - 1
- total path cost ≥ w · depth
- hence: depth ≤ (total path cost) / w

This is the fundamental bridge: a tropical algebraic quantity (minimum edge
weight, which is a spectral-gap surrogate) controls computational depth.
-/
theorem tropical_bridge_path_cost {n : ℕ} {M : Matrix (Fin n) (Fin n) ℕ}
    (hM : IsLayered M)
    {w : ℕ} (hw : ∀ i j : Fin n, 0 < M i j → w ≤ M i j)
    {p : List (Fin n)} (hp : IsPath M p)
    {d : ℕ} (hd : p.length = d + 1) :
    w * d ≤ pathCost M p ∧ d ≤ n - 1 := by
  exact ⟨ by simpa [ hd ] using pathCost_ge_minWeight_mul hw hp, Nat.le_sub_one_of_lt <| by linarith [ path_length_le_n hM hp ] ⟩

/-
**Min-Plus Permanent Upper Bound**.
The min-plus permanent of any matrix is at most n × (maximum entry).
This provides an upper bound on the assignment obstruction.
-/
theorem minPlusPerm_le_n_mul_max {n : ℕ} (M : Matrix (Fin n) (Fin n) ℕ)
    {W : ℕ} (hW : ∀ i j : Fin n, M i j ≤ W) :
    minPlusPerm M ≤ n * W := by
  exact le_trans ( minPlusPerm_le_permCost M ( Equiv.refl ( Fin n ) ) ) ( by simpa using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => hW i ( i ) )

/-! ## Explicit Family Theorems -/

/-- **Explicit Family Depth Bound**.
For a family of layered matrices indexed by k, where the k-th matrix is
(F k).1 × (F k).1 and every path has at most (F k).1 vertices: -/
theorem family_path_length_bound
    (F : ℕ → (n : ℕ) × Matrix (Fin n) (Fin n) ℕ)
    (h_layered : ∀ k, IsLayered (F k).2) :
    ∀ k, ∀ p : List (Fin (F k).1), IsPath (F k).2 p → p.length ≤ (F k).1 :=
  fun k p hp => path_length_le_n (h_layered k) hp

/-- **Explicit Family Cost Lower Bound**.
For a family of layered matrices where the minimum edge weight grows with k,
any path of d+1 vertices in the k-th matrix has cost ≥ k · d.
This forces either short paths or high total cost. -/
theorem family_cost_lower_bound
    (F : ℕ → (n : ℕ) × Matrix (Fin n) (Fin n) ℕ)
    (_h_layered : ∀ k, IsLayered (F k).2)
    (h_weight : ∀ k, ∀ i j : Fin (F k).1, 0 < (F k).2 i j → k ≤ (F k).2 i j) :
    ∀ k, ∀ p : List (Fin (F k).1), IsPath (F k).2 p →
      k * (p.length - 1) ≤ pathCost (F k).2 p :=
  fun k p hp => pathCost_ge_minWeight_mul (h_weight k) hp

/-
**Depth-Cost Tradeoff for Explicit Families**.
For a family of layered n×n matrices with minimum edge weight ≥ k
and maximum edge weight ≤ W, any path has at most n vertices and
total cost between k·(length-1) and W·(length-1).
-/
theorem family_depth_cost_tradeoff
    (F : ℕ → (n : ℕ) × Matrix (Fin n) (Fin n) ℕ)
    (h_layered : ∀ k, IsLayered (F k).2)
    (h_min_weight : ∀ k, ∀ i j : Fin (F k).1, 0 < (F k).2 i j → k ≤ (F k).2 i j)
    (W : ℕ) (h_max_weight : ∀ k, ∀ i j : Fin (F k).1, (F k).2 i j ≤ W) :
    ∀ k, ∀ p : List (Fin (F k).1), IsPath (F k).2 p →
      k * (p.length - 1) ≤ pathCost (F k).2 p ∧
      pathCost (F k).2 p ≤ W * (p.length - 1) ∧
      p.length ≤ (F k).1 := by
  intro k p hp
  exact ⟨pathCost_ge_minWeight_mul (h_min_weight k) hp, pathCost_le_mul (h_max_weight k) hp, path_length_le_n (h_layered k) hp⟩

end TropicalCircuit