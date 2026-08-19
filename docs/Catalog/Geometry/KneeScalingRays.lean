/-
# Scaling geometry of the knee data: rays, dilations and the median level set

The NET-45/46/48 rounds give, at two context lengths, three-seed knee distributions

| context | low seed | median seed | top seed | product point `P = d·ctx/32` |
|---------|----------|-------------|----------|------------------------------|
| `1024`  | `96`     | `112`       | `128`    | `128`                        |
| `2048`  | `160`    | `224`       | `256`    | `256`                        |

Plotting each measurement as the point `(ctx, k*)` of the plane turns the verbal summary
("the product point is the pinned upper edge, the median is stable at `7/8`, the low tail is
the context-growing quantity") into three checkable geometric statements about **rays through
the origin** and the **dilation `x ↦ 2x`**:

* the two *top* points lie on one ray through the origin, of slope `1/8` (`top_on_ray`);
* the two *median* points lie on one ray through the origin, of slope `7/64 = (7/8)·(1/8)`
  (`median_on_ray`), and `7/64` is the only possible slope (`median_slope_unique`);
* the two *low-tail* points lie on **no** common ray: the triangle they span with the origin
  has area exactly `16384` (`low_tail_not_on_ray`, `low_tail_triangle_area`).

Equivalently, doubling the context is a dilation of the plane; it carries the 8× top and
median points onto the 16× ones (`dilation_top`, `dilation_median`) but *not* the low-tail
point, and the deficit is exactly `32 = P16/8` (`dilation_low_tail_defect`).

The second half of the file looks at the normalised (ratio) triples as points of `ℝ³` and
locates them inside the level set of the median map:

* `median_levelSet_edge` — the entire half-line `{(t, 7/8, 1) : t ≤ 7/8}` lies in the level
  set `median = 7/8`; both measured ratio triples lie on it, so the segment joining them does
  too (`ratio_segment_in_levelSet`);
* `median_levelSet_not_convex` — the level set itself is *not* convex, so the previous item is
  a genuine (non-automatic) statement: the two contexts lie in a common flat face of a
  non-convex polyhedral set;
* `median_levelSet_exit` — the half-line is maximal: as soon as the low coordinate exceeds
  `7/8` the median moves.
-/
import Tropical.KneeMedian.TropicalNormalForm

namespace Catalog.Geometry.KneeScalingRays

open Catalog.Tropical.KneeMedian

/-! ## Plane geometry: the measurement points -/

/-- Twice the signed area of the triangle `O, p, q`: the `2 × 2` determinant. -/
def cross (p q : ℝ × ℝ) : ℝ := p.1 * q.2 - p.2 * q.1

/-- `p` and `q` span a ray through the origin exactly when the determinant vanishes and
neither is the origin.  For plotted data (positive coordinates) this is the statement that
the two measurements obey a common proportional law. -/
def OnCommonRay (p q : ℝ × ℝ) : Prop := cross p q = 0

/-- The determinant vanishes iff the second point is a multiple of the first, provided the
first has nonzero abscissa: the algebraic form of "lies on the ray". -/
theorem onCommonRay_iff {p q : ℝ × ℝ} (hp : p.1 ≠ 0) :
    OnCommonRay p q ↔ q = (q.1 / p.1) • p := by
  constructor
  · intro h
    have h' : p.1 * q.2 = p.2 * q.1 := by
      have := h
      simp only [OnCommonRay, cross, sub_eq_zero] at this
      exact this
    have h1 : (q.1 / p.1) * p.1 = q.1 := by field_simp
    have h2 : (q.1 / p.1) * p.2 = q.2 := by
      field_simp
      linarith [h']
    exact Prod.ext (by simpa using h1.symm) (by simpa using h2.symm)
  · intro hq
    simp only [OnCommonRay, cross]
    rw [show q.1 = ((q.1 / p.1) • p).1 from congrArg Prod.fst hq,
      show q.2 = ((q.1 / p.1) • p).2 from congrArg Prod.snd hq]
    simp only [Prod.smul_fst, Prod.smul_snd, smul_eq_mul]
    ring

/-- The 8× top point `(ctx, k*) = (1024, 128)` (the product point at `ctx = 1024`). -/
def top8 : ℝ × ℝ := (1024, 128)

/-- The 16× top point `(2048, 256)` (the product point at `ctx = 2048`). -/
def top16 : ℝ × ℝ := (2048, 256)

/-- The 8× median point `(1024, 112)`. -/
def med8 : ℝ × ℝ := (1024, 112)

/-- The 16× median point `(2048, 224)`. -/
def med16 : ℝ × ℝ := (2048, 224)

/-- The 8× low-tail point `(1024, 96)`. -/
def low8 : ℝ × ℝ := (1024, 96)

/-- The 16× low-tail point `(2048, 160)`. -/
def low16 : ℝ × ℝ := (2048, 160)

/-! ## Rays: the upper edge and the median are proportional laws, the low tail is not -/

/-- **The product law is a ray**: the two top points are proportional, with slope `1/8`. -/
theorem top_on_ray : OnCommonRay top8 top16 := by
  simp [OnCommonRay, cross, top8, top16]; ring

theorem top_slope : top8.2 / top8.1 = 1 / 8 ∧ top16.2 / top16.1 = 1 / 8 := by
  constructor <;> norm_num [top8, top16]

/-- **The 7/8-median law is a ray**: the two median points are proportional, with slope
`7/64 = (7/8) · (1/8)` — the product-law slope scaled by the median constant. -/
theorem median_on_ray : OnCommonRay med8 med16 := by
  simp [OnCommonRay, cross, med8, med16]; ring

theorem median_slope : med8.2 / med8.1 = 7 / 64 ∧ med16.2 / med16.1 = 7 / 64 := by
  constructor <;> norm_num [med8, med16]

/-- The median slope is `7/8` of the product-law slope: the geometric form of
`median = (7/8) · d·ctx/32`. -/
theorem median_slope_is_seven_eighths_of_top : (7 : ℝ) / 64 = 7 / 8 * (1 / 8) := by norm_num

/-- **Uniqueness of the law constant, and its predictive content.**  A slope through the
origin fitting the 8× median measurement is forced to be `7/64 = (7/8)·(1/8)`; and that
slope then fits the 16× median measurement as well.  The 7/8-law is therefore not fitted
twice — one context fixes it and the other confirms it. -/
theorem median_slope_unique {s : ℝ} (h8 : med8.2 = s * med8.1) :
    s = 7 / 64 ∧ s = (7 / 8) * (1 / 8) ∧ med16.2 = s * med16.1 := by
  simp only [med8] at h8
  have hs : s = 7 / 64 := by linarith
  refine ⟨hs, by rw [hs]; norm_num, ?_⟩
  simp only [med16, hs]
  norm_num

/-- **The low tail is not a ray.**  The determinant of the two low-tail points is `-32768 ≠ 0`,
so no proportional law fits them: the low tail genuinely grows with context, relative to the
product point. -/
theorem low_tail_not_on_ray : ¬ OnCommonRay low8 low16 := by
  simp only [OnCommonRay, cross, low8, low16]
  norm_num

/-- The obstruction is quantitative: the triangle `O, low8, low16` has area `8192`
(determinant `-32768`). -/
theorem low_tail_triangle_area : cross low8 low16 = -32768 ∧ |cross low8 low16| / 2 = 16384 := by
  constructor
  · norm_num [cross, low8, low16]
  · rw [show cross low8 low16 = -32768 by norm_num [cross, low8, low16]]
    rw [abs_of_nonpos (by norm_num)]
    norm_num

/-- For comparison, the corresponding triangles for the top and median points are degenerate. -/
theorem top_median_triangles_degenerate : cross top8 top16 = 0 ∧ cross med8 med16 = 0 :=
  ⟨by norm_num [cross, top8, top16], by norm_num [cross, med8, med16]⟩

/-! ## Doubling the context is a dilation -/

/-- Doubling the context carries the 8× top point to the 16× top point. -/
theorem dilation_top : (2 : ℝ) • top8 = top16 := by
  simp only [top8, top16, Prod.smul_mk, smul_eq_mul]
  norm_num

/-- Doubling the context carries the 8× median point to the 16× median point: the 7/8-law is
*equivariant* under context doubling. -/
theorem dilation_median : (2 : ℝ) • med8 = med16 := by
  simp only [med8, med16, Prod.smul_mk, smul_eq_mul]
  norm_num

/-- The low tail is **not** equivariant: the dilated 8× low tail is `192`, the measured 16×
low tail is `160`, a deficit of exactly `32 = P16 / 8`. -/
theorem dilation_low_tail_defect :
    ((2 : ℝ) • low8).2 = 192 ∧ low16.2 = 160 ∧ ((2 : ℝ) • low8).2 - low16.2 = 32 ∧
      (32 : ℝ) = 256 / 8 := by
  refine ⟨by norm_num [low8], by norm_num [low16], by norm_num [low8, low16], by norm_num⟩

/-- Consequently no dilation at all can match the whole 8× configuration to the 16× one: the
knee *distribution* is not self-similar, even though its median and its upper edge are. -/
theorem no_dilation_matches_all (t : ℝ) :
    ¬ (t • top8 = top16 ∧ t • med8 = med16 ∧ t • low8 = low16) := by
  rintro ⟨ht, -, hl⟩
  have h1 : t * 128 = 256 := by
    have := congrArg Prod.snd ht
    simpa [top8, top16] using this
  have h2 : t * 96 = 160 := by
    have := congrArg Prod.snd hl
    simpa [low8, low16] using this
  have : t = 2 := by linarith
  rw [this] at h2
  norm_num at h2

/-! ## The normalised triples inside the median level set of `ℝ³` -/

/-- The normalised 8× ratio triple `(low, median, top) = (3/4, 7/8, 1)`. -/
noncomputable def r8 : ℝ × ℝ × ℝ := (3 / 4, 7 / 8, 1)

/-- The normalised 16× ratio triple `(5/8, 7/8, 1)`. -/
noncomputable def r16 : ℝ × ℝ × ℝ := (5 / 8, 7 / 8, 1)

/-- The median of a triple of reals, as a function on `ℝ³`. -/
noncomputable def med (v : ℝ × ℝ × ℝ) : ℝ := tropMed3 v.1 v.2.1 v.2.2

theorem med_r8 : med r8 = 7 / 8 := by
  simp only [med, r8, tropMed3, min_def, max_def]
  norm_num

theorem med_r16 : med r16 = 7 / 8 := by
  simp only [med, r16, tropMed3, min_def, max_def]
  norm_num

/-- **A whole edge of the level set.**  Every triple `(t, 7/8, 1)` with `t ≤ 7/8` has median
`7/8`: the low coordinate is invisible to the centre as long as it stays below it. -/
theorem median_levelSet_edge {t : ℝ} (ht : t ≤ 7 / 8) : med (t, 7 / 8, 1) = 7 / 8 := by
  simp only [med, tropMed3, min_def, max_def]
  norm_num
  split_ifs <;> linarith

/-- **Maximality of the edge.**  As soon as the low coordinate rises above `7/8` (and stays
below the pinned top `1`), the median moves with it: the edge cannot be extended. -/
theorem median_levelSet_exit {t : ℝ} (ht : 7 / 8 < t) (ht1 : t ≤ 1) :
    med (t, 7 / 8, 1) = t := by
  simp only [med, tropMed3, min_def, max_def]
  norm_num
  split_ifs <;> linarith

/-- Both measured ratio triples lie on that edge, hence so does the whole segment joining
them: the two contexts occupy a common **flat face** of the median level set.  The proof
needs only `s ≤ 1`, so the face in fact extends past the segment, beyond the 16× endpoint:
the low tail may keep growing without moving the centre. -/
theorem ratio_segment_in_levelSet {s : ℝ} (hs1 : s ≤ 1) :
    med (s • r8 + (1 - s) • r16) = 7 / 8 := by
  have hcoord : s • r8 + (1 - s) • r16 = (s * (3 / 4) + (1 - s) * (5 / 8), 7 / 8, 1) := by
    have h2 : s * (7 / 8) + (1 - s) * (7 / 8) = 7 / 8 := by ring
    have h3 : s * 1 + (1 - s) * 1 = (1 : ℝ) := by ring
    simp only [r8, r16, Prod.smul_mk, Prod.mk_add_mk, smul_eq_mul, h2, h3]
  rw [hcoord]
  refine median_levelSet_edge ?_
  nlinarith

/-- **The level set is not convex.**  The triples `(5/8, 7/8, 1)` and `(7/8, 1, 5/8)` both have
median `7/8`, but their midpoint has median `13/16`.  So the fact that the two measured
contexts lie in a *common convex face* is a real structural statement about the data, not a
formal consequence of both having median `7/8`. -/
theorem median_levelSet_not_convex :
    med (5 / 8, 7 / 8, 1) = 7 / 8 ∧ med (7 / 8, 1, 5 / 8) = 7 / 8 ∧
      med ((1 / 2 : ℝ) • ((5 / 8, 7 / 8, 1) + (7 / 8, 1, 5 / 8)) : ℝ × ℝ × ℝ) = 13 / 16 ∧
      (13 / 16 : ℝ) ≠ 7 / 8 := by
  refine ⟨?_, ?_, ?_, by norm_num⟩
  · simp only [med, tropMed3, min_def, max_def]; norm_num
  · simp only [med, tropMed3, min_def, max_def]; norm_num
  · have hc : ((1 / 2 : ℝ) • ((5 / 8, 7 / 8, 1) + (7 / 8, 1, 5 / 8)) : ℝ × ℝ × ℝ)
        = (3 / 4, 15 / 16, 13 / 16) := by
      simp only [Prod.mk_add_mk, Prod.smul_mk, smul_eq_mul]
      norm_num
    rw [hc]
    simp only [med, tropMed3, min_def, max_def]
    norm_num

end Catalog.Geometry.KneeScalingRays