/-! # CatalogBuild.EML.AIResearch.ReinforcementLearning

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 18
-/

import Mathlib

noncomputable section

/-- [Section: ## §1. Policy Network Efficiency] -/
def stdPolicyParams (stateDim actionDim hiddenWidth : ℕ) : ℕ :=
  stateDim * hiddenWidth + hiddenWidth * hiddenWidth + hiddenWidth * actionDim


def emlPolicyParams (stateDim actionDim : ℕ) : ℕ :=
  4 * (stateDim + actionDim)


theorem eml_policy_compact (s a h : ℕ) (hh : 5 ≤ h) :
    emlPolicyParams s a ≤ stdPolicyParams s a h := by
  unfold emlPolicyParams stdPolicyParams; nlinarith


/-- [Section: ## §2. Value Function Approximation] -/
def bellmanError (gamma : ℝ) (k : ℕ) (initError : ℝ) : ℝ := gamma ^ k * initError


theorem bellman_contracts (gamma initErr : ℝ) (k1 k2 : ℕ)
    (hg0 : 0 ≤ gamma) (hg1 : gamma ≤ 1) (he : 0 ≤ initErr) (hk : k1 ≤ k2) :
    bellmanError gamma k2 initErr ≤ bellmanError gamma k1 initErr := by
  unfold bellmanError
  exact mul_le_mul_of_nonneg_right (pow_le_pow_of_le_one hg0 hg1 hk) he


def emlValueConvergence (d w n : ℕ) : ℝ := Real.sqrt (↑(4 * d * w) / ↑n)

def stdValueConvergence (d w n : ℕ) : ℝ := Real.sqrt (↑(d * w * w) / ↑n)


theorem eml_value_converges_faster (d w n : ℕ) (hw : 5 ≤ w) (hn : 0 < n) :
    emlValueConvergence d w n ≤ stdValueConvergence d w n := by
  unfold emlValueConvergence stdValueConvergence
  apply Real.sqrt_le_sqrt
  apply div_le_div_of_nonneg_right _ (by positivity)
  have : 4 * d * w ≤ d * w * w := by nlinarith [mul_le_mul_of_nonneg_left hw (Nat.zero_le d)]
  exact_mod_cast this


/-- [Section: ## §3. Exploration Bonus] -/
def explorationBonus (visits : ℕ) : ℝ := 1 / Real.sqrt ↑visits


theorem exploration_decays (v1 v2 : ℕ) (hv1 : 0 < v1) (h : v1 ≤ v2) :
    explorationBonus v2 ≤ explorationBonus v1 := by
  unfold explorationBonus; gcongr


/-- [Section: ## §4. Multi-Agent Communication] -/
def stdCommCost (stateDim : ℕ) : ℕ := stateDim

def emlCommCost (stateDim comprRatio : ℕ) : ℕ := stateDim / comprRatio


theorem eml_comm_efficiency (s c : ℕ) :
    emlCommCost s c ≤ stdCommCost s := by
  unfold emlCommCost stdCommCost; exact Nat.div_le_self s c


/-- [Section: ## §5. Reward Shaping] -/
def shapedReward (baseReward potential_diff gamma : ℝ) : ℝ :=
  baseReward + gamma * potential_diff


theorem shaping_zero_preserves (r gamma : ℝ) :
    shapedReward r 0 gamma = r := by
  unfold shapedReward; ring


/-- [Section: ## §6. Sample Efficiency] -/
def stdRLSamples (stateSpace actionSpace : ℕ) (eps : ℝ) : ℝ :=
  ↑(stateSpace * actionSpace) / eps ^ 2


def emlRLSamples (stateSpace actionSpace : ℕ) (eps efficiencyGain : ℝ) : ℝ :=
  ↑(stateSpace * actionSpace) / (eps ^ 2 * efficiencyGain)


theorem eml_rl_sample_efficiency (s a : ℕ) (eps eff : ℝ)
    (heps : 0 < eps) (heff : 1 ≤ eff) (hsa : 0 < s * a) :
    emlRLSamples s a eps eff ≤ stdRLSamples s a eps := by
  unfold emlRLSamples stdRLSamples
  apply div_le_div_of_nonneg_left (by positivity) (by positivity)
  nlinarith [sq_nonneg eps]


end
