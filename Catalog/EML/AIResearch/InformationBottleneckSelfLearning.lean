/-! # CatalogBuild.EML.AIResearch.InformationBottleneckSelfLearning

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 6
-/

import Mathlib

noncomputable section

/-- [Section: ## §1. Information Bottleneck Framework] -/
theorem kl_div_nonneg {n : ℕ} (p q : Fin n → ℝ)
    (hp : ∀ i, 0 < p i) (hq : ∀ i, 0 < q i)
    (hpsum : ∑ i, p i = 1) (hqsum : ∑ i, q i = 1) :
    0 ≤ klDiv p q hp hq := by
  -- Since $p_i > 0$ and $q_i > 0$ for all $i$, we can apply the inequality $p_i \log(p_i / q_i) \geq p_i - q_i$ for all $i$.
  have h_ineq : ∀ i, p i * (Real.log (p i) - Real.log (q i)) ≥ p i - q i := by
    intro i; have := Real.log_le_sub_one_of_pos ( div_pos ( hq i ) ( hp i ) ) ; rw [ Real.log_div ( ne_of_gt ( hq i ) ) ( ne_of_gt ( hp i ) ) ] at this; ring_nf at *; nlinarith [ hp i, hq i, mul_inv_cancel₀ ( ne_of_gt ( hp i ) ) ];
  exact le_trans ( by norm_num [ hpsum, hqsum ] ) ( Finset.sum_le_sum fun i _ => h_ineq i )


/-- Information content at each layer of a deep network -/
structure LayerwiseInfo where
  /-- Number of layers -/
  numLayers : ℕ
  /-- Mutual information with input at each layer -/
  inputMI : Fin numLayers → ℝ
  /-- Mutual information with target at each layer -/
  targetMI : Fin numLayers → ℝ
  /-- Both are nonneg -/
  inputMI_nonneg : ∀ i, 0 ≤ inputMI i
  targetMI_nonneg : ∀ i, 0 ≤ targetMI i


/-- Data processing inequality: MI with input decreases through layers -/
def SatisfiesDataProcessing (L : LayerwiseInfo) : Prop :=
  ∀ i j : Fin L.numLayers, i ≤ j → L.inputMI j ≤ L.inputMI i


/-- Sufficient statistics: the last layer retains all target information -/
def IsSufficientStatistic (L : LayerwiseInfo) (hn : 0 < L.numLayers) : Prop :=
  L.targetMI ⟨L.numLayers - 1, by omega⟩ = L.targetMI ⟨0, by omega⟩


/-- Standard layer capacity: d² parameters -/
def stdLayerCapacity (d : ℕ) (bitsPerParam : ℕ) : ℕ :=
  d * d * bitsPerParam


/-- EML layer capacity: 4d parameters -/
def emlLayerCapacity (d : ℕ) (bitsPerParam : ℕ) : ℕ :=
  4 * d * bitsPerParam


end
