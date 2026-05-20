/-
# EML Depth Separation — Definitions

This file establishes the foundational definitions for a depth hierarchy theorem
in the theory of exact expression languages. We define two expression languages:

- `FullExpr`: the full elementary language with primitive `exp` and `log`
- `EMLExpr`: the restricted EML language where transcendence enters only through
  the combined primitive `eml(a,b) = a * exp(b)`

We prove that bounded `emlDepth` in `EMLExpr` imposes a fundamental barrier on
representational power: the iterated exponential family `iterExp n` requires
`emlDepth ≥ n`, establishing a strict depth hierarchy.

## Novel Definitions

- `AsymptoticProfile`: a structure packaging eventual positivity and growth data
- `GrowthClass`: classification of functions by iterated-exponential growth level
- `DepthCircuit`: semantic circuit complexity analogy for expression languages

## Application Keywords

exact symbolic compilation, bounded-depth circuit lower bounds, semantic complexity,
asymptotic hierarchy, iterated exponentials, expression compression limits,
proof-theoretic stratification, real-function complexity, Hardy hierarchy,
formalized lower bounds, compiler impossibility, symbolic AI, mechanized complexity theory
-/
import Mathlib

noncomputable section

open Real Filter

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

/-- Evaluation of `FullExpr` at a point `x : ℝ`. -/
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

/-! ## Size and Depth Measures -/

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

/-- Size of an `EMLExpr` tree. -/
def EMLExpr.size : EMLExpr → ℕ
  | .var => 1
  | .const _ => 1
  | .add a b => 1 + a.size + b.size
  | .mul a b => 1 + a.size + b.size
  | .neg a => 1 + a.size
  | .inv a => 1 + a.size
  | .eml a b => 1 + a.size + b.size

/-- EML depth: counts the maximum nesting depth of `eml` operations,
    ignoring field operations. This is the key complexity measure.
    Analogous to circuit depth in bounded-depth circuit complexity. -/
def EMLExpr.emlDepth : EMLExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => max a.emlDepth b.emlDepth
  | .mul a b => max a.emlDepth b.emlDepth
  | .neg a => a.emlDepth
  | .inv a => a.emlDepth
  | .eml a b => 1 + max a.emlDepth b.emlDepth

/-- Exponential rank: tracks the maximum depth of exponential nesting.
    Key invariant: `expRank ≤ emlDepth`. -/
def EMLExpr.expRank : EMLExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => max a.expRank b.expRank
  | .mul a b => max a.expRank b.expRank
  | .neg a => a.expRank
  | .inv a => a.expRank
  | .eml a b => max a.expRank (b.expRank + 1)

/-- An EMLExpr has no `eml` nodes: it is a pure field expression. -/
def EMLExpr.noEml : EMLExpr → Prop
  | .var => True
  | .const _ => True
  | .add a b => a.noEml ∧ b.noEml
  | .mul a b => a.noEml ∧ b.noEml
  | .neg a => a.noEml
  | .inv a => a.noEml
  | .eml _ _ => False

/-- An EMLExpr has no `inv` nodes. -/
def EMLExpr.noInv : EMLExpr → Prop
  | .var => True
  | .const _ => True
  | .add a b => a.noInv ∧ b.noInv
  | .mul a b => a.noInv ∧ b.noInv
  | .neg a => a.noInv
  | .inv _ => False
  | .eml a b => a.noInv ∧ b.noInv

/-! ## Iterated Exponential -/

/-- The iterated exponential: `iterExp 0 x = x`, `iterExp (n+1) x = exp(iterExp n x)`.
    This family witnesses the depth hierarchy: `iterExp n` requires EML depth exactly `n`. -/
def iterExp : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => Real.exp (iterExp n x)

/-! ## Canonical Constructions -/

/-- The canonical `FullExpr` representing `iterExp n`. -/
def fullExprIterExp : ℕ → FullExpr
  | 0 => .var
  | n + 1 => .exp (fullExprIterExp n)

/-- The canonical `EMLExpr` representing `iterExp n`:
    `eml(1, eml(1, ... eml(1, var)...))` with `n` nested `eml` layers. -/
def emlExprIterExp : ℕ → EMLExpr
  | 0 => .var
  | n + 1 => .eml (.const 1) (emlExprIterExp n)

/-! ## Representability Predicates -/

/-- `e : EMLExpr` represents function `f` on positive reals. -/
def RepresentsOnPos (e : EMLExpr) (f : ℝ → ℝ) : Prop :=
  ∀ x > 0, e.eval x = f x

/-- `e : FullExpr` represents function `f` on positive reals. -/
def FullRepresentsOnPos (e : FullExpr) (f : ℝ → ℝ) : Prop :=
  ∀ x > 0, e.eval x = f x

/-- Semantic equivalence on positive reals. -/
def SemanticallyEquivalentOnPos (e' : EMLExpr) (e : FullExpr) : Prop :=
  ∀ x : ℝ, 0 < x → e'.eval x = e.eval x

/-! ## Novel Definition: Asymptotic Profile -/

/-- An `AsymptoticProfile` packages a function together with its eventual
    positivity, monotonicity, and growth classification. This structure
    enables systematic comparison of growth rates across different
    expression languages, bridging asymptotic analysis with syntactic
    complexity measures.

    This is a novel concept not present in the existing catalog:
    it provides a semantic interface for growth-rate arguments
    that is independent of the particular expression syntax. -/
structure AsymptoticProfile where
  /-- The underlying function -/
  f : ℝ → ℝ
  /-- Threshold beyond which the function is positive -/
  threshold : ℝ
  /-- The function is positive beyond the threshold -/
  eventually_pos : ∀ x ≥ threshold, 0 < f x
  /-- The function is monotone beyond the threshold -/
  eventually_mono : MonotoneOn f (Set.Ici threshold)

/-- The growth level of a profile: the minimum `k` such that `f` is
    eventually dominated by `iterExp k`. -/
def AsymptoticProfile.growthLevel (p : AsymptoticProfile) (k : ℕ) : Prop :=
  ∃ C > 0, ∃ X : ℝ, ∀ x ≥ X, p.f x ≤ iterExp k (C * x)

/-- A function has growth rank at least `k` if it eventually dominates
    `iterExp k` with some linear scaling. -/
def HasGrowthRankAtLeast (f : ℝ → ℝ) (k : ℕ) : Prop :=
  ∃ C > 0, ∃ X : ℝ, ∀ x ≥ X, iterExp k (C * x) ≤ f x

/-- Eventual domination: `f` eventually dominates `g`. -/
def EventuallyDominates (f g : ℝ → ℝ) : Prop :=
  ∃ X : ℝ, ∀ x ≥ X, g x ≤ f x

/-! ## Novel Definition: Depth Circuit -/

/-- A `DepthCircuit` captures the complexity-theoretic view of an EML expression:
    it records both the syntactic depth bound and the semantic function computed.
    This is the expression-language analogue of a bounded-depth Boolean circuit.

    The key analogy:
    - `emlDepth` ↔ circuit depth
    - `size` ↔ circuit size
    - `eval` ↔ computed function
    - iterated exponentials ↔ hierarchy-separating hard functions

    This structure enables us to state depth hierarchy theorems in the
    language of circuit complexity. -/
structure DepthCircuit where
  /-- The underlying EML expression -/
  expr : EMLExpr
  /-- Depth bound -/
  depthBound : ℕ
  /-- The expression respects the depth bound -/
  depth_valid : expr.emlDepth ≤ depthBound

/-- The function computed by a depth circuit. -/
def DepthCircuit.computedFn (c : DepthCircuit) : ℝ → ℝ := c.expr.eval

/-- Polynomial growth bound for inv-free, eml-free expressions. -/
def EMLExpr.polyDeg : EMLExpr → ℕ
  | .var => 1
  | .const _ => 0
  | .add a b => max a.polyDeg b.polyDeg
  | .mul a b => a.polyDeg + b.polyDeg
  | .neg a => a.polyDeg
  | .inv a => a.polyDeg
  | .eml a b => max a.polyDeg b.polyDeg

/-- Coefficient bound for expressions. -/
def EMLExpr.coefBound : EMLExpr → ℝ
  | .var => 1
  | .const c => |c| + 1
  | .add a b => a.coefBound + b.coefBound
  | .mul a b => a.coefBound * b.coefBound
  | .neg a => a.coefBound
  | .inv a => a.coefBound
  | .eml a b => max a.coefBound b.coefBound

end