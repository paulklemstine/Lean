/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Shadow Isoperimetry for Newton Polytopes — Core Definitions

This file introduces the core definitions for studying discrete isoperimetric
phenomena on finite subsets of `ℕ^n`, viewed as monomial support sets whose
convex hulls are Newton polytopes.

## Main Definitions

* `oneShadow` — The one-step downward shadow: all points obtained by decrementing
  one positive coordinate by 1.
* `lowerClosed` — Predicate for downward-closed (lower ideal) sets in `ℕ^n`.
* `box` — Axis-aligned lattice box `∏ᵢ {0, …, aᵢ}`.
* `latticeInnerBoundary` — Points of `S` with at least one neighbor below outside `S`.
* `shadowDefect` — The defect `|S| - |oneShadow S|`.
* `coordProjection` — Projection onto the complement of one coordinate axis.
* `compressInDir` — Coordinate compression operator in direction `i`.
* `axisFiber` — Fiber of a set along one coordinate axis.

## Cross-Domain Significance

These definitions establish the combinatorial infrastructure for treating the shadow
operator as a **discrete boundary operator** on Newton polytopes. The one-step shadow
corresponds to monomial division by a single variable, connecting to:

- **Algebraic complexity**: support spread under partial differentiation
- **Ehrhart theory**: lattice-point boundary layers of convex polytopes
- **Extremal combinatorics**: Kruskal–Katona type shadow minimization
-/

open Finset BigOperators

namespace ShadowIsoperimetry

variable {n : ℕ}

/-! ## One-Step Shadow -/

/-- The **one-step shadow** of a finite set `S ⊆ ℕ^n`.
A point `y` is in the one-step shadow if there exists `x ∈ S` and a coordinate `i`
such that `x i > 0`, `y i = x i - 1`, and `y j = x j` for all `j ≠ i`.

This models monomial division by a single variable `xᵢ`. -/
def oneShadow (S : Finset (Fin n → ℕ)) : Finset (Fin n → ℕ) :=
  (S.biUnion fun x =>
    (Finset.univ.filter fun i => 0 < x i).image fun i =>
      Function.update x i (x i - 1)).filter fun y =>
    ∃ x ∈ S, ∃ i : Fin n, 0 < x i ∧ y = Function.update x i (x i - 1)

/-- Membership characterization for `oneShadow`. -/
theorem mem_oneShadow_iff {S : Finset (Fin n → ℕ)} {y : Fin n → ℕ} :
    y ∈ oneShadow S ↔
      ∃ x ∈ S, ∃ i : Fin n, 0 < x i ∧ y = Function.update x i (x i - 1) := by
  simp only [oneShadow, mem_filter, mem_biUnion, mem_image, mem_filter, mem_univ, true_and]
  constructor
  · rintro ⟨_, h⟩; exact h
  · rintro ⟨x, hx, i, hi, rfl⟩
    exact ⟨⟨x, hx, i, hi, rfl⟩, x, hx, i, hi, rfl⟩

/-! ## Lower-Closed Sets -/

/-- A finite set `S ⊆ ℕ^n` is **lower-closed** (a lower ideal, or downward-closed)
if whenever `x ∈ S` and `y ≤ x` pointwise, then `y ∈ S`.

Lower-closed sets are the natural extremizers for shadow minimization problems. -/
def lowerClosed (S : Finset (Fin n → ℕ)) : Prop :=
  ∀ x ∈ S, ∀ y : Fin n → ℕ, (∀ i, y i ≤ x i) → y ∈ S

/-! ## Axis-Aligned Box -/

/-- The **lattice box** with side lengths `a : Fin n → ℕ`.
`box n a = ∏ᵢ {0, 1, …, aᵢ}`. -/
def box (n : ℕ) (a : Fin n → ℕ) : Finset (Fin n → ℕ) :=
  Fintype.piFinset fun i => Finset.range (a i + 1)

/-- Membership in a box. -/
theorem mem_box_iff {a x : Fin n → ℕ} :
    x ∈ box n a ↔ ∀ i, x i ≤ a i := by
  simp [box, Fintype.mem_piFinset, Finset.mem_range]

/-- Cardinality of a box is the product of side lengths + 1. -/
theorem card_box (n : ℕ) (a : Fin n → ℕ) :
    (box n a).card = ∏ i : Fin n, (a i + 1) := by
  simp [box, Fintype.card_piFinset]

/-- A box is lower-closed. -/
theorem box_lowerClosed (a : Fin n → ℕ) : lowerClosed (box n a) := by
  intro x hx y hle
  rw [mem_box_iff] at hx ⊢
  intro i; exact le_trans (hle i) (hx i)

/-! ## Lattice Inner Boundary -/

/-- The **lattice inner boundary** of `S`: points `x ∈ S` such that at least one
coordinate can be decremented by 1 to yield a point outside `S`.
This is the discrete analogue of the inner boundary of a convex body. -/
def latticeInnerBoundary (S : Finset (Fin n → ℕ)) : Finset (Fin n → ℕ) :=
  S.filter fun x =>
    ∃ i : Fin n, 0 < x i ∧ Function.update x i (x i - 1) ∉ S

/-- Membership in lattice inner boundary. -/
theorem mem_latticeInnerBoundary_iff {S : Finset (Fin n → ℕ)} {x : Fin n → ℕ} :
    x ∈ latticeInnerBoundary S ↔
      x ∈ S ∧ ∃ i : Fin n, 0 < x i ∧ Function.update x i (x i - 1) ∉ S := by
  simp [latticeInnerBoundary, mem_filter]

/-! ## Shadow Defect -/

/-- The **shadow defect**: `|S| - |oneShadow S|` as an integer. -/
def shadowDefect (S : Finset (Fin n → ℕ)) : ℤ :=
  (S.card : ℤ) - (oneShadow S).card

/-! ## Coordinate Projection -/

/-- **Coordinate projection**: the image of `S` under setting coordinate `i` to `0`. -/
def coordProjection (i : Fin n) (S : Finset (Fin n → ℕ)) : Finset (Fin n → ℕ) :=
  S.image fun x => Function.update x i 0

/-! ## Axis Fiber -/

/-- The **axis fiber** of `S` at coordinate `i` and base point `u`:
the set of values that coordinate `i` takes. -/
def axisFiber (S : Finset (Fin n → ℕ)) (i : Fin n) (u : Fin n → ℕ) : Finset ℕ :=
  (S.filter fun x => ∀ j, j ≠ i → x j = u j).image fun x => x i

/-! ## Compression in Direction i -/

/-- **Compression in direction `i`**: for each fiber along axis `i`, replaces the
set of values with an initial segment `{0, 1, …, k-1}` of the same cardinality.
This is the discrete analogue of Steiner symmetrization. -/
noncomputable def compressInDir (i : Fin n) (S : Finset (Fin n → ℕ)) : Finset (Fin n → ℕ) :=
  let projs := coordProjection i S
  projs.biUnion fun u =>
    let fib := axisFiber S i u
    (Finset.range fib.card).image fun k => Function.update u i k

end ShadowIsoperimetry