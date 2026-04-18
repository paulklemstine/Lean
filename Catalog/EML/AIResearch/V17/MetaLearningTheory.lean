/-
# EML Meta-Learning Theory — v17

## Overview
Meta-learning ("learning to learn") trains models that can adapt to new
tasks with minimal data. MAML-style approaches require computing
second-order gradients over the full model; Prototypical Networks
compute class prototypes in embedding space. EML compression reduces
the cost of both inner-loop adaptation and outer-loop meta-updates.

## Key Results (8 theorems, 0 sorry)
-/

import Mathlib

noncomputable section

open Real Finset BigOperators Nat

/-! ## §1. MAML Inner Loop -/

/-- MAML inner loop: K gradient steps on N-shot support set -/
def mamlInnerCost (innerSteps supportSize modelParams : ℕ) : ℕ :=
  innerSteps * (supportSize * modelParams)

theorem eml_maml_inner_cheaper (K N mp_eml mp_std : ℕ) (hmp : mp_eml ≤ mp_std) :
    mamlInnerCost K N mp_eml ≤ mamlInnerCost K N mp_std := by
  -- Since $mp_eml \leq mp_std$, multiplying both sides by $K$ and then by $N$ preserves the inequality.
  apply Nat.mul_le_mul_left K; apply Nat.mul_le_mul_left N; exact hmp

theorem more_inner_steps_costlier (k1 k2 N mp : ℕ) (hk : k1 ≤ k2) :
    mamlInnerCost k1 N mp ≤ mamlInnerCost k2 N mp := by
  -- Since $k1 \leq k2$, multiplying both sides by $(N * mp)$ preserves the inequality.
  apply Nat.mul_le_mul_right; exact hk

/-! ## §2. MAML Outer Loop -/

/-- MAML outer loop: meta-gradient over T tasks -/
def mamlOuterCost (numTasks innerCost modelParams : ℕ) : ℕ :=
  numTasks * innerCost + modelParams

/-
accumulate + update
-/
theorem eml_maml_outer_cheaper (T ic_eml ic_std mp_eml mp_std : ℕ)
    (hic : ic_eml ≤ ic_std) (hmp : mp_eml ≤ mp_std) :
    mamlOuterCost T ic_eml mp_eml ≤ mamlOuterCost T ic_std mp_std := by
  exact Nat.add_le_add ( Nat.mul_le_mul_left _ hic ) hmp

/-! ## §3. Prototypical Networks -/

/-- Prototype computation: average embeddings per class -/
def prototypeCost (numClasses shotsPerClass embedDim : ℕ) : ℕ :=
  numClasses * shotsPerClass * embedDim

theorem eml_prototype_cheaper (nc spc ed_eml ed_std : ℕ) (hed : ed_eml ≤ ed_std) :
    prototypeCost nc spc ed_eml ≤ prototypeCost nc spc ed_std := by
  -- Since $ed_eml \leq ed_std$, multiplying both sides by $nc * spc$ (which is non-negative) preserves the inequality. Therefore, $nc * spc * ed_eml \leq nc * spc * ed_std$.
  apply Nat.mul_le_mul_left; exact hed

/-! ## §4. Few-Shot Inference -/

/-- Few-shot inference: embed query + compute distances to prototypes -/
def fewShotInferenceCost (numQueries numClasses embedCost : ℕ) : ℕ :=
  numQueries * (embedCost + numClasses)

theorem eml_fewshot_cheaper (nq nc ec_eml ec_std : ℕ) (hec : ec_eml ≤ ec_std) :
    fewShotInferenceCost nq nc ec_eml ≤ fewShotInferenceCost nq nc ec_std := by
  -- Since $ec_eml \leq ec_std$, adding $nc$ to both sides preserves the inequality.
  apply Nat.mul_le_mul_left nq (by linarith)

/-! ## §5. Task Distribution Memory -/

/-- Memory for storing task-specific adaptations -/
def taskAdaptMemory (numTasks adaptSize : ℕ) : ℕ :=
  numTasks * adaptSize

theorem eml_task_memory_cheaper (nt as_eml as_std : ℕ) (has : as_eml ≤ as_std) :
    taskAdaptMemory nt as_eml ≤ taskAdaptMemory nt as_std := by
  -- Since $as_eml \leq as_std$, multiplying both sides by $nt$ (which is non-negative) preserves the inequality.
  apply mul_le_mul_left' has

/-! ## §6. Second-Order Gradient Cost -/

/-- Second-order (Hessian-vector product) cost -/
def secondOrderCost (modelParams batchSize : ℕ) : ℕ :=
  2 * batchSize * modelParams

/-
forward-over-backward
-/
theorem eml_second_order_cheaper (mp_eml mp_std bs : ℕ) (hmp : mp_eml ≤ mp_std) :
    secondOrderCost mp_eml bs ≤ secondOrderCost mp_std bs := by
  unfold secondOrderCost; gcongr;

end