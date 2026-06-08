/-
# Controlled-Inverse Depth Hierarchy — Definitions

This file establishes definitions for the controlled-inverse depth hierarchy theorem.
We prove that EML expressions with "controlled inverses" (where every inverse argument
is bounded away from zero on positive reals) cannot escape their depth class.

## Key Concepts

- **EML**: Expression language with var, const, add, mul, neg, inv, eml(a,b) = a·exp(b)
- **Spectral Margin**: The infimum of |eval e x| over positive reals
- **Controlled Inverses**: Every `inv` argument has positive spectral margin
- **Poly-Tower Majorant**: |eval e x| ≤ iterExp k (C · x^N) for large x

## Main Result

Controlled inverses don't increase depth complexity: if `e` has controlled inverses
and `emlDepth e ≤ D`, then `e` cannot represent `iterExp n` for any `n > D`.
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

/-! ## Poly-Tower Majorant -/

/-- An expression has a polynomial-argument tower majorant at level `k`
    if its evaluation is eventually bounded by `iterExp k (C * x^N)`. -/
def HasPolyTowerMajorant (k : ℕ) (e : EMLExpr) : Prop :=
  ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
    |e.eval x| ≤ iterExp k (C * x ^ N)

/-! ## Novel Definitions: Spectral Margin and Controlled Inverses -/

/-- **The spectral margin**: infimum of |eval e x| over positive reals.
    This quantifies how far the evaluation is from zero on the positive reals.
    A positive spectral margin means the expression is uniformly bounded away from zero. -/
def spectralMargin (e : EMLExpr) : ℝ :=
  sInf { y | ∃ x > 0, |e.eval x| = y }

/-- **Controlled inverses**: every `inv` argument is uniformly bounded away from zero
    on positive reals (has positive lower bound δ > 0). This is the key structural
    condition that ensures inverses don't increase depth complexity. -/
def HasControlledInverses : EMLExpr → Prop
  | .var => True
  | .const _ => True
  | .add e₁ e₂ => HasControlledInverses e₁ ∧ HasControlledInverses e₂
  | .mul e₁ e₂ => HasControlledInverses e₁ ∧ HasControlledInverses e₂
  | .neg e => HasControlledInverses e
  | .inv e => (∃ δ > 0, ∀ x > (0 : ℝ), |e.eval x| ≥ δ) ∧ HasControlledInverses e
  | .eml e₁ e₂ => HasControlledInverses e₁ ∧ HasControlledInverses e₂

/-- Inverse-free expressions trivially have controlled inverses. -/
theorem noInv_hasControlledInverses (e : EMLExpr) (h : e.noInv) : HasControlledInverses e := by
  induction e with
  | var => trivial
  | const _ => trivial
  | add a b iha ihb => exact ⟨iha h.1, ihb h.2⟩
  | mul a b iha ihb => exact ⟨iha h.1, ihb h.2⟩
  | neg a ih => exact ih h
  | inv _ _ => exact absurd h (by simp [EMLExpr.noInv])
  | eml a b iha ihb => exact ⟨iha h.1, ihb h.2⟩

end