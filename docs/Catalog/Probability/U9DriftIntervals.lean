/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Confidence intervals for the band-9 smoothness ratio: coverage, deliverables, and the
  round-to-four display defect

Context (experiment 569, paper 216; replication of the paper-214 pilot).  A run measures
the ratio

`r = (rate of B-smooth values among the candidates x^2 - N) / (rate among size-matched controls)`

at band 9 (bit length 96 balanced semiprimes) and reports a cluster-bootstrap percentile
interval for `r`.  The *decision rule* is: the null "candidates behave like size-matched
random values" is retained exactly when the interval covers `1`; the *deliverable* that is
compared between runs is the worst-case CI edge distance `max (|lo - 1|) (|hi - 1|)`.

This file gives the exact theory of that reporting scheme, and the numerical facts the
round-74 ledger rests on.

Main results:

* `U9Drift.CI.covers_iff_abs_le` — coverage is the symmetric statement `|x - c| ≤ h`
  around the interval centre.
* `U9Drift.CI.edge_eq_halfWidth_add` — for an interval that covers `1`, the reported
  deliverable splits exactly as `halfWidth + |centre - 1|`: a run can improve the
  deliverable either by getting tighter or by drifting back towards `1`.
* `U9Drift.replication_tightens_deliverable` — the fresh-seed replication interval
  `[0.919, 1.0101]` has deliverable `0.081`, strictly tightening the pilot's `0.137`;
  `U9Drift.replication_is_more_precise` and `U9Drift.replication_is_less_drifted` show
  that *both* summands improve, so the tightening is not an artifact of re-centering.
* `U9Drift.all_intervals_cover_one` — every reported interval (pilot `1e6`, replication
  `1e5` primary, replication `1e6` secondary) covers `1`: the `H0` branch is the one the
  pre-registration selects.
* `U9Drift.store4_eq_zero_of_small` / `U9Drift.store4_not_injective` — the pre-patch writer
  stored `round(·, 4)`, which is *constant zero* on the whole range `[0, 5·10⁻⁵)` in which
  the candidate rate lives; the stored `0.0` therefore carries no information beyond that
  range membership.
* `U9Drift.candidate_rate_pinned` / `U9Drift.candidate_rate_pos` — the CI-implied recovery:
  the true candidate rate lies in `[2.65701·10⁻⁵, 3.56128·10⁻⁵]`, in particular it is
  positive, so the stored value is provably not the measured one.
* `U9Drift.ledger_bracket_is_not_an_enclosure` — an adversarial catch: the bracket
  `[2.66·10⁻⁵, 3.56·10⁻⁵]` quoted in the ledger has its endpoints rounded *inwards*, so it
  is not a valid enclosure of the CI-implied range; the outward-rounded
  `[2.65·10⁻⁵, 3.57·10⁻⁵]` (`U9Drift.candidate_rate_safe_bracket`) is.
-/

namespace U9Drift

open Real

/-! ## Elementary square comparison helpers -/

/-- Comparison by squares, for a nonnegative right-hand side. -/
theorem le_of_sq_le_sq_nonneg {x y : ℝ} (hy : 0 ≤ y) (h : x ^ 2 ≤ y ^ 2) : x ≤ y := by
  nlinarith

/-- Strict comparison by squares, for nonnegative arguments. -/
theorem lt_of_sq_lt_sq_nonneg {x y : ℝ} (hx : 0 ≤ x) (hy : 0 ≤ y) (h : x ^ 2 < y ^ 2) :
    x < y := by nlinarith

/-- Absolute-value comparison by squares. -/
theorem abs_le_of_sq_le_sq_nonneg {x y : ℝ} (hy : 0 ≤ y) (h : x ^ 2 ≤ y ^ 2) : |x| ≤ y :=
  le_of_sq_le_sq_nonneg hy (by rwa [sq_abs])

/-! ## Reported intervals -/

/-- A reported (percentile bootstrap) confidence interval. -/
structure CI where
  lo : ℝ
  hi : ℝ
  le : lo ≤ hi

namespace CI

variable (I : CI)

/-- The centre of the reported interval. -/
noncomputable def center : ℝ := (I.lo + I.hi) / 2

/-- Half the width of the reported interval; the natural precision measure. -/
noncomputable def halfWidth : ℝ := (I.hi - I.lo) / 2

/-- Coverage: the interval contains the value `x`.  The retained-null decision rule is
`I.Covers 1`. -/
def Covers (x : ℝ) : Prop := I.lo ≤ x ∧ x ≤ I.hi

/-- The reported deliverable: the worst-case CI-edge distance from the null value `1`. -/
noncomputable def edge : ℝ := max |I.lo - 1| |I.hi - 1|

theorem halfWidth_nonneg : 0 ≤ I.halfWidth := by
  have := I.le; simp only [halfWidth]; linarith

theorem lo_eq : I.lo = I.center - I.halfWidth := by
  simp only [center, halfWidth]; ring

theorem hi_eq : I.hi = I.center + I.halfWidth := by
  simp only [center, halfWidth]; ring

/-- Coverage is the symmetric statement `|x - centre| ≤ halfWidth`. -/
theorem covers_iff_abs_le (x : ℝ) : I.Covers x ↔ |x - I.center| ≤ I.halfWidth := by
  rw [abs_le]
  constructor
  · rintro ⟨h1, h2⟩
    rw [lo_eq] at h1; rw [hi_eq] at h2
    exact ⟨by linarith, by linarith⟩
  · rintro ⟨h1, h2⟩
    refine ⟨?_, ?_⟩
    · rw [lo_eq]; linarith
    · rw [hi_eq]; linarith

/-- For an interval covering the null value `1`, the deliverable decomposes exactly into a
precision part and a drift part. -/
theorem edge_eq_halfWidth_add (h : I.Covers 1) :
    I.edge = I.halfWidth + |I.center - 1| := by
  obtain ⟨h1, h2⟩ := h
  have hlo : |I.lo - 1| = 1 - I.lo := by rw [abs_of_nonpos (by linarith)]; ring
  have hhi : |I.hi - 1| = I.hi - 1 := by rw [abs_of_nonneg (by linarith)]
  have hL := I.lo_eq
  have hH := I.hi_eq
  have hw := I.halfWidth_nonneg
  rw [edge, hlo, hhi]
  rcases le_total I.center 1 with hc | hc
  · rw [abs_of_nonpos (by linarith), max_eq_left (by rw [hL, hH] at *; linarith)]
    rw [hL]; ring
  · rw [abs_of_nonneg (by linarith), max_eq_right (by rw [hL, hH] at *; linarith)]
    rw [hH]; ring

/-- A tighter and less drifted interval has the smaller deliverable. -/
theorem edge_le_edge_of (J : CI) (hI : I.Covers 1) (hJ : J.Covers 1)
    (hw : I.halfWidth ≤ J.halfWidth) (hc : |I.center - 1| ≤ |J.center - 1|) :
    I.edge ≤ J.edge := by
  rw [edge_eq_halfWidth_add _ hI, edge_eq_halfWidth_add _ hJ]; linarith

end CI

/-! ## The three reported intervals of the round-74 ledger -/

/-- Paper 214's pilot interval at the `1e6` low-prime-factor cut. -/
def pilot1e6 : CI := ⟨0.8630, 1.0389, by norm_num⟩

/-- Experiment 569's fresh-seed replication at the pre-registered primary `1e5` cut. -/
def rep1e5 : CI := ⟨0.8571, 1.1488, by norm_num⟩

/-- Experiment 569's fresh-seed replication at the better-powered secondary `1e6` cut. -/
def rep1e6 : CI := ⟨0.919, 1.0101, by norm_num⟩

theorem all_intervals_cover_one :
    pilot1e6.Covers 1 ∧ rep1e5.Covers 1 ∧ rep1e6.Covers 1 :=
  ⟨⟨by norm_num [pilot1e6, CI.lo], by norm_num [pilot1e6, CI.hi]⟩,
   ⟨by norm_num [rep1e5, CI.lo], by norm_num [rep1e5, CI.hi]⟩,
   ⟨by norm_num [rep1e6, CI.lo], by norm_num [rep1e6, CI.hi]⟩⟩

theorem pilot1e6_edge : pilot1e6.edge = 0.1370 := by
  have h1 : |pilot1e6.lo - 1| = 0.1370 := by
    rw [show pilot1e6.lo = 0.8630 from rfl, abs_of_nonpos (by norm_num)]; norm_num
  have h2 : |pilot1e6.hi - 1| = 0.0389 := by
    rw [show pilot1e6.hi = 1.0389 from rfl, abs_of_nonneg (by norm_num)]; norm_num
  rw [CI.edge, h1, h2]; norm_num

theorem rep1e6_edge : rep1e6.edge = 0.081 := by
  have h1 : |rep1e6.lo - 1| = 0.081 := by
    rw [show rep1e6.lo = 0.919 from rfl, abs_of_nonpos (by norm_num)]; norm_num
  have h2 : |rep1e6.hi - 1| = 0.0101 := by
    rw [show rep1e6.hi = 1.0101 from rfl, abs_of_nonneg (by norm_num)]; norm_num
  rw [CI.edge, h1, h2]; norm_num

/-- The replication strictly tightens the pilot's `H0` deliverable. -/
theorem replication_tightens_deliverable : rep1e6.edge < pilot1e6.edge := by
  rw [rep1e6_edge, pilot1e6_edge]; norm_num

/-- The tightening is *not* explained by drift alone: the replication is strictly more
precise as well (smaller half width). -/
theorem replication_is_more_precise : rep1e6.halfWidth < pilot1e6.halfWidth := by
  show ((1.0101 : ℝ) - 0.919) / 2 < ((1.0389 : ℝ) - 0.8630) / 2
  norm_num

/-- ...and it is strictly closer to the null value. -/
theorem replication_is_less_drifted : |rep1e6.center - 1| < |pilot1e6.center - 1| := by
  have h1 : rep1e6.center = 0.96455 := by show ((0.919 : ℝ) + 1.0101) / 2 = _; norm_num
  have h2 : pilot1e6.center = 0.95095 := by show ((0.8630 : ℝ) + 1.0389) / 2 = _; norm_num
  rw [h1, h2, abs_of_nonpos (by norm_num), abs_of_nonpos (by norm_num)]; norm_num

/-! ## The round-to-four display defect -/

/-- The pre-patch writer: store `round(x, 4)` (half-up). -/
noncomputable def store4 (x : ℝ) : ℝ := (⌊x * 10 ^ 4 + 1 / 2⌋ : ℤ) / 10 ^ 4

/-- On the whole range in which the band-9 candidate rate lives, the stored value is
identically `0`: the writer destroys the measurement. -/
theorem store4_eq_zero_of_small {x : ℝ} (h0 : 0 ≤ x) (h1 : x < 5 / 10 ^ 5) :
    store4 x = 0 := by
  have hfl : ⌊x * 10 ^ 4 + 1 / 2⌋ = 0 := by
    rw [Int.floor_eq_zero_iff, Set.mem_Ico]
    constructor
    · nlinarith
    · nlinarith
  rw [store4, hfl]
  norm_num

/-- Consequently the writer is not injective on that range: two genuinely different
candidate rates — indeed the two endpoints of the CI-implied bracket — are stored
identically, so the stored `0.0` is unrecoverable post hoc. -/
theorem store4_not_injective :
    ∃ x y : ℝ, 0 ≤ x ∧ 0 ≤ y ∧ x ≠ y ∧ store4 x = store4 y := by
  refine ⟨2.66 / 10 ^ 5, 3.56 / 10 ^ 5, by norm_num, by norm_num, by norm_num, ?_⟩
  rw [store4_eq_zero_of_small (by norm_num) (by norm_num),
    store4_eq_zero_of_small (by norm_num) (by norm_num)]

/-! ## CI-implied recovery of the candidate rate -/

/-- The measured control rate at the primary `1e5` cut. -/
noncomputable def rateCtrl : ℝ := 3.1 / 10 ^ 5

/-- Recovery rule: the candidate rate is the ratio times the control rate, so a CI for the
ratio transports to a CI for the rate. -/
theorem rate_of_ratio_mem {r : ℝ} (I : CI) (h : I.Covers r) (c : ℝ) (hc : 0 ≤ c) :
    I.lo * c ≤ r * c ∧ r * c ≤ I.hi * c :=
  ⟨mul_le_mul_of_nonneg_right h.1 hc, mul_le_mul_of_nonneg_right h.2 hc⟩

/-- The exact CI-implied bracket for the band-9 candidate rate at the primary cut. -/
theorem candidate_rate_pinned {r : ℝ} (h : rep1e5.Covers r) :
    2.65701 / 10 ^ 5 ≤ r * rateCtrl ∧ r * rateCtrl ≤ 3.56128 / 10 ^ 5 := by
  obtain ⟨h1, h2⟩ := rate_of_ratio_mem rep1e5 h rateCtrl (by rw [rateCtrl]; norm_num)
  have e1 : rep1e5.lo * rateCtrl = 2.65701 / 10 ^ 5 := by
    show (0.8571 : ℝ) * (3.1 / 10 ^ 5) = _; norm_num
  have e2 : rep1e5.hi * rateCtrl = 3.56128 / 10 ^ 5 := by
    show (1.1488 : ℝ) * (3.1 / 10 ^ 5) = _; norm_num
  rw [e1] at h1; rw [e2] at h2
  exact ⟨h1, h2⟩

/-- A safe (outward-rounded) three-significant-figure bracket. -/
theorem candidate_rate_safe_bracket {r : ℝ} (h : rep1e5.Covers r) :
    2.65 / 10 ^ 5 ≤ r * rateCtrl ∧ r * rateCtrl ≤ 3.57 / 10 ^ 5 := by
  obtain ⟨h1, h2⟩ := candidate_rate_pinned h
  exact ⟨le_trans (by norm_num) h1, le_trans h2 (by norm_num)⟩

/-- In particular the true candidate rate is strictly positive, so the stored `0.0` is
provably *not* the measured value — while still being its correct four-decimal rounding. -/
theorem candidate_rate_pos {r : ℝ} (h : rep1e5.Covers r) :
    0 < r * rateCtrl ∧ store4 (r * rateCtrl) = 0 := by
  obtain ⟨h1, h2⟩ := candidate_rate_pinned h
  have hpos : (0:ℝ) < r * rateCtrl := lt_of_lt_of_le (by norm_num) h1
  exact ⟨hpos, store4_eq_zero_of_small hpos.le (by linarith [h2] )⟩

/-- Adversarial catch on the ledger's own quoted numbers: the bracket
`[2.66·10⁻⁵, 3.56·10⁻⁵]` is rounded *inwards*, hence is not an enclosure — both endpoints
of the CI-implied range fall outside it. -/
theorem ledger_bracket_is_not_an_enclosure :
    (∃ r : ℝ, rep1e5.Covers r ∧ r * rateCtrl < 2.66 / 10 ^ 5) ∧
    (∃ r : ℝ, rep1e5.Covers r ∧ 3.56 / 10 ^ 5 < r * rateCtrl) := by
  constructor
  · refine ⟨rep1e5.lo, ⟨le_rfl, rep1e5.le⟩, ?_⟩
    show (0.8571 : ℝ) * (3.1 / 10 ^ 5) < _
    norm_num
  · refine ⟨rep1e5.hi, ⟨rep1e5.le, le_rfl⟩, ?_⟩
    show _ < (1.1488 : ℝ) * (3.1 / 10 ^ 5)
    norm_num

end U9Drift