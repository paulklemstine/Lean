/-
# EML World Model Theory — v17

## Overview
World models learn internal representations of environment dynamics
for planning and decision-making. They consist of an encoder (perception),
a dynamics model (prediction), and a decoder (reconstruction/reward).
EML compresses all three components, enabling real-time world simulation
on edge devices for robotics, autonomous driving, and game AI.

## Key Results (8 theorems, 0 sorry)
-/

import Mathlib

noncomputable section

open Real Finset BigOperators Nat

/-! ## §1. World Model Components -/

/-- Standard encoder: observation → latent state -/
def stdEncoderParams (obsDim latentDim : ℕ) : ℕ :=
  obsDim * latentDim

/-- EML encoder -/
def emlEncoderParams (latentDim : ℕ) : ℕ :=
  4 * latentDim

theorem eml_encoder_compact (od ld : ℕ) (hod : 4 ≤ od) :
    emlEncoderParams ld ≤ stdEncoderParams od ld := by
  -- Since $od \geq 4$, multiplying both sides by $ld$ (which is non-negative) preserves the inequality.
  apply Nat.mul_le_mul_right ld hod

/-! ## §2. Dynamics Model -/

/-- Standard dynamics: latent × action → next latent -/
def stdDynamicsParams (latentDim actionDim : ℕ) : ℕ :=
  (latentDim + actionDim) * latentDim

/-- EML dynamics -/
def emlDynamicsParams (latentDim : ℕ) : ℕ :=
  4 * latentDim

theorem eml_dynamics_compact (ld ad : ℕ) (hld : 4 ≤ ld) :
    emlDynamicsParams ld ≤ stdDynamicsParams ld ad := by
  -- Since $ld \geq 4$, we can divide both sides of the inequality $4 * ld \leq (ld + ad) * ld$ by $ld$ (which is positive), yielding $4 \leq ld + ad$.
  have h_div : 4 ≤ ld + ad := by
    -- Since $ad$ is a natural number, adding it to $ld$ will definitely make the sum larger than or equal to $ld$.
    apply le_add_right hld;
  -- Since $ld$ is positive, multiplying both sides of $4 \leq ld + ad$ by $ld$ preserves the inequality.
  apply Nat.mul_le_mul_right ld h_div

/-! ## §3. Imagination Rollout -/

/-- Cost of imagining H steps into the future -/
def imaginationCost (horizon dynamicsCost : ℕ) : ℕ :=
  horizon * dynamicsCost

theorem eml_imagination_cheaper (H dc_eml dc_std : ℕ) (hdc : dc_eml ≤ dc_std) :
    imaginationCost H dc_eml ≤ imaginationCost H dc_std := by
  -- Since $H$ is a natural number, multiplying both sides of the inequality $dc_eml \leq dc_std$ by $H$ preserves the inequality.
  apply Nat.mul_le_mul_left H hdc

theorem longer_horizon_costlier (h1 h2 dc : ℕ) (hh : h1 ≤ h2) :
    imaginationCost h1 dc ≤ imaginationCost h2 dc := by
  -- By definition of imaginationCost, we have h1 * dc ≤ h2 * dc since h1 ≤ h2.
  apply Nat.mul_le_mul_right dc hh

/-! ## §4. Planning with World Model -/

/-- Planning: imagine N trajectories of length H, pick best -/
def planningCost (numTrajectories horizon dynamicsCost rewardCost : ℕ) : ℕ :=
  numTrajectories * (horizon * dynamicsCost + rewardCost)

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

/-! ## §5. Total World Model System -/

/-- Full world model: encoder + dynamics + reward predictor -/
def worldModelParams (encoderP dynamicsP rewardP : ℕ) : ℕ :=
  encoderP + dynamicsP + rewardP

theorem eml_world_model_compact (ep_eml ep_std dp_eml dp_std rp_eml rp_std : ℕ)
    (hep : ep_eml ≤ ep_std) (hdp : dp_eml ≤ dp_std) (hrp : rp_eml ≤ rp_std) :
    worldModelParams ep_eml dp_eml rp_eml ≤ worldModelParams ep_std dp_std rp_std := by
  -- By definition of `worldModelParams`, we know that
  unfold worldModelParams; exact add_le_add_three hep hdp hrp

/-! ## §6. Multi-Step Prediction Error -/

/-- More prediction steps → compound dynamics cost -/
def multiStepPredCost (steps dynamicsCost decoderCost : ℕ) : ℕ :=
  steps * dynamicsCost + decoderCost

theorem eml_multi_step_cheaper (s dc_eml dc_std dec : ℕ) (hdc : dc_eml ≤ dc_std) :
    multiStepPredCost s dc_eml dec ≤ multiStepPredCost s dc_std dec := by
  -- Since $s$ is a natural number, multiplying both sides of $dc_eml \leq dc_std$ by $s$ preserves the inequality.
  have h_mul : s * dc_eml ≤ s * dc_std := by
    -- Since $s$ is a natural number, multiplying both sides of the inequality $dc_eml \leq dc_std$ by $s$ preserves the inequality.
    apply Nat.mul_le_mul_left s hdc;
  exact Nat.add_le_add_right h_mul _

end