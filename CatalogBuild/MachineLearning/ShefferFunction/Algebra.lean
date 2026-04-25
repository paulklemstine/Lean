/-! # CatalogBuild.MachineLearning.ShefferFunction.Algebra

Auto-generated from theorem catalog database.
Domain: MachineLearning/ShefferFunction
Declarations: 14
-/

import Mathlib

noncomputable section

/-- A Sheffer expression is built from affine functions, softplus activation,
and composition. -/
inductive Expr : Type where
  | affine : ℝ → ℝ → Expr           -- x ↦ ax + b
  | activate : Expr → Expr            -- σ(e(·))
  | comp : Expr → Expr → Expr         -- f ∘ g
  | add : Expr → Expr → Expr          -- f + g
  | smul : ℝ → Expr → Expr            -- c · f





/-- Evaluate a Sheffer expression at a point. -/
noncomputable def Expr.eval : Expr → ℝ → ℝ
  | .affine a b => fun x => a * x + b
  | .activate e => fun x => softplus (e.eval x)
  | .comp f g => fun x => f.eval (g.eval x)
  | .add f g => fun x => f.eval x + g.eval x
  | .smul c f => fun x => c * f.eval x





/-- The depth of a Sheffer expression. -/
def Expr.depth : Expr → ℕ
  | .affine _ _ => 0
  | .activate e => e.depth + 1
  | .comp f g => max f.depth g.depth
  | .add f g => max f.depth g.depth
  | .smul _ f => f.depth





/-- Every Sheffer expression is differentiable. -/
theorem Expr.differentiable (e : Expr) : Differentiable ℝ e.eval := by
  induction e with
  | affine a b => exact (differentiable_id.const_mul a).add (differentiable_const b)
  | activate e ih => exact softplus_differentiable.comp ih
  | comp f g ihf ihg => exact ihf.comp ihg
  | add f g ihf ihg => exact ihf.add ihg
  | smul c f ihf => exact ihf.const_mul c





/-- The identity function is a depth-0 Sheffer expression. -/
def Expr.id : Expr := .affine 1 0





/-- [Section: # CatalogBuild.MachineLearning.ShefferFunction.Algebra
Auto-generated from theorem catalog database.
Domain: MachineLearning/ShefferFunction
Declarations: 14] -/
theorem Expr.id_eval (x : ℝ) : Expr.id.eval x = x := by
  simp [Expr.id, Expr.eval]





/-- Constants are depth-0 Sheffer expressions. -/
def Expr.const (c : ℝ) : Expr := .affine 0 c





/-- [Section: # CatalogBuild.MachineLearning.ShefferFunction.Algebra
Auto-generated from theorem catalog database.
Domain: MachineLearning/ShefferFunction
Declarations: 14] -/
theorem Expr.const_eval (c x : ℝ) : (Expr.const c).eval x = c := by
  simp [Expr.const, Expr.eval]





/-- Activation increases depth by exactly 1. -/
theorem Expr.activate_depth (e : Expr) :
    (Expr.activate e).depth = e.depth + 1 := rfl





/-- The exponential approximation: for large c, the expression
e^c · σ(x - c) approximates e^x. This is depth 1. -/
noncomputable def Expr.expApprox (c : ℝ) : Expr :=
  .smul (Real.exp c) (.activate (.affine 1 (-c)))





/-- [Section: # CatalogBuild.MachineLearning.ShefferFunction.Algebra
Auto-generated from theorem catalog database.
Domain: MachineLearning/ShefferFunction
Declarations: 14] -/
theorem Expr.expApprox_depth (c : ℝ) : (Expr.expApprox c).depth = 1 := rfl





theorem Expr.expApprox_eval (c x : ℝ) :
    (Expr.expApprox c).eval x = Real.exp c * softplus (x - c) := by
  simp [Expr.expApprox, Expr.eval]
  ring_nf





/-- The identity extraction: σ(x) - σ(-x) is a depth-1 expression
that evaluates to x. -/
def Expr.identityExtract : Expr :=
  .add (.activate (.affine 1 0)) (.smul (-1) (.activate (.affine (-1) 0)))





theorem Expr.identityExtract_depth : Expr.identityExtract.depth = 1 := rfl





end
