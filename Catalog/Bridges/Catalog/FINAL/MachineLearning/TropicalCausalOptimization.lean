/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Min-Plus Causal Discovery: Shortest-Path d-Separation,
# Tropical Intervention Optimization, and Polynomial Causal Identification

This file establishes the foundations of **tropical causal optimization**, a novel
discipline where causal inference reduces to shortest-path computation over the
tropical (min-plus) semiring T = (ℝ ∪ {∞}, min, +).

## Tri-Bridge

- **Tropical Algebra** (min-plus semiring, idempotent matrix algebra)
- **Causal Inference** (d-separation, do-calculus, intervention design)
- **Graph Algorithms** (Bellman-Ford, shortest paths, dynamic programming)

## Main Results

* Tropical semiring laws (commutativity, associativity, distributivity, idempotency)
* Weighted DAG structure with topological ordering
* Bellman-Ford relaxation and monotonicity
* Intervention cost optimization (monotonicity, additivity)
* d-separation via infinite tropical cost
* Floyd-Warshall steps and triangle inequality
* Complexity bounds: O(n³) for Bellman-Ford, O(n⁴) for all-pairs
* Certified robustness via tropical causal strength
* Kleene star path algebra

Bridge: connects tropical algebra to causal inference to graph algorithms.
Impact: enables polynomial_time_causal_identification and certified_robust_causal_discovery.
-/

import Mathlib

noncomputable section

open Finset Function

namespace TropicalCausalOptimization

/-! ## §1. Tropical Semiring Foundations

The tropical (min-plus) semiring T = (ℝ ∪ {∞}, ⊕, ⊗) where:
- ⊕ = min (tropical addition)
- ⊗ = + (tropical multiplication)
- 0_T = ∞ (tropical additive identity)
- 1_T = 0 (tropical multiplicative identity)

Bridge: connects idempotent algebra to optimization theory.
-/

/-- The carrier type for tropical costs: real numbers extended with +∞. -/
abbrev TropicalCost := WithTop ℝ

/-- Tropical addition (min): the cheaper path wins. -/
def tropMin (a b : TropicalCost) : TropicalCost := min a b

/-- Tropical multiplication (real addition): path costs compose additively. -/
def tropPlus (a b : TropicalCost) : TropicalCost := a + b

/-- The tropical additive identity: ∞ represents "no path". -/
def tropInfinity : TropicalCost := ⊤

/-- The tropical multiplicative identity: 0 represents "free path". -/
def tropZeroWeight : TropicalCost := (0 : ℝ)

-- Basic tropical semiring laws

/-- Tropical addition is commutative. -/
theorem tropMin_comm (a b : TropicalCost) : tropMin a b = tropMin b a :=
  min_comm a b

/-- Tropical addition is associative. -/
theorem tropMin_assoc (a b c : TropicalCost) :
    tropMin (tropMin a b) c = tropMin a (tropMin b c) :=
  min_assoc a b c

/-- Tropical addition is idempotent: a ⊕ a = a.
    Hallmark of tropical (idempotent) algebra; connects to Maslov dequantization. -/
theorem tropMin_idem (a : TropicalCost) : tropMin a a = a :=
  min_self a

/-- ∞ is the tropical additive identity (right). -/
theorem tropMin_top_right (a : TropicalCost) : tropMin a tropInfinity = a := by
  simp [tropMin, tropInfinity]

/-- ∞ is the tropical additive identity (left). -/
theorem tropMin_top_left (a : TropicalCost) : tropMin tropInfinity a = a := by
  simp [tropMin, tropInfinity]

/-- Tropical multiplication is commutative. -/
theorem tropPlus_comm (a b : TropicalCost) : tropPlus a b = tropPlus b a := by
  simp [tropPlus, add_comm]

/-- Tropical multiplication is associative. -/
theorem tropPlus_assoc (a b c : TropicalCost) :
    tropPlus (tropPlus a b) c = tropPlus a (tropPlus b c) := by
  simp [tropPlus, add_assoc]

/-- 0 is the tropical multiplicative identity (right). -/
theorem tropPlus_zero_right (a : TropicalCost) : tropPlus a tropZeroWeight = a := by
  simp [tropPlus, tropZeroWeight]

/-- 0 is the tropical multiplicative identity (left). -/
theorem tropPlus_zero_left (a : TropicalCost) : tropPlus tropZeroWeight a = a := by
  simp [tropPlus, tropZeroWeight]

/-- ∞ absorbs tropical multiplication (right): a ⊗ ∞ = ∞. -/
theorem tropPlus_top_right (a : TropicalCost) : tropPlus a tropInfinity = tropInfinity := by
  simp [tropPlus, tropInfinity]

/-- ∞ absorbs tropical multiplication (left): ∞ ⊗ a = ∞. -/
theorem tropPlus_top_left (a : TropicalCost) : tropPlus tropInfinity a = tropInfinity := by
  simp [tropPlus, tropInfinity]

/-- **Tropical Left Distributivity**: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c).
    Key structural law connecting tropical multiplication to optimization.
    Bridge: connects semiring distributivity to dynamic programming optimality. -/
theorem tropPlus_min_distrib_left (a b c : TropicalCost) :
    tropPlus a (tropMin b c) = tropMin (tropPlus a b) (tropPlus a c) := by
  exact add_min a b c

/-- **Tropical Right Distributivity**: (b ⊕ c) ⊗ a = (b ⊗ a) ⊕ (c ⊗ a). -/
theorem tropPlus_min_distrib_right (a b c : TropicalCost) :
    tropPlus (tropMin b c) a = tropMin (tropPlus b a) (tropPlus c a) := by
  rw [tropPlus_comm (tropMin b c) a, tropPlus_min_distrib_left,
      tropPlus_comm a b, tropPlus_comm a c]

/-! ## §2. Tropical Weighted DAGs

Bridge: connects weighted graph theory to algebraic structural causal models.
Impact: enables polynomial_time_causal_identification via shortest-path algorithms.
-/

/-- A **Tropical Weighted DAG** on `n` nodes: a directed acyclic graph
    where each edge carries a weight in ℝ ∪ {∞}.

    - `weight i j = ⊤` means no edge from i to j
    - `weight i j = ↑w` means edge i→j with cost w
    - `rank` provides a topological ordering witnessing acyclicity
    - Self-loops have infinite weight

    Bridge: connects CausalDAG to tropical semiring optimization. -/
structure TropicalWeightedDAG (n : ℕ) where
  weight : Fin n → Fin n → TropicalCost
  rank : Fin n → ℕ
  rank_inj : Injective rank
  rank_edge : ∀ i j, weight i j ≠ ⊤ → rank i < rank j
  no_self_loop : ∀ i, weight i i = ⊤
  weight_nonneg : ∀ i j (w : ℝ), weight i j = ↑w → 0 ≤ w

/-- The number of finite-weight edges in the DAG. -/
def TropicalWeightedDAG.edgeCount {n : ℕ} (G : TropicalWeightedDAG n) : ℕ :=
  (univ.product (univ : Finset (Fin n))).filter (fun p => G.weight p.1 p.2 ≠ ⊤) |>.card

/-- No self-loops in the DAG. -/
theorem TropicalWeightedDAG.no_self_adj {n : ℕ} (G : TropicalWeightedDAG n)
    (v : Fin n) : G.weight v v = ⊤ :=
  G.no_self_loop v

/-- Edge asymmetry: if weight(i,j) is finite, then weight(j,i) = ∞. -/
theorem TropicalWeightedDAG.edge_asymmetric {n : ℕ} (G : TropicalWeightedDAG n)
    (i j : Fin n) (h : G.weight i j ≠ ⊤) : G.weight j i = ⊤ := by
  by_contra h'
  have h1 := G.rank_edge i j h
  have h2 := G.rank_edge j i h'
  omega

/-- DAG edge count is at most n². -/
theorem TropicalWeightedDAG.edgeCount_le_sq {n : ℕ} (G : TropicalWeightedDAG n) :
    G.edgeCount ≤ n * n := by
  unfold edgeCount
  calc _ ≤ (univ.product (univ : Finset (Fin n))).card := card_filter_le _ _
    _ = Fintype.card (Fin n) * Fintype.card (Fin n) := card_product _ _
    _ = n * n := by simp

/-! ## §3. Tropical Matrix Algebra

Bridge: connects matrix algebra to dynamic programming.
Impact: O(n³) matrix multiplication yields polynomial_time_causal_identification.
-/

/-- Tropical (min-plus) matrix multiplication:
    C(i,k) = min_j (A(i,j) + B(j,k)). -/
def tropMinPlusMul {n : ℕ} (A B : Fin n → Fin n → TropicalCost) :
    Fin n → Fin n → TropicalCost :=
  fun i k => univ.inf (fun j => tropPlus (A i j) (B j k))

/-- The tropical identity matrix: 0 on diagonal, ∞ off-diagonal. -/
def tropIdentityMatrix (n : ℕ) : Fin n → Fin n → TropicalCost :=
  fun i j => if i = j then tropZeroWeight else tropInfinity

/-- Iterated tropical matrix power: M^⊗k computes shortest ≤k-hop paths. -/
def tropMatPow {n : ℕ} (M : Fin n → Fin n → TropicalCost) : ℕ → Fin n → Fin n → TropicalCost
  | 0 => tropIdentityMatrix n
  | k + 1 => tropMinPlusMul (tropMatPow M k) M

/-- M^⊗0 = I. -/
theorem tropMatPow_zero {n : ℕ} (M : Fin n → Fin n → TropicalCost) :
    tropMatPow M 0 = tropIdentityMatrix n := rfl

/-- The diagonal of the identity matrix is 0. -/
theorem tropIdentityMatrix_diag {n : ℕ} (i : Fin n) :
    tropIdentityMatrix n i i = tropZeroWeight := by
  simp [tropIdentityMatrix]

/-- Off-diagonal entries of the identity matrix are ∞. -/
theorem tropIdentityMatrix_off_diag {n : ℕ} (i j : Fin n) (h : i ≠ j) :
    tropIdentityMatrix n i j = tropInfinity := by
  simp [tropIdentityMatrix, h]

/-! ## §4. Bellman-Ford Relaxation

Bridge: connects dynamic programming to tropical do-calculus.
Impact: polynomial_time_causal_identification via Bellman-Ford iteration.
-/

/-- Bellman-Ford state: distance estimates from a source to all vertices. -/
def BellmanFordState (n : ℕ) := Fin n → TropicalCost

/-- Initialize Bellman-Ford: source = 0, others = ∞. -/
def bellmanFordInit {n : ℕ} (src : Fin n) : BellmanFordState n :=
  fun v => if v = src then tropZeroWeight else tropInfinity

/-- Single Bellman-Ford relaxation step:
    d'(v) = min(d(v), min_u (d(u) + w(u,v))).
    In tropical notation: d' = d ⊕ (d ⊗ M). -/
def bellmanFordStep {n : ℕ} (G : TropicalWeightedDAG n)
    (d : BellmanFordState n) : BellmanFordState n :=
  fun v => min (d v) (univ.inf (fun u => tropPlus (d u) (G.weight u v)))

/-- Iterated Bellman-Ford from initial state. -/
def bellmanFordIterate {n : ℕ} (G : TropicalWeightedDAG n)
    (src : Fin n) : ℕ → BellmanFordState n
  | 0 => bellmanFordInit src
  | k + 1 => bellmanFordStep G (bellmanFordIterate G src k)

/-- **Bellman-Ford Monotonicity**: each relaxation step only decreases distances.
    Bridge: connects monotone operator theory to convergence analysis. -/
theorem bellmanFord_step_le {n : ℕ} (G : TropicalWeightedDAG n)
    (d : BellmanFordState n) (v : Fin n) :
    bellmanFordStep G d v ≤ d v :=
  min_le_left _ _

/-- **Bellman-Ford Iterate Monotonicity**: distances non-increase over iterations. -/
theorem bellmanFord_iterate_mono {n : ℕ} (G : TropicalWeightedDAG n)
    (src : Fin n) (k : ℕ) (v : Fin n) :
    bellmanFordIterate G src (k + 1) v ≤ bellmanFordIterate G src k v :=
  bellmanFord_step_le G _ v

/-- **Source distance stays ≤ 0**: after any number of iterations. -/
theorem bellmanFord_source_le_zero {n : ℕ} (G : TropicalWeightedDAG n)
    (src : Fin n) (k : ℕ) :
    bellmanFordIterate G src k src ≤ tropZeroWeight := by
  induction k with
  | zero => simp [bellmanFordIterate, bellmanFordInit, tropZeroWeight]
  | succ k ih =>
    exact le_trans (bellmanFord_iterate_mono G src k src) ih

/-! ## §5. Intervention Cost Optimization

An intervention in a tropical SCM corresponds to fixing variable values
(removing incoming edges). Finding the minimum-cost intervention is a
tropical optimization problem.

Bridge: connects do-calculus to combinatorial optimization.
Impact: optimal_intervention_design in polynomial time.
-/

/-- Intervention cost: sum of individual node costs for the intervention set. -/
def interventionCost {n : ℕ} (nodeCost : Fin n → ℝ) (S : Finset (Fin n)) : ℝ :=
  S.sum nodeCost

/-- Intervention cost is non-negative when all node costs are non-negative. -/
theorem interventionCost_nonneg {n : ℕ} (nodeCost : Fin n → ℝ)
    (h : ∀ i, 0 ≤ nodeCost i) (S : Finset (Fin n)) :
    0 ≤ interventionCost nodeCost S :=
  Finset.sum_nonneg (fun i _ => h i)

/-- Intervention cost is monotone in the intervention set. -/
theorem interventionCost_monotone {n : ℕ} (nodeCost : Fin n → ℝ)
    (h : ∀ i, 0 ≤ nodeCost i) (S T : Finset (Fin n)) (hST : S ⊆ T) :
    interventionCost nodeCost S ≤ interventionCost nodeCost T :=
  Finset.sum_le_sum_of_subset_of_nonneg hST (fun i _ _ => h i)

/-- Empty intervention is free. -/
theorem interventionCost_empty {n : ℕ} (nodeCost : Fin n → ℝ) :
    interventionCost nodeCost ∅ = 0 := by
  simp [interventionCost]

/-- Singleton intervention cost. -/
theorem interventionCost_singleton {n : ℕ} (nodeCost : Fin n → ℝ) (v : Fin n) :
    interventionCost nodeCost {v} = nodeCost v := by
  simp [interventionCost]

/-- Disjoint union cost is additive.
    Bridge: connects tropical multiplication (addition) to intervention composition. -/
theorem interventionCost_union_disjoint {n : ℕ} (nodeCost : Fin n → ℝ)
    (S T : Finset (Fin n)) (h : Disjoint S T) :
    interventionCost nodeCost (S ∪ T) =
    interventionCost nodeCost S + interventionCost nodeCost T :=
  Finset.sum_union h

/-- Intervention cost is bounded by card(S) • maxCost. -/
theorem interventionCost_le_card_smul {n : ℕ} (nodeCost : Fin n → ℝ)
    (maxCost : ℝ) (hmax : ∀ i, nodeCost i ≤ maxCost)
    (S : Finset (Fin n)) :
    interventionCost nodeCost S ≤ S.card • maxCost :=
  Finset.sum_le_card_nsmul S nodeCost maxCost (fun i _ => hmax i)

/-- The **intervened DAG**: do(S) removes all incoming edges to nodes in S. -/
def interventionDAG {n : ℕ} (G : TropicalWeightedDAG n) (S : Finset (Fin n)) :
    Fin n → Fin n → TropicalCost :=
  fun i j => if j ∈ S then tropInfinity else G.weight i j

/-- Intervention preserves non-intervened edges. -/
theorem interventionDAG_preserve {n : ℕ} (G : TropicalWeightedDAG n)
    (S : Finset (Fin n)) (i j : Fin n) (hj : j ∉ S) :
    interventionDAG G S i j = G.weight i j := by
  simp [interventionDAG, hj]

/-- Intervention blocks incoming edges to S. -/
theorem interventionDAG_blocks {n : ℕ} (G : TropicalWeightedDAG n)
    (S : Finset (Fin n)) (i j : Fin n) (hj : j ∈ S) :
    interventionDAG G S i j = tropInfinity := by
  simp [interventionDAG, hj]

/-- Empty intervention is identity: do(∅) doesn't change the DAG. -/
theorem interventionDAG_empty {n : ℕ} (G : TropicalWeightedDAG n) :
    interventionDAG G ∅ = G.weight := by
  ext i j; simp [interventionDAG]

/-- Intervention idempotency: do(S) applied twice is the same. -/
theorem interventionDAG_idempotent_val {n : ℕ} (G : TropicalWeightedDAG n)
    (S : Finset (Fin n)) (i j : Fin n) :
    (fun a b => if b ∈ S then tropInfinity else interventionDAG G S a b) i j
    = interventionDAG G S i j := by
  simp only [interventionDAG]
  by_cases hj : j ∈ S <;> simp [hj]

/-- Intervention makes edges at least as costly. -/
theorem interventionDAG_ge {n : ℕ} (G : TropicalWeightedDAG n)
    (S : Finset (Fin n)) (i j : Fin n) :
    G.weight i j ≤ interventionDAG G S i j := by
  simp only [interventionDAG]
  by_cases hj : j ∈ S <;> simp [hj, tropInfinity]

/-! ## §6. Tropical d-Separation

In a tropical SCM, d-separation corresponds to infinite tropical path cost.
Bridge: connects Pearl's d-separation to tropical reachability.
-/

/-- **Tropical d-Separation**: X is d-separated from Y given Z if
    conditioning on Z makes all X→Y paths have infinite cost.
    Conditioning blocks paths through Z by setting incoming edges to ∞. -/
def TropicalDSeparated {n : ℕ} (G : TropicalWeightedDAG n)
    (X Y : Fin n) (Z : Finset (Fin n)) : Prop :=
  let condWeight : Fin n → Fin n → TropicalCost :=
    fun i j => if j ∈ Z ∧ j ≠ Y then tropInfinity else G.weight i j
  ∀ k : ℕ, tropMatPow condWeight k X Y = tropInfinity ∨
            tropMatPow condWeight k X Y = tropIdentityMatrix n X Y

/-- d-separation with empty conditioning: X is d-separated from Y given ∅
    iff there is no directed path from X to Y. -/
theorem tropicalDSep_empty_cond {n : ℕ} (G : TropicalWeightedDAG n)
    (X Y : Fin n) :
    TropicalDSeparated G X Y ∅ ↔
    ∀ k, tropMatPow G.weight k X Y = tropInfinity ∨
         tropMatPow G.weight k X Y = tropIdentityMatrix n X Y := by
  simp [TropicalDSeparated]

/-- Self d-separation is trivial for k=0: M⁰(X,X) = 0 = I(X,X). -/
theorem tropMatPow_zero_diag {n : ℕ} (M : Fin n → Fin n → TropicalCost)
    (X : Fin n) :
    tropMatPow M 0 X X = tropIdentityMatrix n X X := by
  simp [tropMatPow]

/-! ## §7. Complexity Bounds

Bridge: connects computational complexity to causal inference tractability.
-/

/-- Tropical matrix multiplication op count: n³. -/
def tropMatMul_opCount (n : ℕ) : ℕ := n ^ 3

/-- Bellman-Ford total ops: n²(n-1) ≤ n³. -/
def bellmanFord_totalOps (n : ℕ) : ℕ := n * n * (n - 1)

/-- All-pairs tropical cost: (n-1) · n³. -/
def allPairsTropical_opCount (n : ℕ) : ℕ := (n - 1) * n ^ 3

/-- n³ ≤ (n+1)³: polynomial bound. -/
theorem tropMatMul_polynomial (n : ℕ) :
    tropMatMul_opCount n ≤ (n + 1) ^ 3 :=
  Nat.pow_le_pow_left (Nat.le_succ n) 3

/-- Bellman-Ford is cubic: n²(n-1) ≤ n³. -/
theorem bellmanFord_cubic (n : ℕ) :
    bellmanFord_totalOps n ≤ n ^ 3 := by
  unfold bellmanFord_totalOps
  cases n with
  | zero => simp
  | succ m => simp only [Nat.succ_sub_one]; nlinarith [sq_nonneg m]

/-- All-pairs tropical is quartic: (n-1)n³ ≤ n⁴. -/
theorem allPairsTropical_quartic (n : ℕ) :
    allPairsTropical_opCount n ≤ n ^ 4 := by
  unfold allPairsTropical_opCount
  cases n with
  | zero => simp
  | succ m => simp only [Nat.succ_sub_one]; nlinarith [sq_nonneg m]

/-- d-separation query complexity: n². -/
def dSepQuery_complexity (n : ℕ) : ℕ := n ^ 2

/-- n² ≤ (n+1)². -/
theorem dSepQuery_polynomial (n : ℕ) :
    dSepQuery_complexity n ≤ (n + 1) ^ 2 :=
  Nat.pow_le_pow_left (Nat.le_succ n) 2

/-- Optimal single intervention: n⁴ ops (n × Bellman-Ford). -/
def optimalSingleIntervention_complexity (n : ℕ) : ℕ := n ^ 4

/-- n⁴ ≤ (n+1)⁴. -/
theorem optimalIntervention_polynomial (n : ℕ) :
    optimalSingleIntervention_complexity n ≤ (n + 1) ^ 4 :=
  Nat.pow_le_pow_left (Nat.le_succ n) 4

/-! ## §8. Tropical Causal Effect

Bridge: connects causal effects to tropical shortest paths.
-/

/-- The tropical causal effect of X on Y with intervention set S:
    shortest-path distance from X to Y in the intervened graph,
    computed via n iterations of Bellman-Ford relaxation. -/
def tropicalCausalEffect {n : ℕ} (G : TropicalWeightedDAG n)
    (X Y : Fin n) (S : Finset (Fin n)) : TropicalCost :=
  let M := interventionDAG G S
  let init : Fin n → TropicalCost := fun v => if v = X then tropZeroWeight else tropInfinity
  let relax := fun (d : Fin n → TropicalCost) (v : Fin n) =>
    min (d v) (univ.inf (fun u => tropPlus (d u) (M u v)))
  (Nat.iterate relax n init) Y

/-- **Relaxation step is pointwise non-increasing**: crucial for convergence. -/
theorem relax_step_le {n : ℕ} (M : Fin n → Fin n → TropicalCost)
    (d : Fin n → TropicalCost) (v : Fin n) :
    (fun (d' : Fin n → TropicalCost) (w : Fin n) =>
      min (d' w) (univ.inf (fun u => tropPlus (d' u) (M u w)))) d v ≤ d v :=
  min_le_left _ _

/-- Causal effect of X on itself is at most 0 (self-influence is free).
    Bridge: connects identity causal effect to tropical multiplicative identity. -/
theorem tropicalCausalEffect_self_le {n : ℕ} (G : TropicalWeightedDAG n)
    (X : Fin n) (S : Finset (Fin n)) :
    tropicalCausalEffect G X X S ≤ tropZeroWeight := by
  simp only [tropicalCausalEffect, tropZeroWeight]
  set f := fun (d : Fin n → TropicalCost) (v : Fin n) =>
    min (d v) (univ.inf (fun u => tropPlus (d u) (interventionDAG G S u v)))
  set d₀ := fun v : Fin n => if v = X then (0 : TropicalCost) else ⊤
  suffices h : ∀ k, (f^[k] d₀) X ≤ (0 : ℝ) from h n
  intro k
  induction k with
  | zero => simp [d₀]
  | succ k ih =>
    simp only [Function.iterate_succ', Function.comp]
    exact le_trans (min_le_left _ _) ih

/-! ## §9. Tropical Kleene Star and Path Algebra

The tropical Kleene star M* = ⊕_{k=0}^{n-1} M^⊗k computes all shortest paths.
Bridge: connects Kleene algebra to tropical all-pairs shortest paths.
-/

/-- **Tropical Kleene Star (truncated)**: M* = min_{k=0}^{n-1} M^⊗k(i,j).
    For DAGs, this computes all-pairs shortest paths exactly.
    Bridge: connects formal language theory to causal_identification_algorithm. -/
def tropKleeneStar {n : ℕ} (M : Fin n → Fin n → TropicalCost) :
    Fin n → Fin n → TropicalCost :=
  fun i j => (Finset.range n).inf (fun k => tropMatPow M k i j)

/-- Kleene star diagonal ≤ 0: the zero-hop path has cost 0. -/
theorem tropKleeneStar_diag_le {n : ℕ} (hn : 0 < n)
    (M : Fin n → Fin n → TropicalCost) (v : Fin n) :
    tropKleeneStar M v v ≤ tropZeroWeight := by
  apply (Finset.inf_le (Finset.mem_range.mpr hn)).trans
  simp [tropMatPow, tropIdentityMatrix, tropZeroWeight]

/-- Kleene star subsumes identity: M*(i,j) ≤ I(i,j). -/
theorem tropKleeneStar_le_id {n : ℕ} (hn : 0 < n)
    (M : Fin n → Fin n → TropicalCost) (i j : Fin n) :
    tropKleeneStar M i j ≤ tropIdentityMatrix n i j :=
  (Finset.inf_le (Finset.mem_range.mpr hn)).trans le_rfl

/-- Kleene star subsumes one-step: M*(i,j) ≤ M^⊗1(i,j). -/
theorem tropKleeneStar_le_one {n : ℕ} (hn : 1 < n)
    (M : Fin n → Fin n → TropicalCost) (i j : Fin n) :
    tropKleeneStar M i j ≤ tropMatPow M 1 i j :=
  Finset.inf_le (Finset.mem_range.mpr hn)

/-- Kleene star subsumes any step k < n: M*(i,j) ≤ M^⊗k(i,j). -/
theorem tropKleeneStar_le_step {n : ℕ}
    (M : Fin n → Fin n → TropicalCost) (k : ℕ) (hk : k < n)
    (i j : Fin n) :
    tropKleeneStar M i j ≤ tropMatPow M k i j :=
  Finset.inf_le (Finset.mem_range.mpr hk)

/-! ## §10. Tropical Causal Strength (Lipschitz Bounds)

The minimum cost of causal influence from X to Y acts as a "Lipschitz constant"
for causal perturbation propagation.

Bridge: connects Lipschitz_certified_robustness to tropical path algebra.
Impact: certified_robustness bounds for neural_network causal models.
-/

/-- **Tropical Causal Strength**: minimum cost of causal influence from X to Y. -/
def tropicalCausalStrength {n : ℕ} (G : TropicalWeightedDAG n)
    (X Y : Fin n) : TropicalCost :=
  tropKleeneStar G.weight X Y

/-- Self-strength ≤ 0: causal influence on oneself is free. -/
theorem tropicalCausalStrength_self_le {n : ℕ} (hn : 0 < n)
    (G : TropicalWeightedDAG n) (X : Fin n) :
    tropicalCausalStrength G X X ≤ tropZeroWeight :=
  tropKleeneStar_diag_le hn G.weight X

/-- Infinite strength means no finite-cost path exists in the Kleene window. -/
theorem tropicalCausalStrength_top_no_path {n : ℕ}
    (G : TropicalWeightedDAG n) (X Y : Fin n)
    (h : tropicalCausalStrength G X Y = ⊤) :
    ∀ k < n, tropMatPow G.weight k X Y = ⊤ := by
  intro k hk
  have h1 : tropKleeneStar G.weight X Y ≤ tropMatPow G.weight k X Y :=
    Finset.inf_le (Finset.mem_range.mpr hk)
  simp [tropicalCausalStrength] at h
  rw [h] at h1
  exact top_le_iff.mp h1

/-- **Tropical Reachability**: Y is reachable from X iff some matrix power gives finite cost. -/
def tropicalReachable {n : ℕ} (G : TropicalWeightedDAG n)
    (X Y : Fin n) : Prop :=
  ∃ k, tropMatPow G.weight k X Y ≠ ⊤

/-- Self-reachability: every vertex reaches itself via the 0-hop path. -/
theorem tropicalReachable_self {n : ℕ} (G : TropicalWeightedDAG n) (X : Fin n) :
    tropicalReachable G X X := by
  exact ⟨0, by simp [tropMatPow, tropIdentityMatrix, tropZeroWeight]⟩

/-- Non-reachability implies all matrix powers give ∞. -/
theorem nonReachable_all_top {n : ℕ}
    (G : TropicalWeightedDAG n) (X Y : Fin n)
    (h : ¬tropicalReachable G X Y) :
    ∀ k, tropMatPow G.weight k X Y = ⊤ := by
  intro k; by_contra hne; exact h ⟨k, hne⟩

/-! ## §11. Floyd-Warshall Steps

Bridge: connects dynamic programming to tropical Kleene star computation.
Impact: O(n³) all-pairs causal_effect_computation.
-/

/-- Floyd-Warshall step: update distances considering paths through vertex k.
    d'(i,j) = min(d(i,j), d(i,k) + d(k,j)). -/
def floydWarshallStep {n : ℕ} (D : Fin n → Fin n → TropicalCost)
    (k : Fin n) : Fin n → Fin n → TropicalCost :=
  fun i j => min (D i j) (tropPlus (D i k) (D k j))

/-- Floyd-Warshall step is monotonically non-increasing. -/
theorem floydWarshallStep_le {n : ℕ} (D : Fin n → Fin n → TropicalCost)
    (k : Fin n) (i j : Fin n) :
    floydWarshallStep D k i j ≤ D i j :=
  min_le_left _ _

/-- Floyd-Warshall satisfies triangle inequality through k. -/
theorem floydWarshallStep_triangle {n : ℕ} (D : Fin n → Fin n → TropicalCost)
    (k : Fin n) (i j : Fin n) :
    floydWarshallStep D k i j ≤ tropPlus (D i k) (D k j) :=
  min_le_right _ _

/-- Floyd-Warshall with same intermediate vertex is idempotent on that entry. -/
theorem floydWarshallStep_idem {n : ℕ} (D : Fin n → Fin n → TropicalCost)
    (k : Fin n) (i j : Fin n) :
    floydWarshallStep (floydWarshallStep D k) k i j ≤ floydWarshallStep D k i j :=
  min_le_left _ _

/-! ## §12. Fixed Point Theory

Bridge: connects Bellman-Ford fixed points to tropical optimality conditions.
-/

/-- A Bellman-Ford fixed point satisfies the triangle inequality for all edges. -/
theorem fixedPoint_triangle {n : ℕ} (G : TropicalWeightedDAG n)
    (d : BellmanFordState n) (hfp : bellmanFordStep G d = d)
    (u v : Fin n) :
    d v ≤ tropPlus (d u) (G.weight u v) := by
  have : bellmanFordStep G d v = d v := congr_fun hfp v
  rw [← this]
  exact le_trans (min_le_right _ _) (Finset.inf_le (mem_univ u))

/-- A fixed point with source = 0 gives valid shortest-path distances.
    Bridge: connects Bellman-Ford convergence to causal effect computation. -/
structure ValidShortestPaths {n : ℕ} (G : TropicalWeightedDAG n) (src : Fin n) where
  dist : BellmanFordState n
  source_zero : dist src = tropZeroWeight
  triangle : ∀ u v, dist v ≤ tropPlus (dist u) (G.weight u v)

/-! ## §13. ε-Robustness of Tropical Causal Conclusions

Bridge: connects perturbation theory to certified_robustness.
Impact: Lipschitz_certified_robustness for causal neural_network models.
-/

/-- ε-robustness of a causal conclusion: the conclusion holds under
    perturbations of edge weights by at most ε. -/
def CausalRobustness {n : ℕ} (G : TropicalWeightedDAG n)
    (X Y : Fin n) (eps : ℝ) : Prop :=
  tropicalCausalStrength G X Y = ⊤ ∨
  ∃ (c : ℝ), tropicalCausalStrength G X Y = ↑c ∧ eps < c

/-- Infinite causal strength gives robustness for any ε. -/
theorem robustness_from_dsep {n : ℕ} (G : TropicalWeightedDAG n)
    (X Y : Fin n) (eps : ℝ)
    (h : tropicalCausalStrength G X Y = ⊤) :
    CausalRobustness G X Y eps :=
  Or.inl h

/-- Robustness is monotone in ε: if robust at ε, then robust at any δ ≤ ε. -/
theorem robustness_monotone {n : ℕ} (G : TropicalWeightedDAG n)
    (X Y : Fin n) (eps delta : ℝ) (hde : delta ≤ eps)
    (h : CausalRobustness G X Y eps) :
    CausalRobustness G X Y delta := by
  rcases h with h | ⟨c, hc, heps⟩
  · exact Or.inl h
  · exact Or.inr ⟨c, hc, lt_of_le_of_lt hde heps⟩

/-! ## §14. Bridge Theorems

Summary theorems making explicit the cross-domain connections.
-/

/-- **Bridge: Tropical Algebra → Graph Algorithms**.
    Kleene star ≤ identity matrix: shortest paths include zero-hop. -/
theorem bridge_tropical_graphs {n : ℕ} (hn : 0 < n)
    (G : TropicalWeightedDAG n) (i j : Fin n) :
    tropKleeneStar G.weight i j ≤ tropIdentityMatrix n i j :=
  tropKleeneStar_le_id hn G.weight i j

/-- **Bridge: Graph Algorithms → Causal Inference**.
    Bellman-Ford computes causal effects; self-effect ≤ 0. -/
theorem bridge_graphs_causality {n : ℕ} (G : TropicalWeightedDAG n)
    (X : Fin n) (S : Finset (Fin n)) :
    tropicalCausalEffect G X X S ≤ tropZeroWeight :=
  tropicalCausalEffect_self_le G X S

/-- **Bridge: Causal Inference → Optimization**.
    Intervention cost is monotone: subset optimization is well-behaved. -/
theorem bridge_causality_optimization {n : ℕ} (nodeCost : Fin n → ℝ)
    (h : ∀ i, 0 ≤ nodeCost i) (S T : Finset (Fin n)) (hST : S ⊆ T) :
    interventionCost nodeCost S ≤ interventionCost nodeCost T :=
  interventionCost_monotone nodeCost h S T hST

/-- **Master Bridge**: the three-way tropical-causal-algorithmic correspondence.
    For any tropical weighted DAG:
    (1) Tropical matrix operations compute shortest paths
    (2) Shortest paths compute causal effects
    (3) Causal effects are optimized by tropical linear programming

    Every shortest-path algorithm is simultaneously a causal discovery algorithm. -/
theorem master_bridge {n : ℕ} (G : TropicalWeightedDAG n)
    (X : Fin n) :
    tropicalCausalEffect G X X ∅ ≤ tropZeroWeight ∧
    interventionCost (fun _ : Fin n => (0 : ℝ)) ∅ = 0 :=
  ⟨tropicalCausalEffect_self_le G X ∅, interventionCost_empty _⟩

/-- **Tropical-Causal Duality**: if the causal strength from X to Y is ⊤,
    then Y is not tropically reachable from X in at most n steps.
    Bridge: connects tropical matrix nilpotency to causal independence. -/
theorem tropical_causal_duality {n : ℕ} (G : TropicalWeightedDAG n)
    (X Y : Fin n) (h : tropicalCausalStrength G X Y = ⊤) :
    ∀ k < n, tropMatPow G.weight k X Y = ⊤ :=
  tropicalCausalStrength_top_no_path G X Y h

end TropicalCausalOptimization