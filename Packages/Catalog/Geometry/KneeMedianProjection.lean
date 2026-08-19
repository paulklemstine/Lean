/-
# The knee median as a nearest-point projection onto a segment

`Tropical.KneeMedian.TropicalNormalForm` presents the median of three as the tropical
polynomial `tropMed3 a b c = (a ⊓ b) ⊔ (b ⊓ c) ⊔ (a ⊓ c)`.  This file gives the *convex
geometric* reading of the same object, with two already-measured seeds held fixed and the
third seed varying:

    `x ↦ tropMed3 a b x` is the **metric projection of ℝ onto the segment `[a ⊓ b, a ⊔ b]`**.

That single identification explains the qualitative behaviour reported for NET-48:

* the median never leaves the segment spanned by the two measured seeds
  (`tropMed3_mem_uIcc`), so no third seed can move it outside — and every point of the
  segment is attained (`median_range`);
* the set of third seeds giving a prescribed median *at an endpoint* is a closed half-line,
  the normal cone of the segment there (`clamp_eq_left_iff`, `clamp_eq_right_iff`);
* the projection is **firmly nonexpansive** (`proj_firmly_nonexpansive`), strictly stronger
  than the `1`-Lipschitz bound `tropMed3_nonexpansive` of the tropical file;
* the arithmetic mean has none of these properties (`mean_surjective`), which is the precise
  sense in which the centre, and not the average, is the robust statistic.

## Main results

* `tropMed3_eq_proj` — `tropMed3 a b x = max (a ⊓ b) (min (a ⊔ b) x)`, the clamp of `x` to
  the segment; `proj_eq_projIcc` identifies it with Mathlib's `Set.projIcc`.
* `proj_is_nearest`, `proj_unique_nearest` — the clamp is the *unique* nearest point of the
  segment to `x`, so the median is a genuine metric projection.
* `proj_monotone`, `proj_nonexpansive`, `proj_firmly_nonexpansive` — monotonicity, the
  `1`-Lipschitz bound, and the firm-nonexpansiveness inequality
  `(P x - P y)^2 ≤ (x - y) * (P x - P y)`.
* `clamp_eq_left_iff`, `clamp_eq_right_iff`, `clamp_eq_interior_iff` — the complete fibre
  description: endpoints have half-line fibres (normal cones), interior points singletons.
* `net48_stability_ray` — at 16× the fixed seeds are `256` and `224`, and the third-seed
  values keeping the median at `224` are **exactly** the ray `x ≤ 224`; the measured `160`
  is in it (`net48_third_seed_160`), and the informal claim "only `x ≥ 256` moves the
  centre" is refuted by `x = 240` (`net48_informal_claim_false`).
* `net48_projection_distance` — the measured third seed sits at distance exactly `64`
  from the segment `[224,256]`, and the projection absorbs the entire excursion.
* `net48_mean_moves`, `mean_surjective` — the mean of the 16× triple is `640/3 ≠ 224`, and
  as a function of the third seed the mean is surjective onto ℝ, while the median's range is
  the compact segment `[224,256]`.
-/
import Tropical.KneeMedian.TropicalNormalForm
import Mathlib.Order.Interval.Set.ProjIcc

namespace Catalog.Geometry.KneeMedianProjection

open Catalog.Tropical.KneeMedian

/-! ## The projection form of the median of three -/

variable {α : Type*} [LinearOrder α]

/-- The clamp of `x` to the segment spanned by `a` and `b`. -/
def clamp (a b x : α) : α := max (min a b) (min (max a b) x)

/-- **The median of three is a clamp.**  With two of its arguments held fixed, the median
of three is the order-theoretic projection of the third onto the segment they span. -/
theorem tropMed3_eq_proj (a b x : α) : tropMed3 a b x = clamp a b x := by
  simp only [tropMed3, clamp, min_def, max_def]
  split_ifs <;> order

/-- The clamp lands in the segment spanned by `a` and `b`. -/
theorem clamp_mem_uIcc (a b x : α) : clamp a b x ∈ Set.uIcc a b := by
  rw [show (Set.uIcc a b) = Set.Icc (min a b) (max a b) by simp [Set.uIcc]]
  exact ⟨le_max_left _ _, max_le min_le_max (min_le_left _ _)⟩

/-- The median of three, as a function of the third seed, never leaves the segment
determined by the first two. -/
theorem tropMed3_mem_uIcc (a b x : α) : tropMed3 a b x ∈ Set.uIcc a b := by
  rw [tropMed3_eq_proj]; exact clamp_mem_uIcc a b x

/-- The clamp is the identity on the segment: the projection is a retraction. -/
theorem clamp_of_mem {a b x : α} (hx : x ∈ Set.uIcc a b) : clamp a b x = x := by
  rw [show (Set.uIcc a b) = Set.Icc (min a b) (max a b) by simp [Set.uIcc]] at hx
  obtain ⟨h1, h2⟩ := hx
  rw [clamp, min_eq_right h2, max_eq_right h1]

/-- Below the segment the clamp is the left endpoint. -/
theorem clamp_of_le_left {a b x : α} (hab : a ≤ b) (hx : x ≤ a) : clamp a b x = a := by
  simp only [clamp, min_def, max_def]
  split_ifs <;> order

/-- Above the segment the clamp is the right endpoint. -/
theorem clamp_of_right_le {a b x : α} (hab : a ≤ b) (hx : b ≤ x) : clamp a b x = b := by
  simp only [clamp, min_def, max_def]
  split_ifs <;> order

/-- On a sorted pair the clamp is Mathlib's `Set.projIcc`. -/
theorem proj_eq_projIcc {a b : α} (hab : a ≤ b) (x : α) :
    clamp a b x = (Set.projIcc a b hab x : α) := by
  simp only [clamp, Set.projIcc, min_def, max_def]
  split_ifs <;> order

/-! ## Fibres of the projection: normal cones -/

/-- The fibre over the left endpoint is the closed half-line below it — the normal cone of
the segment at `a`. -/
theorem clamp_eq_left_iff {a b x : α} (hab : a < b) : clamp a b x = a ↔ x ≤ a := by
  constructor
  · intro h
    by_contra hx
    push_neg at hx
    rcases le_total x b with hxb | hxb
    · rw [clamp_of_mem (by rw [Set.uIcc_of_le hab.le]; exact ⟨hx.le, hxb⟩)] at h
      exact absurd h (ne_of_gt hx)
    · rw [clamp_of_right_le hab.le hxb] at h
      exact absurd h.symm (ne_of_lt hab)
  · intro hx
    exact clamp_of_le_left hab.le hx

/-- The fibre over the right endpoint is the closed half-line above it. -/
theorem clamp_eq_right_iff {a b x : α} (hab : a < b) : clamp a b x = b ↔ b ≤ x := by
  constructor
  · intro h
    by_contra hx
    push_neg at hx
    rcases le_total a x with hax | hax
    · rw [clamp_of_mem (by rw [Set.uIcc_of_le hab.le]; exact ⟨hax, hx.le⟩)] at h
      exact absurd h (ne_of_lt hx)
    · rw [clamp_of_le_left hab.le hax] at h
      exact absurd h (ne_of_lt hab)
  · intro hx
    exact clamp_of_right_le hab.le hx

/-- Over an interior point of the segment the fibre is a single point. -/
theorem clamp_eq_interior_iff {a b m x : α} (ham : a < m) (hmb : m < b) :
    clamp a b x = m ↔ x = m := by
  constructor
  · intro h
    rcases lt_trichotomy x m with hx | hx | hx
    · rcases le_total x a with hxa | hxa
      · rw [clamp_of_le_left (ham.trans hmb).le hxa] at h
        exact absurd h (ne_of_lt ham)
      · rw [clamp_of_mem (show x ∈ Set.uIcc a b by
          rw [Set.uIcc_of_le (ham.trans hmb).le]; exact ⟨hxa, (hx.trans hmb).le⟩)] at h
        exact absurd h (ne_of_lt hx)
    · exact hx
    · rcases le_total b x with hbx | hbx
      · rw [clamp_of_right_le (ham.trans hmb).le hbx] at h
        exact absurd h.symm (ne_of_lt hmb)
      · rw [clamp_of_mem (show x ∈ Set.uIcc a b by
          rw [Set.uIcc_of_le (ham.trans hmb).le]; exact ⟨(ham.trans hx).le, hbx⟩)] at h
        exact absurd h (ne_of_gt hx)
  · rintro rfl
    exact clamp_of_mem (by rw [Set.uIcc_of_le (ham.trans hmb).le]; exact ⟨ham.le, hmb.le⟩)

/-- The range of the projection is the whole segment: every value in `[a,b]` is realised by
some third seed. -/
theorem median_range {a b : ℝ} (hab : a ≤ b) :
    Set.range (fun x : ℝ => tropMed3 a b x) = Set.Icc a b := by
  ext m
  constructor
  · rintro ⟨x, rfl⟩
    have h := tropMed3_mem_uIcc a b x
    rw [Set.uIcc_of_le hab] at h
    exact h
  · intro hm
    refine ⟨m, ?_⟩
    show tropMed3 a b m = m
    rw [tropMed3_eq_proj]
    exact clamp_of_mem (by rwa [Set.uIcc_of_le hab])

/-! ## The metric content: it really is the nearest point -/

/-- **The clamp is a nearest point of the segment.** -/
theorem proj_is_nearest {a b : ℝ} (hab : a ≤ b) (x : ℝ) {y : ℝ} (hy : y ∈ Set.Icc a b) :
    |clamp a b x - x| ≤ |y - x| := by
  obtain ⟨hya, hyb⟩ := hy
  rcases le_total x a with hxa | hxa
  · rw [clamp_of_le_left hab hxa, abs_of_nonneg (by linarith), abs_of_nonneg (by linarith)]
    linarith
  · rcases le_total b x with hbx | hbx
    · rw [clamp_of_right_le hab hbx, abs_of_nonpos (by linarith), abs_of_nonpos (by linarith)]
      linarith
    · rw [clamp_of_mem (by rw [Set.uIcc_of_le hab]; exact ⟨hxa, hbx⟩), sub_self, abs_zero]
      exact abs_nonneg _

/-- **Uniqueness of the nearest point.** -/
theorem proj_unique_nearest {a b : ℝ} (hab : a ≤ b) (x : ℝ) {y : ℝ} (hy : y ∈ Set.Icc a b)
    (h : |y - x| ≤ |clamp a b x - x|) : y = clamp a b x := by
  obtain ⟨hya, hyb⟩ := hy
  rcases le_total x a with hxa | hxa
  · rw [clamp_of_le_left hab hxa] at h ⊢
    rw [abs_of_nonneg (by linarith : (0:ℝ) ≤ y - x), abs_of_nonneg (by linarith)] at h
    linarith
  · rcases le_total b x with hbx | hbx
    · rw [clamp_of_right_le hab hbx] at h ⊢
      rw [abs_of_nonpos (by linarith : y - x ≤ 0), abs_of_nonpos (by linarith)] at h
      linarith
    · rw [clamp_of_mem (by rw [Set.uIcc_of_le hab]; exact ⟨hxa, hbx⟩)] at h ⊢
      rw [sub_self, abs_zero] at h
      have := abs_nonneg (y - x)
      have hzero : y - x = 0 := by
        have := abs_eq_zero.mp (le_antisymm h (abs_nonneg _))
        exact this
      linarith

/-! ## Stability: monotonicity, nonexpansiveness, firm nonexpansiveness -/

/-- The projection is monotone in the third seed. -/
theorem proj_monotone (a b : ℝ) {x y : ℝ} (hxy : x ≤ y) :
    clamp a b x ≤ clamp a b y := by
  simp only [clamp, min_def, max_def]
  split_ifs <;> linarith

/-- The projection is `1`-Lipschitz. -/
theorem proj_nonexpansive (a b x y : ℝ) :
    |clamp a b x - clamp a b y| ≤ |x - y| := by
  simp only [clamp, min_def, max_def]
  split_ifs <;>
    rw [abs_sub_le_iff] <;>
      constructor <;>
        first
          | (rcases abs_cases (x - y) with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> linarith)

/-- **Firm nonexpansiveness.**  The defining inequality of a metric projection onto a convex
set: `(P x - P y)^2 ≤ (x - y) * (P x - P y)`.  It implies the `1`-Lipschitz bound but is
strictly stronger — it says the projection is a *firmly* nonexpansive retraction. -/
theorem proj_firmly_nonexpansive (a b x y : ℝ) :
    (clamp a b x - clamp a b y) ^ 2 ≤ (x - y) * (clamp a b x - clamp a b y) := by
  rcases le_total x y with hxy | hxy
  · have hmono := proj_monotone a b hxy
    have hlip : clamp a b y - clamp a b x ≤ y - x := by
      have := proj_nonexpansive a b x y
      rcases abs_cases (clamp a b x - clamp a b y) with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;>
        rcases abs_cases (x - y) with ⟨h3, h4⟩ | ⟨h3, h4⟩ <;> linarith
    nlinarith
  · have hmono := proj_monotone a b hxy
    have hlip : clamp a b x - clamp a b y ≤ x - y := by
      have := proj_nonexpansive a b x y
      rcases abs_cases (clamp a b x - clamp a b y) with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;>
        rcases abs_cases (x - y) with ⟨h3, h4⟩ | ⟨h3, h4⟩ <;> linarith
    nlinarith

/-! ## The measured NET-48 configuration -/

/-- **The stability ray.**  With the two measured 16× seeds `256` and `224` fixed, the
third-seed values that keep the three-seed median at `224` are *exactly* the closed
half-line `x ≤ 224` — the normal cone of the segment `[224,256]` at its left endpoint. -/
theorem net48_stability_ray (x : ℝ) : tropMed3 256 224 x = 224 ↔ x ≤ 224 := by
  rw [tropMed3_eq_proj]
  have h : clamp (256 : ℝ) 224 x = clamp 224 256 x := by
    simp only [clamp, min_comm, max_comm]
  rw [h]
  exact clamp_eq_left_iff (by norm_num)

/-- The measured third seed `160` lies in the stability ray, so the 16× median is `224`. -/
theorem net48_third_seed_160 : tropMed3 (256 : ℝ) 224 160 = 224 :=
  (net48_stability_ray 160).mpr (by norm_num)

/-- **The informal claim "only third seeds `≥ 256` move the centre" is false**: the value
`240`, which is `< 256`, already moves the median off `224`. -/
theorem net48_informal_claim_false :
    tropMed3 (256 : ℝ) 224 240 = 240 ∧ (240 : ℝ) < 256 ∧ tropMed3 (256 : ℝ) 224 240 ≠ 224 := by
  have h : tropMed3 (256 : ℝ) 224 240 = 240 := by
    rw [tropMed3_eq_proj]
    have h' : clamp (256 : ℝ) 224 240 = clamp 224 256 240 := by
      simp only [clamp, min_comm, max_comm]
    rw [h']
    exact clamp_of_mem (by rw [Set.uIcc_of_le (by norm_num : (224:ℝ) ≤ 256)]; constructor <;>
      norm_num)
  exact ⟨h, by norm_num, by rw [h]; norm_num⟩

/-- The measured third seed is `64` below the segment spanned by the first two seeds, and
`64` is exactly its distance to that segment: the projection absorbs the whole excursion. -/
theorem net48_projection_distance :
    |clamp (224 : ℝ) 256 160 - 160| = 64 ∧
      ∀ y ∈ Set.Icc (224 : ℝ) 256, (64 : ℝ) ≤ |y - 160| := by
  constructor
  · rw [clamp_of_le_left (by norm_num) (by norm_num)]
    rw [abs_of_nonneg (by norm_num)]
    norm_num
  · intro y hy
    obtain ⟨hy1, _⟩ := hy
    rw [abs_of_nonneg (by linarith)]
    linarith

/-- The median's range, as the third seed varies over all of ℝ, is the compact segment
`[224,256]`. -/
theorem net48_median_range :
    Set.range (fun x : ℝ => tropMed3 224 256 x) = Set.Icc 224 256 :=
  median_range (by norm_num)

/-! ## Contrast with the mean -/

/-- The arithmetic mean of three reals. -/
noncomputable def mean3 (a b x : ℝ) : ℝ := (a + b + x) / 3

/-- **The mean is unbounded in the third seed**: with two seeds fixed, the mean attains
*every* real value, so no analogue of `net48_median_range` holds for it. -/
theorem mean_surjective (a b : ℝ) : Set.range (fun x : ℝ => mean3 a b x) = Set.univ := by
  ext m
  refine ⟨fun _ => trivial, fun _ => ⟨3 * m - a - b, ?_⟩⟩
  simp only [mean3]
  ring

/-- On the measured 16× data the mean is `640/3`, off the product-point scale, whereas the
median is exactly `224 = 7/8 · 256`. -/
theorem net48_mean_moves :
    mean3 256 224 160 = 640 / 3 ∧ mean3 (256:ℝ) 224 160 ≠ 224 ∧
      tropMed3 (256:ℝ) 224 160 = 7 / 8 * 256 := by
  refine ⟨by norm_num [mean3], by norm_num [mean3], ?_⟩
  rw [net48_third_seed_160]; norm_num

end Catalog.Geometry.KneeMedianProjection