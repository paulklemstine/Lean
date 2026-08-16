import Mathlib
import Shared.Logic.One_plus_exp_pos
import Shared.NeuralCoding.Softplus

/-! # CatalogBuild.Shared.LogisticSigmoid

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 6
-/

noncomputable section

/-- The logistic sigmoid function S(x) = eˣ / (1 + eˣ), the derivative of softplus -/
def logisticSigmoid (x : ℝ) : ℝ := Real.exp x / (1 + Real.exp x)

/-- Sigmoid at zero equals 1/2 -/
theorem logisticSigmoid_zero : logisticSigmoid 0 = 1 / 2 := by
  unfold logisticSigmoid
  simp [Real.exp_zero]
  ring

/-- The logistic sigmoid is strictly less than 1 -/
lemma logisticSigmoid_lt_one (x : ℝ) : logisticSigmoid x < 1 := by
  unfold logisticSigmoid
  rw [div_lt_one (one_plus_exp_pos x)]
  linarith

/-- Sigmoid symmetry: S(-x) = 1 - S(x) -/
theorem logisticSigmoid_symmetry (x : ℝ) : logisticSigmoid (-x) = 1 - logisticSigmoid x := by
  unfold logisticSigmoid
  rw [Real.exp_neg]
  have he : Real.exp x > 0 := Real.exp_pos x
  have h1 : (1 : ℝ) + Real.exp x > 0 := one_plus_exp_pos x
  have h2 : (1 : ℝ) + (Real.exp x)⁻¹ > 0 := by positivity
  field_simp
  ring

/-- The logistic sigmoid is strictly positive -/
lemma logisticSigmoid_pos (x : ℝ) : logisticSigmoid x > 0 := by
  unfold logisticSigmoid
  exact div_pos (Real.exp_pos x) (one_plus_exp_pos x)

/-- Logistic sigmoid is between 0 and 1 -/
lemma logisticSigmoid_mem_Ioo (x : ℝ) : logisticSigmoid x ∈ Set.Ioo (0 : ℝ) 1 :=
  ⟨logisticSigmoid_pos x, logisticSigmoid_lt_one x⟩

end