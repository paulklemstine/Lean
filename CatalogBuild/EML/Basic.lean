/-! # CatalogBuild.EML.Basic

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 9
-/

import Mathlib

noncomputable section

/-- The inverse for hyperbolic SPB is also negation. -/
theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
  simp [spbH]


/-- Wick duality: SPB with negated second argument equals the "difference"
in the hyperbolic SPB. This is the real-variable manifestation of the
Wick rotation t → it. -/
theorem wick_duality (x y : ℝ) :
    spb x (-y) = (x - y) / (1 + x * y) := by
  simp only [spb]
  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
  rw [heq]; ring


/-- The tangent addition law IS the stereographic sum.
tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/
theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
  field_simp


/-- SPB expression trees — analogous to EML expression trees. -/
inductive SPBExpr where
  | zero : SPBExpr
  | one : SPBExpr
  | var : ℕ → SPBExpr
  | node : SPBExpr → SPBExpr → SPBExpr
  deriving Repr, BEq


/-- Evaluate an SPB expression. -/
def SPBExpr.eval (e : SPBExpr) (vars : ℕ → ℝ) : ℝ :=
  match e with
  | .zero => 0
  | .one => 1
  | .var n => vars n
  | .node l r => spb (l.eval vars) (r.eval vars)


/-- Depth of an SPB expression. -/
def SPBExpr.depth : SPBExpr → ℕ
  | .zero => 0
  | .one => 0
  | .var _ => 0
  | .node l r => 1 + max l.depth r.depth


/-- Leaf count. -/
def SPBExpr.leafCount : SPBExpr → ℕ
  | .zero => 1
  | .one => 1
  | .var _ => 1
  | .node l r => l.leafCount + r.leafCount


/-- Internal node count. -/
def SPBExpr.nodeCount : SPBExpr → ℕ
  | .zero => 0
  | .one => 0
  | .var _ => 0
  | .node l r => 1 + l.nodeCount + r.nodeCount


/-- Binary tree identity: leaves = internal nodes + 1. -/
theorem SPBExpr.leaf_eq_node_succ (e : SPBExpr) :
    e.leafCount = e.nodeCount + 1 := by
  induction e with
  | zero => rfl
  | one => rfl
  | var _ => rfl
  | node l r ihl ihr =>
    simp [SPBExpr.leafCount, SPBExpr.nodeCount, ihl, ihr]
    omega


end
