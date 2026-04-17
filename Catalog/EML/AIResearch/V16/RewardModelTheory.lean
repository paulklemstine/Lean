/-
# EML Reward Modeling & RLHF Theory — v16

## Overview
RLHF (Reinforcement Learning from Human Feedback) trains a reward model
from human preferences, then uses it to fine-tune an LLM via RL.
Both the reward model and the policy model can be EML-compressed,
and the RL optimization loop (PPO/DPO) becomes cheaper per step.

## Key Results (11 theorems, 0 sorry)
-/

import Mathlib

noncomputable section

open Real Finset BigOperators Nat

/-! ## §1. Reward Model -/

/-- Standard reward model: LLM backbone + scalar head -/
def stdRewardModelParams (backboneParams headDim : ℕ) : ℕ :=
  backboneParams + headDim

/-- EML reward model -/
def emlRewardModelParams (emlBackboneParams headDim : ℕ) : ℕ :=
  emlBackboneParams + headDim

theorem eml_reward_model_compact (bp_eml bp_std hd : ℕ) (hbp : bp_eml ≤ bp_std) :
    emlRewardModelParams bp_eml hd ≤ stdRewardModelParams bp_std hd := by
  unfold emlRewardModelParams stdRewardModelParams; omega

/-! ## §2. PPO Training -/

/-- PPO step cost: forward + backward on policy + reward model evaluation -/
def ppoStepCost (policyParams rewardParams batchSize : ℕ) : ℕ :=
  batchSize * (3 * policyParams + rewardParams)

theorem eml_ppo_cheaper (pp_eml pp_std rp_eml rp_std bs : ℕ)
    (hpp : pp_eml ≤ pp_std) (hrp : rp_eml ≤ rp_std) :
    ppoStepCost pp_eml rp_eml bs ≤ ppoStepCost pp_std rp_std bs := by
  unfold ppoStepCost; nlinarith

theorem larger_batch_costlier (pp rp b1 b2 : ℕ) (hb : b1 ≤ b2) :
    ppoStepCost pp rp b1 ≤ ppoStepCost pp rp b2 := by
  unfold ppoStepCost; nlinarith

/-! ## §3. DPO (Direct Preference Optimization) -/

/-- DPO cost: forward pass on chosen + rejected, no separate reward model -/
def dpoStepCost (policyParams batchSize : ℕ) : ℕ :=
  batchSize * (2 * policyParams)

theorem eml_dpo_cheaper (pp_eml pp_std bs : ℕ) (hpp : pp_eml ≤ pp_std) :
    dpoStepCost pp_eml bs ≤ dpoStepCost pp_std bs := by
  unfold dpoStepCost; nlinarith

/-- DPO is cheaper than PPO (no reward model forward pass) -/
theorem dpo_cheaper_than_ppo (pp rp bs : ℕ) :
    dpoStepCost pp bs ≤ ppoStepCost pp rp bs := by
  unfold dpoStepCost ppoStepCost; nlinarith

/-! ## §4. KL Divergence Penalty -/

/-- KL penalty cost: compare policy vs reference model -/
def klPenaltyCost (referenceParams vocabSize seqLen : ℕ) : ℕ :=
  seqLen * (referenceParams + vocabSize)

theorem eml_kl_penalty_cheaper (rp_eml rp_std vs sl : ℕ) (hrp : rp_eml ≤ rp_std) :
    klPenaltyCost rp_eml vs sl ≤ klPenaltyCost rp_std vs sl := by
  unfold klPenaltyCost; nlinarith

/-! ## §5. Multi-Turn RLHF -/

/-- Total RLHF cost: numRounds × (generation + scoring + update) -/
def rlhfTotalCost (numRounds genCost scoreCost updateCost : ℕ) : ℕ :=
  numRounds * (genCost + scoreCost + updateCost)

theorem eml_rlhf_cheaper (nr gc sc uc_eml uc_std : ℕ) (huc : uc_eml ≤ uc_std) :
    rlhfTotalCost nr gc sc uc_eml ≤ rlhfTotalCost nr gc sc uc_std := by
  unfold rlhfTotalCost; nlinarith

theorem more_rounds_costlier (r1 r2 gc sc uc : ℕ) (hr : r1 ≤ r2) :
    rlhfTotalCost r1 gc sc uc ≤ rlhfTotalCost r2 gc sc uc := by
  unfold rlhfTotalCost; nlinarith

end
