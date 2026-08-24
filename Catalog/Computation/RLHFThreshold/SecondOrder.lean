import Computation.RLHFThreshold.Threshold

/-!
# The second-order hacking coefficient is a skew-covariance

Domain: Computation (alignment theory × perturbation theory).

The first-order law says the audit gap is `Cov_p(r,f)/β + O(β⁻²)`.  What *is* the
`β⁻²` term?  This file identifies it exactly: it is one half of the **skew
covariance**

`SkewCov_p(r,f) = 𝔼_p[(r − 𝔼_p r)² (f − 𝔼_p f)]`,

the correlation of the audit statistic with the *squared fluctuation* of the reward.

* `RLHF.skewCov` — the skew covariance;
* `RLHF.skewCov_eq` — `SkewCov_p(r,f) = Cov_p(r², f) − 2 𝔼_p[r] Cov_p(r,f)`;
* `RLHF.quadModel`, `RLHF.cov_quadModel` — the quadratic model of the likelihood ratio
  and its exact covariance with `f`;
* `RLHF.abs_tilt_sub_quadModel_osc` — the likelihood ratio agrees with its quadratic
  model up to an oscillation `40 (R/β)³`;
* `RLHF.audit_gap_second_order` — **the main result**:
  `|𝔼_{π_β} f − 𝔼_p f − Cov_p(r,f)/β − SkewCov_p(r,f)/(2β²)| ≤ 40 (R/β)³ σ_p(f)`;
* `RLHF.audit_gap_third_order_of_uncorrelated` — a statistic uncorrelated with the
  reward *and* with its squared fluctuation moves only at order `β⁻³`.

This refines `RLHF.audit_gap_first_order` (a statistic can be first-order safe yet
second-order hackable, precisely when `SkewCov ≠ 0`), and it exhibits the hierarchy of
audit invariants: order `β⁻ᵏ` safety is a statement about the `k`-th reward cumulant
pairing.
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω]

/-! ## 1. The skew covariance -/

/-- The **skew covariance** `𝔼_p[(r − 𝔼_p r)² (f − 𝔼_p f)]`: the pairing of the audit
statistic with the squared fluctuation of the reward. -/
noncomputable def skewCov (p r f : Ω → ℝ) : ℝ :=
  ∑ y, p y * ((r y - mean p r) ^ 2 * (f y - mean p f))

/-- Centred sums vanish. -/
theorem sum_centered_eq_zero {p : Ω → ℝ} (hp : IsDist p) (f : Ω → ℝ) :
    ∑ y, p y * (f y - mean p f) = 0 := by
  have h : ∀ y, p y * (f y - mean p f) = p y * f y - mean p f * p y := by
    intro y; ring
  rw [Finset.sum_congr rfl fun y _ => h y, Finset.sum_sub_distrib, ← Finset.mul_sum, hp.2]
  simp [mean]

/-- The covariance only needs one argument centred. -/
theorem cov_eq_sum_centered {p : Ω → ℝ} (hp : IsDist p) (g f : Ω → ℝ) :
    cov p g f = ∑ y, p y * (g y * (f y - mean p f)) := by
  have h : ∀ y, p y * ((g y - mean p g) * (f y - mean p f))
      = p y * (g y * (f y - mean p f)) - mean p g * (p y * (f y - mean p f)) := by
    intro y; ring
  rw [cov, Finset.sum_congr rfl fun y _ => h y, Finset.sum_sub_distrib, ← Finset.mul_sum,
    sum_centered_eq_zero hp f]
  ring

/-- `SkewCov_p(r,f) = Cov_p(r², f) − 2 𝔼_p[r] Cov_p(r,f)`: the skew covariance is the
third mixed cumulant of `(r, r, f)`. -/
theorem skewCov_eq {p : Ω → ℝ} (hp : IsDist p) (r f : Ω → ℝ) :
    skewCov p r f = cov p (fun y => r y ^ 2) f - 2 * mean p r * cov p r f := by
  rw [cov_eq_sum_centered hp, cov_eq_sum_centered hp, skewCov]
  have h : ∀ y, p y * ((r y - mean p r) ^ 2 * (f y - mean p f))
      = p y * (r y ^ 2 * (f y - mean p f))
        - 2 * mean p r * (p y * (r y * (f y - mean p f)))
        + (mean p r) ^ 2 * (p y * (f y - mean p f)) := by
    intro y; ring
  rw [Finset.sum_congr rfl fun y _ => h y, Finset.sum_add_distrib, Finset.sum_sub_distrib,
    ← Finset.mul_sum, ← Finset.mul_sum, sum_centered_eq_zero hp f]
  ring

/-! ## 2. The quadratic model of the likelihood ratio -/

/-- The second-order model of the likelihood ratio: `r/β + (r/β)²/2 − 𝔼_p[r](r/β)/β`
(constants are irrelevant inside a covariance, so the model is normalized to have no
constant term). -/
noncomputable def quadModel (β : ℝ) (r p : Ω → ℝ) : Ω → ℝ :=
  fun y => r y / β + (r y / β) ^ 2 / 2 - (mean p r / β) * (r y / β)

/-- **The quadratic model reproduces exactly the first two orders of the audit gap.** -/
theorem cov_quadModel {β : ℝ} {r p : Ω → ℝ} (hp : IsDist p) (hβ : β ≠ 0) (f : Ω → ℝ) :
    cov p (quadModel β r p) f = cov p r f / β + skewCov p r f / (2 * β ^ 2) := by
  rw [cov_eq_sum_centered hp, skewCov_eq hp, cov_eq_sum_centered hp r f,
    cov_eq_sum_centered hp (fun y => r y ^ 2) f]
  have h : ∀ y, p y * (quadModel β r p y * (f y - mean p f))
      = (1 / β) * (p y * (r y * (f y - mean p f)))
        + (1 / (2 * β ^ 2)) * (p y * (r y ^ 2 * (f y - mean p f)))
        - (mean p r / β ^ 2) * (p y * (r y * (f y - mean p f))) := by
    intro y
    unfold quadModel
    field_simp
  rw [Finset.sum_congr rfl fun y _ => h y, Finset.sum_sub_distrib, Finset.sum_add_distrib,
    ← Finset.mul_sum, ← Finset.mul_sum, ← Finset.mul_sum]
  field_simp
  ring

/-! ## 3. The cubic oscillation estimate -/

/-- Third-order Taylor bound for the exponential on `[−1, 1]`. -/
theorem abs_exp_sub_quadratic_le {x : ℝ} (hx : |x| ≤ 1) :
    |Real.exp x - 1 - x - x ^ 2 / 2| ≤ |x| ^ 3 := by
  have hb := Real.exp_bound hx (n := 3) (by norm_num)
  simp [Finset.sum_range_succ, Nat.factorial] at hb
  have heq : Real.exp x - 1 - x - x ^ 2 / 2 = Real.exp x - (1 + x + x ^ 2 / 2) := by ring
  rw [heq]
  nlinarith [abs_nonneg x, pow_nonneg (abs_nonneg x) 3, hb]

variable [Nonempty Ω]

omit [Nonempty Ω] in
/-- The mean reward inherits the uniform reward bound. -/
theorem abs_mean_le {R : ℝ} {r p : Ω → ℝ} (hp : IsDist p) (hR : ∀ y, |r y| ≤ R) :
    |mean p r| ≤ R := by
  have hbound : ∀ y ∈ (univ : Finset Ω), |p y * r y| ≤ p y * R := by
    intro y _
    rw [abs_mul, abs_of_nonneg (hp.1 y)]
    exact mul_le_mul_of_nonneg_left (hR y) (hp.1 y)
  calc |mean p r| ≤ ∑ y, |p y * r y| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ y, p y * R := Finset.sum_le_sum hbound
    _ = R := by rw [← Finset.sum_mul, hp.2, one_mul]

omit [Nonempty Ω] in
/-- Second-order estimate of the partition function: `|Z − 1 − 𝔼_p[r]/β| ≤ (R/β)²`. -/
theorem abs_partition_sub_one_sub_mean_le {β R : ℝ} {r p : Ω → ℝ} (hβ : 0 < β)
    (hp : IsPosDist p) (hR : ∀ y, |r y| ≤ R) (hRβ : R ≤ β) :
    |partition β r p - 1 - mean p r / β| ≤ (R / β) ^ 2 := by
  have ht1 : R / β ≤ 1 := by rw [div_le_one hβ]; exact hRβ
  have hsub : partition β r p - 1 - mean p r / β
      = ∑ y, p y * (Real.exp (r y / β) - 1 - r y / β) := by
    have h : ∀ y, p y * (Real.exp (r y / β) - 1 - r y / β)
        = p y * Real.exp (r y / β) - p y - (1 / β) * (p y * r y) := by
      intro y; field_simp
    rw [Finset.sum_congr rfl fun y _ => h y, Finset.sum_sub_distrib, Finset.sum_sub_distrib,
      ← Finset.mul_sum, hp.2]
    simp only [partition, mean]
    ring
  rw [hsub]
  have hbound : ∀ y ∈ (univ : Finset Ω), |p y * (Real.exp (r y / β) - 1 - r y / β)|
      ≤ p y * (R / β) ^ 2 := by
    intro y _
    have hu : |r y / β| ≤ R / β := by
      rw [abs_div, abs_of_pos hβ]
      exact (div_le_div_iff_of_pos_right hβ).mpr (hR y)
    have h1 : |Real.exp (r y / β) - 1 - r y / β| ≤ (r y / β) ^ 2 :=
      Real.abs_exp_sub_one_sub_id_le (le_trans hu ht1)
    have h2 : (r y / β) ^ 2 ≤ (R / β) ^ 2 := by
      nlinarith [abs_nonneg (r y / β), sq_abs (r y / β)]
    rw [abs_mul, abs_of_nonneg (hp.1 y).le]
    exact mul_le_mul_of_nonneg_left (h1.trans h2) (hp.1 y).le
  calc |∑ y, p y * (Real.exp (r y / β) - 1 - r y / β)|
      ≤ ∑ y, |p y * (Real.exp (r y / β) - 1 - r y / β)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ y, p y * (R / β) ^ 2 := Finset.sum_le_sum hbound
    _ = (R / β) ^ 2 := by rw [← Finset.sum_mul, hp.2, one_mul]

/-- **The likelihood ratio agrees with its quadratic model up to an oscillation of
order `(R/β)³`.** -/
theorem abs_tilt_sub_quadModel_osc {β R : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hR : ∀ y, |r y| ≤ R) (hRβ : R ≤ β) (x y : Ω) :
    |(tilt β r p x - quadModel β r p x) - (tilt β r p y - quadModel β r p y)|
      ≤ 40 * (R / β) ^ 3 := by
  have hR0 : 0 ≤ R := nonneg_of_abs_le hR
  have ht1 : R / β ≤ 1 := by rw [div_le_one hβ]; exact hRβ
  have ht0 : 0 ≤ R / β := by positivity
  have hZ := partition_pos (β := β) (r := r) hp
  have hZ3 : 1 / 3 ≤ partition β r p := partition_ge_third hβ hp hR hRβ
  have hZ1 : |partition β r p - 1| ≤ 3 * (R / β) := abs_partition_sub_one_le hβ hp hR hRβ
  have hrho : |partition β r p - 1 - mean p r / β| ≤ (R / β) ^ 2 :=
    abs_partition_sub_one_sub_mean_le hβ hp hR hRβ
  have habs : ∀ z : Ω, |r z / β| ≤ R / β := by
    intro z
    rw [abs_div, abs_of_pos hβ]
    exact (div_le_div_iff_of_pos_right hβ).mpr (hR z)
  have hm : |mean p r / β| ≤ R / β := by
    rw [abs_div, abs_of_pos hβ]
    exact (div_le_div_iff_of_pos_right hβ).mpr (abs_mean_le hp.isDist hR)
  have hcubic : ∀ z : Ω,
      |Real.exp (r z / β) - 1 - r z / β - (r z / β) ^ 2 / 2| ≤ (R / β) ^ 3 := by
    intro z
    have h1 : |r z / β| ≤ 1 := le_trans (habs z) ht1
    refine (abs_exp_sub_quadratic_le h1).trans ?_
    exact pow_le_pow_left₀ (abs_nonneg _) (habs z) 3
  -- the exact algebraic decomposition
  have hkey : (tilt β r p x - quadModel β r p x) - (tilt β r p y - quadModel β r p y)
      = (((Real.exp (r x / β) - 1 - r x / β - (r x / β) ^ 2 / 2)
            - (Real.exp (r y / β) - 1 - r y / β - (r y / β) ^ 2 / 2))
          + ((r x / β) ^ 2 - (r y / β) ^ 2) / 2 * (1 - partition β r p)
          + (r x / β - r y / β)
              * (1 - partition β r p + (mean p r / β) * partition β r p))
        / partition β r p := by
    unfold tilt quadModel
    field_simp
    ring
  rw [hkey, abs_div, abs_of_pos hZ, div_le_iff₀ hZ]
  -- bound the three pieces of the numerator
  have hA1 : |(Real.exp (r x / β) - 1 - r x / β - (r x / β) ^ 2 / 2)
      - (Real.exp (r y / β) - 1 - r y / β - (r y / β) ^ 2 / 2)| ≤ 2 * (R / β) ^ 3 := by
    refine le_trans (abs_sub _ _) ?_
    linarith [hcubic x, hcubic y]
  have hsq : |((r x / β) ^ 2 - (r y / β) ^ 2) / 2| ≤ (R / β) ^ 2 / 2 := by
    rw [abs_div, abs_of_pos (by norm_num : (0:ℝ) < 2)]
    have hx2 : (r x / β) ^ 2 ≤ (R / β) ^ 2 := by
      nlinarith [abs_nonneg (r x / β), sq_abs (r x / β), habs x]
    have hy2 : (r y / β) ^ 2 ≤ (R / β) ^ 2 := by
      nlinarith [abs_nonneg (r y / β), sq_abs (r y / β), habs y]
    have hxy : |(r x / β) ^ 2 - (r y / β) ^ 2| ≤ (R / β) ^ 2 := by
      rw [abs_le]
      constructor <;> nlinarith [sq_nonneg (r x / β), sq_nonneg (r y / β)]
    linarith
  have hA2 : |((r x / β) ^ 2 - (r y / β) ^ 2) / 2 * (1 - partition β r p)|
      ≤ 3 * (R / β) ^ 3 / 2 := by
    rw [abs_mul]
    have hZ1' : |1 - partition β r p| ≤ 3 * (R / β) := by
      rw [abs_sub_comm]; exact hZ1
    have := mul_le_mul hsq hZ1' (abs_nonneg _) (by positivity)
    calc |((r x / β) ^ 2 - (r y / β) ^ 2) / 2| * |1 - partition β r p|
        ≤ (R / β) ^ 2 / 2 * (3 * (R / β)) := this
      _ = 3 * (R / β) ^ 3 / 2 := by ring
  have hlin : |1 - partition β r p + (mean p r / β) * partition β r p| ≤ 4 * (R / β) ^ 2 := by
    have hsplit : 1 - partition β r p + (mean p r / β) * partition β r p
        = -(partition β r p - 1 - mean p r / β)
          + (mean p r / β) * (partition β r p - 1) := by ring
    rw [hsplit]
    have h1 : |(mean p r / β) * (partition β r p - 1)| ≤ (R / β) * (3 * (R / β)) := by
      rw [abs_mul]
      exact mul_le_mul hm hZ1 (abs_nonneg _) ht0
    calc |-(partition β r p - 1 - mean p r / β) + (mean p r / β) * (partition β r p - 1)|
        ≤ |-(partition β r p - 1 - mean p r / β)|
          + |(mean p r / β) * (partition β r p - 1)| := abs_add_le _ _
      _ ≤ (R / β) ^ 2 + (R / β) * (3 * (R / β)) := by
          rw [abs_neg]; linarith
      _ = 4 * (R / β) ^ 2 := by ring
  have hA3 : |(r x / β - r y / β)
      * (1 - partition β r p + (mean p r / β) * partition β r p)| ≤ 8 * (R / β) ^ 3 := by
    rw [abs_mul]
    have hd : |r x / β - r y / β| ≤ 2 * (R / β) := by
      refine le_trans (abs_sub _ _) ?_
      linarith [habs x, habs y]
    have := mul_le_mul hd hlin (abs_nonneg _) (by positivity)
    calc |r x / β - r y / β| * |1 - partition β r p + (mean p r / β) * partition β r p|
        ≤ (2 * (R / β)) * (4 * (R / β) ^ 2) := this
      _ = 8 * (R / β) ^ 3 := by ring
  have hnum : |((Real.exp (r x / β) - 1 - r x / β - (r x / β) ^ 2 / 2)
        - (Real.exp (r y / β) - 1 - r y / β - (r y / β) ^ 2 / 2))
      + ((r x / β) ^ 2 - (r y / β) ^ 2) / 2 * (1 - partition β r p)
      + (r x / β - r y / β) * (1 - partition β r p + (mean p r / β) * partition β r p)|
      ≤ 12 * (R / β) ^ 3 := by
    calc |((Real.exp (r x / β) - 1 - r x / β - (r x / β) ^ 2 / 2)
          - (Real.exp (r y / β) - 1 - r y / β - (r y / β) ^ 2 / 2))
        + ((r x / β) ^ 2 - (r y / β) ^ 2) / 2 * (1 - partition β r p)
        + (r x / β - r y / β) * (1 - partition β r p + (mean p r / β) * partition β r p)|
        ≤ |((Real.exp (r x / β) - 1 - r x / β - (r x / β) ^ 2 / 2)
              - (Real.exp (r y / β) - 1 - r y / β - (r y / β) ^ 2 / 2))
            + ((r x / β) ^ 2 - (r y / β) ^ 2) / 2 * (1 - partition β r p)|
          + |(r x / β - r y / β)
              * (1 - partition β r p + (mean p r / β) * partition β r p)| := abs_add_le _ _
      _ ≤ (2 * (R / β) ^ 3 + 3 * (R / β) ^ 3 / 2) + 8 * (R / β) ^ 3 := by
          have := abs_add_le ((Real.exp (r x / β) - 1 - r x / β - (r x / β) ^ 2 / 2)
              - (Real.exp (r y / β) - 1 - r y / β - (r y / β) ^ 2 / 2))
            (((r x / β) ^ 2 - (r y / β) ^ 2) / 2 * (1 - partition β r p))
          linarith
      _ ≤ 12 * (R / β) ^ 3 := by linarith [pow_nonneg ht0 3]
  have hfinal : 12 * (R / β) ^ 3 ≤ 40 * (R / β) ^ 3 * partition β r p := by
    nlinarith [pow_nonneg ht0 3]
  linarith

/-! ## 4. The second-order law -/

/-- **The audit gap to second order.**  For `|r| ≤ R ≤ β`,
`|𝔼_{π_β} f − 𝔼_p f − Cov_p(r,f)/β − SkewCov_p(r,f)/(2β²)| ≤ 40 (R/β)³ σ_p(f)`.
The `β⁻²` coefficient of reward hacking is the pairing of the audit statistic with the
*squared fluctuation* of the reward. -/
theorem audit_gap_second_order {β R : ℝ} {r p f : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hR : ∀ y, |r y| ≤ R) (hRβ : R ≤ β) :
    |mean (gibbsPolicy β r p) f - mean p f - cov p r f / β - skewCov p r f / (2 * β ^ 2)|
      ≤ 40 * (R / β) ^ 3 * Real.sqrt (variance p f) := by
  have hR0 : 0 ≤ R := nonneg_of_abs_le hR
  have hgap : mean (gibbsPolicy β r p) f - mean p f = cov p (tilt β r p) f :=
    mean_gibbs_sub_mean hp f
  have hsplit : cov p (tilt β r p) f
      = cov p (quadModel β r p) f
        + cov p (fun y => tilt β r p y - quadModel β r p y) f := by
    rw [cov_sub_left hp.isDist]
    ring
  have hquad := cov_quadModel (β := β) (r := r) hp.isDist (ne_of_gt hβ) f
  have heq : mean (gibbsPolicy β r p) f - mean p f - cov p r f / β
      - skewCov p r f / (2 * β ^ 2)
      = cov p (fun y => tilt β r p y - quadModel β r p y) f := by
    rw [hgap, hsplit, hquad]
    ring
  rw [heq]
  refine (abs_cov_le hp.isDist _ f).trans ?_
  have hosc : Real.sqrt (variance p (fun y => tilt β r p y - quadModel β r p y))
      ≤ 40 * (R / β) ^ 3 :=
    sqrt_variance_le_of_osc hp.isDist (by positivity) fun x y =>
      abs_tilt_sub_quadModel_osc hβ hp hR hRβ x y
  exact mul_le_mul_of_nonneg_right hosc (Real.sqrt_nonneg _)

/-- **The skew covariance is exactly the second-order hacking rate.**
`β²·(G(β) − Cov_p(r,f)/β) → SkewCov_p(r,f)/2` as `β → ∞`. -/
theorem tendsto_beta_sq_mul_auditGap_sub {R : ℝ} {r p f : Ω → ℝ} (hp : IsPosDist p)
    (hR : ∀ y, |r y| ≤ R) :
    Filter.Tendsto (fun β => β ^ 2 * (auditGap β r p f - cov p r f / β)) Filter.atTop
      (nhds (skewCov p r f / 2)) := by
  have hR0 : 0 ≤ R := nonneg_of_abs_le hR
  rw [tendsto_iff_dist_tendsto_zero]
  have hzero : Filter.Tendsto
      (fun β : ℝ => 40 * R ^ 3 * Real.sqrt (variance p f) / β) Filter.atTop (nhds 0) :=
    Filter.Tendsto.div_atTop tendsto_const_nhds Filter.tendsto_id
  refine squeeze_zero' (Filter.Eventually.of_forall fun β => dist_nonneg) ?_ hzero
  filter_upwards [Filter.eventually_ge_atTop (max R 1)] with β hβ
  have hβ1 : (1 : ℝ) ≤ β := le_trans (le_max_right R 1) hβ
  have hβ0 : 0 < β := lt_of_lt_of_le zero_lt_one hβ1
  have hRβ : R ≤ β := le_trans (le_max_left R 1) hβ
  have h := audit_gap_second_order (f := f) hβ0 hp hR hRβ
  have hdist : dist (β ^ 2 * (auditGap β r p f - cov p r f / β)) (skewCov p r f / 2)
      = β ^ 2 * |auditGap β r p f - cov p r f / β - skewCov p r f / (2 * β ^ 2)| := by
    rw [Real.dist_eq, ← abs_of_pos (by positivity : (0:ℝ) < β ^ 2), ← abs_mul,
      abs_of_pos (by positivity : (0:ℝ) < β ^ 2)]
    congr 1
    field_simp
  rw [hdist, auditGap]
  have hstep := mul_le_mul_of_nonneg_left h (by positivity : (0:ℝ) ≤ β ^ 2)
  refine hstep.trans_eq ?_
  field_simp

/-- **Second-order safety.**  A statistic that is uncorrelated with the reward *and*
with its squared fluctuation cannot be hacked before order `β⁻³`. -/
theorem audit_gap_third_order_of_uncorrelated {β R : ℝ} {r p f : Ω → ℝ} (hβ : 0 < β)
    (hp : IsPosDist p) (hR : ∀ y, |r y| ≤ R) (hRβ : R ≤ β) (hcov : cov p r f = 0)
    (hskew : skewCov p r f = 0) :
    |mean (gibbsPolicy β r p) f - mean p f| ≤ 40 * (R / β) ^ 3 * Real.sqrt (variance p f) := by
  have h := audit_gap_second_order (f := f) hβ hp hR hRβ
  rwa [hcov, hskew, zero_div, zero_div, sub_zero, sub_zero] at h

end RLHF