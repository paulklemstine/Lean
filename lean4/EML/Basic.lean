/-
# EML Operator: The Continuous Sheffer Stroke

## Overview
The EML (Exp-Minus-Log) operator eml(x,y) = exp(x) - ln(y) is a single binary
operator that, together with the constant 1, generates all elementary functions.

This file formalizes the core identities and algebraic properties of the EML operator.

## Reference
Based on: "All elementary functions from a single operator" by A. Odrzywolek (2025)
-/

import Mathlib

noncomputable section

open Complex Real

/-! ## Definition of the EML operator -/

/-- The EML (Exp-Minus-Log) operator on complex numbers.
    eml(x, y) = exp(x) - log(y) -/
def eml (x y : ℂ) : ℂ := Complex.exp x - Complex.log y

/-- The EML operator on real numbers (for real-domain identities). -/
def emlR (x y : ℝ) : ℝ := Real.exp x - Real.log y

/-! ## Fundamental Identity: exp as EML -/

/-- The exponential function is recovered as eml(x, 1). -/
theorem eml_exp (x : ℂ) : eml x 1 = Complex.exp x := by
  simp [eml, Complex.log_one]

/-- Real version: exp(x) = emlR(x, 1). -/
theorem emlR_exp (x : ℝ) : emlR x 1 = Real.exp x := by
  simp [emlR, Real.log_one]

/-! ## The constant e -/

/-- The constant e is generated as eml(1, 1). -/
theorem eml_e : eml 1 1 = Complex.exp 1 := by
  simp [eml, Complex.log_one]

/-- Real version: e = emlR(1, 1). -/
theorem emlR_e : emlR 1 1 = Real.exp 1 := by
  simp [emlR, Real.log_one]

/-! ## Core Algebraic Properties of EML -/

/-- EML is non-commutative in general. -/
theorem eml_noncommutative : ∃ x y : ℂ, eml x y ≠ eml y x := by
  use 0, 1
  simp [eml, Complex.log_one, Complex.log_zero, Complex.exp_zero]
  intro h
  have : (1 : ℝ) = Real.exp 1 := by
    have := congr_arg Complex.re h
    simp at this
    exact this
  linarith [Real.one_lt_exp_iff.mpr (by linarith : (0:ℝ) < 1)]

/-- For positive reals, log(exp(x)) = x. -/
theorem log_exp_real (x : ℝ) : Real.log (Real.exp x) = x :=
  Real.log_exp x

/-! ## EML Recovery of Natural Logarithm -/

/-
The natural logarithm identity: ln(z) = eml(1, eml(eml(1,z), 1))
    for positive real z.
-/
theorem emlR_log (z : ℝ) (hz : 0 < z) :
    emlR 1 (emlR (emlR 1 z) 1) = Real.log z := by
  unfold emlR;
  norm_num

/-! ## Arithmetic via exp and log -/

/-
Subtraction via exp and log: x - y = log(exp(x) / exp(y)) for reals.
-/
theorem sub_via_exp_log (x y : ℝ) :
    Real.log (Real.exp x / Real.exp y) = x - y := by
  rw [ ← Real.exp_sub, Real.log_exp ]

/-
Addition via exp and log: x + y = log(exp(x) * exp(y)).
-/
theorem add_via_exp_log (x y : ℝ) :
    Real.log (Real.exp x * Real.exp y) = x + y := by
  rw [ ← Real.exp_add, Real.log_exp ]

/-
Multiplication via exp and log for positive reals.
-/
theorem mul_via_exp_log (x y : ℝ) (hx : 0 < x) (hy : 0 < y) :
    Real.exp (Real.log x + Real.log y) = x * y := by
  rw [ Real.exp_add, Real.exp_log hx, Real.exp_log hy ]

/-! ## EML Expression Trees -/

/-- EML expression trees. The grammar S → 1 | x_n | eml(S, S). -/
inductive EMLExpr where
  | one : EMLExpr
  | var : ℕ → EMLExpr
  | node : EMLExpr → EMLExpr → EMLExpr
  deriving Repr, BEq

/-- Evaluate an EML expression given variable assignments. -/
def EMLExpr.eval (e : EMLExpr) (vars : ℕ → ℂ) : ℂ :=
  match e with
  | .one => 1
  | .var n => vars n
  | .node l r => eml (l.eval vars) (r.eval vars)

/-- Depth of an EML expression tree. -/
def EMLExpr.depth : EMLExpr → ℕ
  | .one => 0
  | .var _ => 0
  | .node l r => 1 + max l.depth r.depth

/-- Number of leaves in an EML expression tree. -/
def EMLExpr.leafCount : EMLExpr → ℕ
  | .one => 1
  | .var _ => 1
  | .node l r => l.leafCount + r.leafCount

/-- Number of internal (EML) nodes. -/
def EMLExpr.nodeCount : EMLExpr → ℕ
  | .one => 0
  | .var _ => 0
  | .node l r => 1 + l.nodeCount + r.nodeCount

/-
In any EML tree, leaves = internal nodes + 1.
-/
theorem EMLExpr.leaf_eq_node_succ (e : EMLExpr) :
    e.leafCount = e.nodeCount + 1 := by
  -- We will prove this by structural induction on the EML expression tree.
  induction' e with e1 e2 ih1 ih2;
  · rfl;
  · rfl;
  · simp +arith +decide [ *, EMLExpr.leafCount, EMLExpr.nodeCount ]

/-! ## EML Master Formula Parameters -/

/-- Number of parameters in the level-n EML master formula. -/
def masterFormulaParams (n : ℕ) : ℕ := 5 * 2^n - 6

/-- At level 2, there are 14 parameters. -/
theorem masterFormulaParams_two : masterFormulaParams 2 = 14 := by native_decide

/-- At level 3, there are 34 parameters. -/
theorem masterFormulaParams_three : masterFormulaParams 3 = 34 := by native_decide

/-- At level 4, there are 74 parameters. -/
theorem masterFormulaParams_four : masterFormulaParams 4 = 74 := by native_decide

/-! ## Differentiability of EML -/

/-
The EML operator is differentiable in its first argument.
-/
theorem eml_differentiable_fst (y : ℂ) :
    Differentiable ℂ (fun x => eml x y) := by
  exact Complex.differentiable_exp.sub_const _

/-
Partial derivative of eml with respect to x is exp(x).
-/
theorem eml_hasDerivAt_fst (x y : ℂ) :
    HasDerivAt (fun x' => eml x' y) (Complex.exp x) x := by
  exact Complex.hasDerivAt_exp x |> ( fun h => h.sub_const _ )

end