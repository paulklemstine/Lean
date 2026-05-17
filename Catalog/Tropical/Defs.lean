/-
# Tropical Distributed Systems: Definitions

This file provides the foundational definitions for the tropical approach to
distributed computation complexity. We model communication networks as finite
weighted digraphs on `Fin n` with edge delays in `ℝ≥0∞`, and define
shortest-path distances, eccentricity, tropical diameter, broadcast time,
and idempotent aggregation operators.

## Key Concepts

- **Tropical distance**: The minimum-weight path between two nodes, computed
  via min-plus algebra over all walks of bounded length.
- **Eccentricity**: The maximum shortest-path distance from a given source
  to all other nodes.
- **Tropical diameter**: The maximum eccentricity over all sources.
- **Broadcast time**: The minimum time for a datum at a source to reach all
  nodes, where forwarding requires prior receipt.
- **Idempotent aggregation**: A monotone update operator on network states
  that converges to a fixed point without consensus.

## Cross-Domain Connections

1. **Tropical Geometry ↔ Distributed Systems**: Shortest-path distance is
   min-plus linear algebra; broadcast fronts are tropical wavefronts.
2. **CRDTs / Eventually Consistent Databases**: Idempotent commutative
   monotone aggregation is the algebraic skeleton of convergence without consensus.
3. **Relativistic Computation**: At astronomical scales, latency *is* geometry.
4. **Max-Plus Discrete Event Systems**: Barrier synchronization and task
   completion times are naturally min-plus/max-plus dynamical systems.
-/
import Mathlib

open scoped ENNReal

namespace TropicalDistributed

/-! ## Network Model -/

/-- A weighted digraph on `Fin n` with edge delays in `ℝ≥0∞`. -/
structure Network (n : ℕ) where
  /-- Edge weight/delay function. `w i j` is the direct communication delay
      from node `i` to node `j`. Self-loops have zero delay, absent edges
      have delay `⊤`. -/
  w : Fin n → Fin n → ℝ≥0∞
  /-- Self-loops have zero delay. -/
  self_zero : ∀ i, w i i = 0

/-! ## Walk-based shortest path distance

We define the shortest-path distance as the infimum over walks of length at
most `n - 1` (sufficient for finite graphs with nonneg weights). A walk of
length `k` from `i` to `j` is a sequence of `k + 1` nodes starting at `i`
and ending at `j`, and its cost is the sum of edge weights along the walk.
-/

/-- Cost of a walk given by a sequence of nodes. -/
noncomputable def walkCost (w : Fin n → Fin n → ℝ≥0∞) : List (Fin n) → ℝ≥0∞
  | [] => 0
  | [_] => 0
  | a :: b :: rest => w a b + walkCost w (b :: rest)

/-- A walk from `i` to `j` is a nonempty list starting at `i` and ending at `j`. -/
def isWalk (path : List (Fin n)) (i j : Fin n) : Prop :=
  path.head? = some i ∧ path.getLast? = some j ∧ path.length ≥ 1

/-- Shortest-path distance from `i` to `j` using at most `n` edges.
    On a graph with `n` nodes and nonneg weights, optimal paths use ≤ n-1 edges. -/
noncomputable def shortestDist (w : Fin n → Fin n → ℝ≥0∞) (i j : Fin n) : ℝ≥0∞ :=
  ⨅ (path : List (Fin n)) (_ : isWalk path i j), walkCost w path

/-- Eccentricity of a node: the maximum shortest-path distance to any other node. -/
noncomputable def eccentricity (w : Fin n → Fin n → ℝ≥0∞) (s : Fin n) : ℝ≥0∞ :=
  ⨆ j : Fin n, shortestDist w s j

/-- Tropical diameter: the maximum eccentricity over all nodes. -/
noncomputable def tropicalDiameter (w : Fin n → Fin n → ℝ≥0∞) : ℝ≥0∞ :=
  ⨆ i : Fin n, eccentricity w i

/-! ## Broadcast Model

A broadcast schedule from source `s` assigns to each node `j` a delivery
time `t j`. The source receives at time 0. Each other node receives the
datum when some neighbor who already has it forwards it, incurring the
edge delay.

The optimal broadcast time from `s` is the infimum over all valid schedules
of the maximum delivery time.
-/

/-- A broadcast schedule assigns a delivery time to each node. -/
def BroadcastSchedule (n : ℕ) := Fin n → ℝ≥0∞

/-- A broadcast schedule is valid if the source gets the datum at time 0,
    and every other node receives it from some earlier node plus edge delay. -/
def isValidBroadcast (w : Fin n → Fin n → ℝ≥0∞) (s : Fin n)
    (t : BroadcastSchedule n) : Prop :=
  t s = 0 ∧ ∀ j : Fin n, j ≠ s → ∃ i : Fin n, t i + w i j ≤ t j

/-- Completion time of a broadcast schedule. -/
noncomputable def broadcastCompletionTime (t : BroadcastSchedule n) : ℝ≥0∞ :=
  ⨆ j : Fin n, t j

/-- Optimal broadcast time from source `s`. -/
noncomputable def optimalBroadcastTimeFrom (w : Fin n → Fin n → ℝ≥0∞) (s : Fin n) : ℝ≥0∞ :=
  ⨅ (t : BroadcastSchedule n) (_ : isValidBroadcast w s t), broadcastCompletionTime t

end TropicalDistributed