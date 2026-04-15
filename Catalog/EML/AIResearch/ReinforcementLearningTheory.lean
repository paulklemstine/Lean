/-! # CatalogBuild.EML.AIResearch.ReinforcementLearningTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 18
-/

import Mathlib

noncomputable section

/-- Standard value function: state → scalar -/
def stdValueParams (stateDim hiddenDim numLayers : ℕ) : ℕ :=
  stateDim * hiddenDim + numLayers * hiddenDim * hiddenDim + hiddenDim


/-- EML value function -/
def emlValueParams (hiddenDim numLayers : ℕ) : ℕ :=
  4 * hiddenDim + numLayers * 4 * hiddenDim + 4


theorem eml_value_compact (sd hd nL : ℕ) (hs : 4 ≤ sd) (hh : 4 ≤ hd) :
    emlValueParams hd nL ≤ stdValueParams sd hd nL := by
  unfold emlValueParams stdValueParams
  have h1 : 4 * hd ≤ sd * hd := Nat.mul_le_mul_right hd hs
  have h2 : nL * 4 ≤ nL * hd := Nat.mul_le_mul_left nL hh
  have h3 : nL * 4 * hd ≤ nL * hd * hd := Nat.mul_le_mul_right hd h2
  have h4 : 4 ≤ hd := hh
  omega


/-- Discounted return: γ^k * r -/
def discountedReward (gamma reward : ℝ) (step : ℕ) : ℝ := gamma ^ step * reward


theorem discount_decays (g r : ℝ) (k1 k2 : ℕ) (hg0 : 0 ≤ g) (hg1 : g ≤ 1)
    (hr : 0 ≤ r) (hk : k1 ≤ k2) :
    discountedReward g r k2 ≤ discountedReward g r k1 := by
  unfold discountedReward
  exact mul_le_mul_of_nonneg_right (pow_le_pow_of_le_one hg0 hg1 hk) hr


theorem no_discount_full_reward (r : ℝ) (k : ℕ) :
    discountedReward 1 r k = r := by
  unfold discountedReward; simp


theorem zero_discount_immediate (r : ℝ) :
    discountedReward 0 r 0 = r := by
  unfold discountedReward; simp


/-- Standard actor-critic: separate policy + value networks -/
def stdActorCriticParams (policyP valueP : ℕ) : ℕ := policyP + valueP


theorem eml_ac_compact (pp_eml pp_std vp_eml vp_std : ℕ)
    (hp : pp_eml ≤ pp_std) (hv : vp_eml ≤ vp_std) :
    stdActorCriticParams pp_eml vp_eml ≤ stdActorCriticParams pp_std vp_std := by
  unfold stdActorCriticParams; omega


/-- Replay buffer memory: transitions × (state + action + reward + next_state) -/
def replayMemory (bufferSize stateDim actionDim : ℕ) : ℕ :=
  bufferSize * (2 * stateDim + actionDim + 1)


theorem larger_buffer_more_memory (b1 b2 sd ad : ℕ) (hb : b1 ≤ b2) :
    replayMemory b1 sd ad ≤ replayMemory b2 sd ad := by
  unfold replayMemory; exact Nat.mul_le_mul_right _ hb


theorem more_visits_less_bonus (c : ℝ) (n1 n2 : ℕ) (hc : 0 < c) (hn1 : 0 < n1) (hn : n1 ≤ n2) :
    explorationBonus c n2 ≤ explorationBonus c n1 := by
  unfold explorationBonus
  exact div_le_div_of_nonneg_left (le_of_lt hc) (by positivity) (Real.sqrt_le_sqrt (by exact_mod_cast hn))


/-- Communication cost between agents -/
def maCommCost (numAgents messageDim : ℕ) : ℕ := numAgents * numAgents * messageDim


theorem eml_ma_comm_cheaper (n md_eml md_std : ℕ) (hm : md_eml ≤ md_std) :
    maCommCost n md_eml ≤ maCommCost n md_std := by
  unfold maCommCost; exact Nat.mul_le_mul_left (n * n) hm


/-- World model: predict next state from current state + action -/
def stdWorldModelParams (stateDim actionDim hiddenDim : ℕ) : ℕ :=
  (stateDim + actionDim) * hiddenDim + hiddenDim * stateDim


def emlWorldModelParams (hiddenDim stateDim : ℕ) : ℕ :=
  4 * hiddenDim + 4 * stateDim


theorem eml_world_model_compact (sd ad hd : ℕ) (hsa : 4 ≤ sd + ad) (hh : 4 ≤ hd) :
    emlWorldModelParams hd sd ≤ stdWorldModelParams sd ad hd := by
  unfold emlWorldModelParams stdWorldModelParams
  have h1 : 4 * hd ≤ (sd + ad) * hd := Nat.mul_le_mul_right hd hsa
  have h2 : 4 * sd ≤ hd * sd := Nat.mul_le_mul_right sd hh
  omega


theorem zero_potential_preserves (r gamma : ℝ) :
    shapedReward r gamma 0 0 = r := by
  unfold shapedReward; ring


end
