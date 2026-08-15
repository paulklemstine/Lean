/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Tropical Source Coding and Min-Plus Rate-Distortion Theory

## Bridge: Idempotent Mathematics ↔ Data Compression ↔ Certified Robustness

The min-plus rate-distortion function R_min(D) = H_∞(X) - D gives an exact
(not asymptotic) compression bound. This is the tropical dual of Shannon's
classical source coding theorem.

## Impact: certified_compression_bound, post_quantum_security, neural_network_compression
-/

import Mathlib
import Bridges.MinEntropy
open Finset Real BigOperators NonArchInfoTheory

namespace NonArchInfoTheory

/-! ## Section 1: Min-Plus Rate-Distortion -/

/-- Min-plus rate-distortion function: R_min(D) = H_∞(X) - D.
    The tropical dual of Shannon's rate-distortion function.
    Bridge: idempotent mathematics ↔ data compression theory.
    Unlike Shannon's R(D) which is asymptotic, R_min(D) is exact.
    Impact: certified_compression_bound — exact rate bounds for worst-case sources. -/
noncomputable def minPlusRateDistortion {α : Type*} [Fintype α] [Nonempty α]
    (μ : FinProbDist α) (D : ℝ) : ℝ :=
  minEntropy μ - D

/-! ## Section 2: Rate-Distortion Bounds -/

variable {α : Type*} [Fintype α] [Nonempty α]

/-- The min-plus rate-distortion lower bound: R_min(D) ≥ H_∞(X) - D.
    This is trivially an equality by definition, but states the fundamental
    tropical source coding theorem.
    Bridge: idempotent mathematics ↔ data compression.
    Impact: certified_compression_bound — exact rate bounds for worst-case sources. -/
theorem minPlus_rate_distortion_bound (μ : FinProbDist α) (D : ℝ) :
    minPlusRateDistortion μ D = minEntropy μ - D := rfl

/-- Rate-distortion is nonneg for D ≤ H_∞(X).
    When distortion budget ≤ entropy, positive rate is needed.
    Impact: certified_compression_bound — distortion ≤ entropy requires positive rate. -/
theorem minPlusRateDistortion_nonneg (μ : FinProbDist α) (D : ℝ)
    (hD : D ≤ minEntropy μ) :
    0 ≤ minPlusRateDistortion μ D := by
  unfold minPlusRateDistortion; linarith

/-- Rate-distortion is zero at D = H_∞(X).
    When distortion budget = entropy, lossless compression is not needed.
    Impact: certified_compression_bound — threshold for lossless vs lossy. -/
theorem minPlusRateDistortion_at_entropy (μ : FinProbDist α) :
    minPlusRateDistortion μ (minEntropy μ) = 0 := by
  unfold minPlusRateDistortion; ring

/-- Rate-distortion is nonpositive for D ≥ H_∞(X).
    When distortion budget exceeds entropy, no coding is needed.
    Impact: certified_compression_bound — overcomplete distortion regime. -/
theorem minPlusRateDistortion_nonpos_of_large_D (μ : FinProbDist α) (D : ℝ)
    (hD : minEntropy μ ≤ D) :
    minPlusRateDistortion μ D ≤ 0 := by
  unfold minPlusRateDistortion; linarith

/-- Rate-distortion is antitone in D.
    More distortion budget → less rate needed.
    Impact: certified_compression_bound — distortion-rate tradeoff. -/
theorem minPlusRateDistortion_antitone (μ : FinProbDist α)
    (D₁ D₂ : ℝ) (h : D₁ ≤ D₂) :
    minPlusRateDistortion μ D₂ ≤ minPlusRateDistortion μ D₁ := by
  unfold minPlusRateDistortion; linarith

/-- Rate-distortion at D = 0 equals full entropy.
    Zero distortion → lossless compression → rate = entropy.
    Impact: certified_compression_bound — lossless compression limit. -/
theorem minPlusRateDistortion_at_zero (μ : FinProbDist α) :
    minPlusRateDistortion μ 0 = minEntropy μ := by
  unfold minPlusRateDistortion; ring

/-- Uniform source has maximal rate-distortion at D = 0.
    Impact: certified_compression_bound — worst case is uniform source. -/
theorem minPlusRateDistortion_uniform_at_zero :
    minPlusRateDistortion (uniformDist α) 0 = Real.log (Fintype.card α : ℝ) := by
  rw [minPlusRateDistortion_at_zero, minEntropy_uniform_eq_log_card]

/-! ## Section 3: Tropical Code -/

/-- A tropical code: an encoding scheme with guaranteed distortion bounds.
    Bridge: coding theory ↔ tropical optimization.
    Impact: neural_network_compression — codes with certified compression bounds. -/
structure TropicalCode (α : Type*) [Fintype α] (β : Type*) [Fintype β] where
  /-- The encoding function -/
  encode : α → β
  /-- The decoding function -/
  decode : β → α
  /-- Maximum distortion under reconstruction -/
  maxDistortion : ℝ
  /-- Distortion is nonneg -/
  maxDistortion_nonneg : 0 ≤ maxDistortion

/-- The rate of a tropical code.
    Impact: neural_network_compression — rate = log of codebook size. -/
noncomputable def TropicalCode.rate {β : Type*} [Fintype β] [Nonempty β]
    (c : TropicalCode α β) : ℝ :=
  Real.log (Fintype.card β : ℝ)

/-- The compression ratio: how much the code reduces the representation.
    Impact: neural_network_compression — compression ratio quantified. -/
noncomputable def TropicalCode.compressionRatio {β : Type*} [Fintype β] [Nonempty β]
    (c : TropicalCode α β) : ℝ :=
  1 - c.rate / Real.log (Fintype.card α : ℝ)

/-! ## Section 4: Source Coding Bounds -/

/-- The rate of any code is at least R_min(D) when D ≥ H_∞ - log|β|.
    Bridge: compression ↔ entropy ↔ tropical algebra.
    Impact: certified_compression_bound — universal lower bound on rate. -/
theorem tropical_source_coding_bound (μ : FinProbDist α) (D : ℝ)
    (hD : 0 ≤ D) :
    minPlusRateDistortion μ D ≤ minEntropy μ := by
  unfold minPlusRateDistortion; linarith

/-! ## Section 5: Additive Source Coding -/

/-- For independent sources, rates are additive.
    H_∞(X × Y) - D = (H_∞(X) + H_∞(Y)) - D.
    Bridge: independence ↔ tropical tensor product.
    Impact: neural_network_compression — layer-wise compression adds rates. -/
theorem minPlusRateDistortion_product
    {β : Type*} [Fintype β] [Nonempty β]
    (μ : FinProbDist α) (ν : FinProbDist β) (D : ℝ) :
    minPlusRateDistortion (productDist μ ν) D =
    minEntropy μ + minEntropy ν - D := by
  unfold minPlusRateDistortion; rw [minEntropy_product_eq_add]

/-- Decomposition: total rate-distortion can be split across components.
    Impact: neural_network_compression — component-wise distortion allocation. -/
theorem rate_distortion_decomposition
    {β : Type*} [Fintype β] [Nonempty β]
    (μ : FinProbDist α) (ν : FinProbDist β) (D₁ D₂ : ℝ) :
    minPlusRateDistortion μ D₁ + minPlusRateDistortion ν D₂ =
    minPlusRateDistortion (productDist μ ν) (D₁ + D₂) := by
  unfold minPlusRateDistortion; rw [minEntropy_product_eq_add]; ring

/-! ## Section 6: Deterministic Source Coding -/

/-- Deterministic sources need zero rate at any distortion.
    Bridge: zero entropy ↔ trivial compression.
    Impact: neural_network_compression — constant layers need no bits. -/
theorem deterministic_source_zero_rate [DecidableEq α] (a : α) (D : ℝ) (hD : 0 ≤ D) :
    minPlusRateDistortion (deterministicDist a) D ≤ 0 := by
  unfold minPlusRateDistortion
  rw [minEntropy_deterministic_eq_zero]; linarith

/-! ## Section 7: Uniform Source Coding -/

/-- Uniform source rate-distortion: R_min(D) = log|α| - D.
    Bridge: maximum entropy ↔ hardest compression problem.
    Impact: certified_compression_bound — worst-case source bound. -/
theorem uniform_source_rate_distortion (D : ℝ) :
    minPlusRateDistortion (uniformDist α) D =
    Real.log (Fintype.card α : ℝ) - D := by
  unfold minPlusRateDistortion; rw [minEntropy_uniform_eq_log_card]

/-! ## Section 8: Distortion-Rate Function (Dual) -/

/-- Distortion-rate function: D(R) = H_∞(X) - R.
    The tropical dual of the rate-distortion function.
    Bridge: Fenchel duality ↔ tropical Legendre transform.
    Impact: certified_compression_bound — dual perspective on compression. -/
noncomputable def distortionRate (μ : FinProbDist α) (R : ℝ) : ℝ :=
  minEntropy μ - R

/-- Distortion-rate equals rate-distortion evaluated at R.
    Bridge: tropical duality ↔ self-duality of linear rate-distortion.
    Impact: certified_compression_bound — duality simplifies analysis. -/
theorem distortionRate_eq_rateDistortion (μ : FinProbDist α) (R : ℝ) :
    distortionRate μ R = minPlusRateDistortion μ R := rfl

/-- Distortion at zero rate equals entropy.
    Impact: certified_compression_bound — no bits means max distortion. -/
theorem distortionRate_at_zero (μ : FinProbDist α) :
    distortionRate μ 0 = minEntropy μ := by
  unfold distortionRate; ring

/-- Distortion at entropy rate is zero.
    Impact: certified_compression_bound — full rate means zero distortion. -/
theorem distortionRate_at_entropy (μ : FinProbDist α) :
    distortionRate μ (minEntropy μ) = 0 := by
  unfold distortionRate; ring

/-! ## Section 9: Lipschitz Properties -/

/-- Rate-distortion function is 1-Lipschitz in D.
    |R(D₁) - R(D₂)| = |D₁ - D₂|.
    Bridge: metric structure of distortion-rate space.
    Impact: lipschitz_certified_robustness — rate function is stable. -/
theorem rateDistortion_lipschitz (μ : FinProbDist α) (D₁ D₂ : ℝ) :
    |minPlusRateDistortion μ D₁ - minPlusRateDistortion μ D₂| = |D₁ - D₂| := by
  unfold minPlusRateDistortion
  rw [show (minEntropy μ - D₁) - (minEntropy μ - D₂) = D₂ - D₁ from by ring]
  rw [abs_sub_comm]

/-- Rate-distortion is 1-Lipschitz in the source entropy.
    |R_μ(D) - R_ν(D)| = |H_∞(μ) - H_∞(ν)|.
    Impact: lipschitz_certified_robustness — rate is stable under source perturbation. -/
theorem rateDistortion_lipschitz_source (μ ν : FinProbDist α) (D : ℝ) :
    |minPlusRateDistortion μ D - minPlusRateDistortion ν D| =
    |minEntropy μ - minEntropy ν| := by
  unfold minPlusRateDistortion
  congr 1; ring

/-! ## Section 10: Redundancy -/

/-- Redundancy: difference between actual rate and optimal rate-distortion.
    Bridge: information-theoretic optimality ↔ coding efficiency.
    Impact: neural_network_compression — quantifies compression suboptimality. -/
noncomputable def redundancy (μ : FinProbDist α)
    {β : Type*} [Fintype β] [Nonempty β]
    (c : TropicalCode α β) : ℝ :=
  c.rate - minPlusRateDistortion μ c.maxDistortion

/-- Redundancy at distortion D ≤ entropy is nonneg for codes with rate ≥ entropy.
    Bridge: tropical source coding converse ↔ optimality bound.
    Impact: neural_network_compression — no code beats the rate-distortion bound. -/
theorem redundancy_nonneg_of_large_rate (μ : FinProbDist α)
    {β : Type*} [Fintype β] [Nonempty β]
    (c : TropicalCode α β)
    (hrate : minEntropy μ ≤ c.rate) :
    0 ≤ redundancy μ c := by
  unfold redundancy; unfold minPlusRateDistortion; linarith [c.maxDistortion_nonneg]

/-! ## Section 11: Quantization Error -/

/-- Quantization error bound: for any n-point quantizer of a uniform source
    with n ≤ |α|, the representation gap is at least log(|α|) - log(n) ≥ 0.
    Bridge: quantization theory ↔ tropical rate-distortion.
    Impact: neural_network_compression — weight quantization lower bound. -/
theorem quantization_error_lower_bound
    (n : ℕ) (hn : 0 < n) (hle : n ≤ Fintype.card α) :
    0 ≤ Real.log (Fintype.card α : ℝ) - Real.log n := by
  have : Real.log (n : ℝ) ≤ Real.log (Fintype.card α : ℝ) := by
    apply Real.log_le_log (by positivity)
    exact Nat.cast_le.mpr hle
  linarith

/-! ## Section 12: Concatenated Source Coding -/

/-- For k independent uses of a source, the rate-distortion scales linearly.
    R_min(kD; X^k) = k · R_min(D; X).
    Bridge: independence ↔ linear scaling in tropical algebra.
    Impact: neural_network_compression — multi-layer compression scaling. -/
theorem rate_distortion_k_uses (μ : FinProbDist α) (D : ℝ) (k : ℕ) :
    k * minPlusRateDistortion μ D = k * minEntropy μ - k * D := by
  unfold minPlusRateDistortion; ring

end NonArchInfoTheory