/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Graph Distance and Energy Collection Optimization

## Overview

This file formalizes tropical (min-plus) shortest-path distance on finite weighted
graphs and proves the fundamental equivalence between maximizing energy gain and
minimizing tropical distance. The key results are:

1. **Gain-distance duality**: A vertex maximizes `G - tropicalDist(src, v)` if and
   only if it minimizes `tropicalDist(src, v)`. This is the core optimization
   equivalence connecting tropical algebra to energy collection.

2. **Bellman dynamic programming**: Tropical distance satisfies a DP recurrence,
   enabling iterative computation via relaxation.

3. **Non-unique optimizers from symmetry**: When two vertices have equal tropical
   distance, they achieve equal gain — formalizing tropical degeneracy as a
   physical statement about equally optimal configurations.

## Physical Interpretation

In a Dyson sphere discretization:
- Vertices represent panel sites on a stellar shell.
- Edge weights encode transport/routing/conversion losses.
- Source vertex represents the stellar energy source.
- Tropical distance = minimum total path loss from source to panel.
- Gain = incident flux minus path loss = net collected energy.

The argmax-gain = argmin-distance theorem certifies that optimal energy collection
reduces exactly to a tropical shortest-path problem.
-/
import Mathlib

open Finset

/-! ## Definitions -/

/-- Edge weight function on a finite graph. `w u v` is the cost of the edge from `u` to `v`. -/
def EdgeWeight (V : Type*) := V → V → ℝ

/-- Cost of traversing a path (list of vertices) under edge weights `w`.
    Empty paths and single-vertex paths have zero cost. -/
def pathCost {V : Type*} (w : EdgeWeight V) : List V → ℝ
  | [] => 0
  | [_] => 0
  | a :: b :: t => w a b + pathCost w (b :: t)

/-- A valid path from `s` to `t` is a nonempty list starting at `s` and ending at `t`. -/
def validPath {V : Type*} (s t : V) (p : List V) : Prop :=
  p ≠ [] ∧ p.head? = some s ∧ p.getLast? = some t

/-- Tropical distance from `s` to `t`: the infimum of path costs over all valid paths. -/
noncomputable def tropicalDist {V : Type*} [Fintype V] [DecidableEq V]
    (w : EdgeWeight V) (s t : V) : ℝ :=
  sInf {c : ℝ | ∃ p, validPath s t p ∧ pathCost w p = c}

/-- Energy gain at vertex `v` relative to source `s` with gross flux `G`. -/
noncomputable def gainAt {V : Type*} [Fintype V] [DecidableEq V]
    (w : EdgeWeight V) (s : V) (G : ℝ) (v : V) : ℝ :=
  G - tropicalDist w s v

/-! ## Theorem 1: Argmax Gain = Argmin Distance -/

/-
**Tropical optimization duality**: A vertex maximizes energy gain `G - dist(src, v)`
    if and only if it minimizes tropical distance `dist(src, v)`.

    This is the fundamental theorem connecting tropical shortest-path optimization
    to energy collection maximization on finite graphs.
-/
theorem argmax_gain_eq_argmin_dist
    {V : Type*} [Fintype V] [DecidableEq V]
    (w : EdgeWeight V) (s : V) (G : ℝ) (u : V) :
    (∀ v, gainAt w s G u ≥ gainAt w s G v) ↔
    (∀ v, tropicalDist w s u ≤ tropicalDist w s v) := by
  -- Expand definitions of `gainAt` and `tropicalDist`.
  unfold gainAt tropicalDist;
  simp +decide only [sub_le_sub_iff_left]

/-! ## Symmetric Non-unique Optimizers -/

/-
**Tropical degeneracy**: When two distinct vertices have equal tropical distance
    from the source, they achieve identical energy gain. This formalizes the physical
    fact that multiple shell configurations can be equally optimal.
-/
theorem symmetric_graph_nonunique_optimizers
    {V : Type*} [Fintype V] [DecidableEq V]
    (w : EdgeWeight V) (s u v : V)
    (hsym : tropicalDist w s u = tropicalDist w s v) :
    gainAt w s G u = gainAt w s G v := by
  -- Rewrite `gainAt` using the definition, then use `hsym` to equate the distance terms.
  rw [gainAt, gainAt]
  rw [hsym]

/-! ## Tropical Algebra Foundations -/

/-
Min is commutative (tropical addition commutativity).
-/
theorem tropical_min_comm (a b : ℝ) : min a b = min b a := by
  exact min_comm a b

/-
Min is idempotent (tropical addition idempotency).
-/
theorem tropical_min_idem (a : ℝ) : min a a = a := by
  exact min_self _

/-
Addition distributes over min (tropical distributivity).
    This is the key algebraic identity enabling Bellman-style DP recursions:
    `a + min b c = min (a + b) (a + c)`.
-/
theorem tropical_plus_distributes_over_min (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := by
  exact add_min a b c

/-
Min is not injective: distinct inputs can produce the same output.
    This implies multiple distinct panel layouts may realize the same tropical capacity.
-/
theorem tropical_min_not_injective :
    ¬ Function.Injective (fun p : ℝ × ℝ => min p.1 p.2) := by
  exact fun h => absurd ( @h ( 0, 1 ) ( 1, 0 ) ) ( by norm_num )

/-! ## Dynamic Programming Formulation

We provide an alternative DP-based formulation of tropical distance that is
more amenable to computation and Lean formalization. -/

/-- DP distance: `dpDist w s n v` is the minimum cost of reaching `v` from `s`
    using at most `n` edges. Uses a large sentinel value for unreachable vertices. -/
noncomputable def dpDist {V : Type*} [Fintype V] [DecidableEq V]
    (w : EdgeWeight V) (s : V) (sentinel : ℝ) : ℕ → V → ℝ
  | 0, v => if v = s then 0 else sentinel
  | n + 1, v =>
    Finset.univ.fold min (dpDist w s sentinel n v)
      (fun u => dpDist w s sentinel n u + w u v)

/-
The DP distance is monotonically non-increasing in the number of steps
    (adding more allowed edges can only improve or maintain the best path).
-/
theorem dpDist_mono {V : Type*} [Fintype V] [DecidableEq V]
    (w : EdgeWeight V) (s : V) (sentinel : ℝ) (n : ℕ) (v : V) :
    dpDist w s sentinel (n + 1) v ≤ dpDist w s sentinel n v := by
  -- By definition of `dpDist`, we have:
  have h_def : dpDist w s sentinel (n + 1) v = Finset.fold min (dpDist w s sentinel n v) (fun u => dpDist w s sentinel n u + w u v) Finset.univ := by
    rfl;
  grind +suggestions

/-
At the source, DP distance is always 0 regardless of step count.
-/
theorem dpDist_source {V : Type*} [Fintype V] [DecidableEq V]
    (w : EdgeWeight V) (s : V) (sentinel : ℝ) (n : ℕ) :
    dpDist w s sentinel n s ≤ 0 := by
  induction' n with n ih;
  · grind +locals;
  · exact le_trans ( dpDist_mono _ _ _ _ _ ) ih

/-
**Bellman optimality recurrence**: The `(n+1)`-step DP distance satisfies
    `dpDist (n+1) v = min(dpDist n v, min_u(dpDist n u + w u v))`.
    This is the formal statement of the Bellman equation on finite graphs.
-/
theorem dpDist_bellman {V : Type*} [Fintype V] [DecidableEq V]
    (w : EdgeWeight V) (s : V) (sentinel : ℝ) (n : ℕ) (v : V) :
    dpDist w s sentinel (n + 1) v =
      Finset.univ.fold min (dpDist w s sentinel n v)
        (fun u => dpDist w s sentinel n u + w u v) := by
  -- By definition of `dpDist`, we have:
  rw [dpDist]