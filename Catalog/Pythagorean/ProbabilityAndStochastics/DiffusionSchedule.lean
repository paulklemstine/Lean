/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Diffusion Model Noise Schedule Algebra

This file formalizes the mathematical foundations of diffusion probabilistic models
(DDPMs), establishing key properties of the noise schedule that governs the
forward diffusion process.

## Main Results

- `diffusionAlphaBar_exp_bound` : ᾱ_t ≤ exp(-∑_{i<t} β_i)
- `univGaussianKL_nonneg` : KL(N(μ₁,σ₁²) ‖ N(μ₂,σ₂²)) ≥ 0
- `univGaussianKL_self` : KL(N(μ,σ²) ‖ N(μ,σ²)) = 0
- `diffusionSNR_strictAnti` : SNR is strictly decreasing
-/
import Mathlib

open Real BigOperators Finset

noncomputable section

/-! ## Section 1: Noise Schedule Definitions -/

/-- Cumulative signal retention: ᾱ_t = ∏_{i<t} (1 - β_i). -/
def diffusionAlphaBar (β : ℕ → ℝ) (t : ℕ) : ℝ :=
  ∏ i ∈ Finset.range t, (1 - β i)

@[simp]
theorem diffusionAlphaBar_zero (β : ℕ → ℝ) : diffusionAlphaBar β 0 = 1 := by
  simp [diffusionAlphaBar]

theorem diffusionAlphaBar_succ (β : ℕ → ℝ) (t : ℕ) :
    diffusionAlphaBar β (t + 1) = diffusionAlphaBar β t * (1 - β t) := by
  simp [diffusionAlphaBar, Finset.prod_range_succ]

theorem diffusionAlphaBar_pos (β : ℕ → ℝ) (hβ_lt : ∀ i, β i < 1) (t : ℕ) :
    0 < diffusionAlphaBar β t := by
  apply Finset.prod_pos
  intro i _; linarith [hβ_lt i]

theorem diffusionAlphaBar_le_one (β : ℕ → ℝ) (hβ_pos : ∀ i, 0 < β i)
    (hβ_lt : ∀ i, β i < 1) (t : ℕ) : diffusionAlphaBar β t ≤ 1 := by
  apply Finset.prod_le_one
  · intro i _; linarith [hβ_lt i]
  · intro i _; linarith [hβ_pos i]

/-- The variance-preserving identity: ᾱ_t + (1 - ᾱ_t) = 1. -/
theorem diffusion_variance_preserving (β : ℕ → ℝ) (t : ℕ) :
    diffusionAlphaBar β t + (1 - diffusionAlphaBar β t) = 1 := by ring

/-- ᾱ is strictly decreasing. -/
theorem diffusionAlphaBar_strictAnti (β : ℕ → ℝ) (hβ_pos : ∀ i, 0 < β i)
    (hβ_lt : ∀ i, β i < 1) (t : ℕ) :
    diffusionAlphaBar β (t + 1) < diffusionAlphaBar β t := by
  rw [diffusionAlphaBar_succ]
  have h1 : 0 < diffusionAlphaBar β t := diffusionAlphaBar_pos β hβ_lt t
  have h2 : 1 - β t < 1 := by linarith [hβ_pos t]
  exact mul_lt_of_lt_one_right h1 h2

/-- ᾱ is antitone. -/
theorem diffusionAlphaBar_antitone (β : ℕ → ℝ) (hβ_pos : ∀ i, 0 < β i)
    (hβ_lt : ∀ i, β i < 1) : Antitone (diffusionAlphaBar β) := by
  apply antitone_nat_of_succ_le
  intro n
  exact le_of_lt (diffusionAlphaBar_strictAnti β hβ_pos hβ_lt n)

/-! ## Section 2: Exponential Decay Bound -/

/-
The key inequality: 1 - x ≤ exp(-x) for all x ∈ ℝ.
-/
theorem one_sub_le_exp_neg (x : ℝ) : 1 - x ≤ Real.exp (-x) := by
  linarith [ Real.add_one_le_exp ( -x ) ]

/-
**The exponential decay bound**: ᾱ_t ≤ exp(-∑_{i<t} β_i).
-- !-- Induction on t. Base: ᾱ_0 = 1 = exp(0). Step: ᾱ_{t+1} = ᾱ_t · (1-β_t)
≤ exp(-∑_{i<t} β_i) · exp(-β_t) = exp(-∑_{i<t+1} β_i), using IH and 1-x ≤ exp(-x). -- !--
-/
theorem diffusionAlphaBar_exp_bound (β : ℕ → ℝ) (hβ_lt : ∀ i, β i < 1) (t : ℕ) :
    diffusionAlphaBar β t ≤ Real.exp (- ∑ i ∈ Finset.range t, β i) := by
  induction' t with t ih;
  · norm_num [ diffusionAlphaBar ];
  · rw [ Finset.sum_range_succ, diffusionAlphaBar_succ ];
    rw [ neg_add, Real.exp_add ];
    exact mul_le_mul ih ( by linarith [ Real.add_one_le_exp ( -β t ) ] ) ( by linarith [ hβ_lt t ] ) ( by positivity )

/-! ## Section 3: Signal-to-Noise Ratio -/

/-- SNR at step t: SNR_t = ᾱ_t / (1 - ᾱ_t). -/
def diffusionSNR (β : ℕ → ℝ) (t : ℕ) : ℝ :=
  diffusionAlphaBar β t / (1 - diffusionAlphaBar β t)

/-
1 - ᾱ_t > 0 for t ≥ 1.
-/
theorem one_sub_diffusionAlphaBar_pos (β : ℕ → ℝ) (hβ_pos : ∀ i, 0 < β i)
    (hβ_lt : ∀ i, β i < 1) (t : ℕ) (ht : 1 ≤ t) :
    0 < 1 - diffusionAlphaBar β t := by
  rw [ sub_pos ];
  induction' ht with k hk;
  · unfold diffusionAlphaBar; aesop;
  · exact lt_of_le_of_lt ( diffusionAlphaBar_strictAnti β hβ_pos hβ_lt k |> le_of_lt ) ( by linarith )

/-
The function x ↦ x/(1-x) is strictly increasing on (0,1).
-/
theorem div_one_sub_strictMonoOn :
    StrictMonoOn (fun x : ℝ => x / (1 - x)) (Set.Ioo 0 1) := by
  exact fun x hx y hy hxy => by rw [ div_lt_div_iff₀ ] <;> nlinarith [ hx.1, hx.2, hy.1, hy.2 ] ;

/-
**SNR is strictly decreasing**: for 1 ≤ s < t, SNR_s > SNR_t.
-- !-- Since ᾱ is strictly decreasing with values in (0,1) and x/(1-x)
is strictly increasing on (0,1), the composition reverses monotonicity. -- !--
-/
theorem diffusionSNR_strictAnti (β : ℕ → ℝ) (hβ_pos : ∀ i, 0 < β i)
    (hβ_lt : ∀ i, β i < 1) (s t : ℕ) (hs : 1 ≤ s) (hst : s < t) :
    diffusionSNR β t < diffusionSNR β s := by
  -- For 1 ≤ s < t, ᾱ_t < ᾱ_s since ᾱ is strictly decreasing.
  have h_diffusionAlphaBar_lt : diffusionAlphaBar β t < diffusionAlphaBar β s := by
    exact strictAnti_nat_of_succ_lt ( fun n => diffusionAlphaBar_strictAnti β hβ_pos hβ_lt n ) hst;
  unfold diffusionSNR;
  rw [ div_lt_div_iff₀ ] <;> nlinarith [ one_sub_diffusionAlphaBar_pos β hβ_pos hβ_lt t ( by linarith ), one_sub_diffusionAlphaBar_pos β hβ_pos hβ_lt s ( by linarith ), diffusionAlphaBar_pos β ( fun i => hβ_lt i ) t, diffusionAlphaBar_pos β ( fun i => hβ_lt i ) s ]

/-! ## Section 4: Univariate Gaussian KL Divergence -/

/-- The closed-form KL divergence between univariate Gaussians:
    KL(N(μ₁,σ₁²) ‖ N(μ₂,σ₂²)) = log(σ₂/σ₁) + (σ₁² + (μ₁-μ₂)²)/(2σ₂²) - 1/2. -/
def univGaussianKL (μ₁ σ₁ μ₂ σ₂ : ℝ) : ℝ :=
  Real.log (σ₂ / σ₁) + (σ₁ ^ 2 + (μ₁ - μ₂) ^ 2) / (2 * σ₂ ^ 2) - 1 / 2

/-
**KL divergence between identical Gaussians is zero.**
-- !-- Direct computation: log(1)=0, (σ²+0)/(2σ²)=1/2, so 0+1/2-1/2=0. -- !--
-/
theorem univGaussianKL_self (μ σ : ℝ) (hσ : 0 < σ) :
    univGaussianKL μ σ μ σ = 0 := by
  unfold univGaussianKL; norm_num [ hσ.ne' ] ;
  rw [ div_sub_div, div_eq_iff ] <;> ring <;> positivity

/-
**KL divergence between univariate Gaussians is non-negative.**
-- !-- Let r = σ₁²/σ₂². Then KL = -log(r)/2 + r/2 + (μ₁-μ₂)²/(2σ₂²) - 1/2
= (r - 1 - log r)/2 + (μ₁-μ₂)²/(2σ₂²). Both terms are ≥ 0 by
the standard inequality x - 1 - log x ≥ 0 for x > 0. -- !--
-/
theorem univGaussianKL_nonneg (μ₁ σ₁ μ₂ σ₂ : ℝ) (hσ₁ : 0 < σ₁) (hσ₂ : 0 < σ₂) :
    0 ≤ univGaussianKL μ₁ σ₁ μ₂ σ₂ := by
  unfold univGaussianKL;
  rw [ Real.log_div hσ₂.ne' hσ₁.ne' ];
  rw [ add_div', div_sub_div, le_div_iff₀ ] <;> try positivity;
  have := Real.log_le_sub_one_of_pos ( by positivity : 0 < σ₁ / σ₂ );
  rw [ Real.log_div ] at this <;> try linarith;
  rw [ div_sub_one, le_div_iff₀ ] at this <;> nlinarith [ sq_nonneg ( σ₁ - σ₂ ), mul_pos hσ₁ hσ₂ ]

end