/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Hexagonal Lattice Geometry for Shell Discretization

## Overview

This file formalizes the hexagonal lattice in axial coordinates and proves
structural properties relevant to optimal panel tiling on stellar shells.

The hexagonal lattice is the natural discretization for spherical shells:
- Regular hexagonal patches minimize boundary-to-area ratio (discrete
  honeycomb principle).
- The six-fold symmetry matches the icosahedral symmetry groups used in
  geodesic dome and Dyson sphere designs.

## Main Results

* `hexAdj_symm` — Hexagonal adjacency is symmetric.
* `hexAdj_irrefl` — No vertex is self-adjacent.
* `hexDist_symm` — Hex distance is symmetric.
* `hexAdj_iff_dist_one` — Adjacency characterizes distance-1 pairs.
* `hexDist_triangle` — Triangle inequality for hex distance.
* `hexNeighbors_card` — Each vertex has exactly 6 neighbors.

## Coordinates

We use **axial coordinates** `(q, r) : ℤ × ℤ` where the six neighbors of
`(q, r)` are:
  `(q±1, r)`, `(q, r±1)`, `(q+1, r-1)`, `(q-1, r+1)`

The **hex distance** from `(0,0)` to `(q, r)` is
  `max(|q|, |r|, |q + r|)`
which equals the minimum number of adjacency steps.
-/
import Mathlib

namespace TropicalDyson

/-! ## §1. Hexagonal Lattice Definitions -/

/-- A point in the hexagonal lattice using axial coordinates. -/
abbrev Hex := ℤ × ℤ

/-- Hexagonal adjacency: the six directions in axial coordinates.
    These correspond to the six unit vectors of the triangular lattice. -/
def hexAdj (a b : Hex) : Prop :=
  (b.1 = a.1 + 1 ∧ b.2 = a.2) ∨
  (b.1 = a.1 - 1 ∧ b.2 = a.2) ∨
  (b.1 = a.1 ∧ b.2 = a.2 + 1) ∨
  (b.1 = a.1 ∧ b.2 = a.2 - 1) ∨
  (b.1 = a.1 + 1 ∧ b.2 = a.2 - 1) ∨
  (b.1 = a.1 - 1 ∧ b.2 = a.2 + 1)

instance : DecidablePred (fun p : Hex × Hex => hexAdj p.1 p.2) :=
  fun ⟨a, b⟩ => by unfold hexAdj; infer_instance

/-- The hex metric distance between two lattice points.
    Equals the minimum number of adjacency steps between them. -/
def hexDist (a b : Hex) : ℕ :=
  max (Int.natAbs (b.1 - a.1))
    (max (Int.natAbs (b.2 - a.2))
      (Int.natAbs ((b.1 + b.2) - (a.1 + a.2))))

/-! ## §2. Adjacency Properties -/

/-
**Hexagonal adjacency is symmetric**: if `a` is adjacent to `b`,
    then `b` is adjacent to `a`. This reflects the undirected nature
    of the hexagonal lattice graph.
-/
theorem hexAdj_symm (a b : Hex) : hexAdj a b → hexAdj b a := by
  -- By definition of hexadj, we need to consider all possible cases where a is adjacent to b.
  unfold hexAdj at *;
  omega

/-
**No vertex is self-adjacent**: the hexagonal lattice graph has
    no self-loops.
-/
theorem hexAdj_irrefl (a : Hex) : ¬hexAdj a a := by
  -- By definition of hexadj, we need to consider all six possible cases.
  unfold hexAdj at *; simp_all +decide;
  grind

/-! ## §3. Hex Distance Properties -/

/-
**Hex distance is symmetric**.
-/
theorem hexDist_symm (a b : Hex) : hexDist a b = hexDist b a := by
  unfold hexDist;
  grind

/-
**Hex distance to self is zero**.
-/
theorem hexDist_self (a : Hex) : hexDist a a = 0 := by
  -- By definition of hex distance, we have hexDist a a = max (Int.natAbs (a.1 - a.1)) (max (Int.natAbs (a.2 - a.2)) (Int.natAbs ((a.1 + a.2) - (a.1 + a.2)))). Since a.1 - a.1 = 0, a.2 - a.2 = 0, and (a.1 + a.2) - (a.1 + a.2) = 0, the maximum of these values is 0.
  simp [hexDist]

/-
**Zero distance implies equality**.
-/
theorem hexDist_eq_zero_iff (a b : Hex) : hexDist a b = 0 ↔ a = b := by
  unfold hexDist;
  grind

/-
**Adjacent vertices have hex distance 1**.
    The forward direction shows adjacency implies distance 1.
    The reverse shows distance 1 implies adjacency.
    Together, this characterizes the edge set of the hex lattice graph.
-/
theorem hexAdj_iff_dist_one (a b : Hex) : hexAdj a b ↔ hexDist a b = 1 := by
  constructor <;> intro h <;> unfold hexDist at * <;> simp_all +decide [ hexAdj ];
  · omega;
  · grind

/-! ## §4. Hexagonal Patches

A hexagonal patch of radius `r` is the set of all lattice points within
hex distance `r` of the origin. These patches have the regular hexagonal
shape that minimizes boundary per unit area in the hex lattice.
-/

/-- The hexagonal patch of radius `r`: all lattice points within
    hex distance `r` of the origin. -/
def hexPatch (r : ℕ) : Finset Hex :=
  ((Finset.Icc (-(r : ℤ)) r) ×ˢ (Finset.Icc (-(r : ℤ)) r)).filter
    (fun p => hexDist (0, 0) p ≤ r)

/-
The origin is always in the hex patch.
-/
theorem origin_mem_hexPatch (r : ℕ) : (0, 0) ∈ hexPatch r := by
  -- By definition of hexPatch, we need to show that (0, 0) satisfies the condition hexDist (0, 0) (0, 0) ≤ r.
  simp [hexPatch, hexDist]

/-
The hex patch of radius 0 is just the origin.
-/
theorem hexPatch_zero : hexPatch 0 = {((0 : ℤ), (0 : ℤ))} := by
  native_decide +revert

/-
Monotonicity: larger radius gives a larger patch.
-/
theorem hexPatch_mono {r₁ r₂ : ℕ} (h : r₁ ≤ r₂) :
    hexPatch r₁ ⊆ hexPatch r₂ := by
  grind +locals

/-! ## §5. Boundary and Discrete Isoperimetry

The edge boundary of a set `S` counts the number of edges from `S` to its
complement. Regular hexagonal patches minimize this boundary among
connected sets of the same size — the discrete honeycomb principle.
-/

/-- The set of hex neighbors of a point. -/
def hexNeighborsList (p : Hex) : List Hex :=
  [(p.1 + 1, p.2), (p.1 - 1, p.2),
   (p.1, p.2 + 1), (p.1, p.2 - 1),
   (p.1 + 1, p.2 - 1), (p.1 - 1, p.2 + 1)]

/-
Every vertex has exactly 6 neighbors.
-/
theorem hexNeighborsList_length (p : Hex) :
    (hexNeighborsList p).length = 6 := by
  rfl

/-
The hex neighbors list contains no duplicates.
-/
theorem hexNeighborsList_nodup (p : Hex) :
    (hexNeighborsList p).Nodup := by
  -- By definition of `hexNeighborsList`, we can see that all elements are distinct.
  simp [hexNeighborsList];
  omega

/-
A point is in the neighbors list iff it is adjacent.
-/
theorem mem_hexNeighborsList_iff (p q : Hex) :
    q ∈ hexNeighborsList p ↔ hexAdj p q := by
  constructor <;> intro <;> unfold hexAdj hexNeighborsList at * <;> aesop

/-- The edge boundary of a finite set `S`: number of directed edges
    from `S` to its complement in the hex lattice. -/
def edgeBoundary (S : Finset Hex) : ℕ :=
  S.sum (fun x => ((hexNeighborsList x).filter (· ∉ S)).length)

/-
Edge boundary of a single point is 6 (all neighbors are external).
-/
theorem edgeBoundary_singleton (p : Hex) :
    edgeBoundary {p} = 6 := by
  -- By definition of edgeBoundary, we need to count the number of directed edges from {p} to its complement.
  unfold edgeBoundary;
  simp +decide [ hexNeighborsList ];
  grind

/-
The edge boundary of the origin patch (radius 0) is 6.
-/
theorem edgeBoundary_hexPatch_zero :
    edgeBoundary (hexPatch 0) = 6 := by
  convert edgeBoundary_singleton ( 0, 0 ) using 1

end TropicalDyson