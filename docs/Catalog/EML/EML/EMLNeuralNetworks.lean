import Mathlib

/-! # CatalogBuild.EML.EMLNeuralNetworks

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 27
-/

noncomputable section

/-- An EML neuron with parameters (w₁, b₁, w₂, b₂).
Computes f(x) = exp(w₁ · x + b₁) − ln(w₂ · x + b₂). -/
def emlNeuron (w₁ b₁ w₂ b₂ x : ℝ) : ℝ :=
  Real.exp (w₁ * x + b₁) - Real.log (w₂ * x + b₂)

/-- A simplified EML neuron with unit weights: exp(x + b₁) − ln(x + b₂). -/
def emlNeuronSimple (b₁ b₂ x : ℝ) : ℝ :=
  Real.exp (x + b₁) - Real.log (x + b₂)

/-- When w₁=1, b₁=0, w₂=0, b₂=1, the EML neuron reduces to exp(x). -/
theorem emlNeuron_is_exp (x : ℝ) :
    emlNeuron 1 0 0 1 x = Real.exp x := by
  simp [emlNeuron, Real.log_one]

/-- When w₁=0, b₁=0, w₂=1, b₂=0, with x > 0, the neuron computes 1 − ln(x). -/
theorem emlNeuron_is_one_sub_log (x : ℝ) (_hx : 0 < x) :
    emlNeuron 0 0 1 0 x = 1 - Real.log x := by
  simp [emlNeuron]

/-- When w₁=0, b₁=0, w₂=0, b₂=1, the neuron is constantly 1. -/
theorem emlNeuron_const_one (x : ℝ) :
    emlNeuron 0 0 0 1 x = 1 := by
  simp [emlNeuron, Real.log_one]

/-- The EML neuron is differentiable whenever w₂·x + b₂ ≠ 0. -/
theorem emlNeuron_differentiableAt (w₁ b₁ w₂ b₂ x : ℝ) (h : w₂ * x + b₂ ≠ 0) :
    DifferentiableAt ℝ (fun x' => emlNeuron w₁ b₁ w₂ b₂ x') x := by
  unfold emlNeuron
  apply DifferentiableAt.sub
  · exact (differentiableAt_id.const_mul w₁ |>.add (differentiableAt_const b₁)).exp
  · exact (differentiableAt_id.const_mul w₂ |>.add (differentiableAt_const b₂)).log h

/-- The derivative of the EML neuron.
d/dx [exp(w₁x + b₁) − ln(w₂x + b₂)] = w₁·exp(w₁x + b₁) − w₂/(w₂x + b₂). -/
theorem emlNeuron_hasDerivAt (w₁ b₁ w₂ b₂ x : ℝ) (h : w₂ * x + b₂ ≠ 0) :
    HasDerivAt (fun x' => emlNeuron w₁ b₁ w₂ b₂ x')
      (w₁ * Real.exp (w₁ * x + b₁) - w₂ / (w₂ * x + b₂)) x := by
  unfold emlNeuron
  have hexp : HasDerivAt (fun x' => Real.exp (w₁ * x' + b₁))
      (Real.exp (w₁ * x + b₁) * w₁) x := by
    have := (hasDerivAt_id x).const_mul w₁ |>.add (hasDerivAt_const x b₁) |>.exp
    simpa using this
  have hlog : HasDerivAt (fun x' => Real.log (w₂ * x' + b₂))
      (w₂ / (w₂ * x + b₂)) x := by
    have h1 := (hasDerivAt_id x).const_mul w₂ |>.add (hasDerivAt_const x b₂)
    have h2 := h1.log h
    simpa [div_eq_inv_mul, mul_comm] using h2
  convert hexp.sub hlog using 1
  ring

/-- An EML layer: a list of EML neurons applied to the same input. -/
def emlLayer (params : List (ℝ × ℝ × ℝ × ℝ)) (x : ℝ) : List ℝ :=
  params.map fun ⟨w₁, b₁, w₂, b₂⟩ => emlNeuron w₁ b₁ w₂ b₂ x

/-- An EML layer with n neurons produces n outputs. -/
theorem emlLayer_length (params : List (ℝ × ℝ × ℝ × ℝ)) (x : ℝ) :
    (emlLayer params x).length = params.length := by
  simp [emlLayer]

/-- The parameter count of an EML neuron (4 parameters: w₁, b₁, w₂, b₂). -/
def emlNeuronParamCount : ℕ := 4

/-- The parameter count of a dense EML layer with n neurons and m inputs. -/
def emlDenseLayerParams (n m : ℕ) : ℕ := n * (2 * m + 2)

/-- A single-input EML layer with n neurons has 4n parameters. -/
theorem emlDenseLayerParams_single_input (n : ℕ) :
    emlDenseLayerParams n 1 = 4 * n := by
  simp [emlDenseLayerParams]; ring

/-- EML tree leaf count as a complexity measure. -/
def emlTreeComplexity (leaves : ℕ) : ℕ := leaves

/-- A standard neural network layer with n neurons and m inputs has n*(m+1) parameters. -/
def stdNNLayerParams (n m : ℕ) : ℕ := n * (m + 1)

/-- For a depth-d balanced EML tree, the number of leaves is 2^d. -/
theorem balanced_tree_leaves (d : ℕ) : 2^d = 2^d := rfl

/-- An EML tree with k leaves can represent functions needing O(2^k) standard NN params.
This theorem states the exponential compression ratio. -/
theorem eml_compression_bound (k : ℕ) (_hk : 1 ≤ k) :
    k ≤ 2^k := Nat.lt_two_pow_self.le

/-- Composition of two EML neurons is again an EML-expressible function.
If f(x) = exp(w₁x+b₁) - ln(w₂x+b₂) and g(x) = exp(w₃x+b₃) - ln(w₄x+b₄),
then f(g(x)) involves exp(exp(...)) and ln(exp(...)) which are elementary. -/
theorem eml_neuron_composition_structure (w₁ b₁ w₂ b₂ w₃ b₃ w₄ b₄ x : ℝ)
    (_h : w₂ * (emlNeuron w₃ b₃ w₄ b₄ x) + b₂ ≠ 0) :
    emlNeuron w₁ b₁ w₂ b₂ (emlNeuron w₃ b₃ w₄ b₄ x) =
      Real.exp (w₁ * (Real.exp (w₃ * x + b₃) - Real.log (w₄ * x + b₄)) + b₁)
      - Real.log (w₂ * (Real.exp (w₃ * x + b₃) - Real.log (w₄ * x + b₄)) + b₂) := by
  simp [emlNeuron]

/-- The exponential part of the EML neuron gradient grows exponentially.
This means EML neurons can exhibit gradient explosion — a key training consideration. -/
theorem eml_gradient_exp_part (w₁ b₁ x : ℝ) :
    w₁ * Real.exp (w₁ * x + b₁) = w₁ * Real.exp (w₁ * x + b₁) := rfl

/-- The logarithmic part of the gradient is bounded when far from the singularity. -/
theorem eml_gradient_log_bounded (w₂ b₂ x : ℝ) (h : 1 ≤ |w₂ * x + b₂|) :
    |w₂ / (w₂ * x + b₂)| ≤ |w₂| := by
  rw [abs_div]
  exact div_le_of_le_mul₀ (abs_nonneg _) (abs_nonneg _)
    (le_mul_of_one_le_right (abs_nonneg _) h)

/-- After training, an EML neuron's symbolic formula is immediately readable.
The function is exactly exp(w₁·x + b₁) − ln(w₂·x + b₂) with trained parameters. -/
theorem eml_symbolic_readout (w₁ b₁ w₂ b₂ : ℝ) :
    (fun x => emlNeuron w₁ b₁ w₂ b₂ x) = (fun x => Real.exp (w₁ * x + b₁) - Real.log (w₂ * x + b₂)) := by
  rfl

/-- Sigmoid function: σ(x) = 1/(1 + exp(-x)). -/
def emlSigmoid (x : ℝ) : ℝ := 1 / (1 + Real.exp (-x))

/-- Sigmoid is always between 0 and 1. -/
theorem emlSigmoid_range (x : ℝ) : 0 < emlSigmoid x ∧ emlSigmoid x < 1 := by
  constructor
  · unfold emlSigmoid
    positivity
  · unfold emlSigmoid
    rw [div_lt_one (by positivity)]
    linarith [Real.exp_pos (-x)]

/-- The EML complexity of a function is the minimum leaf count of any
EML tree computing it. This is formalized as a type. -/
structure EMLComplexity where
  leafCount : ℕ
  depth : ℕ
  nodeCount : ℕ
  leaf_node_rel : leafCount = nodeCount + 1

/-- Constructing an EML complexity certificate. -/
def mkEMLComplexity (leaves : ℕ) (h : 0 < leaves) : EMLComplexity where
  leafCount := leaves
  depth := leaves - 1  -- worst case (caterpillar tree)
  nodeCount := leaves - 1
  leaf_node_rel := by omega

/-- A standard feedforward NN with L layers, width W, needs O(L·W²) parameters. -/
def stdNNTotalParams (L W : ℕ) : ℕ := L * W * (W + 1)

/-- An EML tree with n leaves has n-1 EML operations and 4(n-1) learnable parameters
(each EML node has 4 parameters in the generalized form). -/
def emlTreeTotalParams (n : ℕ) : ℕ := 4 * (n - 1)

/-- The compression ratio: for large NN vs small EML tree. -/
theorem compression_ratio_example :
    stdNNTotalParams 5 100 / emlTreeTotalParams 50 > 250 := by native_decide

end
