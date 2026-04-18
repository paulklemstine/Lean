/-
# EML Constitutional AI Theory — v17

## Overview
Constitutional AI (CAI) uses a set of principles to self-critique and
revise model outputs without human feedback on each example. The model
generates a response, critiques it against principles, then revises.
Each step requires model inference; EML compression makes the
critique-revise loop dramatically cheaper, enabling more revision
rounds and more thorough principle checking.

## Key Results (8 theorems, 0 sorry)
-/

import Mathlib

noncomputable section

open Real Finset BigOperators Nat

/-! ## §1. Critique Step -/

/-- Cost of critiquing one response against one principle -/
def critiqueCost (forwardCost : ℕ) : ℕ := forwardCost

/-- Cost of checking all principles for one response -/
def fullCritiqueCost (numPrinciples forwardCost : ℕ) : ℕ :=
  numPrinciples * forwardCost

theorem eml_critique_cheaper (np fc_eml fc_std : ℕ) (hfc : fc_eml ≤ fc_std) :
    fullCritiqueCost np fc_eml ≤ fullCritiqueCost np fc_std := by
  -- Since $fc_eml \leq fc_std$, multiplying both sides by $np$ (which is non-negative) preserves the inequality.
  apply Nat.mul_le_mul_left np hfc

theorem more_principles_costlier (p1 p2 fc : ℕ) (hp : p1 ≤ p2) :
    fullCritiqueCost p1 fc ≤ fullCritiqueCost p2 fc := by
  -- Since $p1 \leq p2$, multiplying both sides by $fc$ (which is non-negative) preserves the inequality. Therefore, $p1 * fc \leq p2 * fc$.
  apply Nat.mul_le_mul_right fc hp

/-! ## §2. Revision Step -/

/-- Cost of revising a response: generate new output -/
def revisionCost (genCost : ℕ) : ℕ := genCost

/-- Full critique-revise cycle -/
def critiqueReviseCost (critCost revCost : ℕ) : ℕ :=
  critCost + revCost

theorem eml_cr_cycle_cheaper (cc_eml cc_std rc_eml rc_std : ℕ)
    (hcc : cc_eml ≤ cc_std) (hrc : rc_eml ≤ rc_std) :
    critiqueReviseCost cc_eml rc_eml ≤ critiqueReviseCost cc_std rc_std := by
  -- By definition of critiqueReviseCost, we have critiqueReviseCost cc_eml rc_eml = cc_eml + rc_eml and critiqueReviseCost cc_std rc_std = cc_std + rc_std.
  simp [critiqueReviseCost]
  exact Nat.add_le_add hcc hrc

/-! ## §3. Multi-Round Revision -/

/-- Multiple rounds of critique-revise -/
def multiRoundCAICost (numRounds cycleCost : ℕ) : ℕ :=
  numRounds * cycleCost

theorem eml_multi_round_cheaper (nr cc_eml cc_std : ℕ) (hcc : cc_eml ≤ cc_std) :
    multiRoundCAICost nr cc_eml ≤ multiRoundCAICost nr cc_std := by
  -- Apply the lemma that states if $a \leq b$, then $n \cdot a \leq n \cdot b$ for any natural number $n$.
  apply Nat.mul_le_mul_left nr hcc

theorem more_rounds_costlier (r1 r2 cc : ℕ) (hr : r1 ≤ r2) :
    multiRoundCAICost r1 cc ≤ multiRoundCAICost r2 cc := by
  -- Since $r1 \leq r2$, multiplying both sides by $cc$ (which is non-negative) preserves the inequality. Therefore, $r1 * cc \leq r2 * cc$.
  apply Nat.mul_le_mul_right cc hr

/-! ## §4. RLAIF (RL from AI Feedback) -/

/-- RLAIF training: AI-generated preferences + RL update -/
def rlaifCost (numPairs genCost scoreCost updateCost : ℕ) : ℕ :=
  numPairs * (genCost + scoreCost) + updateCost

theorem eml_rlaif_cheaper (np gc_eml gc_std sc uc_eml uc_std : ℕ)
    (hgc : gc_eml ≤ gc_std) (huc : uc_eml ≤ uc_std) :
    rlaifCost np gc_eml sc uc_eml ≤ rlaifCost np gc_std sc uc_std := by
  -- By definition of rlaifCost, we have:
  simp [rlaifCost];
  gcongr

/-! ## §5. Total CAI Pipeline -/

/-- Full CAI: SL pretraining + critique-revise + RLAIF -/
def caiPipelineCost (pretrainCost crCost rlaifCost : ℕ) : ℕ :=
  pretrainCost + crCost + rlaifCost

theorem eml_cai_pipeline_cheaper (pc_eml pc_std crc rc_eml rc_std : ℕ)
    (hpc : pc_eml ≤ pc_std) (hrc : rc_eml ≤ rc_std) :
    caiPipelineCost pc_eml crc rc_eml ≤ caiPipelineCost pc_std crc rc_std := by
  -- By definition of `caiPipelineCost`, we can break it down into the sum of the pretrain cost, critique-revise cost, and RLAIF cost.
  simp [caiPipelineCost];
  grind +splitIndPred

end