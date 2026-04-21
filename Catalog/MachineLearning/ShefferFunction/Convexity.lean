/-! # CatalogBuild.MachineLearning.ShefferFunction.Convexity

Auto-generated from theorem catalog database.
Domain: MachineLearning/ShefferFunction
Declarations: 5
-/

import Mathlib

/-- Logistic sigmoid is bounded: 0 ≤ S(x) ≤ 1. -/
theorem logisticSigmoid_nonneg (x : ℝ) : logisticSigmoid x ≥ 0 :=
  le_of_lt (logisticSigmoid_pos x)




/-- [Section: # CatalogBuild.MachineLearning.ShefferFunction.Convexity
Auto-generated from theorem catalog database.
Domain: MachineLearning/ShefferFunction
Declarations: 5] -/
theorem logisticSigmoid_le_one (x : ℝ) : logisticSigmoid x ≤ 1 :=
  le_of_lt (logisticSigmoid_lt_one x)




/-- The complementary identity: S(x) + S(-x) = 1. -/
theorem logisticSigmoid_complement (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 := by
  unfold logisticSigmoid
  rw [exp_neg]
  field_simp
  ring




/-- Sigmoid is the derivative of softplus. -/
theorem softplus_hasDerivAt (x : ℝ) :
    HasDerivAt softplus (logisticSigmoid x) x := by
  unfold softplus logisticSigmoid
  convert HasDerivAt.log
    (HasDerivAt.add (hasDerivAt_const x 1) (Real.hasDerivAt_exp x))
    (by positivity : (1 : ℝ) + exp x ≠ 0) using 1
  norm_num




/-- The product S(x)(1 - S(x)) is positive, reflecting strict convexity. -/
theorem logisticSigmoid_variance_pos (x : ℝ) :
    logisticSigmoid x * (1 - logisticSigmoid x) > 0 := by
  exact mul_pos (logisticSigmoid_pos x) (by linarith [logisticSigmoid_lt_one x])



