-- import EML.Lean.SoftplusBasic
import Mathlib

/-! # CatalogBuild.EML.UniversalApproximation

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 29
-/

noncomputable section

/-- The `n`-th Catalan number.  (Supplied here as Mathlib's `catalan`: the
auto-generated file used `catalanNum` without carrying its definition along.) -/
def catalanNum (n : ℕ) : ℕ := catalan n

/-- An EML neuron function: f(x) = exp(w₁·x + b₁) − ln(w₂·x + b₂). -/
def emlNeuronFn (w₁ b₁ w₂ b₂ : ℝ) : ℝ → ℝ :=
  fun x => Real.exp (w₁ * x + b₁) - Real.log (w₂ * x + b₂)

/-- A single-layer EML network: weighted sum of EML neurons plus bias. -/
def emlNetworkLayer (neurons : List (ℝ × ℝ × ℝ × ℝ × ℝ)) (bias : ℝ) : ℝ → ℝ :=
  fun x => bias + (neurons.map fun ⟨α, w₁, b₁, w₂, b₂⟩ =>
    α * emlNeuronFn w₁ b₁ w₂ b₂ x).sum

/-- EML neurons separate points: for any two distinct points x₁ ≠ x₂,
there exists an EML neuron taking different values.
We use the pure exponential neuron (w₂=0, b₂=1) which gives exp(w₁x+b₁). -/
theorem eml_separates_points :
    ∀ x₁ x₂ : ℝ, x₁ ≠ x₂ →
    ∃ w₁ b₁ : ℝ, emlNeuronFn w₁ b₁ 0 1 x₁ ≠ emlNeuronFn w₁ b₁ 0 1 x₂ := by
  intro x₁ x₂ hne
  use 1, 0
  simp only [emlNeuronFn, Real.log_one, one_mul, zero_add, zero_mul, sub_zero]
  exact Real.exp_injective.ne (by simp; exact hne)

/-- EML neurons are nonvanishing: for any point x₀, there exists an EML neuron
that is nonzero at x₀. -/
theorem eml_nonvanishing (x₀ : ℝ) :
    ∃ w₁ b₁ : ℝ, emlNeuronFn w₁ b₁ 0 1 x₀ ≠ 0 := by
  use 0, 0
  simp only [emlNeuronFn, Real.log_one, zero_mul, zero_add, Real.exp_zero, sub_zero]
  exact one_ne_zero

/-- The exp-only EML neuron is continuous everywhere. -/
theorem eml_exp_neuron_continuous (w₁ b₁ : ℝ) :
    Continuous (fun x => Real.exp (w₁ * x + b₁)) := by
  exact Real.continuous_exp.comp (continuous_const.mul continuous_id |>.add continuous_const)

/-- exp(x) is exactly representable by a single EML neuron. -/
theorem exp_is_eml_neuron :
    (fun x => Real.exp x) = emlNeuronFn 1 0 0 1 := by
  ext x; simp [emlNeuronFn, Real.log_one]

/-- Constants are exactly representable by EML networks. -/
theorem const_is_eml_neuron (c : ℝ) :
    (fun _ : ℝ => c) = emlNetworkLayer [] c := by
  ext x; simp [emlNetworkLayer]

/-- Parameters in a single EML layer with n neurons.
Each neuron has 5 parameters (α weight + 4 EML params) plus 1 bias. -/
def emlLayerParams (n : ℕ) : ℕ := 5 * n + 1

/-- A depth-D EML network with uniform width W has this many parameters. -/
def emlDeepNetParams (D W : ℕ) : ℕ := D * emlLayerParams W

/-- Width-1 depth-D network has 6D parameters. -/
theorem width1_params (D : ℕ) : emlDeepNetParams D 1 = 6 * D := by
  simp [emlDeepNetParams, emlLayerParams]; ring

/-- Width-W depth-1 network has 5W+1 parameters. -/
theorem depth1_params (W : ℕ) : emlDeepNetParams 1 W = 5 * W + 1 := by
  simp [emlDeepNetParams, emlLayerParams]

/-- Zero neurons give zero network (just bias). -/
theorem zero_neurons_is_const (b : ℝ) (x : ℝ) :
    emlNetworkLayer [] b x = b := by
  simp [emlNetworkLayer]

/-- The composition of two exponentials is an exponential of a sum. -/
theorem double_exp_composition (a b c d : ℝ) (x : ℝ) :
    Real.exp (a * Real.exp (b * x + c) + d) =
    Real.exp d * Real.exp (a * Real.exp (b * x + c)) := by
  rw [Real.exp_add, mul_comm]

/-- [Section: # CatalogBuild.EML.UniversalApproximation
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 29] -/
theorem catalan_0 : catalanNum 0 = 1 := by simp [catalanNum]

/-- [Section: # CatalogBuild.EML.UniversalApproximation
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 29] -/
theorem catalan_1 : catalanNum 1 = 1 := by native_decide

theorem catalan_2 : catalanNum 2 = 2 := by native_decide

theorem catalan_3 : catalanNum 3 = 5 := by native_decide

theorem catalan_4 : catalanNum 4 = 14 := by native_decide

/-- Total number of EML tree topologies up to n leaves. -/
def totalTopologies (n : ℕ) : ℕ :=
  (List.range n).map (fun k => catalanNum k) |>.sum

/-- The total number of EML topologies with up to 5 leaves is 1+1+2+5+14 = 23. -/
theorem total_topologies_5 : totalTopologies 5 = 23 := by native_decide

/-- The gradient of an EML neuron decomposes into exp and log parts. -/
theorem eml_gradient_decomposition (w₁ b₁ w₂ b₂ x : ℝ) :
    w₁ * Real.exp (w₁ * x + b₁) - w₂ / (w₂ * x + b₂) =
    w₁ * Real.exp (w₁ * x + b₁) + (-(w₂ / (w₂ * x + b₂))) := by ring

/-- The exponential gradient component is always positive when w₁ > 0. -/
theorem exp_gradient_positive (w₁ b₁ x : ℝ) (hw : 0 < w₁) :
    0 < w₁ * Real.exp (w₁ * x + b₁) := by positivity

/-- The logarithmic gradient component magnitude is bounded by |w₂|
when |w₂·x + b₂| ≥ 1. -/
theorem log_gradient_bounded (w₂ b₂ x : ℝ) (h : 1 ≤ |w₂ * x + b₂|) :
    |w₂ / (w₂ * x + b₂)| ≤ |w₂| := by
  rw [abs_div]
  exact div_le_of_le_mul₀ (abs_nonneg _) (abs_nonneg _)
    (le_mul_of_one_le_right (abs_nonneg _) h)

/-- A depth-1 Sheffer expression: Σᵢ wᵢ σ(aᵢx + bᵢ) + c -/
structure Depth1ShefferExpr where
  n : ℕ
  weights : Fin n → ℝ
  slopes : Fin n → ℝ
  biases : Fin n → ℝ
  offset : ℝ

/-- Evaluate a depth-1 Sheffer expression -/
def Depth1ShefferExpr.eval (e : Depth1ShefferExpr) (x : ℝ) : ℝ :=
  (∑ i : Fin e.n, e.weights i * softplus (e.slopes i * x + e.biases i)) + e.offset

/-- Softplus separates points: if x₁ ≠ x₂, there exist a, b such that
σ(ax₁ + b) ≠ σ(ax₂ + b) -/
theorem softplus_separates_points {x₁ x₂ : ℝ} (hne : x₁ ≠ x₂) :
    ∃ a b : ℝ, softplus (a * x₁ + b) ≠ softplus (a * x₂ + b) := by
  exact ⟨1, 0, by simp; exact fun h => hne (softplus_strictMono.injective h)⟩

/-- The softplus family does not vanish: for every x, there exist a, b with σ(ax + b) ≠ 0 -/
theorem softplus_nonvanishing (x : ℝ) : ∃ a b : ℝ, softplus (a * x + b) ≠ 0 := by
  exact ⟨1, 0, ne_of_gt (softplus_pos (1 * x + 0))⟩

/-- Softplus is continuous -/
theorem softplus_continuous : Continuous softplus :=
  softplus_differentiable.continuous

/-- Each member of the softplus family σ(ax + b) is continuous -/
theorem softplus_family_continuous (a b : ℝ) :
    Continuous (fun x => softplus (a * x + b)) :=
  softplus_continuous.comp ((continuous_const.mul continuous_id).add continuous_const)

end