import Mathlib

/-!
# The PTX pretraining mix-in creates a `β`-independent alignment floor

Domain: Novelty (information theory × convex analysis × alignment theory).

## The question

Earlier cycles of this thread studied the KL-regularised RLHF optimum
`π_β = argmax_q  𝔼_q[r] − β · KL(q ‖ p)`, whose closed form is the Gibbs tilt
`π_β(y) ∝ p(y) e^{r(y)/β}`, and established the *drift law*
`‖π_β − p‖₁ = Θ(σ_p(r)/β)`: as the KL penalty `β → ∞` the aligned policy returns
to the reference policy `p` at rate `1/β`, with constant the reward standard
deviation.

Production RLHF (InstructGPT-style) adds a **PTX pretraining mix-in**: a fraction
`γ` of pretraining data, drawn from a distribution `d`, is folded back into the
objective.  In the *anchor* formulation adopted here the mix-in replaces the
reference measure by the mixture `p_γ = (1−γ)p + γd`, so the optimum becomes

  `q*_{β,γ}(y) ∝ ((1−γ) p(y) + γ d(y)) · e^{r(y)/β}`.

This file proves the resulting **two-scale drift law**: the total drift away from
the SFT policy `p` splits into a `β`-independent term coming from the mix-in and a
reward-induced term obeying the old `σ/β` law.

## Main results

* `RLHFPTX.l1_mix_self` — `‖p_γ − p‖₁ = γ · ‖d − p‖₁`, exactly.
* `RLHFPTX.gibbs_l1_le_sd` — the reward-induced drift from the *anchor*:
  `‖gibbs β m r − m‖₁ ≤ e^{(M−L)/β} · σ_m(r) / β` for any `L ≤ r ≤ M`.
  (This is the cycle-2 `σ/β` law, reproved here self-containedly.)
* `RLHFPTX.ptx_drift_upper` / `RLHFPTX.ptx_drift_lower` — the two-sided estimate
  `|‖q*_{β,γ} − p‖₁ − γ‖d − p‖₁| ≤ e^{(M−L)/β} σ_{p_γ}(r)/β`.
* `RLHFPTX.ptx_l1_tendsto` — hence `‖q*_{β,γ} − p‖₁ → γ‖d − p‖₁` as `β → ∞`.
* `RLHFPTX.ptx_no_return_to_p` — **the alignment floor**: if `γ > 0` and `d ≠ p`
  then `‖q*_{β,γ} − p‖₁` does *not* tend to `0`; no amount of KL regularisation
  brings the PTX-augmented optimum back to the SFT policy.
* `RLHFPTX.gibbs_beta_l1_tendsto_mad` — the *sharp* constant of the reward-induced
  part: `β · ‖gibbs β m r − m‖₁ → 𝔼_m|r − 𝔼_m r|`, the **mean absolute deviation**,
  not the standard deviation.
* `RLHFPTX.mad_le_sd` and `RLHFPTX.sq_sd_le_range_mul_mad` — the guard that turns
  the sharp constant back into a `Θ(σ/β)` statement:
  `σ²/(M−L) ≤ MAD ≤ σ`.  So the `σ/β` law is two-sided exactly up to the
  dimensionless factor `σ/(M−L)`, and *not* better: the honest first-order
  constant is the MAD.
* `RLHFPTX.ptx_beta_l1_tendsto_mad` — the reward-induced part of the PTX drift,
  measured from the mixture anchor, obeys the same sharp law.
* `RLHFPTX.ptxOpt_optimal` — a Gibbs variational principle showing that `q*_{β,γ}` really
  is the maximiser of the PTX objective `q ↦ 𝔼_q[r] − β KL(q ‖ p_γ)`, so all of the above
  are statements about a genuine optimisation problem, not about an ad hoc formula.
* `RLHFPTX.anchor_return_iff` — model independence: for *any* anchor `m`,
  `‖gibbs β m r − p‖₁ → 0` iff `m = p`; instantiated at the *geometric* mix-in
  `p^{1−γ}d^γ/Z` in `RLHFPTX.geoMix_return_iff`, so the floor is not an artefact of the
  arithmetic mixture model.
* `RLHFPTX.ptx_mean_tendsto` — the tax in reward units: the achieved reward converges to
  `𝔼_p[r] + γ(𝔼_d[r] − 𝔼_p[r])`, a `β`-independent shift.
* `RLHFPTX.ptx_beta_l1_expansion` — the exact `1/β` coefficient of the *total* drift, a
  **signed** covariance `∑_y sgn(p_γ y − p y) p_γ y (r y − 𝔼_{p_γ} r)`; unlike the drift from
  the anchor it can be negative, so reward optimisation may partially cancel the tax.

## Relation to the earlier cycles

The cycle-2 modules that established the `σ/β` law are not part of this snapshot of the
catalog (the files present reference modules that are absent), so this file is written to be
self-contained: it reproves the `σ/β` law it needs, in the same formulation, before
extending it.

## Method

No differentiation of the free energy anywhere.  The reward-induced bound comes
from the elementary convexity estimate `|e^a − e^b| ≤ e^{max a b}|a − b|`
(`RLHFPTX.abs_exp_sub_exp_le`) combined with the variational characterisation
`Var(X) ≤ 𝔼(X − c)²`, and the sharp constant comes from the derivative of
`t ↦ e^{ct}` at `t = 0` transported along `β ↦ 1/β`.
-/

namespace RLHFPTX

open Finset Real Filter Topology

variable {Ω : Type*} [Fintype Ω]

/-! ## 1. Distributions, moments, and the PTX optimum -/

/-- A probability distribution on a finite type. -/
def IsDist (p : Ω → ℝ) : Prop := (∀ y, 0 ≤ p y) ∧ ∑ y, p y = 1

/-- The mean `𝔼_p[f]`. -/
noncomputable def mean (p f : Ω → ℝ) : ℝ := ∑ y, p y * f y

/-- The variance `Var_p(f)`. -/
noncomputable def variance (p f : Ω → ℝ) : ℝ := ∑ y, p y * (f y - mean p f) ^ 2

/-- The standard deviation `σ_p(f)`. -/
noncomputable def sd (p f : Ω → ℝ) : ℝ := Real.sqrt (variance p f)

/-- The mean absolute deviation `MAD_p(f) = 𝔼_p|f − 𝔼_p f|`. -/
noncomputable def mad (p f : Ω → ℝ) : ℝ := ∑ y, p y * |f y - mean p f|

/-- Total-variation (ℓ¹) distance, unnormalised. -/
noncomputable def l1 (f g : Ω → ℝ) : ℝ := ∑ y, |f y - g y|

/-- The PTX mixture anchor `p_γ = (1−γ)p + γd`. -/
noncomputable def mix (γ : ℝ) (p d : Ω → ℝ) : Ω → ℝ := fun y => (1 - γ) * p y + γ * d y

/-- The partition function `Z_β = ∑ m(z) e^{r(z)/β}`. -/
noncomputable def partf (β : ℝ) (m r : Ω → ℝ) : ℝ := ∑ z, m z * Real.exp (r z / β)

/-- The Gibbs tilt of the anchor `m` by reward `r` at temperature `β`. -/
noncomputable def gibbs (β : ℝ) (m r : Ω → ℝ) : Ω → ℝ :=
  fun y => m y * Real.exp (r y / β) / partf β m r

/-- The PTX-augmented optimum `q*_{β,γ}`: the Gibbs tilt of the mixture anchor. -/
noncomputable def ptxOpt (β γ : ℝ) (p d r : Ω → ℝ) : Ω → ℝ := gibbs β (mix γ p d) r

/-! ## 2. Elementary structure of the objects -/

theorem l1_nonneg (f g : Ω → ℝ) : 0 ≤ l1 f g :=
  Finset.sum_nonneg fun _ _ => abs_nonneg _

theorem l1_comm (f g : Ω → ℝ) : l1 f g = l1 g f :=
  Finset.sum_congr rfl fun _ _ => abs_sub_comm _ _

theorem l1_triangle (f g h : Ω → ℝ) : l1 f h ≤ l1 f g + l1 g h := by
  rw [l1, l1, l1, ← Finset.sum_add_distrib]
  refine Finset.sum_le_sum fun y _ => ?_
  have hy : f y - h y = (f y - g y) + (g y - h y) := by ring
  rw [hy]
  exact abs_add_le _ _

theorem variance_nonneg {p : Ω → ℝ} (hp : IsDist p) (f : Ω → ℝ) : 0 ≤ variance p f :=
  Finset.sum_nonneg fun y _ => mul_nonneg (hp.1 y) (sq_nonneg _)

theorem sd_nonneg (p f : Ω → ℝ) : 0 ≤ sd p f := Real.sqrt_nonneg _

theorem mad_nonneg {p : Ω → ℝ} (hp : IsDist p) (f : Ω → ℝ) : 0 ≤ mad p f :=
  Finset.sum_nonneg fun y _ => mul_nonneg (hp.1 y) (abs_nonneg _)

/-- The mixture of two distributions is a distribution. -/
theorem mix_isDist {p d : Ω → ℝ} (hp : IsDist p) (hd : IsDist d) {γ : ℝ}
    (h0 : 0 ≤ γ) (h1 : γ ≤ 1) : IsDist (mix γ p d) := by
  constructor
  · intro y
    have := hp.1 y; have := hd.1 y
    have : (0:ℝ) ≤ 1 - γ := by linarith
    unfold mix; positivity
  · unfold mix
    rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum, hp.2, hd.2]
    ring

/-- **The mix-in drift is exactly `γ‖d − p‖₁`.** -/
theorem l1_mix_self (p d : Ω → ℝ) {γ : ℝ} (h0 : 0 ≤ γ) : l1 (mix γ p d) p = γ * l1 d p := by
  unfold l1 mix
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun y _ => ?_
  have : (1 - γ) * p y + γ * d y - p y = γ * (d y - p y) := by ring
  rw [this, abs_mul, abs_of_nonneg h0]

/-- The mean under the mixture anchor is the mixture of the means. -/
theorem mean_mix (p d f : Ω → ℝ) (γ : ℝ) :
    mean (mix γ p d) f = (1 - γ) * mean p f + γ * mean d f := by
  unfold mean mix
  rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun y _ => by ring

/-! ## 3. The partition function and the Gibbs tilt -/

theorem partf_pos {m : Ω → ℝ} (hm : IsDist m) (r : Ω → ℝ) (β : ℝ) : 0 < partf β m r := by
  obtain ⟨y, hy⟩ : ∃ y : Ω, 0 < m y := by
    by_contra h
    push_neg at h
    have : ∑ y, m y = 0 := by
      refine Finset.sum_eq_zero fun y _ => le_antisymm (h y) (hm.1 y)
    rw [hm.2] at this; norm_num at this
  refine Finset.sum_pos' (fun z _ => mul_nonneg (hm.1 z) (Real.exp_pos _).le) ⟨y, mem_univ y, ?_⟩
  exact mul_pos hy (Real.exp_pos _)

theorem gibbs_isDist {m : Ω → ℝ} (hm : IsDist m) (r : Ω → ℝ) (β : ℝ) : IsDist (gibbs β m r) := by
  have hZ := partf_pos hm r β
  constructor
  · intro y
    exact div_nonneg (mul_nonneg (hm.1 y) (Real.exp_pos _).le) hZ.le
  · unfold gibbs
    rw [← Finset.sum_div]
    exact div_self hZ.ne'

/-- Explicit form of the pointwise deviation of the Gibbs tilt from its anchor. -/
theorem gibbs_sub_anchor {m : Ω → ℝ} (hm : IsDist m) (r : Ω → ℝ) (β : ℝ) (y : Ω) :
    gibbs β m r y - m y = m y * (Real.exp (r y / β) - partf β m r) / partf β m r := by
  have hZ := partf_pos hm r β
  unfold gibbs
  field_simp

/-! ## 4. The convexity engine -/

/-- `|e^a − e^b| ≤ e^{max a b} · |a − b|`: the mean-value bound for `exp`, proved from
`1 + x ≤ e^x` alone. -/
theorem abs_exp_sub_exp_le (a b : ℝ) :
    |Real.exp a - Real.exp b| ≤ Real.exp (max a b) * |a - b| := by
  -- key one-sided estimate
  have key : ∀ u v : ℝ, u ≤ v → Real.exp v - Real.exp u ≤ Real.exp v * (v - u) := by
    intro u v _
    have h := Real.add_one_le_exp (u - v)
    have hv : (0:ℝ) < Real.exp v := Real.exp_pos v
    have h2 : Real.exp v * (u - v + 1) ≤ Real.exp v * Real.exp (u - v) := by
      exact mul_le_mul_of_nonneg_left h hv.le
    rw [← Real.exp_add] at h2
    have : v + (u - v) = u := by ring
    rw [this] at h2
    nlinarith [h2]
  rcases le_total a b with hab | hab
  · rw [abs_of_nonpos (by simpa using Real.exp_le_exp.mpr hab), abs_of_nonpos (by linarith),
      max_eq_right hab]
    have := key a b hab
    linarith
  · rw [abs_of_nonneg (by simpa using Real.exp_le_exp.mpr hab), abs_of_nonneg (by linarith),
      max_eq_left hab]
    have := key b a hab
    linarith

/-- `Var_p(f) ≤ 𝔼_p (f − c)²` for every constant `c`. -/
theorem variance_le_sq_dev {p : Ω → ℝ} (hp : IsDist p) (f : Ω → ℝ) (c : ℝ) :
    variance p f ≤ ∑ y, p y * (f y - c) ^ 2 := by
  have hvar : variance p f = ∑ y, p y * (f y - mean p f) ^ 2 := rfl
  have hmean : ∑ y, p y * f y = mean p f := rfl
  have key : ∑ y, p y * (f y - c) ^ 2 - ∑ y, p y * (f y - mean p f) ^ 2
      = (mean p f - c) ^ 2 := by
    rw [← Finset.sum_sub_distrib]
    have h : ∀ y : Ω, p y * (f y - c) ^ 2 - p y * (f y - mean p f) ^ 2
        = (2 * (mean p f - c)) * (p y * f y) + ((mean p f - c) * (-c - mean p f)) * p y := by
      intro y; ring
    rw [Finset.sum_congr rfl fun y _ => h y, Finset.sum_add_distrib, ← Finset.mul_sum,
      ← Finset.mul_sum, hp.2, hmean]
    ring
  nlinarith [sq_nonneg (mean p f - c)]

/-! ## 5. The reward-induced drift obeys the `σ/β` law -/

/-- Cauchy–Schwarz: `𝔼_p|g| ≤ √(𝔼_p g²)`. -/
theorem abs_mean_le_sqrt {p : Ω → ℝ} (hp : IsDist p) (g : Ω → ℝ) :
    ∑ y, p y * |g y| ≤ Real.sqrt (∑ y, p y * g y ^ 2) := by
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq (Finset.univ : Finset Ω)
    (fun y => Real.sqrt (p y)) (fun y => Real.sqrt (p y) * |g y|)
  have h1 : ∀ y : Ω, Real.sqrt (p y) * (Real.sqrt (p y) * |g y|) = p y * |g y| := by
    intro y
    rw [← mul_assoc, Real.mul_self_sqrt (hp.1 y)]
  have h2 : ∀ y : Ω, Real.sqrt (p y) ^ 2 = p y := fun y => Real.sq_sqrt (hp.1 y)
  have h3 : ∀ y : Ω, (Real.sqrt (p y) * |g y|) ^ 2 = p y * g y ^ 2 := by
    intro y
    rw [mul_pow, h2, sq_abs]
  simp only [h1, h2, h3] at hcs
  rw [hp.2, one_mul] at hcs
  have hnn : 0 ≤ ∑ y, p y * |g y| := Finset.sum_nonneg fun y _ => mul_nonneg (hp.1 y) (abs_nonneg _)
  calc ∑ y, p y * |g y| = Real.sqrt ((∑ y, p y * |g y|) ^ 2) := (Real.sqrt_sq hnn).symm
    _ ≤ Real.sqrt (∑ y, p y * g y ^ 2) := Real.sqrt_le_sqrt hcs

/-- `MAD_p(f) ≤ σ_p(f)`. -/
theorem mad_le_sd {p : Ω → ℝ} (hp : IsDist p) (f : Ω → ℝ) : mad p f ≤ sd p f :=
  abs_mean_le_sqrt hp (fun y => f y - mean p f)

theorem mean_le_of_le {m r : Ω → ℝ} (hm : IsDist m) {M : ℝ} (hM : ∀ y, r y ≤ M) :
    mean m r ≤ M := by
  have h : mean m r ≤ ∑ y, m y * M :=
    Finset.sum_le_sum fun y _ => mul_le_mul_of_nonneg_left (hM y) (hm.1 y)
  rwa [← Finset.sum_mul, hm.2, one_mul] at h

theorem le_mean_of_le {m r : Ω → ℝ} (hm : IsDist m) {L : ℝ} (hL : ∀ y, L ≤ r y) :
    L ≤ mean m r := by
  have h : ∑ y, m y * L ≤ mean m r :=
    Finset.sum_le_sum fun y _ => mul_le_mul_of_nonneg_left (hL y) (hm.1 y)
  rwa [← Finset.sum_mul, hm.2, one_mul] at h

/-- The partition function is bounded below by `e^{L/β}` when `r ≥ L`. -/
theorem exp_le_partf {m r : Ω → ℝ} (hm : IsDist m) {L β : ℝ} (hβ : 0 < β)
    (hL : ∀ y, L ≤ r y) : Real.exp (L / β) ≤ partf β m r := by
  have h : ∑ y, m y * Real.exp (L / β) ≤ partf β m r := by
    refine Finset.sum_le_sum fun y _ => mul_le_mul_of_nonneg_left ?_ (hm.1 y)
    exact Real.exp_le_exp.mpr (by gcongr; exact hL y)
  rwa [← Finset.sum_mul, hm.2, one_mul] at h

/-- The `ℓ¹` drift of the Gibbs tilt from its anchor, in mean-deviation form. -/
theorem gibbs_l1_eq {m : Ω → ℝ} (hm : IsDist m) (r : Ω → ℝ) (β : ℝ) :
    l1 (gibbs β m r) m
      = (∑ y, m y * |Real.exp (r y / β) - partf β m r|) / partf β m r := by
  have hZ := partf_pos hm r β
  rw [l1, Finset.sum_div]
  refine Finset.sum_congr rfl fun y _ => ?_
  rw [gibbs_sub_anchor hm r β y, abs_div, abs_of_pos hZ, abs_mul, abs_of_nonneg (hm.1 y)]

/-- The variance of the exponential tilt is controlled by the variance of the reward. -/
theorem variance_tilt_le {m r : Ω → ℝ} (hm : IsDist m) {M β : ℝ} (hβ : 0 < β)
    (hM : ∀ y, r y ≤ M) :
    variance m (fun y => Real.exp (r y / β))
      ≤ (Real.exp (M / β) / β) ^ 2 * variance m r := by
  refine le_trans (variance_le_sq_dev hm _ (Real.exp (mean m r / β))) ?_
  rw [variance, Finset.mul_sum]
  refine Finset.sum_le_sum fun y _ => ?_
  have hbd : |Real.exp (r y / β) - Real.exp (mean m r / β)|
      ≤ Real.exp (M / β) / β * |r y - mean m r| := by
    refine le_trans (abs_exp_sub_exp_le _ _) ?_
    have hmax : max (r y / β) (mean m r / β) ≤ M / β := by
      refine max_le ?_ ?_ <;> gcongr
      · exact hM y
      · exact mean_le_of_le hm hM
    have habs : |r y / β - mean m r / β| = |r y - mean m r| / β := by
      rw [div_sub_div_same, abs_div, abs_of_pos hβ]
    rw [habs]
    have h1 : Real.exp (max (r y / β) (mean m r / β)) ≤ Real.exp (M / β) :=
      Real.exp_le_exp.mpr hmax
    have h2 : (0:ℝ) ≤ |r y - mean m r| / β := div_nonneg (abs_nonneg _) hβ.le
    calc Real.exp (max (r y / β) (mean m r / β)) * (|r y - mean m r| / β)
        ≤ Real.exp (M / β) * (|r y - mean m r| / β) := by nlinarith
      _ = Real.exp (M / β) / β * |r y - mean m r| := by ring
  have hsq := mul_self_le_mul_self (abs_nonneg _) hbd
  have e1 : |Real.exp (r y / β) - Real.exp (mean m r / β)|
      * |Real.exp (r y / β) - Real.exp (mean m r / β)|
      = (Real.exp (r y / β) - Real.exp (mean m r / β)) ^ 2 := by
    rw [← abs_mul, ← sq, abs_of_nonneg (sq_nonneg _)]
  have e2 : Real.exp (M / β) / β * |r y - mean m r| * (Real.exp (M / β) / β * |r y - mean m r|)
      = (Real.exp (M / β) / β) ^ 2 * (r y - mean m r) ^ 2 := by
    rw [show Real.exp (M / β) / β * |r y - mean m r| * (Real.exp (M / β) / β * |r y - mean m r|)
        = (Real.exp (M / β) / β) ^ 2 * (|r y - mean m r| * |r y - mean m r|) by ring,
      ← abs_mul, ← sq, abs_of_nonneg (sq_nonneg _)]
  rw [e1, e2] at hsq
  calc m y * (Real.exp (r y / β) - Real.exp (mean m r / β)) ^ 2
      ≤ m y * ((Real.exp (M / β) / β) ^ 2 * (r y - mean m r) ^ 2) :=
        mul_le_mul_of_nonneg_left hsq (hm.1 y)
    _ = (Real.exp (M / β) / β) ^ 2 * (m y * (r y - mean m r) ^ 2) := by ring

/-- **The reward-induced drift law (cycle-2 `σ/β`, reproved self-containedly).**
For any anchor distribution `m` and any reward with `L ≤ r ≤ M`,
`‖gibbs β m r − m‖₁ ≤ e^{(M−L)/β} · σ_m(r) / β`. -/
theorem gibbs_l1_le_sd {m r : Ω → ℝ} (hm : IsDist m) {L M β : ℝ} (hβ : 0 < β)
    (hL : ∀ y, L ≤ r y) (hM : ∀ y, r y ≤ M) :
    l1 (gibbs β m r) m ≤ Real.exp ((M - L) / β) * sd m r / β := by
  have hZ := partf_pos hm r β
  -- numerator estimate: `𝔼_m|u − 𝔼_m u| ≤ σ_m(u) ≤ (e^{M/β}/β) σ_m(r)`
  have hmeanu : mean m (fun y => Real.exp (r y / β)) = partf β m r := rfl
  have step1 : (∑ y, m y * |Real.exp (r y / β) - partf β m r|)
      ≤ Real.sqrt (variance m (fun y => Real.exp (r y / β))) := by
    have h := abs_mean_le_sqrt hm (fun y => Real.exp (r y / β) - partf β m r)
    simpa [variance, hmeanu] using h
  have step2 : Real.sqrt (variance m (fun y => Real.exp (r y / β)))
      ≤ Real.exp (M / β) / β * sd m r := by
    refine le_trans (Real.sqrt_le_sqrt (variance_tilt_le hm hβ hM)) ?_
    rw [Real.sqrt_mul (sq_nonneg _), Real.sqrt_sq (by positivity)]
    rfl
  have hnum : (∑ y, m y * |Real.exp (r y / β) - partf β m r|)
      ≤ Real.exp (M / β) / β * sd m r := le_trans step1 step2
  rw [gibbs_l1_eq hm r β]
  have hfinal : (∑ y, m y * |Real.exp (r y / β) - partf β m r|) / partf β m r
      ≤ (Real.exp (M / β) / β * sd m r) / Real.exp (L / β) := by
    exact div_le_div₀ (mul_nonneg (by positivity) (sd_nonneg _ _)) hnum (Real.exp_pos _)
      (exp_le_partf hm hβ hL)
  refine le_trans hfinal (le_of_eq ?_)
  rw [sub_div, Real.exp_sub]
  field_simp

/-! ## 6. The two-scale PTX drift law -/

/-- **Upper half of the two-scale law.** The total drift of the PTX optimum away from the
SFT policy `p` is at most the mix-in drift `γ‖d − p‖₁` plus the reward drift `O(σ/β)`. -/
theorem ptx_drift_upper {p d r : Ω → ℝ} (hp : IsDist p) (hd : IsDist d) {γ L M β : ℝ}
    (hγ0 : 0 ≤ γ) (hγ1 : γ ≤ 1) (hβ : 0 < β) (hL : ∀ y, L ≤ r y) (hM : ∀ y, r y ≤ M) :
    l1 (ptxOpt β γ p d r) p
      ≤ γ * l1 d p + Real.exp ((M - L) / β) * sd (mix γ p d) r / β := by
  have hmix := mix_isDist hp hd hγ0 hγ1
  have h1 := l1_triangle (ptxOpt β γ p d r) (mix γ p d) p
  have h2 := gibbs_l1_le_sd (r := r) hmix hβ hL hM
  rw [l1_mix_self p d hγ0] at h1
  unfold ptxOpt at h1 ⊢
  linarith

/-- **Lower half of the two-scale law.** The mix-in drift cannot be cancelled: the total
drift is at least `γ‖d − p‖₁` minus the reward drift. -/
theorem ptx_drift_lower {p d r : Ω → ℝ} (hp : IsDist p) (hd : IsDist d) {γ L M β : ℝ}
    (hγ0 : 0 ≤ γ) (hγ1 : γ ≤ 1) (hβ : 0 < β) (hL : ∀ y, L ≤ r y) (hM : ∀ y, r y ≤ M) :
    γ * l1 d p - Real.exp ((M - L) / β) * sd (mix γ p d) r / β
      ≤ l1 (ptxOpt β γ p d r) p := by
  have hmix := mix_isDist hp hd hγ0 hγ1
  have h1 := l1_triangle (mix γ p d) (ptxOpt β γ p d r) p
  have h2 := gibbs_l1_le_sd (r := r) hmix hβ hL hM
  rw [l1_mix_self p d hγ0, l1_comm (mix γ p d) (ptxOpt β γ p d r)] at h1
  unfold ptxOpt at h1 ⊢
  linarith

/-- **The two-scale drift law**, in one statement:
`| ‖q*_{β,γ} − p‖₁ − γ‖d − p‖₁ | ≤ e^{(M−L)/β} σ_{p_γ}(r) / β`. -/
theorem ptx_drift_two_sided {p d r : Ω → ℝ} (hp : IsDist p) (hd : IsDist d) {γ L M β : ℝ}
    (hγ0 : 0 ≤ γ) (hγ1 : γ ≤ 1) (hβ : 0 < β) (hL : ∀ y, L ≤ r y) (hM : ∀ y, r y ≤ M) :
    |l1 (ptxOpt β γ p d r) p - γ * l1 d p|
      ≤ Real.exp ((M - L) / β) * sd (mix γ p d) r / β := by
  rw [abs_le]
  constructor
  · have := ptx_drift_lower hp hd hγ0 hγ1 hβ hL hM; linarith
  · have := ptx_drift_upper hp hd hγ0 hγ1 hβ hL hM; linarith

/-- `e^{c/β} → 1` as `β → ∞`. -/
theorem tendsto_exp_div_one (c : ℝ) :
    Filter.Tendsto (fun β : ℝ => Real.exp (c / β)) Filter.atTop (nhds 1) := by
  have hb : Filter.Tendsto (fun β : ℝ => c / β) Filter.atTop (nhds 0) :=
    Filter.Tendsto.div_atTop tendsto_const_nhds Filter.tendsto_id
  simpa using (Real.continuous_exp.tendsto 0).comp hb

/-- The `σ/β` envelope vanishes as `β → ∞`. -/
theorem tendsto_drift_bound (K C : ℝ) :
    Filter.Tendsto (fun β : ℝ => Real.exp (K / β) * C / β) Filter.atTop (nhds 0) := by
  simpa using
    Filter.Tendsto.div_atTop ((tendsto_exp_div_one K).mul (tendsto_const_nhds (x := C)))
      Filter.tendsto_id

/-- **The alignment floor.** As `β → ∞` the PTX-augmented optimum does not return to the
SFT policy `p`: its `ℓ¹` distance from `p` converges to the strictly positive constant
`γ‖d − p‖₁` whenever `γ > 0` and `d ≠ p`. -/
theorem ptx_l1_tendsto {p d r : Ω → ℝ} (hp : IsDist p) (hd : IsDist d) {γ L M : ℝ}
    (hγ0 : 0 ≤ γ) (hγ1 : γ ≤ 1) (hL : ∀ y, L ≤ r y) (hM : ∀ y, r y ≤ M) :
    Filter.Tendsto (fun β : ℝ => l1 (ptxOpt β γ p d r) p) Filter.atTop
      (nhds (γ * l1 d p)) := by
  have hzero : Filter.Tendsto
      (fun β : ℝ => l1 (ptxOpt β γ p d r) p - γ * l1 d p) Filter.atTop (nhds 0) := by
    refine squeeze_zero_norm' ?_ (tendsto_drift_bound (M - L) (sd (mix γ p d) r))
    filter_upwards [Filter.eventually_gt_atTop (0:ℝ)] with β hβ
    simpa [Real.norm_eq_abs] using ptx_drift_two_sided hp hd hγ0 hγ1 hβ hL hM
  simpa using hzero.add (tendsto_const_nhds (x := γ * l1 d p))

/-- **No return to the reference policy.** With a strictly positive pretraining mix-in and a
pretraining distribution different from the SFT policy, `‖q*_{β,γ} − p‖₁` does *not* tend to
`0`, in sharp contrast with the pure KL-regularised case `γ = 0`. -/
theorem ptx_no_return_to_p {p d r : Ω → ℝ} (hp : IsDist p) (hd : IsDist d) {γ L M : ℝ}
    (hγ0 : 0 < γ) (hγ1 : γ ≤ 1) (hL : ∀ y, L ≤ r y) (hM : ∀ y, r y ≤ M)
    (hdp : d ≠ p) :
    ¬ Filter.Tendsto (fun β : ℝ => l1 (ptxOpt β γ p d r) p) Filter.atTop (nhds 0) := by
  intro hcon
  have hlim := ptx_l1_tendsto hp hd hγ0.le hγ1 hL hM
  have heq : γ * l1 d p = 0 := tendsto_nhds_unique hlim hcon
  have hl1 : l1 d p = 0 := by
    rcases mul_eq_zero.1 heq with h | h
    · exact absurd h hγ0.ne'
    · exact h
  refine hdp (funext fun y => ?_)
  have hy : |d y - p y| = 0 := by
    have hnn : ∀ z ∈ (Finset.univ : Finset Ω), 0 ≤ |d z - p z| := fun z _ => abs_nonneg _
    exact (Finset.sum_eq_zero_iff_of_nonneg hnn).1 hl1 y (Finset.mem_univ y)
  have := abs_eq_zero.1 hy
  linarith

/-! ## 7. The sharp constant of the reward-induced drift is the mean absolute deviation -/

/-- `β(e^{c/β} − 1) → c`: the derivative of `t ↦ e^{ct}` at `t = 0`, transported along
`β ↦ 1/β`. -/
theorem tendsto_beta_mul_exp_sub_one (c : ℝ) :
    Filter.Tendsto (fun β : ℝ => β * (Real.exp (c / β) - 1)) Filter.atTop (nhds c) := by
  have hd : HasDerivAt (fun t : ℝ => Real.exp (c * t)) c 0 := by
    simpa using (Real.hasDerivAt_exp (c * 0)).comp 0 ((hasDerivAt_id (0:ℝ)).const_mul c)
  have hs := hasDerivAt_iff_tendsto_slope.1 hd
  have hinv : Filter.Tendsto (fun β : ℝ => β⁻¹) Filter.atTop (nhdsWithin 0 {(0:ℝ)}ᶜ) := by
    refine tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within _ tendsto_inv_atTop_zero ?_
    filter_upwards [Filter.eventually_gt_atTop (0:ℝ)] with β hβ
    simp [hβ.ne']
  refine (hs.comp hinv).congr' ?_
  filter_upwards [Filter.eventually_gt_atTop (0:ℝ)] with β hβ
  have hβ0 : β ≠ 0 := hβ.ne'
  simp only [Function.comp_apply, slope_def_field]
  field_simp [slope, hβ0]
  simp

/-- The partition function tends to `1` as `β → ∞`. -/
theorem tendsto_partf_one {m : Ω → ℝ} (hm : IsDist m) (r : Ω → ℝ) :
    Filter.Tendsto (fun β : ℝ => partf β m r) Filter.atTop (nhds 1) := by
  have h : Filter.Tendsto (fun β : ℝ => ∑ y, m y * Real.exp (r y / β)) Filter.atTop
      (nhds (∑ _y : Ω, m _y * 1)) :=
    tendsto_finset_sum _ fun y _ => tendsto_const_nhds.mul (tendsto_exp_div_one (r y))
  simpa [partf, hm.2] using h

/-- `β(Z_β − 1) → 𝔼_m[r]`: the first-order expansion of the free energy. -/
theorem tendsto_beta_mul_partf_sub_one {m : Ω → ℝ} (hm : IsDist m) (r : Ω → ℝ) :
    Filter.Tendsto (fun β : ℝ => β * (partf β m r - 1)) Filter.atTop (nhds (mean m r)) := by
  have key : ∀ β : ℝ, β * (partf β m r - 1)
      = ∑ y, m y * (β * (Real.exp (r y / β) - 1)) := by
    intro β
    have e : ∑ y, m y * (Real.exp (r y / β) - 1)
        = (∑ y, m y * Real.exp (r y / β)) - (∑ y, m y) := by
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun y _ => by ring
    calc β * (partf β m r - 1)
        = β * ∑ y, m y * (Real.exp (r y / β) - 1) := by rw [e, hm.2]; rfl
      _ = ∑ y, m y * (β * (Real.exp (r y / β) - 1)) := by
          rw [Finset.mul_sum]; exact Finset.sum_congr rfl fun y _ => by ring
  have h : Filter.Tendsto (fun β : ℝ => ∑ y, m y * (β * (Real.exp (r y / β) - 1)))
      Filter.atTop (nhds (∑ y : Ω, m y * r y)) :=
    tendsto_finset_sum _ fun y _ => tendsto_const_nhds.mul (tendsto_beta_mul_exp_sub_one (r y))
  exact (h.congr fun β => (key β).symm).congr' (by filter_upwards with β using rfl)

/-- Each coordinate of the rescaled deviation converges to the centred reward. -/
theorem tendsto_beta_mul_dev {m : Ω → ℝ} (hm : IsDist m) (r : Ω → ℝ) (y : Ω) :
    Filter.Tendsto (fun β : ℝ => β * (Real.exp (r y / β) - partf β m r)) Filter.atTop
      (nhds (r y - mean m r)) := by
  refine ((tendsto_beta_mul_exp_sub_one (r y)).sub
    (tendsto_beta_mul_partf_sub_one hm r)).congr fun β => by ring

/-- **The sharp reward-drift constant is the mean absolute deviation.**
`β · ‖gibbs β m r − m‖₁ → 𝔼_m|r − 𝔼_m r|` as `β → ∞`.  In particular the `σ/β` upper
bound is *not* attained in general: the true first-order constant is `MAD_m(r) ≤ σ_m(r)`. -/
theorem gibbs_beta_l1_tendsto_mad {m : Ω → ℝ} (hm : IsDist m) (r : Ω → ℝ) :
    Filter.Tendsto (fun β : ℝ => β * l1 (gibbs β m r) m) Filter.atTop (nhds (mad m r)) := by
  have hZ1 := tendsto_partf_one hm r
  have hterm : ∀ y : Ω, Filter.Tendsto
      (fun β : ℝ => m y * |β * (Real.exp (r y / β) - partf β m r)| / partf β m r)
      Filter.atTop (nhds (m y * |r y - mean m r| / 1)) := fun y =>
    ((tendsto_const_nhds.mul (tendsto_beta_mul_dev hm r y).abs).div hZ1 one_ne_zero)
  have hsum := tendsto_finset_sum (Finset.univ : Finset Ω) fun y _ => hterm y
  have hconst : (∑ y : Ω, m y * |r y - mean m r| / 1) = mad m r := by simp [mad]
  rw [hconst] at hsum
  refine hsum.congr' ?_
  filter_upwards [Filter.eventually_gt_atTop (0:ℝ)] with β hβ
  rw [gibbs_l1_eq hm r β, mul_comm, div_mul_eq_mul_div, Finset.sum_mul, Finset.sum_div]
  refine Finset.sum_congr rfl fun y _ => ?_
  rw [abs_mul, abs_of_pos hβ]
  ring

/-- `σ² ≤ (M − L) · MAD`: the reverse comparison that turns the sharp `MAD/β` law back into a
two-sided `Θ(σ/β)` statement, with dimensionless loss factor `σ/(M − L)`. -/
theorem sq_sd_le_range_mul_mad {m r : Ω → ℝ} (hm : IsDist m) {L M : ℝ}
    (hL : ∀ y, L ≤ r y) (hM : ∀ y, r y ≤ M) :
    sd m r ^ 2 ≤ (M - L) * mad m r := by
  have hvar : sd m r ^ 2 = variance m r := Real.sq_sqrt (variance_nonneg hm r)
  rw [hvar, variance, mad, Finset.mul_sum]
  refine Finset.sum_le_sum fun y _ => ?_
  have hdev : |r y - mean m r| ≤ M - L := by
    rw [abs_le]
    constructor
    · have := hM y; have := mean_le_of_le hm hM; have := hL y; have := le_mean_of_le hm hL
      linarith
    · have := hM y; have := le_mean_of_le hm hL
      linarith
  have hsq : (r y - mean m r) ^ 2 ≤ (M - L) * |r y - mean m r| := by
    have h1 : (r y - mean m r) ^ 2 = |r y - mean m r| * |r y - mean m r| := by
      rw [← abs_mul, ← sq, abs_of_nonneg (sq_nonneg _)]
    rw [h1]
    exact mul_le_mul_of_nonneg_right hdev (abs_nonneg _)
  calc m y * (r y - mean m r) ^ 2 ≤ m y * ((M - L) * |r y - mean m r|) :=
        mul_le_mul_of_nonneg_left hsq (hm.1 y)
    _ = (M - L) * (m y * |r y - mean m r|) := by ring

/-- **The guarded `Θ(σ/β)` statement.** The exact first-order drift constant `MAD_m(r)`
is sandwiched between `σ²/(M − L)` and `σ`; so the `σ/β` law is two-sided precisely up to
the dimensionless ratio `σ/(M − L)`, and cannot be improved to an equality. -/
theorem mad_sandwich {m r : Ω → ℝ} (hm : IsDist m) {L M : ℝ}
    (hL : ∀ y, L ≤ r y) (hM : ∀ y, r y ≤ M) (hLM : L < M) :
    sd m r ^ 2 / (M - L) ≤ mad m r ∧ mad m r ≤ sd m r := by
  refine ⟨?_, mad_le_sd hm r⟩
  rw [div_le_iff₀ (by linarith)]
  have := sq_sd_le_range_mul_mad hm hL hM
  linarith

/-- **The reward-induced part of the PTX drift obeys the sharp `MAD/β` law.**
Measured from the mixture anchor `p_γ`, the drift of the PTX optimum is asymptotically
`MAD_{p_γ}(r)/β` — the `γ`-dependence enters only through the anchor. -/
theorem ptx_beta_l1_tendsto_mad {p d r : Ω → ℝ} (hp : IsDist p) (hd : IsDist d) {γ : ℝ}
    (hγ0 : 0 ≤ γ) (hγ1 : γ ≤ 1) :
    Filter.Tendsto (fun β : ℝ => β * l1 (ptxOpt β γ p d r) (mix γ p d)) Filter.atTop
      (nhds (mad (mix γ p d) r)) :=
  gibbs_beta_l1_tendsto_mad (mix_isDist hp hd hγ0 hγ1) r

/-! ## 8. `q*_{β,γ}` really is the PTX optimum: a Gibbs variational principle

The results above are statements about the *formula* `q*_{β,γ} ∝ p_γ e^{r/β}`.  This section
closes the loop by proving that this formula is exactly the maximiser of the PTX-augmented
RLHF objective `q ↦ 𝔼_q[r] − β KL(q ‖ p_γ)`, so the drift laws above are statements about a
genuine optimum. -/

/-- Kullback–Leibler divergence on a finite space, with the usual `0 log 0 = 0` convention
built in by the product form of the summand. -/
noncomputable def kl (q s : Ω → ℝ) : ℝ := ∑ y, q y * Real.log (q y / s y)

/-- `KL(s ‖ s) = 0`. -/
theorem kl_self (s : Ω → ℝ) : kl s s = 0 := by
  refine Finset.sum_eq_zero fun y _ => ?_
  rcases eq_or_ne (s y) 0 with h | h
  · rw [h]; ring
  · rw [div_self h, Real.log_one, mul_zero]

/-- **Gibbs' inequality**: `KL(q ‖ s) ≥ 0` for distributions `q`, `s` with `s > 0`. -/
theorem kl_nonneg {q s : Ω → ℝ} (hq : IsDist q) (hs : IsDist s) (hspos : ∀ y, 0 < s y) :
    0 ≤ kl q s := by
  have key : ∀ y : Ω, -(q y * Real.log (q y / s y)) ≤ s y - q y := by
    intro y
    rcases eq_or_lt_of_le (hq.1 y) with h | h
    · rw [← h]
      simpa using (hspos y).le
    · have hlog : Real.log (s y / q y) ≤ s y / q y - 1 :=
        Real.log_le_sub_one_of_pos (div_pos (hspos y) h)
      have hneg : Real.log (s y / q y) = -Real.log (q y / s y) := by
        rw [← inv_div, Real.log_inv]
      have hmul : q y * Real.log (s y / q y) ≤ q y * (s y / q y - 1) :=
        mul_le_mul_of_nonneg_left hlog h.le
      have hval : q y * (s y / q y - 1) = s y - q y := by field_simp
      rw [hneg] at hmul
      linarith [hmul, hval ▸ hmul]
  have hsum : ∑ y, -(q y * Real.log (q y / s y)) ≤ ∑ y, (s y - q y) :=
    Finset.sum_le_sum fun y _ => key y
  have h0 : ∑ y : Ω, (s y - q y) = 0 := by
    rw [Finset.sum_sub_distrib, hs.2, hq.2]; ring
  rw [Finset.sum_neg_distrib, h0] at hsum
  simpa [kl] using neg_nonpos.1 hsum

/-- The Gibbs tilt of a strictly positive anchor is strictly positive. -/
theorem gibbs_pos {m : Ω → ℝ} (hm : IsDist m) (hmpos : ∀ y, 0 < m y) (r : Ω → ℝ) (β : ℝ)
    (y : Ω) : 0 < gibbs β m r y :=
  div_pos (mul_pos (hmpos y) (Real.exp_pos _)) (partf_pos hm r β)

/-- The **Gibbs variational identity**: for every candidate policy `q`,
`𝔼_q[r] − β KL(q ‖ m) = β log Z_β − β KL(q ‖ gibbs β m r)`. -/
theorem objective_eq {q m r : Ω → ℝ} (hq : IsDist q) (hm : IsDist m) (hmpos : ∀ y, 0 < m y)
    {β : ℝ} (hβ : 0 < β) :
    mean q r - β * kl q m = β * Real.log (partf β m r) - β * kl q (gibbs β m r) := by
  have hZ := partf_pos hm r β
  have key : ∀ y : Ω, q y * Real.log (q y / gibbs β m r y)
      = q y * Real.log (q y / m y) - q y * (r y / β) + q y * Real.log (partf β m r) := by
    intro y
    rcases eq_or_lt_of_le (hq.1 y) with h | h
    · rw [← h]; ring
    · have hg : gibbs β m r y = m y * Real.exp (r y / β) / partf β m r := rfl
      have hnum : m y * Real.exp (r y / β) ≠ 0 := (mul_pos (hmpos y) (Real.exp_pos _)).ne'
      have hgpos : (0:ℝ) < m y * Real.exp (r y / β) / partf β m r :=
        div_pos (mul_pos (hmpos y) (Real.exp_pos _)) hZ
      rw [hg, Real.log_div h.ne' hgpos.ne', Real.log_div hnum hZ.ne',
        Real.log_mul (hmpos y).ne' (Real.exp_ne_zero _), Real.log_exp,
        Real.log_div h.ne' (hmpos y).ne']
      ring
  have hklg : kl q (gibbs β m r)
      = kl q m - mean q r / β + Real.log (partf β m r) := by
    unfold kl
    rw [Finset.sum_congr rfl fun y _ => key y]
    rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.sum_mul]
    rw [hq.2, one_mul]
    have : ∑ y : Ω, q y * (r y / β) = mean q r / β := by
      rw [mean, Finset.sum_div]
      exact Finset.sum_congr rfl fun y _ => by ring
    rw [this]
  rw [hklg]
  field_simp
  ring

/-- **The Gibbs tilt is the optimum.**  For every distribution `q`,
`𝔼_q[r] − β KL(q ‖ m) ≤ 𝔼_{gibbs}[r] − β KL(gibbs ‖ m)`. -/
theorem gibbs_optimal {q m r : Ω → ℝ} (hq : IsDist q) (hm : IsDist m) (hmpos : ∀ y, 0 < m y)
    {β : ℝ} (hβ : 0 < β) :
    mean q r - β * kl q m ≤ mean (gibbs β m r) r - β * kl (gibbs β m r) m := by
  have hg := gibbs_isDist hm r β
  have h1 : mean q r - β * kl q m
      = β * Real.log (partf β m r) - β * kl q (gibbs β m r) := objective_eq hq hm hmpos hβ
  have h2 : mean (gibbs β m r) r - β * kl (gibbs β m r) m
      = β * Real.log (partf β m r) - β * kl (gibbs β m r) (gibbs β m r) :=
    objective_eq hg hm hmpos hβ
  rw [kl_self] at h2
  have h3 : 0 ≤ kl q (gibbs β m r) :=
    kl_nonneg hq hg (gibbs_pos hm hmpos r β)
  nlinarith [h1, h2, h3]

omit [Fintype Ω] in
/-- The mixture anchor is strictly positive when both `p` and `d` are. -/
theorem mix_pos {p d : Ω → ℝ} (hp : ∀ y, 0 < p y) (hd : ∀ y, 0 < d y) {γ : ℝ}
    (h0 : 0 ≤ γ) (h1 : γ ≤ 1) (y : Ω) : 0 < mix γ p d y := by
  unfold mix
  rcases eq_or_lt_of_le h0 with h | h
  · rw [← h]; simpa using hp y
  · have hnn : 0 ≤ (1 - γ) * p y := mul_nonneg (by linarith) (hp y).le
    nlinarith [mul_pos h (hd y)]

/-- **`ptxOpt` is the PTX-augmented optimum.**  It maximises the PTX objective
`q ↦ 𝔼_q[r] − β KL(q ‖ p_γ)` over all policies `q`, which is what makes all the drift laws
of this file statements about a genuine optimisation problem. -/
theorem ptxOpt_optimal {p d q r : Ω → ℝ} (hq : IsDist q) (hp : IsDist p) (hd : IsDist d)
    (hppos : ∀ y, 0 < p y) (hdpos : ∀ y, 0 < d y) {γ β : ℝ}
    (hγ0 : 0 ≤ γ) (hγ1 : γ ≤ 1) (hβ : 0 < β) :
    mean q r - β * kl q (mix γ p d)
      ≤ mean (ptxOpt β γ p d r) r - β * kl (ptxOpt β γ p d r) (mix γ p d) :=
  gibbs_optimal hq (mix_isDist hp hd hγ0 hγ1) (mix_pos hppos hdpos hγ0 hγ1) hβ

/-! ## 9. The alignment floor is a property of the anchor, not of the mixture model

The arithmetic mixture `p_γ = (1−γ)p + γd` is one way to model the PTX mix-in.  This section
shows the floor phenomenon is *model independent*: for **any** anchor `m`, the `β → ∞` limit
of `‖gibbs β m r − p‖₁` is exactly `‖m − p‖₁`, so the optimum returns to `p` iff the anchor
*is* `p`.  We then instantiate this at the *geometric* mix-in `p^{1−γ}d^γ / Z`, the anchor
produced by adding a `KL(q ‖ d)` term rather than mixing the data. -/

/-- The `ℓ¹` distance separates policies. -/
theorem l1_eq_zero_iff (f g : Ω → ℝ) : l1 f g = 0 ↔ f = g := by
  constructor
  · intro h
    refine funext fun y => ?_
    have hnn : ∀ z ∈ (Finset.univ : Finset Ω), 0 ≤ |f z - g z| := fun z _ => abs_nonneg _
    have := abs_eq_zero.1 ((Finset.sum_eq_zero_iff_of_nonneg hnn).1 h y (Finset.mem_univ y))
    linarith
  · intro h
    simp [l1, h]

/-- Reverse triangle inequality for the `ℓ¹` distance. -/
theorem abs_l1_sub_l1_le (f g h : Ω → ℝ) : |l1 f h - l1 g h| ≤ l1 f g := by
  have h1 := l1_triangle f g h
  have h2 := l1_triangle g f h
  rw [l1_comm g f] at h2
  rw [abs_le]
  constructor <;> linarith

/-- **Model-independent limit.** For any anchor `m` and any fixed policy `f`,
`‖gibbs β m r − f‖₁ → ‖m − f‖₁` as `β → ∞`: the reward washes out, the anchor does not. -/
theorem anchor_l1_tendsto {m r : Ω → ℝ} (hm : IsDist m) (f : Ω → ℝ) {L M : ℝ}
    (hL : ∀ y, L ≤ r y) (hM : ∀ y, r y ≤ M) :
    Filter.Tendsto (fun β : ℝ => l1 (gibbs β m r) f) Filter.atTop (nhds (l1 m f)) := by
  have hzero : Filter.Tendsto (fun β : ℝ => l1 (gibbs β m r) f - l1 m f) Filter.atTop
      (nhds 0) := by
    refine squeeze_zero_norm' ?_ (tendsto_drift_bound (M - L) (sd m r))
    filter_upwards [Filter.eventually_gt_atTop (0:ℝ)] with β hβ
    have h1 := abs_l1_sub_l1_le (gibbs β m r) m f
    have h2 := gibbs_l1_le_sd hm hβ hL hM
    simpa [Real.norm_eq_abs] using h1.trans h2
  simpa using hzero.add (tendsto_const_nhds (x := l1 m f))

/-- **The floor is exactly the anchor displacement.** The KL-regularised optimum returns to the
SFT policy `p` in the low-temperature-penalty limit *if and only if* the anchor equals `p`. -/
theorem anchor_return_iff {m p r : Ω → ℝ} (hm : IsDist m) {L M : ℝ}
    (hL : ∀ y, L ≤ r y) (hM : ∀ y, r y ≤ M) :
    Filter.Tendsto (fun β : ℝ => l1 (gibbs β m r) p) Filter.atTop (nhds 0) ↔ m = p := by
  constructor
  · intro hcon
    have hlim := anchor_l1_tendsto hm p hL hM
    exact (l1_eq_zero_iff m p).1 (tendsto_nhds_unique hlim hcon)
  · intro hmp
    have hlim := anchor_l1_tendsto hm p hL hM
    rwa [(l1_eq_zero_iff m p).2 hmp] at hlim

/-- The unnormalised geometric mix-in `p^{1−γ} d^γ`. -/
noncomputable def geoRaw (γ : ℝ) (p d : Ω → ℝ) : Ω → ℝ :=
  fun y => p y ^ (1 - γ) * d y ^ γ

/-- The geometric (log-linear) pretraining mix-in anchor `p^{1−γ} d^γ / Z`, which is the
anchor produced by regularising with `(1−γ)KL(q ‖ p) + γ KL(q ‖ d)` instead of mixing data. -/
noncomputable def geoMix (γ : ℝ) (p d : Ω → ℝ) : Ω → ℝ :=
  fun y => geoRaw γ p d y / ∑ z, geoRaw γ p d z

omit [Fintype Ω] in
theorem geoRaw_pos {p d : Ω → ℝ} (hp : ∀ y, 0 < p y) (hd : ∀ y, 0 < d y) (γ : ℝ) (y : Ω) :
    0 < geoRaw γ p d y :=
  mul_pos (Real.rpow_pos_of_pos (hp y) _) (Real.rpow_pos_of_pos (hd y) _)

theorem geoMix_isDist [Nonempty Ω] {p d : Ω → ℝ} (hp : ∀ y, 0 < p y) (hd : ∀ y, 0 < d y)
    (γ : ℝ) : IsDist (geoMix γ p d) := by
  have hS : 0 < ∑ z, geoRaw γ p d z :=
    Finset.sum_pos (fun z _ => geoRaw_pos hp hd γ z) ⟨Classical.arbitrary Ω, Finset.mem_univ _⟩
  refine ⟨fun y => (div_pos (geoRaw_pos hp hd γ y) hS).le, ?_⟩
  unfold geoMix
  rw [← Finset.sum_div, div_self hS.ne']

/-- **Robustness across mix-in models.** With the *geometric* mix-in anchor the same floor
appears: the optimum converges to the log-linear mixture, and returns to `p` only if that
mixture is `p`.  So the `β`-independent drift is not an artefact of the arithmetic mixture. -/
theorem geoMix_return_iff [Nonempty Ω] {p d r : Ω → ℝ} (hp : ∀ y, 0 < p y)
    (hd : ∀ y, 0 < d y) {γ L M : ℝ} (hL : ∀ y, L ≤ r y) (hM : ∀ y, r y ≤ M) :
    Filter.Tendsto (fun β : ℝ => l1 (gibbs β (geoMix γ p d) r) p) Filter.atTop (nhds 0)
      ↔ geoMix γ p d = p :=
  anchor_return_iff (geoMix_isDist hp hd γ) hL hM

/-! ## 10. The floor in reward units: a `β`-independent alignment tax

The drift floor is a statement in total variation.  Dualising against the reward itself turns
it into a statement about the *achieved reward*: the mix-in shifts it by the `β`-independent
amount `γ(𝔼_d r − 𝔼_p r)`, which is negative exactly when the pretraining distribution is
worse-rewarded than the SFT policy. -/

/-- Duality between `ℓ¹` distance and bounded statistics. -/
theorem abs_mean_sub_mean_le {f g h : Ω → ℝ} {C : ℝ} (hC : ∀ y, |h y| ≤ C) :
    |mean f h - mean g h| ≤ C * l1 f g := by
  have hexp : mean f h - mean g h = ∑ y, (f y - g y) * h y := by
    rw [mean, mean, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun y _ => by ring
  rw [hexp, l1, Finset.mul_sum]
  refine le_trans (Finset.abs_sum_le_sum_abs _ _) (Finset.sum_le_sum fun y _ => ?_)
  rw [abs_mul]
  calc |f y - g y| * |h y| ≤ |f y - g y| * C :=
        mul_le_mul_of_nonneg_left (hC y) (abs_nonneg _)
    _ = C * |f y - g y| := mul_comm _ _

/-- **The achieved reward converges to the anchor's reward.** -/
theorem anchor_mean_tendsto {m r : Ω → ℝ} (hm : IsDist m) {L M C : ℝ}
    (hL : ∀ y, L ≤ r y) (hM : ∀ y, r y ≤ M) (hC : ∀ y, |r y| ≤ C) :
    Filter.Tendsto (fun β : ℝ => mean (gibbs β m r) r) Filter.atTop (nhds (mean m r)) := by
  have hzero : Filter.Tendsto (fun β : ℝ => mean (gibbs β m r) r - mean m r) Filter.atTop
      (nhds 0) := by
    have hbd : Filter.Tendsto
        (fun β : ℝ => C * (Real.exp ((M - L) / β) * sd m r / β)) Filter.atTop (nhds 0) := by
      simpa using (tendsto_drift_bound (M - L) (sd m r)).const_mul C
    refine squeeze_zero_norm' ?_ hbd
    filter_upwards [Filter.eventually_gt_atTop (0:ℝ)] with β hβ
    have h1 := abs_mean_sub_mean_le (f := gibbs β m r) (g := m) hC
    have h2 := gibbs_l1_le_sd hm hβ hL hM
    have hCnn : 0 ≤ C := by
      rcases isEmpty_or_nonempty Ω with hE | hE
      · exact absurd hm.2 (by simp)
      · exact le_trans (abs_nonneg _) (hC (Classical.arbitrary Ω))
    have := mul_le_mul_of_nonneg_left h2 hCnn
    simpa [Real.norm_eq_abs] using h1.trans this
  simpa using hzero.add (tendsto_const_nhds (x := mean m r))

/-- The mix-in shifts the anchor's reward by exactly `γ(𝔼_d r − 𝔼_p r)`. -/
theorem mean_mix_sub_mean (p d r : Ω → ℝ) (γ : ℝ) :
    mean (mix γ p d) r - mean p r = γ * (mean d r - mean p r) := by
  rw [mean_mix]; ring

/-- **The reward-level alignment tax.** As `β → ∞` the reward achieved by the PTX optimum
converges to `𝔼_p[r] + γ(𝔼_d[r] − 𝔼_p[r])`: a `β`-independent shift, a genuine *loss* of
reward whenever the pretraining distribution scores below the SFT policy. -/
theorem ptx_mean_tendsto {p d r : Ω → ℝ} (hp : IsDist p) (hd : IsDist d) {γ L M C : ℝ}
    (hγ0 : 0 ≤ γ) (hγ1 : γ ≤ 1) (hL : ∀ y, L ≤ r y) (hM : ∀ y, r y ≤ M)
    (hC : ∀ y, |r y| ≤ C) :
    Filter.Tendsto (fun β : ℝ => mean (ptxOpt β γ p d r) r) Filter.atTop
      (nhds (mean p r + γ * (mean d r - mean p r))) := by
  have h := anchor_mean_tendsto (mix_isDist hp hd hγ0 hγ1) (r := r) hL hM hC
  have he : mean p r + γ * (mean d r - mean p r) = mean (mix γ p d) r := by
    rw [mean_mix]; ring
  rw [he]
  exact h

/-! ## 11. The exact `1/β` correction to the floor: a signed covariance

Sections 6–7 give `‖q*_{β,γ} − p‖₁ = γ‖d − p‖₁ + O(1/β)` and identify the sharp constant
of the drift *from the anchor*.  Here we identify the exact `1/β` coefficient of the drift
*from `p`* under the nondegeneracy condition that the anchor differs from `p` in every
coordinate.  The coefficient is a **signed** covariance, so — unlike the drift from the
anchor, which is a positive multiple of `MAD` — reward optimisation can *reduce* the total
drift, partially cancelling the pretraining tax. -/

/-- The sign pattern of `f − g` (valued in `±1`). -/
noncomputable def sgnAt (f g : Ω → ℝ) : Ω → ℝ := fun y => if g y < f y then 1 else -1

omit [Fintype Ω] in
theorem abs_eq_sgnAt_mul {f g : Ω → ℝ} {y : Ω} (h : g y ≠ f y) :
    |f y - g y| = sgnAt f g y * (f y - g y) := by
  unfold sgnAt
  rcases lt_or_gt_of_ne h with hlt | hgt
  · rw [if_pos hlt, one_mul, abs_of_pos (by linarith)]
  · rw [if_neg (by linarith), abs_of_neg (by linarith)]
    ring

/-- The Gibbs tilt converges pointwise to its anchor. -/
theorem tendsto_gibbs_pointwise {m : Ω → ℝ} (hm : IsDist m) (r : Ω → ℝ) (y : Ω) :
    Filter.Tendsto (fun β : ℝ => gibbs β m r y) Filter.atTop (nhds (m y)) := by
  have h : Filter.Tendsto (fun β : ℝ => m y * Real.exp (r y / β) / partf β m r) Filter.atTop
      (nhds (m y * 1 / 1)) :=
    (tendsto_const_nhds.mul (tendsto_exp_div_one (r y))).div (tendsto_partf_one hm r) one_ne_zero
  simpa [gibbs] using h

/-- The rescaled pointwise drift converges to the centred reward weighted by the anchor. -/
theorem tendsto_beta_mul_gibbs_sub {m : Ω → ℝ} (hm : IsDist m) (r : Ω → ℝ) (y : Ω) :
    Filter.Tendsto (fun β : ℝ => β * (gibbs β m r y - m y)) Filter.atTop
      (nhds (m y * (r y - mean m r))) := by
  have h : Filter.Tendsto
      (fun β : ℝ => m y * (β * (Real.exp (r y / β) - partf β m r)) / partf β m r)
      Filter.atTop (nhds (m y * (r y - mean m r) / 1)) :=
    (tendsto_const_nhds.mul (tendsto_beta_mul_dev hm r y)).div (tendsto_partf_one hm r)
      one_ne_zero
  rw [div_one] at h
  refine h.congr fun β => ?_
  rw [gibbs_sub_anchor hm r β y]
  field_simp

/-- **The exact `1/β` correction.**  If the anchor `m` differs from `p` in every coordinate,
then `β (‖gibbs β m r − p‖₁ − ‖m − p‖₁) → ∑_y sgn(m y − p y) · m y · (r y − 𝔼_m r)`,
a signed covariance between the reward and the direction of the anchor displacement. -/
theorem anchor_beta_l1_expansion {m p r : Ω → ℝ} (hm : IsDist m) (hne : ∀ y, p y ≠ m y) :
    Filter.Tendsto (fun β : ℝ => β * (l1 (gibbs β m r) p - l1 m p)) Filter.atTop
      (nhds (∑ y, sgnAt m p y * (m y * (r y - mean m r)))) := by
  have hsum : Filter.Tendsto
      (fun β : ℝ => ∑ y, sgnAt m p y * (β * (gibbs β m r y - m y))) Filter.atTop
      (nhds (∑ y, sgnAt m p y * (m y * (r y - mean m r)))) :=
    tendsto_finset_sum _ fun y _ =>
      tendsto_const_nhds.mul (tendsto_beta_mul_gibbs_sub hm r y)
  refine hsum.congr' ?_
  have hev : ∀ y : Ω, ∀ᶠ β : ℝ in Filter.atTop,
      |gibbs β m r y - p y| = sgnAt m p y * (gibbs β m r y - p y) := by
    intro y
    have hq := tendsto_gibbs_pointwise hm r y
    unfold sgnAt
    rcases lt_or_gt_of_ne (hne y) with hlt | hgt
    · rw [if_pos hlt]
      filter_upwards [hq.eventually_const_lt hlt] with β hβ
      rw [one_mul, abs_of_pos (by linarith)]
    · rw [if_neg (by linarith)]
      filter_upwards [hq.eventually_lt_const hgt] with β hβ
      rw [abs_of_neg (by linarith)]; ring
  filter_upwards [Filter.eventually_all.2 hev] with β hβ
  have h1 : l1 (gibbs β m r) p = ∑ y, sgnAt m p y * (gibbs β m r y - p y) :=
    Finset.sum_congr rfl fun y _ => hβ y
  have h2 : l1 m p = ∑ y, sgnAt m p y * (m y - p y) :=
    Finset.sum_congr rfl fun y _ => abs_eq_sgnAt_mul (hne y)
  rw [h1, h2, ← Finset.sum_sub_distrib, Finset.mul_sum]
  exact Finset.sum_congr rfl fun y _ => by ring

/-- **The PTX drift, to first order in `1/β`.**  When the mix-in moves every coordinate
(`p_γ y ≠ p y` for all `y`),
`‖q*_{β,γ} − p‖₁ = γ‖d − p‖₁ + (1/β)·∑_y sgn(p_γ y − p y) p_γ y (r y − 𝔼_{p_γ} r) + o(1/β)`.
The correction has no fixed sign: the reward can push the optimum back toward `p`. -/
theorem ptx_beta_l1_expansion {p d r : Ω → ℝ} (hp : IsDist p) (hd : IsDist d) {γ : ℝ}
    (hγ0 : 0 ≤ γ) (hγ1 : γ ≤ 1) (hne : ∀ y, p y ≠ mix γ p d y) :
    Filter.Tendsto (fun β : ℝ => β * (l1 (ptxOpt β γ p d r) p - γ * l1 d p)) Filter.atTop
      (nhds (∑ y, sgnAt (mix γ p d) p y
        * (mix γ p d y * (r y - mean (mix γ p d) r)))) := by
  have h := anchor_beta_l1_expansion (m := mix γ p d) (p := p) (r := r)
    (mix_isDist hp hd hγ0 hγ1) hne
  rwa [l1_mix_self p d hγ0] at h

end RLHFPTX