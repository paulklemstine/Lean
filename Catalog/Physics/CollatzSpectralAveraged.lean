import Physics.CollatzTwoStepSpectrum

/-!
# Averaged spectral statistics of the `a n + 1` maps

The pointwise theory developed in `Catalog/Novelty/CollatzSpectral*.lean` and in
`Catalog/Physics/CollatzTwoStepSpectrum.lean` shows that the normalized cutoff
transforms `F a ω N / N` and `F2 a ω N / N` converge to explicit amplitudes, and
that near frequency `0` (and near every even integer) the transforms are of full
size `N`.  Any *pointwise* decay statement is therefore false.

This file replaces pointwise statements by **averaged** ones, in the spirit of an
`L²` theory:

* `abs_L2_F_period_four_sub_two_le` — the finite-`N` mean-square identity with an
  explicit error: `|∫₀⁴ ‖F a ω N / N‖² dω − 2| ≤ 8 · errL2 N`, where
  `errL2 N = (1 + 8π(1 + log N))/N → 0`.
* `abs_L2_F2_period_four_sub_le` — the same at iteration depth two, with limit
  `5/2` instead of `2`.
* `L2_separates_depth` — consequently the *averaged* statistic separates
  iteration depth: eventually
  `∫₀⁴ ‖F2 a ω N/N‖² − ∫₀⁴ ‖F a ω N/N‖² ≥ 1/4` for every odd multiplier.
* `measure_peak_set_le` — a Chebyshev bound: for every threshold `lam > 0` the set
  of frequencies in a period where `‖F a ω N‖ ≥ lam · N` has Lebesgue measure at
  most `(2 + 8 errL2 N)/lam²`.
* `eventually_measure_peak_set_le` — hence, for large `N`, the frequencies where
  the transform attains its trivial size `N` occupy at most half of a period (up
  to `ε`).  This is exactly the kind of statement that is compatible with the
  isolated resonant peaks, unlike a pointwise bound.
-/

namespace CollatzSpectral

open Filter Complex MeasureTheory
open scoped Real Topology

/-! ## Continuity and trivial bounds -/

lemma continuous_F (a : ℕ) (N : ℕ) : Continuous fun ω : ℝ => F a ω N := by
  unfold F
  refine continuous_finset_sum _ (fun k _ => ?_)
  exact continuous_E.comp (continuous_id.mul continuous_const)

lemma continuous_F2 (a : ℕ) (N : ℕ) : Continuous fun ω : ℝ => F2 a ω N := by
  unfold F2
  refine continuous_finset_sum _ (fun k _ => ?_)
  exact continuous_E.comp (continuous_id.mul continuous_const)

lemma continuous_limitAmp (a : ℕ) : Continuous fun ω : ℝ => limitAmp a ω := by
  unfold limitAmp
  exact ((continuous_E.comp (continuous_id.div_const 2)).add
    (continuous_E.comp (continuous_const.mul continuous_id))).div_const 2

lemma continuous_limitAmp2 (a : ℕ) : Continuous fun ω : ℝ => limitAmp2 a ω := by
  unfold limitAmp2
  exact ((continuous_E.comp (continuous_id.div_const 4)).add
    (continuous_const.mul
      (continuous_E.comp ((continuous_const.mul continuous_id).div_const 2)))).div_const 4

lemma norm_F_div_le_one (a : ℕ) (ω : ℝ) {N : ℕ} (hN : 1 ≤ N) : ‖F a ω N / (N : ℂ)‖ ≤ 1 := by
  have hN0 : (0 : ℝ) < N := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hN
  have hsum : ‖F a ω N‖ ≤ N := by
    unfold F
    refine (norm_sum_le _ _).trans ?_
    simp [norm_E]
  rw [norm_div, Complex.norm_natCast, div_le_one hN0]
  exact hsum

lemma norm_F2_div_le_one (a : ℕ) (ω : ℝ) {N : ℕ} (hN : 1 ≤ N) : ‖F2 a ω N / (N : ℂ)‖ ≤ 1 := by
  have hN0 : (0 : ℝ) < N := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hN
  have hsum : ‖F2 a ω N‖ ≤ N := by
    unfold F2
    refine (norm_sum_le _ _).trans ?_
    simp [norm_E]
  rw [norm_div, Complex.norm_natCast, div_le_one hN0]
  exact hsum

lemma norm_limitAmp_le_one (a : ℕ) (ω : ℝ) : ‖limitAmp a ω‖ ≤ 1 := by
  unfold limitAmp
  rw [norm_div, show ‖(2 : ℂ)‖ = 2 by norm_num, div_le_one (by norm_num)]
  refine (norm_add_le _ _).trans ?_
  rw [norm_E, norm_E]
  norm_num

lemma norm_limitAmp2_le_one (a : ℕ) (ω : ℝ) : ‖limitAmp2 a ω‖ ≤ 1 := by
  unfold limitAmp2
  rw [norm_div, show ‖(4 : ℂ)‖ = 4 by norm_num, div_le_one (by norm_num)]
  refine (norm_add_le _ _).trans ?_
  rw [norm_E, norm_mul, norm_E, show ‖(3 : ℂ)‖ = 3 by norm_num]
  norm_num

/-- If two complex numbers of modulus at most `1` are close, so are their squared
moduli. -/
lemma abs_norm_sq_sub_le {x y : ℂ} (hx : ‖x‖ ≤ 1) (hy : ‖y‖ ≤ 1) :
    |‖x‖ ^ 2 - ‖y‖ ^ 2| ≤ 2 * ‖x - y‖ := by
  have hfac : ‖x‖ ^ 2 - ‖y‖ ^ 2 = (‖x‖ - ‖y‖) * (‖x‖ + ‖y‖) := by ring
  have h1 : |‖x‖ - ‖y‖| ≤ ‖x - y‖ := abs_norm_sub_norm_le x y
  have h2 : |‖x‖ + ‖y‖| ≤ 2 := by
    rw [abs_of_nonneg (by positivity)]
    linarith
  rw [hfac, abs_mul]
  calc |‖x‖ - ‖y‖| * |‖x‖ + ‖y‖| ≤ ‖x - y‖ * 2 :=
        mul_le_mul h1 h2 (abs_nonneg _) (norm_nonneg _)
    _ = 2 * ‖x - y‖ := by ring

private lemma freq_bound_aux {x L : ℝ} (hx : |x| ≤ 4) (hL : 0 ≤ L) :
    2 * Real.pi * |x| * L ≤ 8 * Real.pi * L := by
  have h := mul_nonneg (mul_nonneg Real.pi_pos.le hL) (by linarith : (0:ℝ) ≤ 8 - 2 * |x|)
  nlinarith [h]

/-! ## The `L²` error function -/

/-- The `L²` error term over the period `[0,4]`. -/
noncomputable def errL2 (N : ℕ) : ℝ := (1 + 8 * Real.pi * (1 + Real.log N)) / N

lemma tendsto_errL2 : Tendsto errL2 atTop (𝓝 0) := by
  have := tendsto_errorBound 4
  refine this.congr (fun N => ?_)
  unfold errL2
  ring_nf

/-- The two-step `L²` error term. -/
noncomputable def errL2two (N : ℕ) : ℝ := (2 + 8 * Real.pi * (1 + Real.log N)) / N

lemma tendsto_errL2two : Tendsto errL2two atTop (𝓝 0) := by
  have := tendsto_errorBound2 4
  refine this.congr (fun N => ?_)
  unfold errL2two
  ring_nf

/-! ## Finite-`N` mean-square identities -/

/-- **Depth-one mean-square identity with explicit error.** -/
theorem abs_L2_F_period_four_sub_two_le (a : ℕ) {N : ℕ} (hN : 1 ≤ N) :
    |(∫ ω in (0 : ℝ)..4, ‖F a ω N / (N : ℂ)‖ ^ 2) - 2| ≤ 8 * errL2 N := by
  have hcf : Continuous fun ω : ℝ => ‖F a ω N / (N : ℂ)‖ ^ 2 :=
    (((continuous_F a N).div_const _).norm).pow 2
  have hcg : Continuous fun ω : ℝ => ‖limitAmp a ω‖ ^ 2 := ((continuous_limitAmp a).norm).pow 2
  have hsub : (∫ ω in (0 : ℝ)..4, ‖F a ω N / (N : ℂ)‖ ^ 2) - 2
      = ∫ ω in (0 : ℝ)..4, (‖F a ω N / (N : ℂ)‖ ^ 2 - ‖limitAmp a ω‖ ^ 2) := by
    rw [intervalIntegral.integral_sub (hcf.intervalIntegrable _ _) (hcg.intervalIntegrable _ _),
      meanSquare_limitAmp_period_four a]
  have hbound : ∀ ω ∈ Set.uIoc (0 : ℝ) 4,
      ‖‖F a ω N / (N : ℂ)‖ ^ 2 - ‖limitAmp a ω‖ ^ 2‖ ≤ 2 * errL2 N := by
    intro ω hω
    rw [Set.uIoc_of_le (by norm_num : (0:ℝ) ≤ 4)] at hω
    have habs : |ω| ≤ 4 := by
      rw [abs_le]
      exact ⟨by linarith [hω.1], hω.2⟩
    have hlogpos : 0 ≤ 1 + Real.log N := by
      have h1 : (1 : ℝ) ≤ N := by exact_mod_cast hN
      have := Real.log_nonneg h1
      linarith
    have hN0 : (0 : ℝ) < N := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hN
    have hpt : ‖F a ω N / (N : ℂ) - limitAmp a ω‖ ≤ errL2 N := by
      refine (norm_F_div_sub_limitAmp_le a ω hN).trans ?_
      unfold errL2
      rw [div_le_div_iff_of_pos_right hN0]
      linarith [freq_bound_aux habs hlogpos]
    have := abs_norm_sq_sub_le (norm_F_div_le_one a ω hN) (norm_limitAmp_le_one a ω)
    rw [Real.norm_eq_abs]
    linarith
  rw [hsub]
  have := intervalIntegral.norm_integral_le_of_norm_le_const hbound
  rw [Real.norm_eq_abs] at this
  calc |∫ ω in (0 : ℝ)..4, (‖F a ω N / (N : ℂ)‖ ^ 2 - ‖limitAmp a ω‖ ^ 2)|
      ≤ 2 * errL2 N * |(4 : ℝ) - 0| := this
    _ = 8 * errL2 N := by norm_num; ring

/-- **Depth-two mean-square identity with explicit error.** -/
theorem abs_L2_F2_period_four_sub_le {a : ℕ} (ha : a % 2 = 1) {N : ℕ} (hN : 1 ≤ N) :
    |(∫ ω in (0 : ℝ)..4, ‖F2 a ω N / (N : ℂ)‖ ^ 2) - 5 / 2| ≤ 8 * errL2two N := by
  have hcf : Continuous fun ω : ℝ => ‖F2 a ω N / (N : ℂ)‖ ^ 2 :=
    (((continuous_F2 a N).div_const _).norm).pow 2
  have hcg : Continuous fun ω : ℝ => ‖limitAmp2 a ω‖ ^ 2 := ((continuous_limitAmp2 a).norm).pow 2
  have hsub : (∫ ω in (0 : ℝ)..4, ‖F2 a ω N / (N : ℂ)‖ ^ 2) - 5 / 2
      = ∫ ω in (0 : ℝ)..4, (‖F2 a ω N / (N : ℂ)‖ ^ 2 - ‖limitAmp2 a ω‖ ^ 2) := by
    rw [intervalIntegral.integral_sub (hcf.intervalIntegrable _ _) (hcg.intervalIntegrable _ _),
      meanSquare_limitAmp2_period_four a]
  have hbound : ∀ ω ∈ Set.uIoc (0 : ℝ) 4,
      ‖‖F2 a ω N / (N : ℂ)‖ ^ 2 - ‖limitAmp2 a ω‖ ^ 2‖ ≤ 2 * errL2two N := by
    intro ω hω
    rw [Set.uIoc_of_le (by norm_num : (0:ℝ) ≤ 4)] at hω
    have habs : |ω| ≤ 4 := by
      rw [abs_le]
      exact ⟨by linarith [hω.1], hω.2⟩
    have hlogpos : 0 ≤ 1 + Real.log N := by
      have h1 : (1 : ℝ) ≤ N := by exact_mod_cast hN
      have := Real.log_nonneg h1
      linarith
    have hN0 : (0 : ℝ) < N := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hN
    have hpt : ‖F2 a ω N / (N : ℂ) - limitAmp2 a ω‖ ≤ errL2two N := by
      refine (norm_F2_div_sub_limitAmp2_le ha ω hN).trans ?_
      unfold errL2two
      rw [div_le_div_iff_of_pos_right hN0]
      linarith [freq_bound_aux habs hlogpos]
    have := abs_norm_sq_sub_le (norm_F2_div_le_one a ω hN) (norm_limitAmp2_le_one a ω)
    rw [Real.norm_eq_abs]
    linarith
  rw [hsub]
  have := intervalIntegral.norm_integral_le_of_norm_le_const hbound
  rw [Real.norm_eq_abs] at this
  calc |∫ ω in (0 : ℝ)..4, (‖F2 a ω N / (N : ℂ)‖ ^ 2 - ‖limitAmp2 a ω‖ ^ 2)|
      ≤ 2 * errL2two N * |(4 : ℝ) - 0| := this
    _ = 8 * errL2two N := by norm_num; ring

/-- **An averaged statistic that separates iteration depth.**  For every odd
multiplier the depth-two mean-square power eventually exceeds the depth-one power
by at least `1/4`.  Unlike the pointwise resonance structure, this survives
averaging. -/
theorem L2_separates_depth {a : ℕ} (ha : a % 2 = 1) :
    ∀ᶠ N : ℕ in atTop,
      (∫ ω in (0 : ℝ)..4, ‖F a ω N / (N : ℂ)‖ ^ 2) + 1 / 4
        ≤ ∫ ω in (0 : ℝ)..4, ‖F2 a ω N / (N : ℂ)‖ ^ 2 := by
  have hz1 : Tendsto (fun N : ℕ => 8 * errL2 N) atTop (𝓝 0) := by
    simpa using tendsto_errL2.const_mul (8 : ℝ)
  have hz2 : Tendsto (fun N : ℕ => 8 * errL2two N) atTop (𝓝 0) := by
    simpa using tendsto_errL2two.const_mul (8 : ℝ)
  have h1 : ∀ᶠ N : ℕ in atTop, 8 * errL2 N ≤ 1 / 8 :=
    hz1.eventually (eventually_le_nhds (by norm_num))
  have h2 : ∀ᶠ N : ℕ in atTop, 8 * errL2two N ≤ 1 / 8 :=
    hz2.eventually (eventually_le_nhds (by norm_num))
  filter_upwards [h1, h2, eventually_ge_atTop 1] with N hN1 hN2 hN
  have e1 := abs_L2_F_period_four_sub_two_le a hN
  have e2 := abs_L2_F2_period_four_sub_le ha hN
  rw [abs_le] at e1 e2
  linarith [e1.1, e1.2, e2.1, e2.2]

/-! ## A Chebyshev bound on the resonant peaks -/

/-- **Chebyshev bound for the peak set.**  For every threshold `lam > 0`, the set of
frequencies in a period where the transform reaches size `lam · N` has measure at
most `(2 + 8 errL2 N)/lam²`.  The peaks near the even integer frequencies are
therefore confined to a small exceptional set. -/
theorem measure_peak_set_le (a : ℕ) {lam : ℝ} (hlam : 0 < lam) {N : ℕ} (hN : 1 ≤ N) :
    (volume {ω : ℝ | ω ∈ Set.Icc (0 : ℝ) 4 ∧ lam ≤ ‖F a ω N / (N : ℂ)‖}).toReal
      ≤ (2 + 8 * errL2 N) / lam ^ 2 := by
  classical
  set g : ℝ → ℝ := fun ω => ‖F a ω N / (N : ℂ)‖ with hgdef
  have hgc : Continuous g := ((continuous_F a N).div_const _).norm
  set S : Set ℝ := {ω : ℝ | ω ∈ Set.Icc (0 : ℝ) 4 ∧ lam ≤ g ω} with hSdef
  have hSsub : S ⊆ Set.Icc (0 : ℝ) 4 := fun ω hω => hω.1
  have hSmeas : MeasurableSet S :=
    measurableSet_Icc.inter (measurableSet_le measurable_const hgc.measurable)
  have hintIcc : IntegrableOn (fun ω => g ω ^ 2) (Set.Icc (0 : ℝ) 4) volume :=
    (hgc.pow 2).continuousOn.integrableOn_Icc
  have hintS : IntegrableOn (fun ω => g ω ^ 2) S volume := hintIcc.mono_set hSsub
  have hvolfin : volume S ≠ ⊤ := by
    refine ne_top_of_le_ne_top ?_ (measure_mono hSsub)
    simp [Real.volume_Icc]
  -- Chebyshev's inequality on `S`
  have hstep1 : lam ^ 2 * (volume S).toReal ≤ ∫ ω in S, g ω ^ 2 := by
    have hconst : ∫ _ω in S, lam ^ 2 = (volume S).toReal • lam ^ 2 := setIntegral_const _
    have hmono : ∫ _ω in S, lam ^ 2 ≤ ∫ ω in S, g ω ^ 2 := by
      refine setIntegral_mono_on (integrableOn_const hvolfin) hintS hSmeas (fun ω hω => ?_)
      have h1 : lam ≤ g ω := hω.2
      nlinarith [hlam.le, h1]
    rw [hconst, smul_eq_mul, mul_comm] at hmono
    exact hmono
  have hstep2 : ∫ ω in S, g ω ^ 2 ≤ ∫ ω in Set.Icc (0 : ℝ) 4, g ω ^ 2 := by
    refine setIntegral_mono_set hintIcc ?_ (HasSubset.Subset.eventuallyLE hSsub)
    filter_upwards with ω using sq_nonneg (g ω)
  have hstep3 : ∫ ω in Set.Icc (0 : ℝ) 4, g ω ^ 2 = ∫ ω in (0 : ℝ)..4, g ω ^ 2 := by
    rw [intervalIntegral.integral_of_le (by norm_num : (0:ℝ) ≤ 4),
      MeasureTheory.integral_Icc_eq_integral_Ioc]
  have hL2 := abs_L2_F_period_four_sub_two_le a hN
  rw [abs_le] at hL2
  have hupper : ∫ ω in (0 : ℝ)..4, g ω ^ 2 ≤ 2 + 8 * errL2 N := by
    have : (∫ ω in (0 : ℝ)..4, g ω ^ 2) - 2 ≤ 8 * errL2 N := hL2.2
    linarith
  have hfinal : lam ^ 2 * (volume S).toReal ≤ 2 + 8 * errL2 N := by
    calc lam ^ 2 * (volume S).toReal ≤ ∫ ω in S, g ω ^ 2 := hstep1
      _ ≤ ∫ ω in Set.Icc (0 : ℝ) 4, g ω ^ 2 := hstep2
      _ = ∫ ω in (0 : ℝ)..4, g ω ^ 2 := hstep3
      _ ≤ 2 + 8 * errL2 N := hupper
  rw [le_div_iff₀ (by positivity)]
  linarith [hfinal]

/-- **The peaks occupy at most half of a period.**  For large `N` the set of
frequencies at which the transform attains its trivial size `N` has measure at
most `2 + ε` inside the period `[0,4]` of length `4`.  This is the corrected,
averaged replacement of the impossible pointwise decay statement: it is fully
compatible with the isolated resonant peaks at the even integers. -/
theorem eventually_measure_peak_set_le (a : ℕ) {ε : ℝ} (hε : 0 < ε) :
    ∀ᶠ N : ℕ in atTop,
      (volume {ω : ℝ | ω ∈ Set.Icc (0 : ℝ) 4 ∧ 1 ≤ ‖F a ω N / (N : ℂ)‖}).toReal ≤ 2 + ε := by
  have hz1 : Tendsto (fun N : ℕ => 8 * errL2 N) atTop (𝓝 0) := by
    simpa using tendsto_errL2.const_mul (8 : ℝ)
  have h1 : ∀ᶠ N : ℕ in atTop, 8 * errL2 N ≤ ε := hz1.eventually (eventually_le_nhds hε)
  filter_upwards [h1, eventually_ge_atTop 1] with N hN1 hN
  have := measure_peak_set_le a (lam := 1) (by norm_num) hN
  simpa using this.trans (by
    rw [one_pow, div_one]
    linarith)

end CollatzSpectral