/-! # CatalogBuild.Bridges.ExponentialBoundBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 10
-/

import Mathlib

/-- Fundamental: exp(x) ≥ x + 1 for all x.
The first-order Taylor bound for exp, foundation of
the exponential function's growth properties. -/
theorem exp_ge_add_one (x : ℝ) : x + 1 ≤ Real.exp x :=
  Real.add_one_le_exp x


/-- exp(x) ≥ 1 + x (commutative form).
Useful when 1 comes first in the chain of inequalities. -/
theorem exp_ge_one_add (x : ℝ) : 1 + x ≤ Real.exp x := by linarith [Real.add_one_le_exp x]


/-- exp(x) ≥ 1 for x ≥ 0. Exponential is never below 1 on [0,∞). -/
theorem exp_ge_one_nonneg (x : ℝ) (hx : 0 ≤ x) : (1 : ℝ) ≤ Real.exp x :=
  Real.one_le_exp hx


/-- exp is strictly convex on all of ℝ.
This means exp((a+b)/2) < (exp(a)+exp(b))/2 for a ≠ b,
which is the foundation of the log-sum-exp approximation:
log((exp(a)+exp(b))/2) > (a+b)/2, connecting to our LSE bounds. -/
theorem exp_strict_convex : StrictConvexOn ℝ Set.univ Real.exp :=
  strictConvexOn_exp


/-- exp is convex on all of ℝ.
exp((a+b)/2) ≤ (exp(a)+exp(b))/2, implying LSE ≥ max. -/
theorem exp_convex : ConvexOn ℝ Set.univ Real.exp :=
  convexOn_exp


/-- log(x) ≤ x - 1 for x > 0. Equivalently, exp(y) ≥ 1 + y for all y.
The fundamental logarithmic upper bound connecting to AM-GM:
√(ab) ≤ (a+b)/2 follows from log((a+b)/2) ≥ (log a + log b)/2 ≥ log(√(ab)). -/
theorem log_le_sub_one (x : ℝ) (hx : 0 < x) :
    Real.log x ≤ x - 1 := by
  have h := Real.add_one_le_exp (Real.log x)
  rw [Real.exp_log hx] at h
  linarith


/-- log(1) = 0: the identity for logarithmic base. -/
theorem log_one_eq_zero : Real.log 1 = 0 :=
  Real.log_one


/-- log is monotone: 0 < x ≤ y → log x ≤ log y.
(re-export for bridge context, connecting to NormInequalityBridge) -/
theorem log_mono {x y : ℝ} (hx : 0 < x) (hxy : x ≤ y) :
    Real.log x ≤ Real.log y :=
  Real.log_le_log hx hxy


/-- exp is positive: exp(x) > 0 for all x.
This means EML activations are always positive,
connecting to EMLStoneWeierstrassBridge. -/
theorem exp_always_pos (x : ℝ) : 0 < Real.exp x :=
  Real.exp_pos x


/-- For x ≥ 0: 1 ≤ 1 + x ≤ exp(x).
Exponential grows at least linearly on [0,∞),
connecting to GronwallDiscreteBridge's linear growth bound. -/
theorem exp_lower_chain (x : ℝ) (hx : 0 ≤ x) :
    (1 : ℝ) ≤ 1 + x ∧ 1 + x ≤ Real.exp x := by
  constructor
  · linarith
  · exact exp_ge_one_add x

