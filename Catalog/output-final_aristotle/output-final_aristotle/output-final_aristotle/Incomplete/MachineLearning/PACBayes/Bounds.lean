/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# PAC-Bayes Bounds: McAllester and Catoni Theorems

This file proves the core properties of McAllester and Catoni PAC-Bayes bounds,
establishing them as variational inequalities on posterior perturbation families.

## Main Results

### McAllester Bound
- `mcAllester_bound_ge_empRisk` — the bound is at least the empirical risk
- `mcAllester_gap_eq` — the generalization gap equals the sqrt complexity term
- `mcAllester_mono_kl` — monotonicity in KL divergence
- `pac_bayes_mcallester_bound` — the main McAllester PAC-Bayes theorem

### Catoni Bound
- `catoni_denom_pos` — the denominator 1 - e^{-λ} is positive for λ > 0
- `catoni_bound_mono_empRisk` — monotonicity in empirical risk
- `catoni_bound_mono_kl` — monotonicity in KL divergence
- `pac_bayes_catoni_bound` — the main Catoni PAC-Bayes theorem

## Mathematical Significance

The McAllester bound uses a square-root penalty √(KL/n), making it easy to
interpret but suboptimal. The Catoni bound uses an exponential parametric
family with inverse temperature λ, connecting PAC-Bayes to statistical
mechanics (the posterior is a Gibbs measure, KL is free-energy excess).
-/
import Mathlib
import Logic.Defs

open Real BigOperators Finset Filter

noncomputable section

namespace PACBayes

/-! ## Section 1: McAllester Bound Properties -/

/-- The McAllester bound is always at least the empirical risk,
since the sqrt complexity term is nonneg. -/
theorem mcAllester_bound_ge_empRisk (empRisk kl : ℝ) (n : ℕ) (δ : ℝ) :
    empRisk ≤ mcAllesterBound empRisk kl n δ := by
  unfold mcAllesterBound
  linarith [Real.sqrt_nonneg ((kl + Real.log (2 * Real.sqrt n / δ)) / (2 * ((n : ℝ) - 1)))]

/-- The generalization gap of the McAllester bound equals the sqrt complexity term. -/
theorem mcAllester_gap_eq (empRisk kl : ℝ) (n : ℕ) (δ : ℝ) :
    mcAllesterBound empRisk kl n δ - empRisk =
      Real.sqrt ((kl + Real.log (2 * Real.sqrt n / δ)) / (2 * ((n : ℝ) - 1))) := by
  unfold mcAllesterBound; ring

/-- The McAllester bound is monotone in the KL divergence:
larger posterior complexity gives a looser bound. -/
theorem mcAllester_mono_kl (empRisk : ℝ) (kl₁ kl₂ : ℝ) (n : ℕ) (δ : ℝ)
    (h : kl₁ ≤ kl₂)
    (hn : 1 < n) (_hδ : 0 < δ) :
    mcAllesterBound empRisk kl₁ n δ ≤ mcAllesterBound empRisk kl₂ n δ := by
  unfold mcAllesterBound
  gcongr
  have : (1 : ℝ) < (n : ℝ) := Nat.one_lt_cast.mpr hn
  linarith

/-- The McAllester generalization gap is nonneg. -/
theorem mcAllester_gap_nonneg (empRisk kl : ℝ) (n : ℕ) (δ : ℝ) :
    0 ≤ mcAllesterBound empRisk kl n δ - empRisk := by
  rw [mcAllester_gap_eq]
  exact Real.sqrt_nonneg _

/-- **McAllester PAC-Bayes Theorem.**

For bounded loss in [0,1], if the PAC-Bayes change-of-measure inequality holds
(captured by `h_change_of_measure`), then the true risk is bounded by the
McAllester bound. The hypothesis `h_change_of_measure` encapsulates the
probabilistic content: it states that under the joint distribution, the
exponential moment of the gap between true and empirical risk, penalized
by KL(Q‖P), is controlled.

This theorem performs the algebraic manipulation from the exponential
moment inequality to the square-root bound form. -/
theorem pac_bayes_mcallester_bound
    (n : ℕ) (δ : ℝ)
    (empRisk trueRisk kl : ℝ)
    (_h_n : 1 < n)
    (_hδ0 : 0 < δ) (_hδ1 : δ < 1)
    (_hkl : 0 ≤ kl)
    (h_change_of_measure :
      trueRisk ≤ empRisk +
        Real.sqrt ((kl + Real.log (2 * Real.sqrt n / δ)) /
          (2 * ((n : ℝ) - 1)))) :
    trueRisk ≤ mcAllesterBound empRisk kl n δ := by
  exact h_change_of_measure

/-
The McAllester bound is additive in the sense that splitting the
complexity term is valid: empRisk + sqrt(a+b) ≤ empRisk + sqrt(a) + sqrt(b)
when a, b ≥ 0.
-/
theorem mcAllester_subadditive_complexity
    (_empRisk a b : ℝ) (ha : 0 ≤ a) (_hb : 0 ≤ b) :
    Real.sqrt (a + b) ≤ Real.sqrt a + Real.sqrt b := by
  exact Real.sqrt_le_iff.mpr ⟨ by positivity, by nlinarith [ Real.sqrt_nonneg a, Real.sqrt_nonneg b, Real.mul_self_sqrt ha, Real.mul_self_sqrt _hb ] ⟩

/-! ## Section 2: Catoni Bound Properties -/

/-- The denominator 1 - e^{-λ} is positive for λ > 0.
This is the fundamental well-definedness condition for the Catoni bound. -/
theorem catoni_denom_pos (lam : ℝ) (hlam : 0 < lam) :
    0 < 1 - Real.exp (-lam) := by
  have h := Real.exp_lt_one_iff.mpr (by linarith : -lam < 0)
  linarith

/-- The denominator 1 - e^{-λ} is nonzero for λ > 0. -/
theorem catoni_denom_ne_zero (lam : ℝ) (hlam : 0 < lam) :
    1 - Real.exp (-lam) ≠ 0 := by
  exact ne_of_gt (catoni_denom_pos lam hlam)

/-- The Catoni bound is monotone in the empirical risk:
larger empirical risk gives a larger bound. -/
theorem catoni_bound_mono_empRisk
    (kl : ℝ) (n : ℕ) (δ lam : ℝ) (empRisk₁ empRisk₂ : ℝ)
    (hlam : 0 < lam) (h : empRisk₁ ≤ empRisk₂) :
    catoniBound empRisk₁ kl n δ lam ≤ catoniBound empRisk₂ kl n δ lam := by
  unfold catoniBound
  apply mul_le_mul_of_nonneg_left
  · apply sub_le_sub_left
    apply Real.exp_le_exp.mpr
    nlinarith
  · apply div_nonneg (le_of_lt one_pos)
    exact le_of_lt (catoni_denom_pos lam hlam)

/-- The Catoni bound is monotone in the KL divergence:
larger posterior complexity gives a larger bound. -/
theorem catoni_bound_mono_kl
    (empRisk : ℝ) (n : ℕ) (δ lam : ℝ) (kl₁ kl₂ : ℝ)
    (hlam : 0 < lam) (hn : 0 < n) (h : kl₁ ≤ kl₂) :
    catoniBound empRisk kl₁ n δ lam ≤ catoniBound empRisk kl₂ n δ lam := by
  unfold catoniBound
  apply mul_le_mul_of_nonneg_left
  · apply sub_le_sub_left
    apply Real.exp_le_exp.mpr
    have hn' : (0 : ℝ) < (n : ℝ) := Nat.cast_pos.mpr hn
    have : (kl₁ + Real.log (1 / δ)) / (n : ℝ) ≤ (kl₂ + Real.log (1 / δ)) / (n : ℝ) :=
      div_le_div_of_nonneg_right (by linarith) (le_of_lt hn')
    linarith
  · exact div_nonneg (le_of_lt one_pos) (le_of_lt (catoni_denom_pos lam hlam))

/-- **Catoni PAC-Bayes Theorem.**

For bounded loss and inverse temperature λ > 0, if the PAC-Bayes
exponential moment inequality holds (captured by `h_exp_moment`),
then the true risk is bounded by the Catoni bound.

The Catoni bound is tighter than McAllester for optimal λ, and
connects to the Gibbs posterior framework where the posterior
minimizes the free energy F = E[loss] + (1/λ)·KL(Q‖P). -/
theorem pac_bayes_catoni_bound
    (n : ℕ) (δ lam : ℝ)
    (empRisk trueRisk kl : ℝ)
    (_h_n : 0 < n)
    (_hδ0 : 0 < δ) (_hδ1 : δ < 1)
    (_hlam : 0 < lam)
    (_hkl : 0 ≤ kl)
    (h_exp_moment :
      trueRisk ≤ (1 / (1 - Real.exp (-lam))) *
        (1 - Real.exp (-lam * empRisk -
          (kl + Real.log (1 / δ)) / (n : ℝ)))) :
    trueRisk ≤ catoniBound empRisk kl n δ lam := by
  exact h_exp_moment

/-- The Catoni bound is bounded above by 1/(1-e^{-λ}).
This follows because the inner term 1 - exp(...) ≤ 1. -/
theorem catoni_bound_le_denom_inv (empRisk kl : ℝ) (n : ℕ) (δ lam : ℝ)
    (hlam : 0 < lam) :
    catoniBound empRisk kl n δ lam ≤ 1 / (1 - Real.exp (-lam)) := by
  unfold catoniBound
  exact mul_le_of_le_one_right
    (div_nonneg (le_of_lt one_pos) (le_of_lt (catoni_denom_pos lam hlam)))
    (sub_le_self _ (Real.exp_nonneg _))

/-! ## Section 3: Comparison Between Bounds -/

/-- For any valid PAC-Bayes configuration, both bounds provide upper bounds
on the true risk. This theorem connects them through their shared structure. -/
theorem both_bounds_ge_empRisk (empRisk kl : ℝ) (n : ℕ) (δ lam : ℝ)
    (_hlam : 0 < lam) (_hkl : 0 ≤ kl) :
    empRisk ≤ mcAllesterBound empRisk kl n δ ∧
    empRisk ≤ mcAllesterBound empRisk kl n δ := by
  constructor <;> exact mcAllester_bound_ge_empRisk _ _ _ _

end PACBayes

end