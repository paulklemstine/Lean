import Novelty.BekensteinHawkingUniversality

/-!
# Horizon thermodynamics: the differential first law and the Hagedorn transition

Building on the exact microstate count of `Novelty.BekensteinHawkingAreaLaw`,
this file establishes two genuinely thermodynamic statements about the quantum
isolated horizon.

* `hStates_ratio_tendsto` : the microstate count grows by a factor tending to
  `2 + √2` per area quantum;
* `entropy_increment_tendsto` : the *differential* form of the area law,
  `S(A+1) - S(A) → log (2+√2)`.  This is strictly stronger than the Cesàro-type
  statement `S(A)/A → log (2+√2)` of `entropy_area_law`;
* `first_law_of_horizon_thermodynamics` : with the Bekenstein–Hawking
  normalisation `γ = 4 log (2+√2)` of the area quantum, the entropy response to
  an area increment tends to `1/4`, i.e. `dS/dA = 1/4`;
* `partition_function_summable_iff` : the canonical partition function
  `Z(x) = ∑ W(A) x^A` (with `x = e^{-β}` per area quantum) converges **iff**
  `x < 1/(2+√2)`, i.e. iff the temperature is below
  `T_H = 1 / log (2+√2)`.  The horizon gas therefore has a Hagedorn-type
  limiting temperature, exactly at the point where the microcanonical entropy
  density is saturated;
* `partition_function_closed_form` : below that point the partition function is
  the explicit rational function `(1-x)² / (2x² - 4x + 1)`, so the Hagedorn
  transition is a simple pole at `x = 1/(2+√2)`.
-/

open Finset

namespace BekensteinHawking

/-- The upper bound `W(n) ≤ (2+√2)^n` in the form valid for *all* areas. -/
lemma hStates_le_pow (n : ℕ) : (hStates n : ℝ) ≤ growth ^ n := by
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp
  · exact (hStates_bounds n hn).2

lemma hStates_pos (n : ℕ) : 0 < (hStates n : ℝ) := by
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp
  · exact lt_of_lt_of_le (div_pos (pow_pos growth_pos n) (by norm_num)) (hStates_bounds n hn).1

/-! ## The differential area law -/

/-- The ratio of successive microstate counts converges to the growth rate. -/
theorem hStates_ratio_tendsto :
    Filter.Tendsto (fun n : ℕ => (hStates (n + 1) : ℝ) / (hStates n : ℝ))
      Filter.atTop (nhds growth) := by
  set a : ℝ := 1 + Real.sqrt 2 with ha
  set b : ℝ := 1 - Real.sqrt 2 with hb
  set q : ℝ := growth' / growth with hq
  have hgpos : (0:ℝ) < growth := growth_pos
  have hg'pos : (0:ℝ) < growth' := growth'_pos
  have hapos : 0 < a := by rw [ha]; positivity
  have hq0 : 0 ≤ q := by rw [hq]; positivity
  have hq1 : q < 1 := by
    rw [hq, div_lt_one hgpos]
    unfold growth growth'
    nlinarith [Real.sqrt_pos.mpr (show (0:ℝ) < 2 by norm_num)]
  have hqpow : Filter.Tendsto (fun n : ℕ => q ^ n) Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one hq0 hq1
  have hnum : Filter.Tendsto (fun n : ℕ => a * growth + b * growth' * q ^ n)
      Filter.atTop (nhds (a * growth)) := by
    have := (hqpow.const_mul (b * growth')).const_add (a * growth)
    simpa using this
  have hden : Filter.Tendsto (fun n : ℕ => a + b * q ^ n) Filter.atTop (nhds a) := by
    have := (hqpow.const_mul b).const_add a
    simpa using this
  have hdiv : Filter.Tendsto (fun n : ℕ => (a * growth + b * growth' * q ^ n) / (a + b * q ^ n))
      Filter.atTop (nhds ((a * growth) / a)) := hnum.div hden (ne_of_gt hapos)
  have hval : (a * growth) / a = growth := by field_simp
  rw [hval] at hdiv
  refine hdiv.congr' ?_
  filter_upwards [Filter.eventually_ge_atTop 1] with n hn
  have hW := hStates_closed_form n hn
  have hW1 := hStates_closed_form (n + 1) (by omega)
  have hWpos := hStates_pos n
  have hqn : q ^ n * growth ^ n = growth' ^ n := by
    rw [hq, div_pow, div_mul_cancel₀]
    positivity
  have hnum' : 4 * (hStates (n + 1) : ℝ) = growth ^ n * (a * growth + b * growth' * q ^ n) := by
    rw [hW1, pow_succ growth n, pow_succ growth' n, ← hqn]
    ring
  have hden' : 4 * (hStates n : ℝ) = growth ^ n * (a + b * q ^ n) := by
    rw [hW]
    have : growth' ^ n = q ^ n * growth ^ n := hqn.symm
    rw [this]; ring
  have hgn : (0:ℝ) < growth ^ n := pow_pos hgpos n
  have hdennz : a + b * q ^ n ≠ 0 := by
    have : growth ^ n * (a + b * q ^ n) = 4 * (hStates n : ℝ) := hden'.symm
    intro hzero
    rw [hzero, mul_zero] at this
    linarith
  field_simp
  have h4 : (4:ℝ) * hStates (n + 1) * (a + b * q ^ n)
      = (4:ℝ) * hStates n * (a * growth + b * growth' * q ^ n) := by
    rw [hnum', hden']; ring
  linarith

/-- **Differential area law.**  The entropy gained by adding one area quantum
converges to the entropy density.  (This refines `entropy_area_law`, which only
controls the Cesàro averages.) -/
theorem entropy_increment_tendsto :
    Filter.Tendsto (fun n : ℕ => entropy (n + 1) - entropy n) Filter.atTop
      (nhds entropyDensity) := by
  have hlog : Filter.Tendsto (fun n : ℕ => Real.log ((hStates (n + 1) : ℝ) / (hStates n : ℝ)))
      Filter.atTop (nhds (Real.log growth)) :=
    (Real.continuousAt_log (ne_of_gt growth_pos)).tendsto.comp hStates_ratio_tendsto
  refine hlog.congr ?_
  intro n
  rw [Real.log_div (ne_of_gt (hStates_pos (n + 1))) (ne_of_gt (hStates_pos n))]
  rfl

/-- **First law with the Bekenstein–Hawking normalisation.**  If one area
quantum carries physical area `γ = 4 log (2+√2)`, then the entropy response of
the horizon to an area increment converges to `1/4`: `dS/dA = 1/4`. -/
theorem first_law_of_horizon_thermodynamics :
    Filter.Tendsto (fun n : ℕ => (entropy (n + 1) - entropy n) / (4 * entropyDensity))
      Filter.atTop (nhds (1 / 4)) := by
  have hD : 0 < entropyDensity := entropyDensity_pos
  have h := entropy_increment_tendsto.div_const (4 * entropyDensity)
  have hval : entropyDensity / (4 * entropyDensity) = 1 / 4 := by
    field_simp
  rwa [hval] at h

/-! ## The canonical ensemble and its Hagedorn temperature -/

/-- **Hagedorn transition.**  The canonical partition function of the quantum
horizon converges exactly below the critical fugacity `1/(2+√2)`; at and above
it — i.e. at and above the temperature `1 / log (2+√2)` — the canonical
ensemble does not exist. -/
theorem partition_function_summable_iff (x : ℝ) (hx : 0 ≤ x) :
    Summable (fun n : ℕ => (hStates n : ℝ) * x ^ n) ↔ x < growth⁻¹ := by
  have hgpos : (0:ℝ) < growth := growth_pos
  constructor
  · intro hsum
    by_contra hcon
    push_neg at hcon
    have hterm : Filter.Tendsto (fun n : ℕ => (hStates n : ℝ) * x ^ n) Filter.atTop (nhds 0) :=
      hsum.tendsto_atTop_zero
    have hhalf : ∀ n : ℕ, 1 ≤ n → (1:ℝ)/2 ≤ (hStates n : ℝ) * x ^ n := by
      intro n hn
      have h1 := (hStates_bounds n hn).1
      have h2 : (growth⁻¹) ^ n ≤ x ^ n := pow_le_pow_left₀ (by positivity) hcon n
      have h3 : growth ^ n * (growth⁻¹) ^ n = 1 := by
        rw [← mul_pow, mul_inv_cancel₀ (ne_of_gt hgpos), one_pow]
      have hstep : (growth ^ n / 2) * (growth⁻¹) ^ n = 1 / 2 := by
        rw [div_mul_eq_mul_div, h3]
      calc (1:ℝ)/2 = (growth ^ n / 2) * (growth⁻¹) ^ n := hstep.symm
        _ ≤ (hStates n : ℝ) * (growth⁻¹) ^ n := by
            have : (0:ℝ) < (growth⁻¹) ^ n := by positivity
            nlinarith
        _ ≤ (hStates n : ℝ) * x ^ n := by
            have : (0:ℝ) ≤ (hStates n : ℝ) := le_of_lt (hStates_pos n)
            nlinarith
    have hlim : (1:ℝ)/2 ≤ 0 := by
      refine le_of_tendsto_of_tendsto tendsto_const_nhds hterm ?_
      filter_upwards [Filter.eventually_ge_atTop 1] with n hn using hhalf n hn
    linarith
  · intro hlt
    have hxg : x * growth < 1 := by
      have h := mul_lt_mul_of_pos_right hlt hgpos
      rwa [inv_mul_cancel₀ (ne_of_gt hgpos)] at h
    refine Summable.of_nonneg_of_le (fun n => by positivity) (fun n => ?_)
      (summable_geometric_of_lt_one (by positivity) hxg)
    calc (hStates n : ℝ) * x ^ n ≤ growth ^ n * x ^ n := by
          have : (0:ℝ) ≤ x ^ n := by positivity
          nlinarith [hStates_le_pow n]
      _ = (x * growth) ^ n := by rw [mul_pow]; ring


/-- **Exact canonical partition function.**  Below the Hagedorn point the
partition function of the quantum horizon is the rational function
`(1-x)² / (2x² - 4x + 1)`, whose poles `1 ± 1/√2` are the inverse growth rates;
the physical pole `x = 1/(2+√2)` is exactly the Hagedorn fugacity of
`partition_function_summable_iff`. -/
theorem partition_function_closed_form (x : ℝ) (hx0 : 0 ≤ x) (hx : x < growth⁻¹) :
    ∑' n : ℕ, (hStates n : ℝ) * x ^ n = (1 - x) ^ 2 / (2 * x ^ 2 - 4 * x + 1) := by
  have hgpos : (0:ℝ) < growth := growth_pos
  have hg'pos : (0:ℝ) < growth' := growth'_pos
  have hr : Real.sqrt 2 ^ 2 = 2 := sqrt_two_sq
  have hsum : Summable (fun n : ℕ => (hStates n : ℝ) * x ^ n) :=
    (partition_function_summable_iff x hx0).mpr hx
  have hgx : growth * x < 1 := by
    have h := mul_lt_mul_of_pos_left hx hgpos
    rwa [mul_inv_cancel₀ (ne_of_gt hgpos)] at h
  have hg'x : growth' * x < 1 := by
    have : growth' * x ≤ growth * x := mul_le_mul_of_nonneg_right growth'_le_growth hx0
    linarith
  have habs1 : |growth * x| < 1 := by
    rw [abs_of_nonneg (mul_nonneg (le_of_lt hgpos) hx0)]; exact hgx
  have habs2 : |growth' * x| < 1 := by
    rw [abs_of_nonneg (mul_nonneg (le_of_lt hg'pos) hx0)]; exact hg'x
  have hshift : ∀ y : ℝ, |y| < 1 → Summable (fun n : ℕ => y ^ (n + 1)) := by
    intro y hy
    refine ((summable_geometric_of_abs_lt_one hy).mul_left y).congr ?_
    intro n; ring
  have hgeo : ∀ y : ℝ, |y| < 1 → ∑' n : ℕ, y ^ (n + 1) = y / (1 - y) := by
    intro y hy
    have h : (fun n : ℕ => y ^ (n + 1)) = fun n : ℕ => y * y ^ n := funext (fun n => by ring)
    rw [h, tsum_mul_left, tsum_geometric_of_abs_lt_one hy, div_eq_mul_inv]
  have hterm : ∀ n : ℕ, (hStates (n + 1) : ℝ) * x ^ (n + 1)
      = ((1 + Real.sqrt 2) / 4) * (growth * x) ^ (n + 1)
        + ((1 - Real.sqrt 2) / 4) * (growth' * x) ^ (n + 1) := by
    intro n
    have h := hStates_closed_form (n + 1) (by omega)
    have hW : (hStates (n + 1) : ℝ)
        = ((1 + Real.sqrt 2) * growth ^ (n + 1) + (1 - Real.sqrt 2) * growth' ^ (n + 1)) / 4 := by
      linarith
    rw [hW, mul_pow, mul_pow]; ring
  have hne1 : (1 : ℝ) - growth * x ≠ 0 := by linarith
  have hne2 : (1 : ℝ) - growth' * x ≠ 0 := by linarith
  have hD : (1 - growth * x) * (1 - growth' * x) = 2 * x ^ 2 - 4 * x + 1 := by
    unfold growth growth'
    linear_combination (-(x ^ 2)) * hr
  have hDne : 2 * x ^ 2 - 4 * x + 1 ≠ 0 := by
    rw [← hD]
    exact mul_ne_zero hne1 hne2
  rw [hsum.tsum_eq_zero_add, tsum_congr hterm,
    Summable.tsum_add ((hshift _ habs1).mul_left _) ((hshift _ habs2).mul_left _),
    tsum_mul_left, tsum_mul_left, hgeo _ habs1, hgeo _ habs2]
  have hmid : ((1 + Real.sqrt 2) / 4) * (growth * x / (1 - growth * x))
      + ((1 - Real.sqrt 2) / 4) * (growth' * x / (1 - growth' * x))
      = x * (2 - x) / (2 * x ^ 2 - 4 * x + 1) := by
    have e1 : ((1 + Real.sqrt 2) / 4) * (growth * x / (1 - growth * x))
        = ((1 + Real.sqrt 2) * (growth * x) / 4) / (1 - growth * x) := by
      field_simp
    have e2 : ((1 - Real.sqrt 2) / 4) * (growth' * x / (1 - growth' * x))
        = ((1 - Real.sqrt 2) * (growth' * x) / 4) / (1 - growth' * x) := by
      field_simp
    rw [e1, e2, div_add_div _ _ hne1 hne2, hD]
    congr 1
    unfold growth growth'
    linear_combination ((x + x ^ 2) / 2) * hr
  have h0 : (hStates 0 : ℝ) * x ^ 0 = 1 := by simp
  have hfin : (1:ℝ) + x * (2 - x) / (2 * x ^ 2 - 4 * x + 1)
      = (1 - x) ^ 2 / (2 * x ^ 2 - 4 * x + 1) := by
    rw [eq_div_iff hDne, add_mul, div_mul_cancel₀ _ hDne]
    ring
  rw [hmid, h0, hfin]

end BekensteinHawking