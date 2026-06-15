/-
# The Boltzmann Bridge XI — Convexity & Bicombing of Interleaving Geodesics

Bridges IX–X (`Applications.BoltzmannBridge.InterleavingGeodesic`,
`Applications.BoltzmannBridge.InterleavingGeodesicGluing`) studied a *single*
geodesic `lerp F G` and its reparametrisations.  Bridge XI supplies the
**curvature** layer: it compares *different* geodesics run by the *same* clock and
proves the interleaving metric is **convex** in the strong sense of admitting a
convex geodesic bicombing:

> `d(lerp F G t, lerp F' G' t) ≤ ofReal (1−t)·d(F,F') + ofReal t·d(G,G')`.

Two geodesics run by the same clock never separate faster than the convex
combination of the distances between their endpoints — the defining inequality of a
Busemann (non-positively curved) space.  Specialising one geodesic to a constant
point (`lerp H H t = H`, `lerp_self`) recovers ordinary convexity of the distance to
a fixed filtration along a geodesic.  The whole result is, once again, the Bridge
VIII sup-isometry (`eInterleavingDist_eq_weightSupEDist`) transporting a single
elementary fact — the triangle inequality for real absolute values,
`|(1−t)a + tb| ≤ (1−t)|a| + t|b|` — through a supremum.

## Main results

* `lerp_reverse` — the affine reversal symmetry `lerp F G t = lerp G F (1−t)`.
* `lerp_self` — constant geodesics are stationary, `lerp F F t = F`.
* `weightSupEDist_lerp_bicombing` — the convexity bound at the sup-distance level.
* `eInterleavingDist_lerp_bicombing` — the convex geodesic bicombing inequality
  (Busemann convexity of the interleaving metric).
* `eInterleavingDist_lerp_convex` — convexity of the distance to a fixed filtration
  along the geodesic, as the constant-geodesic special case.
-/
import Mathlib
import Applications.BoltzmannBridge.HigherPersistence
import Applications.BoltzmannBridge.PersistenceStability
import Applications.BoltzmannBridge.BottleneckStability
import Applications.BoltzmannBridge.InterleavingMetric
import Applications.BoltzmannBridge.InterleavingClosure
import Applications.BoltzmannBridge.InterleavingIsometry
import Applications.BoltzmannBridge.InterleavingGeodesic
import Applications.BoltzmannBridge.InterleavingGeodesicGluing

open Finset BigOperators
open scoped ENNReal

namespace BoltzmannBridge

namespace Filtration

variable {α : Type*}

/-! ## Affine symmetries of the geodesic -/

-- !-- `ext_weight`; pointwise `(1−t)F + tG = (1−(1−t))G + (1−t)F` by `ring`. -- !--
/-- **Affine reversal symmetry.**  Running the geodesic from `G` to `F` with the
reversed clock `1 − t` traces the *same* points: `lerp F G t = lerp G F (1 − t)`. -/
theorem lerp_reverse (F G : Filtration α) {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    lerp F G t ht0 ht1 = lerp G F (1 - t) (by linarith) (by linarith) := by
  apply ext_weight; funext σ; simp only [lerp_weight]; ring

-- !-- `ext_weight`; pointwise `(1−t)F + tF = F` by `ring`. -- !--
/-- **Constant geodesics are stationary.**  Interpolating a filtration with itself
never moves: `lerp F F t = F` for every `t`. -/
theorem lerp_self (F : Filtration α) {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    lerp F F t ht0 ht1 = F := by
  apply ext_weight; funext σ; simp only [lerp_weight]; ring

/-! ## The convex geodesic bicombing -/

-- !-- `iSup_le`: for each `σ`, the per-simplex gap factors as
-- !-- `|(1−t)(F−F') + t(G−G')| ≤ (1−t)|F−F'| + t|G−G'|` (`abs_add`, `abs_mul`,
-- !-- nonnegativity of `1−t, t`).  Push `ofReal` through the sum/products and dominate
-- !-- each weight gap by its `weightSupEDist` supremum (`le_iSup`), then `gcongr`. -- !--
/-- **Convexity bound at the sup-distance level.**  The sup-distance between two
same-clock interpolants is bounded by the convex combination of the endpoint
sup-distances. -/
theorem weightSupEDist_lerp_bicombing (F G F' G' : Filtration α) {t : ℝ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    weightSupEDist (lerp F G t ht0 ht1) (lerp F' G' t ht0 ht1)
      ≤ ENNReal.ofReal (1 - t) * weightSupEDist F F'
        + ENNReal.ofReal t * weightSupEDist G G' := by
  refine' iSup_le _;
  intro σ
  have h_abs : |(F.lerp G t ht0 ht1).weight σ - (F'.lerp G' t ht0 ht1).weight σ| ≤ (1 - t) * |F.weight σ - F'.weight σ| + t * |G.weight σ - G'.weight σ| := by
    rw [ lerp_weight, lerp_weight ];
    cases abs_cases ( F.weight σ - F'.weight σ ) <;> cases abs_cases ( G.weight σ - G'.weight σ ) <;> cases abs_cases ( ( 1 - t ) * F.weight σ + t * G.weight σ - ( ( 1 - t ) * F'.weight σ + t * G'.weight σ ) ) <;> nlinarith;
  refine' le_trans ( ENNReal.ofReal_le_ofReal h_abs ) _;
  rw [ ENNReal.ofReal_add, ENNReal.ofReal_mul, ENNReal.ofReal_mul ] <;> try linarith;
  · gcongr; all_goals exact le_iSup_of_le σ ( by simp +decide );
  · exact mul_nonneg ( sub_nonneg.2 ht1 ) ( abs_nonneg _ );
  · positivity

-- !-- Rewrite the three distances via Bridge VIII's
-- !-- `eInterleavingDist_eq_weightSupEDist` and apply `weightSupEDist_lerp_bicombing`. -- !--
/-- **Convex geodesic bicombing (Busemann convexity).**  Two geodesics run by the
same clock never separate faster than the convex combination of the distances
between their endpoints:
`d(lerp F G t, lerp F' G' t) ≤ ofReal (1−t)·d(F,F') + ofReal t·d(G,G')`. -/
theorem eInterleavingDist_lerp_bicombing (F G F' G' : Filtration α) {t : ℝ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    eInterleavingDist (lerp F G t ht0 ht1) (lerp F' G' t ht0 ht1)
      ≤ ENNReal.ofReal (1 - t) * eInterleavingDist F F'
        + ENNReal.ofReal t * eInterleavingDist G G' := by
  -- Apply the isometry property to rewrite the goal in terms of weightSupEDist.
  rw [eInterleavingDist_eq_weightSupEDist, eInterleavingDist_eq_weightSupEDist,
    eInterleavingDist_eq_weightSupEDist]
  exact weightSupEDist_lerp_bicombing F G F' G' ht0 ht1

-- !-- Write `H = lerp H H t` (`lerp_self`) and apply `eInterleavingDist_lerp_bicombing`
-- !-- with `F' = G' = H`. -- !--
/-- **Convexity of the distance to a fixed filtration.**  Along the geodesic
`lerp F G`, the distance to any fixed filtration `H` is a convex function of the
parameter: `d(lerp F G t, H) ≤ ofReal (1−t)·d(F,H) + ofReal t·d(G,H)`.  This is the
constant-geodesic special case of the bicombing bound (`lerp H H t = H`). -/
theorem eInterleavingDist_lerp_convex (F G H : Filtration α) {t : ℝ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    eInterleavingDist (lerp F G t ht0 ht1) H
      ≤ ENNReal.ofReal (1 - t) * eInterleavingDist F H
        + ENNReal.ofReal t * eInterleavingDist G H := by
  convert eInterleavingDist_lerp_bicombing F G H H ht0 ht1 using 1;
  rw [ lerp_self ]

end Filtration

/-
-- !-- Lab Notebook -- !--

## Hypothesis
Bridges IX–X established that `(Filtration α, eInterleavingDist)` is geodesic with a
self-coherent field of geodesics `lerp`.  The adversarial hypothesis: the space is
not merely geodesic but *non-positively curved* in the Busemann sense, i.e. `lerp`
is a **convex geodesic bicombing** — two geodesics run by the same clock separate at
most as fast as the convex combination of their endpoint distances.

## Result
Confirmed.  `weightSupEDist_lerp_bicombing` is the convexity bound at the
sup-distance level; transported through the Bridge VIII isometry it becomes
`eInterleavingDist_lerp_bicombing`, the Busemann convexity inequality.  Specialising
one geodesic to a constant point (`lerp_self`: `lerp H H t = H`) yields
`eInterleavingDist_lerp_convex`, ordinary convexity of the distance to a fixed
filtration.  The affine reversal `lerp_reverse` records the segment's symmetry.

## Insight
Curvature, like geodesy (Bridge IX) and coherence (Bridge X), is *inherited through
the isometry*.  The only nontrivial step is the per-simplex triangle inequality for
real absolute values, `|(1−t)a + tb| ≤ (1−t)|a| + t|b|`; the supremum then preserves
the bound coordinatewise.  An ℓ^∞-type (sup-normed) geometry is flat-convex: the
bicombing inequality holds with the optimal convex coefficients, but it is never
*strict*, since the sup is attained on possibly different simplices for the two
endpoint distances.

## Failure analysis
The bound is an inequality, not the equality of the constant-speed law
`eInterleavingDist_lerp`: convexity loses information when the supremising simplices
of the two endpoint distances disagree (the convexity *defect*).  The convexity
hypotheses `0 ≤ t ≤ 1` remain intrinsic — they are needed both to name the `lerp`
filtrations and to keep the coefficients `1−t, t` nonnegative for the absolute-value
triangle inequality.  Whether the bound sharpens to the `max` (nonexpansiveness) or
admits a matching reverse bound is deferred to FUTURE_DIRECTIONS (Directions 3, 4).
-/

end BoltzmannBridge