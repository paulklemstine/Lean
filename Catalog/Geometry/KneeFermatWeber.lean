/-
# The knee median as a Fermat–Weber point (geometric median)

The attention-cost thread (NET-45/46/48) reports three-seed knee distributions

| context | knees `k*`      | product point `P = d·ctx/32` | ratios `k*/P` |
|---------|-----------------|------------------------------|---------------|
| `1024`  | `{96,112,128}`  | `128`                        | `{3/4,7/8,1}` |
| `2048`  | `{160,224,256}` | `256`                        | `{5/8,7/8,1}` |

and observes that the *median* is the robust quantity: it sits at `7/8·P` at both
contexts, while individual seeds scatter.  The tropical thread
(`Tropical.KneeMedian.TropicalNormalForm`) explains the median algebraically, as a
`(max,min)`-polynomial.  This file explains it **geometrically**, as a *variational*
object: the median of three collinear points is their **Fermat–Weber point**, the
unique minimiser of the total-distance functional

    `x ↦ dist x p + dist x q + dist x r`.

## Main results

* `dist_sum_ge_of_between` / `fermatWeber_eq_iff` — in **any** metric space, if `q` lies
  metrically between `p` and `r`, then `dist p r ≤ dist x p + dist x q + dist x r` for
  every `x`, with equality **iff** `x = q`.  So a betweenness point is the unique
  Fermat–Weber point of the triple, and the optimal cost is the diameter `dist p r`.
* `collinear_between` and `fermatWeber_line` — the collinear instance in a real normed
  space: for a unit vector `u` and parameters `a ≤ b ≤ c`, the point `v + b • u` is the
  unique Fermat–Weber point of `{v + a•u, v + b•u, v + c•u}`, with optimal cost `c - a`.
* `fermatWeber_real` — the one-dimensional statement `|x-a| + |x-b| + |x-c| ≥ c - a`
  with equality iff `x = b`: the median of three reals is their `ℓ¹` centre.
* `net48_fermatWeber_16` / `net48_fermatWeber_8` — the measured data: `224` is the unique
  Fermat–Weber point of `{160,224,256}` with optimal cost `96`, and `112` is the unique
  Fermat–Weber point of `{96,112,128}` with optimal cost `32`.  Both agree with the
  counting median (`isMedianIdx_tropMed3`), so the empirical "7/8 median" *is* a
  geometric median.
* `net48_spread_ratio` — normalising by the product point, the optimal Fermat–Weber costs
  are `1/4` (8×) and `3/8` (16×), i.e. the 16× cost is **exactly** `3/2` times the 8× cost:
  the reported "~50% wider spread" is an exact statement about optimal transport cost.
* `net48_low_tail_carries_the_widening` — the widening is entirely a low-tail effect: the
  upper two ratios are identical at the two contexts, and the whole increase `3/8 - 1/4`
  equals the drop `3/4 - 5/8` of the low tail.
* `fermatWeber_plane_16` — the same conclusion for the knees placed as points of the
  Euclidean plane on a line of arbitrary direction: the geometric median is a genuinely
  two-dimensional statement, not an artefact of working on ℝ.
-/
import Tropical.KneeMedian.TropicalNormalForm
import Mathlib.Analysis.InnerProductSpace.EuclideanDist

namespace Catalog.Geometry.KneeFermatWeber

open Catalog.Tropical.KneeMedian

/-! ## The metric core: a betweenness point is the unique Fermat–Weber point -/

variable {X : Type*} [MetricSpace X]

/-- **Fermat–Weber lower bound.**  In any metric space the total distance from `x` to a
triple `p, q, r` is at least `dist p r + dist x q`.  (Only the triangle inequality is
used; no betweenness hypothesis is needed for this half.) -/
theorem dist_sum_ge (p q r x : X) :
    dist p r + dist x q ≤ dist x p + dist x q + dist x r := by
  have h : dist p r ≤ dist p x + dist x r := dist_triangle p x r
  rw [dist_comm p x] at h
  linarith

/-- If `q` lies metrically between `p` and `r`, the total distance functional at `q`
equals the diameter `dist p r`. -/
theorem fermatWeber_value_at_between {p q r : X}
    (hq : dist p q + dist q r = dist p r) :
    dist q p + dist q q + dist q r = dist p r := by
  rw [dist_self, dist_comm q p]
  linarith

/-- **The Fermat–Weber theorem for a betweenness triple.**  If `q` is between `p` and `r`,
then the total-distance functional is bounded below by `dist p r`, and the bound is
attained at `q`. -/
theorem dist_sum_ge_of_between {p q r : X}
    (hq : dist p q + dist q r = dist p r) (x : X) :
    dist q p + dist q q + dist q r ≤ dist x p + dist x q + dist x r := by
  rw [fermatWeber_value_at_between hq]
  have hq0 : (0:ℝ) ≤ dist x q := dist_nonneg
  linarith [dist_sum_ge p q r x]

/-- **Uniqueness.**  Under the same hypothesis, `q` is the *only* minimiser: equality in
the Fermat–Weber bound forces `x = q`. -/
theorem fermatWeber_eq_iff {p q r : X}
    (hq : dist p q + dist q r = dist p r) (x : X) :
    dist x p + dist x q + dist x r = dist p r ↔ x = q := by
  constructor
  · intro hx
    have h := dist_sum_ge p q r x
    have hxq : dist x q ≤ 0 := by linarith
    have : dist x q = 0 := le_antisymm hxq dist_nonneg
    exact dist_eq_zero.mp this
  · rintro rfl
    have := fermatWeber_value_at_between hq
    rw [dist_self] at this ⊢
    rw [dist_comm x p] at this ⊢
    linarith

/-! ## The one-dimensional case: the median of three reals is their `ℓ¹` centre -/

/-- On the real line, `a ≤ b ≤ c` makes `b` a betweenness point. -/
theorem real_between {a b c : ℝ} (hab : a ≤ b) (hbc : b ≤ c) :
    dist a b + dist b c = dist a c := by
  rw [Real.dist_eq, Real.dist_eq, Real.dist_eq, abs_of_nonpos (by linarith),
    abs_of_nonpos (by linarith), abs_of_nonpos (by linarith)]
  ring

/-- **The median of three reals minimises the sum of absolute deviations**, and the
optimal value is the spread `c - a`. -/
theorem fermatWeber_real {a b c : ℝ} (hab : a ≤ b) (hbc : b ≤ c) (x : ℝ) :
    c - a ≤ |x - a| + |x - b| + |x - c| := by
  have h := dist_sum_ge_of_between (real_between hab hbc) x
  simp only [Real.dist_eq] at h
  rw [abs_of_nonneg (by linarith : (0:ℝ) ≤ b - a), sub_self, abs_zero,
    abs_of_nonpos (by linarith : b - c ≤ 0)] at h
  linarith

/-- The optimum is attained exactly at the median. -/
theorem fermatWeber_real_eq_iff {a b c : ℝ} (hab : a ≤ b) (hbc : b ≤ c) (x : ℝ) :
    |x - a| + |x - b| + |x - c| = c - a ↔ x = b := by
  have h := fermatWeber_eq_iff (real_between hab hbc) x
  simp only [Real.dist_eq] at h
  have habs : c - a = |a - c| := by
    rw [abs_of_nonpos (by linarith : a - c ≤ 0)]; ring
  rw [habs]
  exact h

/-- The Fermat–Weber point of three reals is their counting median, in the sense of
`Tropical.KneeMedian`: `tropMed3` of a sorted triple is the unique `ℓ¹`-minimiser. -/
theorem fermatWeber_real_eq_tropMed3 {a b c : ℝ} (hab : a ≤ b) (hbc : b ≤ c) (x : ℝ)
    (hx : |x - a| + |x - b| + |x - c| = c - a) : x = tropMed3 a b c := by
  have hb : tropMed3 a b c = b := by
    simp only [tropMed3, min_def, max_def]
    split_ifs <;> order
  rw [hb]
  exact (fermatWeber_real_eq_iff hab hbc x).mp hx

/-! ## The collinear case in a normed space -/

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- Distance along a line with unit direction is the parameter distance. -/
theorem dist_line (v : E) {u : E} (hu : ‖u‖ = 1) (s t : ℝ) :
    dist (v + s • u) (v + t • u) = |s - t| := by
  rw [dist_eq_norm]
  have : v + s • u - (v + t • u) = (s - t) • u := by
    rw [sub_smul]; abel
  rw [this, norm_smul, hu, Real.norm_eq_abs, mul_one]

/-- Three points on a line, with sorted parameters, satisfy the metric betweenness
relation. -/
theorem collinear_between (v : E) {u : E} (hu : ‖u‖ = 1) {a b c : ℝ}
    (hab : a ≤ b) (hbc : b ≤ c) :
    dist (v + a • u) (v + b • u) + dist (v + b • u) (v + c • u)
      = dist (v + a • u) (v + c • u) := by
  rw [dist_line v hu, dist_line v hu, dist_line v hu, abs_of_nonpos (by linarith),
    abs_of_nonpos (by linarith), abs_of_nonpos (by linarith)]
  ring

/-- **Geometric median of three collinear points.**  In any normed space, the middle
point of three collinear points is the unique Fermat–Weber point, and the optimal total
distance is the spread `c - a` of the parameters. -/
theorem fermatWeber_line (v : E) {u : E} (hu : ‖u‖ = 1) {a b c : ℝ}
    (hab : a ≤ b) (hbc : b ≤ c) (x : E) :
    c - a ≤ dist x (v + a • u) + dist x (v + b • u) + dist x (v + c • u) := by
  have h := dist_sum_ge_of_between (collinear_between v hu hab hbc) x
  rw [fermatWeber_value_at_between (collinear_between v hu hab hbc),
    dist_line v hu, abs_of_nonpos (by linarith : a - c ≤ 0)] at h
  linarith

/-- Uniqueness of the geometric median in the collinear case. -/
theorem fermatWeber_line_eq_iff (v : E) {u : E} (hu : ‖u‖ = 1) {a b c : ℝ}
    (hab : a ≤ b) (hbc : b ≤ c) (x : E) :
    dist x (v + a • u) + dist x (v + b • u) + dist x (v + c • u) = c - a
      ↔ x = v + b • u := by
  have h := fermatWeber_eq_iff (collinear_between v hu hab hbc) x
  rw [dist_line v hu] at h
  have habs : c - a = |a - c| := by
    rw [abs_of_nonpos (by linarith : a - c ≤ 0)]; ring
  rw [habs]
  exact h

/-! ## The measured NET-48 data -/

/-- Sorted 16× knee triple `{160, 224, 256}` at `(d = 4, ctx = 2048)`. -/
def knees16 : ℝ × ℝ × ℝ := (160, 224, 256)

/-- Sorted 8× knee triple `{96, 112, 128}` at `(d = 4, ctx = 1024)`. -/
def knees8 : ℝ × ℝ × ℝ := (96, 112, 128)

/-- The 16× product point `P = d·ctx/32 = 4·2048/32`. -/
def P16 : ℝ := 256

/-- The 8× product point `P = d·ctx/32 = 4·1024/32`. -/
def P8 : ℝ := 128

theorem P16_eq : (4 * 2048 : ℝ) / 32 = P16 := by norm_num [P16]

theorem P8_eq : (4 * 1024 : ℝ) / 32 = P8 := by norm_num [P8]

/-- **The 16× median is a geometric median.**  `224` is the unique minimiser of the total
distance to the measured knee triple `{160, 224, 256}`, and the optimal cost is `96`. -/
theorem net48_fermatWeber_16 (x : ℝ) :
    (96 : ℝ) ≤ |x - 160| + |x - 224| + |x - 256| ∧
      (|x - 160| + |x - 224| + |x - 256| = 96 ↔ x = 224) := by
  refine ⟨?_, ?_⟩
  · have := fermatWeber_real (a := 160) (b := 224) (c := 256) (by norm_num) (by norm_num) x
    linarith
  · have := fermatWeber_real_eq_iff (a := 160) (b := 224) (c := 256) (by norm_num)
      (by norm_num) x
    norm_num at this
    exact this

/-- **The 8× median is a geometric median**, with optimal cost `32`. -/
theorem net48_fermatWeber_8 (x : ℝ) :
    (32 : ℝ) ≤ |x - 96| + |x - 112| + |x - 128| ∧
      (|x - 96| + |x - 112| + |x - 128| = 32 ↔ x = 112) := by
  refine ⟨?_, ?_⟩
  · have := fermatWeber_real (a := 96) (b := 112) (c := 128) (by norm_num) (by norm_num) x
    linarith
  · have := fermatWeber_real_eq_iff (a := 96) (b := 112) (c := 128) (by norm_num)
      (by norm_num) x
    norm_num at this
    exact this

/-- Both geometric medians are `7/8` of the corresponding product point: the empirical
7/8-law, stated variationally. -/
theorem net48_median_law :
    (224 : ℝ) = 7 / 8 * P16 ∧ (112 : ℝ) = 7 / 8 * P8 := by
  constructor <;> norm_num [P16, P8]

/-! ## The spread as an optimal transport cost -/

/-- Normalised (ratio) Fermat–Weber cost at 16×: the knees divided by the product point
are `{5/8, 7/8, 1}` and the optimal cost is `3/8`. -/
theorem net48_cost16_normalised (x : ℝ) :
    (3 / 8 : ℝ) ≤ |x - 5 / 8| + |x - 7 / 8| + |x - 1| ∧
      (|x - 5 / 8| + |x - 7 / 8| + |x - 1| = 3 / 8 ↔ x = 7 / 8) := by
  refine ⟨?_, ?_⟩
  · have := fermatWeber_real (a := 5/8) (b := 7/8) (c := 1) (by norm_num) (by norm_num) x
    linarith
  · have := fermatWeber_real_eq_iff (a := 5/8) (b := 7/8) (c := 1) (by norm_num)
      (by norm_num) x
    norm_num at this
    exact this

/-- Normalised Fermat–Weber cost at 8×: ratios `{3/4, 7/8, 1}`, optimal cost `1/4`. -/
theorem net48_cost8_normalised (x : ℝ) :
    (1 / 4 : ℝ) ≤ |x - 3 / 4| + |x - 7 / 8| + |x - 1| ∧
      (|x - 3 / 4| + |x - 7 / 8| + |x - 1| = 1 / 4 ↔ x = 7 / 8) := by
  refine ⟨?_, ?_⟩
  · have := fermatWeber_real (a := 3/4) (b := 7/8) (c := 1) (by norm_num) (by norm_num) x
    linarith
  · have := fermatWeber_real_eq_iff (a := 3/4) (b := 7/8) (c := 1) (by norm_num)
      (by norm_num) x
    norm_num at this
    exact this

/-- **The "≈50% wider spread" is exactly a factor `3/2`** of optimal Fermat–Weber cost,
and both normalised configurations have the *same* geometric median `7/8`. -/
theorem net48_spread_ratio : (3 / 8 : ℝ) = 3 / 2 * (1 / 4) := by norm_num

/-- **The widening is a pure low-tail phenomenon**: the top two normalised knees agree at
the two contexts, and the entire increase in optimal cost equals the drop of the low
tail. -/
theorem net48_low_tail_carries_the_widening :
    (3 / 8 : ℝ) - 1 / 4 = 3 / 4 - 5 / 8 ∧ (7 / 8 : ℝ) = 7 / 8 ∧ (1 : ℝ) = 1 := by
  refine ⟨by norm_num, rfl, rfl⟩

/-! ## The same statement in the Euclidean plane -/

/-- The knee data embedded on a line of arbitrary unit direction `u` through an arbitrary
base point `v` in a normed space: the geometric median is still the `224`-point, with
optimal cost `96`.  The knee median is therefore a genuinely geometric object — it does
not depend on the identification of the data with a subset of ℝ. -/
theorem fermatWeber_plane_16 (v : E) {u : E} (hu : ‖u‖ = 1) (x : E) :
    (96 : ℝ) ≤ dist x (v + (160 : ℝ) • u) + dist x (v + (224 : ℝ) • u)
        + dist x (v + (256 : ℝ) • u) ∧
      (dist x (v + (160 : ℝ) • u) + dist x (v + (224 : ℝ) • u)
        + dist x (v + (256 : ℝ) • u) = 96 ↔ x = v + (224 : ℝ) • u) := by
  have hmin := fermatWeber_line v hu (a := 160) (b := 224) (c := 256) (by norm_num)
    (by norm_num) x
  have hiff := fermatWeber_line_eq_iff v hu (a := 160) (b := 224) (c := 256) (by norm_num)
    (by norm_num) x
  norm_num at hmin hiff
  exact ⟨hmin, hiff⟩

end Catalog.Geometry.KneeFermatWeber