import Mathlib

/-!
# Iterated Exponentials and EML Depth Separation — Core Definitions

This file defines the iterated exponential function `iterExp` and related
concepts for studying depth separation in the EML (Exponential-Multiplicative-Linear)
expression model.

## Main definitions

* `iterExp k x` — the `k`-fold iterated exponential: `exp(exp(⋯exp(x)⋯))`
* `EMLExpr` — inductive syntax for EML expressions
* `EMLExpr.eval` — semantics (evaluation) of EML expressions
* `EMLExpr.depth` — compositional depth of an EML expression
* `EMLExpr.size` — syntactic size of an EML expression
* `uniformApproxOn` — uniform approximation on a set
* `towerExpr` — canonical depth-`k` EML expression for `iterExp k`
-/

noncomputable section

open Real Set Finset

/-- The `k`-fold iterated exponential. `iterExp 0 x = x` and
`iterExp (k+1) x = exp(iterExp k x)`. -/
def iterExp : ℕ → ℝ → ℝ
  | 0 => fun x => x
  | n + 1 => fun x => Real.exp (iterExp n x)

/-- Uniform approximation: `g` approximates `f` within `ε` on a set `I`. -/
def uniformApproxOn (f g : ℝ → ℝ) (I : Set ℝ) (ε : ℝ) : Prop :=
  ∀ x, x ∈ I → |f x - g x| ≤ ε

/-- Inductive syntax for EML (Exponential-Multiplicative-Linear) expressions. -/
inductive EMLExpr where
  | var : EMLExpr
  | const : ℝ → EMLExpr
  | add : EMLExpr → EMLExpr → EMLExpr
  | mul : EMLExpr → EMLExpr → EMLExpr
  | exp : EMLExpr → EMLExpr
  deriving Inhabited

/-- Evaluate an EML expression at a given input value. -/
def EMLExpr.eval : EMLExpr → ℝ → ℝ
  | .var => fun x => x
  | .const c => fun _ => c
  | .add e₁ e₂ => fun x => e₁.eval x + e₂.eval x
  | .mul e₁ e₂ => fun x => e₁.eval x * e₂.eval x
  | .exp e => fun x => Real.exp (e.eval x)

/-- Syntactic size of an EML expression (number of nodes). -/
def EMLExpr.size : EMLExpr → ℕ
  | .var => 1
  | .const _ => 1
  | .add e₁ e₂ => 1 + e₁.size + e₂.size
  | .mul e₁ e₂ => 1 + e₁.size + e₂.size
  | .exp e => 1 + e.size

/-- Compositional depth (nesting depth of `exp` nodes) of an EML expression. -/
def EMLExpr.depth : EMLExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add e₁ e₂ => max e₁.depth e₂.depth
  | .mul e₁ e₂ => max e₁.depth e₂.depth
  | .exp e => 1 + e.depth

/-- The canonical tower expression: `towerExpr 0 = var`,
`towerExpr (k+1) = exp(towerExpr k)`. This represents `iterExp k` exactly. -/
def towerExpr : ℕ → EMLExpr
  | 0 => .var
  | n + 1 => .exp (towerExpr n)

end