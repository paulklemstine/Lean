/-
# Sheffer AI: Core Properties of the Softplus Function

The softplus function σ(x) = log(1 + eˣ) is the central object in the Sheffer function theory.
This file establishes its fundamental analytic properties.
-/

import Mathlib

open Real

noncomputable section

/-! ## Definition -/

/-- The softplus function σ(x) = log(1 + eˣ) -/
def softplus (x : ℝ) : ℝ := Real.log (1 + Real.exp x)

/-- The logistic sigmoid function S(x) = eˣ / (1 + eˣ), the derivative of softplus -/
def logisticSigmoid (x : ℝ) : ℝ := Real.exp x / (1 + Real.exp x)

/-! ## Basic positivity -/

/-- 1 + eˣ > 0 for all x -/
lemma one_plus_exp_pos (x : ℝ) : (1 : ℝ) + Real.exp x > 0 := by
  linarith [Real.exp_pos x]

/-- 1 + eˣ > 1 for all x -/
lemma one_plus_exp_gt_one (x : ℝ) : (1 : ℝ) + Real.exp x > 1 := by
  linarith [Real.exp_pos x]

/-- Softplus is strictly positive: σ(x) > 0 for all x -/
theorem softplus_pos (x : ℝ) : softplus x > 0 := by
  unfold softplus
  exact Real.log_pos (one_plus_exp_gt_one x)

/-! ## Monotonicity -/

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

/-- Softplus is strictly monotone increasing -/
theorem softplus_strictMono : StrictMono softplus := by
  intro a b hab
  unfold softplus
  apply Real.log_lt_log
  · exact one_plus_exp_pos a
  · linarith [Real.exp_lt_exp.mpr hab]

/-- Softplus is monotone increasing -/
theorem softplus_mono : Monotone softplus :=
  softplus_strictMono.monotone

/-! ## Softplus dominates identity -/

/-- Softplus is greater than x for all x -/
theorem softplus_gt_id (x : ℝ) : softplus x > x := by
  unfold softplus
  have h1 : (1 : ℝ) + Real.exp x > Real.exp x := by linarith
  calc x = Real.log (Real.exp x) := (Real.log_exp x).symm
    _ < Real.log (1 + Real.exp x) := by
        apply Real.log_lt_log (Real.exp_pos x) h1

/-! ## Derivative -/

/-- Softplus is differentiable -/
theorem softplus_differentiable : Differentiable ℝ softplus := by
  unfold softplus
  apply Differentiable.log
  · exact differentiable_const 1 |>.add Real.differentiable_exp
  · intro x; exact ne_of_gt (one_plus_exp_pos x)

/-
The derivative of softplus is the logistic sigmoid
-/
theorem softplus_deriv (x : ℝ) : deriv softplus x = logisticSigmoid x := by
  apply HasDerivAt.deriv;
  convert HasDerivAt.log ( HasDerivAt.add ( hasDerivAt_const _ _ ) ( Real.hasDerivAt_exp x ) ) _ using 1 <;> norm_num [ logisticSigmoid ];
  positivity

/-! ## Convexity -/

/-
Softplus is convex
-/
theorem softplus_convex : ConvexOn ℝ Set.univ softplus := by
  have h_hessian : ∀ x, deriv (deriv softplus) x > 0 := by
    rw [ show deriv softplus = logisticSigmoid from funext fun x => softplus_deriv x ];
    unfold logisticSigmoid;
    exact fun x => by norm_num [ Real.differentiableAt_exp, ne_of_gt ( add_pos zero_lt_one ( Real.exp_pos x ) ) ] ; ring_nf; positivity;
  apply_rules [ convexOn_of_deriv2_nonneg, convex_univ ];
  · exact ContinuousOn.log ( continuousOn_const.add ( Real.continuousOn_exp ) ) fun x hx => by positivity;
  · exact fun x _ => DifferentiableAt.differentiableWithinAt ( softplus_differentiable.differentiableAt );
  · exact fun x hx => differentiableAt_of_deriv_ne_zero ( ne_of_gt ( h_hessian x ) ) |> DifferentiableAt.differentiableWithinAt;
  · exact fun x _ => le_of_lt ( h_hessian x )

/-! ## Key Identity -/

/-- e^σ(x) = 1 + eˣ -/
theorem softplus_exp_identity (x : ℝ) : Real.exp (softplus x) = 1 + Real.exp x := by
  unfold softplus
  rw [Real.exp_log (one_plus_exp_pos x)]

/-! ## Functional equation -/

/-
σ(x) - x = σ(-x) (reflection identity)
-/
theorem softplus_reflection (x : ℝ) : softplus x - x = softplus (-x) := by
  unfold softplus;
  rw [ show ( 1 + Real.exp ( -x ) ) = ( 1 + Real.exp x ) / Real.exp x by rw [ add_div, div_self <| ne_of_gt <| Real.exp_pos x ] ; rw [ Real.exp_neg ] ; ring, Real.log_div ( by positivity ) <| by positivity, Real.log_exp ]

/-! ## Sigmoid properties -/

/-- Sigmoid symmetry: S(-x) = 1 - S(x) -/
theorem logisticSigmoid_symmetry (x : ℝ) : logisticSigmoid (-x) = 1 - logisticSigmoid x := by
  unfold logisticSigmoid
  rw [Real.exp_neg]
  have he : Real.exp x > 0 := Real.exp_pos x
  have h1 : (1 : ℝ) + Real.exp x > 0 := one_plus_exp_pos x
  have h2 : (1 : ℝ) + (Real.exp x)⁻¹ > 0 := by positivity
  field_simp
  ring

/-- Sigmoid at zero equals 1/2 -/
theorem logisticSigmoid_zero : logisticSigmoid 0 = 1 / 2 := by
  unfold logisticSigmoid
  simp [Real.exp_zero]
  ring

/-- Softplus at zero equals log 2 -/
theorem softplus_zero : softplus 0 = Real.log 2 := by
  unfold softplus
  simp [Real.exp_zero]
  norm_num

end