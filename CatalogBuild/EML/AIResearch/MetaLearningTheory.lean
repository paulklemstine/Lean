/-! # CatalogBuild.EML.AIResearch.MetaLearningTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 13
-/

import Mathlib

noncomputable section

/-- MAML inner loop: K gradient steps on N-shot support set -/
def mamlInnerCost (innerSteps supportSize modelParams : ℕ) : ℕ :=
  innerSteps * (supportSize * modelParams)


/-- [Section: ## §1. MAML Inner Loop] -/
theorem eml_maml_inner_cheaper (K N mp_eml mp_std : ℕ) (hmp : mp_eml ≤ mp_std) :
    mamlInnerCost K N mp_eml ≤ mamlInnerCost K N mp_std := by
  -- Since $mp_eml \leq mp_std$, multiplying both sides by $K$ and then by $N$ preserves the inequality.
  apply Nat.mul_le_mul_left K; apply Nat.mul_le_mul_left N; exact hmp


/-- [Section: # CatalogBuild.EML.AIResearch.MetaLearningTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 13] -/
theorem more_inner_steps_costlier (k1 k2 N mp : ℕ) (hk : k1 ≤ k2) :
    mamlInnerCost k1 N mp ≤ mamlInnerCost k2 N mp := by
  -- Since $k1 \leq k2$, multiplying both sides by $(N * mp)$ preserves the inequality.
  apply Nat.mul_le_mul_right; exact hk


/-- MAML outer loop: meta-gradient over T tasks -/
def mamlOuterCost (numTasks innerCost modelParams : ℕ) : ℕ :=
  numTasks * innerCost + modelParams


/-- [Section: ## §2. MAML Outer Loop] -/
theorem eml_maml_outer_cheaper (T ic_eml ic_std mp_eml mp_std : ℕ)
    (hic : ic_eml ≤ ic_std) (hmp : mp_eml ≤ mp_std) :
    mamlOuterCost T ic_eml mp_eml ≤ mamlOuterCost T ic_std mp_std := by
  exact Nat.add_le_add ( Nat.mul_le_mul_left _ hic ) hmp


/-- Prototype computation: average embeddings per class -/
def prototypeCost (numClasses shotsPerClass embedDim : ℕ) : ℕ :=
  numClasses * shotsPerClass * embedDim


/-- [Section: ## §3. Prototypical Networks] -/
theorem eml_prototype_cheaper (nc spc ed_eml ed_std : ℕ) (hed : ed_eml ≤ ed_std) :
    prototypeCost nc spc ed_eml ≤ prototypeCost nc spc ed_std := by
  -- Since $ed_eml \leq ed_std$, multiplying both sides by $nc * spc$ (which is non-negative) preserves the inequality. Therefore, $nc * spc * ed_eml \leq nc * spc * ed_std$.
  apply Nat.mul_le_mul_left; exact hed


/-- Few-shot inference: embed query + compute distances to prototypes -/
def fewShotInferenceCost (numQueries numClasses embedCost : ℕ) : ℕ :=
  numQueries * (embedCost + numClasses)


/-- [Section: ## §4. Few-Shot Inference] -/
theorem eml_fewshot_cheaper (nq nc ec_eml ec_std : ℕ) (hec : ec_eml ≤ ec_std) :
    fewShotInferenceCost nq nc ec_eml ≤ fewShotInferenceCost nq nc ec_std := by
  -- Since $ec_eml \leq ec_std$, adding $nc$ to both sides preserves the inequality.
  apply Nat.mul_le_mul_left nq (by linarith)


/-- Memory for storing task-specific adaptations -/
def taskAdaptMemory (numTasks adaptSize : ℕ) : ℕ :=
  numTasks * adaptSize


/-- [Section: ## §5. Task Distribution Memory] -/
theorem eml_task_memory_cheaper (nt as_eml as_std : ℕ) (has : as_eml ≤ as_std) :
    taskAdaptMemory nt as_eml ≤ taskAdaptMemory nt as_std := by
  -- Since $as_eml \leq as_std$, multiplying both sides by $nt$ (which is non-negative) preserves the inequality.
  apply mul_le_mul_left' has


/-- Second-order (Hessian-vector product) cost -/
def secondOrderCost (modelParams batchSize : ℕ) : ℕ :=
  2 * batchSize * modelParams


/-- [Section: ## §6. Second-Order Gradient Cost] -/
theorem eml_second_order_cheaper (mp_eml mp_std bs : ℕ) (hmp : mp_eml ≤ mp_std) :
    secondOrderCost mp_eml bs ≤ secondOrderCost mp_std bs := by
  unfold secondOrderCost; gcongr;


end
