import Mathlib

/-! # CatalogBuild.EML.AIResearch.MemoryAugmentedTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 12
-/

noncomputable section

/-- Standard controller parameters -/
def stdControllerParams (d_model : ℕ) : ℕ :=
  d_model * d_model

/-- EML controller parameters -/
def emlControllerParams (d_model : ℕ) : ℕ :=
  4 * d_model

/-- [Section: ## §1. Controller Network] -/
theorem eml_controller_compact (dm : ℕ) (hdm : 4 ≤ dm) :
    emlControllerParams dm ≤ stdControllerParams dm := by
  unfold emlControllerParams stdControllerParams; nlinarith

/-- Cost of reading from memory: attention over N slots with key dim k -/
def memoryReadCost (numSlots keyDim : ℕ) : ℕ :=
  numSlots * keyDim

/-- [Section: ## §2. Memory Read Cost] -/
theorem eml_read_cheaper (ns kd_eml kd_std : ℕ) (hkd : kd_eml ≤ kd_std) :
    memoryReadCost ns kd_eml ≤ memoryReadCost ns kd_std := by
  apply Nat.mul_le_mul_left ns hkd

theorem larger_memory_costlier (n1 n2 kd : ℕ) (hn : n1 ≤ n2) :
    memoryReadCost n1 kd ≤ memoryReadCost n2 kd := by
  apply Nat.mul_le_mul_right kd hn

/-- Cost of writing to memory: erase + add vectors -/
def memoryWriteCost (numSlots valueDim : ℕ) : ℕ :=
  2 * numSlots * valueDim

/-- [Section: ## §3. Memory Write Cost] -/
theorem eml_write_cheaper (ns vd_eml vd_std : ℕ) (hvd : vd_eml ≤ vd_std) :
    memoryWriteCost ns vd_eml ≤ memoryWriteCost ns vd_std := by
  unfold memoryWriteCost; gcongr

/-- Multi-head memory access: H heads × read + write -/
def multiHeadMemoryCost (numHeads readCost writeCost : ℕ) : ℕ :=
  numHeads * (readCost + writeCost)

/-- [Section: ## §4. Multi-Head Memory Access] -/
theorem eml_multihead_cheaper (nh rc_eml rc_std wc_eml wc_std : ℕ)
    (hrc : rc_eml ≤ rc_std) (hwc : wc_eml ≤ wc_std) :
    multiHeadMemoryCost nh rc_eml wc_eml ≤ multiHeadMemoryCost nh rc_std wc_std := by
  unfold multiHeadMemoryCost; gcongr

/-- Full MANN cost: controller + memory access per step -/
def mannStepCost (controllerCost memoryCost : ℕ) : ℕ :=
  controllerCost + memoryCost

/-- [Section: ## §5. Full MANN System] -/
theorem eml_mann_cheaper (cc_eml cc_std mc_eml mc_std : ℕ)
    (hcc : cc_eml ≤ cc_std) (hmc : mc_eml ≤ mc_std) :
    mannStepCost cc_eml mc_eml ≤ mannStepCost cc_std mc_std := by
  unfold mannStepCost; omega

end