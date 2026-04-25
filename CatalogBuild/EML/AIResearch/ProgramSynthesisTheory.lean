/-! # CatalogBuild.EML.AIResearch.ProgramSynthesisTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 10
-/

import Mathlib

noncomputable section

/-- Cost to generate one code candidate -/
def codeGenCost (modelParams seqLen : ℕ) : ℕ :=
  modelParams * seqLen


/-- [Section: ## §1. Code Generation Cost] -/
theorem eml_codegen_cheaper (mp_eml mp_std sl : ℕ) (hmp : mp_eml ≤ mp_std) :
    codeGenCost mp_eml sl ≤ codeGenCost mp_std sl := by
  apply Nat.mul_le_mul_right sl hmp


/-- Cost of generating N candidates for best-of-N selection -/
def multiCandidateCost (numCandidates genCost : ℕ) : ℕ :=
  numCandidates * genCost


/-- [Section: ## §2. Multi-Candidate Generation] -/
theorem eml_multicand_cheaper (nc gc_eml gc_std : ℕ) (hgc : gc_eml ≤ gc_std) :
    multiCandidateCost nc gc_eml ≤ multiCandidateCost nc gc_std := by
  apply Nat.mul_le_mul_left nc hgc


/-- [Section: # CatalogBuild.EML.AIResearch.ProgramSynthesisTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 10] -/
theorem more_candidates_costlier (c1 c2 gc : ℕ) (hc : c1 ≤ c2) :
    multiCandidateCost c1 gc ≤ multiCandidateCost c2 gc := by
  apply Nat.mul_le_mul_right gc hc


/-- Cost of iterative code refinement: R rounds of generate + test -/
def refinementCost (numRounds genCost testCost : ℕ) : ℕ :=
  numRounds * (genCost + testCost)


/-- [Section: ## §3. Iterative Refinement] -/
theorem eml_refinement_cheaper (nr gc_eml gc_std tc : ℕ) (hgc : gc_eml ≤ gc_std) :
    refinementCost nr gc_eml tc ≤ refinementCost nr gc_std tc := by
  unfold refinementCost; gcongr


theorem more_rounds_costlier_prog (r1 r2 gc tc : ℕ) (hr : r1 ≤ r2) :
    refinementCost r1 gc tc ≤ refinementCost r2 gc tc := by
  apply Nat.mul_le_mul_right _ hr


/-- Full program synthesis pipeline: generate N candidates, refine top-k -/
def synthPipelineCost (genAllCost refineCost : ℕ) : ℕ :=
  genAllCost + refineCost


/-- [Section: ## §4. Full Pipeline] -/
theorem eml_pipeline_cheaper_prog (ga_eml ga_std rc_eml rc_std : ℕ)
    (hga : ga_eml ≤ ga_std) (hrc : rc_eml ≤ rc_std) :
    synthPipelineCost ga_eml rc_eml ≤ synthPipelineCost ga_std rc_std := by
  unfold synthPipelineCost; gcongr


end
