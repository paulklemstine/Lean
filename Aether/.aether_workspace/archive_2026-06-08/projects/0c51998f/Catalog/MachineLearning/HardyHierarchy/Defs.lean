import Mathlib

/-!
# Hardy Field Hierarchy for EML Expressions — Definitions

This file defines the EML expression language, a syntactic-semantic asymptotic
hierarchy (`HardyLevel`) inspired by classical Hardy fields, and auxiliary concepts
needed to connect EML depth to asymptotic growth classification.

## Main Definitions

- `EmlExpr`: expression language with `eml(a,b) = a * exp(b)` as the sole transcendental
- `EmlExpr.eval`, `EmlExpr.emlDepth`: semantics and depth measure
- `EventuallyEq'`: eventual equality of real functions
- `HardyLevel`: inductive asymptotic hierarchy stratified by exponential nesting
- `iterExp`: iterated exponential `E_n(x) = exp^n(x)`
- `HasHardyRank`: predicate asserting exact Hardy rank
- `emlExprIterExp`: canonical EML expression for `iterExp n`
-/

noncomputable section

open Real

/-! ## EML Expression Language -/

/-- EML expression language: transcendence enters only through `eml(a,b) = a * exp(b)`. -/
inductive EmlExpr where
  | var : EmlExpr
  | const : ℝ → EmlExpr
  | add : EmlExpr → EmlExpr → EmlExpr
  | mul : EmlExpr → EmlExpr → EmlExpr
  | neg : EmlExpr → EmlExpr
  | eml : EmlExpr → EmlExpr → EmlExpr

/-- Evaluation of `EmlExpr` at a point `x : ℝ`.
    The key operation: `eml(a,b)` evaluates to `a(x) * exp(b(x))`. -/
def EmlExpr.eval : EmlExpr → ℝ → ℝ
  | .var, x => x
  | .const c, _ => c
  | .add a b, x => a.eval x + b.eval x
  | .mul a b, x => a.eval x * b.eval x
  | .neg a, x => -(a.eval x)
  | .eml a b, x => a.eval x * Real.exp (b.eval x)

/-- EML depth: counts the maximum nesting depth of `eml` operations,
    ignoring field operations. This is the key complexity measure. -/
def EmlExpr.emlDepth : EmlExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => max a.emlDepth b.emlDepth
  | .mul a b => max a.emlDepth b.emlDepth
  | .neg a => a.emlDepth
  | .eml a b => 1 + max a.emlDepth b.emlDepth

/-- Size of an `EmlExpr` tree. -/
def EmlExpr.size : EmlExpr → ℕ
  | .var => 1
  | .const _ => 1
  | .add a b => 1 + a.size + b.size
  | .mul a b => 1 + a.size + b.size
  | .neg a => 1 + a.size
  | .eml a b => 1 + a.size + b.size

/-- An EmlExpr with no eml nodes. -/
def EmlExpr.noEml : EmlExpr → Prop
  | .var => True
  | .const _ => True
  | .add a b => a.noEml ∧ b.noEml
  | .mul a b => a.noEml ∧ b.noEml
  | .neg a => a.noEml
  | .eml _ _ => False

/-! ## Iterated Exponential -/

/-- The iterated exponential: `iterExp 0 x = x`, `iterExp (n+1) x = exp(iterExp n x)`. -/
def iterExp : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => Real.exp (iterExp n x)

/-- The canonical `EmlExpr` representing `iterExp n`:
    `eml(1, eml(1, ... eml(1, var)...))` with `n` nested `eml` layers. -/
def emlExprIterExp : ℕ → EmlExpr
  | 0 => .var
  | n + 1 => .eml (.const 1) (emlExprIterExp n)

/-! ## Eventual Relations -/

/-- Two functions are eventually equal if they agree for all sufficiently large inputs. -/
def EventuallyEq' (f g : ℝ → ℝ) : Prop :=
  ∃ A : ℝ, ∀ x ≥ A, f x = g x

/-- Eventual domination: `f` eventually dominates `g`. -/
def EventuallyDominates (f g : ℝ → ℝ) : Prop :=
  ∃ A : ℝ, ∀ x ≥ A, g x ≤ f x

/-! ## Hardy Level Hierarchy -/

/-- The Hardy level hierarchy, stratifying real functions by exponential nesting depth.

  * Level 0 contains the identity, constants, and closure under `+` and `*`.
  * Each application of `f * exp(g)` raises the level by one.
  * Functions that agree eventually with a level-`d` function are also at level `d`.

  This is a syntactic-semantic asymptotic hierarchy designed to mirror the
  log-exp Hardy field hierarchy. It captures the exact operation highlighted in
  the EML framework: `eml(a,b) = a * exp(b)` raises hierarchy level by one. -/
inductive HardyLevel : ℕ → (ℝ → ℝ) → Prop
  | base_id : HardyLevel 0 (fun x => x)
  | base_const (c : ℝ) : HardyLevel 0 (fun _ => c)
  | add {n f g} : HardyLevel n f → HardyLevel n g →
      HardyLevel n (fun x => f x + g x)
  | mul {n f g} : HardyLevel n f → HardyLevel n g →
      HardyLevel n (fun x => f x * g x)
  | exp_step {n f g} : HardyLevel n f → HardyLevel n g →
      HardyLevel (n + 1) (fun x => f x * Real.exp (g x))
  | congr {n f g} : HardyLevel n f → EventuallyEq' f g → HardyLevel n g

/-- A function has Hardy rank exactly `d` if it belongs to level `d`
    but not to any lower level. -/
def HasHardyRank (f : ℝ → ℝ) (d : ℕ) : Prop :=
  HardyLevel d f ∧ ∀ e < d, ¬ HardyLevel e f

/-- `growthRank` for EML expressions, defined as the `emlDepth`. -/
def growthRank (e : EmlExpr) : ℕ := e.emlDepth

end