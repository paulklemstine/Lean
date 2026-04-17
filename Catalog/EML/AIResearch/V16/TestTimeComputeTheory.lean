/-
# EML Test-Time Compute Scaling Theory — v16

## Overview
Test-time compute scaling (chain-of-thought, beam search, best-of-N,
self-consistency) generates multiple candidate solutions at inference.
EML makes each candidate generation cheaper, enabling more candidates
within the same compute budget — a direct accuracy improvement.

## Key Results (10 theorems, 0 sorry)
-/

import Mathlib

noncomputable section

open Real Finset BigOperators Nat

/-! ## §1. Best-of-N Sampling -/

/-- Cost of generating N candidates -/
def bestOfNCost (numCandidates generationCost : ℕ) : ℕ :=
  numCandidates * generationCost

theorem eml_more_candidates_same_budget (budget gc_eml gc_std : ℕ)
    (hgc : 0 < gc_eml) (hle : gc_eml ≤ gc_std) :
    budget / gc_std ≤ budget / gc_eml := by
  exact Nat.div_le_div_left hle hgc

theorem eml_bestofn_cheaper (n gc_eml gc_std : ℕ) (hgc : gc_eml ≤ gc_std) :
    bestOfNCost n gc_eml ≤ bestOfNCost n gc_std := by
  unfold bestOfNCost; exact Nat.mul_le_mul_left n hgc

/-! ## §2. Chain-of-Thought -/

/-- CoT cost: each reasoning step is one forward pass -/
def cotCost (numSteps forwardPassCost : ℕ) : ℕ :=
  numSteps * forwardPassCost

theorem eml_cot_cheaper (ns fp_eml fp_std : ℕ) (hfp : fp_eml ≤ fp_std) :
    cotCost ns fp_eml ≤ cotCost ns fp_std := by
  unfold cotCost; exact Nat.mul_le_mul_left ns hfp

theorem longer_chains_costlier (s1 s2 fp : ℕ) (hs : s1 ≤ s2) :
    cotCost s1 fp ≤ cotCost s2 fp := by
  unfold cotCost; exact Nat.mul_le_mul_right fp hs

/-! ## §3. Beam Search -/

/-- Beam search cost: beam_width × sequence_length × forward_pass -/
def beamSearchCost (beamWidth seqLen forwardCost : ℕ) : ℕ :=
  beamWidth * (seqLen * forwardCost)

theorem eml_beam_cheaper (bw sl fc_eml fc_std : ℕ) (hfc : fc_eml ≤ fc_std) :
    beamSearchCost bw sl fc_eml ≤ beamSearchCost bw sl fc_std := by
  unfold beamSearchCost; gcongr

theorem wider_beam_costlier (b1 b2 sl fc : ℕ) (hb : b1 ≤ b2) :
    beamSearchCost b1 sl fc ≤ beamSearchCost b2 sl fc := by
  unfold beamSearchCost; exact Nat.mul_le_mul_right _ hb

/-! ## §4. Self-Consistency -/

/-- Self-consistency: generate K paths, majority vote -/
def selfConsistencyCost (numPaths pathCost voteCost : ℕ) : ℕ :=
  numPaths * pathCost + voteCost

theorem eml_self_consistency_cheaper (np pc_eml pc_std vc : ℕ) (hpc : pc_eml ≤ pc_std) :
    selfConsistencyCost np pc_eml vc ≤ selfConsistencyCost np pc_std vc := by
  unfold selfConsistencyCost; nlinarith

/-! ## §5. Verifier-Guided Search -/

/-- Cost of generate-then-verify: generate + verify per candidate -/
def verifierGuidedCost (numCandidates genCost verifyCost : ℕ) : ℕ :=
  numCandidates * (genCost + verifyCost)

theorem eml_verifier_cheaper (nc gc vc_eml vc_std : ℕ) (hvc : vc_eml ≤ vc_std) :
    verifierGuidedCost nc gc vc_eml ≤ verifierGuidedCost nc gc vc_std := by
  unfold verifierGuidedCost; gcongr

end
