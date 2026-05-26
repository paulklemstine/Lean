/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.NoiseStabilityDefs

/-!
# Noise-Stability Universality: Main Theorems

This file proves the main theorems of the noise-stability universality
framework. The central results establish:

1. **Structural properties of universality comparability** — reflexivity,
   symmetry, and transitivity.

2. **Gap transfer pipeline** — the composition of Lorentzian-to-residual and
   residual-to-spectral transfers yields certified spectral gap lower bounds.

3. **Obstruction theorem** — residual gap collapse prevents uniform
   inverse-polynomial spectral gap bounds.

4. **Uniform matroid centering** — the uniform perturbation model is centered.

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Anari–Liu–Oveis Gharan–Vinzant, "Log-Concave Polynomials", STOC 2019
-/

open Finset BigOperators

noncomputable section

namespace NoiseStability

/-! ## Structural Properties of Universality Comparability -/

/-- **Reflexivity**: Every positive real is universality comparable to itself
    with constants C₁ = C₂ = 1. -/
theorem universalityComparable_refl (R : ℝ) :
    UniversalityComparable R R := by
  exact ⟨1, 1, one_pos, one_pos, by linarith, by linarith⟩

/-- **Symmetry up to inversion**: If Rgeom and Ralg are comparable,
    then so are Ralg and Rgeom (with swapped constants). -/
theorem universalityComparable_symm {Rgeom Ralg : ℝ}
    (_hR : 0 < Rgeom) (_hA : 0 < Ralg)
    (h : UniversalityComparable Rgeom Ralg) :
    UniversalityComparable Ralg Rgeom := by
  obtain ⟨C1, C2, hC1, hC2, hlo, hhi⟩ := h
  refine ⟨C2⁻¹, C1⁻¹, inv_pos.mpr hC2, inv_pos.mpr hC1, ?_, ?_⟩
  · rw [inv_mul_le_iff₀ hC2]
    linarith
  · rw [le_inv_mul_iff₀ hC1]
    linarith

/-- **Transitivity**: Comparability composes. If R₁ ~ R₂ and R₂ ~ R₃,
    then R₁ ~ R₃ with composed constants. This is the key structural
    property enabling the pipeline: geometric → residual → spectral. -/
theorem universalityComparable_trans {R1 R2 R3 : ℝ}
    (h12 : UniversalityComparable R1 R2)
    (h23 : UniversalityComparable R2 R3) :
    UniversalityComparable R1 R3 := by
  obtain ⟨C1, C2, hC1, hC2, hlo1, hhi1⟩ := h12
  obtain ⟨C3, C4, hC3, hC4, hlo2, hhi2⟩ := h23
  exact ⟨C3 * C1, C4 * C2, mul_pos hC3 hC1, mul_pos hC4 hC2,
    by nlinarith, by nlinarith⟩

/-- **Scaling**: If R₁ and R₂ are comparable, then so are λ*R₁ and λ*R₂
    for any positive λ. Universality comparability is scale-invariant. -/
theorem universalityComparable_scale {R1 R2 : ℝ} (c : ℝ) (hc : 0 < c)
    (h : UniversalityComparable R1 R2) :
    UniversalityComparable (c * R1) (c * R2) := by
  obtain ⟨C1, C2, hC1, hC2, hlo, hhi⟩ := h
  refine ⟨C1, C2, hC1, hC2, ?_, ?_⟩
  · nlinarith
  · nlinarith

/-- Weak lower comparability is implied by full comparability. -/
theorem weakLowerComparable_of_comparable {Rgeom Ralg : ℝ}
    (h : UniversalityComparable Rgeom Ralg) :
    WeakLowerComparable Rgeom Ralg := by
  obtain ⟨C1, _, hC1, _, hlo, _⟩ := h
  exact ⟨C1, hC1, hlo⟩

/-- Weak upper comparability is implied by full comparability. -/
theorem weakUpperComparable_of_comparable {Rgeom Ralg : ℝ}
    (h : UniversalityComparable Rgeom Ralg) :
    WeakUpperComparable Rgeom Ralg := by
  obtain ⟨_, C2, _, hC2, _, hhi⟩ := h
  exact ⟨C2, hC2, hhi⟩

/-- Full comparability is equivalent to having both weak bounds. -/
theorem universalityComparable_iff_both_weak {Rgeom Ralg : ℝ} :
    UniversalityComparable Rgeom Ralg ↔
      WeakLowerComparable Rgeom Ralg ∧ WeakUpperComparable Rgeom Ralg := by
  constructor
  · intro h
    exact ⟨weakLowerComparable_of_comparable h, weakUpperComparable_of_comparable h⟩
  · rintro ⟨⟨C1, hC1, hlo⟩, ⟨C2, hC2, hhi⟩⟩
    exact ⟨C1, C2, hC1, hC2, hlo, hhi⟩

/-! ## Uniform Perturbation Model Properties -/

/-- The uniform perturbation model is centered: at ε = 0, it recovers the base. -/
theorem uniformPertModel_centered (n k : ℕ) :
    (uniformPertModel n k).IsCentered := by
  ext S
  simp [uniformPertModel, uniformWeight, uniformPerturbedWeight]

/-- For the uniform perturbation model, the perturbation preserves positivity
    when ε > -1. -/
theorem uniformPerturbed_pos {n k : ℕ} {ε : ℝ} (hε : -1 < ε)
    {S : Finset (Fin n)} (hS : S.card = k) :
    0 < (uniformPertModel n k).perturbed ε S := by
  simp [uniformPertModel, uniformPerturbedWeight, hS]
  linarith

/-! ## Gap Transfer Pipeline -/

/-- **Theorem A (Abstract): Lorentzian-to-spectral gap transfer.**

Given a Lorentzian-to-residual transfer and a residual-to-spectral transfer,
we obtain a certified spectral gap lower bound from the Lorentzian property. -/
theorem spectralGap_pos_of_lorentzian
    {ι β : Type*}
    (LR : LorentzianResidualTransfer ι)
    (GT : GapTransfer ι β)
    (hcompat : LR.rgap = GT.rgap)
    (w : Finset ι → ℝ)
    (hLor : LR.isLorentzian w) :
    0 < GT.sgap.gap w := by
  have hrgap := LR.lor_to_residual w hLor
  rw [hcompat] at hrgap
  exact GT.transfer w hrgap

/-- **Quantitative transfer**: If the residual gap is at least δ, the spectral
    gap is at least δ/(δ+1). -/
theorem spectralGap_quant_of_residualGap
    {ι β : Type*}
    (GT : GapTransfer ι β)
    (w : Finset ι → ℝ) (δ : ℝ) (hδ : 0 < δ)
    (hrgap : GT.rgap.gap w ≥ δ) :
    GT.sgap.gap w ≥ δ / (δ + 1) := by
  exact GT.quant_transfer w δ hδ hrgap

/-- **Transfer pipeline composition**: Lorentzian → residual gap → spectral gap. -/
theorem spectralGap_of_lorentzian_pipeline
    {ι β : Type*}
    (LR : LorentzianResidualTransfer ι)
    (GT : GapTransfer ι β)
    (hcompat : LR.rgap = GT.rgap)
    (w : Finset ι → ℝ)
    (_hLor : LR.isLorentzian w)
    (δ : ℝ) (hδ : 0 < δ)
    (hbound : LR.rgap.gap w ≥ δ) :
    GT.sgap.gap w ≥ δ / (δ + 1) := by
  rw [hcompat] at hbound
  exact GT.quant_transfer w δ hδ hbound

/-! ## Obstruction Theorem -/

/-- **Theorem B: Residual gap collapse obstructs uniform polynomial spectral gap.**

If the residual gap can be made arbitrarily small by perturbations, then
no uniform inverse-polynomial spectral gap bound can hold across all
perturbations, provided the spectral gap is bounded above by the residual gap. -/
theorem no_uniform_poly_gap_of_residualGap_collapse
    {ι β : Type*} [Fintype ι]
    (GT : GapTransfer ι β)
    (M : PerturbationModel ι)
    (hn : 0 < Fintype.card ι)
    (hCollapse : ∀ K : ℕ, 0 < K →
      ∃ ε : ℝ, GT.rgap.gap (M.perturbed ε) < 1 / (K : ℝ))
    (hTransferSharp : ∀ w : Finset ι → ℝ,
      GT.sgap.gap w ≤ GT.rgap.gap w) :
    ¬ ∃ k : ℕ, 0 < k ∧ ∀ ε : ℝ,
        GT.sgap.gap (M.perturbed ε) ≥ 1 / (Fintype.card ι : ℝ) ^ k := by
  rintro ⟨k, hk, hunif⟩
  set n := Fintype.card ι
  obtain ⟨ε, hε⟩ := hCollapse (n ^ k + 1) (by positivity)
  have h1 := hunif ε
  have h2 := hTransferSharp (M.perturbed ε)
  have h3 : GT.sgap.gap (M.perturbed ε) < 1 / ((n : ℝ) ^ k + 1) := by
    calc GT.sgap.gap (M.perturbed ε) ≤ GT.rgap.gap (M.perturbed ε) := h2
    _ < 1 / ((↑(n ^ k + 1) : ℝ)) := hε
    _ = 1 / ((n : ℝ) ^ k + 1) := by push_cast; ring_nf
  have h4 : (1 : ℝ) / (n : ℝ) ^ k ≤ GT.sgap.gap (M.perturbed ε) := h1
  have h5 : (1 : ℝ) / ((n : ℝ) ^ k + 1) ≤ 1 / (n : ℝ) ^ k := by
    have hpow : (0 : ℝ) < (n : ℝ) ^ k := by positivity
    exact div_le_div_of_nonneg_left (by linarith : (0 : ℝ) ≤ 1) hpow (by linarith)
  linarith

/-! ## Radius Transfer Composition -/

/-- **Theorem C (Abstract): Radius domination through transfer.**

If Lorentzian stability at radius ρ implies residual gap ≥ δ,
and residual gap ≥ δ implies spectral gap ≥ f(δ), then Lorentzian
stability at radius ρ implies spectral gap ≥ f(δ(ρ)).

This is the abstract cross-domain comparison theorem. -/
theorem radius_transfer_composition
    {ι β : Type*}
    (LR : LorentzianResidualTransfer ι)
    (GT : GapTransfer ι β)
    (hcompat : LR.rgap = GT.rgap)
    (M : PerturbationModel ι)
    (ρ δ : ℝ) (hδ : 0 < δ)
    (hMargin : ∀ ε : ℝ, |ε| ≤ ρ → LR.rgap.gap (M.perturbed ε) ≥ δ) :
    ∀ ε : ℝ, |ε| ≤ ρ → GT.sgap.gap (M.perturbed ε) ≥ δ / (δ + 1) := by
  intro ε hε
  have hrgap := hMargin ε hε
  rw [hcompat] at hrgap
  exact GT.quant_transfer (M.perturbed ε) δ hδ hrgap

/-! ## Lorentzian Stability Radius Properties -/

/-- If a perturbation model is centered, the Lorentzian stability radius
    is nonneg whenever the base weight is Lorentzian. -/
theorem lorentzianStabilityRadius_nonneg {ι : Type*}
    (isLorentzian : (Finset ι → ℝ) → Prop)
    (M : PerturbationModel ι) (hC : M.IsCentered)
    (hBase : isLorentzian M.base)
    (hBdd : BddAbove {r : ℝ | LorentzianStableUnder isLorentzian M r})
    (_hNe : {r : ℝ | LorentzianStableUnder isLorentzian M r}.Nonempty) :
    0 ≤ lorentzianStabilityRadius isLorentzian M := by
  apply le_csSup hBdd
  refine ⟨le_refl 0, ?_⟩
  intro ε hε
  have hε0 : ε = 0 := by
    have := abs_nonneg ε
    have h2 := hε
    rw [abs_le] at h2
    linarith
  subst hε0
  change isLorentzian (M.perturbed 0)
  rw [show M.perturbed 0 = M.base from hC]
  exact hBase

/-! ## Explicit Constants for Uniform Matroid -/

/-- For the uniform perturbation model, the base weight of a k-subset is 1. -/
theorem uniformWeight_of_card_eq {n k : ℕ} {S : Finset (Fin n)} (hS : S.card = k) :
    uniformWeight n k S = 1 := by
  simp [uniformWeight, hS]

/-- For the uniform perturbation model, the weight of a non-k-subset is 0. -/
theorem uniformWeight_of_card_ne {n k : ℕ} {S : Finset (Fin n)} (hS : S.card ≠ k) :
    uniformWeight n k S = 0 := by
  simp [uniformWeight, hS]

/-- The perturbation magnitude for the uniform model is exactly ε on k-subsets. -/
theorem uniformPerturb_diff {n k : ℕ} {ε : ℝ} {S : Finset (Fin n)} (hS : S.card = k) :
    (uniformPertModel n k).perturbed ε S - (uniformPertModel n k).base S = ε := by
  simp [uniformPertModel, uniformPerturbedWeight, uniformWeight, hS]

/-! ## Comparability of Composed Radii -/

/-- If two radius comparabilities hold in sequence (R₁ ~ R₂ and R₂ ~ R₃),
    then the composed comparability R₁ ~ R₃ has constants bounded by
    the products of the individual constants.

    This is the **pipeline composition principle**: each stage of
    geometry → residual → spectral → mixing contributes a multiplicative
    factor to the universal constants. -/
theorem comparability_pipeline_constants
    {R1 R2 R3 : ℝ}
    {C1 C2 C3 C4 : ℝ}
    (_hC1 : 0 < C1) (_hC2 : 0 < C2)
    (hC3 : 0 < C3) (hC4 : 0 < C4)
    (h12_lo : C1 * R1 ≤ R2) (h12_hi : R2 ≤ C2 * R1)
    (h23_lo : C3 * R2 ≤ R3) (h23_hi : R3 ≤ C4 * R2) :
    (C3 * C1) * R1 ≤ R3 ∧ R3 ≤ (C4 * C2) * R1 := by
  constructor
  · calc (C3 * C1) * R1 = C3 * (C1 * R1) := by ring
    _ ≤ C3 * R2 := by nlinarith
    _ ≤ R3 := h23_lo
  · calc R3 ≤ C4 * R2 := h23_hi
    _ ≤ C4 * (C2 * R1) := by nlinarith
    _ = (C4 * C2) * R1 := by ring

end NoiseStability