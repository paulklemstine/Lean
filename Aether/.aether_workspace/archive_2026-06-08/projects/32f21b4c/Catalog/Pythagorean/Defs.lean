import Mathlib

/-!
# Compiler Lower Bound Theory — Definitions

This file defines the core structures for a formal impossibility theory of
semantics-preserving compiler optimization in inverse-free EML expressions.

## Overview

We formalize **EML (Exp-Mul-Log) expressions**, a natural algebraic language where
transcendence enters through the operation `eml(a,b) = a * exp(b)`. We then define:

- `EMLExpr.InverseFree`: expressions without multiplicative inverse nodes
- `ComputesIterExp`: semantic predicate for computing iterated exponentials
- `OptPass`: structure bundling a transformation with semantics/inverse-freeness preservation
- Concrete optimization passes: CSE, constant folding, algebraic simplification
- `OptPass.comp`, `runPipeline`: pass composition and pipeline execution

## Cross-Domain Connections

- **Circuit Complexity**: EML expressions are algebraic circuits; `emlDepth` is circuit depth
- **Verified Compilation**: `OptPass` models verified compiler passes (CompCert, CakeML)
- **Abstract Interpretation**: Semantics preservation captures correctness of abstract rewrites
- **Parallel Computation**: `emlDepth` is the critical path length / parallel time
-/

noncomputable section

open Real

/-! ## Expression Language -/

/-- EML expression language: transcendence enters only through `eml(a,b) = a * exp(b)`.
    This is a natural algebraic language sitting between polynomial arithmetic and
    the full exp-log algebra. -/
inductive EMLExpr where
  | var : EMLExpr
  | const : ℝ → EMLExpr
  | add : EMLExpr → EMLExpr → EMLExpr
  | mul : EMLExpr → EMLExpr → EMLExpr
  | neg : EMLExpr → EMLExpr
  | inv : EMLExpr → EMLExpr
  | eml : EMLExpr → EMLExpr → EMLExpr

/-! ## Semantics -/

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

/-! ## Depth and Complexity Measures -/

/-- EML depth: counts the maximum nesting depth of `eml` operations,
    ignoring field operations. This is the key complexity measure that
    captures exponential nesting depth — the "critical path" through
    transcendental operations. -/
def EMLExpr.emlDepth : EMLExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => max a.emlDepth b.emlDepth
  | .mul a b => max a.emlDepth b.emlDepth
  | .neg a => a.emlDepth
  | .inv a => a.emlDepth
  | .eml a b => 1 + max a.emlDepth b.emlDepth

/-- Size of an EMLExpr tree (total node count). -/
def EMLExpr.size : EMLExpr → ℕ
  | .var => 1
  | .const _ => 1
  | .add a b => 1 + a.size + b.size
  | .mul a b => 1 + a.size + b.size
  | .neg a => 1 + a.size
  | .inv a => 1 + a.size
  | .eml a b => 1 + a.size + b.size

/-! ## Iterated Exponential -/

/-- The iterated exponential: `iterExp 0 x = x`, `iterExp (n+1) x = exp(iterExp n x)`.
    This is the family of functions that witnesses the depth hierarchy:
    computing `iterExp n` requires EML depth at least `n`. -/
def iterExp : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => Real.exp (iterExp n x)

/-! ## Representability -/

/-- `e : EMLExpr` represents function `f` on positive reals.
    This is the semantic correctness predicate: `e` computes `f`
    on the domain of interest. -/
def RepresentsOnPos (e : EMLExpr) (f : ℝ → ℝ) : Prop :=
  ∀ x > 0, e.eval x = f x

/-! ## Inverse-Freeness -/

/-- An EML expression is **inverse-free** if it contains no `inv` nodes.
    This is the key syntactic invariant that ensures monotonic growth,
    enabling depth lower bounds. Without inverse-freeness, one could
    potentially cancel exponential growth, defeating the lower bound. -/
def EMLExpr.InverseFree : EMLExpr → Prop
  | .var => True
  | .const _ => True
  | .add a b => a.InverseFree ∧ b.InverseFree
  | .mul a b => a.InverseFree ∧ b.InverseFree
  | .neg a => a.InverseFree
  | .inv _ => False
  | .eml a b => a.InverseFree ∧ b.InverseFree

/-! ## Exponential Rank -/

/-- Exponential rank: a syntactic invariant measuring the maximum depth of
    exponential nesting an EML expression can produce.

    - Field operations preserve the max rank of their arguments
    - `eml(a,b) = a * exp(b)` wraps one exponential around `b`,
      so the rank is `max(rank(a), rank(b) + 1)`

    The chain of reasoning is: `n ≤ expRank e ≤ emlDepth e`
    for any inverse-free `e` computing `iterExp n`. -/
def EMLExpr.expRank : EMLExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => max a.expRank b.expRank
  | .mul a b => max a.expRank b.expRank
  | .neg a => a.expRank
  | .inv a => a.expRank
  | .eml a b => max a.expRank (b.expRank + 1)

/-! ## Semantic Predicates -/

/-- An EML expression `e` computes `iterExp n` if it agrees with `iterExp n`
    on all positive real inputs. -/
def ComputesIterExp (n : ℕ) (e : EMLExpr) : Prop :=
  RepresentsOnPos e (iterExp n)

/-! ## Optimization Pass Structure -/

/-- An **optimization pass** on EML expressions.
    Bundles a syntactic transformation with proofs that it preserves:
    1. Denotational semantics (pointwise on positive reals)
    2. Inverse-freeness

    This is the central compiler-theoretic structure. It captures the
    essential constraints that any correct, structure-preserving optimizer
    must satisfy. The key insight is that these two preservation properties
    are exactly what is needed to transport the depth lower bound through
    any optimization. -/
structure OptPass where
  /-- The syntactic transformation on EML expressions -/
  transform : EMLExpr → EMLExpr
  /-- The transformation preserves evaluation on positive reals -/
  preserves_semantics :
    ∀ (G : EMLExpr) (x : ℝ), 0 < x → (transform G).eval x = G.eval x
  /-- The transformation preserves inverse-freeness -/
  preserves_inverseFree :
    ∀ G, G.InverseFree → (transform G).InverseFree

/-- The impossibility predicate: an optimization pass cannot reduce the
    EML depth of inverse-free expressions computing `iterExp n` below `n`. -/
def CannotReduceIterExpDepth (P : OptPass) : Prop :=
  ∀ n G,
    ComputesIterExp n G →
    G.InverseFree →
    n ≤ G.emlDepth →
    n ≤ (P.transform G).emlDepth

/-! ## Concrete Optimization Passes -/

/-- **Common Subexpression Elimination (CSE)**: In a tree representation,
    CSE is the identity since there's no sharing to exploit. In a DAG
    representation, CSE would identify and merge structurally equal subtrees,
    reducing size but not depth. -/
def cseTransform : EMLExpr → EMLExpr := id

/-- **Constant Folding**: Replaces `const a ⊕ const b` with `const (a ⊕ b)`.
    Recursively simplifies constant subexpressions. This reduces size and
    may reduce depth (by collapsing chains of constant operations), but
    cannot reduce the EML depth of expressions computing `iterExp n`
    because the essential exponential nesting remains. -/
def constFoldTransform : EMLExpr → EMLExpr
  | .var => .var
  | .const c => .const c
  | .add a b =>
    match constFoldTransform a, constFoldTransform b with
    | .const ca, .const cb => .const (ca + cb)
    | a', b' => .add a' b'
  | .mul a b =>
    match constFoldTransform a, constFoldTransform b with
    | .const ca, .const cb => .const (ca * cb)
    | a', b' => .mul a' b'
  | .neg a =>
    match constFoldTransform a with
    | .const ca => .const (-ca)
    | a' => .neg a'
  | .inv a =>
    match constFoldTransform a with
    | .const ca => .const ca⁻¹
    | a' => .inv a'
  | .eml a b =>
    match constFoldTransform a, constFoldTransform b with
    | .const ca, .const cb => .const (ca * exp cb)
    | a', b' => .eml a' b'

/-- **Algebraic Simplification**: Applies basic algebraic identities.
    - `neg (neg e) → e`
    Recursively applied. This is a conservative pass that preserves
    the expression structure while eliminating redundant negations. -/
def algSimpTransform : EMLExpr → EMLExpr
  | .var => .var
  | .const c => .const c
  | .add a b => .add (algSimpTransform a) (algSimpTransform b)
  | .mul a b => .mul (algSimpTransform a) (algSimpTransform b)
  | .neg a =>
    match algSimpTransform a with
    | .neg a' => a'
    | a' => .neg a'
  | .inv a => .inv (algSimpTransform a)
  | .eml a b => .eml (algSimpTransform a) (algSimpTransform b)

/-! ## Pass Composition and Pipelines -/

/-- Compose two optimization passes: apply `Q` first, then `P`. -/
def OptPass.comp (P Q : OptPass) : OptPass where
  transform := P.transform ∘ Q.transform
  preserves_semantics := by
    intro G x hx
    simp only [Function.comp]
    rw [P.preserves_semantics _ x hx, Q.preserves_semantics G x hx]
  preserves_inverseFree := fun G hG =>
    P.preserves_inverseFree _ (Q.preserves_inverseFree G hG)

/-- The identity optimization pass: transforms nothing. -/
def OptPass.identity : OptPass where
  transform := _root_.id
  preserves_semantics := fun _ _ _ => rfl
  preserves_inverseFree := fun _ hG => hG

/-- Run a pipeline of optimization passes sequentially (right to left). -/
def runPipeline : List OptPass → OptPass
  | [] => OptPass.identity
  | p :: ps => p.comp (runPipeline ps)

/-! ## Canonical Constructions -/

/-- The canonical `EMLExpr` representing `iterExp n`:
    `eml(1, eml(1, ... eml(1, var)...))` with `n` nested `eml` layers.
    This is the optimal construction: `emlDepth = n` and `size = 2n + 1`. -/
def emlExprIterExp : ℕ → EMLExpr
  | 0 => .var
  | n + 1 => .eml (.const 1) (emlExprIterExp n)

end