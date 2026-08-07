import Mathlib
import MachineLearning.GrokkingDelayedTransition.NextCycle
import MachineLearning.GrokkingDelayedTransition.WidthLawsAndRelapses

/-!
# Sharp constants for the two grokking delay laws

`FUTURE_DIRECTIONS.md`, Conjecture 1, proposes an *exponent dichotomy* for
grokking delays: a logarithmic law for the threshold-crossing (relaxation)
mechanism and an inverse-square-root law for the saddle-node bottleneck.  The
previous cycles proved one-sided bounds in both cases
(`crossTime_lower_bound`, `passageTime_lower_bound`) and, in
`WidthLawsAndRelapses.lean`, that the second bound eventually dominates the
first.  This file pins down the **leading constants** of both laws, turning the
qualitative dichotomy into two exact asymptotics:

* `crossTime_sharp_constant`:
  `crossTime λ / log (1/μ(λ)) → θ/s = 1/λ_c` as `λ ↑ λ_c`, i.e.
  `crossTime ∼ λ_c⁻¹ · log(1/μ)`.
* `passageTime_sharp_constant` / `bottleneck_sharp_constant`:
  `√(-μ) · passageTime (√(-μ)) A → π`, i.e. `passageTime ∼ π · |μ|^{-1/2}`,
  independently of the observation level `A`.

Combining the two, `delay_ratio_tendsto_zero` shows the relaxation delay is
*negligible* compared with the bottleneck delay near criticality, and
`bottleneck_delay_eventually_larger` gives the quantitative comparison with the
sharp constants in place.  Everything is `sorry`-free.
-/

namespace GrokkingDelayExponents

open Filter Topology
open GrokkingTraining GrokkingNextCycle GrokkingBifurcation GrokkingWidthLaws

/-! ### The logarithmic law: leading constant `1/λ_c` -/

/-- **Sharp constant of the relaxation delay.**  As the weight decay increases
to its critical value `λ_c = s/θ`, the crossing time of the weight-decayed
gradient flow satisfies `crossTime λ ∼ λ_c⁻¹ · log(1/μ(λ))`, where
`μ(λ) = s/λ - θ` is the bifurcation parameter: the ratio converges to
`θ/s = 1/λ_c`. -/
theorem crossTime_sharp_constant (s theta w0 : ℝ) (hs : 0 < s) (hth : 0 < theta)
    (hw0 : w0 < theta) :
    Tendsto (fun lam => crossTime lam s w0 theta / Real.log (1 / bifParam lam s theta))
      (𝓝[<] (criticalDecay s theta)) (𝓝 (theta / s)) := by
  set c : ℝ := criticalDecay s theta with hc
  have hcpos : 0 < c := by rw [hc, criticalDecay]; positivity
  have hden : 0 < 2 * theta - w0 := by linarith
  set a : ℝ := s / (2 * theta - w0) with ha
  have hapos : 0 < a := by rw [ha]; positivity
  have hac : a < c := by
    rw [ha, hc, criticalDecay]
    exact div_lt_div_of_pos_left hs hth (by linarith)
  have hIoo : Set.Ioo a c ∈ 𝓝[<] c := Ioo_mem_nhdsLT hac
  have hfacts : ∀ lam ∈ Set.Ioo a c, 0 < lam ∧ theta < s / lam ∧ s / lam < 2 * theta - w0 := by
    rintro lam ⟨h1, h2⟩
    have hlam : 0 < lam := lt_trans hapos h1
    refine ⟨hlam, ?_, ?_⟩
    · rw [lt_div_iff₀ hlam]
      have : lam * theta < s := by
        rw [hc, criticalDecay] at h2
        exact (lt_div_iff₀ hth).mp h2
      linarith
    · rw [div_lt_iff₀ hlam]
      have : s < lam * (2 * theta - w0) := by
        rw [ha, div_lt_iff₀ hden] at h1
        linarith
      linarith
  have hval : s / c - theta = 0 := by
    rw [hc, criticalDecay]; field_simp; ring
  have hsc : s / c = theta := by linarith
  have hcont : Tendsto (fun lam => bifParam lam s theta) (𝓝[<] c) (𝓝 0) := by
    have hca : ContinuousAt (fun lam : ℝ => s / lam - theta) c :=
      (continuousAt_const.div continuousAt_id (ne_of_gt hcpos)).sub continuousAt_const
    have h := hca.tendsto.mono_left (nhdsWithin_le_nhds (s := Set.Iio c))
    rw [hval] at h
    simpa only [bifParam] using h
  have hwithin : ∀ᶠ lam in 𝓝[<] c, bifParam lam s theta ∈ Set.Ioi (0 : ℝ) := by
    filter_upwards [hIoo] with lam hlam
    have h := hfacts lam hlam
    simp only [bifParam, Set.mem_Ioi]
    linarith [h.2.1]
  have hgt : Tendsto (fun lam => bifParam lam s theta) (𝓝[<] c) (𝓝[>] (0 : ℝ)) :=
    tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within _ hcont hwithin
  have hinv : Tendsto (fun lam => (bifParam lam s theta)⁻¹) (𝓝[<] c) atTop :=
    tendsto_inv_nhdsGT_zero.comp hgt
  have hL : Tendsto (fun lam => Real.log (1 / bifParam lam s theta)) (𝓝[<] c) atTop := by
    have h := Real.tendsto_log_atTop.comp hinv
    simp only [one_div]
    exact h
  have hnumlog : Tendsto (fun lam => Real.log (s / lam - w0)) (𝓝[<] c)
      (𝓝 (Real.log (theta - w0))) := by
    have hca : ContinuousAt (fun lam : ℝ => s / lam - w0) c :=
      (continuousAt_const.div continuousAt_id (ne_of_gt hcpos)).sub continuousAt_const
    have hne : s / c - w0 ≠ 0 := by rw [hsc]; linarith
    have hcomp : ContinuousAt (fun lam : ℝ => Real.log (s / lam - w0)) c := hca.log hne
    have h := hcomp.tendsto.mono_left (nhdsWithin_le_nhds (s := Set.Iio c))
    rwa [hsc] at h
  have hratio0 : Tendsto
      (fun lam => Real.log (s / lam - w0) / Real.log (1 / bifParam lam s theta)) (𝓝[<] c) (𝓝 0) :=
    hnumlog.div_atTop hL
  have hlamlim : Tendsto (fun lam : ℝ => 1 / lam) (𝓝[<] c) (𝓝 (1 / c)) := by
    have hca : ContinuousAt (fun lam : ℝ => 1 / lam) c :=
      continuousAt_const.div continuousAt_id (ne_of_gt hcpos)
    exact hca.tendsto.mono_left (nhdsWithin_le_nhds (s := Set.Iio c))
  have hprod : Tendsto
      (fun lam => (1 / lam) *
        (Real.log (s / lam - w0) / Real.log (1 / bifParam lam s theta) + 1)) (𝓝[<] c)
      (𝓝 (theta / s)) := by
    have h := hlamlim.mul (hratio0.add (tendsto_const_nhds (x := (1 : ℝ))))
    have heq : (1 / c) * (0 + 1) = theta / s := by
      rw [hc, criticalDecay, zero_add, mul_one, one_div_div]
    rwa [heq] at h
  refine hprod.congr' ?_
  have hLbig : ∀ᶠ lam in 𝓝[<] c, 1 < Real.log (1 / bifParam lam s theta) :=
    hL.eventually_gt_atTop 1
  filter_upwards [hIoo, hLbig] with lam hlam' hLb
  obtain ⟨hlampos, hthlt, _⟩ := hfacts lam hlam'
  have hmu : 0 < s / lam - theta := by linarith
  have hA : 0 < s / lam - w0 := by linarith
  have hLne : Real.log (1 / bifParam lam s theta) ≠ 0 := by linarith
  have hmuB : bifParam lam s theta = s / lam - theta := rfl
  have hsplit : Real.log ((s / lam - w0) / (s / lam - theta))
      = Real.log (s / lam - w0) + Real.log (1 / bifParam lam s theta) := by
    rw [Real.log_div (ne_of_gt hA) (ne_of_gt hmu), hmuB,
      Real.log_div one_ne_zero (ne_of_gt hmu), Real.log_one]
    ring
  simp only [crossTime, hsplit]
  field_simp

/-! ### The bottleneck law: leading constant `π` -/

/-- **Sharp constant of the bottleneck passage time in the tangent variable.**
`k · passageTime k A → π` as `k ↓ 0`, for every fixed observation level
`A > 0`. -/
theorem passageTime_sharp_constant (A : ℝ) (hA : 0 < A) :
    Tendsto (fun k : ℝ => k * passageTime k A) (𝓝[>] 0) (𝓝 Real.pi) := by
  have hdiv : Tendsto (fun k : ℝ => A / k) (𝓝[>] 0) atTop := by
    have h : Tendsto (fun k : ℝ => k⁻¹) (𝓝[>] (0 : ℝ)) atTop := tendsto_inv_nhdsGT_zero
    simpa [div_eq_mul_inv, mul_comm] using h.const_mul_atTop hA
  have harc : Tendsto (fun k : ℝ => Real.arctan (A / k)) (𝓝[>] 0) (𝓝 (Real.pi / 2)) :=
    (Real.tendsto_arctan_atTop.mono_right nhdsWithin_le_nhds).comp hdiv
  have h2 : Tendsto (fun k : ℝ => 2 * Real.arctan (A / k)) (𝓝[>] 0) (𝓝 Real.pi) := by
    have h3 := harc.const_mul 2
    rw [show (2 : ℝ) * (Real.pi / 2) = Real.pi by ring] at h3
    exact h3
  refine h2.congr' ?_
  filter_upwards [self_mem_nhdsWithin] with k hk
  have hk0 : (0 : ℝ) < k := hk
  simp only [passageTime]
  field_simp

/-- **Sharp inverse-square-root law.**  In the bifurcation parameter,
`passageTime (√(-μ)) A ∼ π · |μ|^{-1/2}` as `μ ↑ 0`: the exponent is `-1/2` and
the leading constant is exactly `π`, independently of the observation level. -/
theorem bottleneck_sharp_constant (A : ℝ) (hA : 0 < A) :
    Tendsto (fun mu : ℝ => Real.sqrt (-mu) * passageTime (Real.sqrt (-mu)) A)
      (𝓝[<] (0 : ℝ)) (𝓝 Real.pi) := by
  have hsq : Tendsto (fun mu : ℝ => Real.sqrt (-mu)) (𝓝[<] (0 : ℝ)) (𝓝[>] 0) := by
    rw [tendsto_nhdsWithin_iff]
    constructor
    · have hcont : Continuous fun mu : ℝ => Real.sqrt (-mu) :=
        Real.continuous_sqrt.comp continuous_neg
      have h0 : Tendsto (fun mu : ℝ => Real.sqrt (-mu)) (𝓝 (0 : ℝ)) (𝓝 0) := by
        simpa using hcont.tendsto (0 : ℝ)
      exact h0.mono_left nhdsWithin_le_nhds
    · filter_upwards [self_mem_nhdsWithin] with mu hmu
      have hneg : mu < 0 := hmu
      exact Real.sqrt_pos.mpr (by linarith)
  exact (passageTime_sharp_constant A hA).comp hsq

/-! ### The dichotomy: the bottleneck exponent wins -/

/-- **The relaxation delay is negligible against the bottleneck delay.**  With
the sharp constants in place, the ratio of a logarithmic delay `K · log(D/μ)` to
the bottleneck delay `π/(2√μ)` tends to `0` as `μ ↓ 0`. -/
theorem delay_ratio_tendsto_zero (K D : ℝ) (hD : 0 < D) :
    Tendsto (fun mu : ℝ => (K * Real.log (D / mu)) / (Real.pi / (2 * Real.sqrt mu)))
      (𝓝[>] (0 : ℝ)) (𝓝 0) := by
  have hsqrt : Tendsto (fun mu : ℝ => Real.sqrt mu) (𝓝[>] 0) (𝓝 0) := by
    have h : Tendsto (fun mu : ℝ => Real.sqrt mu) (𝓝 0) (𝓝 0) := by
      simpa using (Real.continuous_sqrt.tendsto (0 : ℝ))
    exact h.mono_left nhdsWithin_le_nhds
  have hgoal : Tendsto
      (fun mu : ℝ => (2 * K / Real.pi) * (Real.sqrt mu * Real.log D)
        + (2 * K / Real.pi) * (Real.sqrt mu * Real.log (1 / mu))) (𝓝[>] 0) (𝓝 0) := by
    have h1 : Tendsto (fun mu : ℝ => (2 * K / Real.pi) * (Real.sqrt mu * Real.log D))
        (𝓝[>] 0) (𝓝 0) := by
      simpa using ((hsqrt.mul_const (Real.log D)).const_mul (2 * K / Real.pi))
    have h2 : Tendsto (fun mu : ℝ => (2 * K / Real.pi) * (Real.sqrt mu * Real.log (1 / mu)))
        (𝓝[>] 0) (𝓝 0) := by
      simpa using (sqrt_mul_log_inv_tendsto_zero.const_mul (2 * K / Real.pi))
    simpa using h1.add h2
  refine hgoal.congr' ?_
  filter_upwards [self_mem_nhdsWithin] with mu hmu
  have hmu0 : (0 : ℝ) < mu := hmu
  have hs : 0 < Real.sqrt mu := Real.sqrt_pos.mpr hmu0
  have hpi := Real.pi_pos
  have hlog : Real.log (D / mu) = Real.log D + Real.log (1 / mu) := by
    rw [Real.log_div (ne_of_gt hD) (ne_of_gt hmu0), Real.log_div one_ne_zero (ne_of_gt hmu0),
      Real.log_one]
    ring
  rw [hlog]
  field_simp

/-- **Quantitative form of the dichotomy.**  Every logarithmic delay is
eventually beaten by the bottleneck passage time; combined with
`crossTime_sharp_constant` and `bottleneck_sharp_constant` this says that in a
one-parameter family exhibiting both mechanisms the total delay is asymptotic to
the inverse-square-root term. -/
theorem bottleneck_delay_eventually_larger (K D A : ℝ) (hD : 0 < D) (hA : 0 < A) :
    ∀ᶠ mu in 𝓝[>] (0 : ℝ), K * Real.log (D / mu) < passageTime (Real.sqrt mu) A :=
  log_delay_lt_bottleneck_delay K D A hD hA

end GrokkingDelayExponents