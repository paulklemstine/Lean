import Mathlib

/-! # CatalogBuild.EML.AIResearch.NeuralScalingLaws

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 18
-/

noncomputable section

/-- Power-law scaling: loss = A * N^(-α) + irreducible loss -/
def powerLawLoss (A α irreducibleLoss : ℝ) (N : ℝ) : ℝ :=
  A * N ^ (-α) + irreducibleLoss

/-- Loss is above the irreducible minimum (for positive A, N, α) -/
theorem loss_above_irreducible (A α L_irr N : ℝ)
    (hA : 0 < A) (hα : 0 < α) (hN : 0 < N) :
    L_irr < powerLawLoss A α L_irr N := by
  unfold powerLawLoss
  linarith [mul_pos hA (rpow_pos_of_pos hN (-α))]

/-- Larger N gives lower loss (for positive exponent) -/
theorem larger_N_lower_loss (A α L_irr N₁ N₂ : ℝ)
    (hA : 0 < A) (hα : 0 < α) (hN1 : 0 < N₁) (hN2 : 0 < N₂)
    (hN : N₁ ≤ N₂) :
    powerLawLoss A α L_irr N₂ ≤ powerLawLoss A α L_irr N₁ := by
  unfold powerLawLoss
  have : N₁ ^ (-α) ≥ N₂ ^ (-α) := by
    exact rpow_le_rpow_of_exponent_nonpos hN1 hN (neg_nonpos.mpr hα.le)
  nlinarith

/-- Loss is nonneg when irreducible loss is nonneg -/
theorem loss_nonneg (A α L_irr N : ℝ)
    (hA : 0 ≤ A) (hN : 0 < N) (hL : 0 ≤ L_irr) :
    0 ≤ powerLawLoss A α L_irr N := by
  unfold powerLawLoss
  have : 0 ≤ A * N ^ (-α) := mul_nonneg hA (rpow_nonneg hN.le (-α))
  linarith

/-- For fixed compute, increasing N requires decreasing D -/
theorem compute_tradeoff (C N₁ N₂ D₁ D₂ : ℝ)
    (hN1 : 0 < N₁) (hN2 : 0 < N₂) (hD1 : 0 < D₁) (hD2 : 0 < D₂)
    (h1 : totalCompute N₁ D₁ = C) (h2 : totalCompute N₂ D₂ = C)
    (hN : N₁ < N₂) :
    D₂ < D₁ := by
  unfold totalCompute at h1 h2
  nlinarith

/-- [Section: ## §2. Compute-Optimal Training] -/
theorem compute_linear_D (N D₁ D₂ : ℝ) (hN : 0 < N)
    (hD : D₁ ≤ D₂) :
    totalCompute N D₁ ≤ totalCompute N D₂ := by
  unfold totalCompute; nlinarith

/-- The scaling exponent determines the rate of improvement with scale -/
def scalingExponent (loss₁ loss₂ N₁ N₂ : ℝ) (hN1 : 0 < N₁) (hN2 : 0 < N₂) (hl1 : 0 < loss₁) (hl2 : 0 < loss₂) : ℝ :=
  -(Real.log loss₂ - Real.log loss₁) / (Real.log N₂ - Real.log N₁)

/-- Larger scaling exponent means faster improvement -/
def BetterScaling (α₁ α₂ : ℝ) : Prop :=
  α₁ < α₂

/-- Better scaling gives strictly lower loss at same N -/
theorem better_scaling_lower_loss (A L_irr N α₁ α₂ : ℝ)
    (hA : 0 < A) (hN : 1 < N) (hα1 : 0 < α₁) (hα : α₁ < α₂) :
    powerLawLoss A α₂ L_irr N < powerLawLoss A α₁ L_irr N := by
  unfold powerLawLoss
  have : N ^ (-α₂) < N ^ (-α₁) := by
    exact rpow_lt_rpow_of_exponent_lt hN (by linarith)
  nlinarith

/-- Marginal improvement is nonneg (loss decreases with scale) -/
theorem marginal_improvement_nonneg (A α L_irr N : ℝ)
    (hA : 0 < A) (hα : 0 < α) (hN : 0 < N) :
    0 ≤ marginalImprovement A α L_irr N := by
  unfold marginalImprovement
  linarith [larger_N_lower_loss A α L_irr N (2 * N) hA hα hN (by linarith) (by linarith)]

/-- EML effective parameter count -/
def emlEffectiveParams (d : ℕ) : ℕ := 4 * d

/-- Standard effective parameter count -/
def stdEffectiveParams (d : ℕ) : ℕ := d * d

/-- EML achieves same effective capacity with fewer real parameters,
shifting the scaling curve -/
theorem eml_parameter_efficiency (d : ℕ) (hd : 5 ≤ d) :
    emlEffectiveParams d < stdEffectiveParams d := by
  unfold emlEffectiveParams stdEffectiveParams; nlinarith

/-- With the same parameter budget, EML can use a wider model -/
theorem eml_wider_model (budget d₁ d₂ : ℕ)
    (hd1 : 5 ≤ d₁) (hd2 : 5 ≤ d₂)
    (h_eml : 4 * d₂ ≤ budget)
    (h_std : d₁ * d₁ ≤ budget)
    (h_eq : 4 * d₂ = d₁ * d₁) :
    d₁ < d₂ := by
  nlinarith

/-- The data-parameter equivalence: doubling data is equivalent to
multiplying parameters by 2^(α_D/α_N) in terms of loss reduction -/
def dataParameterRatio (αN αD : ℝ) : ℝ :=
  αD / αN

/-- Equal scaling exponents mean data and parameters are interchangeable -/
theorem equal_exponents_interchangeable (α : ℝ) (hα : 0 < α) :
    dataParameterRatio α α = 1 := by
  unfold dataParameterRatio
  exact div_self (ne_of_gt hα)

/-- When αD > αN, data is more valuable than parameters -/
theorem data_more_valuable (αN αD : ℝ) (hN : 0 < αN) (h : αN < αD) :
    1 < dataParameterRatio αN αD := by
  unfold dataParameterRatio
  rwa [one_lt_div hN]

/-- When αD < αN, parameters are more valuable than data -/
theorem params_more_valuable (αN αD : ℝ) (hN : 0 < αN) (h : αD < αN) :
    dataParameterRatio αN αD < 1 := by
  unfold dataParameterRatio
  rwa [div_lt_one hN]

end
