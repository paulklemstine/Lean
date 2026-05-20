import Mathlib

/-!
# EML Circuit Depth Separation — Definitions

We define two expression languages over ℝ:
- `FullExpr`: with primitive `exp` and `log`
- `EMLExpr`: where transcendence is mediated through `eml(a,b) = a * exp(b)`

We also define depth measures, the iterated exponential family, and a key
syntactic invariant `expRank` that tracks exponential nesting depth.

## Main Definitions

- `FullExpr`, `EMLExpr`: expression tree types
- `FullExpr.eval`, `EMLExpr.eval`: total evaluation over ℝ
- `FullExpr.depth`, `EMLExpr.depth`, `EMLExpr.emlDepth`: depth measures
- `EMLExpr.expRank`: exponential nesting rank (key invariant)
- `iterExp`: iterated exponential E_n(x) = exp^n(x)
- `RepresentsOnPos`: positive-domain representability
-/

noncomputable section

open Real

/-! ## Expression Languages -/

/-- Full expression language with primitive `exp` and `log`. -/
inductive FullExpr where
  | var : FullExpr
  | const : ℝ → FullExpr
  | add : FullExpr → FullExpr → FullExpr
  | mul : FullExpr → FullExpr → FullExpr
  | neg : FullExpr → FullExpr
  | inv : FullExpr → FullExpr
  | exp : FullExpr → FullExpr
  | log : FullExpr → FullExpr

/-- EML expression language: transcendence enters only through `eml(a,b) = a * exp(b)`. -/
inductive EMLExpr where
  | var : EMLExpr
  | const : ℝ → EMLExpr
  | add : EMLExpr → EMLExpr → EMLExpr
  | mul : EMLExpr → EMLExpr → EMLExpr
  | neg : EMLExpr → EMLExpr
  | inv : EMLExpr → EMLExpr
  | eml : EMLExpr → EMLExpr → EMLExpr

/-! ## Semantics -/

/-- Evaluation of `FullExpr` at a point `x : ℝ`. Uses `Real.log` (returns 0 for ≤ 0). -/
def FullExpr.eval : FullExpr → ℝ → ℝ
  | .var, x => x
  | .const c, _ => c
  | .add a b, x => a.eval x + b.eval x
  | .mul a b, x => a.eval x * b.eval x
  | .neg a, x => -(a.eval x)
  | .inv a, x => (a.eval x)⁻¹
  | .exp a, x => Real.exp (a.eval x)
  | .log a, x => Real.log (a.eval x)

/-- Evaluation of `EMLExpr` at a point `x : ℝ`.
    The key operation: `eml(a,b)` evaluates to `a(x) * exp(b(x))`. -/
def EMLExpr.eval : EMLExpr → ℝ → ℝ
  | .var, x => x
  | .const c, _ => c
  | .add a b, x => a.eval x + b.eval x
  | .mul a b, x => a.eval x * b.eval x
  | .neg a, x => -(a.eval x)
  | .inv a, x => (a.eval x)⁻¹
  | .eml a b, x => a.eval x * Real.exp (b.eval x)

/-! ## Depth and Size Measures -/

/-- Depth of a `FullExpr` tree. -/
def FullExpr.depth : FullExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => 1 + max a.depth b.depth
  | .mul a b => 1 + max a.depth b.depth
  | .neg a => 1 + a.depth
  | .inv a => 1 + a.depth
  | .exp a => 1 + a.depth
  | .log a => 1 + a.depth

/-- Size of a `FullExpr` tree. -/
def FullExpr.size : FullExpr → ℕ
  | .var => 1
  | .const _ => 1
  | .add a b => 1 + a.size + b.size
  | .mul a b => 1 + a.size + b.size
  | .neg a => 1 + a.size
  | .inv a => 1 + a.size
  | .exp a => 1 + a.size
  | .log a => 1 + a.size

/-- Depth of an `EMLExpr` tree. -/
def EMLExpr.depth : EMLExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => 1 + max a.depth b.depth
  | .mul a b => 1 + max a.depth b.depth
  | .neg a => 1 + a.depth
  | .inv a => 1 + a.depth
  | .eml a b => 1 + max a.depth b.depth

/-- EML depth: counts the maximum nesting depth of `eml` operations,
    ignoring field operations. This is the key complexity measure. -/
def EMLExpr.emlDepth : EMLExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => max a.emlDepth b.emlDepth
  | .mul a b => max a.emlDepth b.emlDepth
  | .neg a => a.emlDepth
  | .inv a => a.emlDepth
  | .eml a b => 1 + max a.emlDepth b.emlDepth

/-- Size of an `EMLExpr` tree. -/
def EMLExpr.size : EMLExpr → ℕ
  | .var => 1
  | .const _ => 1
  | .add a b => 1 + a.size + b.size
  | .mul a b => 1 + a.size + b.size
  | .neg a => 1 + a.size
  | .inv a => 1 + a.size
  | .eml a b => 1 + a.size + b.size

/-! ## Exponential Rank -/

/-- Exponential rank: a syntactic invariant measuring the maximum depth of
    exponential nesting an EML expression can produce.

    - Field operations preserve the max rank of their arguments
    - `eml(a,b) = a * exp(b)` wraps one exponential around `b`,
      so the rank is `max(rank(a), rank(b) + 1)`

    This is the key lower-bound invariant: we prove `expRank ≤ emlDepth`,
    and that `iterExp n` requires `expRank ≥ n`. -/
def EMLExpr.expRank : EMLExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => max a.expRank b.expRank
  | .mul a b => max a.expRank b.expRank
  | .neg a => a.expRank
  | .inv a => a.expRank
  | .eml a b => max a.expRank (b.expRank + 1)

/-! ## Iterated Exponential -/

/-- The iterated exponential: `iterExp 0 x = x`, `iterExp (n+1) x = exp(iterExp n x)`. -/
def iterExp : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => Real.exp (iterExp n x)

/-! ## Representability Predicates -/

/-- `e : EMLExpr` represents function `f` on positive reals. -/
def RepresentsOnPos (e : EMLExpr) (f : ℝ → ℝ) : Prop :=
  ∀ x > 0, e.eval x = f x

/-- `e : FullExpr` represents function `f` on positive reals. -/
def FullRepresentsOnPos (e : FullExpr) (f : ℝ → ℝ) : Prop :=
  ∀ x > 0, e.eval x = f x

/-- Two expressions from different languages represent the same function on positive reals. -/
def RepresentsSameFunctionOnPos (ef : FullExpr) (ee : EMLExpr) : Prop :=
  ∀ x > 0, ef.eval x = ee.eval x

/-! ## Canonical Constructions -/

/-- The canonical `FullExpr` representing `iterExp n`: nested applications of `exp` to `var`. -/
def fullExprIterExp : ℕ → FullExpr
  | 0 => .var
  | n + 1 => .exp (fullExprIterExp n)

/-- The canonical `EMLExpr` representing `iterExp n`:
    `eml(1, eml(1, ... eml(1, var)...))` with `n` nested `eml` layers. -/
def emlExprIterExp : ℕ → EMLExpr
  | 0 => .var
  | n + 1 => .eml (.const 1) (emlExprIterExp n)

/-- Predicate: expression is a tree (always true for our inductive type). -/
def EMLExpr.IsTreeModel (_ : EMLExpr) : Prop := True

/-- An EMLExpr with no eml nodes: all nodes are field operations. -/
def EMLExpr.noEml : EMLExpr → Prop
  | .var => True
  | .const _ => True
  | .add a b => a.noEml ∧ b.noEml
  | .mul a b => a.noEml ∧ b.noEml
  | .neg a => a.noEml
  | .inv a => a.noEml
  | .eml _ _ => False

end