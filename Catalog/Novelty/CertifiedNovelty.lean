/-
Copyright (c) 2024 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Certified Novelty Detection in Metric Spaces

This file develops a quantitative theory of *novelty certification* in (pseudo)metric
spaces. The basic object is the predicate `IsNovel ε S x`, asserting that a point `x`
is `ε`-separated from every element of a reference set `S` ("everything already known").

We connect this qualitative predicate to a continuous *novelty score*
`noveltyScore S x = Metric.infDist x S`, prove its regularity (1-Lipschitz in the
point, antitone in the reference set), and establish two transport principles:

* **Robustness / triangle transfer** (`novel_triangle_transfer`): novelty degrades
  gracefully under perturbation of the query point.
* **Novelty transport under antilipschitz maps** (`novel_transport_antilipschitz`):
  novelty certificates survive *expanding* (lower-Lipschitz) embeddings, with the
  threshold scaling by the antilipschitz constant. Bi-Lipschitz maps therefore give
  faithful two-sided transport (`novel_transport_lipschitz_le`).

Finally we link novelty to *packing*: a mutually `ε`-separated reference set induces a
family of pairwise-disjoint balls of radius `ε/2` (`separated_balls_pairwiseDisjoint`),
the geometric core of all sphere-packing capacity bounds.

## Main results

* `isNovel_iff_le_noveltyScore` — `x` is `ε`-novel iff `ε ≤ noveltyScore S x`.
* `noveltyScore_lipschitz` — the novelty score is 1-Lipschitz in the query point.
* `noveltyScore_antitone` — the novelty score is antitone in the reference set.
* `novel_triangle_transfer` — perturbing the query by `δ` costs at most `δ` of novelty.
* `novel_transport_antilipschitz` — antilipschitz maps transport novelty.
* `separated_balls_pairwiseDisjoint` — mutual separation ⇒ disjoint half-radius balls.
-/

namespace CertifiedNovelty

open Metric

variable {α β : Type*} [PseudoMetricSpace α] [PseudoMetricSpace β]

/-! ## Core definitions -/

/-- `x` is **`ε`-novel** with respect to a reference set `S` if it is at distance at
least `ε` from every point of `S`. -/
def IsNovel (ε : ℝ) (S : Set α) (x : α) : Prop := ∀ s ∈ S, ε ≤ dist x s

/-- The **novelty score** of `x` relative to `S` is the distance from `x` to the set
`S`. For finite `S` this is `min_{s ∈ S} dist x s`; the general definition uses
`Metric.infDist`, inheriting all its regularity. -/
noncomputable def noveltyScore (S : Set α) (x : α) : ℝ := Metric.infDist x S

/-- A set `S` is **mutually `ε`-separated** if any two distinct points are at distance
at least `ε`. -/
def MutuallySeparated (ε : ℝ) (S : Set α) : Prop := S.Pairwise (fun a b => ε ≤ dist a b)

/-! ## Score characterization -/

-- !-- `IsNovel` unfolds to a lower bound on all distances, which is exactly the
-- content of `Metric.le_infDist` for nonempty sets. -- !--
/-- **Adaptive threshold via the score.** A point is `ε`-novel exactly when its novelty
score meets the threshold `ε`. This bridges the predicate-based framework to a
continuous, optimizable scoring function. -/
theorem isNovel_iff_le_noveltyScore {ε : ℝ} {S : Set α} (hS : S.Nonempty) {x : α} :
    IsNovel ε S x ↔ ε ≤ noveltyScore S x := by
  unfold IsNovel noveltyScore
  rw [Metric.le_infDist hS]

/-- One direction holds without nonemptiness: a threshold met by the score certifies
novelty for nonempty sets; here we record the always-true converse for empty `S`. -/
theorem isNovel_empty (ε : ℝ) (x : α) : IsNovel ε (∅ : Set α) x := by
  intro s hs; simp at hs

/-! ## Regularity of the novelty score -/

-- !-- This is exactly `Metric.lipschitz_infDist_pt`: distance-to-a-set is
-- 1-Lipschitz in the point. -- !--
/-- The novelty score is **1-Lipschitz** in the query point: nearby queries have
nearby novelty, so the score is robust to small perturbations of the input. -/
theorem noveltyScore_lipschitz (S : Set α) : LipschitzWith 1 (noveltyScore S) :=
  lipschitz_infDist_pt S

/-- The novelty score is always nonnegative. -/
theorem noveltyScore_nonneg (S : Set α) (x : α) : 0 ≤ noveltyScore S x :=
  Metric.infDist_nonneg

-- !-- Enlarging the reference set can only bring known points closer, so `infDist`
-- decreases; this is `Metric.infDist_le_infDist_of_subset`. -- !--
/-- The novelty score is **antitone in the reference set**: the more you already know,
the less novel any fixed query can be. -/
theorem noveltyScore_antitone {S T : Set α} (hTS : T ⊆ S) (hT : T.Nonempty) (x : α) :
    noveltyScore S x ≤ noveltyScore T x :=
  Metric.infDist_le_infDist_of_subset hTS hT

/-- Novelty is **antitone in the reference set** at the predicate level: novelty against
a larger set implies novelty against any subset. -/
theorem isNovel_antitone_set {ε : ℝ} {S T : Set α} (hTS : T ⊆ S) {x : α}
    (h : IsNovel ε S x) : IsNovel ε T x :=
  fun s hs => h s (hTS hs)

/-! ## Robustness: triangle transfer -/

-- !-- For `s ∈ S`, the triangle inequality gives
-- `dist y s ≥ dist x s - dist x y ≥ ε - δ`. -- !--
/-- **Novelty triangle transfer (robustness).** If `x` is `ε`-novel and `y` lies within
`δ` of `x`, then `y` is `(ε - δ)`-novel. Novelty certificates degrade by at most the
perturbation size. -/
theorem novel_triangle_transfer {ε δ : ℝ} {S : Set α} {x y : α}
    (hxy : dist x y ≤ δ) (hx : IsNovel ε S x) : IsNovel (ε - δ) S y := by
  intro s hs
  have h1 : ε ≤ dist x s := hx s hs
  have h2 : dist x s ≤ dist x y + dist y s := dist_triangle x y s
  linarith

/-! ## Transport under maps -/

-- !-- Antilipschitz means `dist x s ≤ K * dist (f x) (f s)`, so
-- `dist (f x) (f s) ≥ dist x s / K ≥ ε / K`. -- !--
/-- **Novelty transport under antilipschitz (expanding) maps.** If `f` is
`AntilipschitzWith K` with `K > 0` and `x` is `ε`-novel w.r.t. `S`, then `f x` is
`(ε / K)`-novel w.r.t. the image `f '' S`. Expanding embeddings never destroy novelty;
they only rescale the threshold. -/
theorem novel_transport_antilipschitz {K : NNReal} {f : α → β}
    (hf : AntilipschitzWith K f) (hK : 0 < (K : ℝ)) {ε : ℝ} {S : Set α} {x : α}
    (hx : IsNovel ε S x) : IsNovel (ε / K) (f '' S) (f x) := by
  rintro _ ⟨s, hs, rfl⟩
  have hxs : ε ≤ dist x s := hx s hs
  have hle : dist x s ≤ (K : ℝ) * dist (f x) (f s) := hf.le_mul_dist x s
  rw [div_le_iff₀ hK]
  calc ε ≤ dist x s := hxs
    _ ≤ (K : ℝ) * dist (f x) (f s) := hle
    _ = dist (f x) (f s) * K := by ring

-- !-- Lipschitz maps contract distances, so the image distance is an upper bound on the
-- transported threshold; `dist (f x) (f s) ≤ K * dist x s`. -- !--
/-- **One-sided contraction under Lipschitz maps.** If `f` is `LipschitzWith K` then the
image distance is bounded by `K` times the source distance, so the maximal novelty
threshold of `f x` w.r.t. `f '' S` is at most `K` times that of `x`. Combined with
`novel_transport_antilipschitz`, a bi-Lipschitz map gives faithful two-sided transport. -/
theorem novel_transport_lipschitz_le {K : NNReal} {f : α → β}
    (hf : LipschitzWith K f) (x s : α) :
    dist (f x) (f s) ≤ (K : ℝ) * dist x s :=
  hf.dist_le_mul x s

/-! ## Packing: separation yields disjoint balls -/

-- !-- Two points at distance `≥ ε` have disjoint open balls of radius `ε/2`, since
-- `ε/2 + ε/2 = ε ≤ dist`; apply `Metric.ball_disjoint_ball`. -- !--
/-- **Packing core.** If `a` and `b` are `ε`-separated, the open balls of radius `ε/2`
about them are disjoint. -/
theorem separated_ball_disjoint {ε : ℝ} {a b : α} (h : ε ≤ dist a b) :
    Disjoint (ball a (ε / 2)) (ball b (ε / 2)) :=
  Metric.ball_disjoint_ball (by linarith)

/-- **Packing from mutual separation.** A mutually `ε`-separated reference set induces a
family of pairwise-disjoint balls of radius `ε/2`. This is the geometric heart of every
sphere-packing capacity bound: the number of "genuinely novel" points in a bounded
region is limited by how many disjoint `ε/2`-balls fit. -/
theorem separated_balls_pairwiseDisjoint {ε : ℝ} {S : Set α} (hS : MutuallySeparated ε S) :
    S.PairwiseDisjoint (fun c => ball c (ε / 2)) := by
  intro a ha b hb hab
  exact separated_ball_disjoint (hS ha hb hab)

/-! ## Bridge: separation ⇔ pointwise novelty -/

-- !-- Removing `x` from a separated set, every remaining point is `ε`-far from `x` by
-- definition of `MutuallySeparated`. -- !--
/-- **Separation as pointwise novelty.** In a mutually `ε`-separated set, each point is
`ε`-novel with respect to all the others. This identifies the global packing condition
with the pointwise novelty certificates it guarantees. -/
theorem isNovel_of_mutuallySeparated {ε : ℝ} {S : Set α} (hS : MutuallySeparated ε S)
    {x : α} (hx : x ∈ S) : IsNovel ε (S \ {x}) x := by
  intro s hs
  have hsx : s ≠ x := by
    intro h; exact hs.2 (by simp [h])
  have h := hS hx hs.1 (fun h => hsx h.symm)
  simpa using h

end CertifiedNovelty