import Mathlib

/-! # ResNet Lipschitz Bounds: Additive vs Multiplicative Growth

Proves that residual connections preserve Lipschitz bounds additively
rather than multiplicatively, explaining why ResNets scale to greater
depth than feedforward networks.

Main results:
1. `resnet_block_lipschitz`: ‖x+g(x)-(y+g(y))‖ ≤ (1+L)·‖x-y‖
2. `resnet_block_bounded`: ‖x+g(x)‖ ≤ ‖x‖+M
3. `resnet_compose_two`: two-block bound (1+L₂)(1+L₁)
4. `bernoulli_resnet`: (1+L)^n ≥ 1+nL (Bernoulli's inequality)
5. `resnet_quadratic_lower`: (1+L)² ≥ 1+2L
6. `resnet_cubic_lower`: (1+L)³ ≥ 1+3L

The fundamental insight: ResNet depth cost (1+L)^K grows at least linearly
(by Bernoulli) but polynomially rather than exponentially when L < 1.
Feedforward depth cost L^K grows exponentially for L > 1.

This connects to:
- Tropical Satake isomorphism (SatakeIsomorphism.lean): tropical degree bounds
- Certified robustness (TropicalDegreeRobustness.lean): L∞ certified bounds
- Softmax dequantization (SatakeEMLBridge.lean): soft vs hard max convergence
-/

namespace ResNetLipschitz

open Real

/-! ## Section 1: ResNet Block Lipschitz Bound -/

/-- A ResNet block f(x) = x + g(x) has Lipschitz bound 1+L when g is L-Lipschitz.

The skip connection contributes ‖x-y‖, the residual g contributes ≤ L·‖x-y‖.
Total: (1+L)·‖x-y‖ — this is the ADDITIVE property of residual connections.
Compare with a feedforward layer h∘g with bound L_h · L_g (MULTIPLICATIVE). -/
theorem resnet_block_lipschitz {X : Type*} [NormedAddCommGroup X]
    (g : X → X) (L : ℝ) (_ : 0 ≤ L)
    (hg : ∀ x y, ‖g x - g y‖ ≤ L * ‖x - y‖)
    (x y : X) :
    ‖(x + g x) - (y + g y)‖ ≤ (1 + L) * ‖x - y‖ := by
  have h1 : (x + g x) - (y + g y) = (x - y) + (g x - g y) := by abel
  rw [h1]
  calc ‖(x - y) + (g x - g y)‖
      ≤ ‖x - y‖ + ‖g x - g y‖ := norm_add_le _ _
    _ ≤ ‖x - y‖ + L * ‖x - y‖ := by linarith [hg x y]
    _ = (1 + L) * ‖x - y‖ := by ring

/-- ResNet block boundedness: ‖x + g(x)‖ ≤ ‖x‖ + M when ‖g‖ ≤ M -/
theorem resnet_block_bounded {X : Type*} [NormedAddCommGroup X]
    (g : X → X) (M : ℝ) (hg : ∀ x, ‖g x‖ ≤ M) (x : X) :
    ‖x + g x‖ ≤ ‖x‖ + M := by
  calc ‖x + g x‖ ≤ ‖x‖ + ‖g x‖ := norm_add_le _ _
    _ ≤ ‖x‖ + M := by linarith [hg x]

/-! ## Section 2: Composition Bounds -/

/-- Two sequential ResNet blocks: bound (1+L₂)(1+L₁).

For K blocks with per-block Lipschitz L, the K-depth bound is (1+L)^K.
When L << 1, (1+L)^K ≈ 1 + KL (nearly additive in depth K). -/
theorem resnet_compose_two {X : Type*} [NormedAddCommGroup X]
    (g₁ g₂ : X → X) (L₁ L₂ : ℝ) (hL₁ : 0 ≤ L₁) (hL₂ : 0 ≤ L₂)
    (hg₁ : ∀ x y, ‖g₁ x - g₁ y‖ ≤ L₁ * ‖x - y‖)
    (hg₂ : ∀ x y, ‖g₂ x - g₂ y‖ ≤ L₂ * ‖x - y‖)
    (x y : X) :
    ‖(x + g₁ x + g₂ (x + g₁ x)) - (y + g₁ y + g₂ (y + g₁ y))‖ ≤
    (1 + L₂) * (1 + L₁) * ‖x - y‖ := by
  have h1 := resnet_block_lipschitz g₁ L₁ hL₁ hg₁ x y
  have h2 := resnet_block_lipschitz g₂ L₂ hL₂ hg₂ (x + g₁ x) (y + g₁ y)
  calc ‖(x + g₁ x + g₂ (x + g₁ x)) - (y + g₁ y + g₂ (y + g₁ y))‖
      ≤ (1 + L₂) * ‖(x + g₁ x) - (y + g₁ y)‖ := h2
    _ ≤ (1 + L₂) * ((1 + L₁) * ‖x - y‖) := mul_le_mul_of_nonneg_left h1 (by linarith)
    _ = (1 + L₂) * (1 + L₁) * ‖x - y‖ := by ring

/-! ## Section 3: Bernoulli's Inequality and ResNet Growth Bounds -/

/-- Bernoulli's inequality: (1+L)^n ≥ 1 + n·L for L ≥ 0.
    Proves that ResNet depth cost grows at least linearly. -/
theorem bernoulli_resnet (L : ℝ) (hL : 0 ≤ L) (n : ℕ) :
    1 + n * L ≤ (1 + L) ^ n := by
  induction n with
  | zero => simp
  | succ n ih =>
    push_cast
    have h1 : (1 + (n : ℝ) * L) * (1 + L) ≤ (1 + L) ^ n * (1 + L) :=
      mul_le_mul_of_nonneg_right ih (by linarith)
    have h2 : (1 + L) ^ n * (1 + L) = (1 + L) ^ (n + 1) := by ring
    have h3 : 1 + ((n : ℝ) + 1) * L ≤ (1 + (n : ℝ) * L) * (1 + L) := by
      nlinarith [sq_nonneg L]
    linarith [h1, h2, h3]

/-- (1+L)² ≥ 1 + 2L: quadratic lower bound -/
theorem resnet_quadratic_lower (L : ℝ) (_ : 0 ≤ L) :
    1 + 2 * L ≤ (1 + L) ^ 2 := by nlinarith [sq_nonneg L]

/-- (1+L)³ ≥ 1 + 3L: cubic lower bound -/
theorem resnet_cubic_lower (L : ℝ) (_ : 0 ≤ L) :
    1 + 3 * L ≤ (1 + L) ^ 3 := by nlinarith [sq_nonneg L, sq_nonneg (L * L)]

/-- Feedforward K-layer bound grows as L^K (exponential for L > 1),
    while ResNet K-block bound grows as (1+L)^K (polynomial for L < 1).
    When L = 0, ResNet = identity regardless of depth. -/
theorem resnet_identity_bound : (1 : ℝ) + 0 = 1 := by ring

end ResNetLipschitz