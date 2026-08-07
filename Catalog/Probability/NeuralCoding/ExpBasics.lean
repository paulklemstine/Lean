import Mathlib

/-! # Elementary positivity facts for the exponential

The single fact `1 + eˣ > 0` underlies the whole softplus / logistic-sigmoid
development (it is the positivity side condition of every `Real.log` in it).
-/

/-- `1 + eˣ` is strictly positive. -/
lemma one_plus_exp_pos (x : ℝ) : (0 : ℝ) < 1 + Real.exp x := by
  have := Real.exp_pos x
  linarith