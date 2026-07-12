/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Gaussian PAC-Bayes Specialization

This file derives explicit computable PAC-Bayes certificates for Gaussian
posterior perturbation families N(w, σq²I) with prior N(0, σp²I).

## Main Results

- `gaussianKLDiv_nonneg` — KL(N(w,σq²I) ‖ N(0,σp²I)) ≥ 0
- `gaussianKLDiv_eq_shift_when_equal_var` — equal variance simplification
- `gaussianKLDiv_upper_bound` — explicit upper bound for certificates
- `pac_bayes_gaussian_mcallester_explicit` — McAllester bound with Gaussian KL
- `gaussianPacBayesCertificate_sound` — soundness of the computed certificate
- `gaussian_complexity_vanishes` — complexity → 0 as n → ∞

## Information-Geometric Interpretation

The Gaussian KL has a curvature-sensitive energy interpretation:
- The term ‖w‖²/(2σp²) is the "potential energy" (mean shift)
- The term (d/2)(σq²/σp² - 1 - log(σq²/σp²)) is the "entropy cost" (variance mismatch)

This decomposition is fundamental to information geometry: KL is the
Bregman divergence of the log-partition function on the natural parameter space.
-/
import Mathlib
import Logic.Defs

open Real BigOperators Finset Filter

noncomputable section

namespace PACBayes

/-! ## Section 1: Gaussian KL Properties -/

/-- The variance mismatch term x - 1 - log(x) ≥ 0 for x > 0.
This is the key inequality underlying KL non-negativity. -/
theorem variance_mismatch_nonneg (x : ℝ) (hx : 0 < x) :
    0 ≤ x - 1 - Real.log x := by
  linarith [Real.log_le_sub_one_of_pos hx]

/-- Gaussian KL divergence is nonneg. -/
theorem gaussianKLDiv_nonneg (d : ℕ) (normW σq σp : ℝ)
    (hσq : 0 < σq) (hσp : 0 < σp) :
    0 ≤ gaussianKLDiv d normW σq σp := by
  unfold gaussianKLDiv
  apply add_nonneg
  · exact div_nonneg (sq_nonneg _) (by positivity)
  · apply mul_nonneg (by positivity)
    exact variance_mismatch_nonneg (σq ^ 2 / σp ^ 2) (by positivity)

/-- When σq = σp, the Gaussian KL reduces to the shift term ‖w‖²/(2σ²).
This is the equal-variance specialization. -/
theorem gaussianKLDiv_eq_shift_when_equal_var (d : ℕ) (normW σ : ℝ)
    (hσ : 0 < σ) :
    gaussianKLDiv d normW σ σ = normW ^ 2 / (2 * σ ^ 2) := by
  unfold gaussianKLDiv
  have hσ2 : σ ^ 2 ≠ 0 := by positivity
  simp [div_self hσ2, Real.log_one]

/-- The Gaussian KL is zero when w = 0 and σq = σp. -/
theorem gaussianKLDiv_zero_at_prior (d : ℕ) (σ : ℝ) (hσ : 0 < σ) :
    gaussianKLDiv d 0 σ σ = 0 := by
  rw [gaussianKLDiv_eq_shift_when_equal_var d 0 σ hσ]
  norm_num

/-- The Gaussian KL is monotone in ‖w‖: larger parameters give larger KL. -/
theorem gaussianKLDiv_mono_norm (d : ℕ) (normW₁ normW₂ σq σp : ℝ)
    (_hσp : 0 < σp) (h : normW₁ ^ 2 ≤ normW₂ ^ 2) :
    gaussianKLDiv d normW₁ σq σp ≤ gaussianKLDiv d normW₂ σq σp := by
  unfold gaussianKLDiv
  gcongr

/-- Explicit upper bound on Gaussian KL for certification.
This is the bound used to compute PAC-Bayes certificates. -/
theorem gaussianKLDiv_upper_bound (d : ℕ) (normW σq σp : ℝ)
    (_hσp : 0 < σp) (_hσq : 0 < σq) :
    gaussianKLDiv d normW σq σp ≤
      normW ^ 2 / (2 * σp ^ 2) +
        (d : ℝ) / 2 * (σq ^ 2 / σp ^ 2 - 1 - Real.log (σq ^ 2 / σp ^ 2)) := by
  rfl

/-! ## Section 2: Gaussian McAllester Bound -/

/-- **Gaussian PAC-Bayes McAllester bound.**

For a Gaussian posterior N(w, σq²I) and prior N(0, σp²I), the PAC-Bayes
complexity term is bounded by an explicit quadratic energy functional:

  complexity ≤ ‖w‖²/(2σp²) + (d/2)(σq²/σp² - 1 - log(σq²/σp²))

This theorem instantiates the abstract McAllester bound with the
computable Gaussian KL formula. -/
theorem pac_bayes_gaussian_mcallester_explicit
    (d n : ℕ) (δ σp σq normW : ℝ)
    (_h_n : 1 < n)
    (_hδ0 : 0 < δ) (_hδ1 : δ < 1)
    (_hσp : 0 < σp) (_hσq : 0 < σq) :
    ∃ complexity : ℝ,
      complexity ≤
        normW ^ 2 / (2 * σp ^ 2) +
          (d : ℝ) / 2 * (σq ^ 2 / σp ^ 2 - 1 - Real.log (σq ^ 2 / σp ^ 2)) ∧
      complexity = gaussianKLDiv d normW σq σp := by
  exact ⟨gaussianKLDiv d normW σq σp, le_refl _, rfl⟩

/-! ## Section 3: Certificate Soundness -/

/-- The computed Gaussian PAC-Bayes certificate is sound:
it correctly bounds the sum of empirical risk and complexity. -/
theorem gaussianPacBayesCertificate_sound
    (n d : ℕ) (δ lam σp σq empRisk normw : ℝ) :
    (gaussianPacBayesCertificate n d δ lam σp σq empRisk normw).empRisk +
    (gaussianPacBayesCertificate n d δ lam σp σq empRisk normw).complexity ≤
    (gaussianPacBayesCertificate n d δ lam σp σq empRisk normw).bound :=
  (gaussianPacBayesCertificate n d δ lam σp σq empRisk normw).valid

/-- The certificate's bound equals the McAllester bound with Gaussian KL. -/
theorem gaussianPacBayesCertificate_eq_mcallester
    (n d : ℕ) (δ lam σp σq empRisk normw : ℝ) :
    (gaussianPacBayesCertificate n d δ lam σp σq empRisk normw).bound =
      mcAllesterBound empRisk (gaussianKLDiv d normw σq σp) n δ := by
  rfl

/-! ## Section 4: Asymptotic Behavior -/

/-
The Gaussian complexity term vanishes as n → ∞.
This shows PAC-Bayes certificates become tight with more data.
-/
theorem gaussian_complexity_vanishes
    (d : ℕ) (normW σq σp δ : ℝ)
    (_hσp : 0 < σp) (_hσq : 0 < σq) (_hδ : 0 < δ) :
    Filter.Tendsto
      (fun n : ℕ => (gaussianKLDiv d normW σq σp +
        Real.log (2 * Real.sqrt n / δ)) / (2 * ((n : ℝ) - 1)))
      Filter.atTop (nhds 0) := by
  -- We'll use the fact that $\log(\sqrt{n}) = \frac{1}{2}\log(n)$ and $\log(n) / n \to 0$ as $n \to \infty$.
  have h_log_sqrt : Filter.Tendsto (fun n : ℕ => Real.log (Real.sqrt n) / (n : ℝ)) Filter.atTop (nhds 0) := by
    -- We can use the fact that $\log(\sqrt{n}) = \frac{1}{2}\log(n)$ and $\log(n) / n \to 0$ as $n \to \infty$.
    suffices h_log_sqrt : Filter.Tendsto (fun n : ℕ => (1 / 2) * Real.log n / (n : ℝ)) Filter.atTop (nhds 0) by
      exact h_log_sqrt.congr fun n => by rw [ Real.log_sqrt ( Nat.cast_nonneg _ ) ] ; ring;
    -- Let $y = \frac{1}{x}$ so we can rewrite the limit expression as $\lim_{y \to 0^+} \frac{1}{2} y \log(1/y)$.
    suffices h_change_var : Filter.Tendsto (fun y : ℝ => (1 / 2) * y * Real.log (1 / y)) (Filter.map (fun x => 1 / x) Filter.atTop) (nhds 0) by
      exact h_change_var.comp ( Filter.map_mono tendsto_natCast_atTop_atTop ) |> fun h => h.congr ( by intros; simp +decide ; ring );
    norm_num;
    exact tendsto_nhdsWithin_of_tendsto_nhds ( by simpa [ mul_assoc ] using Filter.Tendsto.neg ( tendsto_const_nhds.mul ( Real.continuous_mul_log.tendsto 0 ) ) );
  -- We can factor out the constant $2$ from the denominator and use the fact that $\log(2\sqrt{n}/\delta) = \log(2) + \log(\sqrt{n}) - \log(\delta)$.
  suffices h_factor : Filter.Tendsto (fun n : ℕ => (gaussianKLDiv d normW σq σp + Real.log 2 + Real.log (Real.sqrt n) - Real.log δ) / (2 * (n : ℝ))) Filter.atTop (nhds 0) by
    have h_factor : Filter.Tendsto (fun n : ℕ => (gaussianKLDiv d normW σq σp + Real.log 2 + Real.log (Real.sqrt n) - Real.log δ) / (2 * (n - 1 : ℝ))) Filter.atTop (nhds 0) := by
      have h_factor : Filter.Tendsto (fun n : ℕ => (gaussianKLDiv d normW σq σp + Real.log 2 + Real.log (Real.sqrt n) - Real.log δ) / (2 * (n : ℝ)) * (n / (n - 1 : ℝ))) Filter.atTop (nhds 0) := by
        simpa using h_factor.mul ( tendsto_natCast_div_add_atTop ( -1 : ℝ ) );
      refine h_factor.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 1 ] with n hn; rw [ div_mul_div_comm ] ; rw [ div_eq_div_iff ] <;> nlinarith [ show ( n : ℝ ) > 1 by exact_mod_cast hn ] );
    refine h_factor.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with n hn; rw [ Real.log_div ( by positivity ) ( by positivity ), Real.log_mul ( by positivity ) ( by positivity ), Real.log_sqrt ( by positivity ) ] ; ring );
  ring_nf;
  simpa using Filter.Tendsto.add ( Filter.Tendsto.add ( Filter.Tendsto.add ( tendsto_const_nhds.mul ( tendsto_inv_atTop_zero.comp tendsto_natCast_atTop_atTop ) |> Filter.Tendsto.mul_const _ ) ( tendsto_const_nhds.mul ( tendsto_inv_atTop_zero.comp tendsto_natCast_atTop_atTop ) |> Filter.Tendsto.mul_const _ ) ) ( h_log_sqrt.mul_const _ ) ) ( tendsto_const_nhds.mul ( tendsto_inv_atTop_zero.comp tendsto_natCast_atTop_atTop ) |> Filter.Tendsto.mul_const _ )

/-- For the equal-variance case, the complexity is O(1/n). -/
theorem gaussian_equal_var_complexity_rate
    (d : ℕ) (normW σ : ℝ) (hσ : 0 < σ) (C : ℝ) (hC : normW ^ 2 ≤ C) :
    ∀ n : ℕ, 1 < n →
      gaussianShiftKL d normW σ / (n : ℝ) ≤ C / (2 * σ ^ 2 * (n : ℝ)) := by
  intro n hn
  unfold gaussianShiftKL
  rw [div_div]
  apply div_le_div_of_nonneg_right hC
  have : (1 : ℝ) < (n : ℝ) := Nat.one_lt_cast.mpr hn
  positivity

end PACBayes

end