/-
# Jittered backoff and the optimal grid ratio

Cycle 2 of the PTX starvation programme.  `Physics.PTXStarvationFloor` and
`Physics.PTXStarvationSpectrum` showed that a dyadic backoff arbiter satisfies the
no-starvation floor `ideal y ≤ service y` and that the worst-case slack is exactly `2`
(approached, never attained).  Two questions remain, and this file answers both.

## Question 1: can randomisation beat the factor `2`?

A *jittered* arbiter shifts the whole backoff ladder by a phase `θ ∈ [0,1)` (in units of
`log ρ`), delivering
```
jitterCeil ρ θ x = ρ ^ (⌈log_ρ x − θ⌉ + θ) .
```
* `self_le_jitterCeil`, `jitterCeil_lt` : the floor and the factor-`ρ` ceiling survive **for
  every phase**.  Randomisation cannot beat the worst case: the constant `2` of
  `ptx_no_starvation` is phase-independent.
* `jitter_log_slack_eq_fract` : the log-slack is exactly `Int.fract (θ − log_ρ x)`, i.e. the
  slack is an equidistributed rotation on the circle `ℝ / log ρ ℤ`.  (Here a number-theoretic
  object — the fractional part — controls a scheduling quantity.)
* `jitter_mean_log_slack` : the phase-averaged log-slack is exactly `1/2`, so
  `jitter_geometric_mean_slack` : the geometric-mean slack of the jittered arbiter is exactly
  `√ρ`, uniformly in the instance.  For the dyadic arbiter this is `√2 ≈ 1.414`, strictly
  better than the worst case `2` (`ptx_dyadic_jitter_gain`).

* `jitter_arithmetic_mean_slack` : the phase-averaged (arithmetic mean) slack is exactly
  `(ρ − 1)/log ρ`, i.e. `1/log 2 ≈ 1.4427` for the dyadic arbiter (`ptx_dyadic_mean_slack`),
  and `ptx_dyadic_mean_between` locates it strictly between `√2` and `2`.

So: the *worst-case* factor `2` is unimprovable, but the *typical* factor is `√2` and the mean
factor is `1/log 2`; all three constants are separated
(`ptx_worst_case_exceeds_typical`, `ptx_dyadic_mean_between`).

## Question 2: why `2`?

Define the *grid cost* `gridCost ρ = ρ / log ρ`: the worst-case slack `ρ` per unit of
logarithmic dynamic range covered by one backoff level.
* `exp_one_le_gridCost` : `e ≤ gridCost ρ` for every `ρ > 1`, with
* `exp_one_lt_gridCost_of_ne` : strict inequality unless `ρ = e`, and
* `gridCost_exp_one` : `gridCost e = e`.
So the *unique* optimal arbiter grid ratio is Euler's number, not `2`.
* `gridCost_four_eq_gridCost_two` : the binary and quaternary arbiters have exactly the same
  cost, and `dyadic_gridCost_lt` : the dyadic arbiter is within `7 %` of the optimum.
-/

import Physics.PTXStarvationSpectrum

namespace Physics.PTX

open MeasureTheory intervalIntegral

/-! ## 0. Two arithmetic-analytic lemmas -/

/-- The ceiling defect equals the fractional part of the negative: `⌈x⌉ − x = fract (−x)`. -/
lemma ceil_sub_self_eq_fract_neg (x : ℝ) : (⌈x⌉ : ℝ) - x = Int.fract (-x) := by
  rcases eq_or_ne (Int.fract x) 0 with h | h
  · have hx : x = (⌊x⌋ : ℝ) := by
      have hf : Int.fract x = x - (⌊x⌋ : ℝ) := rfl
      rw [h] at hf; linarith
    rw [hx, Int.ceil_intCast, ← Int.cast_neg, Int.fract_intCast]
    ring
  · rw [Int.ceil_sub_self_eq h, Int.fract_neg h]

lemma integral_fract_zero_one : ∫ x in (0:ℝ)..1, Int.fract x = 1 / 2 := by
  have hae : ∀ᵐ x : ℝ ∂volume, x ∈ Set.uIoc (0:ℝ) 1 → Int.fract x = x := by
    filter_upwards [compl_mem_ae_iff.2 (measure_singleton (1:ℝ))] with x hx hmem
    rw [Set.uIoc_of_le (by norm_num)] at hmem
    have hlt : x < 1 := lt_of_le_of_ne hmem.2 (by simpa using hx)
    exact Int.fract_eq_self.2 ⟨le_of_lt hmem.1, hlt⟩
  rw [integral_congr_ae hae, integral_id]
  norm_num

/-- The mean of the fractional part over any interval of unit length is `1/2`. -/
lemma integral_fract_unit (a : ℝ) : ∫ x in a..(a + 1), Int.fract x = 1 / 2 := by
  rw [(Int.fract_periodic ℝ).intervalIntegral_add_eq a 0, zero_add, integral_fract_zero_one]

/-! ## 1. The jittered arbiter -/

/-- The jittered backoff window: the ladder `ρ^ℤ` shifted by the phase `θ`. -/
noncomputable def jitterCeil (rho theta x : ℝ) : ℝ :=
  rho ^ (((⌈Real.logb rho x - theta⌉ : ℤ) : ℝ) + theta)

lemma jitterCeil_pos {rho theta x : ℝ} (hrho : 1 < rho) : 0 < jitterCeil rho theta x :=
  Real.rpow_pos_of_pos (lt_trans zero_lt_one hrho) _

/-- **The floor is phase-independent.**  Whatever the jitter phase, the delivered window covers
the request. -/
lemma self_le_jitterCeil {rho theta x : ℝ} (hrho : 1 < rho) (hx : 0 < x) :
    x ≤ jitterCeil rho theta x := by
  have h0 : (0 : ℝ) < rho := lt_trans zero_lt_one hrho
  have hlog : rho ^ (Real.logb rho x) = x := Real.rpow_logb h0 (ne_of_gt hrho) hx
  have he : Real.logb rho x ≤ ((⌈Real.logb rho x - theta⌉ : ℤ) : ℝ) + theta := by
    have := Int.le_ceil (Real.logb rho x - theta)
    linarith
  calc x = rho ^ (Real.logb rho x) := hlog.symm
    _ ≤ rho ^ (((⌈Real.logb rho x - theta⌉ : ℤ) : ℝ) + theta) :=
        Real.rpow_le_rpow_of_exponent_le (le_of_lt hrho) he
    _ = jitterCeil rho theta x := rfl

/-- **The factor-`ρ` ceiling is phase-independent.**  Randomising the ladder cannot improve the
worst-case slack. -/
lemma jitterCeil_lt {rho theta x : ℝ} (hrho : 1 < rho) (hx : 0 < x) :
    jitterCeil rho theta x < rho * x := by
  have h0 : (0 : ℝ) < rho := lt_trans zero_lt_one hrho
  have hlog : rho ^ (Real.logb rho x) = x := Real.rpow_logb h0 (ne_of_gt hrho) hx
  have he : ((⌈Real.logb rho x - theta⌉ : ℤ) : ℝ) + theta < Real.logb rho x + 1 := by
    have := Int.ceil_lt_add_one (Real.logb rho x - theta)
    linarith
  calc jitterCeil rho theta x = rho ^ (((⌈Real.logb rho x - theta⌉ : ℤ) : ℝ) + theta) := rfl
    _ < rho ^ (Real.logb rho x + 1) := (Real.rpow_lt_rpow_left_iff hrho).2 he
    _ = rho ^ (Real.logb rho x) * rho := by rw [Real.rpow_add h0, Real.rpow_one]
    _ = rho * x := by rw [hlog]; ring

/-- **The log-slack is a circle rotation.**  In units of `log ρ`, the slack of the jittered
arbiter is the fractional part of `θ − log_ρ x`. -/
theorem jitter_log_slack_eq_fract {rho theta x : ℝ} (hrho : 1 < rho) (hx : 0 < x) :
    Real.logb rho (jitterCeil rho theta x / x) = Int.fract (theta - Real.logb rho x) := by
  have h0 : (0 : ℝ) < rho := lt_trans zero_lt_one hrho
  have hne : rho ≠ 1 := ne_of_gt hrho
  have hlog : rho ^ (Real.logb rho x) = x := Real.rpow_logb h0 hne hx
  have hdiv : jitterCeil rho theta x / x
      = rho ^ ((((⌈Real.logb rho x - theta⌉ : ℤ) : ℝ) + theta) - Real.logb rho x) := by
    rw [Real.rpow_sub h0, jitterCeil, hlog]
  rw [hdiv, Real.logb_rpow h0 hne]
  have hkey := ceil_sub_self_eq_fract_neg (Real.logb rho x - theta)
  have hneg : -(Real.logb rho x - theta) = theta - Real.logb rho x := by ring
  rw [hneg] at hkey
  linarith

/-- **The phase-averaged log-slack is exactly one half.** -/
theorem jitter_mean_log_slack {rho x : ℝ} (hrho : 1 < rho) (hx : 0 < x) :
    ∫ theta in (0:ℝ)..1, Real.logb rho (jitterCeil rho theta x / x) = 1 / 2 := by
  have hcongr : ∀ theta ∈ Set.uIcc (0:ℝ) 1,
      Real.logb rho (jitterCeil rho theta x / x) = Int.fract (theta - Real.logb rho x) :=
    fun theta _ => jitter_log_slack_eq_fract hrho hx
  rw [integral_congr hcongr,
    intervalIntegral.integral_comp_sub_right (fun u => Int.fract u) (Real.logb rho x),
    zero_sub, show (1 : ℝ) - Real.logb rho x = -Real.logb rho x + 1 by ring,
    integral_fract_unit]

/-- The phase-averaged natural log-slack is `(log ρ)/2`. -/
theorem jitter_mean_log_slack_nat {rho x : ℝ} (hrho : 1 < rho) (hx : 0 < x) :
    ∫ theta in (0:ℝ)..1, Real.log (jitterCeil rho theta x / x) = Real.log rho / 2 := by
  have h0 : (0 : ℝ) < rho := lt_trans zero_lt_one hrho
  have hlogpos : 0 < Real.log rho := Real.log_pos hrho
  have hcongr : ∀ theta ∈ Set.uIcc (0:ℝ) 1,
      Real.log (jitterCeil rho theta x / x)
        = Real.logb rho (jitterCeil rho theta x / x) * Real.log rho := by
    intro theta _
    rw [Real.logb, div_mul_cancel₀]
    exact ne_of_gt hlogpos
  rw [integral_congr hcongr, intervalIntegral.integral_mul_const,
    jitter_mean_log_slack hrho hx]
  ring

/-- **The geometric-mean slack of the jittered arbiter is exactly `√ρ`.**  It does not depend on
the instance at all. -/
theorem jitter_geometric_mean_slack {rho x : ℝ} (hrho : 1 < rho) (hx : 0 < x) :
    Real.exp (∫ theta in (0:ℝ)..1, Real.log (jitterCeil rho theta x / x)) = Real.sqrt rho := by
  have h0 : (0 : ℝ) < rho := lt_trans zero_lt_one hrho
  rw [jitter_mean_log_slack_nat hrho hx, Real.sqrt_eq_rpow, Real.rpow_def_of_pos h0]
  ring_nf

/-- Averaging a function of the fractional part over a unit interval is the same as averaging it
over `[0,1]`. -/
lemma integral_comp_fract_unit (g : ℝ → ℝ) (a : ℝ) :
    ∫ x in a..(a + 1), g (Int.fract x) = ∫ x in (0:ℝ)..1, g x := by
  have hper : Function.Periodic (fun x => g (Int.fract x)) 1 := by
    intro x; simp [Int.fract_add_one]
  rw [hper.intervalIntegral_add_eq a 0, zero_add]
  have hae : ∀ᵐ x : ℝ ∂volume, x ∈ Set.uIoc (0:ℝ) 1 → g (Int.fract x) = g x := by
    filter_upwards [compl_mem_ae_iff.2 (measure_singleton (1:ℝ))] with x hx hmem
    rw [Set.uIoc_of_le (by norm_num)] at hmem
    have hlt : x < 1 := lt_of_le_of_ne hmem.2 (by simpa using hx)
    rw [Int.fract_eq_self.2 ⟨le_of_lt hmem.1, hlt⟩]
  exact integral_congr_ae hae

/-- `∫₀¹ ρ^s ds = (ρ − 1)/log ρ`. -/
lemma integral_rpow_const {rho : ℝ} (hrho : 1 < rho) :
    ∫ s in (0:ℝ)..1, rho ^ s = (rho - 1) / Real.log rho := by
  have h0 : (0:ℝ) < rho := lt_trans zero_lt_one hrho
  have hlog : Real.log rho ≠ 0 := ne_of_gt (Real.log_pos hrho)
  have hcongr : ∀ s ∈ Set.uIcc (0:ℝ) 1, rho ^ s = Real.exp (Real.log rho * s) := by
    intro s _; rw [Real.rpow_def_of_pos h0]
  rw [integral_congr hcongr, intervalIntegral.integral_comp_mul_left Real.exp hlog, integral_exp,
    mul_one, mul_zero, Real.exp_zero, Real.exp_log h0, smul_eq_mul]
  field_simp

/-- **The phase-averaged (arithmetic mean) slack is `(ρ − 1)/log ρ`.**  For the dyadic arbiter
this is `1/log 2 ≈ 1.4427`, again far below the worst case `2`. -/
theorem jitter_arithmetic_mean_slack {rho x : ℝ} (hrho : 1 < rho) (hx : 0 < x) :
    ∫ theta in (0:ℝ)..1, jitterCeil rho theta x / x = (rho - 1) / Real.log rho := by
  have h0 : (0:ℝ) < rho := lt_trans zero_lt_one hrho
  have hcongr : ∀ theta ∈ Set.uIcc (0:ℝ) 1,
      jitterCeil rho theta x / x = rho ^ (Int.fract (theta - Real.logb rho x)) := by
    intro theta _
    have hpos : 0 < jitterCeil rho theta x / x := div_pos (jitterCeil_pos hrho) hx
    rw [← jitter_log_slack_eq_fract hrho hx, Real.rpow_logb h0 (ne_of_gt hrho) hpos]
  rw [integral_congr hcongr,
    intervalIntegral.integral_comp_sub_right (fun u => rho ^ (Int.fract u)) (Real.logb rho x),
    zero_sub, show (1 : ℝ) - Real.logb rho x = -Real.logb rho x + 1 by ring,
    integral_comp_fract_unit (fun u => rho ^ u), integral_rpow_const hrho]

/-- The dyadic mean slack is exactly `1 / log 2`. -/
theorem ptx_dyadic_mean_slack {x : ℝ} (hx : 0 < x) :
    ∫ theta in (0:ℝ)..1, jitterCeil 2 theta x / x = 1 / Real.log 2 := by
  rw [jitter_arithmetic_mean_slack (by norm_num) hx]
  norm_num

/-! ## 2. Worst case versus typical case for the dyadic arbiter -/

lemma sqrt_two_lt_two : Real.sqrt 2 < 2 := by
  nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2), Real.sqrt_nonneg 2]

/-- For the dyadic arbiter the geometric-mean slack `√2` is strictly below the worst-case slack
`2`: jitter does not change the guarantee, but it does change the typical behaviour. -/
theorem ptx_dyadic_jitter_gain {x : ℝ} (hx : 0 < x) :
    Real.exp (∫ theta in (0:ℝ)..1, Real.log (jitterCeil 2 theta x / x)) < 2 := by
  rw [jitter_geometric_mean_slack (by norm_num) hx]
  exact sqrt_two_lt_two

/-- The worst-case slack of a PTX arbiter with grid ratio `ρ` strictly exceeds its typical
(geometric-mean) slack `√ρ`. -/
theorem ptx_worst_case_exceeds_typical {rho : ℝ} (hrho : 1 < rho) : Real.sqrt rho < rho := by
  have h0 : (0:ℝ) < rho := lt_trans zero_lt_one hrho
  have hs : Real.sqrt rho * Real.sqrt rho = rho := Real.mul_self_sqrt (le_of_lt h0)
  have hspos : 0 < Real.sqrt rho := Real.sqrt_pos.2 h0
  nlinarith [hs, hspos, hrho]

/-- The jittered arbiter applied to a PTX instance. -/
noncomputable def serviceJitter {ι : Type*} (rho theta : ℝ) (I : PTXInstance ι) (y : ι) : ℝ :=
  jitterCeil rho theta (ideal I y)

/-- **No starvation for the jittered arbiter**, at every phase: the floor
`γ d y / (β log(1/p y) + M + γ − r y)` is untouched by randomisation. -/
theorem ptx_jitter_no_starvation {ι : Type*} {rho theta : ℝ} (hrho : 1 < rho)
    (I : PTXInstance ι) (y : ι) : ideal I y ≤ serviceJitter rho theta I y :=
  self_le_jitterCeil hrho (ideal_pos I y)

/-- **The factor `2` is not an artefact of determinism**: the dyadic jittered arbiter still
overshoots by less than `2`, and by `ptx_two_optimal_ceiling_iff` no smaller constant works. -/
theorem ptx_jitter_lt_two {ι : Type*} {theta : ℝ} (I : PTXInstance ι) (y : ι) :
    serviceJitter 2 theta I y < 2 * ideal I y :=
  jitterCeil_lt (by norm_num) (ideal_pos I y)

/-- The typical slack of the jittered dyadic arbiter on a PTX instance is exactly `√2`. -/
theorem ptx_jitter_typical_slack {ι : Type*} (I : PTXInstance ι) (y : ι) :
    Real.exp (∫ theta in (0:ℝ)..1, Real.log (serviceJitter 2 theta I y / ideal I y))
      = Real.sqrt 2 :=
  jitter_geometric_mean_slack (by norm_num) (ideal_pos I y)

/-! ## 2b. The mean/typical/worst-case hierarchy for every grid ratio -/

/-- `2 log u < u − 1/u` for `u > 1`: the derivative of `u − 1/u − 2 log u` is the perfect square
`(1 − 1/u)²`. -/
theorem two_log_lt_sub_inv {u : ℝ} (hu : 1 < u) : 2 * Real.log u < u - 1 / u := by
  have key : StrictMonoOn (fun t : ℝ => t - 1 / t - 2 * Real.log t) (Set.Ici 1) := by
    apply strictMonoOn_of_deriv_pos (convex_Ici 1)
    · apply ContinuousOn.sub
      · apply ContinuousOn.sub continuousOn_id
        exact ContinuousOn.div continuousOn_const continuousOn_id (fun t ht => by
          simp only [Set.mem_Ici] at ht; intro h; rw [h] at ht; norm_num at ht)
      · apply ContinuousOn.mul continuousOn_const
        exact Real.continuousOn_log.mono (fun t ht => by
          simp only [Set.mem_Ici] at ht
          simp only [Set.mem_compl_iff, Set.mem_singleton_iff]
          intro h; rw [h] at ht; norm_num at ht)
    · intro t ht
      rw [interior_Ici] at ht
      have ht1 : 1 < t := ht
      have ht0 : (0:ℝ) < t := lt_trans zero_lt_one ht1
      have hd : HasDerivAt (fun t : ℝ => t - 1 / t - 2 * Real.log t)
          (1 - (-(1 / t ^ 2)) - 2 * (1 / t)) t := by
        have h1 : HasDerivAt (fun t : ℝ => t) 1 t := hasDerivAt_id t
        have h2 : HasDerivAt (fun t : ℝ => 1 / t) (-(1 / t ^ 2)) t := by
          simpa using hasDerivAt_inv (ne_of_gt ht0)
        have h3 : HasDerivAt (fun t : ℝ => Real.log t) (1 / t) t := by
          simpa using Real.hasDerivAt_log (ne_of_gt ht0)
        exact (h1.sub h2).sub (h3.const_mul 2)
      rw [hd.deriv]
      have heq : 1 - (-(1 / t ^ 2)) - 2 * (1 / t) = (1 - 1 / t) ^ 2 := by field_simp; ring
      rw [heq]
      have hlt : 1 / t < 1 := by rw [div_lt_one ht0]; exact ht1
      have : 0 < 1 - 1 / t := by linarith
      positivity
  have h := key (le_refl (1:ℝ)) (le_of_lt hu) hu
  simp only [Real.log_one] at h
  norm_num at h
  rw [one_div]
  exact h

/-- **The typical slack is strictly below the mean slack, for every grid ratio.**  This is the
strict AM–GM gap `√ρ < (ρ − 1)/log ρ`. -/
theorem sqrt_lt_mean_slack {rho : ℝ} (hrho : 1 < rho) :
    Real.sqrt rho < (rho - 1) / Real.log rho := by
  have h0 : (0:ℝ) < rho := lt_trans zero_lt_one hrho
  have hs : 1 < Real.sqrt rho := by
    rw [show (1:ℝ) = Real.sqrt 1 by simp]
    exact Real.sqrt_lt_sqrt (by norm_num) hrho
  have hsq : Real.sqrt rho * Real.sqrt rho = rho := Real.mul_self_sqrt (le_of_lt h0)
  have hspos : 0 < Real.sqrt rho := lt_trans zero_lt_one hs
  have hlogpos : 0 < Real.log rho := Real.log_pos hrho
  have hlog : 2 * Real.log (Real.sqrt rho) = Real.log rho := by
    rw [show (2:ℝ) * Real.log (Real.sqrt rho)
        = Real.log (Real.sqrt rho) + Real.log (Real.sqrt rho) by ring,
      ← Real.log_mul (ne_of_gt hspos) (ne_of_gt hspos), hsq]
  have hkey := two_log_lt_sub_inv hs
  rw [hlog] at hkey
  rw [lt_div_iff₀ hlogpos]
  have hinv : Real.sqrt rho - 1 / Real.sqrt rho = (rho - 1) / Real.sqrt rho := by
    field_simp
    nlinarith [hsq]
  rw [hinv, lt_div_iff₀ hspos] at hkey
  nlinarith [hkey, hsq, hspos, hlogpos]

/-- The mean slack is strictly below the worst case. -/
theorem mean_slack_lt_worst_case {rho : ℝ} (hrho : 1 < rho) :
    (rho - 1) / Real.log rho < rho := by
  have h0 : (0:ℝ) < rho := lt_trans zero_lt_one hrho
  have hlogpos : 0 < Real.log rho := Real.log_pos hrho
  have hinv : Real.log (1 / rho) < 1 / rho - 1 :=
    Real.log_lt_sub_one_of_pos (by positivity) (by
      intro h
      rw [div_eq_one_iff_eq (ne_of_gt h0)] at h
      linarith)
  rw [Real.log_div one_ne_zero (ne_of_gt h0), Real.log_one] at hinv
  rw [div_lt_iff₀ hlogpos]
  have hmul : rho * (1 / rho) = 1 := by field_simp
  nlinarith [hinv, hmul]

/-- **The three constants of a grid-`ρ` arbiter are strictly ordered**: typical `√ρ`, mean
`(ρ−1)/log ρ`, worst case `ρ`. -/
theorem ptx_slack_constant_hierarchy {rho : ℝ} (hrho : 1 < rho) :
    Real.sqrt rho < (rho - 1) / Real.log rho ∧ (rho - 1) / Real.log rho < rho :=
  ⟨sqrt_lt_mean_slack hrho, mean_slack_lt_worst_case hrho⟩

/-! ## 3. The optimal grid ratio is `e`, and `2` is within 7 % of it -/

/-- Worst-case slack per unit of logarithmic dynamic range covered by one backoff level. -/
noncomputable def gridCost (rho : ℝ) : ℝ := rho / Real.log rho

/-- **Euler's number is a lower bound for the grid cost.** -/
theorem exp_one_le_gridCost {rho : ℝ} (hrho : 1 < rho) : Real.exp 1 ≤ gridCost rho := by
  have hlogpos : 0 < Real.log rho := Real.log_pos hrho
  have he : (0:ℝ) < Real.exp 1 := Real.exp_pos 1
  have hkey : Real.log rho ≤ rho / Real.exp 1 := by
    have hpos : 0 < rho / Real.exp 1 := div_pos (lt_trans zero_lt_one hrho) he
    have h := Real.log_le_sub_one_of_pos hpos
    rw [Real.log_div (by positivity) (ne_of_gt he), Real.log_exp] at h
    linarith
  rw [gridCost, le_div_iff₀ hlogpos]
  calc Real.exp 1 * Real.log rho ≤ Real.exp 1 * (rho / Real.exp 1) := by
        exact mul_le_mul_of_nonneg_left hkey (le_of_lt he)
    _ = rho := by field_simp

/-- **`e` attains the bound**, so the optimal grid ratio is exactly Euler's number. -/
theorem gridCost_exp_one : gridCost (Real.exp 1) = Real.exp 1 := by
  rw [gridCost, Real.log_exp, div_one]

/-- **Uniqueness of the optimum.**  Any grid ratio other than `e` is strictly worse. -/
theorem exp_one_lt_gridCost_of_ne {rho : ℝ} (hrho : 1 < rho) (hne : rho ≠ Real.exp 1) :
    Real.exp 1 < gridCost rho := by
  have hlogpos : 0 < Real.log rho := Real.log_pos hrho
  have he : (0:ℝ) < Real.exp 1 := Real.exp_pos 1
  have hpos : 0 < rho / Real.exp 1 := div_pos (lt_trans zero_lt_one hrho) he
  have hne1 : rho / Real.exp 1 ≠ 1 := by
    intro h
    exact hne (by field_simp at h; exact h)
  have h := Real.log_lt_sub_one_of_pos hpos hne1
  rw [Real.log_div (by positivity) (ne_of_gt he), Real.log_exp] at h
  have hkey : Real.log rho < rho / Real.exp 1 := by linarith
  rw [gridCost, lt_div_iff₀ hlogpos]
  calc Real.exp 1 * Real.log rho < Real.exp 1 * (rho / Real.exp 1) := by
        exact mul_lt_mul_of_pos_left hkey he
    _ = rho := by field_simp

/-- **Binary and quaternary arbiters cost exactly the same**: `4/log 4 = 2/log 2`.  The grid
cost is invariant under squaring the ratio only at these two points, which is why doubling the
window size is a fixed point of the design trade-off. -/
theorem gridCost_four_eq_gridCost_two : gridCost 4 = gridCost 2 := by
  have h4 : Real.log 4 = 2 * Real.log 2 := by
    rw [show (4:ℝ) = 2 ^ 2 by norm_num, Real.log_pow]
    push_cast; ring
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  rw [gridCost, gridCost, h4]
  field_simp
  ring

/-- **The dyadic arbiter is within 7 % of the optimal grid.** -/
theorem dyadic_gridCost_lt : gridCost 2 < 1.07 * Real.exp 1 := by
  have hlog : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hlogpos : 0 < Real.log 2 := by linarith
  have hexp : (2.7182818283 : ℝ) < Real.exp 1 := Real.exp_one_gt_d9
  rw [gridCost, div_lt_iff₀ hlogpos]
  nlinarith [hlog, hexp]

/-- Putting the two halves together: the dyadic arbiter has the unimprovable worst-case slack
`2`, a typical slack `√2`, and a grid cost within `7 %` of the theoretical optimum `e`. -/
theorem ptx_dyadic_verdict :
    Real.exp 1 < gridCost 2 ∧ gridCost 2 < 1.07 * Real.exp 1 ∧ Real.sqrt 2 < 2 := by
  refine ⟨exp_one_lt_gridCost_of_ne (by norm_num) ?_, dyadic_gridCost_lt, ?_⟩
  · intro h
    have : (2.7182818283 : ℝ) < Real.exp 1 := Real.exp_one_gt_d9
    rw [← h] at this
    norm_num at this
  · exact sqrt_two_lt_two

/-- Arithmetic versus geometric mean for the dyadic arbiter: `√2 < 1/log 2 < 2`.  The jittered
arbiter's average overshoot sits strictly between its typical (geometric) overshoot and the
worst case. -/
theorem ptx_dyadic_mean_between : Real.sqrt 2 < 1 / Real.log 2 ∧ 1 / Real.log 2 < 2 := by
  have h1 : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  have h2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h1' : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  constructor
  · have h3 : Real.sqrt 2 * Real.sqrt 2 = 2 := Real.mul_self_sqrt (by norm_num)
    have h4 : Real.sqrt 2 < 1.4143 := by nlinarith [Real.sqrt_nonneg 2]
    rw [lt_div_iff₀ h2]
    nlinarith
  · rw [div_lt_iff₀ h2]
    nlinarith

end Physics.PTX