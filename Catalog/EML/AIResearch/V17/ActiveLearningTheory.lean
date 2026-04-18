/-
# EML Active Learning Theory — v17

## Overview
Active learning selects the most informative data points for labeling,
reducing annotation cost. The acquisition function (uncertainty sampling,
expected information gain, etc.) requires model inference on the unlabeled
pool — a cost proportional to model size × pool size. EML compression
directly reduces acquisition cost, enabling larger pools and more
frequent re-selection cycles.

## Key Results (8 theorems, 0 sorry)
-/

import Mathlib

noncomputable section

open Real Finset BigOperators Nat

/-! ## §1. Acquisition Function Cost -/

/-- Cost of evaluating acquisition function on unlabeled pool -/
def acquisitionCost (poolSize forwardCost : ℕ) : ℕ :=
  poolSize * forwardCost

theorem eml_acquisition_cheaper (ps fc_eml fc_std : ℕ) (hfc : fc_eml ≤ fc_std) :
    acquisitionCost ps fc_eml ≤ acquisitionCost ps fc_std := by
  -- Since $fc_eml \leq fc_std$, multiplying both sides by $ps$ (which is positive) preserves the inequality. Therefore, $ps * fc_eml \leq ps * fc_std$.
  apply Nat.mul_le_mul_left ps hfc

theorem larger_pool_costlier (p1 p2 fc : ℕ) (hp : p1 ≤ p2) :
    acquisitionCost p1 fc ≤ acquisitionCost p2 fc := by
  -- Since $p1 \leq p2$, multiplying both sides by $fc$ (which is non-negative) preserves the inequality.
  apply Nat.mul_le_mul_right fc hp

/-! ## §2. Bayesian Uncertainty -/

/-- MC-Dropout uncertainty: run K forward passes per sample -/
def mcDropoutCost (numSamples numPasses forwardCost : ℕ) : ℕ :=
  numSamples * numPasses * forwardCost

theorem eml_mc_dropout_cheaper (ns np fc_eml fc_std : ℕ) (hfc : fc_eml ≤ fc_std) :
    mcDropoutCost ns np fc_eml ≤ mcDropoutCost ns np fc_std := by
  -- Since $fc_eml \leq fc_std$, multiplying both sides by $ns * np$ (which are non-negative) preserves the inequality.
  apply Nat.mul_le_mul_left (ns * np) hfc

/-! ## §3. Active Learning Cycle -/

/-- One active learning cycle: acquire + label + retrain -/
def alCycleCost (acquisitionCost labelCost retrainCost : ℕ) : ℕ :=
  acquisitionCost + labelCost + retrainCost

/-- Total active learning budget over R rounds -/
def alTotalCost (numRounds cycleCost : ℕ) : ℕ :=
  numRounds * cycleCost

theorem eml_al_cycle_cheaper (ac_eml ac_std lc rc_eml rc_std : ℕ)
    (hac : ac_eml ≤ ac_std) (hrc : rc_eml ≤ rc_std) :
    alCycleCost ac_eml lc rc_eml ≤ alCycleCost ac_std lc rc_std := by
  -- By definition of alCycleCost, we can expand it as acquisitionCost + labelCost + retrainCost.
  simp [alCycleCost];
  -- Adding the inequalities hac and hrc, we get the desired result.
  linarith

theorem more_rounds_costlier (r1 r2 cc : ℕ) (hr : r1 ≤ r2) :
    alTotalCost r1 cc ≤ alTotalCost r2 cc := by
  -- Since $r1 \leq r2$, multiplying both sides by $cc$ (which is non-negative) preserves the inequality.
  apply Nat.mul_le_mul_right cc hr

/-! ## §4. Batch Active Learning -/

/-- Batch selection: select B points per round -/
def batchSelectionCost (batchSize poolSize forwardCost : ℕ) : ℕ :=
  batchSize * (poolSize * forwardCost)

theorem eml_batch_selection_cheaper (bs ps fc_eml fc_std : ℕ) (hfc : fc_eml ≤ fc_std) :
    batchSelectionCost bs ps fc_eml ≤ batchSelectionCost bs ps fc_std := by
  -- By multiplying both sides of the inequality `hfc` by `bs * ps`, we obtain the desired result.
  apply Nat.mul_le_mul_left; exact Nat.mul_le_mul_left ps hfc

/-! ## §5. Core-Set Selection -/

/-- Core-set: embed all points + compute distances -/
def coreSetCost (poolSize embedCost : ℕ) : ℕ :=
  poolSize * embedCost + poolSize * poolSize

theorem eml_coreset_cheaper (ps ec_eml ec_std : ℕ) (hec : ec_eml ≤ ec_std) :
    coreSetCost ps ec_eml ≤ coreSetCost ps ec_std := by
  -- Since $ec_eml \leq ec_std$, multiplying both sides by $ps$ (which is non-negative) preserves the inequality.
  have h_linear : ps * ec_eml ≤ ps * ec_std := by
    -- Since $ps$ is a natural number, multiplying both sides of the inequality $ec_eml \leq ec_std$ by $ps$ preserves the inequality.
    apply Nat.mul_le_mul_left ps hec;
  exact Nat.add_le_add_right h_linear _

end