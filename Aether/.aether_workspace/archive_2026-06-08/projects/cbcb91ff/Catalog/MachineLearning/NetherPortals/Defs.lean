/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Portal Networks: Definitions

## Overview

This file provides the foundational definitions for the tropical-geometric
analysis of scaled dual-world travel networks. The mathematical abstraction
captures any system with two coupled metric spaces related by a deterministic
scaling factor (the "Nether" being 1:8 compressed relative to the "Overworld").

## Mathematical Setup

We work with integer coordinates ℤ × ℤ equipped with the Manhattan (L¹) metric.
The scaling map φ: (x,z) ↦ (x/8, z/8) compresses the Overworld to the Nether.
On the sublattice (8ℤ)², this compression is exact (no rounding error).

The dual-world travel cost between two points is the minimum of:
- Direct Overworld travel: d_O(a, b)
- Nether travel with portal costs: 2c + d_N(φ(a), φ(b))

This minimum operation makes the cost algebra a min-plus (tropical) semiring.

## Main Definitions

* `L1Dist` — Manhattan (L¹) distance on ℤ × ℤ
* `LiftOver` — Lifts Nether coordinates to Overworld (×8 scaling)
* `NetherMap` — Maps Overworld coordinates to Nether (÷8 scaling)
* `DivBy8Point` — Predicate for coordinates on the 8-lattice
* `DualWorldCost` — Min of Overworld and Nether travel with portal cost
* `TropicalMatMul` — Min-plus matrix multiplication
* `TropicalStep` — One step of tropical closure
-/
import Mathlib

namespace NetherPortals

/-! ## Core Distance and Scaling Definitions -/

/-- Manhattan (L¹) distance on ℤ × ℤ, returning a natural number. -/
def L1Dist (p q : ℤ × ℤ) : ℕ :=
  Int.natAbs (p.1 - q.1) + Int.natAbs (p.2 - q.2)

/-- Lift Nether coordinates to Overworld coordinates (scale by 8). -/
def LiftOver (p : ℤ × ℤ) : ℤ × ℤ := (8 * p.1, 8 * p.2)

/-- Map Overworld coordinates to Nether coordinates (integer division by 8). -/
def NetherMap (p : ℤ × ℤ) : ℤ × ℤ := (p.1 / 8, p.2 / 8)

/-- Predicate: a point lies on the 8-lattice (both coordinates divisible by 8). -/
def DivBy8Point (p : ℤ × ℤ) : Prop := 8 ∣ p.1 ∧ 8 ∣ p.2

/-- Dual-world travel cost between two points: minimum of Overworld direct travel
    and Nether travel (with portal entry/exit cost `c` at each end). -/
def DualWorldCost (c : ℕ) (p q : ℤ × ℤ) : ℕ :=
  min (L1Dist p q) (2 * c + L1Dist (NetherMap p) (NetherMap q))

/-! ## Tropical (Min-Plus) Matrix Operations -/

/-- Min-plus (tropical) matrix multiplication on `Fin n × Fin n` matrices. -/
noncomputable def TropicalMatMul {n : ℕ} [NeZero n]
    (A B : Fin n → Fin n → ℕ) : Fin n → Fin n → ℕ :=
  fun i k => Finset.inf' Finset.univ Finset.univ_nonempty (fun j => A i j + B j k)

/-- One step of tropical closure: take element-wise min of W and W² (tropical). -/
noncomputable def TropicalStep {n : ℕ} [NeZero n]
    (W : Fin n → Fin n → ℕ) : Fin n → Fin n → ℕ :=
  fun i k => min (W i k) (TropicalMatMul W W i k)

/-! ## Graph Infrastructure Definitions -/

/-- Total weight of a set of edges in a weighted graph. -/
def totalEdgeWeight {n : ℕ} (w : Fin n → Fin n → ℕ) (edges : List (Fin n × Fin n)) : ℕ :=
  edges.map (fun e => w e.1 e.2) |>.sum

end NetherPortals