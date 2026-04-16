/-! # CatalogBuild.MachineLearning.ShefferFunction.IdentityExtraction

Auto-generated from theorem catalog database.
Domain: MachineLearning/ShefferFunction
Declarations: 5
-/

import Mathlib

/-- [Section: # CatalogBuild.MachineLearning.ShefferFunction.IdentityExtraction
Auto-generated from theorem catalog database.
Domain: MachineLearning/ShefferFunction
Declarations: 5] -/
theorem one_plus_exp_pos' (x : ℝ) : (1 : ℝ) + Real.exp x > 0 := by positivity



theorem softplus_identity_extraction (x : ℝ) :
    softplus x - softplus (-x) = x := by
  unfold softplus; rw [ ← Real.log_div ] <;> norm_num [ Real.exp_neg ];
  · rw [ show ( 1 + Real.exp x ) / ( 1 + ( Real.exp x ) ⁻¹ ) = Real.exp x by rw [ div_eq_iff <| by positivity ] ; nlinarith [ Real.exp_pos x, mul_inv_cancel₀ <| ne_of_gt <| Real.exp_pos x ], Real.log_exp ];
  · positivity;
  · positivity



/-- The softplus addition formula: σ(x) + σ(-x) = x + 2σ(-x) follows
from the reflection identity. This shows that softplus of x and -x
contain all the information about x. -/
theorem softplus_sum_formula (x : ℝ) :
    softplus x + softplus (-x) = x + 2 * softplus (-x) := by
  linarith [softplus_identity_extraction x]



/-- The doubling formula: 2σ(0) = log 4 = 2 log 2. -/
theorem softplus_zero_double : 2 * softplus 0 = Real.log 4 := by
  rw [softplus_zero]
  rw [show (4 : ℝ) = 2 ^ 2 by norm_num]
  rw [Real.log_pow]
  ring



/-- For any a ≠ 0, the scaled difference σ(ax) - σ(-ax) = ax extracts
a scaled version of the identity. -/
theorem softplus_scaled_identity (a : ℝ) (x : ℝ) :
    softplus (a * x) - softplus (-(a * x)) = a * x := by
  exact softplus_identity_extraction (a * x)


