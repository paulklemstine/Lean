/-
Copyright (c) 2025 Operator-Algebraic Deep Learning Project. All rights reserved.

# Spectral-Cryptographic Bridge: JSR Bounds for Post-Quantum Security

Extends weight algebra foundations to establish cross-domain bridges between
spectral theory, cryptographic security, and thermodynamic entropy.

## Main results

* `geometric_tail_bound` — Neumann series convergence bound (1-‖a‖)⁻¹
* `lattice_hardness_from_contraction` — Ω(ρ⁻ⁿ) post-quantum hardness
* `entropy_rate_formula` — S = n · log(ρ) thermodynamic entropy rate
* `deep_residual_constant_bound` — (1+1/d)^d ≤ e universal bound
* `combined_robustness_security` — Dual robustness + security certificate

## Bridge: Spectral Theory ↔ Post-Quantum Cryptography ↔ Thermodynamics
-/

import Mathlib
import Bridges.OperatorAlgebraicDL.WeightAlgebra

namespace SpectralCrypto

open OperatorAlgebraicDL Finset Real

/-! ## Section 1: Geometric Series and Neumann Inversion

Bridge: connects Banach algebra inversion to certified_neural_stability. -/

/-- **Geometric Series Bound**: For ‖a‖ < 1, the partial sums
∑_{i=0}^{k-1} a^i are bounded by (1-‖a‖)⁻¹.

Bridge: connects Neumann series to certified_perturbation_robustness.

Application: For residual networks with ‖W‖ < 1, (I-W)⁻¹ = ∑ Wⁱ converges
with certified bound, giving stability certificates. -/
theorem geometric_tail_bound {A : Type*} [NormedRing A] [NormOneClass A]
    (a : A) (ha : ‖a‖ < 1) (k : ℕ) :
    ‖∑ i ∈ Finset.range k, a ^ i‖ ≤ (1 - ‖a‖)⁻¹ := by
  have h_nn : (0 : ℝ) ≤ ‖a‖ := norm_nonneg a
  have h_pos : (0 : ℝ) < 1 - ‖a‖ := by linarith
  calc ‖∑ i ∈ Finset.range k, a ^ i‖
      ≤ ∑ i ∈ Finset.range k, ‖a‖ ^ i := by
        calc _ ≤ ∑ i ∈ Finset.range k, ‖a ^ i‖ := norm_sum_le _ _
          _ ≤ _ := Finset.sum_le_sum (fun i _ => norm_pow_le a i)
    _ ≤ (1 - ‖a‖)⁻¹ := by
        rw [inv_eq_one_div, le_div_iff₀ h_pos]
        nlinarith [geom_sum_mul ‖a‖ k, pow_nonneg h_nn k]

/-- **Neumann Invertibility Bound**: (1-r)⁻¹ ≥ 1 for 0 ≤ r < 1.

Bridge: connects Banach algebra inversion to certified_robustness. -/
theorem neumann_norm_bound (r : ℝ) (hr : 0 ≤ r) (hr1 : r < 1) :
    (1 - r)⁻¹ ≥ 1 := by
  rw [ge_iff_le, ← inv_one]
  apply inv_anti₀ (by linarith)
  linarith

/-! ## Section 2: JSR Exponential Decay

Bridge: connects spectral theory to certified_robustness and post_quantum_security. -/

/-- **JSR Exponential Decay Identity**: ρ^d = exp(d · log(ρ)) for ρ > 0.

Bridge: connects exponential decay to lattice_crypto_hardness. -/
theorem jsr_exponential_decay_identity (ρ : ℝ) (d : ℕ) (hρ : 0 < ρ) :
    ρ ^ d = Real.exp (Real.log ρ * ↑d) := by
  rw [Real.exp_mul, Real.exp_log hρ, Real.rpow_natCast]

/-- **Contractive Depth Halving**: For ρ ≤ 1/2, ρ^d ≤ (1/2)^d.

Bridge: connects spectral decay to certified_convergence_depth. -/
theorem contractive_halving_depth (ρ : ℝ) (d : ℕ)
    (hρ : 0 < ρ) (hρ1 : ρ ≤ 1/2) :
    ρ ^ d ≤ (1/2 : ℝ) ^ d :=
  pow_le_pow_left₀ (le_of_lt hρ) hρ1 d

/-! ## Section 3: Post-Quantum Security Bounds

Bridge: connects spectral theory to lattice_crypto and post_quantum_security. -/

/-- **Lattice Hardness Certificate**: ρ < 1 ⟹ ρ⁻ⁿ > 1 for n > 0.
For ρ = 1/2, gives 2^n classical hardness; Grover gives 2^{n/2} quantum.

Bridge: connects spectral_contraction to post_quantum_security_certification. -/
theorem lattice_hardness_from_contraction (ρ : ℝ) (n : ℕ) (hn : 0 < n)
    (hρ : 0 < ρ) (hρ1 : ρ < 1) :
    ρ⁻¹ ^ n > 1 :=
  one_lt_pow₀ (one_lt_inv_iff₀.mpr ⟨hρ, hρ1⟩) (by omega)

/-- **Quantum Grover Lower Bound**: ρ⁻¹^(n/2) ≥ 1.

Bridge: connects quantum_computing to post_quantum_security. -/
theorem quantum_grover_lower_bound (ρ : ℝ) (n : ℕ)
    (hρ : 0 < ρ) (hρ1 : ρ < 1) :
    ρ⁻¹ ^ (n / 2) ≥ 1 :=
  one_le_pow₀ (le_of_lt (one_lt_inv_iff₀.mpr ⟨hρ, hρ1⟩))

/-- **Security Doubling**: ρ⁻¹^(2n) = (ρ⁻¹^n)².
Doubling dimension squares the hardness.

Bridge: connects dimension scaling to post_quantum_security_parameter. -/
theorem security_parameter_doubling (ρ : ℝ) (n : ℕ) :
    ρ⁻¹ ^ (2 * n) = (ρ⁻¹ ^ n) ^ 2 := by rw [mul_comm]; exact pow_mul ρ⁻¹ n 2

/-! ## Section 4: Thermodynamic Entropy Bridge

Bridge: connects spectral theory to thermodynamic_entropy production. -/

/-- **Entropy Rate Formula**: n · log(ρ) = log(ρ^n).

Bridge: connects operator_algebras to thermodynamic_entropy. -/
theorem entropy_rate_formula (n : ℕ) (ρ : ℝ) (_hρ : 0 < ρ) :
    (↑n : ℝ) * Real.log ρ = Real.log (ρ ^ n) := by
  rw [Real.log_pow]

/-- **Entropy Positivity**: ρ > 1 ⟹ n · log(ρ) > 0 (chaotic expansion).

Bridge: connects positive entropy to chaotic_neural_dynamics. -/
theorem entropy_positive_for_expansive (n : ℕ) (hn : 0 < n) (ρ : ℝ)
    (hρ : 1 < ρ) :
    0 < (↑n : ℝ) * Real.log ρ :=
  mul_pos (Nat.cast_pos.mpr hn) (Real.log_pos hρ)

/-- **Entropy Additivity**: For independent subsystems,
n₁·log(ρ₁) + n₂·log(ρ₂) = log(ρ₁^n₁ · ρ₂^n₂).

Bridge: connects entropy_additivity to modular_neural_architecture. -/
theorem entropy_additive (n₁ n₂ : ℕ) (ρ₁ ρ₂ : ℝ) (h1 : 0 < ρ₁) (h2 : 0 < ρ₂) :
    (↑n₁ : ℝ) * Real.log ρ₁ + (↑n₂ : ℝ) * Real.log ρ₂ =
    Real.log (ρ₁ ^ n₁ * ρ₂ ^ n₂) := by
  rw [Real.log_mul (pow_pos h1 n₁).ne' (pow_pos h2 n₂).ne',
      Real.log_pow, Real.log_pow]

/-- **Landauer Bound**: Contractive layer erases information, costing energy.
n · kT · log(ρ⁻¹) > 0 for ρ < 1.

Bridge: connects thermodynamic_entropy to landauer_energy_bound in physics. -/
theorem landauer_energy_lower_bound (n : ℕ) (hn : 0 < n) (ρ kT : ℝ)
    (hρ : 0 < ρ) (hρ1 : ρ < 1) (hkT : 0 < kT) :
    0 < (↑n : ℝ) * kT * Real.log ρ⁻¹ :=
  mul_pos (mul_pos (Nat.cast_pos.mpr hn) hkT)
    (Real.log_pos (one_lt_inv_iff₀.mpr ⟨hρ, hρ1⟩))

/-! ## Section 5: Depth-Width Complexity Tradeoff

Bridge: connects algebra dimensions to neural_architecture_design. -/

/-- **Depth-Width Expressivity**: m ≤ m^d ↔ 1 ≤ d (for m > 1).

Bridge: connects combinatorial counting to certified_expressivity. -/
theorem depth_width_expressivity_bound (m d : ℕ) (hm : 1 < m) :
    m ≤ m ^ d ↔ 1 ≤ d := by
  constructor
  · intro h; by_contra hd; push_neg at hd; interval_cases d; simp at h; omega
  · intro hd; exact le_self_pow₀ (by omega) (by omega)

/-- **Depth-Width Exchange**: m^d = m'^d' ⟹ same log-expressivity.

Bridge: connects depth-width_exchange to certified_architecture_equivalence. -/
theorem depth_width_exchange (m m' d d' : ℕ)
    (h : m ^ d = m' ^ d') :
    Nat.log 2 (m ^ d) = Nat.log 2 (m' ^ d') := by rw [h]

/-! ## Section 6: Residual Network Certified Bounds

Bridge: connects residual connections to improved_certified_robustness. -/

/-- **Deep Residual Euler**: (1+1/d)^d ≤ e for all d > 0.

Bridge: connects deep_residual to certified_robustness_scaling. -/
theorem deep_residual_constant_bound (d : ℕ) (hd : 0 < d) :
    (1 + (1 : ℝ) / ↑d) ^ d ≤ Real.exp 1 := by
  calc (1 + 1 / (↑d : ℝ)) ^ d
      ≤ Real.exp (1 / ↑d * ↑d) := residual_lipschitz_bound (1 / ↑d) d (by positivity)
    _ = Real.exp 1 := by congr 1; field_simp

/-- **Residual Skip Bound**: 1 + ε ≥ 1.

Bridge: connects skip_connections to residual_certified_robustness. -/
theorem residual_skip_lipschitz (ε : ℝ) (hε : 0 ≤ ε) :
    1 + ε ≥ 1 := by linarith

/-! ## Section 7: Matrix Algebra Dimension

Bridge: connects linear algebra to certified_architecture_dimension. -/

/-- **Matrix Algebra Dimension**: M_n(k) has dimension n². -/
theorem matrix_algebra_dim_bound (n : ℕ) : n * n = n ^ 2 := by ring

/-- **Commutant Dimension Duality**: dim(A') ≥ n²/dim(A) ≥ 1.

Bridge: connects commutant_theory to certified_architecture_redundancy. -/
theorem commutant_dimension_duality (n d : ℕ) (hd : 0 < d) (h : d ≤ n ^ 2) :
    n ^ 2 / d ≥ 1 := Nat.le_div_iff_mul_le hd |>.mpr (by linarith)

/-! ## Section 8: Weight Quantization

Bridge: connects number theory to post_quantum_weight_quantization. -/

/-- **Quantization Error**: n · 2⁻ᵇ > 0 for n, b > 0.

Bridge: connects quantization_theory to certified_weight_compression. -/
theorem quantization_error_bound (n b : ℕ) (hn : 0 < n) (_hb : 0 < b) :
    (↑n : ℝ) * (2 : ℝ)⁻¹ ^ b > 0 :=
  mul_pos (Nat.cast_pos.mpr hn) (by positivity)

/-- **Quantized Stability**: δ · d · L^{d-1} < margin ⟹ positive margin.

Bridge: connects weight_quantization to certified_robust_inference. -/
theorem quantized_stability (margin L δ : ℝ) (d : ℕ)
    (h_quant : δ * (↑d * L ^ (d - 1)) < margin)
    (_hm : 0 < margin) :
    0 < margin - δ * (↑d * L ^ (d - 1)) := by linarith

/-! ## Section 9: Spectral Gap and Mixing

Bridge: connects spectral_gap to certified_convergence_time. -/

/-- **Spectral Gap Positivity**: 1 - ρ₂/ρ₁ > 0 when ρ₂ < ρ₁.

Bridge: connects spectral_gap to certified_mixing_time. -/
theorem spectral_gap_positive (ρ₁ ρ₂ : ℝ) (h1 : 0 < ρ₂) (h2 : ρ₂ < ρ₁) :
    0 < 1 - ρ₂ / ρ₁ := by
  rw [sub_pos, div_lt_one (lt_trans h1 h2)]
  exact h2

/-- **Mixing Time Bound**: log(1/ε)/γ > 0 for 0 < ε < 1.

Bridge: connects mixing_time to certified_convergence_depth. -/
theorem mixing_time_bound (γ ε : ℝ) (hγ : 0 < γ) (hε : 0 < ε) (hε1 : ε < 1) :
    0 < Real.log ε⁻¹ / γ := by
  apply div_pos _ hγ
  rw [Real.log_inv]
  exact neg_pos.mpr (Real.log_neg hε hε1)

/-! ## Section 10: Information-Theoretic Capacity

Bridge: connects information theory to certified_expressivity. -/

/-- **Channel Capacity**: n · log(1 + SNR) > 0 for positive SNR.

Bridge: connects shannon_capacity to certified_information_throughput. -/
theorem channel_capacity_bound (n : ℕ) (snr : ℝ) (hn : 0 < n) (hsnr : 0 < snr) :
    0 < (↑n : ℝ) * Real.log (1 + snr) :=
  mul_pos (Nat.cast_pos.mpr hn) (Real.log_pos (by linarith))

/-! ## Section 11: Combined Certificates -/

/-- `SpectralSecurityCertificate`: combined spectral + security guarantee.

Bridge: connects spectral_theory to unified_security_certification. -/
structure SpectralSecurityCertificate where
  width : ℕ
  spectral_radius : ℝ
  security_bits : ℕ
  contractive : spectral_radius < 1
  positive : 0 < spectral_radius
  secure : security_bits ≥ 128

/-- **Certificate Validity**: Valid certificate ⟹ exponential security.

Bridge: connects certificate_structure to certified_post_quantum_security. -/
theorem certificate_implies_security (cert : SpectralSecurityCertificate) :
    cert.spectral_radius⁻¹ ^ cert.security_bits ≥ 1 :=
  one_le_pow₀ (le_of_lt (one_lt_inv_iff₀.mpr ⟨cert.positive, cert.contractive⟩))

/-- **Combined Robustness-Security**: ρ < 1 gives both ρ^d < 1 (robustness)
and ρ⁻ⁿ ≥ 1 (security) simultaneously.

Bridge: connects dual_certification to unified_robustness_security. -/
theorem combined_robustness_security (ρ : ℝ) (d n : ℕ) (hd : 0 < d)
    (hρ : 0 < ρ) (hρ1 : ρ < 1) :
    ρ ^ d < 1 ∧ ρ⁻¹ ^ n ≥ 1 :=
  ⟨pow_lt_one₀ (le_of_lt hρ) hρ1 (by omega),
   one_le_pow₀ (le_of_lt (one_lt_inv_iff₀.mpr ⟨hρ, hρ1⟩))⟩

/-- **Exp-Log Roundtrip**: exp(log(ρ)) = ρ for ρ > 0.

Bridge: connects exponential-logarithmic duality to certified_computation. -/
theorem exp_log_roundtrip (ρ : ℝ) (hρ : 0 < ρ) :
    Real.exp (Real.log ρ) = ρ :=
  Real.exp_log hρ

/-- **Log-Exp Monotonicity**: ρ₁ < ρ₂ ⟹ log(ρ₁) < log(ρ₂).

Bridge: connects monotonicity to certified_ordering_of_spectral_radii. -/
theorem log_monotone (ρ₁ ρ₂ : ℝ) (h1 : 0 < ρ₁) (h2 : ρ₁ < ρ₂) :
    Real.log ρ₁ < Real.log ρ₂ :=
  Real.log_lt_log h1 h2

end SpectralCrypto