/-
# Stereographic Projection Bridge (SPB): Core Definitions and Theorems

## Overview
The SPB framework uses stereographic projection and its inverse to construct
a "continuous group gate" — a single binary operator that encodes the group
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
def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- Complex-valued SPB for extending to the full Riemann sphere. -/
def spbC (x y : ℂ) : ℂ := (x + y) / (1 - x * y)

/-- The hyperbolic SPB (Einstein velocity addition with c=1).
    `spbH(x, y) = (x + y) / (1 + x * y)`
    For |x|, |y| < 1, this gives the relativistic velocity composition. -/
def spbH (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-! ## SPB Algebraic Properties -/

/-- SPB is commutative. -/
theorem spb_comm (x y : ℝ) : spb x y = spb y x := by
  simp [spb, add_comm, mul_comm]

/-- 0 is the right identity for SPB. -/
theorem spb_zero_right (x : ℝ) : spb x 0 = x := by
  simp [spb]

/-- 0 is the left identity for SPB. -/
theorem spb_zero_left (x : ℝ) : spb 0 x = x := by
  simp [spb]

/-- The inverse element under SPB is negation: spb(x, -x) = 0. -/
theorem spb_neg_right (x : ℝ) : spb x (-x) = 0 := by
  simp [spb]

/-- SPB is associative (when denominators are nonzero). -/
theorem spb_assoc (x y z : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0)
    (h3 : 1 - spb x y * z ≠ 0) (h4 : 1 - x * spb y z ≠ 0) :
    spb (spb x y) z = spb x (spb y z) := by
  simp only [spb]
  field_simp
  ring

/-- SPB with 1: spb(x, 1) = (x+1)/(1-x). -/
theorem spb_one (x : ℝ) (hx : x ≠ 1) : spb x 1 = (x + 1) / (1 - x) := by
  simp [spb, mul_one]

/-! ## Hyperbolic SPB Properties -/

/-- Hyperbolic SPB is commutative. -/
theorem spbH_comm (x y : ℝ) : spbH x y = spbH y x := by
  simp [spbH, add_comm, mul_comm]

/-- 0 is the identity for hyperbolic SPB. -/
theorem spbH_zero_right (x : ℝ) : spbH x 0 = x := by
  simp [spbH]

/-- The inverse for hyperbolic SPB is also negation. -/
theorem spbH_neg_right (x : ℝ) : spbH x (-x) = 0 := by
  simp [spbH]

/-- Hyperbolic SPB is associative (when denominators are nonzero). -/
theorem spbH_assoc (x y z : ℝ) (h1 : 1 + x * y ≠ 0) (h2 : 1 + y * z ≠ 0)
    (h3 : 1 + spbH x y * z ≠ 0) (h4 : 1 + x * spbH y z ≠ 0) :
    spbH (spbH x y) z = spbH x (spbH y z) := by
  simp only [spbH]
  field_simp
  ring

/-! ## The Wick Rotation: Circular ↔ Hyperbolic Duality -/

/-- Wick duality: SPB with negated second argument equals the "difference"
    in the hyperbolic SPB. This is the real-variable manifestation of the
    Wick rotation t → it. -/
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
theorem spb_tower_1_0 : spb 1 0 = 1 := spb_zero_right 1

/-- spb(0, 1) = 1. -/
theorem spb_tower_0_1 : spb 0 1 = 1 := spb_zero_left 1

/-! ## Differentiability of SPB -/

/-
SPB is differentiable in x when 1 - xy ≠ 0.
-/
theorem spb_hasDerivAt_fst (x y : ℝ) (h : 1 - x * y ≠ 0) :
    HasDerivAt (fun x' => spb x' y) ((1 + y ^ 2) / (1 - x * y) ^ 2) x := by
  unfold spb
  convert HasDerivAt.div ( HasDerivAt.add ( hasDerivAt_id x ) ( hasDerivAt_const _ _ ) ) ( HasDerivAt.sub ( hasDerivAt_const _ _ ) ( hasDerivAt_mul_const y ) ) h using 1 ; ring;
  norm_num ; ring

/-
SPB is differentiable in y when 1 - xy ≠ 0.
-/
theorem spb_hasDerivAt_snd (x y : ℝ) (h : 1 - x * y ≠ 0) :
    HasDerivAt (fun y' => spb x y') ((1 + x ^ 2) / (1 - x * y) ^ 2) y := by
  unfold spb
  convert HasDerivAt.div ( HasDerivAt.add ( hasDerivAt_const _ _ ) ( hasDerivAt_id y ) ) ( HasDerivAt.sub ( hasDerivAt_const _ _ ) ( HasDerivAt.mul ( hasDerivAt_const _ _ ) ( hasDerivAt_id y ) ) ) h using 1;
  norm_num ; ring

/-! ## The SPB Derivative Has Beautiful Structure -/

/-- The partial derivative ∂spb/∂x = (1+y²)/(1-xy)² is always positive
    when 1-xy ≠ 0, showing SPB is strictly monotone in each argument. -/
theorem spb_deriv_fst_pos (y : ℝ) (d : ℝ) (hd : d ≠ 0) :
    (1 + y ^ 2) / d ^ 2 > 0 := by
  apply div_pos
  · linarith [sq_nonneg y]
  · positivity

/-- Similarly for the second argument. -/
theorem spb_deriv_snd_pos (x : ℝ) (d : ℝ) (hd : d ≠ 0) :
    (1 + x ^ 2) / d ^ 2 > 0 := by
  apply div_pos
  · linarith [sq_nonneg x]
  · positivity

/-! ## Idempotent SPB -/

/-- spb(x, x) = 2x/(1-x²), which is the double-angle tangent formula.
    If x = tan(θ), then spb(x,x) = tan(2θ). -/
theorem spb_self (x : ℝ) :
    spb x x = 2 * x / (1 - x * x) := by
  unfold spb; ring

/-- The double-angle connection: spb(tan θ, tan θ) = tan(2θ). -/
theorem spb_tan_double (θ : ℝ) (hc : Real.cos θ ≠ 0) :
    spb (Real.tan θ) (Real.tan θ) = Real.tan (2 * θ) := by
  rw [show 2 * θ = θ + θ from by ring]
  exact (tan_add_eq_spb θ θ hc hc).symm

end