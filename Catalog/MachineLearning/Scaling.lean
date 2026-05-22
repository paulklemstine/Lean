/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Portal Networks: Exact Scaling Theorems

## Overview

This file proves the fundamental scaling law that underpins the tropical
portal network theory: the Manhattan distance between lifted Nether
coordinates is exactly 8 times the Manhattan distance between the
original Nether coordinates.

This is the rigorous mathematical content of the folklore statement
"the Nether is 8× compressed relative to the Overworld." In the language
of tropical geometry, 8 is the **tropical scaling factor** of the
Nether metric embedding.

## Main Results

* `lift_scaling_exact` — L1Dist(LiftOver p, LiftOver q) = 8 * L1Dist(p, q)
* `nether_scaling_exact` — On the 8-lattice, Nether distance × 8 = Overworld distance
* `netherMap_liftOver` — NetherMap ∘ LiftOver = id
* `L1Dist_self` — L1Dist(p, p) = 0
* `L1Dist_symm` — L1Dist is symmetric
* `L1Dist_triangle` — Triangle inequality for L1Dist
* `nether_scaling_rounding_error_bound` — Rounding distortion bounded by 14
* `nether_beats_overworld_beyond_threshold` — Portal threshold theorem
-/
import Mathlib
import Speculative.NetherPortals.Defs

namespace NetherPortals

/-! ## Basic Properties of L1Dist -/

/-- L1Dist of a point with itself is zero. -/
theorem L1Dist_self (p : ℤ × ℤ) : L1Dist p p = 0 := by
  simp [L1Dist]

/-
L1Dist is symmetric.
-/
theorem L1Dist_symm (p q : ℤ × ℤ) : L1Dist p q = L1Dist q p := by
  unfold L1Dist;
  grind +locals

/-
L1Dist satisfies the triangle inequality.
-/
theorem L1Dist_triangle (p q r : ℤ × ℤ) : L1Dist p r ≤ L1Dist p q + L1Dist q r := by
  unfold L1Dist;
  bv_omega

/-! ## Exact Scaling Theorem (Main Result) -/

/-
**Theorem 1 (Exact Tropical Scaling).**
The Manhattan distance between lifted Nether coordinates is exactly
8 times the Manhattan distance between the original Nether coordinates.

This is the clean algebraic form of the 1:8 scaling law. Formally:
  `d_O(LiftOver(p), LiftOver(q)) = 8 · d_N(p, q)`

where `LiftOver(x,z) = (8x, 8z)` is the Overworld lifting map.
-/
theorem lift_scaling_exact (p q : ℤ × ℤ) :
    L1Dist (LiftOver p) (LiftOver q) = 8 * L1Dist p q := by
  unfold L1Dist LiftOver;
  norm_num [ ← mul_sub, Int.natAbs_mul ] ; ring

/-
NetherMap is a left inverse of LiftOver:
    mapping to Overworld and back to Nether recovers the original point.
-/
theorem netherMap_liftOver (p : ℤ × ℤ) : NetherMap (LiftOver p) = p := by
  unfold NetherMap LiftOver; norm_num;

/-
**Corollary: Exact scaling on the 8-lattice.**
For Overworld points whose coordinates are divisible by 8,
the Nether distance times 8 equals the Overworld distance exactly.
-/
theorem nether_scaling_exact (p q : ℤ × ℤ)
    (hp : DivBy8Point p) (hq : DivBy8Point q) :
    L1Dist (NetherMap p) (NetherMap q) * 8 = L1Dist p q := by
  -- Unfold the definitions of `L1Dist` and `NetherMap`: for `p=(x,z)` and `q=(x',z')`, we need to show
  -- `(x//8 - x'//8 + z//8 - z'//8) * 8 = |x-x'| + |z-z'|`
  dsimp [L1Dist, NetherMap];
  rcases hp with ⟨ ⟨ a, ha ⟩, ⟨ b, hb ⟩ ⟩ ; rcases hq with ⟨ ⟨ c, hc ⟩, ⟨ d, hd ⟩ ⟩ ; simp +decide [*];
  grind

/-! ## Rounding Error Bound -/

/-
**Bounded rounding distortion.**
For arbitrary integer Overworld coordinates, integer division by 8
introduces at most 14 units of absolute error in the 8× scaled distance.

The bound 14 = 2 × 7 arises because each of two coordinates can have
remainder at most 7 when divided by 8, contributing at most 7 to the
error in each coordinate's absolute difference.
-/
theorem nether_scaling_rounding_error_bound (p q : ℤ × ℤ) :
    Int.natAbs ((L1Dist p q : ℤ) - 8 * (L1Dist (NetherMap p) (NetherMap q) : ℤ)) ≤ 14 := by
  unfold L1Dist NetherMap;
  grind

/-! ## Portal Threshold Theorem -/

/-
**Portal-entry penalty phase transition.**
When twice the portal cost is less than 7 times the base distance,
Nether travel (cost: 2c + d) strictly dominates Overworld travel (cost: 8d).

This captures the economic threshold: portals are worth building
only when the destination is sufficiently far.
-/
theorem nether_beats_overworld_beyond_threshold
    (c d : ℕ) (h : 2 * c < 7 * d) :
    2 * c + d < 8 * d := by
  linarith

end NetherPortals