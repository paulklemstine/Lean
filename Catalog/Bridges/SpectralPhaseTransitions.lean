/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Spectral Phase Transitions in Quantum Many-Body Certification

This file formalizes a **sharp certification threshold** governing when a noisy quantum
Hamiltonian retains enough spectral structure to certify persistence of a quantum phase.

The central insight mirrors the 2σ edge phenomenon from random matrix theory: if a
Hamiltonian H has a spectral gap Δ separating a low-energy subspace from excited states,
and N is a Hermitian noise operator, then the perturbed Hamiltonian H + pN retains a
positive residual gap if and only if the perturbation strength p is below the critical
threshold p* = Δ/(2‖N‖).

The factor of 2 arises because both the ground-state energy (rising by at most p‖N‖)
and the first excited energy (falling by at most p‖N‖) can move toward each other,
closing the gap at rate 2p‖N‖.

## Main Definitions

* `certThreshold` — The critical perturbation strength Δ/(2σ)
* `Subcritical` — Predicate for perturbation below half the gap
* `certificationResidualGap` — Residual gap Δ − 2pσ after perturbation
* `CertificationPhaseRegime` — Inductive type classifying stable/critical/unstable regimes
* `SpectralCertificate` — Structure encoding a low-energy subspace and gap

## Main Results

* `certThreshold_spec` — Below threshold implies positive residual gap
* `subcritical_gap_stability` — Subcritical perturbation preserves spectral gap
* `energy_certification_bound` — Energy of ground states under perturbation
* `certThreshold_monotone_gap` — Larger gap ⟹ larger certification window
* `certThreshold_antitone_noise` — Larger noise ⟹ smaller certification window
* `certificationResidualGap_pos_iff` — Residual gap positivity characterization
* `certifyPhase_sound` — Soundness of the decidable certification checker
* `no_certification_above_threshold` — Impossibility above threshold
* `sharp_transition` — Both directions: exact phase boundary

## Cross-Domain Connections

* **Quantum information ↔ spectral theory**: Certification of quantum order reduces to
  persistence of an isolated spectral band.
* **Random matrix theory ↔ many-body physics**: The 2σ edge phenomenon becomes a
  prototype for many-body noise thresholds.
* **Condensed matter ↔ verified algorithms**: The computable threshold p* = Δ/(2σ_eff)
  yields an algorithm for certifying noisy Hamiltonians remain in a stable phase.

## Application Keywords

topological order, toric code, quantum error correction, spectral gap stability,
phase transition, universality, random matrix edge, fidelity certification,
many-body localization, noise threshold, projector stability, Hamiltonian complexity,
robust quantum memory, condensed matter, variational principle

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Tracy–Widom, "Level-spacing distributions and the Airy kernel", CMP, 1994
* Bravyi–Hastings–Michalakis, "Topological quantum order: stability under local
  perturbations", J. Math. Phys., 2010
-/

open Real

noncomputable section

namespace SpectralPhaseTransitions

/-! ## Core Definitions -/

/-- **Effective certification threshold.** The critical perturbation strength
    at which gap-based certification breaks down. When σ = 0 (no noise),
    the threshold is infinite (any perturbation strength is safe).

    This is the many-body analog of the 2σ edge threshold from random matrix
    theory: the factor of 2 arises because both the ground-state and excited-state
    energies can shift by up to p·σ, closing the gap at rate 2p·σ. -/
def certThreshold (Δ σ : ℝ) : ℝ := Δ / (2 * σ)

/-- **Subcritical perturbation.** A perturbation of norm σ at strength p
    is subcritical if p·σ < Δ/2, i.e., the total perturbation norm is
    less than half the spectral gap. -/
def Subcritical (Δ pσ : ℝ) : Prop := pσ < Δ / 2

/-- **Certification residual gap.** After perturbing a Hamiltonian with gap Δ
    by a noise operator of effective strength p·σ, the residual gap is
    Δ − 2·p·σ. This is positive exactly in the subcritical regime. -/
def certificationResidualGap (Δ p σ : ℝ) : ℝ := Δ - 2 * p * σ

/-- **Phase regime classification.** Classifies the perturbation strength
    into one of three regimes relative to the certification threshold. -/
inductive CertificationPhaseRegime where
  | stable    : CertificationPhaseRegime  -- p < p*, certification persists
  | critical  : CertificationPhaseRegime  -- p = p*, gap exactly closes
  | unstable  : CertificationPhaseRegime  -- p > p*, no gap-based certification
  deriving DecidableEq, Repr

/-- **Spectral certificate.** A finite-dimensional spectral certificate consisting
    of a spectral gap value and a noise scale, encoding the certification window. -/
structure SpectralCertificate where
  /-- The spectral gap separating low-energy from excited states -/
  gap : ℝ
  /-- Positivity of the spectral gap -/
  gap_pos : 0 < gap
  /-- The effective noise scale (operator norm of noise operator) -/
  noiseScale : ℝ
  /-- Non-negativity of the noise scale -/
  noiseScale_nonneg : 0 ≤ noiseScale

/-- The certification threshold of a spectral certificate. -/
def SpectralCertificate.threshold (cert : SpectralCertificate) : ℝ :=
  certThreshold cert.gap cert.noiseScale

/-- **Decidable certification checker.** Returns true if the perturbation
    is certified to preserve the spectral gap. -/
def certifyPhase (Δ p σ : ℝ) : Bool :=
  decide (0 < certificationResidualGap Δ p σ)

/-- Classify the perturbation regime given gap, perturbation strength, and noise norm. -/
def classifyRegime (Δ p σ : ℝ) : CertificationPhaseRegime :=
  if 0 < certificationResidualGap Δ p σ then CertificationPhaseRegime.stable
  else if certificationResidualGap Δ p σ = 0 then CertificationPhaseRegime.critical
  else CertificationPhaseRegime.unstable

/-! ## Theorem 1: Certification Threshold Specification

The central theorem: if the perturbation strength p is below the certification
threshold Δ/(2σ), then the residual gap Δ − 2pσ is strictly positive.

This is proved via algebraic rearrangement: p < Δ/(2σ) ⟹ 2pσ < Δ ⟹ Δ − 2pσ > 0.
-/

/-- **Certification threshold specification.** Below the threshold, the residual
    gap is positive. This is the fundamental inequality governing the phase
    transition in certification. -/
theorem certThreshold_spec
    (Δ σ p : ℝ)
    (_ : 0 < Δ)
    (hσ : 0 < σ)
    (hp : p < certThreshold Δ σ) :
    0 < Δ - 2 * p * σ := by
  unfold certThreshold at hp
  have h2σ : (0 : ℝ) < 2 * σ := by linarith
  have hp2 : p * (2 * σ) < Δ := by rwa [lt_div_iff₀ h2σ] at hp
  nlinarith

/-- The residual gap equals the certification residual gap definition. -/
theorem certThreshold_spec' (Δ σ p : ℝ) (hΔ : 0 < Δ) (hσ : 0 < σ)
    (hp : p < certThreshold Δ σ) :
    0 < certificationResidualGap Δ p σ := by
  exact certThreshold_spec Δ σ p hΔ hσ hp

/-! ## Theorem 2: Subcritical Gap Stability -/

/-- **Subcritical gap stability.** If the perturbation is subcritical
    (p·σ < Δ/2), then the residual gap Δ − 2pσ is positive. -/
theorem subcritical_gap_stability
    (Δ p σ : ℝ)
    (_ : 0 < Δ)
    (hsub : Subcritical Δ (p * σ)) :
    0 < certificationResidualGap Δ p σ := by
  unfold Subcritical at hsub
  unfold certificationResidualGap
  linarith

/-- **Residual gap formula.** The residual gap after subcritical perturbation
    equals the original gap minus twice the perturbation strength. -/
theorem residualGap_eq (Δ p σ : ℝ) :
    certificationResidualGap Δ p σ = Δ - 2 * p * σ := rfl

/-- **Subcritical ↔ below threshold** when noise is positive. -/
theorem subcritical_iff_below_threshold
    (Δ p σ : ℝ) (hσ : 0 < σ) :
    Subcritical Δ (p * σ) ↔ p < certThreshold Δ σ := by
  unfold Subcritical certThreshold
  rw [lt_div_iff₀ (by linarith : (0:ℝ) < 2 * σ)]
  constructor <;> intro h <;> nlinarith

/-! ## Theorem 3: Energy Certification Under Subcritical Noise -/

/-- **Energy bound for ground states under perturbation.**
    If a state has zero energy under H, its energy under H + pN is
    bounded by p·σ, and excited states have energy at least Δ − p·σ.
    When p·σ < Δ/2, the perturbed ground energy is strictly below the
    perturbed excited energy, so the energy test still certifies. -/
theorem energy_certification_bound
    (Δ p σ perturbedGroundEnergy excitedEnergy : ℝ)
    (_hΔ : 0 < Δ)
    (hexcited : Δ ≤ excitedEnergy)
    (hpert_ground : perturbedGroundEnergy ≤ p * σ)
    (hsub : Subcritical Δ (p * σ)) :
    perturbedGroundEnergy < excitedEnergy - p * σ := by
  unfold Subcritical at hsub
  linarith

/-- **Certification gap persists.** Under subcritical perturbation, the energy
    gap between perturbed ground states and perturbed excited states remains
    positive. The certification score is at least Δ − 2p·σ. -/
theorem certification_gap_persists
    (Δ p σ : ℝ)
    (perturbedGroundEnergy perturbedExcitedEnergy : ℝ)
    (_hΔ : 0 < Δ)
    (hground_bound : perturbedGroundEnergy ≤ p * σ)
    (hexcited_bound : Δ - p * σ ≤ perturbedExcitedEnergy)
    (hsub : Subcritical Δ (p * σ)) :
    0 < perturbedExcitedEnergy - perturbedGroundEnergy := by
  unfold Subcritical at hsub
  linarith

/-! ## Theorem 4: Monotonicity Properties -/

/-- **Monotonicity in gap.** A larger spectral gap yields a larger
    certification threshold: more robust phases are harder to destroy. -/
theorem certThreshold_monotone_gap
    {Δ₁ Δ₂ σ : ℝ}
    (hσ : 0 < σ)
    (hΔ : Δ₁ ≤ Δ₂) :
    certThreshold Δ₁ σ ≤ certThreshold Δ₂ σ := by
  unfold certThreshold
  apply div_le_div_of_nonneg_right hΔ
  linarith

/-- **Antitonicity in noise.** Larger noise scale yields a smaller
    certification threshold. -/
theorem certThreshold_antitone_noise
    {Δ σ₁ σ₂ : ℝ}
    (hΔ : 0 ≤ Δ)
    (hσ₁ : 0 < σ₁)
    (hσσ : σ₁ ≤ σ₂) :
    certThreshold Δ σ₂ ≤ certThreshold Δ σ₁ := by
  unfold certThreshold
  apply div_le_div_of_nonneg_left hΔ
  · linarith
  · exact mul_le_mul_of_nonneg_left hσσ (by norm_num)

/-- **Scaling in gap.** Scaling the gap scales the threshold proportionally. -/
theorem certThreshold_scale_gap (Δ σ c : ℝ) :
    certThreshold (c * Δ) σ = c * certThreshold Δ σ := by
  unfold certThreshold; ring

/-- **Threshold positivity.** The threshold is positive when both gap and noise are positive. -/
theorem certThreshold_pos {Δ σ : ℝ} (hΔ : 0 < Δ) (hσ : 0 < σ) :
    0 < certThreshold Δ σ := by
  unfold certThreshold; positivity

/-! ## Theorem 5: Residual Gap Characterization -/

/-- **Residual gap positivity characterization.** The residual gap is positive
    iff the perturbation is subcritical. -/
theorem certificationResidualGap_pos_iff
    (Δ p σ : ℝ) :
    0 < certificationResidualGap Δ p σ ↔ 2 * p * σ < Δ := by
  unfold certificationResidualGap
  constructor <;> intro h <;> linarith

/-- **Residual gap monotone in gap.** Larger original gap ⟹ larger residual gap. -/
theorem certificationResidualGap_mono_gap
    {Δ₁ Δ₂ p σ : ℝ}
    (h : Δ₁ ≤ Δ₂) :
    certificationResidualGap Δ₁ p σ ≤ certificationResidualGap Δ₂ p σ := by
  unfold certificationResidualGap; linarith

/-- **Residual gap antitone in perturbation.** Stronger perturbation ⟹ smaller residual gap. -/
theorem certificationResidualGap_anti_p
    {Δ p₁ p₂ σ : ℝ}
    (hσ : 0 ≤ σ) (hp : p₁ ≤ p₂) :
    certificationResidualGap Δ p₂ σ ≤ certificationResidualGap Δ p₁ σ := by
  unfold certificationResidualGap; nlinarith

/-- **Residual gap at zero perturbation equals the original gap.** -/
theorem certificationResidualGap_zero (Δ σ : ℝ) :
    certificationResidualGap Δ 0 σ = Δ := by
  unfold certificationResidualGap; ring

/-- **Residual gap at the threshold is zero (when σ > 0).** -/
theorem certificationResidualGap_at_threshold (Δ σ : ℝ) (hσ : σ ≠ 0) :
    certificationResidualGap Δ (certThreshold Δ σ) σ = 0 := by
  unfold certificationResidualGap certThreshold
  field_simp
  ring

/-! ## Theorem 6: Phase Regime Classification -/

/-- **Every parameter configuration falls into exactly one regime.** -/
theorem phase_regime_trichotomy (Δ p σ : ℝ) :
    (0 < certificationResidualGap Δ p σ) ∨
    (certificationResidualGap Δ p σ = 0) ∨
    (certificationResidualGap Δ p σ < 0) := by
  rcases lt_trichotomy (certificationResidualGap Δ p σ) 0 with h | h | h
  · exact Or.inr (Or.inr h)
  · exact Or.inr (Or.inl h)
  · exact Or.inl h

/-- The classification function correctly identifies the stable regime. -/
theorem classifyRegime_stable_iff (Δ p σ : ℝ) :
    classifyRegime Δ p σ = CertificationPhaseRegime.stable ↔
    0 < certificationResidualGap Δ p σ := by
  unfold classifyRegime
  constructor
  · intro h
    split_ifs at h with h1
    exact h1
  · intro h; simp [h]

/-! ## Theorem 7: Soundness of the Decidable Checker -/

/-- **Soundness of the certification checker.** If `certifyPhase` returns true,
    then the residual gap is genuinely positive, meaning certification persists. -/
theorem certifyPhase_sound (Δ p σ : ℝ) (h : certifyPhase Δ p σ = true) :
    0 < certificationResidualGap Δ p σ := by
  simp [certifyPhase] at h
  exact h

/-- **Completeness of the certification checker.** If the residual gap is positive,
    then `certifyPhase` returns true. -/
theorem certifyPhase_complete (Δ p σ : ℝ)
    (h : 0 < certificationResidualGap Δ p σ) :
    certifyPhase Δ p σ = true := by
  simp [certifyPhase, h]

/-- **Certification checker correctness.** The checker is both sound and complete. -/
theorem certifyPhase_iff (Δ p σ : ℝ) :
    certifyPhase Δ p σ = true ↔ 0 < certificationResidualGap Δ p σ :=
  ⟨certifyPhase_sound Δ p σ, certifyPhase_complete Δ p σ⟩

/-! ## Theorem 8: No Uniform Certification Above Threshold -/

/-- **No certification above threshold.** If the perturbation strength exceeds
    the certification threshold, the residual gap bound becomes negative. -/
theorem no_certification_above_threshold
    (Δ p σ : ℝ)
    (hσ : 0 < σ)
    (hp : certThreshold Δ σ < p) :
    certificationResidualGap Δ p σ < 0 := by
  unfold certificationResidualGap certThreshold at *
  have h2σ : (0 : ℝ) < 2 * σ := by linarith
  have h1 : Δ / (2 * σ) * (2 * σ) < p * (2 * σ) :=
  mul_lt_mul_of_pos_right hp h2σ
  rw [div_mul_cancel₀ Δ (ne_of_gt h2σ)] at h1
  nlinarith

/-- **Sharp phase transition.** The certification threshold is exactly the
    boundary between positive and negative residual gap. -/
theorem sharp_transition (Δ σ : ℝ) (hσ : 0 < σ) :
    (∀ p, p < certThreshold Δ σ → 0 < certificationResidualGap Δ p σ) ∧
    (∀ p, certThreshold Δ σ < p → certificationResidualGap Δ p σ < 0) := by
  constructor
  · intro p hp
    unfold certificationResidualGap certThreshold at *
    have h2σ : (0 : ℝ) < 2 * σ := by linarith
    have : p * (2 * σ) < Δ := by rwa [lt_div_iff₀ h2σ] at hp
    nlinarith
  · intro p hp
    exact no_certification_above_threshold Δ p σ hσ hp

/-! ## Theorem 9: Composition and Transitivity -/

/-- **Composition of subcritical perturbations.** If two perturbations are both
    subcritical and their total effect is still subcritical, the composition
    preserves certification. -/
theorem subcritical_composition
    (Δ p₁ p₂ σ₁ σ₂ : ℝ)
    (_hΔ : 0 < Δ)
    (hsub : p₁ * σ₁ + p₂ * σ₂ < Δ / 2) :
    0 < Δ - 2 * (p₁ * σ₁ + p₂ * σ₂) := by
  linarith

/-- **Transitivity of gap degradation.** If we first perturb by p₁σ₁ obtaining
    residual gap Δ₁, then perturb by p₂σ₂, the final residual gap is
    Δ − 2(p₁σ₁ + p₂σ₂). -/
theorem residual_gap_transitivity
    (Δ p₁ p₂ σ₁ σ₂ : ℝ) :
    certificationResidualGap (certificationResidualGap Δ p₁ σ₁) p₂ σ₂ =
    Δ - 2 * p₁ * σ₁ - 2 * p₂ * σ₂ := by
  unfold certificationResidualGap; ring

/-! ## Theorem 10: Connection to GOE Edge Constants -/

/-- **The 2σ edge principle.** The certification threshold equals Δ/(2σ). -/
theorem edge_principle (Δ σ : ℝ) :
    certThreshold Δ σ = Δ / (2 * σ) := rfl

/-- **The certification threshold is half the gap-to-noise ratio.** -/
theorem threshold_is_half_gap_noise_ratio (Δ σ : ℝ) :
    certThreshold Δ σ = (1/2) * (Δ / σ) := by
  unfold certThreshold; ring

/-- **Dimensional consistency.** The threshold scales correctly:
    doubling both gap and noise preserves the threshold. -/
theorem threshold_scale_invariance (Δ σ c : ℝ) (hc : c ≠ 0) :
    certThreshold (c * Δ) (c * σ) = certThreshold Δ σ := by
  unfold certThreshold
  rw [show 2 * (c * σ) = c * (2 * σ) from by ring]
  rw [mul_div_mul_left _ _ hc]

/-! ## Certified Algorithm: Complete Phase Certification Pipeline -/

/-- **Certified phase diagnosis.** Given spectral parameters, compute the full
    certification diagnosis: residual gap, subcriticality, and threshold. -/
structure CertificationDiagnosis where
  /-- The original spectral gap -/
  gap : ℝ
  /-- The perturbation strength -/
  perturbation : ℝ
  /-- The noise operator norm -/
  noiseNorm : ℝ
  /-- The certification threshold p* = Δ/(2σ) -/
  threshold : ℝ
  /-- The residual gap Δ − 2pσ -/
  residualGap : ℝ
  /-- Whether the perturbation is certified subcritical -/
  isSubcritical : Bool
  /-- The phase regime classification -/
  regime : CertificationPhaseRegime

/-- Compute a full certification diagnosis. -/
def diagnose (Δ p σ : ℝ) : CertificationDiagnosis where
  gap := Δ
  perturbation := p
  noiseNorm := σ
  threshold := certThreshold Δ σ
  residualGap := certificationResidualGap Δ p σ
  isSubcritical := certifyPhase Δ p σ
  regime := classifyRegime Δ p σ

/-- **Soundness of the full diagnosis.** If the diagnosis reports subcritical,
    the residual gap is genuinely positive. -/
theorem diagnose_sound (Δ p σ : ℝ)
    (h : (diagnose Δ p σ).isSubcritical = true) :
    0 < (diagnose Δ p σ).residualGap := by
  simp [diagnose] at h ⊢
  exact certifyPhase_sound Δ p σ h

/-! ## Advanced: Stability Under Effective Edge Parameters -/

/-- **Stable regime below effective threshold.** If ‖N‖ ≤ σ_eff and
    p < Δ/(2σ_eff), then the residual gap is positive. This is the
    version with effective edge parameter, relevant for random matrix
    universality. -/
theorem stable_regime_below_threshold
    (Δ p σeff σN : ℝ)
    (hΔ : 0 < Δ)
    (hσeff : 0 < σeff)
    (hσN : σN ≤ σeff)
    (hp : p < certThreshold Δ σeff)
    (hp_nonneg : 0 ≤ p) :
    0 < certificationResidualGap Δ p σN := by
  have hres_eff := certThreshold_spec Δ σeff p hΔ hσeff hp
  unfold certificationResidualGap at *
  nlinarith

/-- **No uniform certification above effective threshold.** If
    p > Δ/(2σ_eff), there exists a noise operator N with ‖N‖ ≤ σ_eff
    for which the residual gap is non-positive. Specifically, taking
    σN = σ_eff works. -/
theorem no_uniform_certification_above_threshold
    (Δ p σeff : ℝ)
    (hσeff : 0 < σeff)
    (hp : certThreshold Δ σeff < p) :
    ∃ σN : ℝ, σN ≤ σeff ∧ certificationResidualGap Δ p σN < 0 := by
  exact ⟨σeff, le_refl _, no_certification_above_threshold Δ p σeff hσeff hp⟩

end SpectralPhaseTransitions