import Computation.RLHFThreshold.SecondOrder
import Computation.RLHFThreshold.TwoPoint

/-!
# The `β⁻²` order of the first-order remainder is optimal

Domain: Computation (alignment theory × perturbation theory).

`RLHF.audit_gap_first_order` bounds the first-order remainder by `24 (R/β)² σ_p(f)`.
Is the exponent `2` optimal, or is the true remainder smaller?  Here we settle this by
exhibiting a one-parameter family of two-point models — the *biased* reference policy
`p = (q, 1−q)` with reward `±R` and audit statistic `±1` — whose skew covariance

`SkewCov_p(r,f) = 8 R² q (1−q) (1−2q)`

is nonzero whenever the reference policy is biased (`q ≠ ½`).  Combined with
`RLHF.tendsto_beta_sq_mul_auditGap_sub`, this shows

`β² (G(β) − Cov_p(r,f)/β) → SkewCov_p(r,f)/2 ≠ 0`,

so the remainder is exactly of order `β⁻²` (`RLHF.Biased.remainder_not_littleO`), and no
bound of the form `o(β⁻²)` can hold.  The symmetric case `q = ½` (the model of
`Computation.RLHFThreshold.TwoPoint`) is exactly the degenerate one where the
second-order term vanishes — bias of the reference policy is what creates second-order
reward hacking.
-/

namespace RLHF.Biased

open Finset RLHF Filter Topology

/-- The biased reference policy `(q, 1−q)` on two responses. -/
noncomputable def pq (q : ℝ) : Bool → ℝ := fun b => if b then q else 1 - q

theorem pq_isPosDist {q : ℝ} (hq0 : 0 < q) (hq1 : q < 1) : IsPosDist (pq q) := by
  constructor
  · intro y; cases y <;> simp [pq] <;> linarith
  · simp [pq]

theorem mean_pq_f2 (q : ℝ) : mean (pq q) TwoPoint.f2 = 2 * q - 1 := by
  simp [mean, pq, TwoPoint.f2]
  ring

theorem mean_pq_r2 (q R : ℝ) : mean (pq q) (TwoPoint.r2 R) = R * (2 * q - 1) := by
  simp [mean, pq, TwoPoint.r2]
  ring

/-- The covariance in the biased model: `Cov = 4 R q (1−q)`. -/
theorem cov_pq (q R : ℝ) : cov (pq q) (TwoPoint.r2 R) TwoPoint.f2 = 4 * R * q * (1 - q) := by
  simp [cov, mean_pq_f2, mean_pq_r2, pq, TwoPoint.r2, TwoPoint.f2]
  ring

/-- **The skew covariance in the biased model: `SkewCov = 8 R² q (1−q) (1−2q)`.**
It vanishes exactly when the reference policy is unbiased. -/
theorem skewCov_pq (q R : ℝ) :
    skewCov (pq q) (TwoPoint.r2 R) TwoPoint.f2 = 8 * R ^ 2 * q * (1 - q) * (1 - 2 * q) := by
  simp [skewCov, mean_pq_f2, mean_pq_r2, pq, TwoPoint.r2, TwoPoint.f2]
  ring

/-- For a biased reference policy the second-order hacking coefficient is nonzero. -/
theorem skewCov_pq_ne_zero {q R : ℝ} (hq0 : 0 < q) (hq1 : q < 1) (hq : q ≠ 1 / 2)
    (hR : R ≠ 0) : skewCov (pq q) (TwoPoint.r2 R) TwoPoint.f2 ≠ 0 := by
  rw [skewCov_pq]
  have h1 : (1 : ℝ) - 2 * q ≠ 0 := by
    intro h
    apply hq
    linarith
  have h2 : (1 : ℝ) - q ≠ 0 := by intro h; linarith
  have hR2 : R ^ 2 ≠ 0 := pow_ne_zero 2 hR
  have hq' : q ≠ 0 := ne_of_gt hq0
  simp [hR2, hq', h2, h1]

/-- **The `β⁻²` remainder of the first-order law is genuinely present.**  In the biased
two-point model the rescaled remainder converges to `4R²q(1−q)(1−2q) ≠ 0`. -/
theorem tendsto_remainder_biased {q R : ℝ} (hq0 : 0 < q) (hq1 : q < 1) (hR : 0 ≤ R) :
    Tendsto (fun β => β ^ 2 * (auditGap β (TwoPoint.r2 R) (pq q) TwoPoint.f2
        - cov (pq q) (TwoPoint.r2 R) TwoPoint.f2 / β)) atTop
      (𝓝 (4 * R ^ 2 * q * (1 - q) * (1 - 2 * q))) := by
  have h := tendsto_beta_sq_mul_auditGap_sub (R := R) (r := TwoPoint.r2 R) (p := pq q)
    (f := TwoPoint.f2) (pq_isPosDist hq0 hq1) (TwoPoint.abs_r2_le hR)
  rw [skewCov_pq] at h
  have heq : 8 * R ^ 2 * q * (1 - q) * (1 - 2 * q) / 2
      = 4 * R ^ 2 * q * (1 - q) * (1 - 2 * q) := by ring
  rwa [heq] at h

/-- **No `o(β⁻²)` improvement of the first-order law is possible.**  For a biased
reference policy the rescaled first-order remainder does *not* tend to zero, so the
exponent `2` in `RLHF.audit_gap_first_order` is optimal. -/
theorem remainder_not_littleO {q R : ℝ} (hq0 : 0 < q) (hq1 : q < 1) (hq : q ≠ 1 / 2)
    (hR : 0 < R) :
    ¬ Tendsto (fun β => β ^ 2 * (auditGap β (TwoPoint.r2 R) (pq q) TwoPoint.f2
        - cov (pq q) (TwoPoint.r2 R) TwoPoint.f2 / β)) atTop (𝓝 0) := by
  intro hzero
  have hlim := tendsto_remainder_biased hq0 hq1 hR.le
  have heq := tendsto_nhds_unique hlim hzero
  have hne : skewCov (pq q) (TwoPoint.r2 R) TwoPoint.f2 ≠ 0 :=
    skewCov_pq_ne_zero hq0 hq1 hq (ne_of_gt hR)
  rw [skewCov_pq] at hne
  apply hne
  linarith

end RLHF.Biased