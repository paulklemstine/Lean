/-
Copyright (c) 2026. All rights reserved.

# Degree-4 vertices in the crease graph of the m×n Miura-ori

## Overview

The **Miura-ori** is a rigid-origami tessellation built on an `m × n` array of
parallelogram cells.  Its crease pattern is combinatorially a grid: the cell
array has `(m+1) × (n+1)` lattice vertices, and at every *interior* lattice
vertex exactly **four** creases meet (the signature degree-4 vertex of a
Miura-ori, where the mountain and valley fold lines cross).

The Phase-A research conjecture for this mission states:

> For all grid sizes `m, n ≥ 3` the number of degree-4 vertices in the (flip /
> crease) graph of the `m × n` Miura-ori equals `(m-1)(n-1)`.

This file formalizes the crease graph as the orthogonal grid graph on
`Fin (m+1) × Fin (n+1)` and proves the closed-form count of degree-4 vertices,
`(m-1)(n-1)`, *for all* `m, n` (the `≥ 3` hypothesis is not needed — the formula
is an identity over `ℕ`).  This is the rigid combinatorial core underlying the
conjecture.

## Main results

* `gridGraph_degree_eq` — the graph degree of a lattice vertex equals the closed
  boundary-indicator formula `degForm`.
* `card_degreeFour` — the number of degree-4 vertices equals `(m-1)*(n-1)`.

## Catalog connections

The "flip graph" terminology follows `Cereceda2009mixing` (the recolouring /
single-site flip graph of a combinatorial structure); here the relevant local
move is a single-vertex crease flip, so the underlying host graph is the crease
grid whose degree-4 vertices we count.  The enumeration technique (split a
`Finset.filter` over a product into a product of one-dimensional counts) mirrors
the counting style of `GineproHull2014counting`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): the number of degree-4 vertices of the m×n Miura-ori
crease graph is exactly (m-1)(n-1).  Bold form: this is *independent* of the
zig-zag offset of the Miura pattern and depends only on the grid combinatorics.

EXPERIMENT (Experimenter): modeled the crease pattern as the orthogonal grid
graph on Fin(m+1)×Fin(n+1).  `#eval` over (3,3),(4,5) gave 4 and 12, matching
(m-1)(n-1).  Proof obtained by (i) reducing graph degree to a 4-term boundary
indicator `degForm`, (ii) characterizing `degForm = 4` as the interior box, and
(iii) a product-count for the interior box.

ANALYSIS (Analyst): the `≥ 3` hypothesis in the informal conjecture is
unnecessary — the identity holds for every m,n (vacuously 0 when m≤1 or n≤1).
The genuinely graph-theoretic content is `gridGraph_degree_eq`; the rest is
arithmetic.  The result is robust to the precise crease orientation because only
the *vertex* combinatorics enter.

CRITIQUE (Critic): is the theorem trivial?  No — the degree computation requires
identifying the neighbour finset of each vertex (a SimpleGraph.degree value),
not a definitional `rfl`.  Guard: we keep the statement parametric in m,n and
prove it for ALL m,n rather than fixed small cases, ruling out `decide`.

SYNTHESIS (PI): degree-4 count = (m-1)(n-1) is established as a clean identity;
see FUTURE_DIRECTIONS.md for the bold follow-ups (flip-graph connectivity,
mixing time bounds).
-/
import Mathlib

open Finset

namespace MiuraFlip

/-- Lattice vertices of the crease pattern of an `m × n` Miura-ori:
the `(m+1) × (n+1)` grid of corners of the `m × n` parallelogram-cell array. -/
abbrev V (m n : ℕ) := Fin (m + 1) × Fin (n + 1)

/-- The crease graph of the `m × n` Miura-ori: orthogonal grid adjacency.
Two lattice vertices are joined by a crease iff they are unit-distance apart
along a row or a column. -/
def gridGraph (m n : ℕ) : SimpleGraph (V m n) where
  Adj p q := (p.1 = q.1 ∧ (p.2.val + 1 = q.2.val ∨ q.2.val + 1 = p.2.val)) ∨
             (p.2 = q.2 ∧ (p.1.val + 1 = q.1.val ∨ q.1.val + 1 = p.1.val))
  symm := by
    intro p q h
    rcases h with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · exact Or.inl ⟨h1.symm, by omega⟩
    · exact Or.inr ⟨h1.symm, by omega⟩
  loopless := ⟨by
    intro p h
    rcases h with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> omega⟩

instance (m n : ℕ) : DecidableRel (gridGraph m n).Adj := by
  intro p q
  unfold gridGraph
  infer_instance

/-- Closed-form boundary-indicator formula for the degree of a grid vertex:
one unit for each of the four orthogonal directions in which a neighbour exists. -/
def degForm (m n : ℕ) (p : V m n) : ℕ :=
  (if 0 < p.1.val then 1 else 0) + (if p.1.val < m then 1 else 0)
    + (if 0 < p.2.val then 1 else 0) + (if p.2.val < n then 1 else 0)

/-
The grid-graph degree of a vertex equals the closed boundary-indicator
formula.  This is the genuinely graph-theoretic step: the neighbour finset of a
vertex consists of its (at most four) orthogonal lattice neighbours.
-/
lemma gridGraph_degree_eq (m n : ℕ) (p : V m n) :
    (gridGraph m n).degree p = degForm m n p := by
  -- The neighbors of p in the grid graph are exactly the vertices that are adjacent to p in the grid.
  have h_neighbors : (gridGraph m n).neighborFinset p = Finset.filter (fun q => (p.1 = q.1 ∧ (p.2.val + 1 = q.2.val ∨ q.2.val + 1 = p.2.val)) ∨ (p.2 = q.2 ∧ (p.1.val + 1 = q.1.val ∨ q.1.val + 1 = p.1.val))) (Finset.univ : Finset (V m n)) := by
    ext q; simp [gridGraph];
  unfold degForm; simp_all +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset_def ] ;
  -- Let's count the number of neighbors of p in the grid graph.
  have h_count : Finset.card (Finset.filter (fun q : V m n => p.1 = q.1 ∧ (p.2.val + 1 = q.2.val ∨ q.2.val + 1 = p.2.val)) (Finset.univ : Finset (V m n))) = (if 0 < p.2.val then 1 else 0) + (if p.2.val < n then 1 else 0) := by
    split_ifs <;> simp_all +decide [ Finset.filter_or ];
    · rw [ Finset.card_eq_two ];
      refine' ⟨ ⟨ p.1, ⟨ p.2 - 1, by omega ⟩ ⟩, ⟨ p.1, ⟨ p.2 + 1, by omega ⟩ ⟩, _, _ ⟩ <;> simp +decide [ Fin.ext_iff ];
      grind;
    · rw [ Finset.card_eq_one ];
      use (p.1, ⟨p.2.val - 1, by
        grind⟩)
      generalize_proofs at *;
      grind;
    · rw [ Finset.card_eq_one ];
      use ( p.1, ⟨ 1, by linarith ⟩ ) ; ext; aesop;
    · grind +suggestions;
  have h_count2 : Finset.card (Finset.filter (fun q : V m n => p.2 = q.2 ∧ (p.1.val + 1 = q.1.val ∨ q.1.val + 1 = p.1.val)) (Finset.univ : Finset (V m n))) = (if 0 < p.1.val then 1 else 0) + (if p.1.val < m then 1 else 0) := by
    split_ifs <;> simp_all +decide [ Finset.ext_iff ];
    · rw [ Finset.card_eq_two ];
      refine' ⟨ ( ⟨ p.1 - 1, by omega ⟩, p.2 ), ( ⟨ p.1 + 1, by omega ⟩, p.2 ), _, _ ⟩ <;> simp +decide [ Fin.ext_iff ];
      ext ⟨ x, y ⟩ ; simp +decide [ Fin.ext_iff ] ; omega;
    · rw [ Finset.card_eq_one ];
      use (⟨p.1.val - 1, by
        exact Nat.lt_succ_of_le ( Nat.sub_le_of_le_add <| by linarith [ Fin.is_lt p.1 ] )⟩, p.2)
      generalize_proofs at *;
      grind;
    · rw [ Finset.card_eq_one ];
      use ⟨ ⟨ 1, by linarith ⟩, p.2 ⟩ ; ext ; aesop;
    · aesop;
  rw [ Finset.filter_or, Finset.card_union_of_disjoint ];
  · grind;
  · simp +contextual [ Finset.disjoint_left ]

/-
`degForm = 4` exactly characterizes the *interior* vertices.
-/
lemma degForm_eq_four_iff (m n : ℕ) (p : V m n) :
    degForm m n p = 4 ↔
      (0 < p.1.val ∧ p.1.val < m ∧ 0 < p.2.val ∧ p.2.val < n) := by
  unfold degForm;
  grind

/-
The number of interior indices of the `(m+1)`-index axis is `m - 1`.
-/
lemma card_interior_axis (m : ℕ) :
    (Finset.univ.filter (fun i : Fin (m + 1) => 0 < i.val ∧ i.val < m)).card
      = m - 1 := by
  rcases m with ( _ | _ | m ) <;> simp +arith +decide;
  convert Finset.card_range ( m + 1 ) using 1;
  refine' Finset.card_bij ( fun x hx => x - 1 ) _ _ _ <;> simp_all +decide;
  · grind;
  · exact fun b hb => ⟨ ⟨ b + 1, by linarith ⟩, ⟨ Nat.succ_pos _, by simpa using by linarith ⟩, rfl ⟩

/-
**Main theorem.**  The number of degree-4 vertices in the crease graph of the
`m × n` Miura-ori equals `(m-1)(n-1)`.  (The conjecture is stated for `m, n ≥ 3`;
the identity in fact holds for all `m, n`.)
-/
theorem card_degreeFour (m n : ℕ) :
    (Finset.univ.filter (fun p : V m n => (gridGraph m n).degree p = 4)).card
      = (m - 1) * (n - 1) := by
  simp +decide only [gridGraph_degree_eq];
  rw [ show ( Finset.filter ( fun p : Fin ( m + 1 ) × Fin ( n + 1 ) => degForm m n p = 4 ) Finset.univ ) = Finset.filter ( fun i : Fin ( m + 1 ) => 0 < i.val ∧ i.val < m ) Finset.univ ×ˢ Finset.filter ( fun j : Fin ( n + 1 ) => 0 < j.val ∧ j.val < n ) Finset.univ from ?_ ];
  · rw [ Finset.card_product, card_interior_axis, card_interior_axis ];
  · grind +suggestions

/-
Number of boundary indices `i` of the `(m+1)`-index axis (`i = 0` or `i = m`).
With `1 ≤ m` the two endpoints are distinct, so this is `2`.
-/
lemma card_boundary_axis (m : ℕ) (hm : 1 ≤ m) :
    (Finset.univ.filter (fun i : Fin (m + 1) => i.val = 0 ∨ i.val = m)).card = 2 := by
  rw [ Finset.card_eq_two ];
  refine' ⟨ ⟨ 0, by linarith ⟩, ⟨ m, by linarith ⟩, _, _ ⟩ <;> simp +decide [ Finset.ext_iff, Fin.forall_fin_succ ];
  · grind;
  · exact fun i => ⟨ fun h => Fin.ext h, fun h => by simpa [ Fin.ext_iff ] using h ⟩

/-
Degree-2 vertices of the crease graph are exactly the four corners.
-/
theorem card_degreeTwo (m n : ℕ) (hm : 1 ≤ m) (hn : 1 ≤ n) :
    (Finset.univ.filter (fun p : V m n => (gridGraph m n).degree p = 2)).card = 4 := by
  convert congr_arg Finset.card ( show Finset.filter ( fun p : Fin ( m + 1 ) × Fin ( n + 1 ) => degForm m n p = 2 ) Finset.univ = Finset.filter ( fun i : Fin ( m + 1 ) => i.val = 0 ∨ i.val = m ) Finset.univ ×ˢ Finset.filter ( fun j : Fin ( n + 1 ) => j.val = 0 ∨ j.val = n ) Finset.univ from ?_ ) using 1;
  · congr! 2;
    exact funext fun p => by rw [ gridGraph_degree_eq ] ;
  · rw [ Finset.card_product, card_boundary_axis m hm, card_boundary_axis n hn ];
  · ext ⟨i, j⟩; simp [degForm];
    grind

/-
Degree-3 vertices of the crease graph are the boundary non-corner vertices;
there are `2(m-1) + 2(n-1)` of them.
-/
theorem card_degreeThree (m n : ℕ) (hm : 1 ≤ m) (hn : 1 ≤ n) :
    (Finset.univ.filter (fun p : V m n => (gridGraph m n).degree p = 3)).card
      = 2 * (m - 1) + 2 * (n - 1) := by
  have h_card : (Finset.univ.filter (fun p : V m n => (gridGraph m n).degree p = 3)).card = (Finset.filter (fun i : Fin (m + 1) => i.val = 0 ∨ i.val = m) Finset.univ).card * (Finset.filter (fun j : Fin (n + 1) => 0 < j.val ∧ j.val < n) Finset.univ).card + (Finset.filter (fun i : Fin (m + 1) => 0 < i.val ∧ i.val < m) Finset.univ).card * (Finset.filter (fun j : Fin (n + 1) => j.val = 0 ∨ j.val = n) Finset.univ).card := by
    rw [ show ( Finset.filter ( fun p : Fin ( m + 1 ) × Fin ( n + 1 ) => ( gridGraph m n ).degree p = 3 ) Finset.univ ) = Finset.filter ( fun i : Fin ( m + 1 ) => i.val = 0 ∨ i.val = m ) Finset.univ ×ˢ Finset.filter ( fun j : Fin ( n + 1 ) => 0 < j.val ∧ j.val < n ) Finset.univ ∪ Finset.filter ( fun i : Fin ( m + 1 ) => 0 < i.val ∧ i.val < m ) Finset.univ ×ˢ Finset.filter ( fun j : Fin ( n + 1 ) => j.val = 0 ∨ j.val = n ) Finset.univ from ?_ ];
    · rw [ Finset.card_union_of_disjoint ] <;> norm_num [ Finset.disjoint_left ];
      aesop;
    · ext ⟨i, j⟩; simp [gridGraph_degree_eq, degForm];
      grind;
  have := card_boundary_axis m hm; have := card_interior_axis m; have := card_boundary_axis n hn; have := card_interior_axis n; simp_all +decide [ Finset.filter_or, Finset.filter_and ] ;
  ring

end MiuraFlip