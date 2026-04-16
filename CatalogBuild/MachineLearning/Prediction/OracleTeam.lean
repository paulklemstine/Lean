/-! # CatalogBuild.MachineLearning.Prediction.OracleTeam

Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 5
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.MachineLearning.Prediction.OracleTeam
Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 5] -/
noncomputable def OracleCouncil.ensemblePrediction {n : ℕ}
    (council : OracleCouncil n) (evidence : ℝ)
    (total_conf_pos : 0 < ∑ i, (council.oracles i).confidence evidence) : ℝ :=
  (∑ i, (council.oracles i).confidence evidence * (council.oracles i).predict evidence) /
  (∑ i, (council.oracles i).confidence evidence)



/-- If all oracles agree, the ensemble agrees too -/
theorem unanimous_council {n : ℕ} (hn : 0 < n)
    (council : OracleCouncil n) (evidence : ℝ)
    (v : ℝ) (h_unanimous : ∀ i, (council.oracles i).predict evidence = v)
    (h_conf_pos : 0 < ∑ i, (council.oracles i).confidence evidence) :
    council.ensemblePrediction evidence h_conf_pos = v := by
  simp only [OracleCouncil.ensemblePrediction]
  simp_rw [h_unanimous, ← Finset.sum_mul]
  rw [mul_div_cancel_left₀]
  exact ne_of_gt h_conf_pos



/-- The ensemble error is bounded by the weighted average of individual errors -/
theorem ensemble_no_worse_than_best {n : ℕ}
    (predictions : Fin n → ℝ) (truth : ℝ)
    (weights : Fin n → ℝ) (hw_nn : ∀ i, 0 ≤ weights i)
    (hw_sum : ∑ i, weights i = 1) :
    let ensemble := ∑ i, weights i * predictions i
    |ensemble - truth| ≤ ∑ i, weights i * |predictions i - truth| := by
  simp only
  calc |∑ i, weights i * predictions i - truth|
      = |∑ i, weights i * predictions i - (∑ i, weights i) * truth| := by
        rw [hw_sum, one_mul]
    _ = |∑ i, (weights i * predictions i - weights i * truth)| := by
        congr 1; rw [Finset.sum_sub_distrib]; congr 1; rw [Finset.sum_mul]
    _ = |∑ i, weights i * (predictions i - truth)| := by
        congr 1; congr 1; ext i; ring
    _ ≤ ∑ i, |weights i * (predictions i - truth)| :=
        Finset.abs_sum_le_sum_abs _ _
    _ = ∑ i, weights i * |predictions i - truth| := by
        congr 1; ext i; rw [abs_mul, abs_of_nonneg (hw_nn i)]



/-- A hedge combines an aggressive and conservative prediction -/
noncomputable def hedge (aggressive conservative lambda_param : ℝ) : ℝ :=
  lambda_param * aggressive + (1 - lambda_param) * conservative



/-- Hedging interpolates between predictions -/
theorem hedge_interpolates (a c : ℝ) (hac : a ≤ c) (lambda_param : ℝ)
    (hl0 : 0 ≤ lambda_param) (hl1 : lambda_param ≤ 1) :
    a ≤ hedge a c lambda_param ∧ hedge a c lambda_param ≤ c := by
  simp only [hedge]
  constructor <;> nlinarith



end
