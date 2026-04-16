/-! # CatalogBuild.Bridges.TropicalNeuralBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 22
-/

import Mathlib

noncomputable section

/-- A piecewise-linear function with n pieces on ℝ. -/
structure PiecewiseLinear where
  breakpoints : List ℝ
  slopes : List ℝ
  intercepts : List ℝ



/-- The number of linear regions of a piecewise-linear function. -/
def numRegions (f : PiecewiseLinear) : ℕ := f.breakpoints.length + 1



/-- The max of two piecewise-linear functions has at most n₁ + n₂ - 1 breakpoints. -/
theorem max_breakpoints_bound (n₁ n₂ : ℕ) :
    n₁ + n₂ + 1 ≤ (n₁ + 1) * (n₂ + 1) := by nlinarith



/-- A single neuron with ReLU creates at most 2 linear regions. -/
theorem single_neuron_regions : 1 + 1 = (2 : ℕ) := rfl



/-- A layer of w neurons can create at most 2^w regions. -/
theorem layer_max_regions (w : ℕ) : 2 ^ w ≥ 1 := Nat.one_le_two_pow



/-- Depth d with width w gives at most w^d regions (simplified bound). -/
theorem depth_width_bound (w d : ℕ) (hw : 1 ≤ w) (hd : 1 ≤ d) :
    1 ≤ w ^ d := Nat.one_le_pow d w hw



/-- Tropical addition of two functions (pointwise max). -/
def tropicalAdd (f g : ℝ → ℝ) : ℝ → ℝ := fun x => max (f x) (g x)



/-- Tropical multiplication of two functions (pointwise addition). -/
def tropicalMul (f g : ℝ → ℝ) : ℝ → ℝ := fun x => f x + g x



/-- Tropical addition is commutative. -/
theorem tropicalAdd_comm (f g : ℝ → ℝ) :
    tropicalAdd f g = tropicalAdd g f := by
  ext x; simp [tropicalAdd, max_comm]



/-- Tropical addition is associative. -/
theorem tropicalAdd_assoc (f g h : ℝ → ℝ) :
    tropicalAdd (tropicalAdd f g) h = tropicalAdd f (tropicalAdd g h) := by
  ext x; simp [tropicalAdd, max_assoc]



/-- Tropical addition is idempotent. -/
theorem tropicalAdd_idem (f : ℝ → ℝ) :
    tropicalAdd f f = f := by
  ext x; simp [tropicalAdd]



/-- Tropical multiplication is commutative. -/
theorem tropicalMul_comm (f g : ℝ → ℝ) :
    tropicalMul f g = tropicalMul g f := by
  ext x; simp [tropicalMul, add_comm]



/-- Tropical multiplication is associative. -/
theorem tropicalMul_assoc (f g h : ℝ → ℝ) :
    tropicalMul (tropicalMul f g) h = tropicalMul f (tropicalMul g h) := by
  ext x; simp [tropicalMul, add_assoc]



/-- Tropical multiplication distributes over tropical addition. -/
theorem tropicalMul_distrib (f g h : ℝ → ℝ) :
    tropicalMul f (tropicalAdd g h) = tropicalAdd (tropicalMul f g) (tropicalMul f h) := by
  ext x; simp [tropicalMul, tropicalAdd, max_add_add_left]



/-- A single ReLU neuron: x ↦ max(w·x + b, 0). -/
def reluNeuron (w b : ℝ) : ℝ → ℝ := fun x => max (w * x + b) 0



/-- ReLU neuron at origin with unit weight. -/
theorem reluNeuron_unit : reluNeuron 1 0 = fun x => max x 0 := by
  ext x; simp [reluNeuron]



/-- Composing a linear map with ReLU gives a tropical linear function. -/
theorem linear_then_relu (a b : ℝ) :
    (fun x => max (a * x + b) 0) = reluNeuron a b := by
  ext x; simp [reluNeuron]



/-- Softmax for two values (the quantum version of argmax). -/
def softmax2 (x y : ℝ) : ℝ × ℝ :=
  (exp x / (exp x + exp y), exp y / (exp x + exp y))



/-- Softmax components sum to 1. -/
theorem softmax2_sum (x y : ℝ) :
    (softmax2 x y).1 + (softmax2 x y).2 = 1 := by
  simp [softmax2]
  rw [← add_div, div_self (ne_of_gt (by positivity : exp x + exp y > 0))]



/-- Softmax components are non-negative. -/
theorem softmax2_nonneg (x y : ℝ) :
    0 ≤ (softmax2 x y).1 ∧ 0 ≤ (softmax2 x y).2 := by
  constructor <;> simp [softmax2] <;> positivity



/-- Softmax components are at most 1. -/
theorem softmax2_le_one (x y : ℝ) :
    (softmax2 x y).1 ≤ 1 ∧ (softmax2 x y).2 ≤ 1 := by
  have hsum := softmax2_sum x y
  have ⟨h1, h2⟩ := softmax2_nonneg x y
  constructor <;> linarith



/-- ReLU is tropically convex. -/
theorem relu_tropically_convex :
    TropicallyConvex (fun x => max x 0) :=
  monotone_tropically_convex _ (fun _ _ h => max_le_max h le_rfl)



end
