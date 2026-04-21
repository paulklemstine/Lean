/-! # CatalogBuild.EML.AIResearch.EnergyBasedModelTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 16
-/

import Mathlib

noncomputable section

/-- The Boltzmann factor: exp(-E/T) for energy E and temperature T. -/
def boltzmannFactor (energy temperature : ℝ) : ℝ :=
  Real.exp (- energy / temperature)


/-- [Section: ## §1. Boltzmann Distribution] -/
theorem boltzmann_factor_pos (E T : ℝ) : 0 < boltzmannFactor E T :=
  Real.exp_pos _


theorem boltzmann_lower_energy_higher_prob (E₁ E₂ T : ℝ) (hT : 0 < T) (hE : E₁ < E₂) :
    boltzmannFactor E₂ T < boltzmannFactor E₁ T := by
  unfold boltzmannFactor
  apply Real.exp_strictMono
  have h1 : -E₂ < -E₁ := by linarith
  exact div_lt_div_of_pos_right h1 hT


theorem boltzmann_zero_energy (T : ℝ) (_ : T ≠ 0) :
    boltzmannFactor 0 T = 1 := by
  simp [boltzmannFactor]


/-- Standard energy network parameters -/
def stdEnergyNetParams (d_input numLayers d_hidden : ℕ) : ℕ :=
  d_input * d_hidden + numLayers * (d_hidden * d_hidden) + d_hidden


/-- EML energy network parameters -/
def emlEnergyNetParams (_d_input numLayers d_hidden : ℕ) : ℕ :=
  4 * d_hidden + numLayers * (4 * d_hidden) + d_hidden


/-- [Section: ## §2. Energy Function Parameterization] -/
theorem eml_energy_net_compact (di nL dh : ℕ) (hdi : 4 ≤ di) (hdh : 4 ≤ dh) :
    emlEnergyNetParams di nL dh ≤ stdEnergyNetParams di nL dh := by
  unfold emlEnergyNetParams stdEnergyNetParams
  have h1 : 4 * dh ≤ di * dh := Nat.mul_le_mul_right dh hdi
  have h2 : 4 * dh ≤ dh * dh := by nlinarith
  nlinarith


/-- Total MCMC chain cost -/
def mcmcChainCost (numSteps energyEvalCost : ℕ) : ℕ :=
  numSteps * energyEvalCost


/-- [Section: ## §3. MCMC Sampling Cost] -/
theorem eml_mcmc_cheaper (T c_eml c_std : ℕ) (hc : c_eml ≤ c_std) :
    mcmcChainCost T c_eml ≤ mcmcChainCost T c_std := by
  unfold mcmcChainCost; exact Nat.mul_le_mul_left T hc


theorem more_steps_costlier (t1 t2 ec : ℕ) (ht : t1 ≤ t2) :
    mcmcChainCost t1 ec ≤ mcmcChainCost t2 ec := by
  unfold mcmcChainCost; exact Nat.mul_le_mul_right ec ht


/-- CD-k cost: k MCMC steps + gradient computation -/
def cdkCost (k energyEvalCost gradCost : ℕ) : ℕ :=
  k * energyEvalCost + gradCost


/-- [Section: ## §4. Contrastive Divergence] -/
theorem eml_cdk_cheaper (k ec_eml ec_std gc_eml gc_std : ℕ)
    (hec : ec_eml ≤ ec_std) (hgc : gc_eml ≤ gc_std) :
    cdkCost k ec_eml gc_eml ≤ cdkCost k ec_std gc_std := by
  unfold cdkCost; nlinarith


/-- Score matching objective cost -/
def scoreMatchCost (modelParams batchSize : ℕ) : ℕ :=
  batchSize * (2 * modelParams)


/-- [Section: ## §5. Score Matching] -/
theorem eml_score_match_cheaper (p_eml p_std bs : ℕ) (hp : p_eml ≤ p_std) :
    scoreMatchCost p_eml bs ≤ scoreMatchCost p_std bs := by
  unfold scoreMatchCost; nlinarith


/-- Partition function estimation cost via importance sampling -/
def partitionEstCost (numSamples energyEvalCost : ℕ) : ℕ :=
  numSamples * energyEvalCost


/-- [Section: ## §6. Partition Function Estimation] -/
theorem eml_partition_cheaper (ns ec_eml ec_std : ℕ) (hec : ec_eml ≤ ec_std) :
    partitionEstCost ns ec_eml ≤ partitionEstCost ns ec_std := by
  unfold partitionEstCost; exact Nat.mul_le_mul_left ns hec


end
