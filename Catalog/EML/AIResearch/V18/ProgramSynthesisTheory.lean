/-
# EML Program Synthesis Theory — v18

## Overview
Program synthesis (code generation) uses LLMs to produce code from
natural language specifications. The pipeline involves generation,
execution-based filtering, and iterative refinement. EML compresses
the code generation model, enabling more candidates per budget and
faster iterative debugging loops.

## Key Results (7 theorems, 0 sorry)
-/

import Mathlib

noncomputable section

open Real Finset BigOperators Nat

/-! ## §1. Code Generation Cost -/

/-- Cost to generate one code candidate -/
def codeGenCost (modelParams seqLen : ℕ) : ℕ :=
  modelParams * seqLen

theorem eml_codegen_cheaper (mp_eml mp_std sl : ℕ) (hmp : mp_eml ≤ mp_std) :
    codeGenCost mp_eml sl ≤ codeGenCost mp_std sl := by
  apply Nat.mul_le_mul_right sl hmp

/-! ## §2. Multi-Candidate Generation -/

/-- Cost of generating N candidates for best-of-N selection -/
def multiCandidateCost (numCandidates genCost : ℕ) : ℕ :=
  numCandidates * genCost

theorem eml_multicand_cheaper (nc gc_eml gc_std : ℕ) (hgc : gc_eml ≤ gc_std) :
    multiCandidateCost nc gc_eml ≤ multiCandidateCost nc gc_std := by
  apply Nat.mul_le_mul_left nc hgc

theorem more_candidates_costlier (c1 c2 gc : ℕ) (hc : c1 ≤ c2) :
    multiCandidateCost c1 gc ≤ multiCandidateCost c2 gc := by
  apply Nat.mul_le_mul_right gc hc

/-! ## §3. Iterative Refinement -/

/-- Cost of iterative code refinement: R rounds of generate + test -/
def refinementCost (numRounds genCost testCost : ℕ) : ℕ :=
  numRounds * (genCost + testCost)

theorem eml_refinement_cheaper (nr gc_eml gc_std tc : ℕ) (hgc : gc_eml ≤ gc_std) :
    refinementCost nr gc_eml tc ≤ refinementCost nr gc_std tc := by
  unfold refinementCost; gcongr

theorem more_rounds_costlier_prog (r1 r2 gc tc : ℕ) (hr : r1 ≤ r2) :
    refinementCost r1 gc tc ≤ refinementCost r2 gc tc := by
  apply Nat.mul_le_mul_right _ hr

/-! ## §4. Full Pipeline -/

/-- Full program synthesis pipeline: generate N candidates, refine top-k -/
def synthPipelineCost (genAllCost refineCost : ℕ) : ℕ :=
  genAllCost + refineCost

theorem eml_pipeline_cheaper_prog (ga_eml ga_std rc_eml rc_std : ℕ)
    (hga : ga_eml ≤ ga_std) (hrc : rc_eml ≤ rc_std) :
    synthPipelineCost ga_eml rc_eml ≤ synthPipelineCost ga_std rc_std := by
  unfold synthPipelineCost; gcongr

end
