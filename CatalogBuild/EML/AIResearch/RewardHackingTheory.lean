/-! # CatalogBuild.EML.AIResearch.RewardHackingTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 10
-/

import Mathlib

noncomputable section

/-- Cost of evaluating K reward models on a response -/
def rewardEnsembleCost (numRewardModels perModelCost : ℕ) : ℕ :=
  numRewardModels * perModelCost


/-- [Section: ## §1. Reward Ensemble Cost] -/
theorem eml_reward_ensemble_cheaper (k pmc_eml pmc_std : ℕ) (hpmc : pmc_eml ≤ pmc_std) :
    rewardEnsembleCost k pmc_eml ≤ rewardEnsembleCost k pmc_std := by
  apply Nat.mul_le_mul_left k hpmc


/-- [Section: # CatalogBuild.EML.AIResearch.RewardHackingTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 10] -/
theorem more_reward_models_costlier (k1 k2 pmc : ℕ) (hk : k1 ≤ k2) :
    rewardEnsembleCost k1 pmc ≤ rewardEnsembleCost k2 pmc := by
  apply Nat.mul_le_mul_right pmc hk


/-- Cost of monitoring reward over T training steps -/
def rewardMonitorCost (numSteps ensembleCost : ℕ) : ℕ :=
  numSteps * ensembleCost


/-- [Section: ## §2. Reward Monitoring] -/
theorem eml_monitoring_cheaper (ns ec_eml ec_std : ℕ) (hec : ec_eml ≤ ec_std) :
    rewardMonitorCost ns ec_eml ≤ rewardMonitorCost ns ec_std := by
  apply Nat.mul_le_mul_left ns hec


/-- Cost of automated red-teaming: generate adversarial prompts + evaluate -/
def redTeamCost (numPrompts genCost evalCost : ℕ) : ℕ :=
  numPrompts * (genCost + evalCost)


/-- [Section: ## §3. Red-Teaming Cost] -/
theorem eml_redteam_cheaper (np gc_eml gc_std ec_eml ec_std : ℕ)
    (hgc : gc_eml ≤ gc_std) (hec : ec_eml ≤ ec_std) :
    redTeamCost np gc_eml ec_eml ≤ redTeamCost np gc_std ec_std := by
  unfold redTeamCost; gcongr


/-- [Section: ## §4. KL Penalty Computation] -/
theorem eml_kl_cheaper (nt pfc_eml pfc_std rfc_eml rfc_std : ℕ)
    (hpfc : pfc_eml ≤ pfc_std) (hrfc : rfc_eml ≤ rfc_std) :
    klPenaltyCost nt pfc_eml rfc_eml ≤ klPenaltyCost nt pfc_std rfc_std := by
  unfold klPenaltyCost; gcongr


/-- Total safety monitoring: reward ensemble + red-team + KL penalty -/
def safetyPipelineCost (rewardC redteamC klC : ℕ) : ℕ :=
  rewardC + redteamC + klC


/-- [Section: ## §5. Safety Pipeline] -/
theorem eml_safety_pipeline_cheaper (rc_eml rc_std rtc_eml rtc_std kc_eml kc_std : ℕ)
    (hrc : rc_eml ≤ rc_std) (hrtc : rtc_eml ≤ rtc_std) (hkc : kc_eml ≤ kc_std) :
    safetyPipelineCost rc_eml rtc_eml kc_eml ≤ safetyPipelineCost rc_std rtc_std kc_std := by
  unfold safetyPipelineCost; omega


end
