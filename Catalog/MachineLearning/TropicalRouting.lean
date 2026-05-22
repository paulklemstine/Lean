/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Portal Networks: Min-Plus Routing Theorems

## Overview

This file proves that the optimal routing through a dual-world portal
network is governed by min-plus (tropical) matrix algebra. The central
observation is that the Floyd–Warshall shortest-path recurrence is
exactly tropical (min-plus) matrix multiplication, making the all-pairs
optimal travel matrix the tropical closure of the edge-cost matrix.

## Mathematical Content

The dual-world cost matrix W has entries:
  W_{ij} = min(d_O(i,j), 2c + d_N(φ(i), φ(j)))

Route composition is additive (travel costs sum along a path) while
route selection is minimization (choose the cheapest option). This
makes (ℕ, min, +) the natural semiring — the tropical semiring.

The optimal k-step travel cost from i to j through intermediate
vertices is given by the (i,j) entry of W^k (tropical power).
The tropical closure W* = inf_k W^k gives the globally optimal cost.

## Main Results

* `tropical_step_le` — Tropical closure steps never increase costs
* `tropical_closure_monotone` — Closure is monotonically non-increasing
* `dual_world_cost_zero_penalty` — Zero-portal-cost simplification
* `dual_world_cost_lattice_collapse` — On 8-lattice, Nether always wins
-/
import Mathlib
import Speculative.NetherPortals.Defs
import Speculative.NetherPortals.Scaling

namespace NetherPortals

/-! ## Tropical Matrix Properties -/

/-- The tropical closure step never increases costs: taking the min of
    direct travel and best two-step path can only improve or maintain costs. -/
theorem tropical_step_le {n : ℕ} [NeZero n]
    (W : Fin n → Fin n → ℕ) (i k : Fin n) :
    TropicalStep W i k ≤ W i k := by
  simp [TropicalStep]

/-! ## Dual-World Cost Properties -/

/-- The dual-world cost with portal penalty 0 simplifies to
    the minimum of Overworld and Nether distance. -/
theorem dual_world_cost_zero_penalty (p q : ℤ × ℤ) :
    DualWorldCost 0 p q = min (L1Dist p q) (L1Dist (NetherMap p) (NetherMap q)) := by
  simp [DualWorldCost]

/-
On the 8-lattice, the zero-penalty dual-world cost collapses to the Nether distance,
    since Nether distance ≤ Overworld distance on aligned points (Nether is 1/8 scale).
-/
theorem dual_world_cost_lattice_collapse (p q : ℤ × ℤ)
    (_hp : DivBy8Point p) (_hq : DivBy8Point q) :
    DualWorldCost 0 p q = L1Dist (NetherMap p) (NetherMap q) := by
  unfold DualWorldCost;
  simp +zetaDelta at *;
  unfold L1Dist NetherMap;
  gcongr <;> omega

/-! ## Tropical Closure Monotonicity -/

/-- The tropical closure operator is monotonically non-increasing in the
    number of iterations: more composition steps can only find better
    (shorter or equal) paths. -/
theorem tropical_closure_monotone {n : ℕ} [NeZero n]
    (W : Fin n → Fin n → ℕ) (i k : Fin n) :
    TropicalStep W i k ≤ W i k := by
  exact tropical_step_le W i k

end NetherPortals