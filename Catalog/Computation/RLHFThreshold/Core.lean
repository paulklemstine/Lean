import Mathlib

/-!
# Reward hacking as a covariance: a self-contained core

Domain: Computation (information theory × perturbation theory × alignment theory).

This file rebuilds, in a self-contained way, the minimal Gibbs/RLHF core needed by the
new results of `Computation.RLHFThreshold.Threshold` and
`Computation.RLHFThreshold.TwoPoint`.

The catalog already contains `Novelty.RLHFVarianceDrift` and
`Novelty.RLHFCovarianceExpansion`, which prove the first-order law
`|𝔼_{π_β} f − 𝔼_p f − Cov_p(r,f)/β| ≤ 24 (R/β)² σ_p(f)`.  Those two modules import
`Novelty.RLHFQuadraticDrift`, which is *absent from this snapshot of the catalog*, so
they cannot be compiled or imported here; the definitions and the first-order law are
therefore reconstructed below (with streamlined proofs that avoid `sup'`/`inf'`), so
that the genuinely new material — the sharp hacking threshold `β_c(ε) ~ |Cov_p(r,f)|/ε`
— rests on a compiling foundation.

Contents:

* `RLHF.mean`, `RLHF.variance`, `RLHF.cov` — the reference-policy moments;
* `RLHF.partition`, `RLHF.gibbsPolicy`, `RLHF.tilt` — the aligned (Gibbs) policy
  `π_β ∝ p · e^{r/β}` and its likelihood ratio against `p`;
* `RLHF.mean_gibbs_sub_mean` — the audit gap *is* the covariance of the likelihood
  ratio with the statistic (exactly, at every temperature);
* `RLHF.abs_tilt_sub_linear_le` — the likelihood ratio agrees with its linearization
  `r/β` up to an oscillation `24 (R/β)²`;
* `RLHF.audit_gap_first_order` — the first-order law;
* `RLHF.audit_gap_of_uncorrelated` — statistics uncorrelated with the reward move only
  at order `β⁻²`.
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω]

/-! ## 1. Distributions and moments -/

/-- `p` is a probability vector. -/
def IsDist (p : Ω → ℝ) : Prop := (∀ y, 0 ≤ p y) ∧ ∑ y, p y = 1

/-- `p` is a strictly positive probability vector (full support). -/
def IsPosDist (p : Ω → ℝ) : Prop := (∀ y, 0 < p y) ∧ ∑ y, p y = 1

theorem IsPosDist.isDist {p : Ω → ℝ} (hp : IsPosDist p) : IsDist p :=
  ⟨fun y => (hp.1 y).le, hp.2⟩

/-- The mean `𝔼_p[f] = ∑ y p y · f y`. -/
noncomputable def mean (p f : Ω → ℝ) : ℝ := ∑ y, p y * f y

/-- The variance `Var_p(f) = 𝔼_p[(f − 𝔼_p f)²]`. -/
noncomputable def variance (p f : Ω → ℝ) : ℝ := ∑ y, p y * (f y - mean p f) ^ 2

/-- The covariance `Cov_p(f, g) = 𝔼_p[(f − 𝔼_p f)(g − 𝔼_p g)]`. -/
noncomputable def cov (p f g : Ω → ℝ) : ℝ :=
  ∑ y, p y * ((f y - mean p f) * (g y - mean p g))

theorem mean_sub (p g h : Ω → ℝ) :
    mean p (fun y => g y - h y) = mean p g - mean p h := by
  rw [mean, mean, mean, ← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl fun y _ => by ring

theorem variance_nonneg {p : Ω → ℝ} (hp : IsDist p) (f : Ω → ℝ) : 0 ≤ variance p f := by
  refine Finset.sum_nonneg fun y _ => ?_
  have := hp.1 y
  positivity

theorem cov_self (p f : Ω → ℝ) : cov p f f = variance p f :=
  Finset.sum_congr rfl fun y _ => by ring

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

theorem cov_comm (p f g : Ω → ℝ) : cov p f g = cov p g f :=
  Finset.sum_congr rfl fun y _ => by ring

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

/-- **Pair representation of the variance**: `Var_p(f) = ½ ∑_{x,y} p x p y (f x − f y)²`. -/
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

/-! ## 2. The aligned (Gibbs) policy -/

/-- The partition function `Z_β = 𝔼_p[e^{r/β}]`. -/
noncomputable def partition (β : ℝ) (r p : Ω → ℝ) : ℝ := ∑ y, p y * Real.exp (r y / β)

/-- The KL-regularized optimal policy `π_β ∝ p · e^{r/β}`. -/
noncomputable def gibbsPolicy (β : ℝ) (r p : Ω → ℝ) : Ω → ℝ :=
  fun y => p y * Real.exp (r y / β) / partition β r p

/-- The likelihood ratio `π_β / p = e^{r/β}/Z_β`. -/
noncomputable def tilt (β : ℝ) (r p : Ω → ℝ) : Ω → ℝ :=
  fun y => Real.exp (r y / β) / partition β r p

variable [Nonempty Ω]

theorem partition_pos {β : ℝ} {r p : Ω → ℝ} (hp : IsPosDist p) : 0 < partition β r p := by
  refine Finset.sum_pos (fun y _ => ?_) univ_nonempty
  have := hp.1 y
  positivity

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

/-- **The audit gap is exactly a covariance**: the shift of the mean of any statistic
under alignment equals the covariance of that statistic with the likelihood ratio. -/
theorem mean_gibbs_sub_mean {β : ℝ} {r p : Ω → ℝ} (hp : IsPosDist p) (f : Ω → ℝ) :
    mean (gibbsPolicy β r p) f - mean p f = cov p (tilt β r p) f := by
  rw [cov_eq_sub hp.isDist, mean_tilt hp, one_mul]
  congr 1
  refine Finset.sum_congr rfl fun y _ => ?_
  rw [gibbsPolicy_eq_mul_tilt]
  ring

/-! ## 3. The tilt is its own linearization, to second order -/

theorem exp_one_le_three : Real.exp 1 ≤ 3 := by linarith [Real.exp_one_lt_d9]

omit [Fintype Ω] in
theorem nonneg_of_abs_le {R : ℝ} {r : Ω → ℝ} (hR : ∀ y, |r y| ≤ R) : 0 ≤ R :=
  le_trans (abs_nonneg (r (Classical.arbitrary Ω))) (hR (Classical.arbitrary Ω))

omit [Nonempty Ω] in
theorem partition_ge_third {β R : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hR : ∀ y, |r y| ≤ R) (hRβ : R ≤ β) : 1 / 3 ≤ partition β r p := by
  have hterm : ∀ y ∈ (univ : Finset Ω),
      p y * Real.exp (-1 : ℝ) ≤ p y * Real.exp (r y / β) := by
    intro y _
    refine mul_le_mul_of_nonneg_left (Real.exp_le_exp.2 ?_) (hp.1 y).le
    rw [le_div_iff₀ hβ]
    have := (abs_le.1 (hR y)).1
    linarith
  have hsum := Finset.sum_le_sum hterm
  rw [← Finset.sum_mul, hp.2, one_mul] at hsum
  have h2 : (1 : ℝ) / 3 ≤ Real.exp (-1 : ℝ) := by
    rw [Real.exp_neg, le_inv_comm₀ (by norm_num) (Real.exp_pos 1)]
    linarith [exp_one_le_three]
  exact le_trans h2 hsum

theorem abs_partition_sub_one_le {β R : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hR : ∀ y, |r y| ≤ R) (hRβ : R ≤ β) : |partition β r p - 1| ≤ 3 * (R / β) := by
  have hR0 : 0 ≤ R := nonneg_of_abs_le hR
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
    have h1 : |Real.exp (r y / β) - 1| ≤ 2 * |r y / β| :=
      Real.abs_exp_sub_one_le (le_trans hu ht1)
    have h2 : |Real.exp (r y / β) - 1| ≤ 3 * (R / β) := by linarith
    rw [abs_mul, abs_of_nonneg (hp.1 y).le]
    exact mul_le_mul_of_nonneg_left h2 (hp.1 y).le
  calc |∑ y, p y * (Real.exp (r y / β) - 1)|
      ≤ ∑ y, |p y * (Real.exp (r y / β) - 1)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ y, p y * (3 * (R / β)) := Finset.sum_le_sum hbound
    _ = 3 * (R / β) := by rw [← Finset.sum_mul, hp.2, one_mul]

/-- **The likelihood ratio is its own linearization, up to `O((R/β)²)` oscillation.** -/
theorem abs_tilt_sub_linear_le {β R : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hR : ∀ y, |r y| ≤ R) (hRβ : R ≤ β) (x y : Ω) :
    |(tilt β r p x - r x / β) - (tilt β r p y - r y / β)| ≤ 24 * (R / β) ^ 2 := by
  have hR0 : 0 ≤ R := nonneg_of_abs_le hR
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

/-! ## 4. The first-order law -/

/-- **The audit gap is a covariance to first order (C4).**  For a reward bounded by `R`
and a temperature `β ≥ R`, every statistic `f` satisfies
`|𝔼_{π_β} f − 𝔼_p f − Cov_p(r, f)/β| ≤ 24 (R/β)² σ_p(f)`. -/
theorem audit_gap_first_order {β R : ℝ} {r p f : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hR : ∀ y, |r y| ≤ R) (hRβ : R ≤ β) :
    |mean (gibbsPolicy β r p) f - mean p f - cov p r f / β|
      ≤ 24 * (R / β) ^ 2 * Real.sqrt (variance p f) := by
  have hR0 : 0 ≤ R := nonneg_of_abs_le hR
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
        ≤ 24 * (R / β) ^ 2 :=
      sqrt_variance_le_of_osc hp.isDist (by positivity) fun x y =>
        abs_tilt_sub_linear_le hβ hp hR hRβ x y
    exact mul_le_mul_of_nonneg_right hosc (Real.sqrt_nonneg _)
  have heq : mean (gibbsPolicy β r p) f - mean p f - cov p r f / β
      = cov p (fun y => tilt β r p y - r y / β) f := by
    rw [hgap, hsplit, hlin]
    ring
  rw [heq]
  exact hrem

/-- **First-order reward hacking requires correlation with the reward model.** -/
theorem audit_gap_of_uncorrelated {β R : ℝ} {r p f : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hR : ∀ y, |r y| ≤ R) (hRβ : R ≤ β) (hcov : cov p r f = 0) :
    |mean (gibbsPolicy β r p) f - mean p f| ≤ 24 * (R / β) ^ 2 * Real.sqrt (variance p f) := by
  have := audit_gap_first_order (f := f) hβ hp hR hRβ
  rwa [hcov, zero_div, sub_zero] at this

end RLHF