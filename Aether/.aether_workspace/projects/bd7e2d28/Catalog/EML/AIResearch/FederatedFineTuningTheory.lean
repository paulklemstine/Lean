import Mathlib

/-! # CatalogBuild.EML.AIResearch.FederatedFineTuningTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 6
-/

noncomputable section

/-- Cost of local fine-tuning at one client -/
def localFineTuneCost (modelParams localSteps batchSize : ℕ) : ℕ :=
  localSteps * modelParams * batchSize

/-- [Section: ## §1. Local Training Cost] -/
theorem eml_local_cheaper (mp_eml mp_std ls bs : ℕ) (hmp : mp_eml ≤ mp_std) :
    localFineTuneCost mp_eml ls bs ≤ localFineTuneCost mp_std ls bs := by
  unfold localFineTuneCost; gcongr

theorem more_clients_more_comm (c1 c2 mp : ℕ) (hc : c1 ≤ c2) :
    commCostPerRound c1 mp ≤ commCostPerRound c2 mp := by
  apply Nat.mul_le_mul_right mp hc

/-- Total federated fine-tuning cost over R rounds -/
def fedFineTuneTotalCost (numRounds localCost commCost : ℕ) : ℕ :=
  numRounds * (localCost + commCost)

/-- [Section: ## §3. Multi-Round Federation] -/
theorem eml_fed_total_cheaper (nr lc_eml lc_std cc_eml cc_std : ℕ)
    (hlc : lc_eml ≤ lc_std) (hcc : cc_eml ≤ cc_std) :
    fedFineTuneTotalCost nr lc_eml cc_eml ≤ fedFineTuneTotalCost nr lc_std cc_std := by
  unfold fedFineTuneTotalCost; gcongr

theorem more_rounds_costlier_fed (r1 r2 lc cc : ℕ) (hr : r1 ≤ r2) :
    fedFineTuneTotalCost r1 lc cc ≤ fedFineTuneTotalCost r2 lc cc := by
  apply Nat.mul_le_mul_right _ hr

end