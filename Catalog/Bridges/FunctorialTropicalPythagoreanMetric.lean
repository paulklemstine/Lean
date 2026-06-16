/-
  # Metric-Space Packaging of the Berggren Boundary Ultrametric (Conjecture C1)

  Bridge: connects the bespoke tree ultrametric `d` of
  `Bridges.FunctorialTropicalPythagorean` to Mathlib's first-class metric infrastructure.

  This file discharges the *metric-space packaging* half of conjecture **C1**: the boundary
  `Addr = ℕ → Fin 3` of the ternary Berggren tree, equipped with `d`, underlies a genuine
  Mathlib `MetricSpace`, and `d` is registered as an `IsUltrametricDist`. This unlocks the
  entire Mathlib metric API (balls, continuity, the ultrametric ball lemmas) for the
  Pythagorean-Berggren boundary.

  -- !-- Lab Notes -- !--
  HYPOTHESIS (Hypothesizer): the six ultrametric axioms already proven (`d_self`, `d_comm`,
  `d_eq_zero_iff`, `d_triangle`, `d_ultra`, `d_le_one`) are *exactly* the data Mathlib needs
  for a `MetricSpace` plus `IsUltrametricDist`; nothing else is required for packaging.
  EXPERIMENT (Experimenter): assemble `MetricSpace Addr` from `d_self`/`d_comm`/`d_triangle`/
  `d_eq_zero_iff`, then `IsUltrametricDist Addr` from `d_ultra`, then re-derive the half-scale
  similarity and the bounded-diameter facts through the Mathlib `dist`.
  ANALYSIS (Analyst): the packaging is purely structural — the only subtlety is that the
  `IsUltrametricDist` field uses the `max (dist x y) (dist y z)` ordering, which is precisely
  `d_ultra`. The instance is `noncomputable` because `d` is.
  CRITIQUE (Critic): completeness/compactness (the Cantor-space half of C1) is *not* claimed
  here; only the metric/ultrametric packaging is. We flag this explicitly so the result is
  not over-stated. `dist_cons_same` is genuine content (the contraction factor through the
  Mathlib `dist`), not a restatement of an instance field.
  SYNTHESIS (PI): with `Addr` now a bona fide ultrametric space, the remaining C1 work
  (totally bounded + complete ⇒ compact) is a clean follow-up recorded in FUTURE_DIRECTIONS.
-/

import Mathlib
import Bridges.FunctorialTropicalPythagorean

namespace FunctorialTropicalPythagorean

open CategoricalTropicalUltrametric
open Classical

/-- The Berggren boundary `Addr` is a Mathlib `MetricSpace` with distance `d`. -/
noncomputable instance instMetricSpaceAddr : MetricSpace Addr where
  dist := d
  dist_self := d_self
  dist_comm := d_comm
  dist_triangle := d_triangle
  eq_of_dist_eq_zero := fun {x y} h => (d_eq_zero_iff x y).mp h

/-- Under the registered instance, `dist` is literally the tree ultrametric `d`. -/
@[simp] theorem dist_eq_d (x y : Addr) : dist x y = d x y := rfl

/-- The Berggren boundary is an ultrametric space (strong triangle inequality). -/
instance instIsUltrametricDistAddr : IsUltrametricDist Addr :=
  ⟨fun x y z => by simpa [dist_eq_d] using d_ultra x y z⟩

/-- Every distance on the boundary is bounded by `1`: the space has diameter `≤ 1`. -/
theorem dist_le_one (x y : Addr) : dist x y ≤ 1 := by
  simpa [dist_eq_d] using d_le_one x y

/-- The Mathlib distance is nonnegative (sanity check on the packaging). -/
theorem dist_nonneg' (x y : Addr) : 0 ≤ dist x y := by
  simpa [dist_eq_d] using d_nonneg x y

/-- **Half-scale similarity, through the Mathlib metric.** Each Berggren branch insertion
    `cons k` is an exact `(1/2)`-similarity of the ultrametric space `(Addr, dist)`. -/
theorem dist_cons_same (k : Fin 3) (x y : Addr) :
    dist (cons k x) (cons k y) = (1 / 2 : ℝ) * dist x y := by
  simpa [dist_eq_d] using d_cons_same k x y

/-- **Maximal separation of distinct branches, through the Mathlib metric.** Images under
    different first labels sit at the maximal distance `1`. -/
theorem dist_cons_diff {k k' : Fin 3} (hk : k ≠ k') (x y : Addr) :
    dist (cons k x) (cons k' y) = 1 := by
  simpa [dist_eq_d] using d_cons_diff hk x y

end FunctorialTropicalPythagorean