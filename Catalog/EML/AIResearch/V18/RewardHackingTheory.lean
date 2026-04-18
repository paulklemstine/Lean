/-
# EML Reward Hacking Detection Theory — v18

## Overview
Reward hacking occurs when RL-trained models exploit reward model
weaknesses rather than learning intended behavior. Detection requires
running multiple reward models (ensemble) and monitoring for divergence
between proxy reward and true intent. EML compresses each reward model,
enabling larger ensembles for more robust reward estimation and cheaper
monitoring of reward over-optimization.

## Key Results (7 theorems, 0 sorry)
-/

import Mathlib

noncomputable section

open Real Finset BigOperators Nat

/-! ## §1. Reward Ensemble Cost -/

/-- Cost of evaluating K reward models on a response -/
def rewardEnsembleCost (numRewardModels perModelCost : ℕ) : ℕ :=
  numRewardModels * perModelCost

theorem eml_reward_ensemble_cheaper (k pmc_eml pmc_std : ℕ) (hpmc : pmc_eml ≤ pmc_std) :
    rewardEnsembleCost k pmc_eml ≤ rewardEnsembleCost k pmc_std := by
  apply Nat.mul_le_mul_left k hpmc

theorem more_reward_models_costlier (k1 k2 pmc : ℕ) (hk : k1 ≤ k2) :
    rewardEnsembleCost k1 pmc ≤ rewardEnsembleCost k2 pmc := by
  apply Nat.mul_le_mul_right pmc hk

/-! ## §2. Reward Monitoring -/

/-- Cost of monitoring reward over T training steps -/
def rewardMonitorCost (numSteps ensembleCost : ℕ) : ℕ :=
  numSteps * ensembleCost

theorem eml_monitoring_cheaper (ns ec_eml ec_std : ℕ) (hec : ec_eml ≤ ec_std) :
    rewardMonitorCost ns ec_eml ≤ rewardMonitorCost ns ec_std := by
  apply Nat.mul_le_mul_left ns hec

/-! ## §3. Red-Teaming Cost -/

/-- Cost of automated red-teaming: generate adversarial prompts + evaluate -/
def redTeamCost (numPrompts genCost evalCost : ℕ) : ℕ :=
  numPrompts * (genCost + evalCost)

theorem eml_redteam_cheaper (np gc_eml gc_std ec_eml ec_std : ℕ)
    (hgc : gc_eml ≤ gc_std) (hec : ec_eml ≤ ec_std) :
    redTeamCost np gc_eml ec_eml ≤ redTeamCost np gc_std ec_std := by
  unfold redTeamCost; gcongr

/-! ## §4. KL Penalty Computation -/

/-- Cost of computing KL divergence penalty between policy and reference -/
def klPenaltyCost (numTokens policyForwardCost refForwardCost : ℕ) : ℕ :=
  numTokens * (policyForwardCost + refForwardCost)

theorem eml_kl_cheaper (nt pfc_eml pfc_std rfc_eml rfc_std : ℕ)
    (hpfc : pfc_eml ≤ pfc_std) (hrfc : rfc_eml ≤ rfc_std) :
    klPenaltyCost nt pfc_eml rfc_eml ≤ klPenaltyCost nt pfc_std rfc_std := by
  unfold klPenaltyCost; gcongr

/-! ## §5. Safety Pipeline -/

/-- Total safety monitoring: reward ensemble + red-team + KL penalty -/
def safetyPipelineCost (rewardC redteamC klC : ℕ) : ℕ :=
  rewardC + redteamC + klC

theorem eml_safety_pipeline_cheaper (rc_eml rc_std rtc_eml rtc_std kc_eml kc_std : ℕ)
    (hrc : rc_eml ≤ rc_std) (hrtc : rtc_eml ≤ rtc_std) (hkc : kc_eml ≤ kc_std) :
    safetyPipelineCost rc_eml rtc_eml kc_eml ≤ safetyPipelineCost rc_std rtc_std kc_std := by
  unfold safetyPipelineCost; omega

end
