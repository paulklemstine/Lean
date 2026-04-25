/-! # CatalogBuild.EML.AIResearch.FederatedLearningTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 20
-/

import Mathlib

noncomputable section

/-- Per-round communication: each client sends model updates -/
def commCostPerRound (numClients modelParams bitsPerParam : ℕ) : ℕ :=
  numClients * modelParams * bitsPerParam


/-- [Section: # CatalogBuild.EML.AIResearch.FederatedLearningTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 20] -/
theorem eml_comm_cheaper (n p_eml p_std b : ℕ) (hp : p_eml ≤ p_std) :
    commCostPerRound n p_eml b ≤ commCostPerRound n p_std b := by
  unfold commCostPerRound
  have : n * p_eml ≤ n * p_std := Nat.mul_le_mul_left n hp
  exact Nat.mul_le_mul_right b this


/-- Total communication over all rounds -/
def totalCommCost (numRounds numClients modelParams bitsPerParam : ℕ) : ℕ :=
  numRounds * commCostPerRound numClients modelParams bitsPerParam


/-- [Section: # CatalogBuild.EML.AIResearch.FederatedLearningTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 20] -/
theorem eml_total_comm_cheaper (r n p_eml p_std b : ℕ) (hp : p_eml ≤ p_std) :
    totalCommCost r n p_eml b ≤ totalCommCost r n p_std b := by
  unfold totalCommCost
  exact Nat.mul_le_mul_left r (eml_comm_cheaper n p_eml p_std b hp)


/-- FedAvg aggregation cost: sum weighted models -/
def aggregationCost (numClients modelParams : ℕ) : ℕ := numClients * modelParams


/-- [Section: # CatalogBuild.EML.AIResearch.FederatedLearningTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 20] -/
theorem eml_aggregation_cheaper (n p_eml p_std : ℕ) (hp : p_eml ≤ p_std) :
    aggregationCost n p_eml ≤ aggregationCost n p_std := by
  unfold aggregationCost; exact Nat.mul_le_mul_left n hp


/-- DP noise magnitude: proportional to sensitivity / epsilon, sensitivity ∝ √params -/
def dpNoiseMagnitude (params : ℝ) (epsilon : ℝ) : ℝ := Real.sqrt params / epsilon


theorem eml_less_noise (p_eml p_std eps : ℝ) (_hpe : 0 ≤ p_eml)
    (hp : p_eml ≤ p_std) (heps : 0 < eps) :
    dpNoiseMagnitude p_eml eps ≤ dpNoiseMagnitude p_std eps := by
  unfold dpNoiseMagnitude
  exact div_le_div_of_nonneg_right (Real.sqrt_le_sqrt hp) (le_of_lt heps)


theorem higher_epsilon_less_noise (p eps1 eps2 : ℝ) (_hp : 0 ≤ p) (he1 : 0 < eps1)
    (he : eps1 ≤ eps2) :
    dpNoiseMagnitude p eps2 ≤ dpNoiseMagnitude p eps1 := by
  unfold dpNoiseMagnitude
  exact div_le_div_of_nonneg_left (Real.sqrt_nonneg p) he1 he


/-- On-device model memory -/
def clientModelMemory (params bitsPerParam : ℕ) : ℕ := params * bitsPerParam


theorem eml_client_smaller (p_eml p_std b : ℕ) (hp : p_eml ≤ p_std) :
    clientModelMemory p_eml b ≤ clientModelMemory p_std b := by
  unfold clientModelMemory; exact Nat.mul_le_mul_right b hp


/-- With K out of N clients per round -/
def partialCommCost (activeClients modelParams bitsPerParam : ℕ) : ℕ :=
  activeClients * modelParams * bitsPerParam


theorem fewer_clients_cheaper (k1 k2 p b : ℕ) (hk : k1 ≤ k2) :
    partialCommCost k1 p b ≤ partialCommCost k2 p b := by
  unfold partialCommCost
  have : k1 * p ≤ k2 * p := Nat.mul_le_mul_right p hk
  exact Nat.mul_le_mul_right b this


/-- Per-client adapter: small personalization layer -/
def stdAdapterParams (d_model d_adapter : ℕ) : ℕ := 2 * d_model * d_adapter


def emlAdapterParams (d_adapter : ℕ) : ℕ := 4 * d_adapter


theorem eml_adapter_compact (dm da : ℕ) (hm : 2 ≤ dm) :
    emlAdapterParams da ≤ stdAdapterParams dm da := by
  unfold emlAdapterParams stdAdapterParams; nlinarith


/-- Secure aggregation: pairwise key exchange + encrypted updates -/
def secureAggCost (numClients modelParams cryptoOverhead : ℕ) : ℕ :=
  numClients * numClients * cryptoOverhead + numClients * modelParams


theorem eml_secure_agg_cheaper (n p_eml p_std c : ℕ) (hp : p_eml ≤ p_std) :
    secureAggCost n p_eml c ≤ secureAggCost n p_std c := by
  unfold secureAggCost
  have : n * p_eml ≤ n * p_std := Nat.mul_le_mul_left n hp
  omega


/-- Compressed gradient communication -/
def compressedGradSize (modelParams comprRatio : ℕ) : ℕ := modelParams / comprRatio


theorem eml_gradient_smaller (p_eml p_std r : ℕ) (hp : p_eml ≤ p_std) :
    compressedGradSize p_eml r ≤ compressedGradSize p_std r := by
  unfold compressedGradSize; exact Nat.div_le_div_right hp


end
