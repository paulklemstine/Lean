import Mathlib

/-! # Idempotent Analysis and Optimization

The tropical/idempotent semiring structure has direct applications to optimization.

## Research Direction 4.5
-/

noncomputable section

/-- max is commutative -/
theorem trop_add_comm (a b : ℝ) : max a b = max b a := max_comm a b

/-- max is associative -/
theorem trop_add_assoc (a b c : ℝ) : max (max a b) c = max a (max b c) := max_assoc a b c

/-- max is idempotent -/
theorem trop_add_idem (a : ℝ) : max a a = a := max_self a

/-- + distributes over max from the left -/
theorem trop_left_distrib (a b c : ℝ) : a + max b c = max (a + b) (a + c) := by
  simp [max_def]; split_ifs <;> linarith

/-- + distributes over max from the right -/
theorem trop_right_distrib (a b c : ℝ) : max a b + c = max (a + c) (b + c) := by
  simp [max_def]; split_ifs <;> linarith

/-- The Bellman operator is monotone -/
theorem bellman_op_monotone (r γ T V W : ℝ) (hγ : 0 ≤ γ) (hVW : V ≤ W) :
    max r (γ * (T + V)) ≤ max r (γ * (T + W)) := by
  apply max_le_max_left; apply mul_le_mul_of_nonneg_left _ hγ; linarith

/-
Maslov dequantization lower bound: log(exp(a) + exp(b)) ≥ max(a, b)
-/
theorem logsumexp_lower (a b : ℝ) :
    max a b ≤ Real.log (Real.exp a + Real.exp b) := by
  rw [ Real.le_log_iff_exp_le ] <;> try positivity;
  cases max_cases a b <;> simp +decide [ * ] <;> linarith [ Real.exp_pos a, Real.exp_pos b ]

/-
Maslov dequantization upper bound: log(exp(a) + exp(b)) ≤ max(a,b) + log 2
-/
theorem logsumexp_upper (a b : ℝ) :
    Real.log (Real.exp a + Real.exp b) ≤ max a b + Real.log 2 := by
  rw [ Real.log_le_iff_le_exp ( by positivity ) ];
  rw [ Real.exp_add, Real.exp_log ] <;> cases max_cases a b <;> nlinarith [ Real.exp_pos a, Real.exp_pos b, Real.exp_le_exp.2 ( le_max_left a b ), Real.exp_le_exp.2 ( le_max_right a b ) ]

end