/-
# Depth Rigidity for Full EML with Inversions — Definitions

This file establishes the foundational definitions for depth rigidity
in the full EML (Exponential-Multiplicative Language) over positive reals,
including inversion nodes.

## Key Definitions

- `iterExp`: iterated exponential function
- `PosExpr`: expression trees over positive reals (var, const, mul, inv, exp)
- `PosExpr.eval`: semantic evaluation at a point x > 0
- `PosExpr.depth`: exponential nesting depth (only exp increments)
- `PosExpr.growthRank`: structural growth complexity (inv preserves rank)
- `HasReciprocalEnvelope`: the novel invariant — eventual two-sided tower bound
  controlling both f(x) and 1/f(x) simultaneously
- `ComputesOnPos`: exact representation on positive reals

## Scientific Significance

The key novelty is `HasReciprocalEnvelope`, which captures the idea that
inversion merely swaps upper and lower asymptotic bounds without increasing
the tower height. This reciprocal-stable invariant is what allows depth
rigidity to survive the introduction of division.
-/
import Mathlib

noncomputable section

open Real Filter

/-! ## Iterated Exponential -/

/-- The iterated exponential: `iterExp 0 x = x`, `iterExp (n+1) x = exp(iterExp n x)`. -/
def iterExp : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => Real.exp (iterExp n x)

@[simp] theorem iterExp_zero (x : ℝ) : iterExp 0 x = x := rfl
@[simp] theorem iterExp_succ (n : ℕ) (x : ℝ) :
    iterExp (n + 1) x = Real.exp (iterExp n x) := rfl

/-! ## Positive-Real Expression Language -/

/-- Expression trees over positive reals with multiplication, inversion, and exponentiation.

    This is the full EML language on positive reals:
    - `var`: the input variable x
    - `const c`: a positive constant c > 0
    - `mul a b`: product a · b
    - `inv a`: reciprocal 1/a
    - `exp a`: exponential exp(a)

    The `exp` operation is the sole source of transcendence and the only
    operation that increments depth. -/
inductive PosExpr where
  | var : PosExpr
  | const : ℝ → PosExpr
  | mul : PosExpr → PosExpr → PosExpr
  | inv : PosExpr → PosExpr
  | exp : PosExpr → PosExpr
  deriving Inhabited

namespace PosExpr

/-- Semantic evaluation of a positive-real expression at input `x`. -/
def eval : PosExpr → ℝ → ℝ
  | .var, x => x
  | .const c, _ => c
  | .mul a b, x => a.eval x * b.eval x
  | .inv a, x => (a.eval x)⁻¹
  | .exp a, x => Real.exp (a.eval x)

/-- Exponential nesting depth: only `exp` increments depth.
    - `var`, `const`: depth 0
    - `mul a b`: max of children depths
    - `inv a`: same as child depth (inversion does not add depth)
    - `exp a`: 1 + child depth -/
def depth : PosExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .mul a b => max a.depth b.depth
  | .inv a => a.depth
  | .exp a => 1 + a.depth

/-- Growth rank: structural growth complexity measure.
    Identical to depth for expression trees, but conceptually distinct
    because it measures semantic growth potential rather than syntactic nesting.

    The critical property: `inv` preserves growth rank, reflecting the
    semantic fact that inversion cannot manufacture new exponential tower levels. -/
def growthRank : PosExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .mul a b => max a.growthRank b.growthRank
  | .inv a => a.growthRank
  | .exp a => 1 + a.growthRank

/-- Predicate: the expression is inverse-free (no `inv` nodes). -/
def invFree : PosExpr → Prop
  | .var => True
  | .const _ => True
  | .mul a b => a.invFree ∧ b.invFree
  | .inv _ => False
  | .exp a => a.invFree

/-- Predicate: all constants in the expression are positive. -/
def posConsts : PosExpr → Prop
  | .var => True
  | .const c => 0 < c
  | .mul a b => a.posConsts ∧ b.posConsts
  | .inv a => a.posConsts
  | .exp a => a.posConsts

/-- Size (number of nodes) of an expression. -/
def size : PosExpr → ℕ
  | .var => 1
  | .const _ => 1
  | .mul a b => 1 + a.size + b.size
  | .inv a => 1 + a.size
  | .exp a => 1 + a.size

end PosExpr

/-! ## Computability and Representability -/

/-- `e` computes function `f` exactly on all positive reals. -/
def ComputesOnPos (e : PosExpr) (f : ℝ → ℝ) : Prop :=
  ∀ x : ℝ, 0 < x → e.eval x = f x

/-! ## Novel Definition: Reciprocal-Stable Envelope -/

/-- **Novel concept: Reciprocal-stable envelope.**

    A positive-valued function `f` has a reciprocal envelope at tower level `d` if both
    `f(x)` and `1/f(x)` are eventually bounded above by `iterExp d (C · x^N)` for some
    constants `C > 0` and `N : ℕ`.

    This is the key invariant that makes depth rigidity survive inversion:
    - Multiplication preserves the envelope level (by the tower absorption lemma).
    - Inversion trivially preserves it (by swapping the upper and reciprocal bounds).
    - Exponentiation increases the level by exactly 1.

    The pair of bounds captures both the growth rate and the decay rate of `f`,
    making it invariant under reciprocal. -/
def HasReciprocalEnvelope (d : ℕ) (f : ℝ → ℝ) : Prop :=
  ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, 0 < X₀ ∧ ∀ x : ℝ, x ≥ X₀ →
    f x ≤ iterExp d (C * x ^ N) ∧
    (f x)⁻¹ ≤ iterExp d (C * x ^ N)

/-- A function has a one-sided tower majorant at level `d`. -/
def HasTowerMajorant (d : ℕ) (f : ℝ → ℝ) : Prop :=
  ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, 0 < X₀ ∧ ∀ x : ℝ, x ≥ X₀ →
    f x ≤ iterExp d (C * x ^ N)

/-! ## Canonical Constructions -/

/-- The canonical expression for `iterExp n`: a chain of `n` nested `exp` nodes. -/
def canonIterExp : ℕ → PosExpr
  | 0 => .var
  | n + 1 => .exp (canonIterExp n)

/-! ## Cross-Domain: Logarithmic Tameness Index -/

/-- **Cross-domain concept: Logarithmic tameness index.**

    The minimum number of iterated logarithms needed to reduce `f(x)` to a
    function that grows at most polynomially. This connects depth rigidity to
    differential algebra (Liouvillian tower height) and symbolic computation
    (simplification depth).

    For a computable definition on PosExpr:
    - `var`, `const`: 0 (already polynomial)
    - `mul a b`: max of children (polynomial operations)
    - `inv a`: same as child (log of inverse = negation of log)
    - `exp a`: child + 1 (one more log needed to undo exp) -/
def PosExpr.logTameIndex : PosExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .mul a b => max a.logTameIndex b.logTameIndex
  | .inv a => a.logTameIndex
  | .exp a => 1 + a.logTameIndex

end