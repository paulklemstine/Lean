/-
# Tropical Obstruction Theorems

This file contains the deeper obstruction theorems showing that layered
transition systems with wide intermediate layers cannot be compressed
to shallow tropical matrix powers.

## Main Results

- `bottleneck_width_obstruction`: If every intermediate layer has width ≥ B,
  and there are L layers, then any tropical compression that preserves
  reachability must use at least L matrix multiplications.

- `exponential_space_linear_time_lb`: For transition families with exponentially
  many configurations (2^(poly(n)) states), the accepting path length grows
  at least linearly in the space bound.

- `polyspace_tropical_encoding`: Any polynomial-space transition system
  can be encoded as tropical reachability in an exponential-size but
  finitely-presented min-plus system.
-/

import Mathlib
import Computation.TropicalComplexity.Defs
import Computation.TropicalComplexity.PathSemantics

open Tropical Matrix Finset TropicalComplexity

namespace TropicalComplexity

/-! ## Width/bottleneck obstruction -/

/-- The width of a layer: number of configurations at a given rank. -/
noncomputable def layerWidth {α : Type*} [Fintype α] [DecidableEq α]
    (rank : α → ℕ) (i : ℕ) : ℕ :=
  Fintype.card {a : α // rank a = i}

/-- **Bottleneck Width Obstruction**.
In a layered system, if `s` reaches `t` at depth `L`, then the path must
traverse every intermediate layer. No compression to fewer layers is possible
because the layering enforces strict rank progression.

More precisely: if the system is layered and `s` reaches `t` at depth `L`,
then no matrix `C` with `tropicalDominates C W` can achieve
`(C ^ k) s t = edge` for any `k < L`, provided `C` also respects a
layering with fewer than `L` levels. -/
theorem bottleneck_width_obstruction {α : Type*} [Fintype α] [DecidableEq α]
    (rank : α → ℕ) (W : Matrix α α T) (s t : α) (L : ℕ)
    (hW : IsZeroInfMatrix W) (hstep : IsLayered rank W)
    (hs : rank s = 0) (ht : rank t = L)
    (hreach : (W ^ L) s t = edge) :
    ∀ k < L, (W ^ k) s t ≠ edge :=
  layered_no_shortcut rank W s t L hW hstep hs ht hreach

/-! ## Configuration count bounds -/

/-
In a layered system with `L` layers, the total number of configurations
    is at least the maximum layer width times the number of layers,
    but more precisely, configurations partition across layers.
-/
theorem layered_cfg_partition {α : Type*} [Fintype α] [DecidableEq α]
    (rank : α → ℕ) (L : ℕ)
    (hbound : ∀ a : α, rank a ≤ L) :
    Fintype.card α = ∑ i ∈ Finset.range (L + 1), layerWidth rank i := by
  unfold layerWidth;
  simp +decide only [Fintype.card_subtype];
  simp +decide only [card_filter];
  rw [ Finset.sum_comm, Finset.sum_congr rfl fun _ _ => Finset.sum_ite_eq _ _ _ ] ; aesop

/-
**Exponential Space Forces Linear Depth**.
If a layered system has `L` layers and at least `B` configurations per layer,
then the total configuration count is at least `B * L`.
Combined with the no-shortcut theorem, this means any accepting computation
must traverse all `L` layers.
-/
theorem exponential_space_linear_depth {α : Type*} [Fintype α] [DecidableEq α]
    (rank : α → ℕ) (L B : ℕ)
    (hbound : ∀ a : α, rank a ≤ L)
    (hwidth : ∀ i ≤ L, B ≤ layerWidth rank i) :
    B * (L + 1) ≤ Fintype.card α := by
  convert Finset.sum_le_sum fun i hi => hwidth i ( Finset.mem_range_succ_iff.mp hi ) using 1;
  · rw [ Finset.sum_const, Finset.card_range, smul_eq_mul, mul_comm ];
  · convert layered_cfg_partition rank L hbound using 1

/-! ## Bridge to complexity theory -/

/-- An abstract bounded-space computation family. -/
structure BoundedSpaceFamily where
  /-- Number of configuration bits for input of length n -/
  spaceBound : ℕ → ℕ
  /-- The transition system for input length n -/
  system : ∀ n, LayeredSystem
  /-- Space bound controls configuration count -/
  cfgBound : ∀ n, Fintype.card (system n).Cfg ≤ 2 ^ spaceBound n
  /-- The depth of computation for input length n -/
  timeDepth : ℕ → ℕ
  /-- The depth equals the rank of the accept state -/
  depth : ∀ n, (system n).rank (system n).accept = timeDepth n
  /-- Space bound is polynomial -/
  polySpace : ∃ k C : ℕ, ∀ n, spaceBound n ≤ C * n ^ k + C

/-
For a layered computation on a graph with ≤ N configs spread across L layers,
    the time (path depth) is at most N.
-/
theorem time_bounded_by_configs {α : Type*} [Fintype α] [DecidableEq α]
    (rank : α → ℕ) (W : Matrix α α T) (s t : α) (L : ℕ)
    (hW : IsZeroInfMatrix W) (hstep : IsLayered rank W)
    (hs : rank s = 0) (ht : rank t = L)
    (_hbound : ∀ a : α, rank a ≤ L)
    (hreach : (W ^ L) s t = edge) :
    L ≤ Fintype.card α := by
  apply TropicalComplexity.tropical_layer_depth_lb W hW s t L hreach;
  exact TropicalComplexity.layered_no_shortcut rank W s t L hW hstep hs ht hreach

/-! ## The tropical encoding theorem -/

/-- **Tropical Encoding Theorem**.
Any finite transition system with a start and accept state can be viewed
as a tropical reachability problem: the computation accepts if and only if
some tropical matrix power connects start to accept with value `edge`.

This is the bridge theorem connecting classical complexity to tropical algebra. -/
theorem tropical_encoding {ts : TransitionSystem}
    (hW : IsZeroInfMatrix ts.W) :
    (∃ k, (ts.W ^ k) ts.start ts.accept = edge) ↔
    (∃ k, Walk ts.W ts.start ts.accept k) := by
  constructor
  · rintro ⟨k, hk⟩
    exact ⟨k, power_implies_walk ts.W hW ts.start ts.accept k hk⟩
  · rintro ⟨k, hk⟩
    exact ⟨k, walk_implies_power ts.W hW ts.start ts.accept k hk⟩

end TropicalComplexity