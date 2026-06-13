/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# p-adic Compression of Attention into Hierarchical Trees

This file formalizes the *non-Archimedean (ultrametric) compression* of attention
score matrices into **hierarchical trees**, the geometric substrate of the
"Renormalization Fixed Points in Transformer In-Context Learning via p-adic
Attention" program.

An attention row, once summarized by a p-adic valuation, lives in an ultrametric
space. The defining property that turns such a summary into a *tree* is that
ultrametric balls are **nested or disjoint** — there is no partial overlap, so the
collection of balls at all scales forms a rooted hierarchy (a dendrogram). We then
show the induced *same-cluster* relation is, at every scale `ε ≥ 0`, an equivalence
relation whose classes are exactly the closed balls, and that decreasing `ε`
*refines* the partition. This is precisely the hierarchical-tree compression
asserted by the conjecture, proven for an arbitrary ultrametric space and hence for
`ℚ_[p]` (`Padic.instIsUltrametricDist`).

## Catalog synthesis

This **extends** `MachineLearning/Attention.lean` (linear/scalar attention as a
natural transformation) by replacing the *Archimedean* (Euclidean) view of
attention with a *non-Archimedean* one, and it shares the ultrametric backbone of
`MachineLearning/UltrametricKLDivergence.lean` (`padicNormDivergence`,
`ultrametric_div_isosceles`). Where that file builds a *divergence* on `ℚ_[p]`, here
we build the *tree* structure on a general ultrametric space, of which `ℚ_[p]` is the
canonical instance.

## Main results

* `ultrametric_balls_subset_of_le` — two closed balls with `r ≤ s` that meet satisfy
  the small ⊆ large containment.
* `ultrametric_balls_nested_or_disjoint` — the tree property: any two closed balls
  (with comparable radii) are nested or disjoint.
* `clusterSetoid` — the same-cluster relation at scale `ε ≥ 0` is an equivalence.
* `cluster_eq_closedBall` — cluster classes are exactly closed balls.
* `sameCluster_mono` — coarsening: classes only grow as the scale `ε` grows
  (equivalently, the partition refines as `ε` shrinks) — the levels of the tree.
-/

import Mathlib

open Metric

namespace PadicAttn

variable {S : Type*} [PseudoMetricSpace S] [IsUltrametricDist S]

/-! ## The hierarchical tree property of ultrametric attention summaries -/

-- !-- Lab Notebook -- !--
-- Hypothesis: p-adic compression of attention rows yields a *tree* iff the balls
--   of the summary space never partially overlap.
-- Result: proved (`ultrametric_balls_nested_or_disjoint`) for any ultrametric space,
--   hence for ℚ_[p]; the strong (isosceles) triangle inequality is the only input.
-- Insight: the entire dendrogram structure is a consequence of a single inequality
--   `dist x z ≤ max (dist x y) (dist y z)` — no probabilistic or learned structure
--   is needed for the hierarchy to exist; it is forced by non-Archimedean geometry.
-- Failure analysis: a first attempt via `‖·‖` and `ring` failed (`ring` does not
--   normalise group subtraction); switching to the `dist` API and
--   `IsUltrametricDist.dist_triangle_max` removed all friction.
-- !-- Lab Notebook -- !--

-- !-- If the closed ball of radius `r` and the (no-smaller) closed ball of radius `s`
-- share a point `z`, then for any `w` in the small ball, `dist w y ≤ s` via two
-- applications of the ultrametric inequality through `z`. -- !--
theorem ultrametric_balls_subset_of_le
    {x y : S} {r s : ℝ} (hrs : r ≤ s)
    (h : (closedBall x r ∩ closedBall y s).Nonempty) :
    closedBall x r ⊆ closedBall y s := by
  obtain ⟨z, hzx, hzy⟩ := h
  simp only [mem_closedBall] at hzx hzy
  intro w hw
  simp only [mem_closedBall] at hw ⊢
  have hxy : dist x y ≤ s := by
    have hmax := IsUltrametricDist.dist_triangle_max x z y
    calc dist x y ≤ max (dist x z) (dist z y) := hmax
      _ ≤ s := max_le (by rw [dist_comm]; exact le_trans hzx hrs) hzy
  calc dist w y ≤ max (dist w x) (dist x y) := IsUltrametricDist.dist_triangle_max w x y
    _ ≤ s := max_le (le_trans hw hrs) hxy

-- !-- Either the balls share a point (then nested, by the previous lemma) or their
-- intersection is empty (then disjoint). -- !--
theorem ultrametric_balls_nested_or_disjoint
    {x y : S} {r s : ℝ} (hrs : r ≤ s) :
    closedBall x r ⊆ closedBall y s ∨ Disjoint (closedBall x r) (closedBall y s) := by
  rcases (closedBall x r ∩ closedBall y s).eq_empty_or_nonempty with h | h
  · right; exact Set.disjoint_iff_inter_eq_empty.mpr h
  · left; exact ultrametric_balls_subset_of_le hrs h

/-! ## Same-cluster relation: the levels of the tree -/

/-- Two attention summaries are in the same cluster at resolution `ε` when their
    ultrametric distance is at most `ε`. -/
def SameCluster (ε : ℝ) (x y : S) : Prop := dist x y ≤ ε

omit [IsUltrametricDist S] in
theorem sameCluster_refl {ε : ℝ} (hε : 0 ≤ ε) (x : S) : SameCluster ε x x := by
  simpa [SameCluster] using hε

omit [IsUltrametricDist S] in
theorem sameCluster_symm {ε : ℝ} {x y : S} (h : SameCluster ε x y) : SameCluster ε y x := by
  rwa [SameCluster, dist_comm]

-- !-- Transitivity is exactly the ultrametric inequality: `dist x z ≤ max (dist x y)
-- (dist y z) ≤ max ε ε = ε`. This is where non-Archimedean geometry is essential —
-- it would FAIL for an ordinary metric. -- !--
theorem sameCluster_trans {ε : ℝ} {x y z : S}
    (hxy : SameCluster ε x y) (hyz : SameCluster ε y z) : SameCluster ε x z :=
  le_trans (IsUltrametricDist.dist_triangle_max x y z) (max_le hxy hyz)

omit [IsUltrametricDist S] in
/-- Coarsening: a coarser resolution `ε₂ ≥ ε₁` merges clusters. Equivalently, the
    partition *refines* as the resolution `ε` decreases — these are the levels of
    the hierarchical tree. -/
theorem sameCluster_mono {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) {x y : S}
    (hxy : SameCluster ε₁ x y) : SameCluster ε₂ x y :=
  le_trans hxy h

/-- At every nonnegative resolution `ε`, the same-cluster relation is an equivalence
    relation: its classes are the nodes of the tree at that level. -/
def clusterSetoid (ε : ℝ) (hε : 0 ≤ ε) : Setoid S where
  r := SameCluster ε
  iseqv := ⟨sameCluster_refl hε, sameCluster_symm, sameCluster_trans⟩

-- !-- A cluster class is, by unfolding both definitions and using `dist_comm`, exactly
-- a closed ball; the tree-property lemma above therefore governs the clusters. -- !--
omit [IsUltrametricDist S] in
theorem cluster_eq_closedBall (ε : ℝ) (x : S) :
    {y | SameCluster ε x y} = closedBall x ε := by
  ext y; simp [SameCluster, mem_closedBall, dist_comm]

/-- The cluster classes at any two comparable resolutions are nested or disjoint:
    the dendrogram is a genuine rooted tree. -/
theorem clusters_nested_or_disjoint {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) (x y : S) :
    {z | SameCluster ε₁ x z} ⊆ {z | SameCluster ε₂ y z} ∨
      Disjoint {z | SameCluster ε₁ x z} {z | SameCluster ε₂ y z} := by
  rw [cluster_eq_closedBall, cluster_eq_closedBall]
  exact ultrametric_balls_nested_or_disjoint h

end PadicAttn