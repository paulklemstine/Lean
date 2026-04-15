/-! # CatalogBuild.EML.Basic

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 10
-/

import Mathlib

structure of the circle S¹ on the real line ℝ.

The **stereographic sum**: `spb(x, y) = (x + y) / (1 - x·y)`
is the group operation on ℝ ∪ {∞} induced by multiplication on S¹ via
stereographic projection. This single formula simultaneously:

1. IS the tangent addition law: tan(α+β) = spb(tan α, tan β)
2. Generates the circle group from the real line
3. With a sign flip (1-xy → 1+xy) becomes Einstein's velocity addition

The **Cayley transform** C(x) = (x - i)/(x + i) provides the unitary bridge:
it maps self-adjoint operators to unitary operators, and geometrically
IS stereographic projection of the real line onto the unit circle.

## Key Results
- SPB forms an abelian group on ℝ \ {poles}
- Cayley transform maps ℝ → S¹ unitarily (|C(x)| = 1 for real x)
- Tangent addition is a special case of SPB
- Hyperbolic variant gives relativistic velocity addition
- Wick rotation (sign flip) bridges circular and hyperbolic geometry

## Connection to EML
Where EML = exp(x) - ln(y) bridges additive and multiplicative arithmetic,
SPB = (x+y)/(1-xy) bridges Euclidean and spherical/hyperbolic geometry.
Both are "continuous Sheffer strokes" — single operators generating rich structure.
-/

import Mathlib

noncomputable section

open Real

/-! ## Core Definitions -/

/-- The Stereographic Projection Bridge operator (stereographic sum).
    `spb(x, y) = (x + y) / (1 - x * y)`
    This is the group operation on ℝ induced by S¹ via stereographic projection.
    It is also the tangent addition formula. -/

theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
  simp [spbH]

/-- Hyperbolic SPB is associative (when denominators are nonzero). -/

theorem wick_duality (x y : ℝ) :
    spb x (-y) = (x - y) / (1 + x * y) := by
  simp only [spb]
  have heq : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
  rw [heq]; ring

/-! ## Connection to Tangent Addition -/

/-- The tangent addition law IS the stereographic sum.
    tan(α + β) = spb(tan α, tan β) when cos α ≠ 0 and cos β ≠ 0. -/

theorem tan_add_eq_spb (α β : ℝ) (hα : Real.cos α ≠ 0) (hβ : Real.cos β ≠ 0) :
    Real.tan (α + β) = spb (Real.tan α) (Real.tan β) := by
  rw [spb, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add,
      Real.tan_eq_sin_div_cos, Real.tan_eq_sin_div_cos]
  field_simp

/-! ## SPB Expression Trees -/

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

/-! ## SPB Number Tower -/

/-- spb(1, 0) = 1 (identity). -/
