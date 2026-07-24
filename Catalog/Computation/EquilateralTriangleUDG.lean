/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# A concrete planar unit-distance graph meeting the `1/4` bound

This file exhibits an explicit, non-vacuous finite unit-distance graph in the
plane and instantiates the general `1/4` independence-ratio bound on it.

The three vertices of a unit equilateral triangle,
`(0,0)`, `(1,0)`, `(1/2, √3/2)`, are pairwise at Euclidean distance exactly `1`.
Hence their unit-distance graph is the complete graph `K₃`.  It is `4`-colourable
(indeed `3`-chromatic), so the headline theorem
`indep_ratio_ge_quarter_of_four_colorable` applies and gives independence ratio
`≥ 1/4`.  We also compute the *exact* independence ratio, `1/3`, confirming the
graph genuinely lies strictly above the `1/4` threshold.
-/
import Mathlib
import Catalog.Computation.UnitDistanceIndependenceRatio

open Finset SimpleGraph EuclideanSpace
open Catalog.Computation.UnitDistanceIndependenceRatio

namespace Catalog.Computation.EquilateralTriangleUDG

/-- The three vertices of a unit equilateral triangle in the plane. -/
noncomputable def triPoints : Fin 3 → EuclideanSpace ℝ (Fin 2)
  | 0 => !₂[0, 0]
  | 1 => !₂[1, 0]
  | 2 => !₂[1 / 2, Real.sqrt 3 / 2]

/-
Any two distinct triangle vertices are at unit distance.
-/
lemma triPoints_dist_one (i j : Fin 3) (h : i ≠ j) :
    dist (triPoints i) (triPoints j) = 1 := by
  fin_cases i <;> fin_cases j <;> simp +decide [ triPoints ] at h ⊢;
  all_goals norm_num [ dist_eq_norm, EuclideanSpace.norm_eq ]; all_goals norm_num [ div_pow ]

/-
The equilateral-triangle unit-distance graph is exactly the complete graph on
three vertices: two vertices are adjacent iff they are distinct.
-/
lemma triGraph_adj_iff (i j : Fin 3) :
    (unitDistanceGraph triPoints).Adj i j ↔ i ≠ j := by
  exact ⟨ fun h => h.1, fun h => ⟨ h, triPoints_dist_one i j h ⟩ ⟩

/-
The triangle graph is `4`-colourable (in fact `3`-chromatic).
-/
lemma triGraph_colorable : (unitDistanceGraph triPoints).Colorable 4 := by
  refine' ⟨ _, _ ⟩;
  exact fun i => Fin.castLE ( by decide ) i;
  simp +decide [ triGraph_adj_iff ]

/-- **Instantiation of the headline bound.**  The concrete equilateral-triangle
unit-distance graph has an independent set of relative size at least `1/4`. -/
theorem triGraph_indep_ratio_ge_quarter :
    ∃ S : Finset (Fin 3),
      (∀ v ∈ S, ∀ u ∈ S, v ≠ u → ¬ (unitDistanceGraph triPoints).Adj v u) ∧
      (1 : ℝ) / 4 ≤ (S.card : ℝ) / (Fintype.card (Fin 3)) :=
  indep_ratio_ge_quarter_of_four_colorable (unitDistanceGraph triPoints) triGraph_colorable

/-
**Exact independence ratio.**  Every independent set of the triangle graph has
at most one vertex, and a one-vertex independent set exists; hence the exact
independence ratio is `1/3`, comfortably above the `1/4` threshold.
-/
theorem triGraph_indep_ratio_eq_third :
    (∀ S : Finset (Fin 3),
        (∀ v ∈ S, ∀ u ∈ S, v ≠ u → ¬ (unitDistanceGraph triPoints).Adj v u) →
        (S.card : ℝ) / (Fintype.card (Fin 3)) ≤ 1 / 3) ∧
      (∃ S : Finset (Fin 3),
        (∀ v ∈ S, ∀ u ∈ S, v ≠ u → ¬ (unitDistanceGraph triPoints).Adj v u) ∧
        (S.card : ℝ) / (Fintype.card (Fin 3)) = 1 / 3) := by
  constructor;
  · intro S hS;
    fin_cases S <;> simp +decide [ triGraph_adj_iff ] at hS ⊢;
  · refine' ⟨ { 0 }, _, _ ⟩ <;> norm_num

/-
-- !-- Lab Notes -- !--

**Hypothesis.**  The general `1/4` bound of `UnitDistanceIndependenceRatio.lean`
should be *non-vacuous*: there is an explicit planar unit-distance graph to which
it applies, and its true ratio should sit strictly above `1/4`.

**Experiment.**  We placed the three vertices of a unit equilateral triangle at
`(0,0)`, `(1,0)`, `(1/2, sqrt 3 / 2)`.  `triPoints_dist_one` verifies all three
pairwise Euclidean distances equal `1` (the `sqrt 3 / 2` coordinate makes the
radicand collapse to `1` via `Real.sq_sqrt`).  `triGraph_adj_iff` then shows the
resulting unit-distance graph is exactly `K_3`, `triGraph_colorable` gives a
4-colouring (via an injection `Fin 3 -> Fin 4`), and
`triGraph_indep_ratio_ge_quarter` instantiates the headline bound.

**Analysis.**  `triGraph_indep_ratio_eq_third` computes the *exact* ratio: any
independent set has at most one vertex (all pairs adjacent), and `{0}` realises
one vertex, so the ratio is exactly `1/3 > 1/4`.  The witness therefore lies
strictly inside the admissible region, confirming the bound is not tight here.

**Critique.**  The geometry is genuine (real square-root distance computation,
not `decide`), and the two directions of the exact-ratio theorem are both
non-trivial (an upper bound over all independent sets plus an explicit witness).

**Synthesis.**  A fully verified planar witness anchoring the abstract engine,
showing the `1/4` threshold is met with room to spare by the smallest
non-trivial planar unit-distance graph.
-/

end Catalog.Computation.EquilateralTriangleUDG