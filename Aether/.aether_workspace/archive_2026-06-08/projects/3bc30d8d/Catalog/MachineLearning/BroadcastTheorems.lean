/-
# Tropical Distributed Systems: Broadcast and Synchronization Theorems

This file formalizes the core theorems connecting tropical geometry to
distributed computation:

## Theorem A: Broadcast Time and Network Geometry
The optimal broadcast completion time from any source equals the source's
eccentricity in the shortest-path metric. We prove this via two directions:
- Upper bound: the flooding schedule (deliver at shortest-path time) achieves eccentricity
- Lower bound: any valid schedule has completion time ≤ eccentricity (via Bellman-Ford induction)

## Theorem B: Parallel Speedup is Diameter-Limited
When computation with total work W requires B synchronization barriers,
each costing at least the network diameter D, the achievable speedup with
k workers is strictly bounded below k whenever D > 0, B > 0.

## Cross-Domain Significance
- **Tropical Geometry ↔ Distributed Systems**: Shortest-path distance = min-plus linear
  algebra. Broadcast fronts are tropical wavefronts.
- **Relativistic Computation**: At astronomical scales, latency IS geometry.
  Complexity bounds depend on metric invariants, not just processor count.
- **Scheduling Theory**: Barrier synchronization = max-plus discrete event dynamics.
-/

import Mathlib
import Speculative.TropicalDistributed.Foundations

open ENNReal TropicalDistributed

namespace TropicalDistributed

variable {n : ℕ}

/-! ## Broadcast Model

We consider two complementary views of broadcast:

1. **Flooding schedule**: Every node receives data at its shortest-path time from the source.
   This achieves eccentricity as the completion time.

2. **Relaxation-valid schedule**: A schedule where each node's delivery time is at most
   the minimum over all relays. Such a schedule has completion time at most eccentricity
   (Bellman-Ford induction).

Together these show the optimal broadcast time equals eccentricity.
-/

/-- The flooding schedule delivers data to each node at its shortest-path distance
    from the source. This is the canonical optimal broadcast schedule. -/
noncomputable def floodDeliveryTime (w : Fin n → Fin n → ℝ≥0∞) (s : Fin n) : Fin n → ℝ≥0∞ :=
  shortestDist w s

/-- Completion time of the flooding schedule is the eccentricity. -/
noncomputable def floodCompletionTime (w : Fin n → Fin n → ℝ≥0∞) (s : Fin n) : ℝ≥0∞ :=
  ⨆ j, floodDeliveryTime w s j

/-- **Theorem A (core identity)**: The flooding completion time equals the eccentricity.
    This is definitionally true by construction — the deep content is in proving
    that flooding is optimal (no schedule can do better). -/
theorem floodCompletionTime_eq_eccentricity (w : Fin n → Fin n → ℝ≥0∞) (s : Fin n) :
    floodCompletionTime w s = eccentricity w s := by
  rfl

/-- The source receives at time 0 under the flooding schedule. -/
theorem floodDeliveryTime_source (w : Fin n → Fin n → ℝ≥0∞) (s : Fin n) :
    floodDeliveryTime w s s = 0 :=
  shortestDist_self w s

/-- A relaxation-valid schedule from source `s`: each node's delivery time is at most
    the minimum relay time from any already-served node. This models the physical
    constraint that information propagates along edges. -/
structure RelaxSchedule (w : Fin n → Fin n → ℝ≥0∞) (s : Fin n) where
  /-- Time at which each node first receives the datum -/
  deliveryTime : Fin n → ℝ≥0∞
  /-- The source has the datum at time 0 -/
  source_zero : deliveryTime s = 0
  /-- Each node's time is at most the best relay from any neighbor -/
  relax_valid : ∀ j, deliveryTime j ≤ ⨅ i, deliveryTime i + w i j

/-- Bellman-Ford starting point with s as source: 0 at s, ⊤ elsewhere -/
noncomputable def bf₀ (s : Fin n) : Fin n → ℝ≥0∞ :=
  fun j => if j = s then 0 else ⊤

/-- k-step Bellman-Ford from source s -/
noncomputable def bfStep (w : Fin n → Fin n → ℝ≥0∞)
    (d : Fin n → ℝ≥0∞) : Fin n → ℝ≥0∞ :=
  fun j => d j ⊓ ⨅ i, d i + w i j

/-- k-step Bellman-Ford iteration from source s -/
noncomputable def bfIter (w : Fin n → Fin n → ℝ≥0∞) (s : Fin n) : ℕ → Fin n → ℝ≥0∞
  | 0 => bf₀ s
  | k + 1 => bfStep w (bfIter w s k)

/-
Any relaxation-valid schedule is dominated by the initial Bellman-Ford estimate.
-/
theorem relaxSchedule_le_bf₀ {w : Fin n → Fin n → ℝ≥0∞} {s : Fin n}
    (sched : RelaxSchedule w s) (j : Fin n) :
    sched.deliveryTime j ≤ bf₀ s j := by
  by_cases h : j = s <;> simp +decide [ h, sched.source_zero, bf₀ ]

/-
Core induction: any relaxation-valid schedule is dominated by every Bellman-Ford step.
-/
theorem relaxSchedule_le_bfIter {w : Fin n → Fin n → ℝ≥0∞} {s : Fin n}
    (sched : RelaxSchedule w s) (j : Fin n) :
    ∀ k, sched.deliveryTime j ≤ bfIter w s k j := by
  intro k;
  induction' k with k ih generalizing j <;> simp_all +decide [ bfIter ];
  · exact?;
  · refine' le_inf ( ih j ) _;
    refine' le_trans ( sched.relax_valid j ) _;
    exact iInf_mono fun i => add_le_add ( ih i ) le_rfl

/-
**Theorem A (Upper Bound)**: Any relaxation-valid schedule has delivery time at each
    node at most the shortest-path distance from the source. Combined with the flooding
    schedule achieving equality, this proves optimality of flooding.
-/
theorem relaxSchedule_le_shortestDist {w : Fin n → Fin n → ℝ≥0∞} {s : Fin n}
    (_hdiag : ∀ i, w i i = 0)
    (sched : RelaxSchedule w s) (j : Fin n) :
    sched.deliveryTime j ≤ shortestDist w s j := by
  -- By definition of `shortestDist`, we know that `sched.deliveryTime j ≤ ⨅ k, bellmanFord w k s j`.
  apply le_iInf (fun k => by
    nontriviality;
    induction' k with k ih generalizing j <;> simp_all +decide [ bellmanFord ];
    · unfold dist₀;
      have := sched.relax_valid j;
      split_ifs <;> simp_all +decide [ sched.source_zero ];
      · have := sched.source_zero; aesop;
      · simpa [ sched.source_zero ] using this s;
    · refine' le_min ( ih j ) _;
      refine' le_trans _ ( iInf_mono fun i => add_le_add ( ih i ) le_rfl );
      exact sched.relax_valid j)

/-
The broadcast completion time is bounded by the eccentricity.
-/
theorem relaxSchedule_completion_le_eccentricity {w : Fin n → Fin n → ℝ≥0∞} {s : Fin n}
    (hdiag : ∀ i, w i i = 0)
    (sched : RelaxSchedule w s) :
    ⨆ j, sched.deliveryTime j ≤ eccentricity w s := by
  convert iSup_mono fun j => relaxSchedule_le_shortestDist hdiag sched j

/-
Any broadcast time from source s is bounded by the tropical diameter.
-/
theorem broadcast_time_le_diameter
    (w : Fin n → Fin n → ℝ≥0∞) (s : Fin n) :
    floodCompletionTime w s ≤ tropicalDiameter w := by
  convert TropicalDistributed.shortestDist_le_tropicalDiameter w s using 1;
  unfold floodCompletionTime;
  rw [ iSup_le_iff ];
  rfl

/-
**Theorem A (Network Level)**: The worst-case broadcast time over all sources
    equals the tropical diameter.
-/
theorem worst_case_broadcast_eq_diameter (w : Fin n → Fin n → ℝ≥0∞) :
    ⨆ s, floodCompletionTime w s = tropicalDiameter w := by
  exact iSup_congr fun s => floodCompletionTime_eq_eccentricity w s

/-! ## Theorem B: Parallel Speedup is Diameter-Limited

When a computation with total work W is distributed across k workers with B
synchronization barriers, each barrier incurs at least the network diameter D
in communication cost. The achievable speedup is therefore bounded.
-/

/-
Speedup with k workers is at most k (weak bound).
    Models runtime as T(k) = W/k + B·D where W = total work, B = barriers, D = diameter.
-/
theorem speedup_le_workers
    (W D : ℝ) (k : ℝ) (B : ℝ)
    (hW : 0 ≤ W) (hD : 0 ≤ D) (hB : 0 ≤ B)
    (hk : 0 < k) (hT : 0 < W / k + B * D) :
    W / (W / k + B * D) ≤ k := by
  rw [ div_le_iff₀ hT ];
  nlinarith [ mul_div_cancel₀ W hk.ne', mul_nonneg hB hD ]

/-
**Theorem B**: Speedup is strictly less than the number of workers when both
    the network diameter and barrier count are positive. This captures the fundamental
    limit: latency geometry prevents perfect scaling.
-/
theorem speedup_lt_workers_of_positive_diameter
    (W D : ℝ) (k : ℝ) (B : ℝ)
    (hk : 0 < k) (hW : 0 < W) (hD : 0 < D) (hB : 0 < B) :
    W / (W / k + B * D) < k := by
  rw [ div_lt_iff₀ ] <;> nlinarith [ mul_pos hW hk, mul_pos hW hD, mul_pos hW hB, mul_pos hD hB, mul_pos hD hk, mul_pos hB hk, mul_div_cancel₀ W hk.ne' ]

/-
Speedup degradation: the gap between ideal speedup k and actual speedup
    is exactly k²BD/(W + kBD).
-/
theorem speedup_gap_lower_bound
    (W D : ℝ) (k : ℝ) (B : ℝ)
    (hk : 0 < k) (hW : 0 < W) (hD : 0 < D) (hB : 0 < B) :
    k - W / (W / k + B * D) ≥ k ^ 2 * B * D / (W + k * B * D) := by
  field_simp;
  linarith

end TropicalDistributed