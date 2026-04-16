/-! # CatalogBuild.MachineLearning.ShefferFunction.Basic

Auto-generated from theorem catalog database.
Domain: MachineLearning/ShefferFunction
Declarations: 6
-/

import Mathlib

noncomputable section

/-- The Sheffer algebra: the set of all functions expressible as Sheffer expressions. -/
def ShefferAlg : Set (ℝ → ℝ) := {f | ∃ e : ShefferExpr, f = e.eval}


/-- Sigmoid satisfies S(x) + S(-x) = 1. -/
theorem logisticSigmoid_add_neg (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
  unfold logisticSigmoid
  rw [Real.exp_neg]
  have h : (0:ℝ) < Real.exp x := Real.exp_pos x
  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith
  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
  field_simp; ring


/-- softplus is the antiderivative of sigmoid: σ'(x) = S(x). -/
theorem hasDerivAt_softplus (x : ℝ) : HasDerivAt softplus (logisticSigmoid x) x := by
  unfold softplus logisticSigmoid
  have h1 : (0 : ℝ) < 1 + Real.exp x := one_plus_exp_pos x
  have h2 : (1 : ℝ) + Real.exp x ≠ 0 := ne_of_gt h1
  have := HasDerivAt.log ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)) h2
  simp at this
  exact this


/-- ShefferAlg is closed under affine pre-composition. -/
theorem sheffer_affinePrecomp {f : ℝ → ℝ} (hf : f ∈ ShefferAlg) (a b : ℝ) :
    (fun x => f (a * x + b)) ∈ ShefferAlg := by
  obtain ⟨e, rfl⟩ := hf
  exact ⟨.affinePrecomp a b e, rfl⟩


/-- ShefferAlg is closed under affine combination. -/
theorem sheffer_affineComb {f g : ℝ → ℝ} (hf : f ∈ ShefferAlg) (hg : g ∈ ShefferAlg)
    (α β γ : ℝ) : (fun x => α * f x + β * g x + γ) ∈ ShefferAlg := by
  obtain ⟨ef, rfl⟩ := hf
  obtain ⟨eg, rfl⟩ := hg
  exact ⟨.affineComb α β γ ef eg, rfl⟩


/-- The identity function is in ShefferAlg: x = σ(x) - σ(-x). -/
theorem id_eq_softplus_diff (x : ℝ) : x = softplus x - softplus (-x) := by
  unfold softplus
  rw [Real.exp_neg]
  have h1 : (0:ℝ) < 1 + Real.exp x := by linarith [Real.exp_pos x]
  have h2 : (0:ℝ) < 1 + (Real.exp x)⁻¹ := by positivity
  rw [← Real.log_div (ne_of_gt h1) (ne_of_gt h2)]
  have : (1 + Real.exp x) / (1 + (Real.exp x)⁻¹) = Real.exp x := by field_simp; ring
  rw [this, Real.log_exp]


end
