/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# MPS Min-Cut Principle: Core Definitions

This file introduces the core definitions for the Matrix Product State (MPS) min-cut
principle, which establishes that for 1D tensor network states, the minimum flattening
rank over all bipartitions is controlled by the minimum bond dimension over contiguous
(prefix) cuts.

## Main Definitions

* `MPSMinCut.cutEdges` — the set of "cut edges" on a path graph for a given subset
* `MPSMinCut.prefixCut` — the prefix cut `{0, …, k-1}` on `Fin n`
* `MPSMinCut.edgeCutMinWeight` — the minimum weight among cut edges
* `MPSMinCut.contiguousMinWeight` — the minimum edge weight (= min contiguous cut weight)
* `MPSMinCut.integratedMinWeight` — the minimum over ALL nontrivial bipartitions
* `MPSMinCut.IsNontrivialBipartition` — predicate for nonempty proper subsets

## References

The MPS min-cut principle encodes the fundamental observation from tensor network theory
that on a 1D chain, entanglement across any bipartition is funneled through the chain
bonds crossing that cut. This file formalizes the combinatorial backbone of that principle.
-/

import Mathlib

namespace MPSMinCut

open Finset

/-! ### Path graph cut edges

On the path graph `0 — 1 — 2 — ⋯ — (n-1)`, an "edge" is a pair `(i, i+1)` for
`i ∈ {0, …, n-2}`. We represent edges as elements of `Fin (n-1)`, where edge `e`
connects vertex `e.val` to vertex `e.val + 1`.

A "cut edge" for subset `S ⊆ Fin n` is an edge where exactly one endpoint belongs to `S`.
-/

/-- Whether edge `e` (connecting `e.val` and `e.val + 1`) is a cut edge for `S`. -/
def isCutEdge {n : ℕ} (S : Finset (Fin n)) (e : Fin (n - 1)) : Bool :=
  let i : Fin n := ⟨e.val, by omega⟩
  let j : Fin n := ⟨e.val + 1, by omega⟩
  xor (i ∈ S) (j ∈ S)

/-- The set of cut edges for a subset `S` of the path graph on `n` vertices. -/
def cutEdges {n : ℕ} (S : Finset (Fin n)) : Finset (Fin (n - 1)) :=
  univ.filter fun e => isCutEdge S e

/-! ### Prefix cuts -/

/-- The prefix cut `{0, …, k-1}` on `Fin n`. For `k = 0` this is empty,
for `k ≥ n` this is everything. -/
def prefixCut (n : ℕ) (k : ℕ) : Finset (Fin n) :=
  univ.filter fun i => i.val < k

/-- A subset is a nontrivial bipartition if it is nonempty and proper. -/
def IsNontrivialBipartition {n : ℕ} (S : Finset (Fin n)) : Prop :=
  S.Nonempty ∧ S ≠ univ

instance {n : ℕ} (S : Finset (Fin n)) : Decidable (IsNontrivialBipartition S) :=
  inferInstanceAs (Decidable (_ ∧ _))

/-! ### Weight functions and bottleneck values

We abstract the MPS bond dimensions as a weight function `w : Fin (n-1) → ℕ` assigning
a "capacity" to each edge of the path graph. The key quantities are:

* **Edge cut min weight**: for a given bipartition `S`, the minimum weight among
  cut edges (or 0 if no cut edges exist, though we prove this can't happen for
  nontrivial bipartitions).

* **Contiguous min weight**: the minimum of `w(k)` over all internal edges,
  representing the best contiguous (prefix) cut.

* **Integrated min weight**: the minimum of the edge-cut-min-weight over all
  nontrivial bipartitions, representing the global information bottleneck.
-/

/-- The minimum edge weight among cut edges of `S`. Returns 0 if there are no cut edges. -/
noncomputable def edgeCutMinWeight {n : ℕ} (w : Fin (n - 1) → ℕ) (S : Finset (Fin n)) : ℕ :=
  if h : (cutEdges S).Nonempty then
    (cutEdges S).inf' h w
  else 0

/-- The minimum edge weight over all edges (= the contiguous min-cut capacity). -/
noncomputable def contiguousMinWeight {n : ℕ} (w : Fin (n - 1) → ℕ) : ℕ :=
  if h : (univ : Finset (Fin (n - 1))).Nonempty then
    univ.inf' h w
  else 0

/-- The set of all nontrivial bipartitions of `Fin n`. -/
def nontrivialBipartitions (n : ℕ) : Finset (Finset (Fin n)) :=
  (univ : Finset (Finset (Fin n))).filter IsNontrivialBipartition

/-- The integrated min weight: the minimum of `edgeCutMinWeight` over all nontrivial
bipartitions. This is the quantity `Φ#(ψ)` from the MPS min-cut principle. -/
noncomputable def integratedMinWeight {n : ℕ} (w : Fin (n - 1) → ℕ) : ℕ :=
  if h : (nontrivialBipartitions n).Nonempty then
    (nontrivialBipartitions n).inf' h (edgeCutMinWeight w)
  else 0

/-! ### Prefix cut has exactly one cut edge -/

/-- The prefix cut `{0, …, k-1}` for `0 < k < n` has `k-1` as a cut edge. -/
theorem prefixCut_cutEdge {n : ℕ} (k : ℕ) (hk1 : 0 < k) (hk2 : k < n) :
    isCutEdge (prefixCut n k) ⟨k - 1, by omega⟩ = true := by
  simp [isCutEdge, prefixCut]
  omega

/-- The prefix cut `{0, …, k-1}` for `0 < k < n` is a nontrivial bipartition. -/
theorem prefixCut_nontrivial {n : ℕ} (k : ℕ) (hk1 : 0 < k) (hk2 : k < n) :
    IsNontrivialBipartition (prefixCut n k) := by
  constructor
  · exact ⟨⟨0, by omega⟩, by simp [prefixCut, hk1]⟩
  · intro h
    have : (⟨k, hk2⟩ : Fin n) ∈ prefixCut n k := by rw [h]; exact mem_univ _
    simp [prefixCut] at this

end MPSMinCut