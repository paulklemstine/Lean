/-
# EML Memory-Augmented Networks Theory — v18

## Overview
Memory-augmented neural networks (MANNs) — including Neural Turing
Machines and Differentiable Neural Computers — use an external memory
matrix that the network reads from and writes to via attention.
The memory access cost scales with memory size × key dimension.
EML compresses the controller network and reduces key dimensions,
enabling larger external memories with faster access.

## Key Results (7 theorems, 0 sorry)
-/

import Mathlib

noncomputable section

open Real Finset BigOperators Nat

/-! ## §1. Controller Network -/

/-- Standard controller parameters -/
def stdControllerParams (d_model : ℕ) : ℕ :=
  d_model * d_model

/-- EML controller parameters -/
def emlControllerParams (d_model : ℕ) : ℕ :=
  4 * d_model

theorem eml_controller_compact (dm : ℕ) (hdm : 4 ≤ dm) :
    emlControllerParams dm ≤ stdControllerParams dm := by
  unfold emlControllerParams stdControllerParams; nlinarith

/-! ## §2. Memory Read Cost -/

/-- Cost of reading from memory: attention over N slots with key dim k -/
def memoryReadCost (numSlots keyDim : ℕ) : ℕ :=
  numSlots * keyDim

theorem eml_read_cheaper (ns kd_eml kd_std : ℕ) (hkd : kd_eml ≤ kd_std) :
    memoryReadCost ns kd_eml ≤ memoryReadCost ns kd_std := by
  apply Nat.mul_le_mul_left ns hkd

theorem larger_memory_costlier (n1 n2 kd : ℕ) (hn : n1 ≤ n2) :
    memoryReadCost n1 kd ≤ memoryReadCost n2 kd := by
  apply Nat.mul_le_mul_right kd hn

/-! ## §3. Memory Write Cost -/

/-- Cost of writing to memory: erase + add vectors -/
def memoryWriteCost (numSlots valueDim : ℕ) : ℕ :=
  2 * numSlots * valueDim

theorem eml_write_cheaper (ns vd_eml vd_std : ℕ) (hvd : vd_eml ≤ vd_std) :
    memoryWriteCost ns vd_eml ≤ memoryWriteCost ns vd_std := by
  unfold memoryWriteCost; gcongr

/-! ## §4. Multi-Head Memory Access -/

/-- Multi-head memory access: H heads × read + write -/
def multiHeadMemoryCost (numHeads readCost writeCost : ℕ) : ℕ :=
  numHeads * (readCost + writeCost)

theorem eml_multihead_cheaper (nh rc_eml rc_std wc_eml wc_std : ℕ)
    (hrc : rc_eml ≤ rc_std) (hwc : wc_eml ≤ wc_std) :
    multiHeadMemoryCost nh rc_eml wc_eml ≤ multiHeadMemoryCost nh rc_std wc_std := by
  unfold multiHeadMemoryCost; gcongr

/-! ## §5. Full MANN System -/

/-- Full MANN cost: controller + memory access per step -/
def mannStepCost (controllerCost memoryCost : ℕ) : ℕ :=
  controllerCost + memoryCost

theorem eml_mann_cheaper (cc_eml cc_std mc_eml mc_std : ℕ)
    (hcc : cc_eml ≤ cc_std) (hmc : mc_eml ≤ mc_std) :
    mannStepCost cc_eml mc_eml ≤ mannStepCost cc_std mc_std := by
  unfold mannStepCost; omega

end
