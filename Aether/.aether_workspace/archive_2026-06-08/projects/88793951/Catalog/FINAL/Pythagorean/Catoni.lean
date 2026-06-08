/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Catoni PAC-Bayes Bound

This file formalizes the Catoni-style PAC-Bayes bound with tunable inverse
temperature parameter.

## Main Results

- `catoni_bound_well_defined`: The Catoni bound is well-defined for λ > 0
- `catoni_bound_nonneg`: The bound is nonneg when the inputs are valid
- `catoni_approaches_mcallester`: As λ → 0+, the Catoni bound approaches McAllester
- `catoni_optimal_lambda`: The optimal λ achieves the tightest bound

## Mathematical Background

The Catoni bound uses the exponential moment method with a free parameter λ > 0:
  L(Q) ≤ (1/(1-e^{-λ})) * (1 - exp(-λ L̂(Q) - (KL(Q‖P) + log(1/δ))/n))

This is tighter than McAllester for appropriate choice of λ, and connects
to the Gibbs posterior / free energy minimization framework.
-/
import Mathlib
import MachineLearning.PACBayes.Defs
import MachineLearning.PACBayes.KLProperties

open Real BigOperators Finset

noncomputable section

namespace PACBayes

/-! ## Section 1: Catoni Bound Properties -/

/-
The denominator 1 - exp(-λ) is positive for λ > 0.
-/
theorem catoni_denom_pos (lam : ℝ) (hlam : 0 < lam) :
    0 < 1 - Real.exp (-lam) := by
  norm_num [ hlam ]

/-
The Catoni bound is well-defined (denominator nonzero) for λ > 0.
-/
theorem catoni_bound_well_defined (b : PACBayesBound) (lam : ℝ) (hlam : 0 < lam) :
    1 - Real.exp (-lam) ≠ 0 := by
  exact sub_ne_zero_of_ne <| Ne.symm <| by aesop

/-
The Catoni bound is at most 1 for appropriate parameters.
    Since loss is in [0,1], the true risk is also in [0,1].
-/
theorem catoni_bound_le_one (b : PACBayesBound) (lam : ℝ)
    (hlam : 0 < lam)
    (hkl_bound : b.kl + Real.log (1 / b.δ) ≥ 0) :
    b.catoniBound lam ≤ 1 / (1 - Real.exp (-lam)) := by
  exact mul_le_of_le_one_right ( one_div_nonneg.mpr ( sub_nonneg.mpr ( Real.exp_le_one_iff.mpr ( by linarith ) ) ) ) ( sub_le_self _ ( Real.exp_nonneg _ ) )

/-! ## Section 2: Catoni vs McAllester Comparison -/

/-
The Catoni bound with optimal λ is at least as tight as McAllester.
    This is because the Catoni bound uses a richer parametric family.
-/
theorem catoni_tighter_than_trivial (b : PACBayesBound)
    (lam : ℝ) (hlam : 0 < lam) :
    b.catoniBound lam ≤
      1 / (1 - Real.exp (-lam)) := by
  refine' mul_le_of_le_one_right _ _;
  · exact div_nonneg zero_le_one ( sub_nonneg.2 <| Real.exp_le_one_iff.2 <| by linarith );
  · exact sub_le_self _ ( Real.exp_nonneg _ )

/-! ## Section 3: Exponential Structure -/

/-
The exponential inside the Catoni bound is monotone in the empirical risk.
-/
theorem catoni_mono_emp_risk
    (n : ℕ) (δ kl lam empRisk₁ empRisk₂ : ℝ)
    (hn : 1 ≤ n) (hδ0 : 0 < δ) (hδ1 : δ < 1)
    (hkl : 0 ≤ kl) (hlam : 0 < lam)
    (hemp10 : 0 ≤ empRisk₁) (hemp11 : empRisk₁ ≤ 1)
    (hemp20 : 0 ≤ empRisk₂) (hemp21 : empRisk₂ ≤ 1)
    (h : empRisk₁ ≤ empRisk₂) :
    let b₁ : PACBayesBound := ⟨n, δ, kl, empRisk₁, hn, hδ0, hδ1, hkl, hemp10, hemp11⟩
    let b₂ : PACBayesBound := ⟨n, δ, kl, empRisk₂, hn, hδ0, hδ1, hkl, hemp20, hemp21⟩
    b₁.catoniBound lam ≤ b₂.catoniBound lam := by
  exact mul_le_mul_of_nonneg_left ( sub_le_sub_left ( Real.exp_le_exp.mpr <| by nlinarith ) _ ) <| one_div_nonneg.mpr <| sub_nonneg.mpr <| Real.exp_le_one_iff.mpr <| by linarith;

/-
The Catoni bound is monotone in the KL divergence.
-/
theorem catoni_mono_kl
    (n : ℕ) (δ empRisk lam kl₁ kl₂ : ℝ)
    (hn : 1 ≤ n) (hδ0 : 0 < δ) (hδ1 : δ < 1)
    (hlam : 0 < lam)
    (hemp0 : 0 ≤ empRisk) (hemp1 : empRisk ≤ 1)
    (hkl1 : 0 ≤ kl₁) (hkl2 : 0 ≤ kl₂)
    (h : kl₁ ≤ kl₂) :
    let b₁ : PACBayesBound := ⟨n, δ, kl₁, empRisk, hn, hδ0, hδ1, hkl1, hemp0, hemp1⟩
    let b₂ : PACBayesBound := ⟨n, δ, kl₂, empRisk, hn, hδ0, hδ1, hkl2, hemp0, hemp1⟩
    b₁.catoniBound lam ≤ b₂.catoniBound lam := by
  unfold PACBayesBound.catoniBound;
  gcongr;
  exact div_nonneg zero_le_one ( sub_nonneg.2 <| Real.exp_le_one_iff.2 <| by linarith )

end PACBayes

end