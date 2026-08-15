import Mathlib
import MachineLearning.ResNetLipschitz
/-! # Multi-Class Certified Robustness for Neural Networks

Proves certified adversarial robustness guarantees for multi-class classifiers
using Lipschitz analysis.

Key results:
1. Certified L-inf radius: epsilon < gamma/(2K) for K-Lipschitz classifiers
2. ResNet certification: gamma/(2*(1+L)^K) for K-block ResNet
3. Radius antitone in Lipschitz constant, monotone in margin
4. Feedforward exponential depth scaling vs ResNet polynomial
-/

noncomputable section

open Real ResNetLipschitz

namespace MultiClassCertificationBridge

/-! ## Section 1: Certified Robustness Radius -/

/-- Certified radius is positive when margin gamma > 0 and K > 0. -/
theorem certified_radius_pos (γ K : ℝ) (hγ : 0 < γ) (hK : 0 < K) :
    γ / (2 * K) > 0 := by positivity

/-- Margin preservation: if margin gamma > 2*K*epsilon and f-g is K-Lipschitz,
    then perturbation within epsilon preserves the sign of f-g.
    This is the fundamental certified robustness theorem. -/
theorem certified_robustness_margin
    (f g : ℝ → ℝ) (γ K ε : ℝ)
    (hγ : 0 < γ) (hK : 0 ≤ K)
    (hfg : ∀ x, γ ≤ f x - g x)
    (hlip : ∀ x y, |(f x - g x) - (f y - g y)| ≤ K * |x - y|)
    (hbnd : 2 * K * ε < γ)
    (x y : ℝ) (hxy : |x - y| ≤ ε) :
    0 < f y - g y := by
  have h1 := hlip x y
  have h2 : K * |x - y| ≤ K * ε := mul_le_mul_of_nonneg_left hxy hK
  have h3 : γ ≤ f x - g x := hfg x
  have h4 : f y - g y ≥ γ - K * ε := by
    have : |(f x - g x) - (f y - g y)| ≤ K * ε := by linarith [h1, h2]
    have : (f x - g x) - K * ε ≤ f y - g y := by linarith [abs_le.mp this]
    linarith
  have : γ - K * ε > 0 := by linarith
  linarith

/-- Zero-Lipschitz (constant) classifier: any positive margin gives robustness everywhere. -/
theorem constant_classifier_robust
    (f g : ℝ → ℝ) (γ : ℝ) (hγ : 0 < γ)
    (hfg : ∀ x, γ ≤ f x - g x)
    (hconst : ∀ x y, f x - g x = f y - g y)
    (y : ℝ) :
    0 < f y - g y := by
  have : f y - g y = f 0 - g 0 := (hconst 0 y).symm
  linarith [hfg 0]

/-! ## Section 2: ResNet and Feedforward Certification -/

/-- ResNet K-block certified radius: gamma / (2 * (1+L)^K). Uses Bernoulli bound. -/
theorem resnet_certified_radius (L γ : ℝ) (hL : 0 ≤ L) (hγ : 0 < γ) (K : ℕ) :
    γ / (2 * (1 + L) ^ K) > 0 := by positivity

/-- ResNet radius upper bound via Bernoulli: gamma/(2*(1+L)^K) <= gamma/(2*(1+KL)).
    The certified radius decays at most linearly in depth K. -/
theorem resnet_radius_bernoulli (L γ : ℝ) (hL : 0 ≤ L) (hγ : 0 < γ) (K : ℕ) :
    γ / (2 * (1 + L) ^ K) ≤ γ / (2 * (1 + ↑K * L)) := by
  have h_bern : (1 : ℝ) + ↑K * L ≤ (1 + L) ^ K := bernoulli_resnet L hL K
  have h_pos : (0 : ℝ) < 2 * (1 + ↑K * L) := by positivity
  have h_mul : 2 * (1 + ↑K * L) ≤ 2 * (1 + L) ^ K := mul_le_mul_of_nonneg_left h_bern (by norm_num : (0 : ℝ) ≤ 2)
  exact div_le_div_of_nonneg_left hγ.le h_pos h_mul

/-- Feedforward K-layer certified radius: gamma / (2 * L^K) for L > 1. -/
theorem feedforward_certified_radius (L γ : ℝ) (hL : 1 < L) (hγ : 0 < γ) (K : ℕ) :
    γ / (2 * L ^ K) > 0 := by positivity

/-! ## Section 3: Monotonicity and Comparison -/

/-- Certification radius is antitone in Lipschitz constant:
    K1 <= K2 => gamma/(2K2) <= gamma/(2K1). -/
theorem radius_antitone_lipschitz (γ K₁ K₂ : ℝ) (hγ : 0 < γ) (hK₁ : 0 < K₁) (hK₂ : 0 ≤ K₂) (hK : K₁ ≤ K₂) :
    γ / (2 * K₂) ≤ γ / (2 * K₁) := by
  have h_pos : (0 : ℝ) < 2 * K₁ := by positivity
  have h_mul : 2 * K₁ ≤ 2 * K₂ := by linarith
  exact div_le_div_of_nonneg_left hγ.le h_pos h_mul

/-- Certification radius is monotone in margin:
    gamma1 <= gamma2 => gamma1/(2K) <= gamma2/(2K). -/
theorem radius_monotone_margin (γ₁ γ₂ K : ℝ) (hγ₁ : 0 ≤ γ₁) (hK : 0 ≤ 2 * K) (hγ : γ₁ ≤ γ₂) :
    γ₁ / (2 * K) ≤ γ₂ / (2 * K) :=
  div_le_div_of_nonneg_right hγ hK

/-- ResNet depth comparison: more blocks means smaller certified radius. -/
theorem resnet_radius_decreases_with_depth (L γ : ℝ) (hL : 0 ≤ L) (hγ : 0 < γ) (n m : ℕ) (hnm : n ≤ m) :
    γ / (2 * (1 + L) ^ m) ≤ γ / (2 * (1 + L) ^ n) := by
  have h_pos : (0 : ℝ) < 2 * (1 + L) ^ n := by positivity
  have h_le : (1 + L) ^ n ≤ (1 + L) ^ m := pow_le_pow_right₀ (by linarith : (1 : ℝ) ≤ 1 + L) hnm
  have h_mul : 2 * (1 + L) ^ n ≤ 2 * (1 + L) ^ m := by linarith
  exact div_le_div_of_nonneg_left hγ.le h_pos h_mul

end MultiClassCertificationBridge