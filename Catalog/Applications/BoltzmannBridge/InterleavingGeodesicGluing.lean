/-
# The Boltzmann Bridge X — Local-to-Global Gluing of Interleaving Geodesics

Bridge IX (`Applications.BoltzmannBridge.InterleavingGeodesic`) turned the
persistence-stability metric into a *geodesic* one: the convex-interpolation path
`lerp F G t := σ ↦ (1−t)·F.weight σ + t·G.weight σ` runs from `F` (`lerp_zero`) to
`G` (`lerp_one`), and the interleaving distance varies *exactly linearly* along it
(`eInterleavingDist_lerp`).

Bridge X promotes this single geodesic to a **self-coherent field of geodesics**.
The keystone is the affine **gluing law**

> `lerp (lerp F G s) (lerp F G t) r = lerp F G ((1−r)·s + r·t)`  (`lerp_lerp`),

which says the geodesic between two points *on* a geodesic is the **same**
geodesic, merely reparametrised — the defining local-to-global coherence (sheaf-like
restriction) condition of a geodesic structure.  Every metric corollary then falls
out by linearity of `ENNReal.ofReal` on nonnegative parameter gaps:

* distance to the far endpoint (`eInterleavingDist_lerp_right`),
* exact additive *betweenness* for ordered parameters
  (`eInterleavingDist_lerp_betweenness`),
* the universal additive split at every interior point
  (`eInterleavingDist_lerp_bisect`, generalising the `t = ½` midpoint bisection
  `eInterleavingDist_midpoint` of Bridge IX to the full continuum),
* multiplicativity of speed under nesting (`eInterleavingDist_lerp_lerp`).

All are proved `sorry`-free over an arbitrary index type `α`, building on the
Bridge VIII isometry `eInterleavingDist_eq_weightSupEDist` (via Bridge IX's
`eInterleavingDist_lerp`).

## Main results

* `lerp_lerp` — affine self-similarity / gluing of the geodesic.
* `eInterleavingDist_lerp_right` — `d(lerp F G t, G) = ofReal (1−t) · d(F,G)`.
* `eInterleavingDist_lerp_betweenness` — `d(s,u) + d(u,t) = d(s,t)` for `s ≤ u ≤ t`.
* `eInterleavingDist_lerp_bisect` — `d(F, lerp t) + d(lerp t, G) = d(F,G)` for all `t`.
* `eInterleavingDist_lerp_lerp` — nested speed multiplies.
-/
import Mathlib
import Applications.BoltzmannBridge.HigherPersistence
import Applications.BoltzmannBridge.PersistenceStability
import Applications.BoltzmannBridge.BottleneckStability
import Applications.BoltzmannBridge.InterleavingMetric
import Applications.BoltzmannBridge.InterleavingClosure
import Applications.BoltzmannBridge.InterleavingIsometry
import Applications.BoltzmannBridge.InterleavingGeodesic

open Finset BigOperators
open scoped ENNReal

namespace BoltzmannBridge

namespace Filtration

variable {α : Type*}

/-! ## The affine gluing law -/

-- !-- The new parameter `u := (1−r)·s + r·t` is a convex combination of `s,t`, so
-- !-- `u ∈ [0,1]` (`nlinarith` on products of the nonnegative gaps).  Pointwise the
-- !-- coefficient of `G` is `(1−r)s + r t = u` and of `F` is `(1−r)(1−s) + r(1−t) =
-- !-- 1 − u`, so `ext_weight` + `ring` finishes. -- !--
/-- **The affine gluing law.**  The geodesic between two points `lerp F G s` and
`lerp F G t` *on* the geodesic `lerp F G` is the **same** geodesic, reparametrised:
`lerp (lerp F G s) (lerp F G t) r = lerp F G ((1−r)·s + r·t)`.  This is the
local-to-global coherence (restriction) axiom of the geodesic structure. -/
theorem lerp_lerp (F G : Filtration α) {r s t : ℝ}
    (hr0 : 0 ≤ r) (hr1 : r ≤ 1) (hs0 : 0 ≤ s) (hs1 : s ≤ 1)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    lerp (lerp F G s hs0 hs1) (lerp F G t ht0 ht1) r hr0 hr1
      = lerp F G ((1 - r) * s + r * t)
          (by nlinarith [mul_nonneg (by linarith : (0:ℝ) ≤ 1 - r) hs0,
                mul_nonneg hr0 ht0])
          (by nlinarith [mul_nonneg (by linarith : (0:ℝ) ≤ 1 - r)
                (by linarith : (0:ℝ) ≤ 1 - s),
                mul_nonneg hr0 (by linarith : (0:ℝ) ≤ 1 - t)]) := by
  apply ext_weight
  funext σ
  simp only [lerp_weight]
  ring

/-! ## Metric corollaries of the gluing law -/

-- !-- `G = lerp F G 1` (`lerp_one`), so the distance is `d(lerp t, lerp 1) =
-- !-- ofReal |t − 1| · d` (`eInterleavingDist_lerp`); `|t − 1| = 1 − t` since `t ≤ 1`. -- !--
/-- **Distance to the far endpoint.**  The interleaving distance from `lerp F G t`
to the endpoint `G` is `ofReal (1 − t) · d(F, G)` — the mirror of Bridge IX's
`eInterleavingDist_lerp_left`. -/
theorem eInterleavingDist_lerp_right (F G : Filtration α) {t : ℝ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    eInterleavingDist (lerp F G t ht0 ht1) G
      = ENNReal.ofReal (1 - t) * eInterleavingDist F G := by
  have h : eInterleavingDist (lerp F G t ht0 ht1) G
      = eInterleavingDist (lerp F G t ht0 ht1) (lerp F G 1 zero_le_one le_rfl) := by
    rw [lerp_one]
  rw [h, eInterleavingDist_lerp]
  congr 2
  rw [abs_of_nonpos (by linarith : t - 1 ≤ 0)]
  ring

-- !-- Three applications of `eInterleavingDist_lerp` rewrite all distances to scalar
-- !-- multiples of `d(F,G)`; with `s ≤ u ≤ t` the absolute values collapse to
-- !-- `u − s`, `t − u`, `t − s`, and `ofReal` is additive on nonnegative gaps, so
-- !-- `(u−s) + (t−u) = (t−s)` closes it. -- !--
/-- **Exact additive betweenness.**  For ordered parameters `s ≤ u ≤ t` the interior
point `lerp F G u` lies metrically *between* `lerp F G s` and `lerp F G t`:
`d(lerp s, lerp u) + d(lerp u, lerp t) = d(lerp s, lerp t)`.  Betweenness is an
*equation*, not an inequality — the additive structure of `[0,1]` transported through
the isometry. -/
theorem eInterleavingDist_lerp_betweenness (F G : Filtration α) {s u t : ℝ}
    (hs0 : 0 ≤ s) (hs1 : s ≤ 1) (hu0 : 0 ≤ u) (hu1 : u ≤ 1)
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (hsu : s ≤ u) (hut : u ≤ t) :
    eInterleavingDist (lerp F G s hs0 hs1) (lerp F G u hu0 hu1)
        + eInterleavingDist (lerp F G u hu0 hu1) (lerp F G t ht0 ht1)
      = eInterleavingDist (lerp F G s hs0 hs1) (lerp F G t ht0 ht1) := by
  rw [eInterleavingDist_lerp, eInterleavingDist_lerp, eInterleavingDist_lerp]
  rw [show |s - u| = u - s by rw [abs_sub_comm]; exact abs_of_nonneg (by linarith),
      show |u - t| = t - u by rw [abs_sub_comm]; exact abs_of_nonneg (by linarith),
      show |s - t| = t - s by rw [abs_sub_comm]; exact abs_of_nonneg (by linarith),
      ← add_mul, ← ENNReal.ofReal_add (by linarith) (by linarith)]
  congr 2
  ring

-- !-- `d(F, lerp t) = ofReal t · d` (Bridge IX `eInterleavingDist_lerp_left`) and
-- !-- `d(lerp t, G) = ofReal (1−t) · d` (`eInterleavingDist_lerp_right`); sum the
-- !-- `ofReal` halves: `t + (1−t) = 1`, and `ofReal 1 · d = d`. -- !--
/-- **Universal additive split.**  *Every* interior point of the geodesic bisects the
distance additively: `d(F, lerp F G t) + d(lerp F G t, G) = d(F, G)` for all
`t ∈ [0,1]`.  This generalises Bridge IX's midpoint bisection
`eInterleavingDist_midpoint` (the `t = ½` case) to the entire continuum, the metric
witness that `lerp` is a constant-speed geodesic. -/
theorem eInterleavingDist_lerp_bisect (F G : Filtration α) {t : ℝ}
    (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    eInterleavingDist F (lerp F G t ht0 ht1)
        + eInterleavingDist (lerp F G t ht0 ht1) G
      = eInterleavingDist F G := by
  rw [eInterleavingDist_lerp_left, eInterleavingDist_lerp_right,
      ← add_mul, ← ENNReal.ofReal_add ht0 (by linarith)]
  rw [show t + (1 - t) = 1 by ring, ENNReal.ofReal_one, one_mul]

-- !-- Apply `eInterleavingDist_lerp` to the *outer* interpolation (parameters `a,b`),
-- !-- producing `ofReal |a−b| · d(lerp F G s, lerp F G t)`; a second
-- !-- `eInterleavingDist_lerp` rewrites the inner distance to `ofReal |s−t| · d(F,G)`. -- !--
/-- **Multiplicativity of speed under nesting.**  Reparametrising a geodesic inside a
geodesic multiplies the speed factors: the distance between two points of the inner
interpolation `lerp (lerp F G s) (lerp F G t)` is
`ofReal |a − b| · (ofReal |s − t| · d(F, G))`.  Equivalently (by `lerp_lerp`) the
nested geodesic is itself a `lerp F G` reparametrised at rate `|s − t|`. -/
theorem eInterleavingDist_lerp_lerp (F G : Filtration α) {a b s t : ℝ}
    (ha0 : 0 ≤ a) (ha1 : a ≤ 1) (hb0 : 0 ≤ b) (hb1 : b ≤ 1)
    (hs0 : 0 ≤ s) (hs1 : s ≤ 1) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    eInterleavingDist
        (lerp (lerp F G s hs0 hs1) (lerp F G t ht0 ht1) a ha0 ha1)
        (lerp (lerp F G s hs0 hs1) (lerp F G t ht0 ht1) b hb0 hb1)
      = ENNReal.ofReal |a - b|
          * (ENNReal.ofReal |s - t| * eInterleavingDist F G) := by
  rw [eInterleavingDist_lerp, eInterleavingDist_lerp]

end Filtration

/-
-- !-- Lab Notebook -- !--

## Hypothesis
Bridge IX produced a single constant-speed geodesic `lerp F G` and proved the
linear law `eInterleavingDist_lerp` and the `t = ½` midpoint bisection.  The
adversarial hypothesis: this is not an isolated path but a *self-coherent field*,
i.e. the geodesic restricts consistently to every subinterval — the geodesic
between two interior points of `lerp F G` is the *same* path reparametrised — and
all metric corollaries (far-endpoint distance, full-continuum betweenness, nested
speed) are forced by this single coherence law plus additivity of `ENNReal.ofReal`.

## Result
Confirmed.  The keystone `lerp_lerp` is an exact identity:
`lerp (lerp F G s) (lerp F G t) r = lerp F G ((1−r)s + r t)`, proved purely by
`ext_weight` + `ring` after recognising the `G`-coefficient `(1−r)s + r t` and the
`F`-coefficient `1 − ((1−r)s + r t)`.  Every metric corollary then reduces to
`eInterleavingDist_lerp`: `eInterleavingDist_lerp_right` (`ofReal (1−t)·d`),
`eInterleavingDist_lerp_betweenness` (`d(s,u)+d(u,t)=d(s,t)` as an *equation* for
`s ≤ u ≤ t`), `eInterleavingDist_lerp_bisect` (universal additive split,
generalising the midpoint), and `eInterleavingDist_lerp_lerp` (speed multiplies
under nesting).

## Insight
Geodesic coherence is *affine*, not metric: `lerp_lerp` lives entirely at the level
of weight functions (a `ring` identity in the two interpolation parameters), and the
metric is only consulted afterwards through the isometry of Bridge VIII.  Betweenness
becoming an *equality* (not the triangle *inequality*) is the signature of a flat,
sup-normed geometry: along the geodesic the supremum is attained coherently, so the
additive structure of the real interval `[0,1]` is transported verbatim into
`ℝ≥0∞` via `ENNReal.ofReal`'s additivity on nonnegative gaps.

## Failure analysis
The convexity hypotheses `0 ≤ ·, · ≤ 1` are intrinsic to *every* `lerp` invocation,
including the nested one in `lerp_lerp`: the new parameter `(1−r)s + r t` must be
shown to land in `[0,1]`, which is exactly a convexity (`nlinarith` on products of
nonnegative gaps) fact — outside `[0,1]` the gluing law has no `Filtration` to name.
Betweenness is *exact only for ordered* parameters; dropping `s ≤ u ≤ t` turns the
equation back into the triangle inequality (the absolute values no longer collapse
additively).  The cocycle-style equation `d(i,j)+d(j,k)=d(i,k)` proved here is the
local datum whose *global* gluing across an indexing poset is the open obstruction
question (see FUTURE_DIRECTIONS, Direction 5).
-/

end BoltzmannBridge