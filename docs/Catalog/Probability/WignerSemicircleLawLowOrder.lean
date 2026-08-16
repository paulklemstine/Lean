/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The semicircle law at orders two and four for the Rademacher Wigner ensemble

Combining

* `Probability.WignerSemicircleMoments` (moments of the semicircle law are Catalan
  numbers),
* `Probability.WignerTraceBridge` (empirical spectral moments = normalised traces),
* `Probability.WignerRademacherEnsemble` (exact trace moments of the ensemble),

this file proves the moment-method form of the Wigner semicircle law at the first
two nontrivial orders:

* `esd_secondMoment` : the second moment of the empirical spectral distribution of
  `W/√N` equals `1 - 1/N` for **every** realisation (perfect self-averaging), and
  converges to `∫ x² dsc(x) = C₁ = 1`;
* `expect_normalizedMoment_four` : the expected fourth moment equals
  `(N-1)(2N-3)/N²`, converging to `∫ x⁴ dsc(x) = C₂ = 2`;
* `eventually_secondMoment_close` : a (deterministic, hence in-probability)
  concentration statement for the second moment.
-/
import Probability.WignerRademacherEnsemble

open Matrix BigOperators Filter Topology

namespace RademacherWigner

variable {N : ℕ}

theorem card_fin_config (N : ℕ) : (Fintype.card (Fin N) : ℝ) = (N : ℝ) := by
  simp

theorem sqrt_inv_sq (N : ℕ) : (Real.sqrt (N : ℝ))⁻¹ ^ 2 = ((N : ℝ))⁻¹ := by
  rw [← Real.sqrt_inv, Real.sq_sqrt (by positivity)]

/-- The normalised second spectral moment is `1 - 1/N` for *every* realisation of
the ensemble: the second moment is perfectly self-averaging. -/
theorem normalizedMoment_two (g : Config N) (hN : 0 < N) :
    WignerBridge.normalizedMoment (W g) 2 = 1 - 1 / (N : ℝ) := by
  have hNR : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hN.ne'
  rw [WignerBridge.normalizedMoment_eq, trace_W_sq, card_fin_config, sqrt_inv_sq]
  field_simp

/-- Spelled out at the level of eigenvalues: the empirical spectral distribution of
`W/√N` has second moment exactly `1 - 1/N`. -/
theorem esd_secondMoment (g : Config N) (hN : 0 < N) :
    (1 / (N : ℝ)) *
        ∑ i, ((W_isHermitian g).eigenvalues i / Real.sqrt (N : ℝ)) ^ 2 = 1 - 1 / (N : ℝ) := by
  have h := WignerBridge.normalizedMoment_eq_sum_eigenvalues (W_isHermitian g) 2
  rw [normalizedMoment_two g hN, Fintype.card_fin] at h
  rw [← h]

theorem expect_const_mul (c : ℝ) (f : Config N → ℝ) :
    expect (fun g => c * f g) = c * expect f := by
  unfold expect
  rw [← Finset.mul_sum]
  ring

/-- **Expected normalised fourth spectral moment** of the Rademacher Wigner
ensemble: exactly `(N-1)(2N-3)/N²`. -/
theorem expect_normalizedMoment_four (N : ℕ) (hN : 0 < N) :
    expect (fun g : Config N => WignerBridge.normalizedMoment (W g) 4) =
      ((N : ℝ) - 1) * (2 * (N : ℝ) - 3) / (N : ℝ) ^ 2 := by
  have hNR : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hN.ne'
  have hpow : (Real.sqrt (N : ℝ))⁻¹ ^ 4 = ((N : ℝ))⁻¹ ^ 2 := by
    rw [show (4 : ℕ) = 2 * 2 from rfl, pow_mul, sqrt_inv_sq]
  have hrw : ∀ g : Config N, WignerBridge.normalizedMoment (W g) 4 =
      (1 / (N : ℝ) * ((N : ℝ))⁻¹ ^ 2) * ((W g) ^ 4).trace := by
    intro g
    rw [WignerBridge.normalizedMoment_eq, card_fin_config, hpow]
  simp only [hrw]
  rw [expect_const_mul, expect_trace_W_four]
  field_simp
  ring

/-! ### Convergence to the semicircle moments -/

theorem tendsto_one_sub_inv :
    Tendsto (fun N : ℕ => 1 - 1 / (N : ℝ)) atTop (𝓝 1) := by
  have h : Tendsto (fun N : ℕ => (1 : ℝ) / (N : ℝ)) atTop (𝓝 0) :=
    tendsto_one_div_atTop_nhds_zero_nat
  simpa using (tendsto_const_nhds (x := (1:ℝ)) (f := atTop (α := ℕ))).sub h

/-- **Semicircle law, order two.**  For any sequence of realisations of the
ensemble, the second moment of the empirical spectral distribution of `W/√N`
converges to the second moment `C₁ = 1` of the semicircle law. -/
theorem tendsto_secondMoment (gseq : ∀ N : ℕ, Config N) :
    Tendsto (fun N : ℕ => WignerBridge.normalizedMoment (W (gseq N)) 2) atTop
      (𝓝 (WignerSemicircle.semicircleMoment 2)) := by
  rw [WignerSemicircle.semicircleMoment_two]
  refine tendsto_one_sub_inv.congr' ?_
  filter_upwards [eventually_gt_atTop 0] with N hN
  exact (normalizedMoment_two (gseq N) hN).symm

/-- **Semicircle law, order four (in expectation).**  The expected fourth moment of
the empirical spectral distribution of `W/√N` converges to the fourth moment
`C₂ = 2` of the semicircle law. -/
theorem tendsto_expected_fourthMoment :
    Tendsto (fun N : ℕ => expect (fun g : Config N => WignerBridge.normalizedMoment (W g) 4))
      atTop (𝓝 (WignerSemicircle.semicircleMoment 4)) := by
  rw [WignerSemicircle.semicircleMoment_four]
  have hlim : Tendsto (fun N : ℕ => 2 - 5 * (1 / (N : ℝ)) + 3 * (1 / (N : ℝ)) ^ 2) atTop
      (𝓝 2) := by
    have h : Tendsto (fun N : ℕ => (1 : ℝ) / (N : ℝ)) atTop (𝓝 0) :=
      tendsto_one_div_atTop_nhds_zero_nat
    have h2 : Tendsto (fun N : ℕ => (2 : ℝ) - 5 * (1 / (N : ℝ)) + 3 * (1 / (N : ℝ)) ^ 2) atTop
        (𝓝 (2 - 5 * 0 + 3 * 0 ^ 2)) :=
      ((tendsto_const_nhds.sub (tendsto_const_nhds.mul h)).add
        (tendsto_const_nhds.mul (h.pow 2)))
    simpa using h2
  refine hlim.congr' ?_
  filter_upwards [eventually_gt_atTop 0] with N hN
  have hNR : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hN.ne'
  rw [expect_normalizedMoment_four N hN]
  field_simp
  ring

/-- **Concentration at order two.**  For every `ε > 0`, eventually in `N` *all*
realisations of the ensemble have second spectral moment within `ε` of the
semicircle value; in particular the second moment converges in probability. -/
theorem eventually_secondMoment_close (eps : ℝ) (heps : 0 < eps) :
    ∀ᶠ N : ℕ in atTop, ∀ g : Config N,
      |WignerBridge.normalizedMoment (W g) 2 - WignerSemicircle.semicircleMoment 2| < eps := by
  have hev : ∀ᶠ N : ℕ in atTop, (1 : ℝ) / eps < (N : ℝ) :=
    tendsto_natCast_atTop_atTop.eventually_gt_atTop (1 / eps)
  filter_upwards [hev, eventually_gt_atTop 0] with N hbig hN g
  have hNR : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  rw [normalizedMoment_two g hN, WignerSemicircle.semicircleMoment_two]
  have : (1 : ℝ) / (N : ℝ) < eps := by
    rw [div_lt_iff₀ hNR]
    rw [div_lt_iff₀ heps] at hbig
    linarith
  rw [show (1 : ℝ) - 1 / (N : ℝ) - 1 = -(1 / (N : ℝ)) by ring, abs_neg,
    abs_of_nonneg (by positivity)]
  exact this

end RademacherWigner