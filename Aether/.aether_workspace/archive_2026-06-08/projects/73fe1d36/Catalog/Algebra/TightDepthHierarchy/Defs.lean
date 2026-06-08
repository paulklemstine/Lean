/-
# EML Tight Depth Hierarchy — Definitions

This file establishes the foundational definitions for the tight depth
hierarchy theorem: inverse-free EML expressions of depth D cannot represent
iterExp n for any n > D.

## Key Innovation

We introduce `HasPolyTowerMajorant k e`, stating that the evaluation of `e`
is bounded by `iterExp k (C * x^N)` for some constants C, N. This is sharper
than the previous `iterExp (k+1) (C * x)` bound, because polynomial arguments
inside iterExp can be absorbed when comparing with the next level.
-/
import Mathlib

noncomputable section

open Real Filter Finset

/-! ## Expression Language -/

/-- EML expression language: transcendence enters only through `eml(a,b) = a * exp(b)`. -/
inductive EMLExpr where
  | var : EMLExpr
  | const : ℝ → EMLExpr
  | add : EMLExpr → EMLExpr → EMLExpr
  | mul : EMLExpr → EMLExpr → EMLExpr
  | neg : EMLExpr → EMLExpr
  | inv : EMLExpr → EMLExpr
  | eml : EMLExpr → EMLExpr → EMLExpr

namespace EMLExpr

/-- Evaluation of `EMLExpr` at a point `x : ℝ`. -/
def eval : EMLExpr → ℝ → ℝ
  | .var, x => x
  | .const c, _ => c
  | .add a b, x => a.eval x + b.eval x
  | .mul a b, x => a.eval x * b.eval x
  | .neg a, x => -(a.eval x)
  | .inv a, x => (a.eval x)⁻¹
  | .eml a b, x => a.eval x * Real.exp (b.eval x)

/-- EML depth: counts maximum nesting of `eml` operations. -/
def emlDepth : EMLExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => max a.emlDepth b.emlDepth
  | .mul a b => max a.emlDepth b.emlDepth
  | .neg a => a.emlDepth
  | .inv a => a.emlDepth
  | .eml a b => 1 + max a.emlDepth b.emlDepth

/-- An EMLExpr has no `inv` nodes: the inverse-free fragment. -/
def noInv : EMLExpr → Prop
  | .var => True
  | .const _ => True
  | .add a b => a.noInv ∧ b.noInv
  | .mul a b => a.noInv ∧ b.noInv
  | .neg a => a.noInv
  | .inv _ => False
  | .eml a b => a.noInv ∧ b.noInv

/-- An EMLExpr has no `eml` nodes: pure field expression. -/
def noEml : EMLExpr → Prop
  | .var => True
  | .const _ => True
  | .add a b => a.noEml ∧ b.noEml
  | .mul a b => a.noEml ∧ b.noEml
  | .neg a => a.noEml
  | .inv a => a.noEml
  | .eml _ _ => False

end EMLExpr

/-! ## Iterated Exponential -/

/-- The iterated exponential: `iterExp 0 x = x`, `iterExp (n+1) x = exp(iterExp n x)`. -/
def iterExp : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => Real.exp (iterExp n x)

@[simp] theorem iterExp_zero (x : ℝ) : iterExp 0 x = x := rfl
@[simp] theorem iterExp_succ (n : ℕ) (x : ℝ) :
    iterExp (n + 1) x = Real.exp (iterExp n x) := rfl

/-! ## Representability -/

/-- `e : EMLExpr` represents function `f` on positive reals. -/
def RepresentsOnPos (e : EMLExpr) (f : ℝ → ℝ) : Prop :=
  ∀ x : ℝ, 0 < x → e.eval x = f x

/-! ## Canonical Constructions -/

/-- The canonical `EMLExpr` representing `iterExp n`. -/
def emlExprIterExp : ℕ → EMLExpr
  | 0 => .var
  | n + 1 => .eml (.const 1) (emlExprIterExp n)

/-! ## Novel Definition: Tower Majorant with Polynomial Argument -/

/-- **Novel concept**: An expression has a polynomial-argument tower majorant at level `k`
    if its evaluation is eventually bounded by `iterExp k (C * x^N)` for some constants
    `C > 0` and `N : ℕ`.

    This is strictly sharper than `HasTowerMajorant k e` (which uses `C * x`),
    because polynomial arguments can be absorbed when comparing adjacent tower levels.
    This absorption is what eliminates the slack in the old `D+3` bound. -/
def HasPolyTowerMajorant (k : ℕ) (e : EMLExpr) : Prop :=
  ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
    |e.eval x| ≤ iterExp k (C * x ^ N)

/-- Standard tower majorant with linear argument (for comparison). -/
def HasTowerMajorant (k : ℕ) (e : EMLExpr) : Prop :=
  ∃ C : ℝ, 0 < C ∧ ∀ x : ℝ, 1 < x →
    e.eval x ≤ iterExp k (C * x)

/-- **Growth rank**: the structural growth complexity of an inverse-free expression.
    This assigns to each expression the minimum tower level needed to majorize it.
    - `var`, `const`: rank 0 (polynomial, bounded by `C * x^N`)
    - `add`, `mul`, `neg`: max of children ranks (polynomial closure)
    - `inv`: not defined for inverse-free fragment
    - `eml(a,b)`: `max(a.growthRank, b.growthRank) + 1`

    Key theorem: `growthRank e ≤ emlDepth e` for all `e`. -/
def EMLExpr.growthRank : EMLExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => max a.growthRank b.growthRank
  | .mul a b => max a.growthRank b.growthRank
  | .neg a => a.growthRank
  | .inv a => a.growthRank
  | .eml a b => 1 + max a.growthRank b.growthRank

end