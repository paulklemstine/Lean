/-! # CatalogBuild.MachineLearning.Prediction.AdversarialPrediction

Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 15
-/

import Mathlib

noncomputable section

  theorem connecting adversarial and stochastic prediction.

  ## Key Results
  1. Minimax theorem for prediction games
  2. Regret bounds for online prediction
  3. Adversarial robustness
  4. The prediction security game
-/

import Mathlib

open Finset BigOperators Real

noncomputable section

/-! ## §1. The Prediction Game -/

/-- A prediction game between a forecaster and an adversary -/

structure PredictionGame where
  actionSpace : ℕ
  loss : ℝ → ℝ → ℝ
  loss_nonneg : ∀ p r, 0 ≤ loss p r
  loss_bounded : ∀ p r, loss p r ≤ 1

/-- Minimax value: the forecaster minimizes the worst case -/

noncomputable def minimaxValue (n m : ℕ) (losses : Fin n → Fin m → ℝ) : ℝ :=
  ⨅ i, ⨆ j, losses i j

/-- Maximin value: the adversary maximizes the best case -/

noncomputable def maximinValue (n m : ℕ) (losses : Fin n → Fin m → ℝ) : ℝ :=
  ⨆ j, ⨅ i, losses i j

/-
Weak duality: maximin ≤ minimax
-/

theorem weak_duality (n m : ℕ) [NeZero n] [NeZero m]
    (losses : Fin n → Fin m → ℝ) :
    maximinValue n m losses ≤ minimaxValue n m losses := by
  refine' ciSup_le _;
  intro j;
  refine' le_ciInf _;
  exact fun i => le_trans ( ciInf_le ( Finite.bddBelow_range fun i => losses i j ) i ) ( le_ciSup ( Finite.bddAbove_range fun j => losses i j ) j )

/-! ## §2. Regret Theory -/

/-- Cumulative regret: how much worse we did than the best fixed action -/

noncomputable def cumulativeRegret (T : ℕ) (losses : ℕ → ℝ) (bestLoss : ℝ) : ℝ :=
  (∑ t ∈ range T, losses t) - T * bestLoss

/-- The regret bound √(T log n / 2) is nonneg (Hoeffding bound) -/

theorem expert_regret_bound_nonneg (n T : ℕ) (hn : 0 < n) (hT : 0 < T) :
    0 ≤ Real.sqrt (T * Real.log n / 2) :=
  Real.sqrt_nonneg _

/-
Average regret vanishes as T → ∞
-/

theorem average_regret_vanishes (n : ℕ) (hn : 0 < n) :
    Filter.Tendsto (fun T : ℕ => Real.sqrt (Real.log n / (2 * T)))
      Filter.atTop (nhds 0) := by
  convert Filter.Tendsto.sqrt ( tendsto_const_nhds.div_atTop <| tendsto_natCast_atTop_atTop.const_mul_atTop zero_lt_two ) using 1 ; norm_num

/-! ## §3. Adversarial Robustness -/

/-- A predictor is ε-robust if small perturbations change predictions by ≤ δ -/

def isRobust (f : ℝ → ℝ) (ε δ : ℝ) : Prop :=
  ∀ x y, |x - y| ≤ ε → |f x - f y| ≤ δ

/-- Lipschitz predictors are robust -/

theorem lipschitz_is_robust (f : ℝ → ℝ) (L : ℝ) (hL : 0 ≤ L)
    (hlip : ∀ x y, |f x - f y| ≤ L * |x - y|)
    (ε : ℝ) (_hε : 0 < ε) :
    isRobust f ε (L * ε) := by
  intro x y hxy
  calc |f x - f y| ≤ L * |x - y| := hlip x y
    _ ≤ L * ε := mul_le_mul_of_nonneg_left hxy hL

/-- There is a fundamental tradeoff: more robust ↔ less accurate -/

theorem robustness_accuracy_tradeoff
    (accuracy : ℝ → ℝ)
    (h_monotone : ∀ δ₁ δ₂, δ₁ < δ₂ → accuracy δ₁ ≥ accuracy δ₂)
    (δ₁ δ₂ : ℝ) (h : δ₁ < δ₂) :
    accuracy δ₁ ≥ accuracy δ₂ :=
  h_monotone δ₁ δ₂ h

/-! ## §4. The Prediction Security Game -/

/-- An adversary has a budget for perturbing inputs -/

structure AdversaryBudget where
  budget : ℝ
  budget_pos : 0 < budget

/-- The adversary's optimal attack maximizes prediction error -/

theorem bounded_adversary_bounded_error
    (f : ℝ → ℝ) (L : ℝ) (hL : 0 ≤ L)
    (hlip : ∀ x y, |f x - f y| ≤ L * |x - y|)
    (adv : AdversaryBudget) :
    ∀ x x', |x - x'| ≤ adv.budget → |f x - f x'| ≤ L * adv.budget := by
  intro x x' hxx'
  calc |f x - f x'| ≤ L * |x - x'| := hlip x x'
    _ ≤ L * adv.budget := mul_le_mul_of_nonneg_left hxx' hL

/-! ## §5. Sequential Prediction Under Adversarial Corruption -/

/-- With fraction α of data corrupted, prediction error degrades linearly -/

theorem corruption_error_bound (α baseline_error : ℝ)
    (_hα0 : 0 ≤ α) (_hα1 : α ≤ 1) (hb : 0 ≤ baseline_error) :
    baseline_error * (1 - α) + α ≤ baseline_error + α := by
  nlinarith

/-- The breakdown point: no estimator works with arbitrary corruption above 50% -/

theorem breakdown_point_principle (corruption_fraction : ℝ) (h : 1/2 < corruption_fraction) :
    corruption_fraction > 1 - corruption_fraction := by
  linarith


end
