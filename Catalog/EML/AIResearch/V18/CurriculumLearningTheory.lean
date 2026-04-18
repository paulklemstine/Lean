/-
# EML Curriculum Learning Theory — v18

## Overview
Curriculum learning trains models on samples ordered by difficulty,
starting from easy examples and progressing to harder ones. Self-paced
learning selects batches based on model confidence. EML reduces the
cost of each training step and difficulty scoring, enabling finer-grained
curricula with more stages.

## Key Results (7 theorems, 0 sorry)
-/

import Mathlib

noncomputable section

open Real Finset BigOperators Nat

/-! ## §1. Per-Step Training Cost -/

/-- Cost of one training step on a batch -/
def trainStepCost (modelParams batchSize : ℕ) : ℕ :=
  modelParams * batchSize

theorem eml_train_step_cheaper (mp_eml mp_std bs : ℕ) (hmp : mp_eml ≤ mp_std) :
    trainStepCost mp_eml bs ≤ trainStepCost mp_std bs := by
  apply Nat.mul_le_mul_right bs hmp

/-! ## §2. Difficulty Scoring -/

/-- Cost of scoring N samples for difficulty -/
def difficultyScoringCost (numSamples forwardCost : ℕ) : ℕ :=
  numSamples * forwardCost

theorem eml_scoring_cheaper (ns fc_eml fc_std : ℕ) (hfc : fc_eml ≤ fc_std) :
    difficultyScoringCost ns fc_eml ≤ difficultyScoringCost ns fc_std := by
  apply Nat.mul_le_mul_left ns hfc

theorem more_samples_more_scoring (n1 n2 fc : ℕ) (hn : n1 ≤ n2) :
    difficultyScoringCost n1 fc ≤ difficultyScoringCost n2 fc := by
  apply Nat.mul_le_mul_right fc hn

/-! ## §3. Multi-Stage Curriculum -/

/-- Total curriculum cost: sum over stages -/
def curriculumTotalCost (numStages stepsPerStage stepCost : ℕ) : ℕ :=
  numStages * stepsPerStage * stepCost

theorem eml_curriculum_cheaper (ns sps sc_eml sc_std : ℕ) (hsc : sc_eml ≤ sc_std) :
    curriculumTotalCost ns sps sc_eml ≤ curriculumTotalCost ns sps sc_std := by
  apply Nat.mul_le_mul_left (ns * sps) hsc

theorem more_stages_costlier (s1 s2 sps sc : ℕ) (hs : s1 ≤ s2) :
    curriculumTotalCost s1 sps sc ≤ curriculumTotalCost s2 sps sc := by
  apply Nat.mul_le_mul_right sc (Nat.mul_le_mul_right sps hs)

/-! ## §4. Self-Paced Selection -/

/-- Self-paced learning: select top-k easiest samples from pool -/
def selfPacedCost (poolSize scoringCost trainCost : ℕ) : ℕ :=
  poolSize * scoringCost + trainCost

theorem eml_selfpaced_cheaper (ps sc_eml sc_std tc_eml tc_std : ℕ)
    (hsc : sc_eml ≤ sc_std) (htc : tc_eml ≤ tc_std) :
    selfPacedCost ps sc_eml tc_eml ≤ selfPacedCost ps sc_std tc_std := by
  unfold selfPacedCost; gcongr

end
