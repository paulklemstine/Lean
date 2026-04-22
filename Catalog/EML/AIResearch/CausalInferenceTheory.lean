import Mathlib

/-! # CatalogBuild.EML.AIResearch.CausalInferenceTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 24
-/

noncomputable section

/-- Standard structural equation: dense function of parents -/
def stdSEMParams (numParents outputDim : ℕ) : ℕ := numParents * outputDim

/-- EML structural equation: 4 params per output -/
def emlSEMParams (outputDim : ℕ) : ℕ := 4 * outputDim

/-- [Section: # CatalogBuild.EML.AIResearch.CausalInferenceTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 24] -/
theorem eml_sem_compact (np od : ℕ) (hn : 4 ≤ np) :
    emlSEMParams od ≤ stdSEMParams np od := by
  unfold emlSEMParams stdSEMParams; exact Nat.mul_le_mul_right od hn

/-- Cost to compute intervened model: recompute downstream -/
def interventionCost (numDescendants modelCostPerNode : ℕ) : ℕ :=
  numDescendants * modelCostPerNode

/-- [Section: # CatalogBuild.EML.AIResearch.CausalInferenceTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 24] -/
theorem eml_intervention_cheaper (nd mc_eml mc_std : ℕ) (hm : mc_eml ≤ mc_std) :
    interventionCost nd mc_eml ≤ interventionCost nd mc_std := by
  unfold interventionCost; exact Nat.mul_le_mul_left nd hm

/-- Sample complexity for estimating ATE -/
def ateSampleComplexity (modelDim : ℕ) (epsilon : ℝ) : ℝ :=
  ↑modelDim / epsilon ^ 2

theorem eml_ate_sample_efficient (d_eml d_std : ℕ) (eps : ℝ) (_heps : 0 < eps)
    (hd : d_eml ≤ d_std) :
    ateSampleComplexity d_eml eps ≤ ateSampleComplexity d_std eps := by
  unfold ateSampleComplexity
  apply div_le_div_of_nonneg_right _ (sq_nonneg _)
  exact_mod_cast hd

/-- Cost to compute counterfactual: abduction + intervention + prediction -/
def counterfactualCost (abductionCost interventionCost predictionCost : ℕ) : ℕ :=
  abductionCost + interventionCost + predictionCost

theorem eml_counterfactual_cheaper (a_eml a_std i_eml i_std p_eml p_std : ℕ)
    (ha : a_eml ≤ a_std) (hi : i_eml ≤ i_std) (hp : p_eml ≤ p_std) :
    counterfactualCost a_eml i_eml p_eml ≤ counterfactualCost a_std i_std p_std := by
  unfold counterfactualCost; omega

/-- Score-based causal discovery: evaluate DAGs -/
def causalDiscoveryCost (numVariables scoringCost : ℕ) : ℕ :=
  numVariables * numVariables * scoringCost

theorem eml_discovery_cheaper (n sc_eml sc_std : ℕ) (hs : sc_eml ≤ sc_std) :
    causalDiscoveryCost n sc_eml ≤ causalDiscoveryCost n sc_std := by
  unfold causalDiscoveryCost; exact Nat.mul_le_mul_left (n * n) hs

/-- IV estimation cost: two-stage regression -/
def ivEstimationCost (firstStageCost secondStageCost : ℕ) : ℕ :=
  firstStageCost + secondStageCost

theorem eml_iv_cheaper (fs_eml fs_std ss_eml ss_std : ℕ)
    (hf : fs_eml ≤ fs_std) (hs : ss_eml ≤ ss_std) :
    ivEstimationCost fs_eml ss_eml ≤ ivEstimationCost fs_std ss_std := by
  unfold ivEstimationCost; omega

/-- Mediation: direct effect + indirect effect estimation -/
def mediationCost (directEffectCost indirectEffectCost : ℕ) : ℕ :=
  directEffectCost + indirectEffectCost

theorem eml_mediation_cheaper (de_eml de_std ie_eml ie_std : ℕ)
    (hd : de_eml ≤ de_std) (hi : ie_eml ≤ ie_std) :
    mediationCost de_eml ie_eml ≤ mediationCost de_std ie_std := by
  unfold mediationCost; omega

/-- Sensitivity: how much does estimate change with unmeasured confounding -/
def sensitivityBound (effectEstimate confoundStrength : ℝ) : ℝ :=
  effectEstimate + confoundStrength

theorem stronger_confounding_weaker_bound (e c1 c2 : ℝ) (hc : c1 ≤ c2) :
    sensitivityBound e c1 ≤ sensitivityBound e c2 := by
  unfold sensitivityBound; linarith

theorem no_confounding_exact (e : ℝ) : sensitivityBound e 0 = e := by
  unfold sensitivityBound; ring

/-- Propensity score model: predict treatment from covariates -/
def propensityModelParams (numCovariates hiddenDim : ℕ) : ℕ := numCovariates * hiddenDim

def emlPropensityParams (numCovariates : ℕ) : ℕ := 4 * numCovariates

theorem eml_propensity_compact (nc hd : ℕ) (hh : 4 ≤ hd) :
    emlPropensityParams nc ≤ propensityModelParams nc hd := by
  unfold emlPropensityParams propensityModelParams
  calc 4 * nc = nc * 4 := by ring
    _ ≤ nc * hd := Nat.mul_le_mul_left nc hh

/-- Learn causal variables from raw observations -/
def causalRepParams (inputDim numCausalVars hiddenDim : ℕ) : ℕ :=
  inputDim * hiddenDim + hiddenDim * numCausalVars

def emlCausalRepParams (numCausalVars : ℕ) : ℕ := 4 * numCausalVars

theorem eml_causal_rep_compact (di ncv hd : ℕ) (_hdi : 4 ≤ di) (hhd : 4 ≤ hd) :
    emlCausalRepParams ncv ≤ causalRepParams di ncv hd := by
  unfold emlCausalRepParams causalRepParams
  have : 4 * ncv ≤ hd * ncv := Nat.mul_le_mul_right ncv hhd
  omega

end
