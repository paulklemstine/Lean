/-
# The Boltzmann Bridge X — The Path Space of Filtrations

This file opens the **homotopical** chapter promised by Bridge IX
(`Applications.BoltzmannBridge.InterleavingGeodesic`).  Bridge IX produced the
first explicit *path of filtrations*, the convex-interpolation geodesic `lerp`,
and proved the constant-speed identity
`eInterleavingDist (lerp F G s) (lerp F G t) = ofReal |s − t| · eInterleavingDist F G`
(`eInterleavingDist_lerp`).  That established `(Filtration α, eInterleavingDist)`
is a geodesic space.

Bridge X studies the **structure of the path space** these geodesics generate:

* **Reparametrisation / path algebra** (`lerp_lerp`): the `lerp` family is closed
  under composition — a `lerp` of two `lerp`s is again a `lerp`, with parameter the
  affine combination `(1−t)·a + t·b`.  Sub-paths of geodesics are geodesics, so the
  geodesics form a reparametrisation-stable family (the combinatorial skeleton of a
  fundamental groupoid).
* **Metric betweenness** (`eInterleavingDist_lerp_betweenness`): for `s ≤ u ≤ t`
  the intermediate point `lerp F G u` lies *metrically between* the endpoints,
  `d(lerp s, lerp u) + d(lerp u, lerp t) = d(lerp s, lerp t)`.  This is the full
  geodesic-segment law generalising Bridge IX's midpoint bisection.
* **Geodesic convexity of the metric** (`eInterleavingDist_convex`): the distance
  to a fixed filtration is convex along `lerp`,
  `d(H, lerp F G t) ≤ ofReal(1−t)·d(H,F) + ofReal t·d(H,G)`.  This is the
  Busemann / non-positive-curvature-flavoured convexity inequality, inherited from
  the sup-distance via Bridge VIII (`eInterleavingDist_eq_weightSupEDist`).
* **The space is geodesic** (`exists_constantSpeed_geodesic`): a single bundled
  existence statement — between any two filtrations there is a path realising the
  interleaving distance at constant speed.

## Main results

* `lerp_self` — `lerp F F t = F` (degenerate geodesic).
* `lerp_lerp` — reparametrisation closure of the geodesic family.
* `eInterleavingDist_lerp_betweenness` — the geodesic-segment additivity law.
* `eInterleavingDist_convex` — convexity of the interleaving distance along `lerp`.
* `exists_constantSpeed_geodesic` — `(Filtration α, eInterleavingDist)` is geodesic.
-/
import Mathlib
import Applications.BoltzmannBridge.HigherPersistence
import Applications.BoltzmannBridge.InterleavingMetric
import Applications.BoltzmannBridge.InterleavingClosure
import Applications.BoltzmannBridge.InterleavingIsometry
import Applications.BoltzmannBridge.InterleavingGeodesic

open Finset BigOperators
open scoped ENNReal

namespace BoltzmannBridge

namespace Filtration

variable {α : Type*}

/-! ## Degenerate geodesic -/

-- !-- `(1−t)·F + t·F = F` pointwise; `ext_weight` then `ring`. -- !--
/-- The geodesic between a filtration and itself is constant. -/
@[simp] theorem lerp_self (F : Filtration α) {t : ℝ} (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    lerp F F t ht0 ht1 = F := by
  apply ext_weight; funext σ; simp only [lerp_weight]; ring

/-! ## Reparametrisation: the geodesic family is closed under composition -/

-- !-- Expand both layers: `lerp (lerp F G a) (lerp F G b) t` has weight
-- !-- `(1−t)[(1−a)F+aG] + t[(1−b)F+bG]`; collecting the `G`-coefficient gives
-- !-- `c := (1−t)a + t b`, and the `F`-coefficient is `1−c`, i.e. `lerp F G c`.
-- !-- `ext_weight` then `simp only [lerp_weight]; ring`. -- !--
/-- **Reparametrisation closure of the geodesic family.**  A `lerp` of two points on
the `F`–`G` geodesic is again a point on that geodesic, at the affine parameter
`(1−t)·a + t·b`.  Hence the geodesics are stable under reparametrisation and
composition — the combinatorial skeleton of a path groupoid. -/
theorem lerp_lerp (F G : Filtration α) {a b t : ℝ}
    (ha0 : 0 ≤ a) (ha1 : a ≤ 1) (hb0 : 0 ≤ b) (hb1 : b ≤ 1)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    lerp (lerp F G a ha0 ha1) (lerp F G b hb0 hb1) t ht0 ht1
      = lerp F G ((1 - t) * a + t * b)
          (by nlinarith) (by nlinarith) := by
  apply ext_weight; funext σ; simp only [lerp_weight]; ring

/-! ## Metric betweenness: the geodesic-segment law -/

-- !-- Rewrite all three distances through `eInterleavingDist_lerp`; with `s ≤ u ≤ t`
-- !-- the absolute values resolve to `u−s`, `t−u`, `t−s`.  Factor `d := d(F,G)` out via
-- !-- `← add_mul`, sum the `ofReal` shifts with `← ENNReal.ofReal_add` (`(u−s)+(t−u)=t−s`). -- !--
/-- **The geodesic-segment law (metric betweenness).**  For `s ≤ u ≤ t` in `[0,1]`,
the point `lerp F G u` lies metrically between `lerp F G s` and `lerp F G t`:
`d(lerp s, lerp u) + d(lerp u, lerp t) = d(lerp s, lerp t)`.  This generalises
Bridge IX's `eInterleavingDist_midpoint` to an arbitrary intermediate parameter and
is the defining additivity property of a geodesic segment. -/
theorem eInterleavingDist_lerp_betweenness (F G : Filtration α) {s u t : ℝ}
    (hs0 : 0 ≤ s) (hs1 : s ≤ 1) (hu0 : 0 ≤ u) (hu1 : u ≤ 1)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (hsu : s ≤ u) (hut : u ≤ t) :
    eInterleavingDist (lerp F G s hs0 hs1) (lerp F G u hu0 hu1)
      + eInterleavingDist (lerp F G u hu0 hu1) (lerp F G t ht0 ht1)
      = eInterleavingDist (lerp F G s hs0 hs1) (lerp F G t ht0 ht1) := by
  rw [eInterleavingDist_lerp, eInterleavingDist_lerp, eInterleavingDist_lerp,
      abs_of_nonpos (by linarith : s - u ≤ 0), abs_of_nonpos (by linarith : u - t ≤ 0),
      abs_of_nonpos (by linarith : s - t ≤ 0), ← add_mul,
      ← ENNReal.ofReal_add (by linarith : (0:ℝ) ≤ -(s - u))
        (by linarith : (0:ℝ) ≤ -(u - t))]
  congr 2
  ring

/-! ## Geodesic convexity of the interleaving distance -/

-- !-- Rewrite every distance via `eInterleavingDist_eq_weightSupEDist` to `weightSupEDist`,
-- !-- `⨆ σ, ofReal |·|`, then `iSup_le`.  Pointwise,
-- !-- `|Hσ − ((1−t)Fσ + tGσ)| ≤ (1−t)|Hσ−Fσ| + t|Hσ−Gσ|` (`abs_cases`/`nlinarith`);
-- !-- push through `ENNReal.ofReal_add`, `ENNReal.ofReal_mul`, then `gcongr` + `le_iSup`. -- !--
/-- **Geodesic convexity of the interleaving distance (Busemann inequality).**  The
distance from a fixed filtration `H` is convex along the geodesic `lerp F G`:
`d(H, lerp F G t) ≤ ofReal(1−t)·d(H,F) + ofReal t·d(H,G)`.  This is the
non-positive-curvature-flavoured convexity inequality; it is inherited from the
sup-distance through Bridge VIII's isometry `eInterleavingDist_eq_weightSupEDist`. -/
theorem eInterleavingDist_convex (H F G : Filtration α) {t : ℝ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    eInterleavingDist H (lerp F G t ht0 ht1)
      ≤ ENNReal.ofReal (1 - t) * eInterleavingDist H F
        + ENNReal.ofReal t * eInterleavingDist H G := by
  rw [eInterleavingDist_eq_weightSupEDist, eInterleavingDist_eq_weightSupEDist,
      eInterleavingDist_eq_weightSupEDist]
  refine iSup_le fun σ => ?_
  have h_abs : |H.weight σ - (lerp F G t ht0 ht1).weight σ|
      ≤ (1 - t) * |H.weight σ - F.weight σ| + t * |H.weight σ - G.weight σ| := by
    rw [lerp_weight]
    cases abs_cases (H.weight σ - F.weight σ) <;>
      cases abs_cases (H.weight σ - G.weight σ) <;>
        cases abs_cases (H.weight σ - ((1 - t) * F.weight σ + t * G.weight σ)) <;>
          nlinarith
  refine le_trans (ENNReal.ofReal_le_ofReal h_abs) ?_
  rw [ENNReal.ofReal_add (mul_nonneg (by linarith) (abs_nonneg _))
        (mul_nonneg ht0 (abs_nonneg _)),
      ENNReal.ofReal_mul (by linarith), ENNReal.ofReal_mul ht0]
  unfold weightSupEDist
  gcongr
  · exact le_iSup (fun τ => ENNReal.ofReal |H.weight τ - F.weight τ|) σ
  · exact le_iSup (fun τ => ENNReal.ofReal |H.weight τ - G.weight τ|) σ

/-! ## The space is geodesic -/

-- !-- Take `γ r := lerp F G (min 1 (max 0 r)) _ _` (the clamp of `r` to `[0,1]`).
-- !-- `γ 0 = F` and `γ 1 = G` since the clamp fixes `0` and `1` (`lerp_zero`, `lerp_one`).
-- !-- For `s, t ∈ [0,1]` the clamp is the identity, so `eInterleavingDist_lerp` applies. -- !--
/-- **`(Filtration α, eInterleavingDist)` is a geodesic space.**  Between any two
filtrations there is a path `γ : ℝ → Filtration α` with `γ 0 = F`, `γ 1 = G`, that
realises the interleaving distance at constant speed:
`d(γ s, γ t) = ofReal |s − t| · d(F, G)` for all `s, t ∈ [0,1]`.  This bundles
Bridge IX's `eInterleavingDist_lerp` into the canonical geodesic-space statement. -/
theorem exists_constantSpeed_geodesic (F G : Filtration α) :
    ∃ γ : ℝ → Filtration α, γ 0 = F ∧ γ 1 = G ∧
      ∀ s t, s ∈ Set.Icc (0 : ℝ) 1 → t ∈ Set.Icc (0 : ℝ) 1 →
        eInterleavingDist (γ s) (γ t)
          = ENNReal.ofReal |s - t| * eInterleavingDist F G := by
  refine ⟨fun r => lerp F G (min 1 (max 0 r))
      (le_min zero_le_one (le_max_left 0 r)) (min_le_left 1 _), ?_, ?_, ?_⟩
  · convert lerp_zero F G using 2
    norm_num
  · convert lerp_one F G using 2
    norm_num
  · intro s t hs ht
    rw [Set.mem_Icc] at hs ht
    have hsc : min 1 (max 0 s) = s := by rw [max_eq_right hs.1, min_eq_right hs.2]
    have htc : min 1 (max 0 t) = t := by rw [max_eq_right ht.1, min_eq_right ht.2]
    simp only [hsc, htc]
    exact eInterleavingDist_lerp F G hs.1 hs.2 ht.1 ht.2

end Filtration

/-
-- !-- Lab Notebook -- !--

## Hypothesis
Bridge IX proved the single geodesic identity `eInterleavingDist_lerp`.  The
homotopical hypothesis is that the resulting geodesics are not isolated objects but
assemble into a *path space*: (a) the family is closed under reparametrisation
(`lerp_lerp`), (b) intermediate points satisfy the full geodesic-segment additivity
law (`eInterleavingDist_lerp_betweenness`), (c) the metric is *convex* along the
geodesics in the Busemann sense (`eInterleavingDist_convex`), and (d) all of this
bundles into the textbook statement that the space is geodesic
(`exists_constantSpeed_geodesic`).

## Result
Confirmed.  `lerp_lerp` shows a `lerp` of two `lerp`s is the `lerp` at the affine
parameter `(1−t)a + t b`, so the geodesic family is a reparametrisation-stable
groupoid skeleton.  `eInterleavingDist_lerp_betweenness` upgrades midpoint bisection
to arbitrary `s ≤ u ≤ t`.  `eInterleavingDist_convex` establishes Busemann
convexity.  `exists_constantSpeed_geodesic` packages the constant-speed geodesic via
a clamped reparametrisation.

## Insight
Two distinct mechanisms cooperate.  *Reparametrisation* (`lerp_lerp`) is purely
**algebraic** — affine combinations of affine combinations are affine — and needs
only `ext_weight` + `ring`; it never touches the metric.  *Convexity*
(`eInterleavingDist_convex`) is **analytic** and routes entirely through Bridge
VIII's isometry: convexity of `|·|` plus the fact that a supremum of convex
combinations is dominated by the convex combination of the suprema.  The geodesic
identity itself (Bridge IX) sits between them: it is the *equality* case of the
convexity inequality restricted to the two endpoints' own geodesic, where the
non-maximising slack vanishes.  Convexity is the inequality; geodesy is its sharp
diagonal.

## Failure analysis
The convexity inequality is genuinely one-directional: equality fails for a generic
third point `H` because the simplex maximising `|H − lerp|` need not maximise either
`|H − F|` or `|H − G|`.  This non-sharpness is the metric shadow of geodesic
*non-uniqueness* (Bridge IX, Direction 2): the sup-metric is flat, not strictly
convex, so the space is geodesic but not uniquely geodesic, and is therefore *not*
CAT(0) despite satisfying the Busemann convexity inequality.  Pinning the exact
defect `ofReal(1−t)·d(H,F) + ofReal t·d(H,G) − d(H, lerp F G t)` is the natural next
target (see FUTURE_DIRECTIONS).
-/

end BoltzmannBridge