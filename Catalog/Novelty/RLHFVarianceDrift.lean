import Novelty.RLHFQuadraticDrift

/-!
# The alignment drift constant is the reward *variance*, not its range

Domain: Novelty (information theory × convex analysis × alignment theory).

`Novelty.RLHFQuadraticDrift` proves the `Θ(β⁻¹)` drift law
`‖π_β − p‖₁ ≤ (range r / β) · exp(range r / (2β))`, whose constant is the reward
*range* `max r − min r`.  Conjecture C1 of the previous cycle asserted that the
range is an artifact of a crude `L∞` estimate and that the true constant is the
reward *standard deviation* under the reference policy.  This file proves that
conjecture (up to an absolute factor):

* `RLHF.variance_tilt_le` — the exponential tilt `y ↦ e^{r y/β}/Z` has variance at
  most `(e^{range r/β}/β)² · Var_p(r)`;
* `RLHF.kl_gibbs_le_variance` — hence `KL(π_β ‖ p) ≤ e^{range r/β} · Var_p(r)/β²`;
* `RLHF.gibbs_l1_le_variance` — hence `‖π_β − p‖₁ ≤ √(2 e^{range r/β} Var_p r)/β`;
* `RLHF.audit_gap_le_stddev` — for *every* audit statistic `f`,
  `|𝔼_{π_β} f − 𝔼_p f| ≤ (e^{range r/β}/β) · σ_p(r) · σ_p(f)`: reward hacking is
  controlled by the *fluctuation* of the audit statistic, not by its magnitude.

Since `Var_p(r) ≤ range(r)²/4` always, and can be arbitrarily smaller (a reward that
is nearly constant on the bulk of `p` but spikes on a rare response), these bounds
strictly refine the previous cycle's.  The engine of the proof is the *pair
representation* `Var_p(f) = ½ ∑_{x,y} p x p y (f x − f y)²`, which converts a
pointwise Lipschitz estimate on the tilt into a variance comparison with no
differentiation anywhere.
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω]

/-! ## 1. Mean, variance and covariance on a finite probability space -/

/-- The mean `𝔼_p[f] = ∑ y p y · f y`. -/
noncomputable def mean (p f : Ω → ℝ) : ℝ := ∑ y, p y * f y

/-- The variance `Var_p(f) = 𝔼_p[(f − 𝔼_p f)²]`. -/
noncomputable def variance (p f : Ω → ℝ) : ℝ := ∑ y, p y * (f y - mean p f) ^ 2

/-- The covariance `Cov_p(f, g) = 𝔼_p[(f − 𝔼_p f)(g − 𝔼_p g)]`. -/
noncomputable def cov (p f g : Ω → ℝ) : ℝ :=
  ∑ y, p y * ((f y - mean p f) * (g y - mean p g))

theorem variance_nonneg {p : Ω → ℝ} (hp : IsDist p) (f : Ω → ℝ) : 0 ≤ variance p f := by
  refine Finset.sum_nonneg fun y _ => ?_
  have := hp.1 y
  positivity

theorem cov_self (p f : Ω → ℝ) : cov p f f = variance p f := by
  refine Finset.sum_congr rfl fun y _ => by ring

/-- Covariance in raw-moment form. -/
theorem cov_eq_sub {p : Ω → ℝ} (hp : IsDist p) (f g : Ω → ℝ) :
    cov p f g = mean p (fun y => f y * g y) - mean p f * mean p g := by
  have h : ∀ y, p y * ((f y - mean p f) * (g y - mean p g))
      = p y * (f y * g y) - mean p g * (p y * f y) - mean p f * (p y * g y)
        + (mean p f * mean p g) * p y := by
    intro y; ring
  rw [cov, Finset.sum_congr rfl fun y _ => h y]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_sub_distrib,
    ← Finset.mul_sum, ← Finset.mul_sum, ← Finset.mul_sum, hp.2]
  simp only [mean]
  ring

/-- **Pair representation of the variance**: `Var_p(f) = ½ ∑_{x,y} p x p y (f x − f y)²`.
This is the identity that lets a pointwise Lipschitz bound be transported to a
variance comparison. -/
theorem variance_eq_pair {p : Ω → ℝ} (hp : IsDist p) (f : Ω → ℝ) :
    variance p f = (∑ x, ∑ y, p x * p y * (f x - f y) ^ 2) / 2 := by
  have hinner : ∀ x, ∑ y, p x * p y * (f x - f y) ^ 2
      = (p x * (f x ^ 2)) * (∑ y, p y) - 2 * (p x * f x) * (∑ y, p y * f y)
        + p x * (∑ y, p y * (f y ^ 2)) := by
    intro x
    have h : ∀ y, p x * p y * (f x - f y) ^ 2
        = (p x * (f x ^ 2)) * p y - 2 * (p x * f x) * (p y * f y)
          + p x * (p y * (f y ^ 2)) := by
      intro y; ring
    rw [Finset.sum_congr rfl fun y _ => h y, Finset.sum_add_distrib, Finset.sum_sub_distrib,
      ← Finset.mul_sum, ← Finset.mul_sum, ← Finset.mul_sum]
  rw [Finset.sum_congr rfl fun x _ => hinner x, hp.2]
  have hexp : ∀ x, (p x * (f x ^ 2)) * 1 - 2 * (p x * f x) * (∑ y, p y * f y)
      + p x * (∑ y, p y * (f y ^ 2))
      = p x * (f x ^ 2) - 2 * (∑ y, p y * f y) * (p x * f x)
        + (∑ y, p y * (f y ^ 2)) * p x := by
    intro x; ring
  rw [Finset.sum_congr rfl fun x _ => hexp x, Finset.sum_add_distrib, Finset.sum_sub_distrib,
    ← Finset.mul_sum, ← Finset.mul_sum, hp.2]
  have hvar : variance p f = (∑ y, p y * (f y ^ 2)) - (∑ y, p y * f y) ^ 2 := by
    have := cov_eq_sub hp f f
    rw [cov_self] at this
    simpa [mean, sq] using this
  rw [hvar]
  ring

/-- A pointwise comparison of oscillations upgrades to a comparison of variances. -/
theorem variance_le_of_pair {p f g : Ω → ℝ} {c : ℝ} (hp : IsDist p)
    (h : ∀ x y, (f x - f y) ^ 2 ≤ c * (g x - g y) ^ 2) :
    variance p f ≤ c * variance p g := by
  have key : (∑ x, ∑ y, p x * p y * (f x - f y) ^ 2)
      ≤ c * ∑ x, ∑ y, p x * p y * (g x - g y) ^ 2 := by
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum fun x _ => ?_
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum fun y _ => ?_
    have hpx := hp.1 x
    have hpy := hp.1 y
    have := h x y
    nlinarith [mul_nonneg hpx hpy]
  rw [variance_eq_pair hp, variance_eq_pair hp]
  linarith

/-- The mean minimizes the mean square deviation: `Var_p(f) ≤ 𝔼_p[(f − c)²]` for every
centre `c`. -/
theorem variance_le_of_center {p : Ω → ℝ} (hp : IsDist p) (f : Ω → ℝ) (c : ℝ) :
    variance p f ≤ ∑ y, p y * (f y - c) ^ 2 := by
  have hcentre : ∑ y, p y * (f y - mean p f) = 0 := by
    have h : ∀ y, p y * (f y - mean p f) = p y * f y - mean p f * p y := by
      intro y; ring
    rw [Finset.sum_congr rfl fun y _ => h y, Finset.sum_sub_distrib, ← Finset.mul_sum, hp.2]
    simp [mean]
  have hexpand : ∀ y, p y * (f y - c) ^ 2
      = p y * (f y - mean p f) ^ 2 + 2 * (mean p f - c) * (p y * (f y - mean p f))
        + (mean p f - c) ^ 2 * p y := by
    intro y; ring
  rw [Finset.sum_congr rfl fun y _ => hexpand y, Finset.sum_add_distrib, Finset.sum_add_distrib,
    ← Finset.mul_sum, ← Finset.mul_sum, hcentre, hp.2]
  have : (0:ℝ) ≤ (mean p f - c) ^ 2 := sq_nonneg _
  simp only [variance, mul_zero, mul_one, add_zero]
  linarith

/-- Cauchy–Schwarz for the covariance. -/
theorem abs_cov_le {p : Ω → ℝ} (hp : IsDist p) (f g : Ω → ℝ) :
    |cov p f g| ≤ Real.sqrt (variance p f) * Real.sqrt (variance p g) := by
  have hsq : (cov p f g) ^ 2 ≤ variance p f * variance p g := by
    have hcs := Finset.sum_mul_sq_le_sq_mul_sq (univ : Finset Ω)
      (fun y => Real.sqrt (p y) * (f y - mean p f))
      (fun y => Real.sqrt (p y) * (g y - mean p g))
    have h1 : ∀ y, (Real.sqrt (p y) * (f y - mean p f)) *
        (Real.sqrt (p y) * (g y - mean p g))
        = p y * ((f y - mean p f) * (g y - mean p g)) := by
      intro y
      rw [mul_mul_mul_comm, Real.mul_self_sqrt (hp.1 y)]
    have h2 : ∀ y, (Real.sqrt (p y) * (f y - mean p f)) ^ 2 = p y * (f y - mean p f) ^ 2 := by
      intro y
      have : Real.sqrt (p y) ^ 2 = p y := Real.sq_sqrt (hp.1 y)
      nlinarith [this]
    have h3 : ∀ y, (Real.sqrt (p y) * (g y - mean p g)) ^ 2 = p y * (g y - mean p g) ^ 2 := by
      intro y
      have : Real.sqrt (p y) ^ 2 = p y := Real.sq_sqrt (hp.1 y)
      nlinarith [this]
    rw [Finset.sum_congr rfl fun y _ => h1 y, Finset.sum_congr rfl fun y _ => h2 y,
      Finset.sum_congr rfl fun y _ => h3 y] at hcs
    exact hcs
  have hf := variance_nonneg hp f
  have hg := variance_nonneg hp g
  have : Real.sqrt ((cov p f g) ^ 2) ≤ Real.sqrt (variance p f * variance p g) :=
    Real.sqrt_le_sqrt hsq
  rwa [Real.sqrt_sq_eq_abs, Real.sqrt_mul hf] at this

/-! ## 2. The exponential tilt and its variance -/

variable [Nonempty Ω]

/-- **Popoviciu's inequality.**  The reference variance never exceeds a quarter of the
squared reward range, so the variance bounds below are always at least as strong as the
range bounds of `Novelty.RLHFQuadraticDrift`, and can be arbitrarily stronger. -/
theorem variance_le_range_sq {p : Ω → ℝ} (hp : IsDist p) (r : Ω → ℝ) :
    variance p r ≤ rewardRange r ^ 2 / 4 := by
  set c : ℝ := (univ.sup' univ_nonempty r + univ.inf' univ_nonempty r) / 2 with hc
  refine (variance_le_of_center hp r c).trans ?_
  have hpt : ∀ y ∈ (univ : Finset Ω), p y * (r y - c) ^ 2 ≤ p y * (rewardRange r ^ 2 / 4) := by
    intro y _
    refine mul_le_mul_of_nonneg_left ?_ (hp.1 y)
    have h1 : r y ≤ univ.sup' univ_nonempty r := Finset.le_sup' r (mem_univ y)
    have h2 : univ.inf' univ_nonempty r ≤ r y := Finset.inf'_le r (mem_univ y)
    have hrr : rewardRange r = univ.sup' univ_nonempty r - univ.inf' univ_nonempty r := rfl
    rw [hrr, hc]
    nlinarith [sq_nonneg (r y - c)]
  have := Finset.sum_le_sum hpt
  rwa [← Finset.sum_mul, hp.2, one_mul] at this

/-- The likelihood ratio `π_β / p = e^{r/β}/Z` of the aligned policy against the
reference. -/
noncomputable def tilt (β : ℝ) (r p : Ω → ℝ) : Ω → ℝ :=
  fun y => Real.exp (r y / β) / partition β r p

omit [Nonempty Ω] in
theorem gibbsPolicy_eq_mul_tilt {β : ℝ} {r p : Ω → ℝ} (y : Ω) :
    gibbsPolicy β r p y = p y * tilt β r p y := by
  unfold gibbsPolicy tilt
  ring

theorem mean_tilt {β : ℝ} {r p : Ω → ℝ} (hp : IsPosDist p) : mean p (tilt β r p) = 1 := by
  have hZ := partition_pos (β := β) (r := r) hp
  have h : ∀ y, p y * tilt β r p y = (p y * Real.exp (r y / β)) / partition β r p := by
    intro y; unfold tilt; ring
  rw [mean, Finset.sum_congr rfl fun y _ => h y, ← Finset.sum_div]
  rw [div_eq_one_iff_eq (ne_of_gt hZ)]
  rfl

/-- The shift in the mean of any statistic is exactly the covariance of that statistic
with the likelihood ratio. -/
theorem mean_gibbs_sub_mean {β : ℝ} {r p : Ω → ℝ} (hp : IsPosDist p) (f : Ω → ℝ) :
    mean (gibbsPolicy β r p) f - mean p f = cov p (tilt β r p) f := by
  rw [cov_eq_sub hp.isDist, mean_tilt hp, one_mul]
  congr 1
  refine Finset.sum_congr rfl fun y _ => ?_
  rw [gibbsPolicy_eq_mul_tilt]
  ring

/-- `|e^a − e^b| ≤ e^{max a b} · |a − b|`: the mean value estimate for `exp`, proved
from the elementary bound `|eˣ − 1| ≤ |x| e^{|x|}`. -/
theorem abs_exp_sub_exp_le (a b : ℝ) :
    |Real.exp a - Real.exp b| ≤ Real.exp (max a b) * |a - b| := by
  rcases le_total b a with hba | hab
  · have hmax : max a b = a := max_eq_left hba
    have h1 : Real.exp a - Real.exp b = Real.exp b * (Real.exp (a - b) - 1) := by
      rw [mul_sub, ← Real.exp_add, mul_one]; ring_nf
    have h2 : |Real.exp (a - b) - 1| ≤ |a - b| * Real.exp |a - b| :=
      abs_exp_sub_one_le_mul (a - b)
    have habs : |a - b| = a - b := abs_of_nonneg (by linarith)
    rw [hmax, h1, abs_mul, abs_of_pos (Real.exp_pos b)]
    calc Real.exp b * |Real.exp (a - b) - 1|
        ≤ Real.exp b * (|a - b| * Real.exp |a - b|) := by
          exact mul_le_mul_of_nonneg_left h2 (Real.exp_pos b).le
      _ = Real.exp a * |a - b| := by
          have hmul : Real.exp b * Real.exp (a - b) = Real.exp a := by
            rw [← Real.exp_add]; ring_nf
          rw [habs]
          linear_combination (a - b) * hmul
  · have hmax : max a b = b := max_eq_right hab
    have h1 : Real.exp a - Real.exp b = -(Real.exp a * (Real.exp (b - a) - 1)) := by
      rw [mul_sub, ← Real.exp_add, mul_one]; ring_nf
    have h2 : |Real.exp (b - a) - 1| ≤ |b - a| * Real.exp |b - a| :=
      abs_exp_sub_one_le_mul (b - a)
    have habs : |b - a| = b - a := abs_of_nonneg (by linarith)
    have hab' : |a - b| = b - a := by rw [abs_sub_comm, habs]
    rw [hmax, h1, abs_neg, abs_mul, abs_of_pos (Real.exp_pos a), hab']
    calc Real.exp a * |Real.exp (b - a) - 1|
        ≤ Real.exp a * (|b - a| * Real.exp |b - a|) := by
          exact mul_le_mul_of_nonneg_left h2 (Real.exp_pos a).le
      _ = Real.exp b * (b - a) := by
          have hmul : Real.exp a * Real.exp (b - a) = Real.exp b := by
            rw [← Real.exp_add]; ring_nf
          rw [habs]
          linear_combination (b - a) * hmul

theorem exp_inf_le_partition {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    Real.exp (univ.inf' univ_nonempty r / β) ≤ partition β r p := by
  have h : ∀ y ∈ (univ : Finset Ω),
      p y * Real.exp (univ.inf' univ_nonempty r / β) ≤ p y * Real.exp (r y / β) := by
    intro y _
    refine mul_le_mul_of_nonneg_left (Real.exp_le_exp.2 ?_) (hp.1 y).le
    exact (div_le_div_iff_of_pos_right hβ).mpr (Finset.inf'_le r (mem_univ y))
  have := Finset.sum_le_sum h
  rwa [← Finset.sum_mul, hp.2, one_mul] at this

/-- **The tilt is Lipschitz in the reward, with constant `e^{range r/β}/β`.** -/
theorem abs_tilt_sub_le {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) (x y : Ω) :
    |tilt β r p x - tilt β r p y| ≤ Real.exp (rewardRange r / β) / β * |r x - r y| := by
  have hZ := partition_pos (β := β) (r := r) hp
  have hinf := exp_inf_le_partition (r := r) hβ hp
  have hsub : tilt β r p x - tilt β r p y
      = (Real.exp (r x / β) - Real.exp (r y / β)) / partition β r p := by
    unfold tilt; ring
  have hmax : max (r x / β) (r y / β) ≤ univ.sup' univ_nonempty r / β := by
    refine max_le ?_ ?_ <;>
      exact (div_le_div_iff_of_pos_right hβ).mpr (Finset.le_sup' r (mem_univ _))
  have hnum : |Real.exp (r x / β) - Real.exp (r y / β)|
      ≤ Real.exp (univ.sup' univ_nonempty r / β) * (|r x - r y| / β) := by
    refine (abs_exp_sub_exp_le _ _).trans ?_
    have habs : |r x / β - r y / β| = |r x - r y| / β := by
      rw [div_sub_div_same, abs_div, abs_of_pos hβ]
    rw [habs]
    exact mul_le_mul_of_nonneg_right (Real.exp_le_exp.2 hmax) (by positivity)
  rw [hsub, abs_div, abs_of_pos hZ]
  rw [div_le_iff₀ hZ]
  refine hnum.trans ?_
  have hkey : Real.exp (univ.sup' univ_nonempty r / β)
      ≤ Real.exp (rewardRange r / β) * Real.exp (univ.inf' univ_nonempty r / β) := by
    rw [← Real.exp_add]
    refine Real.exp_le_exp.2 ?_
    rw [rewardRange]
    field_simp
    linarith
  have h1 : Real.exp (univ.sup' univ_nonempty r / β) * (|r x - r y| / β)
      ≤ (Real.exp (rewardRange r / β) * Real.exp (univ.inf' univ_nonempty r / β))
        * (|r x - r y| / β) :=
    mul_le_mul_of_nonneg_right hkey (by positivity)
  refine h1.trans ?_
  have h2 : Real.exp (rewardRange r / β) / β * |r x - r y| * Real.exp
      (univ.inf' univ_nonempty r / β)
      ≤ Real.exp (rewardRange r / β) / β * |r x - r y| * partition β r p := by
    refine mul_le_mul_of_nonneg_left hinf ?_
    positivity
  calc (Real.exp (rewardRange r / β) * Real.exp (univ.inf' univ_nonempty r / β))
        * (|r x - r y| / β)
      = Real.exp (rewardRange r / β) / β * |r x - r y|
        * Real.exp (univ.inf' univ_nonempty r / β) := by ring
    _ ≤ _ := h2

/-- **The variance of the likelihood ratio is controlled by the reward variance.** -/
theorem variance_tilt_le {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    variance p (tilt β r p) ≤ (Real.exp (rewardRange r / β) / β) ^ 2 * variance p r := by
  refine variance_le_of_pair hp.isDist fun x y => ?_
  have h := abs_tilt_sub_le (r := r) hβ hp x y
  have h0 : 0 ≤ Real.exp (rewardRange r / β) / β * |r x - r y| := by positivity
  have hsq : (tilt β r p x - tilt β r p y) ^ 2
      ≤ (Real.exp (rewardRange r / β) / β * |r x - r y|) ^ 2 := by
    have habs : |tilt β r p x - tilt β r p y| ^ 2 = (tilt β r p x - tilt β r p y) ^ 2 :=
      sq_abs _
    nlinarith [abs_nonneg (tilt β r p x - tilt β r p y)]
  refine hsq.trans_eq ?_
  rw [mul_pow, sq_abs]

/-! ## 3. Variance-form drift bounds -/

/-- **The mean reward gain is at most `e^{range r/β} Var_p(r)/β`.** -/
theorem mean_reward_gain_le {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    mean (gibbsPolicy β r p) r - mean p r
      ≤ Real.exp (rewardRange r / β) / β * variance p r := by
  rw [mean_gibbs_sub_mean hp]
  have hbound := abs_cov_le hp.isDist (tilt β r p) r
  have hle : cov p (tilt β r p) r ≤ Real.sqrt (variance p (tilt β r p))
      * Real.sqrt (variance p r) := le_trans (le_abs_self _) hbound
  refine hle.trans ?_
  have hvt : Real.sqrt (variance p (tilt β r p))
      ≤ Real.exp (rewardRange r / β) / β * Real.sqrt (variance p r) := by
    have h := variance_tilt_le (r := r) hβ hp
    have := Real.sqrt_le_sqrt h
    rwa [Real.sqrt_mul (by positivity), Real.sqrt_sq (by positivity)] at this
  have hs : (0:ℝ) ≤ Real.sqrt (variance p r) := Real.sqrt_nonneg _
  have := mul_le_mul_of_nonneg_right hvt hs
  refine this.trans_eq ?_
  rw [mul_assoc, Real.mul_self_sqrt (variance_nonneg hp.isDist r)]

/-- **Variance form of the drift law (Conjecture C1).**
`KL(π_β ‖ p) ≤ e^{range r/β} · Var_p(r) / β²`.  Compared with
`RLHF.kl_gibbs_le_quadratic` the squared range `range(r)²/2` is replaced by the
reference variance `Var_p(r) ≤ range(r)²/4`, which can be arbitrarily smaller. -/
theorem kl_gibbs_le_variance {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    klDiv (gibbsPolicy β r p) p ≤ Real.exp (rewardRange r / β) * variance p r / β ^ 2 := by
  have hkl := klDiv_gibbs_eq (β := β) (r := r) hp
  have hjensen : ∑ y, p y * (r y / β) ≤ Real.log (partition β r p) := by
    have := log_partition_ge (p := p) (s := fun y => r y / β) hp
    exact this
  have hgain := mean_reward_gain_le (r := r) hβ hp
  have hmean1 : ∑ y, gibbsPolicy β r p y * (r y / β)
      = (mean (gibbsPolicy β r p) r) / β := by
    rw [mean, Finset.sum_div]
    exact Finset.sum_congr rfl fun y _ => by ring
  have hmean2 : ∑ y, p y * (r y / β) = (mean p r) / β := by
    rw [mean, Finset.sum_div]
    exact Finset.sum_congr rfl fun y _ => by ring
  rw [hmean1] at hkl
  rw [hmean2] at hjensen
  have hstep : klDiv (gibbsPolicy β r p) p
      ≤ (mean (gibbsPolicy β r p) r - mean p r) / β := by
    rw [hkl, sub_div]
    linarith
  refine hstep.trans ?_
  rw [div_le_div_iff₀ hβ (by positivity)]
  have hexp : (0:ℝ) < Real.exp (rewardRange r / β) := Real.exp_pos _
  have : (mean (gibbsPolicy β r p) r - mean p r) * β ^ 2
      ≤ (Real.exp (rewardRange r / β) / β * variance p r) * β ^ 2 := by
    exact mul_le_mul_of_nonneg_right hgain (by positivity)
  refine this.trans_eq ?_
  field_simp

/-- **Variance form of the no-collapse law.**
`‖π_β − p‖₁ ≤ √(2 e^{range r/β} Var_p(r)) / β`. -/
theorem gibbs_l1_le_variance {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    l1Dist (gibbsPolicy β r p) p
      ≤ Real.sqrt (2 * Real.exp (rewardRange r / β) * variance p r) / β := by
  have hg : IsPosDist (gibbsPolicy β r p) := gibbsPolicy_isPosDist hp
  have h1 := l1Dist_le_sqrt_two_mul_kl hg.isDist hp
  have h2 := kl_gibbs_le_variance (r := r) hβ hp
  refine h1.trans ?_
  have h3 : Real.sqrt (2 * klDiv (gibbsPolicy β r p) p)
      ≤ Real.sqrt (2 * (Real.exp (rewardRange r / β) * variance p r / β ^ 2)) := by
    exact Real.sqrt_le_sqrt (by linarith)
  refine h3.trans_eq ?_
  have heq : 2 * (Real.exp (rewardRange r / β) * variance p r / β ^ 2)
      = (2 * Real.exp (rewardRange r / β) * variance p r) / β ^ 2 := by ring
  have hnum : (0:ℝ) ≤ 2 * Real.exp (rewardRange r / β) * variance p r := by
    have := variance_nonneg hp.isDist r
    positivity
  rw [heq, Real.sqrt_div hnum, Real.sqrt_sq hβ.le]

/-- **Sharp anti-reward-hacking bound.**  For any audit statistic `f`, the change of
its mean under alignment is controlled by the *product of standard deviations* of the
reward and of `f` — not by `‖f‖_∞`.  In particular a statistic that is (nearly)
deterministic under the reference policy cannot be moved, at any temperature. -/
theorem audit_gap_le_stddev {β : ℝ} {r p f : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    |mean (gibbsPolicy β r p) f - mean p f|
      ≤ Real.exp (rewardRange r / β) / β
        * (Real.sqrt (variance p r) * Real.sqrt (variance p f)) := by
  rw [mean_gibbs_sub_mean hp]
  refine (abs_cov_le hp.isDist (tilt β r p) f).trans ?_
  have hvt : Real.sqrt (variance p (tilt β r p))
      ≤ Real.exp (rewardRange r / β) / β * Real.sqrt (variance p r) := by
    have h := variance_tilt_le (r := r) hβ hp
    have := Real.sqrt_le_sqrt h
    rwa [Real.sqrt_mul (by positivity), Real.sqrt_sq (by positivity)] at this
  have := mul_le_mul_of_nonneg_right hvt (Real.sqrt_nonneg (variance p f))
  refine this.trans_eq ?_
  ring

/-- **Zero variance means zero drift.**  If the reward is `p`-almost surely constant
(equivalently, has zero reference variance) the aligned policy *is* the reference
policy, at every temperature: alignment pressure with no reward contrast cannot move
the model at all. -/
theorem no_drift_of_variance_zero {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hv : variance p r = 0) : l1Dist (gibbsPolicy β r p) p = 0 := by
  have hle := gibbs_l1_le_variance (r := r) hβ hp
  rw [hv, mul_zero, Real.sqrt_zero, zero_div] at hle
  exact le_antisymm hle (l1Dist_nonneg _ _)

end RLHF