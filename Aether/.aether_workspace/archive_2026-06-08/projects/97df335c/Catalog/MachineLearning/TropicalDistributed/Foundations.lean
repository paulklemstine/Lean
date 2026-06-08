/-
# Tropical Distributed Systems: Foundations

This file establishes the graph-theoretic and min-plus algebraic foundations
for a formal theory connecting tropical geometry to distributed computation.

**Key Insight**: In networks where communication latency dominates local computation,
execution time becomes a tropical (min-plus) metric invariant. The shortest-path
distance in the min-plus semiring governs information propagation, synchronization
barriers, and aggregation convergence.

## Main Definitions
- `TropicalDistributed.bellmanFord`: k-step shortest path distances (Bellman-Ford relaxation)
- `TropicalDistributed.shortestDist`: shortest-path distance on finite weighted digraphs
- `TropicalDistributed.eccentricity`: max shortest distance from a source node
- `TropicalDistributed.tropicalDiameter`: max eccentricity over all nodes

## Main Results
- `TropicalDistributed.shortestDist_self`: d(i,i) = 0 when w(i,i) = 0
- `TropicalDistributed.eccentricity_le_tropicalDiameter`: eccentricity ≤ diameter
- `TropicalDistributed.bellmanFord_antitone`: relaxation is monotonically non-increasing
- `TropicalDistributed.shortestDist_le_weight`: d(i,j) ≤ w(i,j)

## Cross-Domain Connections
- **Tropical Geometry**: shortestDist is the Kleene star of the min-plus adjacency matrix
- **Distributed Systems**: broadcast fronts are tropical wavefronts
- **Relativistic Computation**: latency geometry determines computational complexity
- **CRDT Semantics**: idempotent aggregation operators converge without consensus
-/

import Mathlib

open ENNReal

namespace TropicalDistributed

variable {n : ℕ}

/-! ## Bellman-Ford Relaxation

We define shortest-path distances via iterative relaxation (Bellman-Ford style).
Starting from the direct edge weights, each step considers whether routing through
an intermediate node reduces the distance. After at most n-1 steps on a graph
with n nodes and non-negative weights, this process stabilizes to the true
shortest-path distances.
-/

/-- Initial distance: direct edge weight. -/
noncomputable def dist₀ (w : Fin n → Fin n → ℝ≥0∞) (i j : Fin n) : ℝ≥0∞ :=
  if i = j then 0 else w i j

/-- One step of Bellman-Ford relaxation: try routing through any intermediate node k. -/
noncomputable def relaxStep (w : Fin n → Fin n → ℝ≥0∞)
    (d : Fin n → Fin n → ℝ≥0∞) (i j : Fin n) : ℝ≥0∞ :=
  d i j ⊓ (⨅ k : Fin n, d i k + w k j)

/-- k-step Bellman-Ford distances. -/
noncomputable def bellmanFord (w : Fin n → Fin n → ℝ≥0∞) : ℕ → Fin n → Fin n → ℝ≥0∞
  | 0 => dist₀ w
  | k + 1 => relaxStep w (bellmanFord w k)

/-- Shortest-path distance: the limit of Bellman-Ford relaxation. -/
noncomputable def shortestDist (w : Fin n → Fin n → ℝ≥0∞) (i j : Fin n) : ℝ≥0∞ :=
  ⨅ k : ℕ, bellmanFord w k i j

/-- Eccentricity of a node: the maximum shortest-path distance from it to any other node.
    In the distributed systems interpretation, this is the time for a broadcast from
    this node to reach all other nodes. -/
noncomputable def eccentricity (w : Fin n → Fin n → ℝ≥0∞) (i : Fin n) : ℝ≥0∞ :=
  ⨆ j : Fin n, shortestDist w i j

/-- Tropical diameter: the maximum eccentricity over all nodes.
    This is the fundamental complexity invariant — it controls the worst-case
    synchronization cost in any distributed computation over the network. -/
noncomputable def tropicalDiameter (w : Fin n → Fin n → ℝ≥0∞) : ℝ≥0∞ :=
  ⨆ i : Fin n, eccentricity w i

/-! ## Basic Properties -/

/-- The initial distance from a node to itself is zero. -/
theorem dist₀_self (w : Fin n → Fin n → ℝ≥0∞) (i : Fin n) :
    dist₀ w i i = 0 := by
  simp [dist₀]

/-- Bellman-Ford distance from a node to itself is zero at step 0. -/
theorem bellmanFord_zero_self (w : Fin n → Fin n → ℝ≥0∞) (i : Fin n) :
    bellmanFord w 0 i i = 0 := by
  simp [bellmanFord, dist₀]

/-- Relaxation never increases distances. -/
theorem relaxStep_le (w : Fin n → Fin n → ℝ≥0∞)
    (d : Fin n → Fin n → ℝ≥0∞) (i j : Fin n) :
    relaxStep w d i j ≤ d i j := by
  exact inf_le_left

/-- Bellman-Ford distances are non-increasing in the step count. -/
theorem bellmanFord_antitone (w : Fin n → Fin n → ℝ≥0∞) (i j : Fin n) :
    ∀ k, bellmanFord w (k + 1) i j ≤ bellmanFord w k i j := by
  intro k
  simp [bellmanFord]
  exact relaxStep_le w (bellmanFord w k) i j

/-- Shortest distance is at most the direct edge weight (for i ≠ j). -/
theorem shortestDist_le_weight (w : Fin n → Fin n → ℝ≥0∞) (i j : Fin n) (h : i ≠ j) :
    shortestDist w i j ≤ w i j := by
  unfold shortestDist
  apply iInf_le_of_le 0
  simp [bellmanFord, dist₀, h]

/-- Shortest distance from a node to itself is zero. -/
theorem shortestDist_self (w : Fin n → Fin n → ℝ≥0∞) (i : Fin n) :
    shortestDist w i i = 0 := by
  unfold shortestDist
  apply le_antisymm
  · apply iInf_le_of_le 0
    simp [bellmanFord, dist₀]
  · exact zero_le _

/-- Eccentricity of any node is at most the tropical diameter. -/
theorem eccentricity_le_tropicalDiameter (w : Fin n → Fin n → ℝ≥0∞) (i : Fin n) :
    eccentricity w i ≤ tropicalDiameter w := by
  exact le_iSup (fun i => eccentricity w i) i

/-- Shortest distance from source to any node is at most the eccentricity of source. -/
theorem shortestDist_le_eccentricity (w : Fin n → Fin n → ℝ≥0∞) (i j : Fin n) :
    shortestDist w i j ≤ eccentricity w i := by
  exact le_iSup (fun j => shortestDist w i j) j

/-- Shortest distance between any pair is at most the diameter. -/
theorem shortestDist_le_tropicalDiameter (w : Fin n → Fin n → ℝ≥0∞) (i j : Fin n) :
    shortestDist w i j ≤ tropicalDiameter w := by
  calc shortestDist w i j ≤ eccentricity w i := shortestDist_le_eccentricity w i j
    _ ≤ tropicalDiameter w := eccentricity_le_tropicalDiameter w i

/-- The tropical diameter is the supremum of all pairwise shortest distances. -/
theorem tropicalDiameter_eq_iSup_iSup (w : Fin n → Fin n → ℝ≥0∞) :
    tropicalDiameter w = ⨆ i : Fin n, ⨆ j : Fin n, shortestDist w i j := by
  simp [tropicalDiameter, eccentricity]

end TropicalDistributed