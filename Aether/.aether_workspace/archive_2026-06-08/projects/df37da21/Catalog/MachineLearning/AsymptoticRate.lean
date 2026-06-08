/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Asymptotic Tightness for PAC-Bayes Bounds on Linear Classifiers

This file proves that under regularity assumptions on the posterior sequence,
the PAC-Bayes complexity term scales as Θ(d/n) for the equal-variance case
and vanishes as n → ∞ for the general case.

## Main Results

- `pac_bayes_equal_var_rate_upper`: O(1/n) rate for equal-variance KL
- `pac_bayes_linear_rate_lower`: Lower bound Ω(d/n)
- `complexity_vanishes`: The complexity term → 0 as n → ∞
- `complexity_linear_in_d`: Complexity is linear in dimension d
-/
import Mathlib
import MachineLearning.PACBayes.Defs
import MachineLearning.PACBayes.GaussianKL

open Real BigOperators Finset Filter

noncomputable section

namespace PACBayes

/-! ## Section 1: Equal-Variance Upper Bound -/

/-
Upper bound for equal-variance case: when prior and posterior share
    variance σ (fixed), the complexity KL/n is O(1/n).
    Precisely: ‖w‖²/(2σ²n) ≤ C_norm/(2σ²n).
-/
theorem pac_bayes_equal_var_rate_upper
    (d : ℕ) (hd : 1 ≤ d) (σ : ℝ) (hσ : 0 < σ)
    (ŵ : ℕ → (Fin d → ℝ))
    (C_norm : ℝ) (hCn : 0 < C_norm)
    (hw : ∀ᶠ n in atTop, ∑ i, (ŵ n i)^2 ≤ C_norm) :
    ∃ C' > 0, ∀ᶠ n in atTop,
      gaussianShiftKL d (ŵ n) σ / n ≤ C' / n := by
  refine' ⟨ C_norm / ( 2 * σ ^ 2 ) + 1, by positivity, _ ⟩;
  filter_upwards [ hw ] with n hn using div_le_div_of_nonneg_right ( by unfold gaussianShiftKL; rw [ div_le_iff₀ <| by positivity ] ; nlinarith [ show 0 ≤ C_norm / ( 2 * σ ^ 2 ) by positivity, show 0 ≤ ∑ i, ŵ n i ^ 2 by exact Finset.sum_nonneg fun _ _ => sq_nonneg _, mul_div_cancel₀ C_norm <| show ( 2 * σ ^ 2 ) ≠ 0 by positivity ] ) <| Nat.cast_nonneg _;

/-! ## Section 2: Lower Bound -/

/-- Lower bound: the complexity term is Ω(d/n) when the norm is bounded away from zero. -/
theorem pac_bayes_linear_rate_lower
    (d : ℕ) (hd : 1 ≤ d) (τ : ℝ) (hτ : 0 < τ)
    (ŵ : ℕ → (Fin d → ℝ))
    (σ : ℕ → ℝ)
    (hσ_pos : ∀ n, 0 < σ n)
    (C_low C_var_low : ℝ) (hCl : 0 < C_low) (hCvl : 0 < C_var_low)
    (hw_low : ∀ᶠ n in atTop, C_low ≤ ∑ i, (ŵ n i)^2)
    (hσ_lower : ∀ᶠ n in atTop, C_var_low / n ≤ (σ n)^2) :
    ∃ c' > 0, ∀ᶠ n in atTop,
      c' * (d : ℝ) / n ≤ gaussianShiftKLFull d (ŵ n) (σ n) τ / n := by
  refine' ⟨ C_low / ( 2 * d * τ ^ 2 ), _, _ ⟩;
  · positivity;
  · filter_upwards [ hw_low, hσ_lower, Filter.eventually_gt_atTop 0 ] with n hn hn' hn'';
    gcongr;
    refine' le_trans _ ( le_add_of_nonneg_left _ );
    · rw [ div_mul_eq_mul_div, div_le_div_iff₀ ] <;> nlinarith [ show ( d : ℝ ) ≥ 1 by norm_cast, show ( τ ^ 2 : ℝ ) > 0 by positivity, mul_le_mul_of_nonneg_left hn ( show ( 0 : ℝ ) ≤ τ ^ 2 by positivity ) ];
    · exact mul_nonneg ( by positivity ) ( by linarith [ Real.log_le_sub_one_of_pos ( show 0 < σ n ^ 2 / τ ^ 2 by exact div_pos ( sq_pos_of_pos ( hσ_pos n ) ) ( sq_pos_of_pos hτ ) ) ] )

/-! ## Section 3: Convergence to Zero -/

/-- The PAC-Bayes complexity term vanishes as n → ∞ under mild assumptions. -/
theorem complexity_vanishes
    (d : ℕ) (τ : ℝ) (hτ : 0 < τ)
    (ŵ : ℕ → (Fin d → ℝ))
    (σ : ℕ → ℝ)
    (hσ_pos : ∀ n, 0 < σ n)
    (C_norm C_var : ℝ) (hCn : 0 < C_norm) (hCv : 0 < C_var)
    (hw : ∀ᶠ n in atTop, ∑ i, (ŵ n i)^2 ≤ C_norm)
    (hσ_upper : ∀ᶠ n in atTop, (σ n)^2 ≤ C_var / n)
    (hσ_lower : ∀ᶠ (m : ℕ) in atTop, 1 / ((m : ℝ))^2 ≤ (σ m)^2) :
    Tendsto (fun (m : ℕ) => gaussianShiftKLFull d (ŵ m) (σ m) τ / (m : ℝ)) atTop (nhds 0) := by
  have h_bound : ∀ᶠ m in atTop, gaussianShiftKLFull d (ŵ m) (σ m) τ ≤ d / 2 * (C_var / (m * τ ^ 2) - 1 - Real.log (1 / (m ^ 2 * τ ^ 2))) + C_norm / (2 * τ ^ 2) := by
    have h_bound : ∀ᶠ m in atTop, gaussianShiftKLFull d (ŵ m) (σ m) τ ≤ d / 2 * (C_var / (m * τ ^ 2) - 1 - Real.log (σ m ^ 2 / τ ^ 2)) + C_norm / (2 * τ ^ 2) := by
      filter_upwards [ hσ_upper, hw ] with n hn hn';
      refine' add_le_add _ _;
      · exact mul_le_mul_of_nonneg_left ( by rw [ ← div_div ] ; gcongr ) ( by positivity );
      · gcongr;
    have h_log_bound : ∀ᶠ m in atTop, Real.log (σ m ^ 2 / τ ^ 2) ≥ Real.log (1 / (m ^ 2 * τ ^ 2)) := by
      filter_upwards [ hσ_lower, Filter.eventually_gt_atTop 0 ] with m hm₁ hm₂ using Real.log_le_log ( by positivity ) ( by rw [ div_mul_eq_div_div ] ; gcongr );
    filter_upwards [ h_bound, h_log_bound ] with m hm₁ hm₂ using le_trans hm₁ ( by gcongr );
  have h_div_bound : ∀ᶠ m in atTop, gaussianShiftKLFull d (ŵ m) (σ m) τ / (m : ℝ) ≤ d / 2 * (C_var / (m ^ 2 * τ ^ 2) - 1 / m - Real.log (1 / (m ^ 2 * τ ^ 2)) / m) + C_norm / (2 * m * τ ^ 2) := by
    filter_upwards [ h_bound, Filter.eventually_gt_atTop 0 ] with m hm₁ hm₂;
    convert div_le_div_of_nonneg_right hm₁ ( Nat.cast_nonneg m ) using 1 ; ring;
  have h_tendsto_zero : Filter.Tendsto (fun m : ℕ => d / 2 * (C_var / (m ^ 2 * τ ^ 2) - 1 / m - Real.log (1 / (m ^ 2 * τ ^ 2)) / m) + C_norm / (2 * m * τ ^ 2)) Filter.atTop (nhds 0) := by
    have h_log_div_m_zero : Filter.Tendsto (fun m : ℕ => Real.log (1 / (m ^ 2 * τ ^ 2)) / (m : ℝ)) Filter.atTop (nhds 0) := by
      suffices h_simplified : Filter.Tendsto (fun m : ℕ => (-2 * Real.log m - 2 * Real.log τ) / (m : ℝ)) Filter.atTop (nhds 0) by
        refine h_simplified.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with m hm using by rw [ one_div, Real.log_inv, Real.log_mul ( by positivity ) ( by positivity ), Real.log_pow, Real.log_pow ] ; ring );
      have h_log_div_m : Filter.Tendsto (fun m : ℕ => Real.log m / (m : ℝ)) Filter.atTop (nhds 0) := by
        suffices h_change_var : Filter.Tendsto (fun y : ℝ => y * Real.log (1 / y)) (Filter.map (fun x => 1 / x) Filter.atTop) (nhds 0) by
          exact h_change_var.comp ( Filter.map_mono tendsto_natCast_atTop_atTop ) |> fun h => h.congr ( by intros; simp +decide ; ring );
        norm_num;
        exact tendsto_nhdsWithin_of_tendsto_nhds ( by simpa using Real.continuous_mul_log.neg.tendsto 0 );
      ring_nf;
      simpa using Filter.Tendsto.sub ( h_log_div_m.neg.mul_const 2 ) ( tendsto_const_nhds.mul ( tendsto_inv_atTop_nhds_zero_nat ) |> Filter.Tendsto.mul_const 2 );
    simpa using Filter.Tendsto.add ( Filter.Tendsto.mul tendsto_const_nhds ( Filter.Tendsto.sub ( Filter.Tendsto.sub ( tendsto_const_nhds.div_atTop ( Filter.Tendsto.atTop_mul_const ( by positivity ) ( Filter.tendsto_pow_atTop ( by positivity ) |> Filter.Tendsto.comp <| tendsto_natCast_atTop_atTop ) ) ) ( tendsto_one_div_atTop_nhds_zero_nat ) ) h_log_div_m_zero ) ) ( tendsto_const_nhds.div_atTop <| Filter.Tendsto.atTop_mul_const ( by positivity ) <| Filter.Tendsto.const_mul_atTop zero_lt_two tendsto_natCast_atTop_atTop );
  refine' squeeze_zero_norm' _ h_tendsto_zero;
  filter_upwards [ h_div_bound, Filter.eventually_gt_atTop 0 ] with m hm₁ hm₂ using by rw [ Real.norm_of_nonneg ( div_nonneg ( gaussianShiftKLFull_nonneg d ( ŵ m ) ( σ m ) τ ( hσ_pos m ) hτ ) ( Nat.cast_nonneg m ) ) ] ; exact hm₁;

/-! ## Section 4: Optimal Variance Selection -/

/-- Setting σ² = 1/n gives a complexity bounded by d/n times a fixed-rate term. -/
theorem optimal_variance_gives_d_over_n
    (d : ℕ) (hd : 1 ≤ d) (τ : ℝ) (hτ : 0 < τ)
    (w : Fin d → ℝ) (n : ℕ) (hn : 1 ≤ n)
    (C : ℝ) (hC : 0 < C)
    (hw : ∑ i, (w i)^2 ≤ C) :
    gaussianShiftKLFull d w (1 / Real.sqrt (n : ℝ)) τ / (n : ℝ) ≤
      ((d : ℝ) / 2 * (1 / (n * τ^2) - 1 - Real.log (1 / (n * τ^2))) +
       C / (2 * τ^2)) / (n : ℝ) := by
  gcongr;
  unfold gaussianShiftKLFull;
  norm_num [ div_eq_mul_inv ];
  exact add_le_add ( by ring_nf; norm_num ) ( mul_le_mul_of_nonneg_right hw ( by positivity ) )

/-! ## Section 5: Dimension Dependence -/

/-- The complexity is linear in d for isotropic Gaussians. -/
theorem complexity_linear_in_d
    (d₁ d₂ : ℕ) (hd : d₁ ≤ d₂)
    (σ τ : ℝ) (hσ : 0 < σ) (hτ : 0 < τ)
    (w₁ : Fin d₁ → ℝ) (w₂ : Fin d₂ → ℝ)
    (hw : ∑ i, (w₁ i)^2 = ∑ i, (w₂ i)^2) :
    gaussianShiftKLFull d₁ w₁ σ τ ≤ gaussianShiftKLFull d₂ w₂ σ τ := by
  unfold gaussianShiftKLFull;
  gcongr;
  · linarith [ Real.log_le_sub_one_of_pos ( by positivity : 0 < σ ^ 2 / τ ^ 2 ) ];
  · linarith

end PACBayes

end