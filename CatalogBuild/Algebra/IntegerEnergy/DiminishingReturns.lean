/-! # CatalogBuild.Algebra.IntegerEnergy.DiminishingReturns

Auto-generated from theorem catalog database.
Domain: Algebra/IntegerEnergy
Declarations: 10
-/

import Mathlib

noncomputable section

/-- The variance of an equal-weight ensemble of n i.i.d. predictors,
each with individual variance σ² and pairwise correlation ρ, is:
σ²/n + ρ·σ²·(n-1)/n -/
noncomputable def ensembleVariance (σ_sq : ℝ) (ρ : ℝ) (n : ℕ) : ℝ :=
  σ_sq / n + ρ * σ_sq * (n - 1) / n





/-- [Section: # CatalogBuild.MachineLearning.Prediction.DiminishingReturns
Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 10] -/
theorem ensemble_variance_limit (σ_sq : ℝ) (ρ : ℝ) (hσ : 0 < σ_sq) (hρ : 0 ≤ ρ) (hρ1 : ρ < 1) :
    Filter.Tendsto (fun n : ℕ => ensembleVariance σ_sq ρ (n + 1))
      Filter.atTop (nhds (ρ * σ_sq)) := by
  -- We'll use the fact that if the denominator grows much faster than the numerator, the fraction tends to zero.
  have h_tendsto_zero : Filter.Tendsto (fun n => σ_sq / (n + 1)) Filter.atTop (nhds 0) := by
    exact tendsto_const_nhds.div_atTop ( Filter.tendsto_id.atTop_add tendsto_const_nhds );
  -- Functionally decompose `ensembleVariance` to separate the terms involving `ρ`.
  have h_decomp : ∀ n : ℕ, ensembleVariance σ_sq ρ (n + 1) = (ρ * σ_sq) + (σ_sq / (n + 1)) * (1 - ρ) := by
    intro n; unfold ensembleVariance; ring;
    grind +splitImp;
  simpa [ h_decomp ] using tendsto_const_nhds.add ( h_tendsto_zero.comp tendsto_natCast_atTop_atTop |> Filter.Tendsto.mul_const _ )





/-- The marginal improvement from adding the (n+1)-th oracle to an
equally-weighted i.i.d. ensemble with zero correlation -/
noncomputable def marginalImprovement (σ_sq : ℝ) (n : ℕ) : ℝ :=
  σ_sq / n - σ_sq / (n + 1)





/-- [Section: # CatalogBuild.MachineLearning.Prediction.DiminishingReturns
Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 10] -/
theorem marginal_improvement_formula (σ_sq : ℝ) (n : ℕ) (hn : 0 < n) :
    marginalImprovement σ_sq n = σ_sq / (n * (n + 1)) := by
  unfold marginalImprovement; rw [ div_sub_div ] <;> ring <;> positivity;





/-- [Section: # CatalogBuild.MachineLearning.Prediction.DiminishingReturns
Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 10] -/
theorem marginal_improvement_decreasing (σ_sq : ℝ) (hσ : 0 < σ_sq) (n : ℕ) (hn : 0 < n) :
    marginalImprovement σ_sq (n + 1) < marginalImprovement σ_sq n := by
  rw [ marginalImprovement, marginalImprovement ];
  -- Combine the fractions over a common denominator.
  field_simp;
  norm_num; nlinarith;





theorem marginal_improvement_bound (σ_sq : ℝ) (hσ : 0 < σ_sq) (n : ℕ) (hn : 0 < n) :
    marginalImprovement σ_sq n ≤ σ_sq / n ^ 2 := by
  convert div_le_div_of_nonneg_left hσ.le _ _ using 1 <;> norm_num [ mul_comm, sq, hn ];
  exacts [ marginal_improvement_formula σ_sq n hn, by norm_cast; nlinarith ]





/-- The cost of adding an oracle -/
noncomputable def totalCost (σ_sq : ℝ) (costPerOracle : ℝ) (n : ℕ) : ℝ :=
  σ_sq / n + costPerOracle * n





theorem optimal_ensemble_size_bound (σ_sq c : ℝ) (hσ : 0 < σ_sq) (hc : 0 < c) :
    ∀ n : ℕ, 0 < n →
    totalCost σ_sq c n ≥ 2 * Real.sqrt (σ_sq * c) := by
  unfold totalCost;
  intro n hn; nlinarith [ sq_nonneg ( Real.sqrt ( σ_sq * c ) - σ_sq / n ), Real.mul_self_sqrt ( show 0 ≤ σ_sq * c by positivity ), show 0 < σ_sq / n by positivity, show 0 < c * n by positivity, mul_div_cancel₀ σ_sq ( show ( n : ℝ ) ≠ 0 by positivity ) ] ;





theorem correlated_ensemble_floor (σ_sq ρ : ℝ) (n : ℕ) (hn : 0 < n)
    (hρ : 0 ≤ ρ) (hρ1 : ρ ≤ 1) (hσ : 0 < σ_sq) :
    ensembleVariance σ_sq ρ n ≥ ρ * σ_sq := by
  unfold ensembleVariance;
  nlinarith [ show ( n : ℝ ) ≥ 1 by norm_cast, div_mul_cancel₀ ( σ_sq ) ( by positivity : ( n : ℝ ) ≠ 0 ), div_mul_cancel₀ ( ρ * σ_sq * ( n - 1 ) ) ( by positivity : ( n : ℝ ) ≠ 0 ) ]





/-- The total improvement from n oracles over a single oracle is bounded -/
theorem total_improvement_bounded (σ_sq : ℝ) (hσ : 0 < σ_sq) (n : ℕ) (hn : 0 < n) :
    σ_sq - σ_sq / n ≤ σ_sq := by
  linarith [div_nonneg (le_of_lt hσ) (Nat.cast_nonneg' n)]





end
