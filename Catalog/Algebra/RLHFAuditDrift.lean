import Algebra.RLHFKLSecondOrder

/-!
# Exact first-order audit drift: the constant is the covariance

Domain: Algebra (convex analysis × information theory × alignment theory).

The catalogue's anti-reward-hacking bound `RLHF.audit_gap_le_stddev` controls the shift
of an audit statistic `f` under alignment by `σ_p(r)·σ_p(f)·e^{range r/β}/β`.  This file
identifies the exact constant: it is the **covariance**

  `β · (𝔼_{π_β} f − 𝔼_p f) → Cov_p(r, f)`.

* `RLHF.audit_gap_eq_centred` — the exact identity
  `𝔼_{π_β} f − 𝔼_p f = 𝔼_p[(e^{(r−𝔼r)/β} − 1)(f − 𝔼_p f)] / W_β`;
* `RLHF.abs_audit_gap_sub_cov` — `|𝔼_{π_β} f − 𝔼_p f − Cov_p(r,f)/β| ≤
  3·range(f)·Var_p(r)/β²` for `β ≥ range r`;
* `RLHF.audit_gap_tendsto_cov` — hence `β(𝔼_{π_β} f − 𝔼_p f) → Cov_p(r,f)`;
* `RLHF.audit_invariant_of_cov_zero` — an audit statistic **uncorrelated with the
  reward cannot be moved to first order**: its drift is `o(β⁻¹)`.  Reward hacking is
  therefore exactly the reward-correlated component of the audit statistic, and the
  `σ_p(r)σ_p(f)` bound is the Cauchy–Schwarz relaxation of this exact law.

The second half of the file closes the loop between the two sharp laws of
`Algebra.RLHFMeanAbsoluteDeviation` (`ℓ¹` drift `→ MAD/β`) and
`Algebra.RLHFKLSecondOrder` (KL drift `→ Var/(2β²)`):

* `RLHF.pinsker_defect_tendsto` — `‖π_β − p‖₁ / √(2 KL(π_β‖p)) → MAD_p(r)/σ_p(r)`;
* `RLHF.pinsker_asymptotically_tight_iff` — the Pinsker inequality is asymptotically
  tight along the Gibbs path **iff** `|r − 𝔼_p r|` is constant, i.e. exactly for the
  balanced two-valued rewards.

So the standard-deviation constant of conjecture C1 is exactly the Pinsker relaxation
of the true constant, and the deficiency is the deviation defect `σ_p(r) − MAD_p(r)`.
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-! ## 1. The exact audit-drift identity -/

omit [Nonempty Ω] in
/-- The covariance as a centred-reward sum. -/
theorem cov_eq_sum_ctr {p r f : Ω → ℝ} :
    cov p r f = ∑ y, p y * ((r y - mean p r) * (f y - mean p f)) := rfl

/-- **Exact audit drift.**  The mean shift of any statistic `f` under alignment is
`𝔼_p[(e^{(r−𝔼r)/β} − 1)(f − 𝔼_p f)] / W_β`. -/
theorem audit_gap_eq_centred {β : ℝ} {r p : Ω → ℝ} (hp : IsPosDist p) (f : Ω → ℝ) :
    mean (gibbsPolicy β r p) f - mean p f
      = (∑ y, p y * ((Real.exp ((r y - mean p r) / β) - 1) * (f y - mean p f)))
        / tiltNorm β r p := by
  have hW := tiltNorm_pos (β := β) (r := r) hp
  have hWne : tiltNorm β r p ≠ 0 := ne_of_gt hW
  have hnum : (∑ y, p y * ((Real.exp ((r y - mean p r) / β) - 1) * (f y - mean p f)))
      = (∑ y, p y * (Real.exp ((r y - mean p r) / β) * f y))
        - mean p f * tiltNorm β r p := by
    have h : ∀ y, p y * ((Real.exp ((r y - mean p r) / β) - 1) * (f y - mean p f))
        = p y * (Real.exp ((r y - mean p r) / β) * f y)
          - mean p f * (p y * Real.exp ((r y - mean p r) / β))
          - p y * f y + mean p f * p y := fun y => by ring
    rw [Finset.sum_congr rfl fun y _ => h y, Finset.sum_add_distrib, Finset.sum_sub_distrib,
      Finset.sum_sub_distrib, ← Finset.mul_sum, ← Finset.mul_sum, hp.total]
    simp only [tiltNorm, mean]
    ring
  have hmean : mean (gibbsPolicy β r p) f
      = (∑ y, p y * (Real.exp ((r y - mean p r) / β) * f y)) / tiltNorm β r p := by
    rw [mean, Finset.sum_div]
    refine Finset.sum_congr rfl fun y _ => ?_
    rw [gibbsPolicy_eq_centred]
    field_simp
  rw [hmean, hnum]
  field_simp

/-- The audit numerator is `Cov_p(r,f)/β` up to a second-order remainder. -/
theorem abs_audit_num_sub_cov {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsDist p)
    (hr : rewardRange r ≤ β) (f : Ω → ℝ) :
    |(∑ y, p y * ((Real.exp ((r y - mean p r) / β) - 1) * (f y - mean p f)))
        - cov p r f / β|
      ≤ rewardRange f * (variance p r / β ^ 2) := by
  have hsmall : ∀ y, |(r y - mean p r) / β| ≤ 1 := by
    intro y
    rw [abs_div, abs_of_pos hβ, div_le_one hβ]
    exact le_trans (abs_sub_mean_le_range hp y) hr
  have hcov : cov p r f / β = ∑ y, p y * (((r y - mean p r) / β) * (f y - mean p f)) := by
    rw [cov_eq_sum_ctr, Finset.sum_div]
    refine Finset.sum_congr rfl fun y _ => ?_
    ring
  rw [hcov, ← Finset.sum_sub_distrib]
  refine le_trans (Finset.abs_sum_le_sum_abs _ _) ?_
  have hterm : ∀ y ∈ (univ : Finset Ω),
      |p y * ((Real.exp ((r y - mean p r) / β) - 1) * (f y - mean p f))
        - p y * (((r y - mean p r) / β) * (f y - mean p f))|
      ≤ rewardRange f * (p y * ((r y - mean p r) / β) ^ 2) := by
    intro y _
    set s := (r y - mean p r) / β with hs
    have htaylor : |Real.exp s - 1 - s| ≤ s ^ 2 := Real.abs_exp_sub_one_sub_id_le (hsmall y)
    have hg : |f y - mean p f| ≤ rewardRange f := abs_sub_mean_le_range hp y
    have heq : p y * ((Real.exp s - 1) * (f y - mean p f))
        - p y * (s * (f y - mean p f))
        = p y * ((Real.exp s - 1 - s) * (f y - mean p f)) := by ring
    rw [heq, abs_mul, abs_of_nonneg (hp.nonneg y), abs_mul]
    have hprod : |Real.exp s - 1 - s| * |f y - mean p f| ≤ s ^ 2 * rewardRange f :=
      mul_le_mul htaylor hg (abs_nonneg _) (sq_nonneg s)
    calc p y * (|Real.exp s - 1 - s| * |f y - mean p f|)
        ≤ p y * (s ^ 2 * rewardRange f) := mul_le_mul_of_nonneg_left hprod (hp.nonneg y)
      _ = rewardRange f * (p y * s ^ 2) := by ring
  refine le_trans (Finset.sum_le_sum hterm) ?_
  rw [← Finset.mul_sum, sum_ctr_sq_div]

/-- **The audit-drift constant is the covariance.**  For `β ≥ range r`,
`|𝔼_{π_β} f − 𝔼_p f − Cov_p(r,f)/β| ≤ 3·range(f)·Var_p(r)/β²`. -/
theorem abs_audit_gap_sub_cov {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hr : rewardRange r ≤ β) (f : Ω → ℝ) :
    |mean (gibbsPolicy β r p) f - mean p f - cov p r f / β|
      ≤ 3 * (rewardRange f * (variance p r / β ^ 2)) := by
  have hd := hp.isDist
  have hW := tiltNorm_pos (β := β) (r := r) hp
  have hW1 := one_le_tiltNorm (β := β) (r := r) hd
  have hW2 := tiltNorm_le (β := β) (r := r) hβ hd hr
  have hw0 : 0 ≤ tiltNorm β r p - 1 := by linarith
  have hV : 0 ≤ variance p r := variance_nonneg hd r
  have hUf : 0 ≤ rewardRange f := rewardRange_nonneg f
  have hUr : 0 ≤ rewardRange r := rewardRange_nonneg r
  have hVb : 0 ≤ variance p r / β ^ 2 := by positivity
  set D := ∑ y, p y * ((Real.exp ((r y - mean p r) / β) - 1) * (f y - mean p f)) with hD
  have hnum := abs_le.1 (abs_audit_num_sub_cov hβ hd hr f)
  -- `Var/β² ≤ 1`, since `Var ≤ range²/4 ≤ β²`
  have hVsmall : variance p r / β ^ 2 ≤ 1 := by
    have hpop : variance p r ≤ rewardRange r ^ 2 / 4 := variance_le_range_sq hd
    have hsq : rewardRange r ^ 2 ≤ β ^ 2 := by nlinarith
    rw [div_le_one (by positivity)]
    nlinarith
  -- `|Cov| ≤ range(r)·range(f)`
  have hcovb : |cov p r f| ≤ rewardRange r * rewardRange f := by
    rw [cov_eq_sum_ctr]
    refine le_trans (Finset.abs_sum_le_sum_abs _ _) ?_
    have hterm : ∀ y ∈ (univ : Finset Ω),
        |p y * ((r y - mean p r) * (f y - mean p f))|
          ≤ (rewardRange r * rewardRange f) * p y := by
      intro y _
      rw [abs_mul, abs_of_nonneg (hp.pos y).le, abs_mul]
      have h1 : |r y - mean p r| ≤ rewardRange r := abs_sub_mean_le_range hd y
      have h2 : |f y - mean p f| ≤ rewardRange f := abs_sub_mean_le_range hd y
      have h3 : |r y - mean p r| * |f y - mean p f| ≤ rewardRange r * rewardRange f :=
        mul_le_mul h1 h2 (abs_nonneg _) hUr
      calc p y * (|r y - mean p r| * |f y - mean p f|)
          ≤ p y * (rewardRange r * rewardRange f) :=
            mul_le_mul_of_nonneg_left h3 (hp.pos y).le
        _ = (rewardRange r * rewardRange f) * p y := by ring
    have hsum := Finset.sum_le_sum hterm
    rwa [← Finset.mul_sum, hd.total, mul_one] at hsum
  -- hence `|D| ≤ 2 range(f)`
  have hDb : |D| ≤ 2 * rewardRange f := by
    have h1 : |cov p r f / β| ≤ rewardRange f := by
      rw [abs_div, abs_of_pos hβ, div_le_iff₀ hβ]
      calc |cov p r f| ≤ rewardRange r * rewardRange f := hcovb
        _ ≤ β * rewardRange f := mul_le_mul_of_nonneg_right hr hUf
        _ = rewardRange f * β := by ring
    have h2 : |D - cov p r f / β| ≤ rewardRange f * (variance p r / β ^ 2) := by
      rw [abs_le]; exact ⟨hnum.1, hnum.2⟩
    have h3 : rewardRange f * (variance p r / β ^ 2) ≤ rewardRange f :=
      by nlinarith
    calc |D| ≤ |D - cov p r f / β| + |cov p r f / β| := by
          have habs := abs_add_le (D - cov p r f / β) (cov p r f / β)
          simpa using habs
      _ ≤ rewardRange f + rewardRange f := by linarith
      _ = 2 * rewardRange f := by ring
  -- the quotient step
  have hquot : |D / tiltNorm β r p - D| ≤ 2 * (rewardRange f * (variance p r / β ^ 2)) := by
    have heq : D / tiltNorm β r p - D
        = -(D * (tiltNorm β r p - 1) / tiltNorm β r p) := by
      field_simp
      ring
    rw [heq, abs_neg, abs_div, abs_of_pos hW, div_le_iff₀ hW, abs_mul,
      abs_of_nonneg hw0]
    have h1 : |D| * (tiltNorm β r p - 1) ≤ (2 * rewardRange f) * (variance p r / β ^ 2) :=
      mul_le_mul hDb (by linarith) hw0 (by positivity)
    nlinarith [hW1, mul_nonneg (mul_nonneg (by norm_num : (0:ℝ) ≤ 2) hUf) hVb]
  rw [audit_gap_eq_centred hp f, ← hD]
  have hsplit : D / tiltNorm β r p - cov p r f / β
      = (D / tiltNorm β r p - D) + (D - cov p r f / β) := by ring
  rw [hsplit]
  refine le_trans (abs_add_le _ _) ?_
  have h2 : |D - cov p r f / β| ≤ rewardRange f * (variance p r / β ^ 2) := by
    rw [abs_le]; exact ⟨hnum.1, hnum.2⟩
  linarith

/-- **The audit-drift limit law.**  `β·(𝔼_{π_β} f − 𝔼_p f) → Cov_p(r, f)`. -/
theorem audit_gap_tendsto_cov {r p : Ω → ℝ} (hp : IsPosDist p) (f : Ω → ℝ) :
    Filter.Tendsto (fun β : ℝ => β * (mean (gibbsPolicy β r p) f - mean p f)) Filter.atTop
      (nhds (cov p r f)) := by
  have hinv : Filter.Tendsto (fun β : ℝ => (1 : ℝ) / β) Filter.atTop (nhds 0) :=
    Filter.Tendsto.div_atTop tendsto_const_nhds Filter.tendsto_id
  have herr : Filter.Tendsto
      (fun β : ℝ => 3 * (rewardRange f * variance p r) * (1 / β)) Filter.atTop (nhds 0) := by
    simpa using hinv.const_mul (3 * (rewardRange f * variance p r))
  have hlow : Filter.Tendsto
      (fun β : ℝ => cov p r f - 3 * (rewardRange f * variance p r) * (1 / β)) Filter.atTop
      (nhds (cov p r f)) := by simpa using tendsto_const_nhds.sub herr
  have hhigh : Filter.Tendsto
      (fun β : ℝ => cov p r f + 3 * (rewardRange f * variance p r) * (1 / β)) Filter.atTop
      (nhds (cov p r f)) := by simpa using tendsto_const_nhds.add herr
  have hsandwich : ∀ β : ℝ, max (rewardRange r) 1 ≤ β →
      |β * (mean (gibbsPolicy β r p) f - mean p f) - cov p r f|
        ≤ 3 * (rewardRange f * variance p r) * (1 / β) := by
    intro β hβm
    have hβ : 0 < β := lt_of_lt_of_le zero_lt_one (le_trans (le_max_right _ _) hβm)
    have hr : rewardRange r ≤ β := le_trans (le_max_left _ _) hβm
    have hkey := abs_audit_gap_sub_cov hβ hp hr f
    have heq : β * (mean (gibbsPolicy β r p) f - mean p f - cov p r f / β)
        = β * (mean (gibbsPolicy β r p) f - mean p f) - cov p r f := by
      field_simp
    have habs : |β * (mean (gibbsPolicy β r p) f - mean p f - cov p r f / β)|
        = β * |mean (gibbsPolicy β r p) f - mean p f - cov p r f / β| := by
      rw [abs_mul, abs_of_pos hβ]
    rw [← heq, habs]
    refine le_trans (mul_le_mul_of_nonneg_left hkey hβ.le) (le_of_eq ?_)
    field_simp
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow hhigh ?_ ?_
  · filter_upwards [Filter.eventually_ge_atTop (max (rewardRange r) 1)] with β hβm
    linarith [(abs_le.1 (hsandwich β hβm)).1]
  · filter_upwards [Filter.eventually_ge_atTop (max (rewardRange r) 1)] with β hβm
    linarith [(abs_le.1 (hsandwich β hβm)).2]

/-- **Uncorrelated statistics cannot be hacked to first order.**  If the audit statistic
is uncorrelated with the reward under the reference policy, its alignment drift is
`o(β⁻¹)`. -/
theorem audit_invariant_of_cov_zero {r p : Ω → ℝ} (hp : IsPosDist p) (f : Ω → ℝ)
    (hcov : cov p r f = 0) :
    Filter.Tendsto (fun β : ℝ => β * (mean (gibbsPolicy β r p) f - mean p f)) Filter.atTop
      (nhds 0) := by
  have h := audit_gap_tendsto_cov (r := r) hp f
  rwa [hcov] at h

/-! ## 2. The exact Pinsker defect along the Gibbs path -/

/-- `β·√(2 KL(π_β‖p)) → σ_p(r)`. -/
theorem sqrt_two_kl_tendsto_stddev {r p : Ω → ℝ} (hp : IsPosDist p) :
    Filter.Tendsto (fun β : ℝ => β * Real.sqrt (2 * klDiv (gibbsPolicy β r p) p))
      Filter.atTop (nhds (Real.sqrt (variance p r))) := by
  have hkl := kl_tendsto_half_variance (r := r) hp
  have hmul : Filter.Tendsto (fun β : ℝ => 2 * (β ^ 2 * klDiv (gibbsPolicy β r p) p))
      Filter.atTop (nhds (variance p r)) := by
    have := hkl.const_mul (2 : ℝ)
    have heq : 2 * (variance p r / 2) = variance p r := by ring
    rwa [heq] at this
  have hsqrt : Filter.Tendsto
      (fun β : ℝ => Real.sqrt (2 * (β ^ 2 * klDiv (gibbsPolicy β r p) p))) Filter.atTop
      (nhds (Real.sqrt (variance p r))) := (Real.continuous_sqrt.tendsto _).comp hmul
  refine hsqrt.congr' ?_
  filter_upwards [Filter.eventually_gt_atTop (0 : ℝ)] with β hβ
  have h1 : 2 * (β ^ 2 * klDiv (gibbsPolicy β r p) p)
      = β ^ 2 * (2 * klDiv (gibbsPolicy β r p) p) := by ring
  rw [h1, Real.sqrt_mul (sq_nonneg β), Real.sqrt_sq hβ.le]

/-- **The exact Pinsker defect along the Gibbs path.**
`‖π_β − p‖₁ / √(2 KL(π_β‖p)) → MAD_p(r)/σ_p(r) ≤ 1`.  The Pinsker inequality therefore
loses exactly the deviation defect of the reward. -/
theorem pinsker_defect_tendsto {r p : Ω → ℝ} (hp : IsPosDist p)
    (hV : 0 < variance p r) :
    Filter.Tendsto
      (fun β : ℝ => l1Dist (gibbsPolicy β r p) p / Real.sqrt (2 * klDiv (gibbsPolicy β r p) p))
      Filter.atTop (nhds (mad p r / Real.sqrt (variance p r))) := by
  have hnum := l1_drift_tendsto_mad (r := r) hp
  have hden := sqrt_two_kl_tendsto_stddev (r := r) hp
  have hne : Real.sqrt (variance p r) ≠ 0 := by positivity
  have hdiv := hnum.div hden hne
  refine hdiv.congr' ?_
  filter_upwards [Filter.eventually_gt_atTop (0 : ℝ)] with β hβ
  simp only [Pi.div_apply]
  rw [mul_div_mul_left _ _ (ne_of_gt hβ)]

omit [Nonempty Ω] in
/-- **Pinsker is asymptotically tight along the Gibbs path exactly for balanced
two-valued rewards.** -/
theorem pinsker_asymptotically_tight_iff {r p : Ω → ℝ} (hp : IsPosDist p)
    (hV : 0 < variance p r) :
    mad p r / Real.sqrt (variance p r) = 1 ↔ ∀ y, |r y - mean p r| = mad p r := by
  have hne : Real.sqrt (variance p r) ≠ 0 := by positivity
  rw [div_eq_one_iff_eq hne]
  exact mad_eq_sqrt_variance_iff hp r

end RLHF