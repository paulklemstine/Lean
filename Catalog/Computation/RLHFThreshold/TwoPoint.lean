import Computation.RLHFThreshold.Threshold

/-!
# The two-point model: the threshold constant is attained

Domain: Computation (alignment theory × elementary analysis).

The general theory of `Computation.RLHFThreshold.Threshold` sandwiches the audit gap
between `|Cov|/β ∓ K/β²`.  Nothing so far shows that the leading constant `|Cov|` is
*attained*, i.e. that the first-order law is sharp rather than merely valid.  This file
settles that on the smallest nontrivial response space `Ω = Bool` with

* reference policy `p = (½, ½)`,
* reward `r = (+R, −R)`,
* audit statistic `f = (+1, −1)` (perfectly correlated with the reward).

Everything is computed in closed form: `Cov_p(r,f) = R`, `Var_p(f) = 1`, and the audit
gap is *exactly* `tanh(R/β)`.  Since `β tanh(R/β) → R`, the leading coefficient of the
first-order law is attained, and the sharp threshold of `Threshold.lean` reads
`β_c(ε) ~ R/ε` here.

As a by-product the alignment theorem yields the analytic limit
`β · tanh(R/β) → R` (`RLHF.TwoPoint.tendsto_beta_mul_tanh`) — the audit-gap machinery
specialising to a classical hyperbolic identity.
-/

namespace RLHF.TwoPoint

open Finset RLHF Filter Topology

/-- The uniform reference policy on two responses. -/
noncomputable def p2 : Bool → ℝ := fun _ => 1 / 2

/-- The antisymmetric reward of amplitude `R`. -/
noncomputable def r2 (R : ℝ) : Bool → ℝ := fun b => if b then R else -R

/-- The audit statistic that is perfectly aligned with the reward. -/
noncomputable def f2 : Bool → ℝ := fun b => if b then 1 else -1

theorem p2_isPosDist : IsPosDist p2 := by
  constructor
  · intro y; simp [p2]
  · simp [p2]

theorem abs_r2_le {R : ℝ} (hR : 0 ≤ R) (y : Bool) : |r2 R y| ≤ R := by
  cases y <;> simp [r2, abs_of_nonneg hR, abs_of_nonpos (neg_nonpos.2 hR)]

theorem mean_p2_f2 : mean p2 f2 = 0 := by
  simp [mean, p2, f2]

theorem mean_p2_r2 (R : ℝ) : mean p2 (r2 R) = 0 := by
  simp [mean, p2, r2]

theorem variance_p2_f2 : variance p2 f2 = 1 := by
  simp [variance, mean_p2_f2, p2, f2]

/-- The audit statistic has unit standard deviation. -/
theorem sqrt_variance_p2_f2 : Real.sqrt (variance p2 f2) = 1 := by
  rw [variance_p2_f2, Real.sqrt_one]

/-- **The covariance of the reward with the statistic is the reward amplitude.** -/
theorem cov_p2 (R : ℝ) : cov p2 (r2 R) f2 = R := by
  simp [cov, mean_p2_f2, mean_p2_r2, p2, r2, f2]
  ring

/-- The two-point partition function is a hyperbolic cosine. -/
theorem partition_p2 (β R : ℝ) : partition β (r2 R) p2 = Real.cosh (R / β) := by
  simp [partition, p2, r2, Real.cosh_eq, neg_div]
  ring

/-- **Closed form of the audit gap: `G(β) = tanh(R/β)`.** -/
theorem auditGap_p2 (β R : ℝ) : auditGap β (r2 R) p2 f2 = Real.tanh (R / β) := by
  have hcosh : Real.cosh (R / β) ≠ 0 := (Real.cosh_pos _).ne'
  rw [auditGap, mean_p2_f2, sub_zero, mean, Fintype.sum_bool]
  simp only [gibbsPolicy, partition_p2, p2, r2, f2, if_true, if_false, Bool.false_eq_true]
  rw [Real.tanh_eq_sinh_div_cosh, Real.sinh_eq, Real.cosh_eq, neg_div]
  field_simp
  ring

/-- On the two-point model the aligned policy always moves the audit statistic in the
direction of the reward: the gap is strictly positive at every finite temperature. -/
theorem auditGap_p2_pos {β R : ℝ} (hβ : 0 < β) (hR : 0 < R) :
    0 < auditGap β (r2 R) p2 f2 := by
  rw [auditGap_p2, Real.tanh_eq_sinh_div_cosh]
  have h : 0 < R / β := div_pos hR hβ
  positivity

/-- **The first-order constant is attained**: rescaled by `β`, the two-point audit gap
converges to `Cov_p(r,f) = R`.  Hence the leading term of
`RLHF.abs_auditGap_sub_cov_le` cannot be improved. -/
theorem tendsto_beta_mul_auditGap_p2 {R : ℝ} (hR : 0 ≤ R) :
    Tendsto (fun β => β * auditGap β (r2 R) p2 f2) atTop (𝓝 R) := by
  have h := tendsto_beta_mul_auditGap (R := R) (r := r2 R) (p := p2) (f := f2)
    p2_isPosDist (abs_r2_le hR)
  rwa [cov_p2] at h

/-- The same statement read as an analytic fact about the hyperbolic tangent:
`β · tanh(R/β) → R` as `β → ∞`. -/
theorem tendsto_beta_mul_tanh {R : ℝ} (hR : 0 ≤ R) :
    Tendsto (fun β => β * Real.tanh (R / β)) atTop (𝓝 R) := by
  have h := tendsto_beta_mul_auditGap_p2 hR
  refine h.congr fun β => ?_
  rw [auditGap_p2]

/-- **The sharp threshold in the two-point model**: `ε · β_c(ε) → R` as `ε ↓ 0`, i.e.
the critical temperature for `ε`-hacking the statistic is `β_c(ε) = (1+o(1)) R/ε`. -/
theorem tendsto_eps_mul_betaCrit_p2 {R : ℝ} (hR : 0 < R) :
    Tendsto (fun ε => ε * betaCrit R ε (r2 R) p2 f2) (𝓝[>] 0) (𝓝 R) := by
  have hC : 0 < |cov p2 (r2 R) f2| := by
    rw [cov_p2, abs_of_pos hR]
    exact hR
  have h := tendsto_eps_mul_betaCrit (R := R) (r := r2 R) (p := p2) (f := f2)
    p2_isPosDist (abs_r2_le hR.le) hR hC
  rwa [cov_p2, abs_of_pos hR] at h

end RLHF.TwoPoint