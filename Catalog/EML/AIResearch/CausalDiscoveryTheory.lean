import Mathlib

/-! # CatalogBuild.EML.AIResearch.CausalDiscoveryTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 9
-/

noncomputable section

/-- Cost of fitting one SEM for a candidate graph -/
def semFitCost (numEdges modelParamsPerEdge numSamples : ℕ) : ℕ :=
  numEdges * modelParamsPerEdge * numSamples

/-- [Section: ## §1. Structural Equation Model Cost] -/
theorem eml_sem_cheaper (ne mpe_eml mpe_std ns : ℕ) (hmpe : mpe_eml ≤ mpe_std) :
    semFitCost ne mpe_eml ns ≤ semFitCost ne mpe_std ns := by
  unfold semFitCost; gcongr

/-- Cost of evaluating K candidate graphs -/
def graphSearchCost (numCandidates semCost : ℕ) : ℕ :=
  numCandidates * semCost

/-- [Section: ## §2. Graph Search] -/
theorem eml_search_cheaper (nc sc_eml sc_std : ℕ) (hsc : sc_eml ≤ sc_std) :
    graphSearchCost nc sc_eml ≤ graphSearchCost nc sc_std := by
  apply Nat.mul_le_mul_left nc hsc

theorem more_candidates_costlier_graph (c1 c2 sc : ℕ) (hc : c1 ≤ c2) :
    graphSearchCost c1 sc ≤ graphSearchCost c2 sc := by
  apply Nat.mul_le_mul_right sc hc

/-- Cost of bootstrap stability analysis: B resamples × graph search -/
def bootstrapCausalCost (numBootstraps searchCost : ℕ) : ℕ :=
  numBootstraps * searchCost

/-- [Section: ## §4. Bootstrap Stability] -/
theorem eml_bootstrap_cheaper (nb sc_eml sc_std : ℕ) (hsc : sc_eml ≤ sc_std) :
    bootstrapCausalCost nb sc_eml ≤ bootstrapCausalCost nb sc_std := by
  apply Nat.mul_le_mul_left nb hsc

/-- Full causal discovery: search + intervention + bootstrap -/
def causalPipelineCost (searchC interventionC bootstrapC : ℕ) : ℕ :=
  searchC + interventionC + bootstrapC

/-- [Section: ## §5. Full Discovery Pipeline] -/
theorem eml_causal_pipeline_cheaper (sc_eml sc_std ic_eml ic_std bc_eml bc_std : ℕ)
    (hsc : sc_eml ≤ sc_std) (hic : ic_eml ≤ ic_std) (hbc : bc_eml ≤ bc_std) :
    causalPipelineCost sc_eml ic_eml bc_eml ≤ causalPipelineCost sc_std ic_std bc_std := by
  unfold causalPipelineCost; omega

end