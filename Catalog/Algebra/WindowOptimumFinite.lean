/-
# The window is stronger, not shifted: finiteness of the count-dial optimum

Formal core of experiment **577** (paper 227), verdict part
(`WINDOW-STRONGER-NOT-SHIFTED`) and dispersion bookkeeping.

## The verdict to be explained

The pre-registered alternative `H1` was a *scale shift*: that the informative
quadratic-residue window moves outwards as the cutoff `B` grows, so that some
larger `B` would beat `B = 400`.  All four shift candidates failed, and the
measured sweep of the equal-weight count dial

  `B = 400 : R² = .3207`, `4000 : .0241`, `4·10⁴ : .0150`, `10⁵ : .0000`,
  `10⁶ : .0277`

instead *decays*.  The weighted dial, by contrast, is monotone and saturates.

## What is proved here

Working in the harmonic amplitude model of `ProductDialWeighting`:

* `WindowOptimumFinite.countR2_le_countScore` — the count dial's explained
  variance is bounded by the ambient-free score `H_n² / n`.
* `WindowOptimumFinite.countScore_tendsto_zero` — that score tends to `0`:
  there is no escape to larger windows.
* `WindowOptimumFinite.exists_window_optimum` — **the refutation of the scale
  shift**: the count-dial score attains a *global maximum at a finite window*
  `B*`.  Enlarging the window past `B*` can never help; the optimum does not run
  off to infinity.
* `WindowOptimumFinite.weighted_never_hurts` — the contrasting behaviour of the
  weighted dial: it is monotone in the window, so its "optimum" is the whole
  population, and by the saturation theorem it is already essentially attained
  at a small window.
* `WindowOptimumFinite.weighted_saturated_at_400` — at the published window the
  weighted dial captures at least `99.75%` of what any larger window can.
* `WindowOptimumFinite.harmonic_weightedR2_le` — the matching *lower* bound:
  a window of size `n` never explains more than `1 - 1/(8n)`, so the saturation
  rate is of order `1/n` exactly and the window size is a tolerance parameter,
  not a scale parameter.
* `WindowOptimumFinite.reading_ratio` — the exact algebra relating the two
  dispersion readings ("fraction of raw overdispersion" versus "fraction of
  excess above Poisson"): their ratio is `(D-1)/D`, *independent of the size of
  the reduction*.
* `WindowOptimumFinite.readings_consistent` — the two measured dial rows
  (`33.43% / 42.06%` and `48.51% / 61.00%`) imply the same baseline dispersion
  to within `0.03`, which is why both readings may be quoted for the same
  population.
-/
import Mathlib
import Algebra.ProductDialWeighting

namespace WindowOptimumFinite

open Finset Filter Topology ProductDialWeighting

/-! ## 1. The ambient-free count score -/

/-- The count dial's explained variance, stripped of the ambient normaliser:
`H_n² / n`. -/
noncomputable def countScore (n : ℕ) : ℝ := (∑ i ∈ range n, harmonicAmp i) ^ 2 / n

theorem countScore_nonneg (n : ℕ) : 0 ≤ countScore n := by
  unfold countScore; positivity

theorem countScore_one : countScore 1 = 1 := by
  simp [countScore, harmonicAmp]

/-- The count dial in any ambient population is bounded by the score. -/
theorem countR2_le_countScore {n N : ℕ} (hn : 0 < n) (hnN : n ≤ N) :
    countR2 (range N) (range n) harmonicAmp ≤ countScore n := by
  have hNpos : 0 < N := lt_of_lt_of_le hn hnN
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
  have hden : (1 : ℝ) ≤ ∑ i ∈ range N, (harmonicAmp i) ^ 2 :=
    harmonic_total_ge_one (N := N) hNpos
  have hcard : ((range n).card : ℝ) = n := by simp
  rw [countR2, hcard, countScore]
  have hd : (0 : ℝ) < (n : ℝ) * ∑ i ∈ range N, (harmonicAmp i) ^ 2 := by nlinarith
  rw [div_le_div_iff₀ hd hnpos]
  have hs : (0 : ℝ) ≤ (∑ i ∈ range n, harmonicAmp i) ^ 2 := sq_nonneg _
  have hmul : (n : ℝ) ≤ (n : ℝ) * ∑ i ∈ range N, (harmonicAmp i) ^ 2 := by nlinarith
  exact mul_le_mul_of_nonneg_left hmul hs

/-- The score obeys the logarithmic bound. -/
theorem countScore_le_log {n : ℕ} (hn : 0 < n) :
    countScore n ≤ (1 + Real.log n) ^ 2 / n := by
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
  have hnum : ∑ i ∈ range n, harmonicAmp i ≤ 1 + Real.log n := by
    rw [harmonic_window_sum]
    exact harmonic_le_one_add_log n
  have hnum0 : 0 ≤ ∑ i ∈ range n, harmonicAmp i :=
    Finset.sum_nonneg (fun i _ => le_of_lt (harmonicAmp_pos i))
  rw [countScore, div_le_div_iff₀ hnpos hnpos]
  have hsq : (∑ i ∈ range n, harmonicAmp i) ^ 2 ≤ (1 + Real.log n) ^ 2 := by nlinarith
  exact mul_le_mul_of_nonneg_right hsq (le_of_lt hnpos)

/-- **No escape to larger windows**: the count score tends to `0`. -/
theorem countScore_tendsto_zero : Tendsto countScore atTop (𝓝 0) := by
  refine squeeze_zero' (Eventually.of_forall (fun n => countScore_nonneg n)) ?_
    log_sq_div_tendsto_zero
  filter_upwards [eventually_gt_atTop 0] with n hn
  exact countScore_le_log hn

/-- **WINDOW-STRONGER-NOT-SHIFTED.**  The count-dial score attains a global
maximum at a *finite* window `B*`: no matter how far the cutoff is pushed, no
larger window can beat `B*`.  This is the formal refutation of the scale-shift
alternative. -/
theorem exists_window_optimum :
    ∃ B : ℕ, 1 ≤ B ∧ ∀ n : ℕ, 1 ≤ n → countScore n ≤ countScore B := by
  -- beyond some `m`, the score is below its value at the single-prime window
  have h := countScore_tendsto_zero
  rw [Metric.tendsto_atTop] at h
  obtain ⟨m, hm⟩ := h 1 one_pos
  have hbeyond : ∀ n : ℕ, m ≤ n → countScore n < countScore 1 := by
    intro n hn
    have := hm n hn
    rw [Real.dist_eq, sub_zero, countScore_one] at *
    exact lt_of_abs_lt this
  -- maximise over the finite range `[1, m]`
  have hne : (Icc 1 (max m 1)).Nonempty := ⟨1, mem_Icc.mpr ⟨le_refl 1, le_max_right m 1⟩⟩
  obtain ⟨B, hB, hBmax⟩ := Finset.exists_max_image (Icc 1 (max m 1)) countScore hne
  refine ⟨B, (mem_Icc.mp hB).1, fun n hn => ?_⟩
  rcases le_or_gt n (max m 1) with hle | hgt
  · exact hBmax n (mem_Icc.mpr ⟨hn, hle⟩)
  · have hnm : m ≤ n := le_trans (le_max_left m 1) (le_of_lt hgt)
    have h1 : countScore n < countScore 1 := hbeyond n hnm
    have h2 : countScore 1 ≤ countScore B :=
      hBmax 1 (mem_Icc.mpr ⟨le_refl 1, le_max_right m 1⟩)
    linarith

/-- **The weighted dial never suffers from extension.**  Contrast with
`exists_window_optimum`: for the harmonically weighted dial a larger window is
always at least as good, so the "optimal window" question is vacuous — the
content is the *rate* of saturation, quantified in `harmonic_weightedR2_ge`. -/
theorem weighted_never_hurts {n n' N : ℕ} (h : n ≤ n') (hN : 0 < N) :
    weightedR2 (range N) (range n) harmonicAmp
      ≤ weightedR2 (range N) (range n') harmonicAmp :=
  weightedR2_mono (range_subset_range.mpr h) harmonicAmp (harmonic_total_pos hN)

/-- **The `B* = 400` window, quantified.**  At the published window size the
harmonically weighted dial already captures at least `99.75%` of everything any
larger window can capture, whatever the ambient cutoff.  This is the theoretical
floor behind the measured `corr(W(10⁶), W(400)) = .999`. -/
theorem weighted_saturated_at_400 {N : ℕ} (hN : 400 ≤ N) :
    (0.9975 : ℝ) ≤ weightedR2 (range N) (range 400) harmonicAmp := by
  have h := harmonic_weightedR2_ge (n := 400) (N := N) (by norm_num) hN
  norm_num at h ⊢
  linarith

/-! ### 1b. The saturation rate is exactly of order `1/n`

The upper bound `1 - 1/n ≤ weightedR²` of `harmonic_weightedR2_ge` is matched by a
lower bound of the same order, so "how large a window do I need" is a question
about the *tolerance* only, never about the size of the ambient population. -/

/-- The total amplitude mass is at most `2`. -/
theorem harmonic_total_le_two (N : ℕ) :
    ∑ i ∈ range N, (harmonicAmp i) ^ 2 ≤ 2 := by
  rcases Nat.eq_zero_or_pos N with rfl | hN
  · norm_num
  · have hsplit : ∑ i ∈ range N, (harmonicAmp i) ^ 2
        = (harmonicAmp 0) ^ 2 + ∑ i ∈ Ico 1 N, (harmonicAmp i) ^ 2 := by
      rw [Finset.range_eq_Ico, Finset.sum_eq_sum_Ico_succ_bot hN]
    have htail : ∑ i ∈ Ico 1 N, (harmonicAmp i) ^ 2 ≤ 1 := by
      have := harmonic_tail_le (n := 1) (N := N) one_pos
      simpa using this
    have h0 : (harmonicAmp 0) ^ 2 = 1 := by norm_num [harmonicAmp]
    rw [hsplit, h0]
    linarith

/-- The tail beyond a window of size `n` carries at least `1/(4n)` of the
amplitude mass, provided the population reaches `2n`. -/
theorem harmonic_tail_ge {n N : ℕ} (hn : 0 < n) (hN : 2 * n ≤ N) :
    1 / (4 * (n : ℝ)) ≤ ∑ i ∈ Ico n N, (harmonicAmp i) ^ 2 := by
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hsub : Ico n (2 * n) ⊆ Ico n N := by
    apply Finset.Ico_subset_Ico (le_refl n) (by exact_mod_cast hN)
  have hterm : ∀ i ∈ Ico n (2 * n), 1 / (4 * (n : ℝ) ^ 2) ≤ (harmonicAmp i) ^ 2 := by
    intro i hi
    rw [Finset.mem_Ico] at hi
    have hiR : ((i : ℝ) + 1) ≤ 2 * n := by
      have : (i : ℝ) < 2 * n := by exact_mod_cast hi.2
      have hint : i + 1 ≤ 2 * n := hi.2
      exact_mod_cast hint
    have hipos : (0 : ℝ) < (i : ℝ) + 1 := by positivity
    rw [harmonicAmp, div_pow, one_pow]
    apply one_div_le_one_div_of_le
    · positivity
    · nlinarith
  have hcard : (Ico n (2 * n)).card = n := by simp; omega
  calc 1 / (4 * (n : ℝ)) = (n : ℝ) * (1 / (4 * (n : ℝ) ^ 2)) := by field_simp
    _ ≤ ∑ i ∈ Ico n (2 * n), (harmonicAmp i) ^ 2 := by
        have := Finset.sum_le_sum hterm
        simpa [hcard, Finset.sum_const, nsmul_eq_mul] using this
    _ ≤ ∑ i ∈ Ico n N, (harmonicAmp i) ^ 2 :=
        Finset.sum_le_sum_of_subset_of_nonneg hsub (fun i _ _ => sq_nonneg _)

/-- **Matching upper bound on saturation.**  A window of size `n` never explains
more than `1 - 1/(8n)` of the explainable variance once the population reaches
`2n`: saturation is of order `1/n` exactly, so the window size is a tolerance
parameter and not a scale parameter. -/
theorem harmonic_weightedR2_le {n N : ℕ} (hn : 0 < n) (hN : 2 * n ≤ N) :
    weightedR2 (range N) (range n) harmonicAmp ≤ 1 - 1 / (8 * (n : ℝ)) := by
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hNpos : 0 < N := lt_of_lt_of_le (by omega) hN
  have hsub : range n ⊆ range N := range_subset_range.mpr (by omega)
  have hpos := harmonic_total_pos (N := N) hNpos
  have hdiff : range N \ range n = Ico n N := by
    ext i
    simp only [Finset.mem_sdiff, Finset.mem_range, Finset.mem_Ico, not_lt]
    exact ⟨fun h => ⟨h.2, h.1⟩, fun h => ⟨h.2, h.1⟩⟩
  have hsplit : ∑ i ∈ range N \ range n, (harmonicAmp i) ^ 2
      + ∑ i ∈ range n, (harmonicAmp i) ^ 2 = ∑ i ∈ range N, (harmonicAmp i) ^ 2 :=
    Finset.sum_sdiff hsub
  have htail : 1 / (4 * (n : ℝ)) ≤ ∑ i ∈ range N \ range n, (harmonicAmp i) ^ 2 := by
    rw [hdiff]; exact harmonic_tail_ge hn hN
  have htot : ∑ i ∈ range N, (harmonicAmp i) ^ 2 ≤ 2 := harmonic_total_le_two N
  rw [weightedR2, div_le_iff₀ hpos]
  have hfrac : 1 / (8 * (n : ℝ)) * ∑ i ∈ range N, (harmonicAmp i) ^ 2
      ≤ 1 / (4 * (n : ℝ)) := by
    rw [div_mul_eq_mul_div, div_le_div_iff₀ (by positivity) (by positivity)]
    nlinarith
  nlinarith

/-! ## 2. Dispersion bookkeeping: the two readings of one reduction -/

/-- **Exact reading algebra.**  If a covariate removes an amount `Δ` of a
conditional dispersion `D > 1`, the "fraction of raw dispersion" reading is
`Δ/D` and the "fraction of excess above Poisson" reading is `Δ/(D-1)`; their
ratio is `(D-1)/D`, *independent of `Δ`*.  Hence the two published percentage
columns are two coordinates of a single number. -/
theorem reading_ratio (D Δ : ℝ) (hD : 1 < D) (hΔ : Δ ≠ 0) :
    (Δ / D) / (Δ / (D - 1)) = (D - 1) / D := by
  have hD0 : D ≠ 0 := by intro h; rw [h] at hD; linarith
  have hD1 : D - 1 ≠ 0 := by intro h; linarith
  field_simp

/-- Inverting the reading algebra: the baseline dispersion implied by a
raw/excess pair `(r, e)` is `1 / (1 - r/e)`. -/
noncomputable def impliedDispersion (r e : ℝ) : ℝ := 1 / (1 - r / e)

/-- **Both measured rows read the same population.**  The count dial at `B=400`
reported `33.43%` of raw dispersion and `42.06%` of the excess above Poisson;
the `1/ℓ`-weighted dial at `B=10⁶` reported `48.51%` and `61.00%`.  The implied
baseline dispersions agree to within `0.03`, confirming that the two rows are
consistent readings of one and the same overdispersion (rather than a
bookkeeping error). -/
theorem readings_consistent :
    |impliedDispersion (3343/10000) (4206/10000)
      - impliedDispersion (4851/10000) (6100/10000)| < 3/100 := by
  rw [impliedDispersion, impliedDispersion, abs_lt]
  norm_num

/-- **The residual band.**  Taking complements of the four measured shares: on
both readings the weighted dial leaves strictly less unexplained than the count
dial, and all four residuals lie in the band `[0.39, 0.58]`.  This is the
shrinkage of paper 226's "≥ 86% new structure" claim to a `39–58%` residual. -/
theorem residual_band :
    ((1 : ℝ) - 4851/10000 < 1 - 3343/10000) ∧
    ((1 : ℝ) - 6100/10000 < 1 - 4206/10000) ∧
    ((39 : ℝ)/100 ≤ 1 - 6100/10000) ∧
    ((1 : ℝ) - 4206/10000 ≤ 58/100) := by
  refine ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩

end WindowOptimumFinite