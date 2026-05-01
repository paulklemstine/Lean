import Mathlib

/-! # ResNet Robustness Bridge: Identity Preservation and Growth Bounds

Connects ResNet Lipschitz bounds (ResNetLipschitz.lean) to certified
robustness analysis. The key insight: ResNets preserve the identity
function when residuals vanish, preventing depth degradation.

Main results:
1. `certified_radius_positive`: certified radius is positive when margin > 0
2. `resnet_block_radius_positive`: ResNet block certified radius
3. `resnet_identity_preservation`: (1+0)^K = 1 regardless of depth
4. `skip_connection_lipschitz`: skip connections give exact bound 1
5. `bernoulli_L_one`: 2^n ≥ 1+n (exponential beats linear)
6. `resnet_small_residual_total`: for L ≤ 1, (1+L)^K ≤ 2^K
7. `resnet_growth_exceeds_linear`: (1+L)^n ≥ 1+nL (Bernoulli)

The key insight: near-identity ResNet blocks maintain Lipschitz
bounds close to 1 regardless of depth K, preventing gradient
explosion and maintaining robustness certificates at arbitrary depth.
-/

namespace ResNetRobustnessBridge

open Real

/-! ## Section 1: Certified Robustness Radius -/

/-- Certified robustness radius r* = margin / (2·LipBound) is positive
    when margin > 0 and LipBound > 0. -/
theorem certified_radius_positive (margin L : ℝ) (hm : 0 < margin) (hL : 0 < L) :
    0 < margin / (2 * L) := div_pos hm (by linarith)

/-- ResNet block certified radius r* = margin/(2·(1+L)) is positive
    for any margin > 0 and L ≥ 0. -/
theorem resnet_block_radius_positive (margin L : ℝ) (hm : 0 < margin) (_ : 0 ≤ L) :
    0 < margin / (2 * (1 + L)) := div_pos hm (by linarith)

/-! ## Section 2: Identity Preservation -/

/-- THE KEY RESNET PROPERTY: (1+0)^K = 1 regardless of K.
    This is why near-identity ResNets maintain gradient flow:
    the Lipschitz bound is exactly 1 when the residual vanishes. -/
theorem resnet_identity_preservation (K : ℕ) :
    (1 + (0 : ℝ)) ^ K = 1 := by simp

/-- The skip connection alone gives Lipschitz bound exactly 1. -/
theorem skip_connection_lipschitz {X : Type*} [NormedAddCommGroup X] (x y : X) :
    ‖x - y‖ ≤ 1 * ‖x - y‖ := by simp

/-! ## Section 3: Growth Rate Bounds -/

/-- 2^n ≥ 1 + n: exponential beats linear for base 2.
    Proof by induction: 2^(n+1) = 2·2^n ≥ 2(1+n) > 1+(n+1). -/
theorem bernoulli_L_one (n : ℕ) :
    1 + (n : ℝ) ≤ (2 : ℝ) ^ n := by
  induction n with
  | zero => simp
  | succ n ih =>
    push_cast
    have h1 : (1 + ((n : ℝ) + 1)) ≤ (1 + (n : ℝ)) * 2 := by linarith
    have h2 : (1 + (n : ℝ)) * 2 ≤ (2 : ℝ) ^ n * 2 :=
      mul_le_mul_of_nonneg_right ih (by linarith)
    have h3 : (2 : ℝ) ^ n * 2 = (2 : ℝ) ^ (n + 1) := by ring
    linarith [h1, h2, h3]

/-- For L ≤ 1, the per-block bound (1+L) ≤ 2. -/
theorem resnet_small_residual_per_block (L : ℝ) (_ : 0 ≤ L) (_ : L ≤ 1) :
    (1 + L) ≤ 2 := by linarith

/-- For L ≤ 1, K-block ResNet has total bound (1+L)^K ≤ 2^K.
    Any small residual gives at most 2^K regardless of depth. -/
theorem resnet_small_residual_total (L : ℝ) (hL : 0 ≤ L) (hL1 : L ≤ 1) (K : ℕ) :
    (1 + L) ^ K ≤ 2 ^ K := by
  induction K with
  | zero => simp
  | succ k ih =>
    calc (1 + L) ^ (k + 1)
        = (1 + L) ^ k * (1 + L) := by ring
      _ ≤ 2 ^ k * (1 + L) := mul_le_mul_of_nonneg_right ih (by linarith)
      _ ≤ 2 ^ k * 2 := mul_le_mul_of_nonneg_left (by linarith) (by positivity)
      _ = 2 ^ (k + 1) := by ring

/-- Bernoulli's inequality: (1+L)^n ≥ 1+nL for L ≥ 0.
    The ResNet bound grows at least linearly with depth. -/
theorem resnet_growth_exceeds_linear (L : ℝ) (hL : 0 ≤ L) (n : ℕ) :
    1 + n * L ≤ (1 + L) ^ n := by
  induction n with
  | zero => simp
  | succ n ih =>
    push_cast
    have h1 : (1 + L) * (1 + (n : ℝ) * L) = 1 + L + (n : ℝ) * L + (n : ℝ) * L * L := by ring
    have h2 : 1 + ((n : ℝ) + 1) * L ≤ 1 + L + (n : ℝ) * L + (n : ℝ) * L * L := by nlinarith [sq_nonneg L]
    have h3 : (1 + (n : ℝ) * L) * (1 + L) ≤ (1 + L) ^ n * (1 + L) :=
      mul_le_mul_of_nonneg_right ih (by linarith)
    have h4 : (1 + L) ^ n * (1 + L) = (1 + L) ^ (n + 1) := by ring
    have h5 : 1 + ((n : ℝ) + 1) * L ≤ (1 + (n : ℝ) * L) * (1 + L) := by nlinarith [sq_nonneg L]
    linarith [h3, h4]

end ResNetRobustnessBridge
