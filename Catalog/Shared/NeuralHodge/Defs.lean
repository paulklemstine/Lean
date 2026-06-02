/-
# Neural Network Decision Surface Topology: Definitions

This module defines the combinatorial and topological structures arising from
ReLU neural network decision surfaces, including activation patterns,
polyhedral f-vectors, and the neural complexity measure.

## Main Definitions

* `relu` — The ReLU activation function max(0, x)
* `NetworkArch` — Architecture of a feedforward ReLU network
* `PolyhedralFVector` — The f-vector of a polyhedral complex
* `NeuralComplexity` — Topological complexity measure for decision surfaces
* `zaslavskyBound` — Upper bound on regions from a hyperplane arrangement
-/

import Mathlib

open Finset BigOperators

/-! ## ReLU Function -/

/-- The Rectified Linear Unit (ReLU) activation function. -/
noncomputable def relu (x : ℝ) : ℝ := max 0 x

/-- ReLU of a nonneg value is the value itself. -/
theorem relu_of_nonneg {x : ℝ} (hx : 0 ≤ x) : relu x = x := by
  simp [relu, max_eq_right hx]

/-- ReLU of a nonpositive value is zero. -/
theorem relu_of_nonpos {x : ℝ} (hx : x ≤ 0) : relu x = 0 := by
  simp [relu, max_eq_left hx]

/-- ReLU is nonnegative. -/
theorem relu_nonneg (x : ℝ) : 0 ≤ relu x := le_max_left 0 x

/-- ReLU is monotone. -/
theorem relu_mono : Monotone relu := fun _ _ h => max_le_max_left 0 h

/-
ReLU is 1-Lipschitz: |relu(x) - relu(y)| ≤ |x - y| for all x, y.
-/
theorem relu_lipschitz (x y : ℝ) : |relu x - relu y| ≤ |x - y| := by
  unfold relu; cases max_cases ( 0 : ℝ ) x <;> cases max_cases ( 0 : ℝ ) y <;> cases abs_cases ( x - y ) <;> cases abs_cases ( Max.max 0 x - Max.max 0 y ) <;> linarith;

/-
ReLU is idempotent on nonneg: relu(relu(x)) = relu(x).
-/
theorem relu_idempotent (x : ℝ) : relu (relu x) = relu x := by
  exact relu_of_nonneg ( relu_nonneg x )

/-! ## Network Architecture -/

/-- Architecture of a feedforward ReLU network.
  `inputDim` is the input dimension, `hiddenWidths` lists the width of each hidden layer.
  The output is 1-dimensional. -/
structure NetworkArch where
  inputDim : ℕ
  hiddenWidths : List ℕ
  inputPos : 0 < inputDim

/-- The depth (number of hidden layers) of a network. -/
def NetworkArch.depth (arch : NetworkArch) : ℕ := arch.hiddenWidths.length

/-- Total number of hidden neurons. -/
def NetworkArch.totalNeurons (arch : NetworkArch) : ℕ := arch.hiddenWidths.sum

/-! ## Hyperplane Arrangement Bounds -/

/-- The Zaslavsky bound: the maximum number of regions created by w hyperplanes
    in general position in ℝⁿ. This equals Σ_{k=0}^{min(n,w)} C(w,k). -/
def zaslavskyBound (n w : ℕ) : ℕ :=
  ∑ k ∈ Finset.range (min n w + 1), w.choose k

/-
The Zaslavsky bound with 0 hyperplanes is 1 (a single region).
-/
theorem zaslavsky_zero_hyperplanes (n : ℕ) : zaslavskyBound n 0 = 1 := by
  unfold zaslavskyBound; norm_num;

/-
The Zaslavsky bound is at most 2^w (since it's a partial sum of binomial coefficients).
-/
theorem zaslavsky_le_pow (n w : ℕ) : zaslavskyBound n w ≤ 2 ^ w := by
  rw [ ← Nat.sum_range_choose ];
  exact Finset.sum_le_sum_of_subset ( Finset.range_mono ( Nat.succ_le_succ ( min_le_right _ _ ) ) )

/-
The Zaslavsky bound is at least 1 for any arrangement.
-/
theorem zaslavsky_pos (n w : ℕ) : 0 < zaslavskyBound n w := by
  exact Finset.sum_pos ( fun _ _ => Nat.choose_pos ( by linarith [ Finset.mem_range.mp ‹_›, min_le_left n w, min_le_right n w ] ) ) ( by norm_num )

/-
The Zaslavsky bound is monotone in w: more hyperplanes → more regions.
-/
theorem zaslavsky_mono_w (n : ℕ) {w₁ w₂ : ℕ} (h : w₁ ≤ w₂) :
    zaslavskyBound n w₁ ≤ zaslavskyBound n w₂ := by
  exact Finset.sum_le_sum_of_subset ( Finset.range_mono ( Nat.succ_le_succ ( min_le_min_left _ h ) ) ) |> le_trans <| Finset.sum_le_sum fun _ _ => Nat.choose_le_choose _ h

/-! ## Polyhedral Complex F-Vector -/

/-- The f-vector of a polyhedral complex of ambient dimension n.
    `faces k` is the number of k-dimensional faces.
    The f-vector satisfies: faces k = 0 for k > ambientDim. -/
structure PolyhedralFVector (n : ℕ) where
  faces : ℕ → ℕ
  vanish_above : ∀ k, n < k → faces k = 0

/-- Total number of faces in a polyhedral complex. -/
def PolyhedralFVector.totalFaces {n : ℕ} (f : PolyhedralFVector n) : ℕ :=
  ∑ k ∈ Finset.range (n + 1), f.faces k

/-- The Euler characteristic of a polyhedral complex, computed from the f-vector. -/
noncomputable def PolyhedralFVector.eulerChar {n : ℕ} (f : PolyhedralFVector n) : ℤ :=
  ∑ k ∈ Finset.range (n + 1), (-1 : ℤ) ^ k * (f.faces k : ℤ)

/-! ## Neural Complexity -/

/-- The neural complexity of a network architecture measures the maximum topological
    complexity of its decision surface. It is defined as the product of per-layer
    Zaslavsky bounds. This bounds the number of linear regions and hence the
    topological complexity of the decision boundary. -/
def neuralComplexity (arch : NetworkArch) : ℕ :=
  arch.hiddenWidths.foldl (fun acc w => acc * zaslavskyBound arch.inputDim w) 1

/-
Simplified upper bound: neural complexity ≤ 2^{total neurons}.
-/
theorem neuralComplexity_le_pow (arch : NetworkArch) :
    neuralComplexity arch ≤ 2 ^ arch.totalNeurons := by
  unfold neuralComplexity;
  convert List.prod_le_prod' fun w hw => zaslavsky_le_pow arch.inputDim w using 1;
  any_goals exact arch.hiddenWidths;
  · induction arch.hiddenWidths using List.reverseRecOn <;> aesop;
  · unfold NetworkArch.totalNeurons; induction arch.hiddenWidths <;> simp +decide [ *, pow_add ] ;

/-! ## Activation Pattern -/

/-- An activation pattern for a layer of width w records which neurons are active (output > 0).
    This is a function from neuron index to Bool. -/
def ActivationPattern (w : ℕ) := Fin w → Bool

instance activationPatternFintype (w : ℕ) : Fintype (ActivationPattern w) :=
  inferInstanceAs (Fintype (Fin w → Bool))

/-
The number of possible activation patterns for a layer of width w is 2^w.
-/
theorem card_activation_pattern (w : ℕ) :
    Fintype.card (ActivationPattern w) = 2 ^ w := by
  convert Fintype.card_fun ( α := Fin w ) ( β := Bool );
  norm_num

/-- A full activation pattern for a network records activation patterns for each layer. -/
def FullActivationPattern (arch : NetworkArch) :=
  (i : Fin arch.depth) → ActivationPattern (arch.hiddenWidths.get i)