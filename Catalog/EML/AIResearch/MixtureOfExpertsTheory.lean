import Mathlib

/-! # CatalogBuild.EML.AIResearch.MixtureOfExpertsTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 24
-/

noncomputable section

/-- Standard MoE expert: dense layer with d_model × d_ff parameters -/
def stdExpertParams (d_model d_ff : ℕ) : ℕ := 2 * d_model * d_ff

/-- EML expert: 4 parameters per output dimension -/
def emlExpertParams (d_ff : ℕ) : ℕ := 4 * d_ff

/-- [Section: # CatalogBuild.EML.AIResearch.MixtureOfExpertsTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 24] -/
theorem eml_expert_compact (d_model d_ff : ℕ) (hd : 2 ≤ d_model) :
    emlExpertParams d_ff ≤ stdExpertParams d_model d_ff := by
  unfold emlExpertParams stdExpertParams; nlinarith

/-- Total MoE model: numExperts × expert_params + router -/
def stdMoEParams (numExperts d_model d_ff : ℕ) : ℕ :=
  numExperts * stdExpertParams d_model d_ff + d_model * numExperts

/-- [Section: # CatalogBuild.EML.AIResearch.MixtureOfExpertsTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 24] -/
def emlMoEParams (numExperts d_model d_ff : ℕ) : ℕ :=
  numExperts * emlExpertParams d_ff + d_model * numExperts

theorem eml_moe_total_savings (n dm df : ℕ) (hd : 2 ≤ dm) :
    emlMoEParams n dm df ≤ stdMoEParams n dm df := by
  unfold emlMoEParams stdMoEParams
  have : emlExpertParams df ≤ stdExpertParams dm df := eml_expert_compact dm df hd
  exact Nat.add_le_add_right (Nat.mul_le_mul_left n this) _

/-- Standard router: d_model → numExperts linear projection -/
def stdRouterParams (d_model numExperts : ℕ) : ℕ := d_model * numExperts

/-- EML router: uses 4-param EML neurons -/
def emlRouterParams (numExperts : ℕ) : ℕ := 4 * numExperts

theorem eml_router_compact (d_model numExperts : ℕ) (hd : 4 ≤ d_model) :
    emlRouterParams numExperts ≤ stdRouterParams d_model numExperts := by
  unfold emlRouterParams stdRouterParams
  calc 4 * numExperts = numExperts * 4 := by ring
    _ ≤ numExperts * d_model := Nat.mul_le_mul_left numExperts hd
    _ = d_model * numExperts := by ring

/-- Load balancing auxiliary loss: sum of (fraction routed × fraction capacity used) -/
def loadBalanceLoss (fracRouted fracCapacity : ℝ) : ℝ := fracRouted * fracCapacity

theorem load_balance_nonneg (fr fc : ℝ) (hfr : 0 ≤ fr) (hfc : 0 ≤ fc) :
    0 ≤ loadBalanceLoss fr fc := by
  unfold loadBalanceLoss; exact mul_nonneg hfr hfc

theorem perfect_balance (n : ℕ) (hn : 0 < n) :
    loadBalanceLoss (1 / ↑n) (1 / ↑n) = 1 / ↑(n * n) := by
  unfold loadBalanceLoss
  push_cast
  field_simp

/-- Active parameters per token with top-k routing -/
def activeParamsPerToken (expertParams k : ℕ) : ℕ := k * expertParams

theorem fewer_experts_cheaper (ep k1 k2 : ℕ) (hk : k1 ≤ k2) :
    activeParamsPerToken ep k1 ≤ activeParamsPerToken ep k2 := by
  unfold activeParamsPerToken; exact Nat.mul_le_mul_right ep hk

theorem eml_active_cheaper (ep_eml ep_std k : ℕ) (hp : ep_eml ≤ ep_std) :
    activeParamsPerToken ep_eml k ≤ activeParamsPerToken ep_std k := by
  unfold activeParamsPerToken; exact Nat.mul_le_mul_left k hp

/-- Capacity factor: max tokens per expert = CF × (tokens / numExperts) -/
def expertCapacity (totalTokens numExperts capacityFactor : ℕ) : ℕ :=
  capacityFactor * totalTokens / numExperts

theorem higher_capacity_more_tokens (t n cf1 cf2 : ℕ) (hcf : cf1 ≤ cf2) :
    expertCapacity t n cf1 ≤ expertCapacity t n cf2 := by
  unfold expertCapacity
  exact Nat.div_le_div_right (Nat.mul_le_mul_right t hcf)

/-- Specialization score: higher with more training -/
def specialization (baseScore learnRate : ℝ) (steps : ℕ) : ℝ :=
  baseScore + learnRate * ↑steps

theorem more_training_more_specialized (b lr : ℝ) (s1 s2 : ℕ) (hlr : 0 ≤ lr) (hs : s1 ≤ s2) :
    specialization b lr s1 ≤ specialization b lr s2 := by
  unfold specialization; nlinarith [Nat.cast_le (α := ℝ).mpr hs]

/-- All-to-all communication cost for distributed MoE -/
def allToAllCost (numGPUs tokensPerGPU expertSize : ℕ) : ℕ :=
  numGPUs * tokensPerGPU * expertSize

/-- Fine-grained MoE: more experts, each smaller -/
def fineGrainedMoEParams (numExperts paramsPerExpert routerParams : ℕ) : ℕ :=
  numExperts * paramsPerExpert + routerParams

theorem eml_fine_grained_advantage (n pe_eml pe_std r_eml r_std : ℕ)
    (hp : pe_eml ≤ pe_std) (hr : r_eml ≤ r_std) :
    fineGrainedMoEParams n pe_eml r_eml ≤ fineGrainedMoEParams n pe_std r_std := by
  unfold fineGrainedMoEParams
  exact Nat.add_le_add (Nat.mul_le_mul_left n hp) hr

/-- Cost to merge k experts into one -/
def expertMergeCost (k expertParams : ℕ) : ℕ := k * expertParams

theorem eml_merge_cheaper (k ep_eml ep_std : ℕ) (hp : ep_eml ≤ ep_std) :
    expertMergeCost k ep_eml ≤ expertMergeCost k ep_std := by
  unfold expertMergeCost; exact Nat.mul_le_mul_left k hp

end
