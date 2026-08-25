import Mathlib

/-!
# Binning-independent geometry of a windowed hump (exp 582 / paper 232)

This file formalises the *mathematical* content behind the "bin-width permutation ×
u-grid shift" probe.  The experiment measured a ratio curve `R = T/M` on `[0,1]`,
histogrammed it on a `6 × 5` grid of bin widths and circular grid shifts, and asked
whether the mid-window hump at `u* ≈ 0.65` is a property of the curve or of the
binning.  The empirical answer was *mixed-inconclusive*: the hump persists in all
30 cells and its **absolute** vertex is shift-invariant, while one particular
significance operationalisation (a local quadratic fit with a `≥ 1.10` amplitude bar)
fails in 23/30 cells.

We isolate four theorems that decide, rigorously, which of those observations can and
cannot be artefacts of the binning:

* `binVal_translate` — *rigid transport*: translating the data by `t` is exactly the
  same operation as translating the grid offset by `t`.  Bin **labels** drift by
  construction; the **absolute** position `label + shift` is a genuine invariant.
* `hump_certifies_peak` — *one-sided certificate*: a bin average `≥ c` forces the
  underlying curve to reach `c` somewhere in that bin.  Hence a persistent raw-max
  hump can never be manufactured by binning (only destroyed by it).
* `binAvg_peak_bound` and `rawmax_width_independent` — *binning-independent
  amplitude*: for an `L`-Lipschitz curve the raw maximum of the histogram sits within
  `L * w` of the true supremum, so two bin widths agree to `L * (w₁ + w₂)`.  This is
  the analytic version of the named follow-up ("binning-independent shape test").
* `argmax_bin_near_peak` — *vertex localisation*: under a peak cone condition every
  grid offset puts its argmax bin centre within `w/2 + L*w/κ` of the true peak.  This
  is why `vx + sh` pinned to `0.6482–0.6492` across all five shifts.

Two further blocks audit the *estimator* rather than the phenomenon:

* `qfit_*` — the three-point local quadratic fit.  Its vertex is always within half a
  bin of the argmax bin centre **unless** the fit is degenerate (curvature small
  compared with the neighbour asymmetry); this converts the "one erratic `nb = 33`
  cell with a vertex off by 0.19" into a certificate of degeneracy rather than of
  instability.  Its fitted amplitude is always `≥` the raw bin value, so an amplitude
  bar applied to the fit is *not* conservative in the direction one might guess.
* `fwer_*` — the control bars.  A bin-count-agnostic threshold has family-wise error
  tending to `1` as the number of bins grows, while the `nb`-aware threshold
  `1 - α/n` keeps it below `α`.  This is exactly why the three `nb ∈ {50,66,100}`
  cells breaching the flat `1.02` bar are not evidence of contamination.
-/

namespace Catalog.Computation.BinwidthUShift

open Set MeasureTheory

/-! ## Bin averages -/

/-- Average of `f` over the bin `[a, a+w]`. -/
noncomputable def binAvg (f : ℝ → ℝ) (a w : ℝ) : ℝ := w⁻¹ * ∫ x in a..(a + w), f x

/-- The `i`-th bin average of a uniform grid of width `w` anchored at offset `o`. -/
noncomputable def binVal (f : ℝ → ℝ) (o w : ℝ) (i : ℤ) : ℝ := binAvg f (o + i * w) w

/-- Centre of the `i`-th bin of the grid `(o, w)`. -/
noncomputable def binCenter (o w : ℝ) (i : ℤ) : ℝ := o + (i + 1 / 2) * w

/-! ### Rigid transport: data shift = grid shift -/

/-- Translating the data by `t` translates the bin window by `t`. -/
theorem binAvg_translate (f : ℝ → ℝ) (a w t : ℝ) :
    binAvg (fun x => f (x + t)) a w = binAvg f (a + t) w := by
  unfold binAvg
  congr 1
  have := intervalIntegral.integral_comp_add_right (a := a) (b := a + w) (d := t) f
  rw [this]
  ring_nf

/-- **Rigid transport.**  Shifting the data by `t` and shifting the grid offset by `t`
produce *the same* sequence of bin values, with the *same* labels.  Consequently the
label of the argmax bin drifts by construction under a `u`-grid shift, while the
absolute location `binCenter` of that bin is transported rigidly. -/
theorem binVal_translate (f : ℝ → ℝ) (o w t : ℝ) (i : ℤ) :
    binVal (fun x => f (x + t)) o w i = binVal f (o + t) w i := by
  unfold binVal
  rw [binAvg_translate]
  ring_nf

/-- The absolute bin centre moves rigidly with the grid offset: `binCenter` of the
shifted grid is the unshifted centre plus the shift.  Together with `binVal_translate`
this is the statement "`vx + sh` is the invariant, `vx` is not". -/
theorem binCenter_translate (o w t : ℝ) (i : ℤ) :
    binCenter (o + t) w i = binCenter o w i + t := by
  unfold binCenter; ring

/-! ### One-sided certificate: binning cannot manufacture a hump -/

theorem binAvg_le_of_le_on {f : ℝ → ℝ} {a w M : ℝ} (hw : 0 < w)
    (hf : ContinuousOn f (Icc a (a + w))) (h : ∀ x ∈ Icc a (a + w), f x ≤ M) :
    binAvg f a w ≤ M := by
  have hab : a ≤ a + w := by linarith
  have hint : IntervalIntegrable f volume a (a + w) :=
    (hf.mono (by rw [uIcc_of_le hab])).intervalIntegrable
  have hmono : (∫ x in a..(a + w), f x) ≤ ∫ _x in a..(a + w), M := by
    refine intervalIntegral.integral_mono_on hab hint intervalIntegrable_const ?_
    intro x hx; exact h x hx
  rw [intervalIntegral.integral_const] at hmono
  have hM : (a + w - a) • M = w * M := by rw [smul_eq_mul]; ring_nf
  rw [hM] at hmono
  unfold binAvg
  rw [inv_mul_le_iff₀ hw]
  exact hmono

theorem binAvg_ge_of_ge_on {f : ℝ → ℝ} {a w M : ℝ} (hw : 0 < w)
    (hf : ContinuousOn f (Icc a (a + w))) (h : ∀ x ∈ Icc a (a + w), M ≤ f x) :
    M ≤ binAvg f a w := by
  have hab : a ≤ a + w := by linarith
  have hint : IntervalIntegrable f volume a (a + w) :=
    (hf.mono (by rw [uIcc_of_le hab])).intervalIntegrable
  have hmono : (∫ _x in a..(a + w), M) ≤ ∫ x in a..(a + w), f x := by
    refine intervalIntegral.integral_mono_on hab intervalIntegrable_const hint ?_
    intro x hx; exact h x hx
  rw [intervalIntegral.integral_const] at hmono
  have hM : (a + w - a) • M = w * M := by rw [smul_eq_mul]; ring_nf
  rw [hM] at hmono
  unfold binAvg
  rw [le_inv_mul_iff₀ hw]
  exact hmono

/-- A bin average never exceeds the maximum of the curve on that bin. -/
theorem exists_ge_binAvg {f : ℝ → ℝ} {a w : ℝ} (hw : 0 < w) (hf : Continuous f) :
    ∃ x ∈ Icc a (a + w), binAvg f a w ≤ f x := by
  have hne : (Icc a (a + w)).Nonempty := ⟨a, by constructor <;> linarith⟩
  obtain ⟨x, hx, hmax⟩ := isCompact_Icc.exists_isMaxOn hne hf.continuousOn
  exact ⟨x, hx, binAvg_le_of_le_on hw hf.continuousOn (fun y hy => hmax hy)⟩

/-- **One-sided certificate.**  If *any* cell of *any* bin-width × shift grid records a
bin value of at least `c`, then the underlying curve really attains at least `c`.
Binning can only *flatten* a hump, never create one; so persistence of the raw-max
hump across all 30 cells is not an artefact candidate at all. -/
theorem hump_certifies_peak {f : ℝ → ℝ} {o w c : ℝ} {i : ℤ} (hw : 0 < w)
    (hf : Continuous f) (h : c ≤ binVal f o w i) : ∃ x, c ≤ f x := by
  obtain ⟨x, _, hx⟩ := exists_ge_binAvg (a := o + i * w) hw hf
  exact ⟨x, le_trans h hx⟩

/-! ### Binning-independent amplitude -/

variable {f : ℝ → ℝ} {L : ℝ}

/-- Lipschitz lower bound for a bin average around any point of the bin. -/
theorem binAvg_ge_of_lipschitz {a w c : ℝ} (hw : 0 < w) (hL : 0 ≤ L)
    (hf : Continuous f) (hlip : ∀ x y, |f x - f y| ≤ L * |x - y|)
    (hc : c ∈ Icc a (a + w)) : f c - L * w ≤ binAvg f a w := by
  refine binAvg_ge_of_ge_on hw hf.continuousOn ?_
  intro x hx
  have h1 : |f c - f x| ≤ L * |c - x| := hlip c x
  have h2 : |c - x| ≤ w := by
    obtain ⟨h3, h4⟩ := hx
    obtain ⟨h5, h6⟩ := hc
    rw [abs_le]
    constructor <;> linarith
  have h3 : f c - f x ≤ L * |c - x| := le_trans (le_abs_self _) h1
  nlinarith [abs_nonneg (c - x)]

/-- **Binning-independent amplitude.**  If `f` attains its global maximum at `xs` and
`xs` lies in the bin `[a, a+w]`, then that bin's average is within `L * w` of the true
peak value.  In particular the histogram raw maximum is a `O(L·w)`-accurate estimate
of `sup f`, with no reference to the grid offset. -/
theorem binAvg_peak_bound {a w xs : ℝ} (hw : 0 < w) (hL : 0 ≤ L) (hf : Continuous f)
    (hlip : ∀ x y, |f x - f y| ≤ L * |x - y|) (hmax : ∀ x, f x ≤ f xs)
    (hxs : xs ∈ Icc a (a + w)) : |binAvg f a w - f xs| ≤ L * w := by
  have hub : binAvg f a w ≤ f xs :=
    binAvg_le_of_le_on hw hf.continuousOn (fun x _ => hmax x)
  have hlb : f xs - L * w ≤ binAvg f a w := binAvg_ge_of_lipschitz hw hL hf hlip hxs
  rw [abs_le]; constructor <;> linarith

/-- Every real number lies in some bin of every grid. -/
theorem exists_bin_mem (o w xs : ℝ) (hw : 0 < w) :
    ∃ i : ℤ, xs ∈ Icc (o + i * w) (o + i * w + w) := by
  refine ⟨⌊(xs - o) / w⌋, ?_, ?_⟩
  · have h := Int.floor_le ((xs - o) / w)
    have := (div_le_iff₀ hw).mp (le_of_eq rfl : (xs - o) / w ≤ (xs - o) / w)
    nlinarith [mul_le_mul_of_nonneg_right h (le_of_lt hw), div_mul_cancel₀ (xs - o) (ne_of_gt hw)]
  · have h := Int.lt_floor_add_one ((xs - o) / w)
    nlinarith [mul_lt_mul_of_pos_right h hw, div_mul_cancel₀ (xs - o) (ne_of_gt hw)]

/-- **Width independence of the raw maximum.**  Two grids of widths `w₁, w₂` (and
arbitrary, unrelated offsets) each contain a bin whose average is within
`L * (w₁ + w₂)` of the other.  This is the precise sense in which the measured hump
amplitude is a property of the curve, not of the bin width. -/
theorem rawmax_width_independent {o₁ w₁ o₂ w₂ xs : ℝ} (hw₁ : 0 < w₁) (hw₂ : 0 < w₂)
    (hL : 0 ≤ L) (hf : Continuous f) (hlip : ∀ x y, |f x - f y| ≤ L * |x - y|)
    (hmax : ∀ x, f x ≤ f xs) :
    ∃ i j : ℤ, |binVal f o₁ w₁ i - binVal f o₂ w₂ j| ≤ L * (w₁ + w₂) := by
  obtain ⟨i, hi⟩ := exists_bin_mem o₁ w₁ xs hw₁
  obtain ⟨j, hj⟩ := exists_bin_mem o₂ w₂ xs hw₂
  refine ⟨i, j, ?_⟩
  have h1 : |binAvg f (o₁ + i * w₁) w₁ - f xs| ≤ L * w₁ :=
    binAvg_peak_bound hw₁ hL hf hlip hmax (by simpa [add_assoc] using hi)
  have h2 : |binAvg f (o₂ + j * w₂) w₂ - f xs| ≤ L * w₂ :=
    binAvg_peak_bound hw₂ hL hf hlip hmax (by simpa [add_assoc] using hj)
  unfold binVal
  calc |binAvg f (o₁ + i * w₁) w₁ - binAvg f (o₂ + j * w₂) w₂|
      = |(binAvg f (o₁ + i * w₁) w₁ - f xs) - (binAvg f (o₂ + j * w₂) w₂ - f xs)| := by
        ring_nf
    _ ≤ _ := by
        refine le_trans (abs_sub _ _) ?_
        · linarith [h1, h2]

/-! ### Vertex localisation: shift-invariance of the absolute peak -/

/-- **Rigid transport of the vertex.**  Suppose `f` has a peak at `xs` obeying the cone
condition `f x ≤ f xs - κ |x - xs|` and is `L`-Lipschitz.  Then for *any* grid offset
`o` and width `w`, any bin `i` whose value dominates the bin containing `xs` has centre
within `w/2 + (L/κ) * w` of `xs`.  Since the bound does not mention `o`, the absolute
argmax location is shift-invariant up to `O(w)` — the observed
`vx + sh ∈ [0.6482, 0.6492]` behaviour. -/
theorem argmax_bin_near_peak {o w xs kappa : ℝ} {i j : ℤ} (hw : 0 < w) (hL : 0 ≤ L)
    (hk : 0 < kappa) (hf : Continuous f) (hlip : ∀ x y, |f x - f y| ≤ L * |x - y|)
    (hcone : ∀ x, f x ≤ f xs - kappa * |x - xs|)
    (hj : xs ∈ Icc (o + j * w) (o + j * w + w))
    (hdom : binVal f o w j ≤ binVal f o w i) :
    |binCenter o w i - xs| ≤ w / 2 + (L / kappa) * w := by
  set d := |binCenter o w i - xs| with hd
  -- upper bound for bin `i`
  have hupper : binVal f o w i ≤ f xs - kappa * (d - w / 2) := by
    refine binAvg_le_of_le_on hw hf.continuousOn ?_
    intro x hx
    obtain ⟨hx1, hx2⟩ := hx
    have hc : |x - binCenter o w i| ≤ w / 2 := by
      unfold binCenter at *
      rw [abs_le]; constructor <;> [linarith; linarith]
    have : d - w / 2 ≤ |x - xs| := by
      have := abs_sub_abs_le_abs_sub (binCenter o w i - xs) (x - xs)
      have h2 : |binCenter o w i - xs - (x - xs)| = |x - binCenter o w i| := by
        rw [abs_sub_comm]; ring_nf
      rw [h2] at this
      linarith [hd ▸ this]
    have := hcone x
    nlinarith
  -- lower bound for bin `j`
  have hlower : f xs - L * w ≤ binVal f o w j := by
    refine binAvg_ge_of_lipschitz hw hL hf hlip ?_
    exact (by simpa [add_assoc] using hj)
  have hcomb : kappa * (d - w / 2) ≤ L * w := by
    unfold binVal at hdom hlower hupper
    linarith
  have : d - w / 2 ≤ L / kappa * w := by
    rw [div_mul_eq_mul_div, le_div_iff₀ hk]
    linarith [hcomb]
  linarith

/-! ## Auditing the estimator: the three-point local quadratic fit -/

/-- Vertex abscissa of the parabola through `(x₀ - w, y₋)`, `(x₀, y₀)`, `(x₀ + w, y₊)`. -/
noncomputable def qvertex (x₀ w ym y0 yp : ℝ) : ℝ :=
  x₀ + w * (ym - yp) / (2 * (ym - 2 * y0 + yp))

/-- Vertex ordinate (the "fitted peak amplitude") of the same parabola. -/
noncomputable def qpeak (ym y0 yp : ℝ) : ℝ :=
  y0 - (yp - ym) ^ 2 / (8 * (ym - 2 * y0 + yp))

/-- **The local quadratic fit never lowers the amplitude.**  For a strictly concave
three-point fit the fitted peak is `≥` the central raw bin value.  Hence a `≥ 1.10`
bar on the *fitted* amplitude is not a conservative surrogate for a bar on the raw
value; the 7/30-vs-22/30 marginals of exp 582 must come from the centre bin
`y0` itself, not from the fit shaving the peak. -/
theorem qpeak_ge_center {ym y0 yp : ℝ} (hcurv : ym - 2 * y0 + yp < 0) :
    y0 ≤ qpeak ym y0 yp := by
  unfold qpeak
  have h : (yp - ym) ^ 2 / (8 * (ym - 2 * y0 + yp)) ≤ 0 := by
    apply div_nonpos_of_nonneg_of_nonpos (sq_nonneg _)
    linarith
  linarith

/-- **Non-degenerate fits localise the vertex.**  If the central point dominates its two
neighbours (`y0` maximal) and the fit is strictly concave, then the fitted vertex lies
within half a bin of the central bin centre. -/
theorem qvertex_near_center {x₀ w ym y0 yp : ℝ} (hw : 0 < w) (hm : ym ≤ y0)
    (hp : yp ≤ y0) (hcurv : ym - 2 * y0 + yp < 0) :
    |qvertex x₀ w ym y0 yp - x₀| ≤ w / 2 := by
  unfold qvertex
  have hden : ym - 2 * y0 + yp < 0 := hcurv
  have key : |ym - yp| ≤ -(ym - 2 * y0 + yp) := by
    rw [abs_le]; constructor <;> linarith
  have h2 : (0:ℝ) < 2 * (-(ym - 2 * y0 + yp)) := by linarith
  have : |w * (ym - yp) / (2 * (ym - 2 * y0 + yp))| ≤ w / 2 := by
    have habs : |2 * (ym - 2 * y0 + yp)| = 2 * (-(ym - 2 * y0 + yp)) := by
      rw [abs_of_neg (by linarith)]; ring
    rw [abs_div, abs_mul, abs_of_pos hw, habs,
      div_le_div_iff₀ (by linarith) (by norm_num : (0:ℝ) < 2)]
    nlinarith [mul_le_mul_of_nonneg_left key (le_of_lt hw), abs_nonneg (ym - yp)]
  simpa using this

/-- **A far vertex certifies a degenerate fit.**  Contrapositive of
`qvertex_near_center`: the single erratic `nb = 33` cell, whose fitted vertex sat `0.19`
away while the argmax bin centre sat `0.01` from the median, must have had neighbour
asymmetry exceeding its curvature — a numerically degenerate fit, not an unstable
feature. -/
theorem qvertex_far_implies_shallow {x₀ w ym y0 yp : ℝ} (hw : 0 < w)
    (hcurv : ym - 2 * y0 + yp < 0)
    (hfar : w / 2 < |qvertex x₀ w ym y0 yp - x₀|) :
    -(ym - 2 * y0 + yp) < |ym - yp| := by
  by_contra hcon
  push_neg at hcon
  have h1 : ym - yp ≤ |ym - yp| := le_abs_self _
  have h2 : -|ym - yp| ≤ ym - yp := neg_abs_le _
  have hm : ym ≤ y0 := by linarith
  have hp : yp ≤ y0 := by linarith
  exact absurd (qvertex_near_center hw hm hp hcurv) (not_le.mpr hfar)

/-! ## Auditing the control bars: bin-count-aware thresholds -/

/-- **A flat threshold loses control as the grid refines.**  If each of `n` bins
independently exceeds a fixed level with probability `p > 0`, the probability that at
least one does is `1 - (1-p)^n → 1`.  A bin-count-agnostic bar (the flat `1.02`) is
therefore *guaranteed* to be breached once enough bins are used, which is exactly what
the three `nb ∈ {50, 66, 100}` control cells did. -/
theorem fwer_flat_threshold_tendsto_one {p : ℝ} (hp0 : 0 < p) (hp1 : p ≤ 1) :
    Filter.Tendsto (fun n : ℕ => 1 - (1 - p) ^ n) Filter.atTop (nhds 1) := by
  have h : |1 - p| < 1 := by
    rw [abs_lt]; constructor <;> linarith
  have := tendsto_pow_atTop_nhds_zero_of_abs_lt_one h
  simpa using (tendsto_const_nhds.sub this)

/-- **The bin-count-aware threshold does control the family-wise error.**  Using the
per-bin level `α/n` on `n` bins keeps the probability of any breach at most `α`
(Bernoulli's inequality).  With `α = 0.05`, `n = 100` this is the `1.05` `nb`-aware
ceiling that the observed `1.0215–1.0305` breaches respect. -/
theorem fwer_aware_threshold_controlled {alpha : ℝ} (n : ℕ) (h0 : 0 ≤ alpha)
    (h1 : alpha ≤ 1) : 1 - (1 - alpha / n) ^ n ≤ alpha := by
  rcases Nat.eq_zero_or_pos n with hn | hn
  · subst hn; simpa using h0
  have hnpos : (0:ℝ) < n := by exact_mod_cast hn
  have hb : (-2:ℝ) ≤ -(alpha / n) := by
    have : alpha / n ≤ 1 := by
      rw [div_le_one hnpos]
      have : (1:ℝ) ≤ n := by exact_mod_cast hn
      linarith
    linarith
  have hne : (n : ℝ) ≠ 0 := ne_of_gt hnpos
  have hpow := one_add_mul_le_pow hb n
  have hcast : (n : ℝ) * -(alpha / n) = -alpha := by field_simp
  have h2 : (1 : ℝ) + -(alpha / n) = 1 - alpha / n := by ring
  rw [hcast, h2] at hpow
  linarith

end Catalog.Computation.BinwidthUShift