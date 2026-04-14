/-
# Identity Extraction from Softplus

A key result for the Sheffer algebra: the identity function can be
extracted from softplus via the formula x = σ(x) - σ(-x).

This means softplus + affine maps can recover the identity, which
combined with the exponential approximation theorem, gives access
to both fundamental building blocks of elementary functions.
-/

import Mathlib

open Real

namespace ShefferFunction

/-- The softplus function: σ(x) = log(1 + exp(x)) -/
noncomputable def softplus (x : ℝ) : ℝ := Real.log (1 + Real.exp x)

theorem one_plus_exp_pos' (x : ℝ) : (1 : ℝ) + Real.exp x > 0 := by positivity

/-
The identity extraction formula: σ(x) - σ(-x) = x.
    This is the key identity that allows recovering the identity
    function from softplus compositions.
-/
theorem softplus_identity_extraction (x : ℝ) :
    softplus x - softplus (-x) = x := by
  unfold softplus; rw [ ← Real.log_div ] <;> norm_num [ Real.exp_neg ];
  · rw [ show ( 1 + Real.exp x ) / ( 1 + ( Real.exp x ) ⁻¹ ) = Real.exp x by rw [ div_eq_iff <| by positivity ] ; nlinarith [ Real.exp_pos x, mul_inv_cancel₀ <| ne_of_gt <| Real.exp_pos x ], Real.log_exp ];
  · positivity;
  · positivity

/-
Softplus satisfies the reflection identity: σ(x) = x + σ(-x).
-/
theorem softplus_reflection (x : ℝ) : softplus x = x + softplus (-x) := by
  linear_combination softplus_identity_extraction x

/-- The softplus addition formula: σ(x) + σ(-x) = x + 2σ(-x) follows
    from the reflection identity. This shows that softplus of x and -x
    contain all the information about x. -/
theorem softplus_sum_formula (x : ℝ) :
    softplus x + softplus (-x) = x + 2 * softplus (-x) := by
  linarith [softplus_identity_extraction x]

/-- Softplus at zero equals log 2. -/
theorem softplus_zero : softplus 0 = Real.log 2 := by
  unfold softplus; norm_num

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

end ShefferFunction