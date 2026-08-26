import Algebra.SmoothWindows.GaussianWindow

/-!
# Smooth windows III: sidelobes of the rectangular window versus the Gaussian window

This file is the quantitative heart of the programme: it compares the *transfer functions* of the
two windows, i.e. the Fourier transforms of the analysing window used to detect a peak.

The rectangular window `1_{[-T,T]}` — the window implicitly used by the finite cutoff
`|Im ρ| ≤ T` of `Algebra.ReciprocalZeroHarmonics.WindowDichotomy` — has the Dirichlet transfer
function `sin(2πTξ)/(πξ)`.  Its **sidelobes** decay only like `1/ξ`, and at the frequencies
`ξ_n = (2n+1)/(4T)` they attain the exact value `4T/(π(2n+1))`.  These are the spurious responses
that can masquerade as peaks.  The Gaussian window has no sidelobes at all: its transfer function
is a strictly unimodal Gaussian bump with super-polynomial decay.

## Main results

* `fourier_rectWin` — **the Dirichlet kernel identity**: `𝓕 1_{[-T,T]}(ξ) = sin(2πTξ)/(πξ)` for
  `ξ ≠ 0`, proved by an exact contour-free computation of `∫_{-T}^{T} e^{-2πiξt} dt`.
* `sidelobeFreq`, `norm_fourier_rectWin_sidelobeFreq` — the **exact sidelobe peaks**
  `‖𝓕 1_{[-T,T]}(ξ_n)‖ = 4T/(π(2n+1))` at `ξ_n = (2n+1)/(4T)`.
* `rect_sidelobes_not_negligible` — the normalised sidelobe amplitude `ξ‖𝓕 1(ξ)‖` does **not**
  tend to `0`: it equals `1/π` infinitely often.  Hence no `o(1/ξ)` bound holds.
* `gauss_transfer_rapid_decay` — for the Gaussian window `ξ^n ‖𝓕 g_s(ξ)‖ → 0` for every `n`.
* `gauss_beats_rect_at_sidelobes` — **sidelobe suppression theorem**: eventually along the
  rectangular sidelobe frequencies the Gaussian response is *strictly smaller* than the
  rectangular one, for every choice of widths.  A peak found with a Gaussian window at a high
  frequency cannot be a leaked sidelobe of the window itself.
* `rect_sidelobes_not_summable` — the sidelobe amplitudes are not even summable, so the spurious
  energy of the rectangular window is infinite; the Gaussian peaks are summable
  (`gauss_sidelobe_summable`).

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** The failure mode of the rectangular window is not smoothness per
  se but the `1/ξ` tail of its transfer function; a Gaussian window should remove it entirely,
  and the gap should be provable as an *eventual strict inequality*, not merely asymptotically.
* **Experiment (Experimenter).** `𝓕 1_{[-T,T]}` was computed from `integral_exp_mul_complex`
  after rewriting the indicator integral as an interval integral; the phase algebra reduces to
  `Complex.I ^ 2 = -1`.  The peak values use `sin((2n+1)π/2) = ±1`, obtained from
  `Real.cos_nat_mul_pi`.
* **Analysis (Analyst).** Three inequivalent measures of "no sidelobes" were tested: (i) strict
  unimodality (`norm_fourier_gaborAtom_strictAnti` of the previous file), (ii) rapid decay,
  (iii) summability of peak amplitudes.  The rectangular window fails all three; the Gaussian
  satisfies all three.  Only (ii)/(iii) are *quantitative* and survive rescaling of the window.
* **Critique (Critic).** The comparison is not vacuous: both sides are computed exactly, and the
  suppression theorem is stated as an eventual strict inequality along an explicit sequence of
  frequencies rather than as an asymptotic order relation.  `ξ ≠ 0` is essential in
  `fourier_rectWin`: at `ξ = 0` the transfer function equals `2T`, not `0/0`.
-/

namespace SmoothWindows

open Complex Real MeasureTheory FourierTransform

/-! ## The rectangular window and its Dirichlet transfer function -/

/-- The **rectangular window** of half-width `T`, the window implicit in a sharp cutoff. -/
noncomputable def rectWin (T : ℝ) : ℝ → ℂ := Set.indicator (Set.Icc (-T) T) 1

/-- **The Dirichlet transfer function.**  The Fourier transform of the rectangular window is the
sinc kernel `sin(2πTξ)/(πξ)`. -/
theorem fourier_rectWin {T ξ : ℝ} (hT : 0 ≤ T) (hξ : ξ ≠ 0) :
    𝓕 (rectWin T) ξ = ((Real.sin (2 * π * T * ξ) / (π * ξ) : ℝ) : ℂ) := by
  set c : ℂ := ((-(2 * π * ξ) : ℝ) : ℂ) * Complex.I with hcdef
  have hπ := Real.pi_pos
  have hξc : (ξ : ℂ) ≠ 0 := Complex.ofReal_ne_zero.mpr hξ
  have hc : c ≠ 0 := by
    rw [hcdef]
    simp only [ne_eq, mul_eq_zero, Complex.I_ne_zero, or_false, Complex.ofReal_eq_zero]
    intro h
    apply hξ
    have h2 : (2 * π) * ξ = 0 := by linarith [h]
    rcases mul_eq_zero.mp h2 with h1 | h1
    · nlinarith
    · exact h1
  rw [Real.fourier_real_eq_integral_exp_smul]
  have hint : (fun v : ℝ => Complex.exp ((↑(-2 * π * v * ξ) : ℂ) * Complex.I) • rectWin T v)
      = Set.indicator (Set.Icc (-T) T) (fun v : ℝ => Complex.exp (c * v)) := by
    funext v
    by_cases hv : v ∈ Set.Icc (-T) T
    · rw [Set.indicator_of_mem hv, rectWin, Set.indicator_of_mem hv]
      simp only [Pi.one_apply, smul_eq_mul, mul_one]
      congr 1
      rw [hcdef]; push_cast; ring
    · rw [Set.indicator_of_notMem hv, rectWin, Set.indicator_of_notMem hv]
      simp
  rw [hint, MeasureTheory.integral_indicator measurableSet_Icc,
    MeasureTheory.integral_Icc_eq_integral_Ioc,
    ← intervalIntegral.integral_of_le (by linarith : -T ≤ T),
    integral_exp_mul_complex hc]
  have hsin : Complex.sin ((2 * π * T * ξ : ℝ) : ℂ)
      = (Complex.exp (c * T) - Complex.exp (c * (-T))) * Complex.I / 2 := by
    rw [Complex.sin, hcdef]
    congr 3 <;> push_cast <;> ring_nf
  rw [Complex.ofReal_div, Complex.ofReal_sin, hsin]
  push_cast
  field_simp
  simp only [hcdef]
  push_cast
  ring_nf
  rw [Complex.I_sq]
  field_simp
  ring

/-- The modulus of the rectangular transfer function. -/
theorem norm_fourier_rectWin {T ξ : ℝ} (hT : 0 ≤ T) (hξ : ξ ≠ 0) :
    ‖𝓕 (rectWin T) ξ‖ = |Real.sin (2 * π * T * ξ)| / (π * |ξ|) := by
  rw [fourier_rectWin hT hξ, Complex.norm_real, Real.norm_eq_abs, abs_div, abs_mul,
    abs_of_pos Real.pi_pos]

/-! ## The sidelobe frequencies -/

/-- The `n`-th **sidelobe frequency** of the rectangular window of half-width `T`:
`ξ_n = (2n+1)/(4T)`, where the Dirichlet kernel attains a local extremum of its numerator. -/
noncomputable def sidelobeFreq (T : ℝ) (n : ℕ) : ℝ := (2 * n + 1) / (4 * T)

theorem sidelobeFreq_pos {T : ℝ} (hT : 0 < T) (n : ℕ) : 0 < sidelobeFreq T n := by
  rw [sidelobeFreq]
  have : (0 : ℝ) < 2 * n + 1 := by positivity
  positivity

/-- At the sidelobe frequencies the Dirichlet numerator has modulus one. -/
theorem abs_sin_sidelobeFreq {T : ℝ} (hT : 0 < T) (n : ℕ) :
    |Real.sin (2 * π * T * sidelobeFreq T n)| = 1 := by
  have harg : 2 * π * T * sidelobeFreq T n = n * π + π / 2 := by
    rw [sidelobeFreq]
    field_simp
    ring
  rw [harg, Real.sin_add, Real.sin_pi_div_two, Real.cos_pi_div_two, Real.cos_nat_mul_pi]
  simp

/-- **The exact sidelobe amplitudes** of the rectangular window: `4T/(π(2n+1))`. -/
theorem norm_fourier_rectWin_sidelobeFreq {T : ℝ} (hT : 0 < T) (n : ℕ) :
    ‖𝓕 (rectWin T) (sidelobeFreq T n)‖ = 4 * T / (π * (2 * n + 1)) := by
  have hpos := sidelobeFreq_pos hT n
  rw [norm_fourier_rectWin hT.le hpos.ne', abs_sin_sidelobeFreq hT n, abs_of_pos hpos,
    sidelobeFreq]
  have h1 : (0 : ℝ) < 2 * n + 1 := by positivity
  field_simp

/-- The normalised sidelobe amplitude is *exactly* `1/π` at every sidelobe frequency: the
rectangular window leaks a fixed fraction of the signal at arbitrarily high frequencies. -/
theorem sidelobe_normalised_amplitude {T : ℝ} (hT : 0 < T) (n : ℕ) :
    sidelobeFreq T n * ‖𝓕 (rectWin T) (sidelobeFreq T n)‖ = 1 / π := by
  rw [norm_fourier_rectWin_sidelobeFreq hT, sidelobeFreq]
  have h1 : (0 : ℝ) < 2 * n + 1 := by positivity
  have hπ := Real.pi_pos
  field_simp

theorem sidelobeFreq_tendsto_atTop {T : ℝ} (hT : 0 < T) :
    Filter.Tendsto (sidelobeFreq T) Filter.atTop Filter.atTop := by
  have h : Filter.Tendsto (fun n : ℕ => (2 * (n : ℝ) + 1) / (4 * T))
      Filter.atTop Filter.atTop := by
    apply Filter.Tendsto.atTop_div_const (by positivity)
    exact Filter.tendsto_atTop_add_const_right _ 1
      (Filter.Tendsto.const_mul_atTop (by norm_num) tendsto_natCast_atTop_atTop)
  exact h

/-- **The rectangular sidelobes are not negligible.**  There is no bound of the form
`‖𝓕 1_{[-T,T]}(ξ)‖ = o(1/ξ)`: the normalised amplitude equals `1/π` infinitely often. -/
theorem rect_sidelobes_not_negligible {T : ℝ} (hT : 0 < T) :
    ¬ Filter.Tendsto (fun ξ : ℝ => ξ * ‖𝓕 (rectWin T) ξ‖) Filter.atTop (nhds 0) := by
  intro hcon
  have hsub := hcon.comp (sidelobeFreq_tendsto_atTop hT)
  have heq : ((fun ξ : ℝ => ξ * ‖𝓕 (rectWin T) ξ‖) ∘ sidelobeFreq T) = fun _ : ℕ => 1 / π := by
    funext n
    exact sidelobe_normalised_amplitude hT n
  rw [heq] at hsub
  have hlim : (1 : ℝ) / π = 0 := tendsto_nhds_unique tendsto_const_nhds hsub
  have hπ := Real.pi_pos
  have : (0 : ℝ) < 1 / π := by positivity
  linarith

/-! ## The Gaussian window has no sidelobes -/

/-- **Rapid decay of the Gaussian transfer function.**  For every polynomial weight `ξ^n` the
Gaussian response tends to zero — in complete contrast with `rect_sidelobes_not_negligible`. -/
theorem gauss_transfer_rapid_decay {s : ℝ} (hs : 0 < s) (a : ℝ) (n : ℕ) :
    Filter.Tendsto (fun ξ : ℝ => ξ ^ n * ‖𝓕 (gaborAtom s a 0) ξ‖) Filter.atTop (nhds 0) := by
  have hform : (fun ξ : ℝ => ξ ^ n * ‖𝓕 (gaborAtom s a 0) ξ‖)
      = fun ξ : ℝ => s * (ξ ^ n * gaussWin (1 / s) ξ) := by
    funext ξ
    rw [norm_fourier_gaborAtom hs, sub_zero]
    ring
  rw [hform]
  have := gaussWin_tendsto_zero_pow (s := 1 / s) (by positivity) n
  simpa using this.const_mul s

/-- **Sidelobe suppression.**  Along the rectangular sidelobe frequencies the Gaussian response
is eventually *strictly smaller* than the rectangular one, for any pair of widths.  Every
sufficiently high-frequency peak seen through a Gaussian window is therefore genuine, not an
artefact of the window. -/
theorem gauss_beats_rect_at_sidelobes {T s : ℝ} (hT : 0 < T) (hs : 0 < s) (a : ℝ) :
    ∀ᶠ n : ℕ in Filter.atTop,
      ‖𝓕 (gaborAtom s a 0) (sidelobeFreq T n)‖ < ‖𝓕 (rectWin T) (sidelobeFreq T n)‖ := by
  have hπ := Real.pi_pos
  have hdecay := gauss_transfer_rapid_decay hs a 1
  have hsub := hdecay.comp (sidelobeFreq_tendsto_atTop hT)
  have hev : ∀ᶠ n : ℕ in Filter.atTop,
      ((fun ξ : ℝ => ξ ^ 1 * ‖𝓕 (gaborAtom s a 0) ξ‖) ∘ sidelobeFreq T) n < 1 / π :=
    Filter.Tendsto.eventually_lt_const (by positivity) hsub
  filter_upwards [hev] with n hn
  simp only [Function.comp_apply, pow_one] at hn
  have hfreq := sidelobeFreq_pos hT n
  have hrect := sidelobe_normalised_amplitude hT n
  nlinarith [norm_nonneg (𝓕 (gaborAtom s a 0) (sidelobeFreq T n))]

/-! ## Summability: the total spurious energy -/

/-- **The rectangular sidelobe amplitudes are not summable**: the total spurious response of a
sharp cutoff diverges. -/
theorem rect_sidelobes_not_summable {T : ℝ} (hT : 0 < T) :
    ¬ Summable fun n : ℕ => ‖𝓕 (rectWin T) (sidelobeFreq T n)‖ := by
  intro hsum
  have hπ := Real.pi_pos
  have hcomp : Summable fun n : ℕ => 1 / ((n : ℝ) + 1) := by
    refine Summable.of_nonneg_of_le (fun n => by positivity) (fun n => ?_)
      (hsum.mul_left (π / (2 * T)))
    rw [norm_fourier_rectWin_sidelobeFreq hT]
    have hn : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
    rw [show π / (2 * T) * (4 * T / (π * (2 * (n : ℝ) + 1))) = 2 / (2 * (n : ℝ) + 1) by
      field_simp; ring]
    rw [div_le_div_iff₀ (by positivity) (by positivity)]
    linarith
  have h1 : Summable fun n : ℕ => 1 / (((n + 1 : ℕ) : ℝ)) := by
    simpa using hcomp
  exact Real.not_summable_one_div_natCast ((summable_nat_add_iff 1).mp h1)

set_option maxHeartbeats 1000000 in
/-- By contrast the Gaussian responses at the same frequencies are summable: the smooth window has
finite total spurious energy (indeed exponentially small). -/
theorem gauss_sidelobe_summable {T s : ℝ} (hT : 0 < T) (hs : 0 < s) (a : ℝ) :
    Summable fun n : ℕ => ‖𝓕 (gaborAtom s a 0) (sidelobeFreq T n)‖ := by
  have hdecay := gauss_transfer_rapid_decay hs a 2
  have hsub := hdecay.comp (sidelobeFreq_tendsto_atTop hT)
  have hev : ∀ᶠ n : ℕ in Filter.atTop,
      ((fun ξ : ℝ => ξ ^ 2 * ‖𝓕 (gaborAtom s a 0) ξ‖) ∘ sidelobeFreq T) n < 1 :=
    Filter.Tendsto.eventually_lt_const (by norm_num) hsub
  obtain ⟨N, hN⟩ := Filter.eventually_atTop.mp hev
  have hbound : ∀ n : ℕ, N ≤ n →
      ‖𝓕 (gaborAtom s a 0) (sidelobeFreq T n)‖ ≤ 16 * T ^ 2 / ((n : ℝ) + 1) ^ 2 := by
    intro n hn
    have h := hN n hn
    simp only [Function.comp_apply] at h
    have hfreq := sidelobeFreq_pos hT n
    have hsq : (0 : ℝ) < sidelobeFreq T n ^ 2 := by positivity
    have hle : ‖𝓕 (gaborAtom s a 0) (sidelobeFreq T n)‖ ≤ 1 / sidelobeFreq T n ^ 2 := by
      rw [le_div_iff₀ hsq]
      linarith [h, mul_comm (‖𝓕 (gaborAtom s a 0) (sidelobeFreq T n)‖) (sidelobeFreq T n ^ 2)]
    refine hle.trans ?_
    have hval : 1 / sidelobeFreq T n ^ 2 = 16 * T ^ 2 / (2 * (n : ℝ) + 1) ^ 2 := by
      rw [sidelobeFreq, div_pow, one_div_div]
      ring
    rw [hval]
    have hn1 : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
    gcongr
    nlinarith
  have hmaj : Summable fun n : ℕ => 16 * T ^ 2 / ((n : ℝ) + 1) ^ 2 := by
    have hbase : Summable fun n : ℕ => 1 / (n : ℝ) ^ 2 :=
      Real.summable_one_div_nat_pow.mpr one_lt_two
    have h2 : Summable fun n : ℕ => 1 / ((n : ℝ) + 1) ^ 2 := by
      have h1 := (summable_nat_add_iff (f := fun n : ℕ => 1 / (n : ℝ) ^ 2) 1).mpr hbase
      refine h1.congr (fun n => ?_)
      push_cast
      ring
    have h3 := h2.mul_left (16 * T ^ 2)
    refine h3.congr (fun n => ?_)
    rw [mul_one_div]
  refine Summable.of_norm_bounded_eventually_nat hmaj ?_
  filter_upwards [Filter.eventually_ge_atTop N] with n hn
  rw [Real.norm_eq_abs, abs_of_nonneg (norm_nonneg _)]
  exact hbound n hn

end SmoothWindows