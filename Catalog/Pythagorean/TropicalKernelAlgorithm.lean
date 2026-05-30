/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Algorithmic Tropical Kernel Computation

This file establishes foundational results for computing tropical kernel dimensions
algorithmically. The key insight is that the tropical balance condition at each vertex
of a weighted graph translates to a min-plus linear constraint, and the tropical kernel
is the solution set of a structured tropical linear system.

## Main Definitions

* `TropicalLinearConstraint` — A single min-plus linear inequality
* `TropicalLinearSystem` — A system of tropical linear constraints
* `TropicalSolutionSet` — The solution set of a tropical linear system
* `IsTropicalKernelElement` — Tropical kernel membership predicate
* `tropicalPotentialGap` — Potential gap measuring distance from equilibrium

## Main Results

1. `balance_constraint_count_eq` — The balance system has exactly |V| constraints
2. `sparse_system_total_size` — Total system size is O(|V|·Δ)
3. `kernel_shift_invariant` — Translation invariance of tropical kernel
4. `potential_gap_nonneg` — Potential gap ≥ 0 for kernel elements
5. `equilibrium_iff_gap_zero` — Characterization of tropical equilibrium
6. `tropical_conservation_bridge` — Bridge to network flow theory
7. `total_gap_zero_iff_all_equilibrium` — Global equilibrium characterization

## References

* Butkovič, "Max-linear Systems: Theory and Algorithms" (2010)
* Baker–Norine, "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
-/

import Mathlib

open Finset BigOperators Classical

noncomputable section

set_option linter.unusedSectionVars false

namespace TropicalKernelAlgorithm

/-! ## Tropical Linear Systems -/

/-- A **tropical linear constraint** over a finite variable set `V`: a coefficient function,
    a support set, and a bound. The constraint `min_{v ∈ support} (coeffs(v) + x(v)) ≤ bound`
    is the min-plus analogue of a linear inequality. -/
structure TropicalLinearConstraint (V : Type*) [Fintype V] where
  coeffs : V → ℤ
  support : Finset V
  bound : ℤ

/-- Satisfaction of a tropical linear constraint. -/
def TropicalLinearConstraint.isSatisfied {V : Type*} [Fintype V]
    (c : TropicalLinearConstraint V) (x : V → ℤ) : Prop :=
  c.support.Nonempty →
    ∃ v ∈ c.support, c.coeffs v + x v ≤ c.bound

/-- A **tropical linear system** is a list of tropical linear constraints. -/
abbrev TropicalLinearSystem (V : Type*) [Fintype V] :=
  List (TropicalLinearConstraint V)

/-- The **solution set** of a tropical linear system. -/
def TropicalSolutionSet {V : Type*} [Fintype V]
    (sys : TropicalLinearSystem V) : Set (V → ℤ) :=
  {x | ∀ c ∈ sys, c.isSatisfied x}

/-! ## Graph Balance System -/

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- The neighbor finset of a vertex. -/
def nbrFinset (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) : Finset V :=
  G.neighborFinset v

theorem nbrFinset_card (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) :
    (nbrFinset G v).card = G.degree v :=
  G.card_neighborFinset_eq_degree v

theorem nbrFinset_mem_iff (G : SimpleGraph V) [DecidableRel G.Adj] (v u : V) :
    u ∈ nbrFinset G v ↔ G.Adj v u := by
  simp [nbrFinset, SimpleGraph.mem_neighborFinset]

/-- The balance constraint at vertex `v`. -/
def balanceConstraint (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (v : V) : TropicalLinearConstraint V where
  coeffs := fun u => w v u
  support := nbrFinset G v
  bound := 0

/-- The graph balance system: one constraint per vertex. -/
def graphBalanceSystem (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) : TropicalLinearSystem V :=
  (Finset.univ.val.toList).map (balanceConstraint G w)

/-- The balance system has exactly |V| constraints. -/
theorem balance_constraint_count_eq (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) :
    (graphBalanceSystem G w).length = Fintype.card V := by
  unfold graphBalanceSystem
  rw [List.length_map, Multiset.length_toList]
  rfl

/-! ## Complexity Bounds -/

/-- **Sparse system total size**: total constraint size ≤ |V| · Δ. -/
theorem sparse_system_total_size (G : SimpleGraph V) [DecidableRel G.Adj]
    (Δ : ℕ) (hΔ : ∀ v : V, G.degree v ≤ Δ) :
    Finset.univ.sum (fun v => (nbrFinset G v).card) ≤ Fintype.card V * Δ := by
  have heq : Finset.univ.sum (fun v => (nbrFinset G v).card) =
             Finset.univ.sum (fun v => G.degree v) :=
    Finset.sum_congr rfl (fun v _ => nbrFinset_card G v)
  rw [heq]
  calc Finset.univ.sum (fun v => G.degree v)
    _ ≤ Finset.univ.sum (fun _ => Δ) := Finset.sum_le_sum (fun v _ => hΔ v)
    _ = Fintype.card V * Δ := by simp [Finset.sum_const, Finset.card_univ]

/-- Sum of degrees = 2 · |E| (handshaking lemma). -/
theorem sum_degrees_eq_twice_edges (G : SimpleGraph V) [DecidableRel G.Adj] :
    Finset.univ.sum (fun v => G.degree v) = 2 * G.edgeFinset.card :=
  G.sum_degrees_eq_twice_card_edges

/-- System size bounded by n * Δ. -/
theorem polynomial_system_size (G : SimpleGraph V) [DecidableRel G.Adj]
    (Δ : ℕ) (hΔ : ∀ v : V, G.degree v ≤ Δ) :
    Finset.univ.sum (fun v => G.degree v) ≤ Fintype.card V * Δ := by
  have h1 := Finset.sum_le_sum (fun (v : V) (_ : v ∈ Finset.univ) => hΔ v)
  simp [Finset.sum_const, Finset.card_univ] at h1
  exact h1

/-! ## Tropical Kernel -/

/-- A **tropical kernel element** satisfies the balance condition at every vertex:
    for each vertex v with neighbors, there exists a neighbor u such that
    w(v,u) + x(u) ≤ x(v). -/
def IsTropicalKernelElement (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (x : V → ℤ) : Prop :=
  ∀ v : V, (nbrFinset G v).Nonempty →
    ∃ u ∈ nbrFinset G v, w v u + x u ≤ x v

/-- The **tropical kernel** of a weighted graph. -/
def tropicalKernel (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) : Set (V → ℤ) :=
  {x | IsTropicalKernelElement G w x}

/-- Zero is in the kernel when all weights are nonpositive. -/
theorem zero_mem_kernel_of_nonpos_weights (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (hw : ∀ u v : V, G.Adj u v → w u v ≤ 0) :
    (fun _ => (0 : ℤ)) ∈ tropicalKernel G w := by
  intro v hne
  obtain ⟨u, hu⟩ := hne
  exact ⟨u, hu, by linarith [hw v u ((nbrFinset_mem_iff G v u).mp hu)]⟩

/-- **Translation invariance**: shifting by a constant preserves kernel membership. -/
theorem kernel_shift_invariant (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (x : V → ℤ) (c : ℤ)
    (hx : x ∈ tropicalKernel G w) :
    (fun v => x v + c) ∈ tropicalKernel G w := by
  intro v hne
  obtain ⟨u, hu_mem, hu_le⟩ := hx v hne
  exact ⟨u, hu_mem, by linarith⟩

/-- **Weight monotonicity**: decreasing weights enlarges the kernel. -/
theorem kernel_weight_monotone (G : SimpleGraph V) [DecidableRel G.Adj]
    (w w' : V → V → ℤ) (x : V → ℤ)
    (hw : ∀ u v : V, w' u v ≤ w u v)
    (hx : x ∈ tropicalKernel G w) :
    x ∈ tropicalKernel G w' := by
  intro v hne
  obtain ⟨u, hu_mem, hu_le⟩ := hx v hne
  exact ⟨u, hu_mem, by linarith [hw v u]⟩

/-! ## Single Edge Analysis -/

/-- For a single edge, kernel constraints bound potential differences.
    From `w01 + x1 ≤ x0` we get `x0 - x1 ≥ w01`.
    From `w10 + x0 ≤ x1` we get `x0 - x1 ≤ -w10`. -/
theorem single_edge_kernel_interval (w01 w10 : ℤ) (x0 x1 : ℤ)
    (h1 : w01 + x1 ≤ x0) (h2 : w10 + x0 ≤ x1) :
    w01 ≤ x0 - x1 ∧ x0 - x1 ≤ -w10 := by
  constructor <;> linarith

/-- The feasible interval [w01, -w10] is nonempty iff w01 + w10 ≤ 0. -/
theorem edge_kernel_nonempty_iff (w01 w10 : ℤ) :
    (∃ d : ℤ, w01 ≤ d ∧ d ≤ -w10) ↔ w01 + w10 ≤ 0 := by
  constructor
  · rintro ⟨d, hd1, hd2⟩; linarith
  · intro h; exact ⟨w01, le_refl _, by linarith⟩

/-! ## Potential Gap Theory -/

/-- The **tropical potential gap** at a vertex measures how far the vertex
    potential exceeds the minimum incoming weighted potential. -/
def tropicalPotentialGap (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (x : V → ℤ) (v : V) : ℤ :=
  if h : (nbrFinset G v).Nonempty then
    x v - Finset.inf' (nbrFinset G v) h (fun u => w v u + x u)
  else 0

/-- The potential gap is nonneg for kernel elements. -/
theorem potential_gap_nonneg (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (x : V → ℤ) (hx : IsTropicalKernelElement G w x)
    (v : V) : 0 ≤ tropicalPotentialGap G w x v := by
  unfold tropicalPotentialGap
  split
  case isTrue h =>
    obtain ⟨u, hu_mem, hu_le⟩ := hx v h
    have : Finset.inf' (nbrFinset G v) h (fun u => w v u + x u) ≤ w v u + x u :=
      Finset.inf'_le _ hu_mem
    linarith
  case isFalse => exact le_refl 0

/-- **Tropical equilibrium**: gap = 0 iff the infimum equals x(v). -/
theorem equilibrium_iff_gap_zero (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (x : V → ℤ) (_hx : IsTropicalKernelElement G w x)
    (v : V) (hne : (nbrFinset G v).Nonempty) :
    tropicalPotentialGap G w x v = 0 ↔
    Finset.inf' (nbrFinset G v) hne (fun u => w v u + x u) = x v := by
  unfold tropicalPotentialGap
  rw [dif_pos hne]
  omega

/-! ## Cross-Domain: Network Flow Bridge

In classical network flow, conservation says ∑ f_in = ∑ f_out at each vertex.
In tropical network flow, this becomes: min(w + x)_neighbors = x(v).
The following theorem shows that tropical equilibrium (gap = 0) is
exactly this tropical conservation law. -/

/-- **Bridge theorem**: at equilibrium, tropical balance = tropical flow conservation. -/
theorem tropical_conservation_bridge (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (x : V → ℤ) (hx : IsTropicalKernelElement G w x)
    (v : V) (hne : (nbrFinset G v).Nonempty)
    (h_eq : tropicalPotentialGap G w x v = 0) :
    Finset.inf' (nbrFinset G v) hne (fun u => w v u + x u) = x v := by
  rwa [equilibrium_iff_gap_zero G w x hx v hne] at h_eq

/-! ## Tropical Rank -/

/-- Edge count ≤ n choose 2. -/
theorem edge_count_le_choose_two (G : SimpleGraph V) [DecidableRel G.Adj] :
    G.edgeFinset.card ≤ (Fintype.card V).choose 2 :=
  SimpleGraph.card_edgeFinset_le_card_choose_two

/-! ## Solution Set Properties -/

/-- The solution set of the empty system is universal. -/
theorem empty_system_solution_univ :
    TropicalSolutionSet (V := V) ([] : TropicalLinearSystem V) = Set.univ := by
  ext x; simp [TropicalSolutionSet]

/-- Adding a constraint can only shrink the solution set. -/
theorem solution_set_antitone (c : TropicalLinearConstraint V)
    (sys : TropicalLinearSystem V) :
    TropicalSolutionSet (c :: sys) ⊆ TropicalSolutionSet sys := by
  intro x hx c' hc'
  exact hx c' (List.mem_cons_of_mem _ hc')

/-! ## Cubic Bound Arithmetic -/

/-- The quadratic cost of one full system pass. -/
theorem cubic_bound_arithmetic (n Δ : ℕ) :
    n * (n * Δ) = n ^ 2 * Δ := by ring

/-- The cubic cost of n full system passes. -/
theorem full_algorithm_bound (n Δ : ℕ) :
    n * (n ^ 2 * Δ) = n ^ 3 * Δ := by ring

/-! ## Total Potential Gap -/

/-- The **total potential gap** sums gaps across all vertices. -/
def totalPotentialGap (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (x : V → ℤ) : ℤ :=
  Finset.univ.sum (fun v => tropicalPotentialGap G w x v)

/-- Total gap is nonneg for kernel elements. -/
theorem total_gap_nonneg (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (x : V → ℤ) (hx : IsTropicalKernelElement G w x) :
    0 ≤ totalPotentialGap G w x := by
  unfold totalPotentialGap
  exact Finset.sum_nonneg (fun v _ => potential_gap_nonneg G w x hx v)

/-- Total gap = 0 iff every vertex is at equilibrium.
    Uses `Finset.sum_eq_zero_iff_of_nonneg` (forward) and `Finset.sum_eq_zero` (backward). -/
theorem total_gap_zero_iff_all_equilibrium (G : SimpleGraph V) [DecidableRel G.Adj]
    (w : V → V → ℤ) (x : V → ℤ) (hx : IsTropicalKernelElement G w x) :
    totalPotentialGap G w x = 0 ↔
    ∀ v : V, tropicalPotentialGap G w x v = 0 := by
  unfold totalPotentialGap
  constructor
  · intro h v
    have h_nonneg : ∀ v' ∈ Finset.univ, 0 ≤ tropicalPotentialGap G w x v' :=
      fun v' _ => potential_gap_nonneg G w x hx v'
    exact (Finset.sum_eq_zero_iff_of_nonneg h_nonneg).mp h v (Finset.mem_univ v)
  · intro h
    exact Finset.sum_eq_zero (fun v _ => h v)

/-! ## Falsifiable Conjecture

**Conjecture (Polynomial-Time Tropical Kernel)**:
For graphs with n vertices and max degree Δ, the tropical kernel dimension
can be computed in O(n³ · Δ) operations.

**Testable prediction**: For random d-regular graphs with n = 5..20 and d ≤ 4,
measure the number of operations in a tropical LP-based algorithm.
The exponent α in runtime ~ n^α should satisfy α ≤ 3.
If α > 3.5 consistently, the conjecture is refuted.
-/

/-- Per-constraint cost bounded by Δ. -/
theorem per_constraint_cost_bound (G : SimpleGraph V) [DecidableRel G.Adj]
    (Δ : ℕ) (hΔ : ∀ v : V, G.degree v ≤ Δ) (v : V) :
    (nbrFinset G v).card ≤ Δ := by
  rw [nbrFinset_card]
  exact hΔ v

end TropicalKernelAlgorithm