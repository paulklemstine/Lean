import Algebra.SmoothWindows.HarmonicGaborWindow

/-!
# Smooth windows V: the Gaussian scale space of a zero family

Cycle 2 of the programme.  The previous file showed that the Gaussian window removes the *false
nulls* of the sharp cutoff.  Here we study the dependence of the windowed statistic on the window
*width* `s` — the "scale space" of the zero family — and prove that the smooth window turns the
discontinuous step function `T ↦ windowSum Z T` into a continuous, strictly increasing curve that
recovers the full harmonic sum in the wide-window limit.

## Main results

* `gaussSpectral` — the real spectral profile `Σ_t g_s(t)/(1/4 + t²)`, equal to the real part of
  the Gaussian-windowed harmonic sum (`gaussSum_pairedOrdinates_re`).
* `gaussSpectral_mono`, `gaussSpectral_strictMono` — the scale space is monotone in the width, and
  **strictly** monotone as soon as the family contains a nonzero ordinate.  Widening a Gaussian
  window can never decrease the detected mass.
* `gaussSpectral_continuousOn` — the scale space is continuous in the width on `s ≠ 0`.
* `rect_scale_not_continuousAt` — by contrast, the rectangular cutoff `T ↦ windowSum` is **not**
  continuous at `T = |t|`: the sharp window jumps.  This is the precise sense in which the sharp
  cutoff is a discontinuous estimator of the same quantity.
* `gaussSpectral_tendsto_harmonic` — **the wide-window limit recovers the catalog**: as `s → ∞`
  the Gaussian scale space converges to `Σ_t 1/(1/4 + t²)`, the unwindowed harmonic sum of
  `Algebra.ReciprocalZeroHarmonics.Core`.  The smooth window is therefore a genuine deformation of
  the catalog's statistic, not a different one.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** The Gaussian window should organise the zero family into a
  one-parameter *scale space*: a continuous, monotone family interpolating between "see nothing"
  (`s → 0`) and "see everything" (`s → ∞`), whereas the rectangular cutoff only produces a step
  function with jumps exactly at the ordinates.
* **Experiment (Experimenter).** Monotonicity reduces to `s₁ < s₂ ⟹ -πt²/s₁² < -πt²/s₂²`, i.e. to
  `nlinarith` on squares; strictness needs one ordinate `t ≠ 0`, isolated by
  `Multiset.exists_cons_of_mem`.  The wide-window limit uses `Tendsto.div_atTop` and a multiset
  induction over the family.  The discontinuity of the rectangular version is proved by computing
  the left limit `0` inside `𝓝[<] |t|` and comparing with the positive value at `|t|`.
* **Analysis (Analyst).** The jump of the rectangular estimator has size exactly `1/(1/4 + t²)` —
  the same quantity that the window dichotomy of the catalog uses as its detection threshold.  So
  the two windows differ not in what they can eventually see but in the *regularity* with which
  they see it, which is exactly what a numerical peak finder needs.
* **Critique (Critic).** `gaussSpectral_strictMono` genuinely needs a nonzero ordinate: for
  `S = {0}` the profile is the constant `4`, since `g_s(0) = 1` for every width.  The guarded
  hypothesis is stated explicitly rather than hidden.
-/

namespace SmoothWindows

open Complex Real ReciprocalZeroHarmonics

/-- The **Gaussian spectral profile** of a family of critical-line ordinates:
`Σ_t g_s(t)/(1/4 + t²)`. -/
noncomputable def gaussSpectral (S : Multiset ℝ) (s : ℝ) : ℝ :=
  (S.map fun t => gaussWin s t / (1 / 4 + t ^ 2)).sum

@[simp] theorem gaussSpectral_zero (s : ℝ) : gaussSpectral 0 s = 0 := by simp [gaussSpectral]

@[simp] theorem gaussSpectral_cons (t : ℝ) (S : Multiset ℝ) (s : ℝ) :
    gaussSpectral (t ::ₘ S) s = gaussWin s t / (1 / 4 + t ^ 2) + gaussSpectral S s := by
  simp [gaussSpectral]

/-- The spectral profile is the real part of the Gaussian-windowed harmonic sum. -/
theorem gaussSum_pairedOrdinates_re (S : Multiset ℝ) (s : ℝ) :
    (gaussSum (pairedOrdinates S) s).re = gaussSpectral S s := by
  rw [gaussSum_pairedOrdinates, Complex.ofReal_re, gaussSpectral]

/-! ## Monotonicity in the window width -/

theorem gaussWin_le_of_le {s₁ s₂ : ℝ} (h1 : 0 < s₁) (h : s₁ ≤ s₂) (t : ℝ) :
    gaussWin s₁ t ≤ gaussWin s₂ t := by
  rw [gaussWin, gaussWin, Real.exp_le_exp]
  have h1' : 0 < s₁ ^ 2 := pow_pos h1 2
  have h2' : 0 < s₂ ^ 2 := pow_pos (lt_of_lt_of_le h1 h) 2
  have hs : s₁ ^ 2 ≤ s₂ ^ 2 := by nlinarith
  rw [div_le_div_iff₀ h1' h2']
  nlinarith [mul_nonneg (mul_nonneg Real.pi_pos.le (sq_nonneg t)) (sub_nonneg.mpr hs)]

theorem gaussWin_lt_of_lt {t : ℝ} (ht : t ≠ 0) {s₁ s₂ : ℝ} (h1 : 0 < s₁) (h : s₁ < s₂) :
    gaussWin s₁ t < gaussWin s₂ t := by
  rw [gaussWin, gaussWin, Real.exp_lt_exp]
  have h1' : 0 < s₁ ^ 2 := pow_pos h1 2
  have h2' : 0 < s₂ ^ 2 := pow_pos (h1.trans h) 2
  have ht2 : 0 < t ^ 2 := lt_of_le_of_ne (sq_nonneg t) (Ne.symm (pow_ne_zero 2 ht))
  have hs : s₁ ^ 2 < s₂ ^ 2 := by nlinarith
  rw [div_lt_div_iff₀ h1' h2']
  nlinarith [mul_pos (mul_pos Real.pi_pos ht2) (sub_pos.mpr hs)]

/-- **Monotone scale space.**  Widening the Gaussian window never decreases the detected
spectral mass. -/
theorem gaussSpectral_mono (S : Multiset ℝ) {s₁ s₂ : ℝ} (h1 : 0 < s₁) (h : s₁ ≤ s₂) :
    gaussSpectral S s₁ ≤ gaussSpectral S s₂ := by
  refine Multiset.sum_map_le_sum_map _ _ fun t _ => ?_
  have hpos : (0 : ℝ) < 1 / 4 + t ^ 2 := by positivity
  have := gaussWin_le_of_le h1 h t
  gcongr

/-- **Strictly monotone scale space.**  If the family contains a nonzero ordinate the profile is
strictly increasing in the width. -/
theorem gaussSpectral_strictMono {S : Multiset ℝ} {t : ℝ} (ht : t ∈ S) (ht0 : t ≠ 0)
    {s₁ s₂ : ℝ} (h1 : 0 < s₁) (h : s₁ < s₂) :
    gaussSpectral S s₁ < gaussSpectral S s₂ := by
  obtain ⟨S', rfl⟩ := Multiset.exists_cons_of_mem ht
  rw [gaussSpectral_cons, gaussSpectral_cons]
  have hpos : (0 : ℝ) < 1 / 4 + t ^ 2 := by positivity
  have hstrict : gaussWin s₁ t / (1 / 4 + t ^ 2) < gaussWin s₂ t / (1 / 4 + t ^ 2) := by
    have := gaussWin_lt_of_lt ht0 h1 h
    gcongr
  have hrest : gaussSpectral S' s₁ ≤ gaussSpectral S' s₂ := gaussSpectral_mono S' h1 h.le
  linarith

/-! ## Continuity in the window width -/

/-- **The Gaussian scale space is continuous in the width.** -/
theorem gaussSpectral_continuousOn (S : Multiset ℝ) :
    ContinuousOn (fun s : ℝ => gaussSpectral S s) {s : ℝ | s ≠ 0} := by
  induction S using Multiset.induction_on with
  | empty => simpa using continuousOn_const
  | cons t S ih =>
    have harg : ContinuousOn (fun s : ℝ => -π * t ^ 2 / s ^ 2) {s : ℝ | s ≠ 0} :=
      continuousOn_const.div ((continuous_pow 2).continuousOn) fun s hs => pow_ne_zero 2 hs
    have hterm : ContinuousOn (fun s : ℝ => gaussWin s t / (1 / 4 + t ^ 2)) {s : ℝ | s ≠ 0} := by
      refine ContinuousOn.div_const ?_ _
      exact Real.continuous_exp.comp_continuousOn harg
    simpa using hterm.add ih

/-! ## The rectangular cutoff jumps -/

theorem windowSum_pairedOrdinates_singleton (t T : ℝ) :
    windowSum (pairedOrdinates {t}) T
      = if |t| ≤ T then ((1 / (1 / 4 + t ^ 2) : ℝ) : ℂ) else 0 := by
  classical
  rw [windowSum_pairedOrdinates]
  by_cases h : |t| ≤ T
  · rw [if_pos h, Multiset.filter_singleton, if_pos h, harmonicSum_pairedOrdinates]
    simp
  · rw [if_neg h, Multiset.filter_singleton, if_neg h]
    simp [pairedOrdinates]

/-- **The sharp cutoff is a discontinuous estimator.**  For a conjugate pair of critical-line
zeros with ordinate `t` the rectangular statistic jumps at `T = |t|`, by exactly the detection
threshold `1/(1/4 + t²)` of the catalog's window dichotomy. -/
theorem rect_scale_not_continuousAt (t : ℝ) :
    ¬ ContinuousAt (fun T : ℝ => (windowSum (pairedOrdinates {t}) T).re) |t| := by
  intro hcon
  have hval : (windowSum (pairedOrdinates {t}) |t|).re = 1 / (1 / 4 + t ^ 2) := by
    rw [windowSum_pairedOrdinates_singleton, if_pos le_rfl, Complex.ofReal_re]
  have hleft : Filter.Tendsto (fun T : ℝ => (windowSum (pairedOrdinates {t}) T).re)
      (nhdsWithin |t| (Set.Iio |t|)) (nhds ((windowSum (pairedOrdinates {t}) |t|).re)) :=
    hcon.continuousWithinAt.tendsto
  have hzero : Filter.Tendsto (fun T : ℝ => (windowSum (pairedOrdinates {t}) T).re)
      (nhdsWithin |t| (Set.Iio |t|)) (nhds 0) := by
    refine Filter.Tendsto.congr' ?_ tendsto_const_nhds
    filter_upwards [self_mem_nhdsWithin] with T hT
    rw [windowSum_pairedOrdinates_singleton, if_neg (not_le.mpr hT)]
    simp
  have huniq := tendsto_nhds_unique hleft hzero
  rw [hval] at huniq
  have hpos : (0 : ℝ) < 1 / (1 / 4 + t ^ 2) := by positivity
  linarith

/-! ## The wide-window limit recovers the catalog statistic -/

theorem gaussWin_tendsto_one_atTop (t : ℝ) :
    Filter.Tendsto (fun s : ℝ => gaussWin s t) Filter.atTop (nhds 1) := by
  have harg : Filter.Tendsto (fun s : ℝ => -π * t ^ 2 / s ^ 2) Filter.atTop (nhds 0) :=
    Filter.Tendsto.div_atTop tendsto_const_nhds (Filter.tendsto_pow_atTop (by norm_num))
  have := (Real.continuous_exp.tendsto 0).comp harg
  simpa [gaussWin, Function.comp] using this

/-- **The wide-window limit.**  As the Gaussian window widens, the smooth statistic converges to
the catalog's unwindowed harmonic sum `Σ_t 1/(1/4 + t²)`. -/
theorem gaussSpectral_tendsto_harmonic (S : Multiset ℝ) :
    Filter.Tendsto (gaussSpectral S) Filter.atTop
      (nhds ((S.map fun t => 1 / (1 / 4 + t ^ 2)).sum)) := by
  induction S using Multiset.induction_on with
  | empty => simpa using tendsto_const_nhds
  | cons t S ih =>
    have hterm : Filter.Tendsto (fun s : ℝ => gaussWin s t / (1 / 4 + t ^ 2)) Filter.atTop
        (nhds (1 / (1 / 4 + t ^ 2))) :=
      (gaussWin_tendsto_one_atTop t).div_const _
    rw [Multiset.map_cons, Multiset.sum_cons]
    have heq : gaussSpectral (t ::ₘ S)
        = fun s => gaussWin s t / (1 / 4 + t ^ 2) + gaussSpectral S s :=
      funext fun s => gaussSpectral_cons t S s
    rw [heq]
    exact hterm.add ih

/-- The limit value is exactly the catalog's harmonic sum of the paired family. -/
theorem gaussSpectral_tendsto_harmonicSum (S : Multiset ℝ) :
    Filter.Tendsto (gaussSpectral S) Filter.atTop
      (nhds (harmonicSum (pairedOrdinates S)).re) := by
  rw [harmonicSum_pairedOrdinates, Complex.ofReal_re]
  exact gaussSpectral_tendsto_harmonic S

end SmoothWindows