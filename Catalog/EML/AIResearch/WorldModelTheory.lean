/-! # CatalogBuild.EML.AIResearch.WorldModelTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 11
-/

import Mathlib

noncomputable section

/-- [Section: ## §1. World Model Components] -/
theorem eml_encoder_compact (od ld : ℕ) (hod : 4 ≤ od) :
    emlEncoderParams ld ≤ stdEncoderParams od ld := by
  -- Since $od \geq 4$, multiplying both sides by $ld$ (which is non-negative) preserves the inequality.
  apply Nat.mul_le_mul_right ld hod


/-- Standard dynamics: latent × action → next latent -/
def stdDynamicsParams (latentDim actionDim : ℕ) : ℕ :=
  (latentDim + actionDim) * latentDim


/-- EML dynamics -/
def emlDynamicsParams (latentDim : ℕ) : ℕ :=
  4 * latentDim


/-- [Section: ## §2. Dynamics Model] -/
theorem eml_dynamics_compact (ld ad : ℕ) (hld : 4 ≤ ld) :
    emlDynamicsParams ld ≤ stdDynamicsParams ld ad := by
  -- Since $ld \geq 4$, we can divide both sides of the inequality $4 * ld \leq (ld + ad) * ld$ by $ld$ (which is positive), yielding $4 \leq ld + ad$.
  have h_div : 4 ≤ ld + ad := by
    -- Since $ad$ is a natural number, adding it to $ld$ will definitely make the sum larger than or equal to $ld$.
    apply le_add_right hld;
  -- Since $ld$ is positive, multiplying both sides of $4 \leq ld + ad$ by $ld$ preserves the inequality.
  apply Nat.mul_le_mul_right ld h_div


/-- Cost of imagining H steps into the future -/
def imaginationCost (horizon dynamicsCost : ℕ) : ℕ :=
  horizon * dynamicsCost


/-- [Section: ## §3. Imagination Rollout] -/
theorem eml_imagination_cheaper (H dc_eml dc_std : ℕ) (hdc : dc_eml ≤ dc_std) :
    imaginationCost H dc_eml ≤ imaginationCost H dc_std := by
  -- Since $H$ is a natural number, multiplying both sides of the inequality $dc_eml \leq dc_std$ by $H$ preserves the inequality.
  apply Nat.mul_le_mul_left H hdc


/-- Planning: imagine N trajectories of length H, pick best -/
def planningCost (numTrajectories horizon dynamicsCost rewardCost : ℕ) : ℕ :=
  numTrajectories * (horizon * dynamicsCost + rewardCost)


/-- [Section: ## §4. Planning with World Model] -/
theorem eml_planning_cheaper (nt H dc_eml dc_std rc : ℕ) (hdc : dc_eml ≤ dc_std) :
    planningCost nt H dc_eml rc ≤ planningCost nt H dc_std rc := by
  -- Since $dc_eml \leq dc_std$, multiplying both sides by $H$ (which is positive) preserves the inequality.
  have h_mul : H * dc_eml ≤ H * dc_std := by
    -- Since $H$ is a natural number, multiplying both sides of the inequality $dc_eml \leq dc_std$ by $H$ preserves the inequality.
    apply Nat.mul_le_mul_left H hdc;
  -- Since $H * dc_eml \leq H * dc_std$, adding $rc$ to both sides gives $H * dc_eml + rc \leq H * dc_std + rc$.
  have h_add : H * dc_eml + rc ≤ H * dc_std + rc := by
    grind +revert;
  -- Since $nt$ is a natural number, multiplying both sides of the inequality $H * dc_eml + rc \leq H * dc_std + rc$ by $nt$ preserves the inequality.
  apply Nat.mul_le_mul_left nt h_add


/-- Full world model: encoder + dynamics + reward predictor -/
def worldModelParams (encoderP dynamicsP rewardP : ℕ) : ℕ :=
  encoderP + dynamicsP + rewardP


/-- More prediction steps → compound dynamics cost -/
def multiStepPredCost (steps dynamicsCost decoderCost : ℕ) : ℕ :=
  steps * dynamicsCost + decoderCost


/-- [Section: ## §6. Multi-Step Prediction Error] -/
theorem eml_multi_step_cheaper (s dc_eml dc_std dec : ℕ) (hdc : dc_eml ≤ dc_std) :
    multiStepPredCost s dc_eml dec ≤ multiStepPredCost s dc_std dec := by
  -- Since $s$ is a natural number, multiplying both sides of $dc_eml \leq dc_std$ by $s$ preserves the inequality.
  have h_mul : s * dc_eml ≤ s * dc_std := by
    -- Since $s$ is a natural number, multiplying both sides of the inequality $dc_eml \leq dc_std$ by $s$ preserves the inequality.
    apply Nat.mul_le_mul_left s hdc;
  exact Nat.add_le_add_right h_mul _


end
