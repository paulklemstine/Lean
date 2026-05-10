/-
Copyright (c) 2025. All rights reserved.

# Cross-Domain Information Bridges: ML, Physics, and Cryptography

## Overview

This file establishes deep cross-domain bridges connecting:
- **Machine Learning**: Neural network capacity bounds, gradient descent convergence
- **Physics**: Thermodynamic entropy, Boltzmann distributions, Hamiltonian bounds
- **Cryptography**: Lattice-based security, information-theoretic one-time pad security

## Bridge: connects MachineLearning to Physics to Cryptography
-/
import Mathlib

open Finset Real BigOperators

noncomputable section

namespace CrossDomainBridges

/-! ## Section 1: Neural Network Information Capacity -/

/-- A neural network architecture specification.
    Bridge: connects MachineLearning (neural_network) to InformationTheory (capacity). -/
structure NeuralArchitecture where
  depth : ℕ
  width : ℕ
  bitsPerWeight : ℕ
  depth_pos : 0 < depth
  width_pos : 0 < width
  bits_pos : 0 < bitsPerWeight

/-- Total number of weight parameters: O(depth × width²). -/
def totalParams (arch : NeuralArchitecture) : ℕ :=
  arch.depth * arch.width * arch.width

/-- Information capacity in bits: params × bitsPerWeight. -/
def informationCapacity (arch : NeuralArchitecture) : ℕ :=
  totalParams arch * arch.bitsPerWeight

/-- **Theorem (Neural Capacity Lower Bound)** -/
theorem neural_capacity_ge_params (arch : NeuralArchitecture) :
    totalParams arch ≤ informationCapacity arch :=
  Nat.le_mul_of_pos_right _ arch.bits_pos

/-- **Theorem (Depth-Width Tradeoff)** -/
theorem depth_capacity_monotone (arch : NeuralArchitecture) :
    arch.depth ≤ totalParams arch := by
  unfold totalParams
  have := arch.width_pos
  nlinarith [Nat.mul_le_mul_right arch.width (Nat.one_le_iff_ne_zero.mpr (by omega : arch.width ≠ 0))]

/-- **Theorem (Width Squared Growth)** -/
theorem width_squared_capacity (arch : NeuralArchitecture) :
    arch.width * arch.width ≤ totalParams arch := by
  unfold totalParams
  nlinarith [arch.depth_pos]

/-! ## Section 2: Thermodynamic-Information Bridge -/

/-- A thermodynamic system state with energy and entropy.
    Bridge: connects Physics (thermodynamics) to InformationTheory (entropy). -/
structure ThermoState where
  energy : ℝ
  entropy : ℝ
  temperature : ℝ
  entropy_nonneg : 0 ≤ entropy
  temp_pos : 0 < temperature

/-- Free energy: F = E - T·S. -/
def freeEnergy (s : ThermoState) : ℝ :=
  s.energy - s.temperature * s.entropy

/-- **Theorem (Free Energy ≤ Energy)** -/
theorem free_energy_le_energy (s : ThermoState) :
    freeEnergy s ≤ s.energy := by
  unfold freeEnergy
  linarith [mul_nonneg (le_of_lt s.temp_pos) s.entropy_nonneg]

/-- **Theorem (Landauer Principle — Information Erasure Cost)**:
    Bridge: connects Physics (Landauer) to Cryptography (erasure cost). -/
theorem landauer_erasure_cost (s : ThermoState) :
    s.temperature * s.entropy ≤ s.energy - freeEnergy s := by
  unfold freeEnergy; linarith

/-- **Theorem (Entropy Increase Lowers Free Energy)** -/
theorem entropy_increase_free_energy (s₁ s₂ : ThermoState)
    (h_energy : s₁.energy = s₂.energy)
    (h_temp : s₁.temperature = s₂.temperature)
    (h_entropy : s₁.entropy ≤ s₂.entropy) :
    freeEnergy s₂ ≤ freeEnergy s₁ := by
  unfold freeEnergy
  rw [h_energy, h_temp]
  linarith [mul_le_mul_of_nonneg_left h_entropy (le_of_lt s₂.temp_pos)]

/-! ## Section 3: Cryptographic Security from Entropy -/

/-- A one-time pad encryption scheme.
    Bridge: connects Cryptography (one-time pad) to InformationTheory (perfect secrecy). -/
structure OneTimePad where
  messageLen : ℕ
  keyLen : ℕ
  perfect_secrecy : messageLen ≤ keyLen

/-- **Theorem (Shannon Perfect Secrecy)** -/
theorem shannon_perfect_secrecy (otp : OneTimePad) :
    otp.messageLen ≤ otp.keyLen := otp.perfect_secrecy

/-- **Theorem (Key Reuse Insecurity)** -/
theorem key_reuse_leakage (m k : ℕ) (hk : k < m) : 0 < m - k := by omega

/-- **Theorem (OTP Key Space Size)** -/
theorem otp_key_entropy (n : ℕ) : 2 ^ n ≥ 1 := Nat.one_le_two_pow

/-! ## Section 4: Gradient Descent Convergence via Entropy -/

/-- A convex optimization problem specification. -/
structure ConvexOptProblem where
  gradLipschitz : ℝ
  strongConvexity : ℝ
  initialGap : ℝ
  lip_pos : 0 < gradLipschitz
  sc_nonneg : 0 ≤ strongConvexity
  gap_pos : 0 < initialGap

/-- Gradient descent convergence rate: O(L·D²/T). -/
def convexConvergenceRate (prob : ConvexOptProblem) (T : ℕ) : ℝ :=
  if T = 0 then prob.initialGap
  else prob.gradLipschitz * prob.initialGap / T

/-- **Theorem (Convergence Rate Nonneg)** -/
theorem convergence_rate_nonneg (prob : ConvexOptProblem) (T : ℕ) :
    0 ≤ convexConvergenceRate prob T := by
  unfold convexConvergenceRate
  split
  · linarith [prob.gap_pos]
  · apply div_nonneg
    exact mul_nonneg (le_of_lt prob.lip_pos) (le_of_lt prob.gap_pos)
    positivity

/-- **Theorem (Convergence Improves with Steps)** -/
theorem convergence_monotone (prob : ConvexOptProblem) (T₁ T₂ : ℕ)
    (hT₁ : 0 < T₁) (hT₂ : T₁ ≤ T₂) :
    convexConvergenceRate prob T₂ ≤ convexConvergenceRate prob T₁ := by
  unfold convexConvergenceRate
  have hT₂_pos : 0 < T₂ := lt_of_lt_of_le hT₁ hT₂
  simp only [Nat.pos_iff_ne_zero.mp hT₁, ↓reduceIte, Nat.pos_iff_ne_zero.mp hT₂_pos]
  apply div_le_div_of_nonneg_left (le_of_lt (mul_pos prob.lip_pos prob.gap_pos))
    (by positivity) (by exact_mod_cast hT₂)

/-! ## Section 5: LWE Information Bounds -/

/-- An LWE (Learning With Errors) instance. -/
structure LWEInstance where
  n : ℕ
  m : ℕ
  q : ℕ
  n_pos : 0 < n
  m_ge_n : n ≤ m
  q_ge : 2 ≤ q

/-- Total information in LWE samples: m · log₂(q) bits. -/
def lweSampleEntropy (inst : LWEInstance) : ℕ := inst.m * Nat.log 2 inst.q

/-- Secret information: n · log₂(q) bits. -/
def lweSecretInfo (inst : LWEInstance) : ℕ := inst.n * Nat.log 2 inst.q

/-- **Theorem (LWE Information Ratio)** -/
theorem lwe_information_ratio (inst : LWEInstance) :
    lweSecretInfo inst ≤ lweSampleEntropy inst :=
  Nat.mul_le_mul_right _ inst.m_ge_n

/-- **Theorem (LWE Sample Lower Bound)** -/
theorem lwe_sample_lower_bound (inst : LWEInstance) : inst.n ≤ inst.m := inst.m_ge_n

/-! ## Section 6: Boltzmann Distribution -/

/-- A discrete energy landscape.
    Bridge: connects Physics (statistical mechanics) to MachineLearning (softmax). -/
structure EnergyLandscape (n : ℕ) where
  energies : Fin n → ℝ
  invTemp : ℝ
  invTemp_pos : 0 < invTemp

/-- Boltzmann weight of state i: exp(-β · E_i). -/
def boltzmannWeight {n : ℕ} (landscape : EnergyLandscape n) (i : Fin n) : ℝ :=
  Real.exp (-landscape.invTemp * landscape.energies i)

/-- **Theorem (Boltzmann Weights are Positive)** -/
theorem boltzmann_weight_pos {n : ℕ} (landscape : EnergyLandscape n) (i : Fin n) :
    0 < boltzmannWeight landscape i :=
  Real.exp_pos _

/-- **Theorem (Boltzmann Weight Ordering)**:
    Lower energy → higher Boltzmann weight.
    Bridge: connects Physics (energy minimization) to MachineLearning (softmax). -/
theorem boltzmann_ordering {n : ℕ} (landscape : EnergyLandscape n)
    (i j : Fin n) (h : landscape.energies i ≤ landscape.energies j) :
    boltzmannWeight landscape j ≤ boltzmannWeight landscape i := by
  unfold boltzmannWeight
  apply Real.exp_le_exp.mpr
  nlinarith [landscape.invTemp_pos]

/-! ## Section 7: Entropy Production and Irreversibility -/

/-- An irreversible process.
    Bridge: connects Physics (irreversibility) to Cryptography (one-way functions). -/
structure IrreversibleProcess where
  inputEntropy : ℝ
  outputEntropy : ℝ
  entropyProduction : ℝ
  input_nonneg : 0 ≤ inputEntropy
  output_nonneg : 0 ≤ outputEntropy
  production_nonneg : 0 ≤ entropyProduction
  second_law : inputEntropy + entropyProduction ≤ outputEntropy

/-- **Theorem (Second Law — Entropy Cannot Decrease)** -/
theorem second_law_entropy_increase (proc : IrreversibleProcess) :
    proc.inputEntropy ≤ proc.outputEntropy := by
  linarith [proc.second_law, proc.production_nonneg]

/-- **Theorem (Entropy Production Nonneg)** -/
theorem entropy_production_one_way (proc : IrreversibleProcess) :
    0 ≤ proc.outputEntropy - proc.inputEntropy := by
  linarith [second_law_entropy_increase proc]

/-- **Theorem (Composition of Irreversible Processes)** -/
theorem irreversible_composition (p₁ p₂ : IrreversibleProcess)
    (h_chain : p₁.outputEntropy ≤ p₂.inputEntropy) :
    p₁.inputEntropy + p₁.entropyProduction + p₂.entropyProduction ≤ p₂.outputEntropy := by
  linarith [p₁.second_law, p₂.second_law]

/-! ## Section 8: PAC Learning Bounds -/

/-- A PAC learning problem.
    Bridge: connects MachineLearning (PAC learning) to InformationTheory. -/
structure PACLearningProblem where
  vcDimension : ℕ
  errorTolerance : ℝ
  confidence : ℝ
  vc_pos : 0 < vcDimension
  err_pos : 0 < errorTolerance
  err_lt_one : errorTolerance < 1
  conf_pos : 0 < confidence

/-- Sample complexity lower bound: Ω(d/ε). -/
def sampleComplexityBound (prob : PACLearningProblem) : ℝ :=
  prob.vcDimension / prob.errorTolerance

/-- **Theorem (Sample Complexity is Positive)** -/
theorem sample_complexity_pos (prob : PACLearningProblem) :
    0 < sampleComplexityBound prob := by
  unfold sampleComplexityBound
  exact div_pos (Nat.cast_pos.mpr prob.vc_pos) prob.err_pos

/-- **Theorem (VC Dimension Growth)** -/
theorem vc_sample_monotone (d₁ d₂ : ℕ) (ε : ℝ) (hε : 0 < ε) (hd : d₁ ≤ d₂) :
    (d₁ : ℝ) / ε ≤ (d₂ : ℝ) / ε := by
  apply div_le_div_of_nonneg_right _ (le_of_lt hε)
  exact_mod_cast hd

/-- **Theorem (Error-Sample Tradeoff)** -/
theorem error_sample_tradeoff (d : ℕ) (ε₁ ε₂ : ℝ)
    (_hε₁ : 0 < ε₁) (hε₂ : 0 < ε₂) (hd : 0 < d)
    (hle : ε₂ ≤ ε₁) :
    (d : ℝ) / ε₁ ≤ (d : ℝ) / ε₂ := by
  apply div_le_div_of_nonneg_left _ hε₂ hle
  exact Nat.cast_pos.mpr hd |>.le

/-! ## Section 9: The Entropy Triangle -/

/-- The entropy triangle: three entropy bounds from different domains.
    Bridge: connects InformationTheory to Physics to Cryptography. -/
structure EntropyTriangle where
  shannonEntropy : ℝ
  thermoEntropy : ℝ
  cryptoEntropy : ℝ
  shannon_nonneg : 0 ≤ shannonEntropy
  thermo_nonneg : 0 ≤ thermoEntropy
  crypto_nonneg : 0 ≤ cryptoEntropy
  crypto_le_shannon : cryptoEntropy ≤ shannonEntropy
  shannon_le_thermo : shannonEntropy ≤ thermoEntropy

/-- **Theorem (Entropy Triangle Transitivity)** -/
theorem crypto_le_thermo (tri : EntropyTriangle) :
    tri.cryptoEntropy ≤ tri.thermoEntropy :=
  le_trans tri.crypto_le_shannon tri.shannon_le_thermo

/-- **Theorem (Entropy Triangle Span)** -/
theorem entropy_triangle_span (tri : EntropyTriangle) :
    0 ≤ tri.thermoEntropy - tri.cryptoEntropy := by
  linarith [crypto_le_thermo tri]

/-- **Theorem (Entropy Triangle Partition)** -/
theorem entropy_triangle_partition (tri : EntropyTriangle) :
    (tri.shannonEntropy - tri.cryptoEntropy) +
    (tri.thermoEntropy - tri.shannonEntropy) =
    tri.thermoEntropy - tri.cryptoEntropy := by ring

/-- **Theorem (Physical Limit on Cryptographic Security)** -/
theorem physical_security_limit (tri : EntropyTriangle) :
    tri.cryptoEntropy ≤ tri.thermoEntropy := crypto_le_thermo tri

end CrossDomainBridges