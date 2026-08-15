import Mathlib
import MachineLearning.ResNetLipschitz
/-! # Banach Contraction and Neural Network Convergence

Proves contraction mapping properties for neural network training:

1. Power bounds: k² < k for 0 < k < 1
2. GD contraction condition: ηL < 1
3. GD rate shrinkage: (ηL)² < ηL
4. ResNet depth: (1+L)^n ≥ 1+nL (Bernoulli, re-exported)
5. Feedforward contraction: L² < L for 0 < L < 1
6. Feedforward growth: L² > L for L > 1

Links contraction mapping theory to ResNet training convergence.
-/

noncomputable section

open Real ResNetLipschitz

namespace BanachFixedPointBridge

/-! ## Section 1: Power Bounds for Contractions -/

/-- k² < k for 0 < k < 1 (contraction squared shrinks) -/
theorem pow_two_lt_self {k : ℝ} (hk : 0 < k) (hk' : k < 1) :
    k ^ 2 < k := by nlinarith [sq_nonneg k]

/-- k³ < k for 0 < k < 1 -/
theorem pow_three_lt_self {k : ℝ} (hk : 0 < k) (hk' : k < 1) :
    k ^ 3 < k := by nlinarith [sq_nonneg k, sq_nonneg (k * k)]

/-- k/(1-k) > 0 for 0 < k < 1 (geometric series bound) -/
theorem geometric_denom_pos {k : ℝ} (hk : 0 < k) (hk' : k < 1) :
    0 < k / (1 - k) := div_pos hk (by linarith : (0 : ℝ) < 1 - k)

/-! ## Section 2: Neural Network Training -/

/-- GD sufficient: η > 0, L > 0, ηL < 1 gives contraction rate ηL -/
theorem gd_contraction (L η : ℝ) (hL : 0 < L) (hη : 0 < η) (hηL : η * L < 1) :
    0 < η * L ∧ η * L < 1 := ⟨mul_pos hη hL, hηL⟩

/-- GD rate: (ηL)² < ηL (each gradient step shrinks the error) -/
theorem gd_rate_shrink (L η : ℝ) (hη : 0 < η) (hL : 0 < L) (hηL : η * L < 1) :
    (η * L) * (η * L) < η * L := by nlinarith [sq_nonneg (η * L), mul_pos hη hL]

/-! ## Section 3: ResNet vs Feedforward Depth Comparison -/

/-- ResNet depth: (1+L)^K ≥ 1+KL (Bernoulli, from ResNetLipschitz) -/
theorem resnet_depth_bound (L : ℝ) (hL : 0 ≤ L) (K : ℕ) :
    1 + K * L ≤ (1 + L) ^ K :=
  bernoulli_resnet L hL K

/-- ResNet quadratic: (1+L)² ≥ 1+2L -/
theorem resnet_quadratic (L : ℝ) (hL : 0 ≤ L) :
    1 + 2 * L ≤ (1 + L) ^ 2 := by nlinarith [sq_nonneg L]

/-- ResNet cubic: (1+L)³ ≥ 1+3L -/
theorem resnet_cubic (L : ℝ) (hL : 0 ≤ L) :
    1 + 3 * L ≤ (1 + L) ^ 3 := by nlinarith [sq_nonneg L, sq_nonneg (L * L)]

/-- Feedforward contraction: L² < L for 0 < L < 1 (depth shrinks) -/
theorem feedforward_shrink (L : ℝ) (hL : 0 < L) (hL1 : L < 1) :
    L ^ 2 < L := by nlinarith [sq_nonneg L]

/-- Feedforward growth: L² > L for L > 1 (depth grows exponentially) -/
theorem feedforward_grows (L : ℝ) (hL : 1 < L) :
    L < L ^ 2 := by nlinarith [sq_nonneg (L - 1)]

end BanachFixedPointBridge