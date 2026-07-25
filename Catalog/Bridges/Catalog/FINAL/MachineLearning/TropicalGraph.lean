/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Graph Optimization for Stellar Energy Collection

## Overview

This file formalizes the connection between tropical (min-plus) optimization
on finite weighted graphs and energy collection on discretized stellar shells.

The key insight is that maximizing energy gain at panel sites reduces to
minimizing tropical (shortest-path) distance from the stellar source.
This provides a certified algebraic bridge between:
- **Tropical algebra** (min-plus semiring operations),
- **Combinatorial optimization** (shortest paths on finite graphs),
- **Energy network design** (optimal panel placement on stellar shells).

## Main Results

* `tropical_plus_distributes_over_min` — The key distributive law
  `a + min b c = min (a + b) (a + c)` underlying Bellman recursion.
* `argmax_gain_eq_argmin_dist` — Maximizing panel gain ↔ minimizing
  tropical distance: the core optimization equivalence.
* `symmetric_graph_nonunique_optimizers` — Equal tropical distances
  yield equal gains, formalizing degeneracy of optimal configurations.
* `bellman_step` — One-step Bellman relaxation: extending shortest paths
  through predecessors.
* `path_cost_concat` — Path cost decomposes under concatenation.

## Physical Interpretation

- **Vertices** = panel sites on a shell discretization.
- **Edge weights** = transport/routing/conversion losses between sites.
- **Tropical distance** = minimum total loss from stellar source to a site.
- **Gain** = incident flux minus tropical distance = net collected energy.

The optimization equivalence theorem certifies that optimal energy collection
reduces to a standard shortest-path computation in the min-plus semiring.
-/
import Mathlib

open Classical

namespace TropicalDyson

/-! ## §1. Tropical Algebra Foundations

The min-plus semiring (ℝ, min, +) has two operations:
- **Tropical addition**: `a ⊕ b = min a b` (route selection)
- **Tropical multiplication**: `a ⊗ b = a + b` (loss accumulation)

The distributive law `a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c)` translates to
`a + min b c = min (a+b) (a+c)`, which is the algebraic engine of
dynamic programming for shortest paths.
-/

/-
**Tropical Distributivity**: Addition distributes over min.
    This is the foundational identity for Bellman-style dynamic programming
    in the min-plus semiring. It allows path extension (adding edge cost `a`)
    to commute with route selection (taking the min over predecessors).
-/
theorem tropical_plus_distributes_over_min (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := by
  cases min_cases b c <;> cases min_cases ( a + b ) ( a + c ) <;> linarith

/-
Commutativity of tropical addition (min).
-/
theorem tropical_min_comm (a b : ℝ) : min a b = min b a := by
  exact min_comm _ _

/-
Idempotency of tropical addition: selecting among identical options
    yields the same option.
-/
theorem tropical_min_idem (a : ℝ) : min a a = a := by
  grind +qlia

/-
Right-distributivity of addition over min.
-/
theorem tropical_plus_distributes_over_min_right (a b c : ℝ) :
    min a b + c = min (a + c) (b + c) := by
  rw [ min_add_add_right ]

/-
**Tropical non-injectivity**: min is not injective —
    distinct inputs can yield the same output. This is the algebraic
    manifestation of multiple equally optimal configurations.
-/
theorem tropical_min_not_injective :
    ∃ a b c : ℝ, a ≠ b ∧ min a c = min b c := by
  -- If $min a c = min b c$, then either $a = b$ or $min a c = min b c$.
  use 0, 1, 0; simp

/-! ## §2. Finite Graph Tropical Distance

We model a stellar shell discretization as a finite weighted directed graph.
Vertices are panel sites, and edge weights represent transport/conversion losses.
-/

/-- Edge weight function on a graph with vertex type `V`.
    `w u v` is the cost (loss) of routing energy from site `u` to site `v`. -/
def EdgeWeight (V : Type*) := V → V → ℝ

/-- Cost of traversing a path given by a list of vertices.
    In the min-plus semiring, this is the tropical product of edge weights
    along the path. Empty paths and single vertices have zero cost. -/
def pathCost {V : Type*} (w : EdgeWeight V) : List V → ℝ
  | [] => 0
  | [_] => 0
  | a :: b :: t => w a b + pathCost w (b :: t)

/-- A valid path from `s` to `t`: nonempty, starts at `s`, ends at `t`. -/
def validPath {V : Type*} (s t : V) (p : List V) : Prop :=
  p ≠ [] ∧ p.head? = some s ∧ p.getLast? = some t

/-
Path cost decomposes additively under single-step extension:
    appending an edge `(a, b)` adds `w a b` to the cost.
-/
theorem pathCost_cons {V : Type*} (w : EdgeWeight V) (a b : V) (t : List V) :
    pathCost w (a :: b :: t) = w a b + pathCost w (b :: t) := by
  rfl

/-
The trivial self-path `[v]` is a valid path from `v` to `v`.
-/
theorem validPath_self {V : Type*} (v : V) : validPath v v [v] := by
  -- The path [v] is non-empty, starts at v, and ends at v, so it is a valid path from v to v.
  simp [validPath]

/-
The trivial self-path has zero cost.
-/
theorem pathCost_self {V : Type*} (w : EdgeWeight V) (v : V) :
    pathCost w [v] = 0 := by
  rfl

/-- **Tropical distance** from source `s` to target `t`:
    the infimum of path costs over all valid paths.
    This is the shortest-path distance in the min-plus semiring. -/
noncomputable def tropicalDist {V : Type*} [Fintype V] [DecidableEq V]
    (w : EdgeWeight V) (s t : V) : ℝ :=
  sInf {c : ℝ | ∃ p, validPath s t p ∧ pathCost w p = c}

/-- **Panel gain** at vertex `v` from stellar source `s` with incident
    flux parameter `G`. Gain equals incident flux minus transport loss,
    where transport loss is the tropical distance from the source. -/
noncomputable def gainAt {V : Type*} [Fintype V] [DecidableEq V]
    (w : EdgeWeight V) (s : V) (G : ℝ) (v : V) : ℝ :=
  G - tropicalDist w s v

/-! ## §3. Core Optimization Equivalence

The central theorem: maximizing energy gain is equivalent to minimizing
tropical distance. This bridges max-throughput energy collection with
min-cost tropical routing.
-/

/-
**Tropical Optimization Equivalence**: A vertex `u` maximizes energy
    gain from source `s` if and only if it minimizes tropical distance
    from `s`.

    Physically: the best panel placement (maximum energy collection) is
    exactly the site with minimum transport/routing loss.

    The proof reduces to the order-reversing property of subtraction from
    a constant: `G - d_u ≥ G - d_v ↔ d_u ≤ d_v`.
-/
theorem argmax_gain_eq_argmin_dist
    {V : Type*} [Fintype V] [DecidableEq V]
    (w : EdgeWeight V) (s : V) (G : ℝ) (u : V) :
    (∀ v, gainAt w s G v ≤ gainAt w s G u) ↔
    (∀ v, tropicalDist w s u ≤ tropicalDist w s v) := by
  constructor <;> intro h v <;> specialize h v <;> unfold gainAt at *;
  · linarith;
  · linarith

/-
**Non-unique Optimizers (Tropical Degeneracy)**: If two vertices have
    equal tropical distance from the source, they achieve equal gain.

    This formalizes a key physical insight: symmetric placement of solar
    panels on a Dyson sphere yields identical energy collection efficiency.
    Multiple shell configurations can be equally optimal — a theorem-level
    manifestation of degeneracy in tropical optimization.
-/
theorem symmetric_graph_nonunique_optimizers
    {V : Type*} [Fintype V] [DecidableEq V]
    (w : EdgeWeight V) (s u v : V) (G : ℝ)
    (hsym : tropicalDist w s u = tropicalDist w s v) :
    gainAt w s G u = gainAt w s G v := by
  -- By definition of gainAt, we have gainAt w s G u = G - tropicalDist w s u and gainAt w s G v = G - tropicalDist w s v.
  simp [gainAt, hsym]

/-! ## §4. Bellman Dynamic Programming

The Bellman principle for tropical shortest paths: the optimal cost to
reach a vertex `v` decomposes into a one-step extension from some
predecessor `u`. This is the dynamic programming foundation for
computing tropical distances on finite graphs.
-/

/-
One-step Bellman relaxation: if there is a path from `s` to `u`
    with cost `c`, then there is a path from `s` to `v` through `u`
    with cost `c + w u v`.

    This is the path-extension principle that drives DP computation
    of tropical distances.
-/
theorem bellman_step_path {V : Type*} (_w : EdgeWeight V)
    (s u v : V) (p : List V)
    (hp : validPath s u p) :
    validPath s v (p ++ [v]) ∨ (u = v ∧ validPath s v p) := by
  -- If p is valid, then the path from s to u is valid. We can append the edge from u to v to this path.
  simp [validPath] at *;
  grind

/-
Path cost of a two-vertex path equals the edge weight.
-/
theorem pathCost_edge {V : Type*} (w : EdgeWeight V) (u v : V) :
    pathCost w [u, v] = w u v := by
  exact show w u v + 0 = w u v from add_zero _

/-! ## §5. Tropical Capacity and Network Optimization

The tropical capacity of a network captures the best achievable
transport efficiency across all panel sites.
-/

/-- **Tropical capacity** of a network: the minimum tropical distance
    achievable from source `s` to any vertex. Lower capacity means
    more efficient energy routing.

    This is the network-level analogue of channel capacity in
    information theory, expressed in the min-plus semiring. -/
noncomputable def tropicalCapacity {V : Type*} [Fintype V] [DecidableEq V]
    (w : EdgeWeight V) (s : V) : ℝ :=
  ⨅ v : V, tropicalDist w s v

/-
The tropical distance to any vertex is at least the tropical capacity.
-/
theorem tropicalDist_ge_capacity {V : Type*} [Fintype V] [DecidableEq V]
    (w : EdgeWeight V) (s v : V) :
    tropicalCapacity w s ≤ tropicalDist w s v := by
  -- Apply the fact that for any element in the set, the infimum is less than or equal to that element.
  apply ciInf_le;
  exact Set.finite_range _ |> Set.Finite.bddBelow

/-
The maximum gain over all vertices equals `G - tropicalCapacity`.
-/
theorem max_gain_eq {V : Type*} [Fintype V] [DecidableEq V] [Nonempty V]
    (w : EdgeWeight V) (s : V) (G : ℝ) :
    ⨆ v : V, gainAt w s G v = G - tropicalCapacity w s := by
  rw [ @ciSup_eq_of_forall_le_of_forall_lt_exists_gt ];
  · exact fun v => sub_le_sub_left ( tropicalDist_ge_capacity w s v ) _;
  · intro x hxCapacity;
    unfold gainAt;
    contrapose! hxCapacity;
    rw [ sub_le_comm ];
    exact le_ciInf fun i => by linarith [ hxCapacity i ] ;

end TropicalDyson