import Mathlib
import MachineLearning.ResNetLipschitz
/-! # Certified L∞ Robustness for Residual Networks

Proves certified adversarial robustness bounds for ResNets:
1. add_lipschitz: f + g is (L₁+L₂)-Lipschitz
2. certified_radius_bound: K-Lipschitz classifiers have certified radius γ/(2K)
3. resnet_certified_lipschitz: ResNet F(x)=x+g(x) is (1+L)-Lipschitz
4. resnet_certified_radius: ResNet has certified radius γ/(2*(1+L))
5. Polynomial depth bounds + exponential vs polynomial comparison
-/

noncomputable section

open Real ResNetLipschitz

namespace ResNetTropicalCertified

/-- If f is L₁-Lipschitz and g is L₂-Lipschitz, then f+g is (L₁+L₂)-Lipschitz. -/
theorem add_lipschitz {X Y : Type*} [NormedAddCommGroup X] [NormedAddCommGroup Y]
    (f g : X → Y) (L₁ L₂ : ℝ) (_ : 0 ≤ L₁) (_ : 0 ≤ L₂)
    (hf : ∀ x y, ‖f x - f y‖ ≤ L₁ * ‖x - y‖)
    (hg : ∀ x y, ‖g x - g y‖ ≤ L₂ * ‖x - y‖) :
    ∀ x y, ‖(f + g) x - (f + g) y‖ ≤ (L₁ + L₂) * ‖x - y‖ := by
  intro x y
  have h_add : (f + g) x - (f + g) y = (f x - f y) + (g x - g y) := by
    show f x + g x - (f y + g y) = (f x - f y) + (g x - g y); abel
  rw [h_add]
  calc ‖(f x - f y) + (g x - g y)‖
      ≤ ‖f x - f y‖ + ‖g x - g y‖ := norm_add_le _ _
    _ ≤ L₁ * ‖x - y‖ + L₂ * ‖x - y‖ := add_le_add (hf x y) (hg x y)
    _ = (L₁ + L₂) * ‖x - y‖ := by ring

/-- Certified radius for K-Lipschitz function: ‖x-y‖ ≤ γ/(2K) implies ‖f(x)-f(y)‖ ≤ γ/2. -/
theorem certified_radius_bound {X : Type*} [NormedAddCommGroup X]
    (f : X → ℝ) (K γ : ℝ) (hK : 0 < K) (_ : 0 < γ)
    (hf : ∀ x y, ‖f x - f y‖ ≤ K * ‖x - y‖)
    (x y : X) (hdist : ‖x - y‖ ≤ γ / (2 * K)) :
    ‖f x - f y‖ ≤ γ / 2 := by
  have h_lip : ‖f x - f y‖ ≤ K * ‖x - y‖ := hf x y
  have h_dist : K * ‖x - y‖ ≤ K * (γ / (2 * K)) := mul_le_mul_of_nonneg_left hdist hK.le
  have h_simp : K * (γ / (2 * K)) = γ / 2 := by field_simp
  calc ‖f x - f y‖ ≤ K * ‖x - y‖ := h_lip
    _ ≤ K * (γ / (2 * K)) := h_dist
    _ = γ / 2 := h_simp

/-- ResNet block F(x) = x + g(x) is (1+L)-Lipschitz when g is L-Lipschitz. -/
theorem resnet_certified_lipschitz {X : Type*} [NormedAddCommGroup X]
    (g : X → X) (L : ℝ) (hL : 0 ≤ L)
    (hg : ∀ x y, ‖g x - g y‖ ≤ L * ‖x - y‖)
    (x y : X) :
    ‖(x + g x) - (y + g y)‖ ≤ (1 + L) * ‖x - y‖ :=
  resnet_block_lipschitz g L hL hg x y

/-- ResNet certified robustness: γ / (2*(1+L)) certified radius. -/
theorem resnet_certified_radius {X : Type*} [NormedAddCommGroup X]
    (f : X → ℝ) (L γ : ℝ) (hL : 0 ≤ L) (hγ : 0 < γ)
    (hf : ∀ x y, ‖f x - f y‖ ≤ (1 + L) * ‖x - y‖)
    (x y : X) (hdist : ‖x - y‖ ≤ γ / (2 * (1 + L))) :
    ‖f x - f y‖ ≤ γ / 2 :=
  certified_radius_bound f (1 + L) γ (by linarith) hγ hf x y hdist

/-- Bernoulli: (1+L)^n ≥ 1+nL -/
theorem resnet_bernoulli (L : ℝ) (hL : 0 ≤ L) (n : ℕ) :
    1 + n * L ≤ (1 + L) ^ n :=
  bernoulli_resnet L hL n

/-- Quadratic: (1+L)² ≥ 1+2L -/
theorem resnet_depth_two (L : ℝ) (_ : 0 ≤ L) :
    1 + 2 * L ≤ (1 + L) ^ 2 := by nlinarith [sq_nonneg L]

/-- Cubic: (1+L)³ ≥ 1+3L -/
theorem resnet_depth_three (L : ℝ) (_ : 0 ≤ L) :
    1 + 3 * L ≤ (1 + L) ^ 3 := by nlinarith [sq_nonneg L, sq_nonneg (L * L)]

/-- Feedforward L² ≥ 1+L for L ≥ 2 -/
theorem feedforward_exceeds_resnet (L : ℝ) (hL : 2 ≤ L) :
    (1 : ℝ) + L ≤ L ^ 2 := by nlinarith [sq_nonneg (L - 1)]

/-- L ≥ 1 implies L² ≥ L -/
theorem pow_two_ge_self (L : ℝ) (hL : 1 ≤ L) : L ≤ L ^ 2 := by nlinarith [sq_nonneg (L - 1)]

end ResNetTropicalCertified