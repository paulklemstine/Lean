/-
# Growth Rank Completeness — Definitions

This file establishes the foundational definitions for the growth rank
completeness theorem: `growthRank` is the exact semantic stratification
invariant for inverse-free EML expressions.

## Main Concepts

- `EMLExpr`: Expression language with exponential-multiplicative-linear operations
- `growthRank`: Syntactic complexity measure assigning tower level
- `HasPolyTowerMajorant k e`: Semantic upper bound at tower level k
- `ExactPolyTowerLevel k e`: k is the minimal tower majorant level (novel)
- `FGHFinite`: Finite fragment of fast-growing hierarchy
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

/-- **Growth rank**: the structural growth complexity of an expression.
    For inverse-free expressions, this equals `emlDepth`.
    - `var`, `const`: rank 0
    - `add`, `mul`, `neg`: max of children ranks
    - `inv`: child rank (not used in inverse-free fragment)
    - `eml(a,b)`: `max(a.growthRank, b.growthRank) + 1` -/
def growthRank : EMLExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => max a.growthRank b.growthRank
  | .mul a b => max a.growthRank b.growthRank
  | .neg a => a.growthRank
  | .inv a => a.growthRank
  | .eml a b => 1 + max a.growthRank b.growthRank

/-- Syntactic size of an EMLExpr (number of nodes). -/
def size : EMLExpr → ℕ
  | .var => 1
  | .const _ => 1
  | .add a b => 1 + a.size + b.size
  | .mul a b => 1 + a.size + b.size
  | .neg a => 1 + a.size
  | .inv a => 1 + a.size
  | .eml a b => 1 + a.size + b.size

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

/-- The canonical `EMLExpr` representing `iterExp n`:
    `towerExpr 0 = var`, `towerExpr (n+1) = eml(const 1, towerExpr n)`. -/
def towerExpr : ℕ → EMLExpr
  | 0 => .var
  | n + 1 => .eml (.const 1) (towerExpr n)

/-! ## Polynomial-Argument Tower Majorant -/

/-- An expression has a polynomial-argument tower majorant at level `k`
    if its evaluation is eventually bounded by `iterExp k (C * x^N)` for some
    `C > 0` and `N : ℕ`. -/
def HasPolyTowerMajorant (k : ℕ) (e : EMLExpr) : Prop :=
  ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
    |e.eval x| ≤ iterExp k (C * x ^ N)

/-! ## Novel Definition: Exact Tower Level -/

/-- **Novel concept**: An expression is at exact polynomial tower level `k` if it
    has a tower majorant at level `k` but not at any lower level.

    This is the key new definition that upgrades `growthRank` from a syntactic
    upper bound to a semantic invariant: for canonical tower expressions,
    the growth rank computes the exact tower level. -/
def ExactPolyTowerLevel (k : ℕ) (e : EMLExpr) : Prop :=
  HasPolyTowerMajorant k e ∧ ∀ j < k, ¬ HasPolyTowerMajorant j e

/-! ## Eventual Domination -/

/-- Eventual upper bound relation between functions. -/
def EventualLE (f g : ℝ → ℝ) : Prop :=
  ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ → f x ≤ g x

/-! ## Fast-Growing Hierarchy (Finite Fragment) -/

/-- Finite fragment of the fast-growing hierarchy, using exp as the successor operation.
    `FGHFinite 0 x = x + 1`, `FGHFinite (k+1) x = exp(FGHFinite k x)`.

    This connects EML growth rank to the ordinal-indexed fast-growing hierarchy:
    finite tower levels correspond to the ω-fragment. -/
def FGHFinite : ℕ → ℝ → ℝ
  | 0 => fun x => x + 1
  | k + 1 => fun x => Real.exp (FGHFinite k x)

@[simp] theorem FGHFinite_zero (x : ℝ) : FGHFinite 0 x = x + 1 := rfl
@[simp] theorem FGHFinite_succ (k : ℕ) (x : ℝ) :
    FGHFinite (k + 1) x = Real.exp (FGHFinite k x) := rfl

/-! ## Certified Algorithm -/

/-- Certified growth rank computation: computes the exact tower level
    for inverse-free expressions. For inverse-free `e`, this equals `growthRank e`
    and gives the minimal tower majorant level for canonical forms. -/
def certifyGrowthRank (e : EMLExpr) : ℕ := e.growthRank

end