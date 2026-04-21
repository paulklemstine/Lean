/-! # CatalogBuild.EML.AIResearch.SpeculativeDecodingTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 14
-/

import Mathlib

noncomputable section

/-- Standard draft model parameters -/
def stdDraftParams (numLayers d_model : ℕ) : ℕ :=
  numLayers * (d_model * d_model)


/-- EML draft model parameters -/
def emlDraftParams (numLayers d_model : ℕ) : ℕ :=
  numLayers * (4 * d_model)


/-- [Section: ## §1. Draft Model Compression] -/
theorem eml_draft_compact (nL dm : ℕ) (hdm : 4 ≤ dm) :
    emlDraftParams nL dm ≤ stdDraftParams nL dm := by
  -- By dividing both sides of the inequality by $nL$ (assuming $nL \neq 0$), we get $4 * dm \leq dm * dm$.
  have h_div : 4 * dm ≤ dm * dm := by
    -- Since $dm \geq 4$, we can divide both sides of the inequality $4 * dm \leq dm * dm$ by $dm$ (which is positive), yielding $4 \leq dm$.
    nlinarith;
  -- By multiplying both sides of the inequality $4 * dm \leq dm * dm$ by $nL$, we obtain the desired result.
  apply Nat.mul_le_mul_left nL h_div


/-- Cost of one speculative decoding step: draft K tokens + verify batch -/
def specStepCost (draftTokens draftCostPerToken verifyCost : ℕ) : ℕ :=
  draftTokens * draftCostPerToken + verifyCost


/-- [Section: ## §2. Speculative Step Cost] -/
theorem eml_spec_step_cheaper (K dc_eml dc_std vc : ℕ) (hdc : dc_eml ≤ dc_std) :
    specStepCost K dc_eml vc ≤ specStepCost K dc_std vc := by
  -- Since $dc_eml \leq dc_std$, multiplying both sides by $K$ (which is non-negative) preserves the inequality.
  have h_mul : K * dc_eml ≤ K * dc_std := by
    -- Since $K$ is a natural number, multiplying both sides of the inequality $dc_eml \leq dc_std$ by $K$ preserves the inequality.
    apply Nat.mul_le_mul_left K hdc;
  exact Nat.add_le_add_right h_mul vc


theorem more_draft_tokens_costlier (k1 k2 dc vc : ℕ) (hk : k1 ≤ k2) :
    specStepCost k1 dc vc ≤ specStepCost k2 dc vc := by
  -- Since $k1 \leq k2$, multiplying both sides by $dc$ (which is non-negative) preserves the inequality.
  have h_mul : k1 * dc ≤ k2 * dc := by
    -- Since $dc$ is a natural number, multiplying both sides of the inequality $k1 \leq k2$ by $dc$ preserves the inequality.
    apply Nat.mul_le_mul_right dc hk;
  -- Adding $vc$ to both sides of $k1 * dc \leq k2 * dc$ gives $k1 * dc + vc \leq k2 * dc + vc$.
  have h_add : k1 * dc + vc ≤ k2 * dc + vc := by
    grind;
  -- Since $specStepCost k1 dc vc = k1 * dc + vc$ and $specStepCost k2 dc vc = k2 * dc + vc$, we can directly use $h_add$ to conclude the proof.
  convert h_add using 1


/-- Total speculative decoding cost over a sequence -/
def specDecodingTotalCost (numSteps stepCost : ℕ) : ℕ :=
  numSteps * stepCost


/-- [Section: ## §3. Total Decoding Cost] -/
theorem eml_total_spec_cheaper (ns sc_eml sc_std : ℕ) (hsc : sc_eml ≤ sc_std) :
    specDecodingTotalCost ns sc_eml ≤ specDecodingTotalCost ns sc_std := by
  -- Since $sc_eml \leq sc_std$, multiplying both sides by $ns$ (which is non-negative) preserves the inequality.
  apply Nat.mul_le_mul_left ns hsc


/-- With EML draft model, can afford more draft tokens per step.
More draft tokens per step → fewer total steps needed (higher acceptance). -/
def totalSteps (seqLen avgAccepted : ℕ) : ℕ :=
  seqLen / avgAccepted


/-- [Section: ## §4. Acceptance Rate Benefit] -/
theorem more_accepted_fewer_steps (sLen a1 a2 : ℕ) (ha : a1 ≤ a2) (h1 : 0 < a1) :
    totalSteps sLen a2 ≤ totalSteps sLen a1 := by
  -- Since $a1 \leq a2$, dividing by a larger number gives a smaller result, so $sLen / a2 \leq sLen / a1$.
  apply Nat.div_le_div_left ha h1


/-- The draft-verifier parameter ratio determines quality of speculation -/
def draftVerifierRatio (draftParams verifierParams : ℕ) : ℕ :=
  verifierParams / draftParams


/-- [Section: ## §5. Draft-Verifier Gap] -/
theorem eml_better_ratio (dp_eml dp_std vp : ℕ) (hdp : 0 < dp_eml)
    (hle : dp_eml ≤ dp_std) :
    draftVerifierRatio dp_std vp ≤ draftVerifierRatio dp_eml vp := by
  -- By definition of draftVerifierRatio, we have vp / dp_std ≤ vp / dp_eml.
  apply Nat.div_le_div_left hle hdp


/-- Total memory for speculative decoding: draft + verifier must fit -/
def specMemory (draftParams verifierParams : ℕ) : ℕ :=
  draftParams + verifierParams


/-- [Section: ## §6. Memory Budget] -/
theorem eml_spec_fits_better (dp_eml dp_std vp_eml vp_std : ℕ)
    (hdp : dp_eml ≤ dp_std) (hvp : vp_eml ≤ vp_std) :
    specMemory dp_eml vp_eml ≤ specMemory dp_std vp_std := by
  -- By definition of specMemory, we have specMemory dp_eml vp_eml = dp_eml + vp_eml and specMemory dp_std vp_std = dp_std + vp_std.
  simp [specMemory];
  grind +splitImp


end
