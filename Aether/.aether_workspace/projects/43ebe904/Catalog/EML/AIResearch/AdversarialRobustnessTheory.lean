import Mathlib

/-! # CatalogBuild.EML.AIResearch.AdversarialRobustnessTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 15
-/

noncomputable section

/-- [Section: # CatalogBuild.EML.AIResearch.AdversarialRobustnessTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 15] -/
theorem eml_lip_pos (b : ℝ) : 0 < emlLipschitz b := Real.exp_pos b

/-- [Section: # CatalogBuild.EML.AIResearch.AdversarialRobustnessTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 15] -/
theorem eml_lip_monotone (b1 b2 : ℝ) (h : b1 ≤ b2) :
    emlLipschitz b1 ≤ emlLipschitz b2 := Real.exp_le_exp.mpr h

theorem eml_lip_unit_at_zero : emlLipschitz 0 = 1 := by
  unfold emlLipschitz; exact Real.exp_zero

/-- Multi-layer Lipschitz: product of per-layer constants -/
def multiLayerLipschitz (perLayerBound : ℝ) (numLayers : ℕ) : ℝ :=
  (emlLipschitz perLayerBound) ^ numLayers

theorem deeper_higher_lipschitz (b : ℝ) (L1 L2 : ℕ) (hb : 0 ≤ b) (hL : L1 ≤ L2) :
    multiLayerLipschitz b L1 ≤ multiLayerLipschitz b L2 := by
  unfold multiLayerLipschitz
  gcongr
  exact Real.one_le_exp hb

theorem larger_margin_larger_radius (m1 m2 L : ℝ) (hm : m1 ≤ m2) (hL : 0 < L) :
    certifiedRadius m1 L ≤ certifiedRadius m2 L := by
  unfold certifiedRadius; exact div_le_div_of_nonneg_right hm (le_of_lt hL)

/-- Standard adversarial training: PGD steps × model cost -/
def advTrainingCost (pgdSteps modelCost : ℕ) : ℕ := (pgdSteps + 1) * modelCost

/-- Success probability of attack decreases with model robustness -/
def attackSuccessRate (vulnerability perturbBudget : ℝ) : ℝ := vulnerability * perturbBudget

theorem larger_budget_more_vulnerable (v eps1 eps2 : ℝ) (hv : 0 ≤ v) (he : eps1 ≤ eps2) :
    attackSuccessRate v eps1 ≤ attackSuccessRate v eps2 := by
  unfold attackSuccessRate; exact mul_le_mul_of_nonneg_left he hv

theorem zero_perturbation_safe (v : ℝ) : attackSuccessRate v 0 = 0 := by
  unfold attackSuccessRate; ring

/-- Smoothed classifier cost: sample multiple noise perturbations -/
def smoothingCost (numSamples modelCost : ℕ) : ℕ := numSamples * modelCost

theorem eml_smoothing_cheaper (n c_eml c_std : ℕ) (hc : c_eml ≤ c_std) :
    smoothingCost n c_eml ≤ smoothingCost n c_std := by
  unfold smoothingCost; exact Nat.mul_le_mul_left n hc

theorem more_samples_costlier (n1 n2 c : ℕ) (hn : n1 ≤ n2) :
    smoothingCost n1 c ≤ smoothingCost n2 c := by
  unfold smoothingCost; exact Nat.mul_le_mul_right c hn

/-- Cost to verify robustness for all neurons -/
def verificationCost (numNeurons verifyPerNeuron : ℕ) : ℕ := numNeurons * verifyPerNeuron

theorem eml_verify_cheaper (n_eml n_std v : ℕ) (hn : n_eml ≤ n_std) :
    verificationCost n_eml v ≤ verificationCost n_std v := by
  unfold verificationCost; exact Nat.mul_le_mul_right v hn

end