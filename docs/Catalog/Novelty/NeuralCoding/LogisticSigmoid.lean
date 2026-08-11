import Shared.NeuralCoding.Softplus

/-! # CatalogBuild.Shared.LogisticSigmoid

The logistic sigmoid `S(x) = eˣ / (1 + eˣ)` together with the two softplus
results that depend on it (`softplus_deriv`, `softplus_convex`).  As with
`Softplus.lean`, this module is the canonical home of the declarations that the
auto-generated sibling files listed in a non-elaborating order.

Domain: Shared
-/

noncomputable section

/-- The logistic sigmoid function S(x) = eˣ / (1 + eˣ), the derivative of softplus -/
def logisticSigmoid (x : ℝ) : ℝ := Real.exp x / (1 + Real.exp x)

/-- Sigmoid at zero equals 1/2 -/
theorem logisticSigmoid_zero : logisticSigmoid 0 = 1 / 2 := by
  unfold logisticSigmoid
  simp [Real.exp_zero]
  ring

/-- The logistic sigmoid is strictly positive -/
lemma logisticSigmoid_pos (x : ℝ) : logisticSigmoid x > 0 := by
  unfold logisticSigmoid
  exact div_pos (Real.exp_pos x) (one_plus_exp_pos x)

/-- The logistic sigmoid is strictly less than 1 -/
lemma logisticSigmoid_lt_one (x : ℝ) : logisticSigmoid x < 1 := by
  unfold logisticSigmoid
  rw [div_lt_one (one_plus_exp_pos x)]
  linarith

/-- Logistic sigmoid is between 0 and 1 -/
lemma logisticSigmoid_mem_Ioo (x : ℝ) : logisticSigmoid x ∈ Set.Ioo (0 : ℝ) 1 :=
  ⟨logisticSigmoid_pos x, logisticSigmoid_lt_one x⟩

/-- Sigmoid symmetry: S(-x) = 1 - S(x) -/
theorem logisticSigmoid_symmetry (x : ℝ) : logisticSigmoid (-x) = 1 - logisticSigmoid x := by
  unfold logisticSigmoid
  rw [Real.exp_neg]
  have he : Real.exp x > 0 := Real.exp_pos x
  have h1 : (1 : ℝ) + Real.exp x > 0 := one_plus_exp_pos x
  have h2 : (1 : ℝ) + (Real.exp x)⁻¹ > 0 := by positivity
  field_simp
  ring

/-- The derivative of softplus is the logistic sigmoid. -/
theorem softplus_deriv (x : ℝ) : deriv softplus x = logisticSigmoid x := by
  apply HasDerivAt.deriv
  convert HasDerivAt.log (HasDerivAt.add (hasDerivAt_const _ _) (Real.hasDerivAt_exp x)) _ using 1 <;>
    norm_num [logisticSigmoid]
  positivity

/-- Softplus is convex. -/
theorem softplus_convex : ConvexOn ℝ Set.univ softplus := by
  have h_hessian : ∀ x, deriv (deriv softplus) x > 0 := by
    rw [show deriv softplus = logisticSigmoid from funext fun x => softplus_deriv x]
    unfold logisticSigmoid
    exact fun x => by
      norm_num [Real.differentiableAt_exp, ne_of_gt (add_pos zero_lt_one (Real.exp_pos x))]
      ring_nf
      positivity
  apply_rules [convexOn_of_deriv2_nonneg, convex_univ]
  · exact ContinuousOn.log (continuousOn_const.add Real.continuousOn_exp) fun x _ => by positivity
  · exact fun x _ => DifferentiableAt.differentiableWithinAt softplus_differentiable.differentiableAt
  · exact fun x _ =>
      differentiableAt_of_deriv_ne_zero (ne_of_gt (h_hessian x)) |>.differentiableWithinAt
  · exact fun x _ => le_of_lt (h_hessian x)

end