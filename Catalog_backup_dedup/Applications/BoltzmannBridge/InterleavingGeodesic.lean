/-
# The Boltzmann Bridge IX — The Interleaving Metric is *Geodesic*

This file closes the metric story of the persistence-stability arc and opens its
**homotopical** chapter.  The arc so far moved from a relational preorder
(`BottleneckStability`: `Interleaved`), to a pseudo-emetric
(`InterleavingMetric`: `eInterleavingDist`, `interleavingPseudoEMetric`), to a
genuine `EMetricSpace` with attained infimum (`InterleavingClosure`:
`eInterleavingDist_eq_zero_iff_eq`), to an exact isometry onto weight functions
under the extended sup-distance (`InterleavingIsometry`:
`eInterleavingDist_eq_weightSupEDist`, `weightSupEDist`).

Bridge IX adds the missing geometric layer: the space is not merely *isometric* to
a sup-space, it is itself **geodesic**.  Convex interpolation of the weight
functions,

> `lerp F G t` with weight `σ ↦ (1 − t)·F.weight σ + t·G.weight σ`,

is a valid `Filtration` for `0 ≤ t ≤ 1` (the convex combination preserves
`weight_empty` and `weight_mono`), gives a path from `F` (`lerp_zero`) to `G`
(`lerp_one`), and the interleaving distance varies **exactly linearly** along it:

> **`eInterleavingDist (lerp F G s) (lerp F G t) = ENNReal.ofReal |s − t| · eInterleavingDist F G`**
> (`eInterleavingDist_lerp`).

This is the first explicit *path of filtrations* in the catalog — a homotopy
between data shapes that realises the interleaving distance at constant speed —
and the natural launch point for a path-space / fundamental-groupoid treatment of
persistence.

## Main results

* `lerp`, `lerp_weight`, `lerp_zero`, `lerp_one` — the convex-interpolation path of
  filtrations and its endpoints.
* `weight_lerp_sub` — pointwise weight gaps scale linearly:
  `|lerp s − lerp t| = |s − t| · |F − G|`.
* `weightSupEDist_lerp` — the extended sup-distance is linear along the path.
* `eInterleavingDist_lerp` — **the constant-speed geodesic identity** (built on
  Bridge VIII's `eInterleavingDist_eq_weightSupEDist`).
* `eInterleavingDist_lerp_left` — distance from the endpoint `F` is
  `ENNReal.ofReal t · eInterleavingDist F G`.
* `eInterleavingDist_midpoint` — the midpoint bisects the distance additively.
-/
import Mathlib
import Applications.BoltzmannBridge.HigherPersistence
import Applications.BoltzmannBridge.PersistenceStability
import Applications.BoltzmannBridge.BottleneckStability
import Applications.BoltzmannBridge.InterleavingMetric
import Applications.BoltzmannBridge.InterleavingClosure
import Applications.BoltzmannBridge.InterleavingIsometry

open Finset BigOperators
open scoped ENNReal

namespace BoltzmannBridge

namespace Filtration

variable {α : Type*}

/-! ## The convex-interpolation path of filtrations -/

-- !-- The convex combination `(1−t)·F + t·G` of weights.  `weight_empty`:
-- !-- both `F.weight ∅, G.weight ∅ ≤ 0` and both coefficients `≥ 0`, so `nlinarith`.
-- !-- `weight_mono`: combine `F.weight_mono h` and `G.weight_mono h` with nonneg
-- !-- coefficients. -- !--
/-- **The convex-interpolation path of filtrations.**  For `0 ≤ t ≤ 1`, `lerp F G t`
is the filtration whose weight is the convex combination
`σ ↦ (1 − t)·F.weight σ + t·G.weight σ`.  The convexity hypotheses `0 ≤ t` and
`t ≤ 1` are exactly what make the combination a valid monotone, grounded weight. -/
noncomputable def lerp (F G : Filtration α) (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    Filtration α where
  weight σ := (1 - t) * F.weight σ + t * G.weight σ
  weight_empty := by nlinarith [F.weight_empty, G.weight_empty]
  weight_mono := by
    intro σ τ h
    have h1 := F.weight_mono h
    have h2 := G.weight_mono h
    nlinarith

@[simp] theorem lerp_weight (F G : Filtration α) (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1)
    (σ : Finset α) :
    (lerp F G t ht0 ht1).weight σ = (1 - t) * F.weight σ + t * G.weight σ := rfl

-- !-- At `t = 0` the weight is `1·F + 0·G = F`; `ext_weight` then `simp`/`ring`. -- !--
/-- The path starts at `F`: `lerp F G 0 = F`. -/
theorem lerp_zero (F G : Filtration α) : lerp F G 0 le_rfl zero_le_one = F := by
  apply ext_weight; funext σ; simp

-- !-- At `t = 1` the weight is `0·F + 1·G = G`; `ext_weight` then `simp`/`ring`. -- !--
/-- The path ends at `G`: `lerp F G 1 = G`. -/
theorem lerp_one (F G : Filtration α) : lerp F G 1 zero_le_one le_rfl = G := by
  apply ext_weight; funext σ; simp

/-! ## Linearity of the weight gaps and the sup-distance -/

-- !-- `(lerp s − lerp t).weight σ = (t − s)·(F.weight σ − G.weight σ)` by `ring`;
-- !-- take `|·|` via `abs_mul`, `abs_sub_comm`. -- !--
/-- **Pointwise weight gaps scale linearly.**  For `s, t ∈ [0,1]` the gap between
the interpolated weights at every simplex is `|s − t|` times the original gap. -/
theorem weight_lerp_sub (F G : Filtration α) {s t : ℝ}
    (hs0 : 0 ≤ s) (hs1 : s ≤ 1) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (σ : Finset α) :
    |(lerp F G s hs0 hs1).weight σ - (lerp F G t ht0 ht1).weight σ|
      = |s - t| * |F.weight σ - G.weight σ| := by
  simp only [lerp_weight]
  rw [show (1 - s) * F.weight σ + s * G.weight σ
        - ((1 - t) * F.weight σ + t * G.weight σ)
        = (t - s) * (F.weight σ - G.weight σ) by ring,
      abs_mul, abs_sub_comm t s]

-- !-- `weightSupEDist (lerp s)(lerp t) = ⨆ σ, ofReal |lerp s − lerp t|`.  Pull the
-- !-- constant `ofReal |s − t|` out of the `⨆` (`ENNReal.mul_iSup`), then match termwise
-- !-- with `weight_lerp_sub` and `ENNReal.ofReal_mul`. -- !--
/-- **The extended sup-distance is linear along the path.** -/
theorem weightSupEDist_lerp (F G : Filtration α) {s t : ℝ}
    (hs0 : 0 ≤ s) (hs1 : s ≤ 1) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    weightSupEDist (lerp F G s hs0 hs1) (lerp F G t ht0 ht1)
      = ENNReal.ofReal |s - t| * weightSupEDist F G := by
  unfold weightSupEDist
  rw [ENNReal.mul_iSup]
  refine iSup_congr fun σ => ?_
  rw [weight_lerp_sub, ENNReal.ofReal_mul (abs_nonneg _)]

/-! ## The constant-speed geodesic identity -/

-- !-- Rewrite both sides through Bridge VIII's `eInterleavingDist_eq_weightSupEDist`
-- !-- and apply `weightSupEDist_lerp`. -- !--
/-- **The constant-speed geodesic identity.**  The interleaving distance varies
*exactly linearly* along the convex-interpolation path:
`d(lerp F G s, lerp F G t) = ofReal |s − t| · d(F, G)`.  Hence `(Filtration α,
eInterleavingDist)` is a geodesic space and `lerp` is a constant-speed geodesic. -/
theorem eInterleavingDist_lerp (F G : Filtration α) {s t : ℝ}
    (hs0 : 0 ≤ s) (hs1 : s ≤ 1) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    eInterleavingDist (lerp F G s hs0 hs1) (lerp F G t ht0 ht1)
      = ENNReal.ofReal |s - t| * eInterleavingDist F G := by
  rw [eInterleavingDist_eq_weightSupEDist, eInterleavingDist_eq_weightSupEDist,
      weightSupEDist_lerp]

-- !-- `F = lerp F G 0` (`lerp_zero`), so the distance equals
-- !-- `d(lerp 0, lerp t) = ofReal |0 − t| · d`; `|0 − t| = t` since `t ≥ 0`. -- !--
/-- **Distance from the start of the path.**  The interleaving distance from the
endpoint `F` to the point `lerp F G t` is `ofReal t · d(F, G)`. -/
theorem eInterleavingDist_lerp_left (F G : Filtration α) {t : ℝ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    eInterleavingDist F (lerp F G t ht0 ht1)
      = ENNReal.ofReal t * eInterleavingDist F G := by
  have h : eInterleavingDist F (lerp F G t ht0 ht1)
      = eInterleavingDist (lerp F G 0 le_rfl zero_le_one) (lerp F G t ht0 ht1) := by
    rw [lerp_zero]
  rw [h, eInterleavingDist_lerp]
  congr 2
  rw [show (0 : ℝ) - t = -t by ring, abs_neg, abs_of_nonneg ht0]

-- !-- `d(F, mid) = ofReal(1/2)·d` (`eInterleavingDist_lerp_left`) and `d(mid, G) =
-- !-- d(lerp ½, lerp 1) = ofReal|½ − 1|·d = ofReal(1/2)·d`; sum the `ofReal` halves to
-- !-- `ofReal 1 = 1` and `1 · d = d`. -- !--
/-- **The midpoint bisects the distance additively.**  The point `lerp F G ½` sits
exactly halfway: `d(F, lerp F G ½) + d(lerp F G ½, G) = d(F, G)`.  This is the
metric witness that the geodesic `lerp` has constant speed. -/
theorem eInterleavingDist_midpoint (F G : Filtration α) :
    eInterleavingDist F (lerp F G (1/2) (by norm_num) (by norm_num))
      + eInterleavingDist (lerp F G (1/2) (by norm_num) (by norm_num)) G
      = eInterleavingDist F G := by
  rw [eInterleavingDist_lerp_left]
  have hG : eInterleavingDist (lerp F G (1/2) (by norm_num) (by norm_num)) G
      = eInterleavingDist (lerp F G (1/2) (by norm_num) (by norm_num))
          (lerp F G 1 zero_le_one le_rfl) := by
    rw [lerp_one]
  rw [hG, eInterleavingDist_lerp, show |(1/2 : ℝ) - 1| = 1/2 by norm_num,
      ← add_mul, ← ENNReal.ofReal_add (by norm_num) (by norm_num)]
  norm_num

end Filtration

/-
-- !-- Lab Notebook -- !--

## Hypothesis
Bridge VIII proved `(Filtration α, eInterleavingDist)` is *isometric* to the weight
functions under the extended sup-distance (`eInterleavingDist_eq_weightSupEDist`).
A sup-space is geodesic via coordinatewise linear interpolation; the adversarial
hypothesis is that the *same* convex interpolation of the weights,
`lerp F G t := (1−t)·F.weight + t·G.weight`, is (a) a valid filtration for
`t ∈ [0,1]` and (b) a constant-speed geodesic — the interleaving distance is
*exactly* linear, not merely subadditive, along it.

## Result
Confirmed.  `lerp` is a `Filtration` (convexity preserves `weight_empty` and
`weight_mono`), runs from `F` (`lerp_zero`) to `G` (`lerp_one`), and obeys the exact
law `eInterleavingDist (lerp s) (lerp t) = ofReal |s − t| · eInterleavingDist F G`
(`eInterleavingDist_lerp`).  Endpoint distance (`eInterleavingDist_lerp_left`) and
additive midpoint bisection (`eInterleavingDist_midpoint`) follow.  The space is
therefore geodesic, with `lerp` an explicit constant-speed geodesic.

## Insight
Geodesy is *inherited through the isometry*: the only nontrivial step is the
per-simplex factorisation `weight_lerp_sub` (`|lerp s − lerp t| = |s − t|·|F − G|`),
after which the supremum-distance scales by the scalar `ofReal |s − t|` via
`ENNReal.mul_iSup` — a constant pulls straight out of a `⨆`.  The metric content of
the geodesic is thus a *single scalar factor* applied uniformly to every coordinate,
which is exactly why the speed is constant: every simplex travels its own straight
line at a rate proportional to its endpoint gap, and the sup of constant-rate motions
is constant-rate.

## Failure analysis
`lerp` requires the convexity hypotheses `0 ≤ t ≤ 1` *intrinsically* — outside
`[0,1]` the combination can violate `weight_empty` (a positive coefficient on a
negative endpoint flips sign), so the geodesic is a genuine *segment*, not a line.
Uniqueness fails: because `eInterleavingDist` is a `⨆` over simplices, the slack in
non-maximising simplices is free to wander, so `lerp` is one geodesic among a convex
family (deferred — see FUTURE_DIRECTIONS, Direction 2).  Realising the geodesic
*inside* the Vietoris–Rips locus (does `lerp` of two diameter-filtrations remain a
diameter-filtration?) is the geometric-vs-combinatorial frontier (Direction 3).
-/

end BoltzmannBridge