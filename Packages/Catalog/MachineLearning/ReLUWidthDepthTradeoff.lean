import Mathlib
import MachineLearning.Neural.AlgebraicNeuralArchitecture

/-! # ReLU width--depth capacity trade-offs

This file gives a kernel-checked quantitative core for width--depth comparisons.
It uses the catalog's `AlgebraicNeural.ReLU` rather than introducing another
activation.  The capacity model counts the number of cells available to a
piecewise-affine realization: a width `w`, depth `L` architecture has capacity
`(w+1)^L`.  This is the standard combinatorial quantity behind region-count
arguments.

The statements below deliberately distinguish *capacity bounds* from a full
analytic universal-approximation theorem.  In particular, continuity alone has
no function-independent approximation rate.  The proved results quantify the
architectural resources needed once an approximation requires a specified
number of cells.
-/

open Finset BigOperators

namespace ReLUWidthDepth

noncomputable section

open AlgebraicNeural

/-- A scalar one-hidden-layer ReLU realization with `w` hidden neurons. -/
def shallowEval {w : ℕ} (outputBias : ℝ) (outputWeight inputWeight bias : Fin w → ℝ)
    (x : ℝ) : ℝ :=
  outputBias + ∑ i, outputWeight i * ReLU (inputWeight i * x + bias i)

/-- Every scalar shallow ReLU realization is continuous. -/
theorem continuous_shallowEval {w : ℕ} (outputBias : ℝ)
    (outputWeight inputWeight bias : Fin w → ℝ) :
    Continuous (shallowEval outputBias outputWeight inputWeight bias) := by
  have hrelu : Continuous (ReLU : ℝ → ℝ) := by
    simpa [ReLU] using (continuous_id.max continuous_const)
  unfold shallowEval
  fun_prop

/-- Two ReLU neurons exactly realize the identity map. -/
theorem two_relu_identity (x : ℝ) : ReLU x - ReLU (-x) = x := by
  exact (relu_pos_neg_decomposition x).symm

/-- The three-neuron tent map, a basic depth-separation building block. -/
def tent (x : ℝ) : ℝ := ReLU x - 2 * ReLU (x - 1) + ReLU (x - 2)

/-- The tent map interpolates the values `0, 1, 0` at `0, 1, 2`. -/
theorem tent_key_values : tent 0 = 0 ∧ tent 1 = 1 ∧ tent 2 = 0 := by
  norm_num [tent, ReLU]

/-- Iterated composition of the tent map, corresponding to increasing depth. -/
def iteratedTent : ℕ → ℝ → ℝ
  | 0 => id
  | L + 1 => tent ∘ iteratedTent L

/-- Iterating one additional layer is composition by `tent`. -/
theorem iteratedTent_succ (L : ℕ) (x : ℝ) :
    iteratedTent (L + 1) x = tent (iteratedTent L x) := by
  rfl

/-- Region-capacity model for width `w` and depth `L`. -/
def regionCapacity (w L : ℕ) : ℕ := (w + 1) ^ L

/-- Increasing width cannot decrease region capacity. -/
theorem regionCapacity_mono_width {w₁ w₂ L : ℕ} (h : w₁ ≤ w₂) :
    regionCapacity w₁ L ≤ regionCapacity w₂ L := by
  exact Nat.pow_le_pow_left (Nat.add_le_add_right h 1) L

/-- Increasing positive-base depth cannot decrease region capacity. -/
theorem regionCapacity_mono_depth (w : ℕ) {L₁ L₂ : ℕ} (h : L₁ ≤ L₂) :
    regionCapacity w L₁ ≤ regionCapacity w L₂ := by
  unfold regionCapacity
  exact Nat.pow_le_pow_right (by omega) h

/-- The exact shallow width needed for `m^n` cells in the capacity model. -/
theorem shallow_width_for_power_cells (m n : ℕ) (hm : 0 < m) :
    regionCapacity (m - 1) n = m ^ n := by
  simp [regionCapacity, Nat.sub_add_cancel hm]

/-- A shallow architecture with fewer than `m-1` neurons cannot attain `m^n`
cell capacity when the dimension exponent is positive. -/
theorem shallow_width_lower_bound {m n w : ℕ} (hm : 0 < m) (hn : 0 < n)
    (hcap : m ^ n ≤ regionCapacity w n) :
    m - 1 ≤ w := by
  unfold regionCapacity at hcap
  have hbase : m ≤ w + 1 := by
    by_contra h
    have hlt : w + 1 < m := Nat.lt_of_not_ge h
    have hp : (w + 1) ^ n < m ^ n := Nat.pow_lt_pow_left hlt (Nat.ne_of_gt hn)
    omega
  omega

/-- At base `w+1 ≥ 2`, ceiling logarithmic depth supplies any requested
finite cell capacity. -/
theorem logarithmic_depth_suffices (w q : ℕ) (hw : 0 < w) :
    q ≤ regionCapacity w (Nat.clog (w + 1) q) := by
  unfold regionCapacity
  exact Nat.le_pow_clog (by omega) q

/-- Error-scale demand: `m^n` cells corresponds to the common scaling
`ε = 1 / m^n`; the shallow width `m-1` therefore has the encoded
`ε^(-1/n)` behavior. -/
def approximationCellDemand (n m : ℕ) : ℕ := m ^ n

/-- Width `m-1` exactly meets the `m^n` approximation-cell demand. -/
theorem shallow_epsilon_inverse_root_rate (n m : ℕ) (hm : 0 < m) :
    regionCapacity (m - 1) n = approximationCellDemand n m := by
  exact shallow_width_for_power_cells m n hm

/-- Width `n+4` meets the same demand at a ceiling-logarithmic depth. -/
theorem width_n_add_four_log_depth_rate (n m : ℕ) :
    approximationCellDemand n m ≤
      regionCapacity (n + 4) (Nat.clog (n + 5) (approximationCellDemand n m)) := by
  apply logarithmic_depth_suffices
  omega

/-- The cell demand is monotone in inverse error resolution `m`. -/
theorem approximationCellDemand_mono {n m₁ m₂ : ℕ} (h : m₁ ≤ m₂) :
    approximationCellDemand n m₁ ≤ approximationCellDemand n m₂ := by
  exact Nat.pow_le_pow_left h n

/-- A depth `L+1`, width `w` capacity witness is strictly larger than the
capacity of depth `L` at the same positive width. -/
theorem strict_depth_capacity_separation (w L : ℕ) (hw : 0 < w) :
    regionCapacity w L < regionCapacity w (L + 1) := by
  unfold regionCapacity
  rw [pow_succ]
  nlinarith [Nat.one_le_pow L (w + 1) (by omega)]

/-- A depth-one network needs exponentially many neurons to match the capacity
of a width-`w`, depth-`L+1` witness.  This is an explicit depth-separation
size lower bound in the region-capacity model. -/
theorem shallow_exponential_size_lower_bound {w L v : ℕ}
    (hmatch : regionCapacity w (L + 1) ≤ regionCapacity v 1) :
    (w + 1) ^ (L + 1) - 1 ≤ v := by
  simp only [regionCapacity, pow_one] at hmatch
  omega

/-- The exponential shallow width is also sufficient, so the preceding bound
is sharp in this capacity model. -/
theorem shallow_exponential_size_exact (w L : ℕ) :
    regionCapacity ((w + 1) ^ (L + 1) - 1) 1 = regionCapacity w (L + 1) := by
  unfold regionCapacity
  rw [pow_one, Nat.sub_add_cancel]
  exact Nat.one_le_pow _ _ (by omega)

/-- More generally, at positive depth and width, any depth-`L` competitor
matching the capacity of a width-`w`, depth-`L+1` witness must be strictly wider
than `w`.  Thus one extra layer cannot be compensated while keeping the same
(or a smaller) width. -/
theorem depth_separation_power_lower_bound {w v L : ℕ} (hw : 0 < w)
    (hmatch : regionCapacity w (L + 1) ≤ regionCapacity v L) :
    w < v := by
  by_contra h
  have hvw : v ≤ w := Nat.le_of_not_gt h
  have hpow : regionCapacity v L ≤ regionCapacity w L :=
    regionCapacity_mono_width hvw
  have hstrict : regionCapacity w L < regionCapacity w (L + 1) :=
    strict_depth_capacity_separation w L hw
  omega

end

end ReLUWidthDepth