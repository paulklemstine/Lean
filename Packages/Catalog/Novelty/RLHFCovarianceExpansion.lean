import Novelty.RLHFVarianceDrift

/-!
# Reward hacking is a covariance, to first order in `β⁻¹`

Domain: Novelty (information theory × perturbation theory × alignment theory).

`Novelty.RLHFVarianceDrift` bounds the audit gap of an arbitrary statistic `f` by
`(e^{range r/β}/β) σ_p(r) σ_p(f)`.  That bound is uniform but blind to *which*
statistics actually move: Conjecture C4 of the first cycle predicted that the gap is,
to leading order, the reference covariance of the audit statistic with the reward,
so that statistics uncorrelated with the reward model cannot be hacked at first
order.  This file proves that prediction with an explicit second-order remainder.

* `RLHF.cov_sub_left`, `RLHF.cov_div_left` — bilinearity of the covariance;
* `RLHF.sqrt_variance_le_of_osc` — an oscillation bound controls the standard
  deviation (via the pair representation of the variance);
* `RLHF.abs_tilt_sub_linear_le` — the likelihood ratio `e^{r/β}/Z` agrees with its
  linearization `r/β` up to an oscillation of order `(R/β)²`;
* `RLHF.audit_gap_first_order` — **the main result**:
  `|𝔼_{π_β} f − 𝔼_p f − Cov_p(r, f)/β| ≤ 24 (R/β)² σ_p(f)` for `|r| ≤ R ≤ β`;
* `RLHF.audit_gap_of_uncorrelated` — hence an audit statistic uncorrelated with the
  reward moves by `O(β⁻²)`, not `O(β⁻¹)`: *first-order reward hacking requires
  correlation with the reward model.*
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω]

/-! ## 1. Bilinearity of the covariance, and oscillation bounds -/

theorem mean_sub (p g h : Ω → ℝ) :
    mean p (fun y => g y - h y) = mean p g - mean p h := by
  rw [mean, mean, mean, ← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl fun y _ => by ring

theorem cov_sub_left {p : Ω → ℝ} (hp : IsDist p) (g h f : Ω → ℝ) :
    cov p (fun y => g y - h y) f = cov p g f - cov p h f := by
  rw [cov_eq_sub hp, cov_eq_sub hp, cov_eq_sub hp, mean_sub]
  have hprod : mean p (fun y => (g y - h y) * f y)
      = mean p (fun y => g y * f y) - mean p (fun y => h y * f y) := by
    rw [mean, mean, mean, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun y _ => by ring
  rw [hprod]
  ring

theorem cov_div_left {p : Ω → ℝ} (hp : IsDist p) (g f : Ω → ℝ) (c : ℝ) :
    cov p (fun y => g y / c) f = cov p g f / c := by
  have hmean : mean p (fun y => g y / c) = mean p g / c := by
    rw [mean, mean, Finset.sum_div]
    exact Finset.sum_congr rfl fun y _ => by ring
  rw [cov_eq_sub hp, cov_eq_sub hp, hmean]
  have hprod : mean p (fun y => g y / c * f y) = mean p (fun y => g y * f y) / c := by
    rw [mean, mean, Finset.sum_div]
    exact Finset.sum_congr rfl fun y _ => by ring
  rw [hprod]
  ring

/-- A uniform oscillation bound controls the standard deviation. -/
theorem sqrt_variance_le_of_osc {p g : Ω → ℝ} {c : ℝ} (hp : IsDist p) (hc : 0 ≤ c)
    (h : ∀ x y, |g x - g y| ≤ c) : Real.sqrt (variance p g) ≤ c := by
  have hvar : variance p g ≤ c ^ 2 := by
    rw [variance_eq_pair hp]
    have hbound : ∑ x, ∑ y, p x * p y * (g x - g y) ^ 2
        ≤ ∑ x, ∑ y, p x * p y * c ^ 2 := by
      refine Finset.sum_le_sum fun x _ => Finset.sum_le_sum fun y _ => ?_
      have hpx := hp.1 x
      have hpy := hp.1 y
      have hxy := h x y
      have hsq : (g x - g y) ^ 2 ≤ c ^ 2 := by
        nlinarith [abs_nonneg (g x - g y), sq_abs (g x - g y)]
      nlinarith [mul_nonneg hpx hpy]
    have hrhs : ∑ x, ∑ y, p x * p y * c ^ 2 = c ^ 2 := by
      have hinner : ∀ x, ∑ y, p x * p y * c ^ 2 = (p x * c ^ 2) * ∑ y, p y := by
        intro x
        rw [Finset.mul_sum]
        exact Finset.sum_congr rfl fun y _ => by ring
      rw [Finset.sum_congr rfl fun x _ => hinner x, hp.2]
      simp only [mul_one]
      rw [← Finset.sum_mul, hp.2, one_mul]
    linarith [sq_nonneg c]
  calc Real.sqrt (variance p g) ≤ Real.sqrt (c ^ 2) := Real.sqrt_le_sqrt hvar
    _ = c := Real.sqrt_sq hc

/-! ## 2. The tilt agrees with its linearization to second order -/

variable [Nonempty Ω]

theorem exp_one_le_three : Real.exp 1 ≤ 3 := by linarith [Real.exp_one_lt_d9]

theorem partition_ge_third {β R : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hR : ∀ y, |r y| ≤ R) (hRβ : R ≤ β) : 1 / 3 ≤ partition β r p := by
  have hinf : Real.exp (univ.inf' univ_nonempty r / β) ≤ partition β r p :=
    exp_inf_le_partition hβ hp
  have hlow : -R ≤ univ.inf' univ_nonempty r := by
    refine Finset.le_inf' univ_nonempty r fun y _ => ?_
    have := hR y
    cases' abs_le.1 this with h1 _
    exact h1
  have hR0 : 0 ≤ R := le_trans (abs_nonneg (r (Classical.arbitrary Ω)))
    (hR (Classical.arbitrary Ω))
  have hdiv : (-1 : ℝ) ≤ univ.inf' univ_nonempty r / β := by
    rw [le_div_iff₀ hβ]
    linarith
  have h1 : Real.exp (-1 : ℝ) ≤ Real.exp (univ.inf' univ_nonempty r / β) :=
    Real.exp_le_exp.2 hdiv
  have h2 : (1 : ℝ) / 3 ≤ Real.exp (-1 : ℝ) := by
    rw [Real.exp_neg, le_inv_comm₀ (by norm_num) (Real.exp_pos 1)]
    linarith [exp_one_le_three]
  linarith

theorem abs_partition_sub_one_le {β R : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hR : ∀ y, |r y| ≤ R) (hRβ : R ≤ β) : |partition β r p - 1| ≤ 3 * (R / β) := by
  have hR0 : 0 ≤ R := le_trans (abs_nonneg (r (Classical.arbitrary Ω)))
    (hR (Classical.arbitrary Ω))
  have ht1 : R / β ≤ 1 := by rw [div_le_one hβ]; exact hRβ
  have ht0 : 0 ≤ R / β := by positivity
  have hsub : partition β r p - 1 = ∑ y, p y * (Real.exp (r y / β) - 1) := by
    have h : ∀ y, p y * (Real.exp (r y / β) - 1) = p y * Real.exp (r y / β) - p y := by
      intro y; ring
    rw [Finset.sum_congr rfl fun y _ => h y, Finset.sum_sub_distrib, hp.2]
    rfl
  rw [hsub]
  have hbound : ∀ y ∈ (univ : Finset Ω), |p y * (Real.exp (r y / β) - 1)|
      ≤ p y * (3 * (R / β)) := by
    intro y _
    have hu : |r y / β| ≤ R / β := by
      rw [abs_div, abs_of_pos hβ]
      exact (div_le_div_iff_of_pos_right hβ).mpr (hR y)
    have h1 : |Real.exp (r y / β) - 1| ≤ |r y / β| * Real.exp |r y / β| :=
      abs_exp_sub_one_le_mul (r y / β)
    have h2 : Real.exp |r y / β| ≤ 3 := by
      refine le_trans (Real.exp_le_exp.2 (le_trans hu ht1)) exp_one_le_three
    have h3 : |r y / β| * Real.exp |r y / β| ≤ (R / β) * 3 := by
      have := mul_le_mul hu h2 (Real.exp_pos _).le ht0
      exact this
    rw [abs_mul, abs_of_nonneg (hp.1 y).le]
    have := mul_le_mul_of_nonneg_left (h1.trans h3) (hp.1 y).le
    linarith [this]
  calc |∑ y, p y * (Real.exp (r y / β) - 1)|
      ≤ ∑ y, |p y * (Real.exp (r y / β) - 1)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ y, p y * (3 * (R / β)) := Finset.sum_le_sum hbound
    _ = 3 * (R / β) := by rw [← Finset.sum_mul, hp.2, one_mul]

/-- **The likelihood ratio is its own linearization, up to `O((R/β)²)` oscillation.**
The tilt `e^{r/β}/Z` differs from `r/β` by a function whose oscillation is at most
`24 (R/β)²`; the linear part carries all of the first-order effect. -/
theorem abs_tilt_sub_linear_le {β R : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hR : ∀ y, |r y| ≤ R) (hRβ : R ≤ β) (x y : Ω) :
    |(tilt β r p x - r x / β) - (tilt β r p y - r y / β)| ≤ 24 * (R / β) ^ 2 := by
  have hR0 : 0 ≤ R := le_trans (abs_nonneg (r (Classical.arbitrary Ω)))
    (hR (Classical.arbitrary Ω))
  have ht1 : R / β ≤ 1 := by rw [div_le_one hβ]; exact hRβ
  have ht0 : 0 ≤ R / β := by positivity
  have hZ := partition_pos (β := β) (r := r) hp
  have hZ3 : 1 / 3 ≤ partition β r p := partition_ge_third hβ hp hR hRβ
  have hZ1 : |partition β r p - 1| ≤ 3 * (R / β) := abs_partition_sub_one_le hβ hp hR hRβ
  have habs : ∀ z : Ω, |r z / β| ≤ R / β := by
    intro z
    rw [abs_div, abs_of_pos hβ]
    exact (div_le_div_iff_of_pos_right hβ).mpr (hR z)
  have hrem : ∀ z : Ω, |Real.exp (r z / β) - 1 - r z / β| ≤ (R / β) ^ 2 := by
    intro z
    have h1 : |r z / β| ≤ 1 := le_trans (habs z) ht1
    have h2 := Real.abs_exp_sub_one_sub_id_le h1
    have h3 : (r z / β) ^ 2 ≤ (R / β) ^ 2 := by
      have := habs z
      nlinarith [abs_nonneg (r z / β), sq_abs (r z / β)]
    linarith
  -- decompose the difference
  have hkey : (tilt β r p x - r x / β) - (tilt β r p y - r y / β)
      = (((Real.exp (r x / β) - 1 - r x / β) - (Real.exp (r y / β) - 1 - r y / β))
          + (1 - partition β r p) * (r x / β - r y / β)) / partition β r p := by
    unfold tilt
    field_simp
    ring
  rw [hkey, abs_div, abs_of_pos hZ, div_le_iff₀ hZ]
  have hnum : |((Real.exp (r x / β) - 1 - r x / β) - (Real.exp (r y / β) - 1 - r y / β))
      + (1 - partition β r p) * (r x / β - r y / β)| ≤ 8 * (R / β) ^ 2 := by
    have h1 : |(Real.exp (r x / β) - 1 - r x / β) - (Real.exp (r y / β) - 1 - r y / β)|
        ≤ 2 * (R / β) ^ 2 := by
      refine le_trans (abs_sub _ _) ?_
      linarith [hrem x, hrem y]
    have h2 : |(1 - partition β r p) * (r x / β - r y / β)| ≤ 6 * (R / β) ^ 2 := by
      rw [abs_mul]
      have hA : |1 - partition β r p| ≤ 3 * (R / β) := by
        rw [abs_sub_comm]; exact hZ1
      have hB : |r x / β - r y / β| ≤ 2 * (R / β) := by
        refine le_trans (abs_sub _ _) ?_
        linarith [habs x, habs y]
      have := mul_le_mul hA hB (abs_nonneg _) (by positivity)
      calc |1 - partition β r p| * |r x / β - r y / β| ≤ (3 * (R / β)) * (2 * (R / β)) := this
        _ = 6 * (R / β) ^ 2 := by ring
    calc |((Real.exp (r x / β) - 1 - r x / β) - (Real.exp (r y / β) - 1 - r y / β))
          + (1 - partition β r p) * (r x / β - r y / β)|
        ≤ |(Real.exp (r x / β) - 1 - r x / β) - (Real.exp (r y / β) - 1 - r y / β)|
          + |(1 - partition β r p) * (r x / β - r y / β)| := abs_add_le _ _
      _ ≤ 8 * (R / β) ^ 2 := by linarith
  have hfinal : 8 * (R / β) ^ 2 ≤ 24 * (R / β) ^ 2 * partition β r p := by
    nlinarith [sq_nonneg (R / β)]
  linarith

/-! ## 3. First-order expansion of the audit gap -/

/-- **The audit gap is a covariance to first order.**  For a reward bounded by `R` and
a temperature `β ≥ R`, every statistic `f` satisfies
`|𝔼_{π_β} f − 𝔼_p f − Cov_p(r, f)/β| ≤ 24 (R/β)² σ_p(f)`. -/
theorem audit_gap_first_order {β R : ℝ} {r p f : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hR : ∀ y, |r y| ≤ R) (hRβ : R ≤ β) :
    |mean (gibbsPolicy β r p) f - mean p f - cov p r f / β|
      ≤ 24 * (R / β) ^ 2 * Real.sqrt (variance p f) := by
  have hR0 : 0 ≤ R := le_trans (abs_nonneg (r (Classical.arbitrary Ω)))
    (hR (Classical.arbitrary Ω))
  have hgap : mean (gibbsPolicy β r p) f - mean p f = cov p (tilt β r p) f :=
    mean_gibbs_sub_mean hp f
  have hsplit : cov p (tilt β r p) f
      = cov p (fun y => r y / β) f + cov p (fun y => tilt β r p y - r y / β) f := by
    rw [cov_sub_left hp.isDist]
    ring
  have hlin : cov p (fun y => r y / β) f = cov p r f / β := cov_div_left hp.isDist r f β
  have hrem : |cov p (fun y => tilt β r p y - r y / β) f|
      ≤ 24 * (R / β) ^ 2 * Real.sqrt (variance p f) := by
    refine (abs_cov_le hp.isDist _ f).trans ?_
    have hosc : Real.sqrt (variance p (fun y => tilt β r p y - r y / β))
        ≤ 24 * (R / β) ^ 2 := by
      refine sqrt_variance_le_of_osc hp.isDist (by positivity) fun x y => ?_
      exact abs_tilt_sub_linear_le hβ hp hR hRβ x y
    exact mul_le_mul_of_nonneg_right hosc (Real.sqrt_nonneg _)
  have heq : mean (gibbsPolicy β r p) f - mean p f - cov p r f / β
      = cov p (fun y => tilt β r p y - r y / β) f := by
    rw [hgap, hsplit, hlin]
    ring
  rw [heq]
  exact hrem

/-- **First-order reward hacking requires correlation with the reward model.**
If an audit statistic is uncorrelated with the reward under the reference policy, its
mean can only move by `O(β⁻²)` — one order better than the uniform `O(β⁻¹)` guarantee
of `RLHF.audit_gap_le_stddev`. -/
theorem audit_gap_of_uncorrelated {β R : ℝ} {r p f : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hR : ∀ y, |r y| ≤ R) (hRβ : R ≤ β) (hcov : cov p r f = 0) :
    |mean (gibbsPolicy β r p) f - mean p f| ≤ 24 * (R / β) ^ 2 * Real.sqrt (variance p f) := by
  have := audit_gap_first_order (f := f) hβ hp hR hRβ
  rwa [hcov, zero_div, sub_zero] at this

end RLHF