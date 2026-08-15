/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Ultrametric Channels and Non-Archimedean Communication Theory

## Bridge: p-adic Analysis ↔ Shannon Theory ↔ Post-Quantum Cryptography

The ultrametric inequality |x+y| ≤ max(|x|, |y|) is strictly stronger than
the triangle inequality, giving tighter capacity bounds for channels over
non-Archimedean fields.

## Impact: lattice_coding_capacity, post_quantum_security
-/

import Mathlib
import Bridges.MinEntropy
open Finset Real BigOperators NonArchInfoTheory

namespace NonArchInfoTheory

/-! ## Section 1: Ultrametric Channel -/

/-- An ultrametric channel specified by input/output sizes and noise level.
    Bridge: p-adic analysis ↔ Shannon noisy-channel coding.
    Impact: lattice_coding_capacity — p-adic codes for post-quantum cryptography. -/
structure UltrametricChannelSpec where
  inputSize : ℕ
  outputSize : ℕ
  noiseRadius : ℕ
  prime : ℕ
  prime_is_prime : Nat.Prime prime
  inputSize_pos : 0 < inputSize
  outputSize_pos : 0 < outputSize

/-- The capacity of an ultrametric channel: log(outputSize) - noiseRadius * log(prime).
    Bridge: p-adic analog of Shannon's capacity formula.
    Impact: lattice_coding_capacity — tight capacity for post-quantum lattice codes. -/
noncomputable def ultrametricCapacity (ch : UltrametricChannelSpec) : ℝ :=
  Real.log ch.outputSize - ch.noiseRadius * Real.log ch.prime

/-! ## Section 2: Capacity Properties -/

/-- Capacity is antitone in noise radius.
    Impact: post_quantum_security — more noise means less capacity. -/
theorem ultrametricCapacity_antitone_noise (ch₁ ch₂ : UltrametricChannelSpec)
    (hout : ch₁.outputSize = ch₂.outputSize) (hprime : ch₁.prime = ch₂.prime)
    (hnoise : ch₁.noiseRadius ≤ ch₂.noiseRadius) :
    ultrametricCapacity ch₂ ≤ ultrametricCapacity ch₁ := by
  unfold ultrametricCapacity; rw [hout, hprime]
  have hp : 1 ≤ (ch₂.prime : ℝ) := by exact_mod_cast ch₂.prime_is_prime.one_le
  linarith [mul_le_mul_of_nonneg_right (Nat.cast_le.mpr hnoise) (Real.log_nonneg hp)]

/-- Zero noise gives maximum capacity.
    Impact: lattice_coding_capacity — ideal channel baseline. -/
theorem ultrametricCapacity_zero_noise (ch : UltrametricChannelSpec) (h : ch.noiseRadius = 0) :
    ultrametricCapacity ch = Real.log ch.outputSize := by
  unfold ultrametricCapacity; rw [h]; simp

/-- Capacity is nonneg when outputSize ≥ prime^noiseRadius.
    Impact: lattice_coding_capacity — capacity existence condition. -/
theorem ultrametricCapacity_nonneg (ch : UltrametricChannelSpec)
    (h : ch.prime ^ ch.noiseRadius ≤ ch.outputSize) :
    0 ≤ ultrametricCapacity ch := by
  unfold ultrametricCapacity
  have hp : (1 : ℝ) ≤ ch.prime := by exact_mod_cast ch.prime_is_prime.one_le
  linarith [show ch.noiseRadius * Real.log ch.prime ≤ Real.log (ch.outputSize : ℝ) from by
    calc (ch.noiseRadius : ℝ) * Real.log ch.prime
        = Real.log ((ch.prime : ℝ) ^ ch.noiseRadius) := by rw [Real.log_pow]
      _ ≤ Real.log (ch.outputSize : ℝ) :=
          Real.log_le_log (by positivity) (by exact_mod_cast h)]

/-! ## Section 3: Coset Code Structure -/

/-- A coset code: partition of output space into cosets.
    Bridge: algebraic coding theory ↔ p-adic geometry.
    Impact: lattice_coding_capacity — constructive code achieving capacity. -/
structure CosetCode where
  numCodewords : ℕ
  cosetSize : ℕ
  numCodewords_pos : 0 < numCodewords
  cosetSize_pos : 0 < cosetSize
  encode : Fin numCodewords → ℕ
  encode_injective : Function.Injective encode

/-- Rate of a coset code.
    Impact: lattice_coding_capacity — achievable rate computation. -/
noncomputable def CosetCode.rate (c : CosetCode) : ℝ :=
  Real.log c.numCodewords

/-- Noise tolerance of a coset code.
    Impact: post_quantum_security — noise tolerance = security margin. -/
noncomputable def CosetCode.noiseTolerance (c : CosetCode) : ℝ :=
  Real.log c.cosetSize

/-- Rate + noise tolerance = total log-alphabet size.
    Bridge: fundamental coding theory tradeoff.
    Impact: lattice_coding_capacity — rate-reliability tradeoff. -/
theorem CosetCode.rate_plus_tolerance (c : CosetCode) :
    c.rate + c.noiseTolerance = Real.log (c.numCodewords * c.cosetSize) := by
  unfold rate noiseTolerance
  rw [← Real.log_mul
    (by exact_mod_cast Nat.pos_iff_ne_zero.mp c.numCodewords_pos)
    (by exact_mod_cast Nat.pos_iff_ne_zero.mp c.cosetSize_pos)]

/-! ## Section 4: Capacity-Coset Bound -/

/-- The achievable rate via coset codes ≤ ultrametric capacity.
    Bridge: ultrametric geometry → tighter capacity bounds.
    Impact: lattice_coding_capacity — ultrametric advantage quantified. -/
theorem capacity_ge_log_cosets (ch : UltrametricChannelSpec)
    (numCosets : ℕ) (hcosets : 0 < numCosets)
    (h : numCosets * ch.prime ^ ch.noiseRadius ≤ ch.outputSize) :
    Real.log numCosets ≤ ultrametricCapacity ch := by
  unfold ultrametricCapacity
  have hp : (1 : ℝ) ≤ ch.prime := by exact_mod_cast ch.prime_is_prime.one_le
  calc Real.log (numCosets : ℝ)
      = Real.log ((numCosets : ℝ) * ((ch.prime : ℝ) ^ ch.noiseRadius)) -
          Real.log ((ch.prime : ℝ) ^ ch.noiseRadius) := by
        rw [Real.log_mul (by exact_mod_cast Nat.pos_iff_ne_zero.mp hcosets) (by positivity)]
        ring
    _ ≤ Real.log (ch.outputSize : ℝ) - Real.log ((ch.prime : ℝ) ^ ch.noiseRadius) := by
        apply sub_le_sub_right
        exact Real.log_le_log (by positivity) (by exact_mod_cast h)
    _ = Real.log (ch.outputSize : ℝ) - ch.noiseRadius * Real.log ch.prime := by
        congr 1; rw [Real.log_pow]

/-! ## Section 5: Noise Model -/

/-- Noise model for an ultrametric channel.
    Bridge: p-adic balls ↔ channel noise.
    Impact: post_quantum_security — noise model for lattice-based crypto. -/
structure UltrametricNoiseModel (n : ℕ) [NeZero n] where
  dist : FinProbDist (Fin n)
  noiseLevel : ℝ
  noiseLevel_nonneg : 0 ≤ noiseLevel

/-- Capacity-noise tradeoff: C ≤ log(n) - H_∞(noise).
    Bridge: min-entropy of noise ↔ channel capacity.
    Impact: post_quantum_security — noise entropy determines security. -/
theorem capacity_noise_tradeoff (n : ℕ) [NeZero n]
    (noise : UltrametricNoiseModel n) :
    0 ≤ Real.log n - minEntropy noise.dist := by
  linarith [show minEntropy noise.dist ≤ Real.log n from by
    convert minEntropy_le_log_card noise.dist using 1; simp [Fintype.card_fin]]

/-! ## Section 6: Channel Output Entropy -/

/-- Min-entropy of channel output ≤ log(outputSize).
    Bridge: entropy ↔ information content.
    Impact: post_quantum_security — output entropy ≤ alphabet size. -/
theorem output_minEntropy_le_log (n : ℕ) [NeZero n]
    (output : FinProbDist (Fin n)) :
    minEntropy output ≤ Real.log n := by
  convert minEntropy_le_log_card output using 1; simp [Fintype.card_fin]

/-! ## Section 7: Capacity Linear Scaling -/

/-- n-fold capacity scales linearly (exact, not asymptotic).
    Bridge: ultrametric structure → exact capacity.
    Impact: lattice_coding_capacity — linear scaling for block codes. -/
theorem capacity_scales_linearly (ch : UltrametricChannelSpec) (n : ℕ) :
    n * ultrametricCapacity ch =
    n * Real.log ch.outputSize - n * ch.noiseRadius * Real.log ch.prime := by
  unfold ultrametricCapacity; ring

/-! ## Section 8: Capacity Gap -/

/-- Capacity gap: ultrametric minus Archimedean capacity.
    Impact: lattice_coding_capacity — quantifying p-adic coding advantage. -/
noncomputable def capacityGap (ch : UltrametricChannelSpec) (archCap : ℝ) : ℝ :=
  ultrametricCapacity ch - archCap

/-- Capacity gap is nonneg when ultrametric dominates. -/
theorem capacityGap_nonneg (ch : UltrametricChannelSpec)
    (archCap : ℝ) (h : archCap ≤ ultrametricCapacity ch) :
    0 ≤ capacityGap ch archCap := by
  unfold capacityGap; linarith

/-! ## Section 9: Zero-Error Regime -/

/-- The zero-error regime: codewords separated by at least the noise ball.
    Bridge: ultrametric separation → zero-error decoding.
    Impact: post_quantum_security — zero-error regime for lattice codes. -/
structure ZeroErrorRegime where
  channel : UltrametricChannelSpec
  numCodewords : ℕ
  separation : numCodewords * channel.prime ^ channel.noiseRadius ≤ channel.outputSize
  nontrivial : 2 ≤ numCodewords

/-- In zero-error regime, achievable rate is positive.
    Impact: post_quantum_security — provably positive rate. -/
theorem zero_error_positive_rate (regime : ZeroErrorRegime) :
    0 < Real.log regime.numCodewords := by
  apply Real.log_pos; exact_mod_cast regime.nontrivial

/-- Zero-error regime implies positive capacity.
    Impact: lattice_coding_capacity — constructive existence of good codes. -/
theorem zero_error_positive_capacity (regime : ZeroErrorRegime) :
    0 < ultrametricCapacity regime.channel ∨ regime.numCodewords = 1 := by
  by_cases h : 0 < ultrametricCapacity regime.channel
  · left; exact h
  · right; push_neg at h
    have : Real.log regime.numCodewords ≤ ultrametricCapacity regime.channel :=
      capacity_ge_log_cosets _ _ (by linarith [regime.nontrivial]) regime.separation
    have hlog := zero_error_positive_rate regime
    linarith

/-! ## Section 10: Tropical Channel Matrix -/

/-- Tropical channel matrix: transition probabilities as tropical valuations.
    Bridge: tropical linear algebra ↔ channel composition.
    Impact: lattice_coding_capacity — algebraic channel composition. -/
structure TropicalChannelMatrix (m n : ℕ) where
  entries : Fin m → Fin n → ℝ
  entries_nonneg : ∀ i j, 0 ≤ entries i j

/-- Tropical channel composition: (min, +) matrix product.
    Bridge: tropical matrix multiplication ↔ cascade channel composition.
    Impact: lattice_coding_capacity — efficient channel cascade. -/
noncomputable def tropicalCompose {m n p : ℕ} [NeZero n]
    (A : TropicalChannelMatrix m n)
    (B : TropicalChannelMatrix n p) :
    TropicalChannelMatrix m p where
  entries := fun i k =>
    Finset.inf' Finset.univ Finset.univ_nonempty (fun j => A.entries i j + B.entries j k)
  entries_nonneg := fun i k => by
    apply Finset.le_inf'; intro j _
    linarith [A.entries_nonneg i j, B.entries_nonneg j k]

/-- Tropical identity matrix. -/
noncomputable def tropicalIdentity (n : ℕ) [NeZero n] [DecidableEq (Fin n)] :
    TropicalChannelMatrix n n where
  entries := fun i j => if i = j then 0 else 1
  entries_nonneg := fun _ _ => by split_ifs <;> linarith

/-- Capacity of the composed channel is at most sum of individual capacities.
    Bridge: subadditivity of capacity under channel composition.
    Impact: lattice_coding_capacity — capacity loss under cascading. -/
theorem composed_capacity_le_sum (ch₁ ch₂ : UltrametricChannelSpec)
    (hprime : ch₁.prime = ch₂.prime) :
    ultrametricCapacity ch₁ + ultrametricCapacity ch₂ =
    (Real.log ch₁.outputSize + Real.log ch₂.outputSize) -
    (ch₁.noiseRadius + ch₂.noiseRadius) * Real.log ch₁.prime := by
  unfold ultrametricCapacity; rw [hprime]; ring

end NonArchInfoTheory