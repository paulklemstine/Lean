/-! # CatalogBuild.EML.AIResearch.StateSpaceModelTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 27
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.EML.AIResearch.StateSpaceModelTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 27] -/
def ssmTransition (a delta : ℝ) : ℝ := Real.exp (delta * a)



theorem ssm_transition_pos (a delta : ℝ) : 0 < ssmTransition a delta :=
  Real.exp_pos _



theorem negative_eigenvalue_contracts (a delta : ℝ) (ha : a < 0) (hd : 0 < delta) :
    ssmTransition a delta < 1 := by
  unfold ssmTransition; rw [Real.exp_lt_one_iff]; exact mul_neg_of_pos_of_neg hd ha



theorem more_negative_faster_decay (a1 a2 delta : ℝ) (hd : 0 < delta) (ha : a1 ≤ a2) :
    ssmTransition a1 delta ≤ ssmTransition a2 delta := by
  unfold ssmTransition; exact Real.exp_le_exp.mpr (by nlinarith)



def stdSSMParams (stateDim inputDim : ℕ) : ℕ :=
  stateDim * stateDim + 2 * stateDim * inputDim + inputDim



def emlSSMParams (stateDim inputDim : ℕ) : ℕ :=
  stateDim + 8 * inputDim + inputDim



theorem eml_ssm_efficiency (s i : ℕ) (hs : 9 ≤ s) :
    emlSSMParams s i ≤ stdSSMParams s i := by
  unfold emlSSMParams stdSSMParams; nlinarith



def mambaSelectParams (d_model d_inner : ℕ) : ℕ := d_model * d_inner


def emlMambaParams (d_model : ℕ) : ℕ := 4 * d_model



theorem eml_mamba_efficiency (dm di : ℕ) (hdi : 4 ≤ di) :
    emlMambaParams dm ≤ mambaSelectParams dm di := by
  unfold emlMambaParams mambaSelectParams
  calc 4 * dm = dm * 4 := by ring
    _ ≤ dm * di := Nat.mul_le_mul_left dm hdi



def stdKernelCost (stateDim seqLen : ℕ) : ℕ := stateDim * seqLen


def emlKernelCost (seqLen : ℕ) : ℕ := 4 * seqLen



theorem eml_kernel_efficiency (n l : ℕ) (hn : 4 ≤ n) :
    emlKernelCost l ≤ stdKernelCost n l := by
  unfold emlKernelCost stdKernelCost; exact Nat.mul_le_mul_right l hn



def parallelScanWork (seqLen : ℕ) : ℕ := seqLen * Nat.log 2 seqLen


def emlParallelScanWork (seqLen opCostRatio : ℕ) : ℕ :=
  seqLen * Nat.log 2 seqLen / opCostRatio



theorem eml_parallel_scan_cheaper (l r : ℕ) :
    emlParallelScanWork l r ≤ parallelScanWork l := by
  unfold emlParallelScanWork parallelScanWork; exact Nat.div_le_self _ _



def memoryRetention (decay : ℝ) (k : ℕ) : ℝ := decay ^ k



theorem memory_decays (d : ℝ) (k1 k2 : ℕ) (hd0 : 0 ≤ d) (hd1 : d ≤ 1) (hk : k1 ≤ k2) :
    memoryRetention d k2 ≤ memoryRetention d k1 := by
  unfold memoryRetention; exact pow_le_pow_of_le_one hd0 hd1 hk



theorem higher_decay_more_memory (d1 d2 : ℝ) (k : ℕ) (hd1 : 0 ≤ d1)
    (h : d1 ≤ d2) :
    memoryRetention d1 k ≤ memoryRetention d2 k := by
  unfold memoryRetention; gcongr



def denseInitCost (stateDim : ℕ) : ℕ := stateDim * stateDim


def emlInitCost (stateDim rank : ℕ) : ℕ := stateDim + 2 * stateDim * rank



theorem eml_init_cheaper (n r : ℕ) (hr : 2 * r + 1 ≤ n) :
    emlInitCost n r ≤ denseInitCost n := by
  unfold emlInitCost denseInitCost; nlinarith



def hybridStdParams (ssmLayers attnLayers d_model : ℕ) : ℕ :=
  ssmLayers * d_model * d_model + attnLayers * d_model * d_model



def hybridEMLParams (ssmLayers attnLayers d_model : ℕ) : ℕ :=
  ssmLayers * 4 * d_model + attnLayers * 8 * d_model



theorem eml_hybrid_efficiency (sL aL d : ℕ) (hd : 8 ≤ d) :
    hybridEMLParams sL aL d ≤ hybridStdParams sL aL d := by
  unfold hybridEMLParams hybridStdParams
  have h1 : sL * 4 ≤ sL * d := Nat.mul_le_mul_left sL (by omega)
  have h2 : aL * 8 ≤ aL * d := Nat.mul_le_mul_left aL hd
  have h3 : sL * 4 * d ≤ sL * d * d := Nat.mul_le_mul_right d h1
  have h4 : aL * 8 * d ≤ aL * d * d := Nat.mul_le_mul_right d h2
  omega



def discretizationError (stepSize : ℝ) : ℝ := stepSize ^ 2



theorem smaller_step_less_error (s1 s2 : ℝ) (hs1 : 0 ≤ s1) (_ : 0 ≤ s2) (h : s1 ≤ s2) :
    discretizationError s1 ≤ discretizationError s2 := by
  unfold discretizationError; exact sq_le_sq' (by linarith) h



end
