/-! # CatalogBuild.EML.QuantumDensityEstimation

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 21
-/

import Mathlib

noncomputable section

/-- EML exponential map: density from log-density -/
noncomputable def emlExp (logρ : ℝ) : ℝ := Real.exp logρ


/-- EML logarithmic map: log-density from density -/
noncomputable def emlLog (ρ : ℝ) : ℝ := Real.log ρ


/-- EML multiplicative operation on densities -/
noncomputable def emlMul (ρ₁ ρ₂ : ℝ) : ℝ := ρ₁ * ρ₂


/-- EML exp-log roundtrip -/
theorem eml_exp_log_id (ρ : ℝ) (hρ : 0 < ρ) :
    emlExp (emlLog ρ) = ρ := by
  exact Real.exp_log hρ


/-- EML log-exp roundtrip -/
theorem eml_log_exp_id (x : ℝ) :
    emlLog (emlExp x) = x := by
  exact Real.log_exp x


/-- EML multiplication in log space is addition -/
theorem eml_log_mul (ρ₁ ρ₂ : ℝ) (h₁ : 0 < ρ₁) (h₂ : 0 < ρ₂) :
    emlLog (emlMul ρ₁ ρ₂) = emlLog ρ₁ + emlLog ρ₂ := by
  exact Real.log_mul (ne_of_gt h₁) (ne_of_gt h₂)


/-- Wave function norm squared gives density -/
noncomputable def waveToDensity (sqrtRho : ℝ) : ℝ := sqrtRho^2


/-- Density is non-negative -/
theorem waveToDensity_nonneg (sqrtRho : ℝ) :
    0 ≤ waveToDensity sqrtRho := by
  exact sq_nonneg _


/-- Log-density from wave function -/
noncomputable def waveToLogDensity (sqrtRho : ℝ) : ℝ :=
  2 * Real.log sqrtRho


/-- Log-density consistency -/
theorem log_density_consistent (sqrtRho : ℝ) (h : 0 < sqrtRho) :
    waveToLogDensity sqrtRho = emlLog (waveToDensity sqrtRho) := by
  unfold waveToLogDensity waveToDensity emlLog
  rw [Real.log_pow]; norm_cast


/-- Classical density evolution -/
noncomputable def densityEvol (ρ₀ : ℝ) (divIntegral : ℝ) : ℝ :=
  ρ₀ * Real.exp (-divIntegral)


/-- EML log-density evolution (additive in log space) -/
noncomputable def logDensityEvol (logρ₀ : ℝ) (divIntegral : ℝ) : ℝ :=
  logρ₀ - divIntegral


/-- EML density evolution preserves positivity -/
theorem densityEvol_pos (ρ₀ divInt : ℝ) (h : 0 < ρ₀) :
    0 < densityEvol ρ₀ divInt := by
  exact mul_pos h (Real.exp_pos _)


/-- EML log-density evolution equals log of density evolution -/
theorem eml_density_consistency (ρ₀ divInt : ℝ) (h : 0 < ρ₀) :
    logDensityEvol (emlLog ρ₀) divInt = emlLog (densityEvol ρ₀ divInt) := by
  unfold logDensityEvol densityEvol emlLog
  rw [Real.log_mul (ne_of_gt h) (ne_of_gt (Real.exp_pos _)), Real.log_exp]; ring


/-- Density evolution composes multiplicatively -/
theorem densityEvol_compose (ρ₀ s₁ s₂ : ℝ) :
    densityEvol (densityEvol ρ₀ s₁) s₂ = densityEvol ρ₀ (s₁ + s₂) := by
  unfold densityEvol
  rw [mul_assoc, ← Real.exp_add]; ring_nf


/-- Total density from multiple branches (with interference) -/
noncomputable def totalDensity (branches : Fin n → ℝ × ℝ) (hbar : ℝ) : ℝ :=
  Complex.normSq (Finset.sum Finset.univ (fun j =>
    (Real.sqrt (branches j).1 : ℂ) *
    Complex.exp (Complex.I * ((branches j).2 / hbar))))


/-- Total density is non-negative -/
theorem totalDensity_nonneg (branches : Fin n → ℝ × ℝ) (hbar : ℝ) :
    0 ≤ totalDensity branches hbar := by
  exact Complex.normSq_nonneg _


/-- [Section: ## Section 4: Multi-Branch Density Estimation
Given measurements of |ψ|² = |Σ_j ψ_j|², estimate the branch densities ρ_j.] -/
theorem single_branch_density (ρ φ hbar : ℝ) (hρ : 0 ≤ ρ) :
    totalDensity (fun (_ : Fin 1) => (ρ, φ)) hbar = ρ := by
  unfold totalDensity; norm_num [ Complex.normSq, Complex.exp_re, Complex.exp_im ] ; ring;
  rw [ ← mul_add, Real.cos_sq_add_sin_sq, mul_one, Real.sq_sqrt hρ ]


/-- Tropical density: log of density in the ℏ→0 limit -/
noncomputable def tropicalDensityLimit [NeZero n] (actions : Fin n → ℝ) : ℝ :=
  -(Finset.inf' Finset.univ Finset.univ_nonempty actions)


/-- Boltzmann weight sum -/
noncomputable def boltzmannSum (actions : Fin n → ℝ) (β : ℝ) : ℝ :=
  Finset.sum Finset.univ (fun j => Real.exp (-β * actions j))


/-- [Section: ## Section 5: Tropical Density in the Classical Limit
As ℏ → 0, the density concentrates on the minimum-action path.
This is the tropical projection of the density.] -/
theorem boltzmannSum_pos [NeZero n] (actions : Fin n → ℝ) (β : ℝ) :
    0 < boltzmannSum actions β := by
  exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty


end
