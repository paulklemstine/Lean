/-
# EML Federated Fine-Tuning Theory — v18

## Overview
Federated fine-tuning enables distributed model adaptation without
sharing raw data. Each client computes local gradients and sends
model updates to a central server. Communication cost is proportional
to model size, making EML compression directly reduce bandwidth.

## Key Results (7 theorems, 0 sorry)
-/

import Mathlib

noncomputable section

open Real Finset BigOperators Nat

/-! ## §1. Local Training Cost -/

/-- Cost of local fine-tuning at one client -/
def localFineTuneCost (modelParams localSteps batchSize : ℕ) : ℕ :=
  localSteps * modelParams * batchSize

theorem eml_local_cheaper (mp_eml mp_std ls bs : ℕ) (hmp : mp_eml ≤ mp_std) :
    localFineTuneCost mp_eml ls bs ≤ localFineTuneCost mp_std ls bs := by
  unfold localFineTuneCost; gcongr

/-! ## §2. Communication Cost -/

/-- Communication cost per round: each client sends model update -/
def commCostPerRound (numClients modelParams : ℕ) : ℕ :=
  numClients * modelParams

theorem eml_comm_cheaper (nc mp_eml mp_std : ℕ) (hmp : mp_eml ≤ mp_std) :
    commCostPerRound nc mp_eml ≤ commCostPerRound nc mp_std := by
  apply Nat.mul_le_mul_left nc hmp

theorem more_clients_more_comm (c1 c2 mp : ℕ) (hc : c1 ≤ c2) :
    commCostPerRound c1 mp ≤ commCostPerRound c2 mp := by
  apply Nat.mul_le_mul_right mp hc

/-! ## §3. Multi-Round Federation -/

/-- Total federated fine-tuning cost over R rounds -/
def fedFineTuneTotalCost (numRounds localCost commCost : ℕ) : ℕ :=
  numRounds * (localCost + commCost)

theorem eml_fed_total_cheaper (nr lc_eml lc_std cc_eml cc_std : ℕ)
    (hlc : lc_eml ≤ lc_std) (hcc : cc_eml ≤ cc_std) :
    fedFineTuneTotalCost nr lc_eml cc_eml ≤ fedFineTuneTotalCost nr lc_std cc_std := by
  unfold fedFineTuneTotalCost; gcongr

theorem more_rounds_costlier_fed (r1 r2 lc cc : ℕ) (hr : r1 ≤ r2) :
    fedFineTuneTotalCost r1 lc cc ≤ fedFineTuneTotalCost r2 lc cc := by
  apply Nat.mul_le_mul_right _ hr

/-! ## §4. Aggregation at Server -/

/-- Server aggregation cost: average N client updates -/
def aggregationCost (numClients modelParams : ℕ) : ℕ :=
  numClients * modelParams

theorem eml_aggregation_cheaper (nc mp_eml mp_std : ℕ) (hmp : mp_eml ≤ mp_std) :
    aggregationCost nc mp_eml ≤ aggregationCost nc mp_std := by
  apply Nat.mul_le_mul_left nc hmp

end
