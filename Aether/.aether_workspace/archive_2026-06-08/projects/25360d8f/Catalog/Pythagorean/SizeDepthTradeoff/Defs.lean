/-
# Size–Depth Tradeoffs for Inverse-Free EML Expressions — Definitions

This file introduces quantitative notions of expression complexity for
inverse-free EML expressions, building on the tight depth hierarchy from
`Algebra.TightDepthHierarchy`.

## Key Definitions

- `EMLExpr.size`: syntactic size (number of constructor nodes)
- `GrowthProfile`: quantitative growth invariant extracted from syntax
- `profileOf`: assigns a `GrowthProfile` to each expression
- `towerMajorant`: the explicit majorant function `iterExp D (C * x^N)`
- `profileBudget`: a single-number budget summarizing growth complexity

## Scientific Context

These definitions enable a quantitative theory of expression complexity:
bounded-depth, bounded-size expressions have constrained growth profiles,
while iterated exponentials require profiles that outgrow any such budget.
This creates a formal bridge between:
- circuit complexity (size = gates, depth = layers),
- Kolmogorov complexity (expression = program, size = description length),
- symbolic regression (shallow models cannot compactly express deep towers).
-/
import Algebra.TightDepthHierarchy.Defs

noncomputable section

open Real EMLExpr

/-! ## Expression Size -/

/-- Syntactic size of an EML expression: total number of constructor nodes. -/
def EMLExpr.size : EMLExpr → ℕ
  | .var => 1
  | .const _ => 1
  | .add a b => 1 + a.size + b.size
  | .mul a b => 1 + a.size + b.size
  | .neg a => 1 + a.size
  | .inv a => 1 + a.size
  | .eml a b => 1 + a.size + b.size

theorem EMLExpr.size_pos (e : EMLExpr) : 0 < e.size := by
  cases e <;> simp [EMLExpr.size] <;> omega

/-! ## Growth Profile -/

/-- A `GrowthProfile` captures the quantitative growth parameters of an
    inverse-free EML expression's evaluation. It records:
    - `towerHeight`: the level of tower iteration (≤ depth)
    - `polyDeg`: the polynomial degree in the tower argument
    - `coeff`: the multiplicative coefficient in the tower argument

    An expression with profile `⟨k, N, C⟩` satisfies
    `|eval e x| ≤ iterExp k (C * x^N)` for large x. -/
structure GrowthProfile where
  towerHeight : ℕ
  polyDeg : ℕ
  coeff : ℕ  -- using ℕ for finiteness / counting
  deriving DecidableEq

/-- The majorant function associated with a growth profile:
    `iterExp k (C * x^N)` where `k`, `N`, `C` come from the profile. -/
def towerMajorant (p : GrowthProfile) (x : ℝ) : ℝ :=
  iterExp p.towerHeight ((p.coeff : ℝ) * x ^ p.polyDeg)

/-- A natural-number budget summarizing the complexity of a growth profile.
    This is a single number that bounds how "complex" the majorant is. -/
def profileBudget (p : GrowthProfile) : ℕ :=
  p.towerHeight + p.polyDeg + p.coeff

/-- The set of growth profiles achievable at bounded tower height, polynomial degree,
    and coefficient. -/
def boundedProfiles (D s : ℕ) : Finset GrowthProfile :=
  (Finset.range (D + 1) ×ˢ (Finset.range (s + 1) ×ˢ Finset.range (s + 1)))
    |>.map ⟨fun ⟨h, n, c⟩ => GrowthProfile.mk h n c,
           fun ⟨a,b,c⟩ ⟨d,e,f⟩ h => by simp [GrowthProfile.mk.injEq] at h; exact Prod.ext h.1 (Prod.ext h.2.1 h.2.2)⟩

/-! ## Size of Canonical Construction -/

/-- The size of the canonical iterExp expression grows linearly. -/
theorem emlExprIterExp_size (n : ℕ) : (emlExprIterExp n).size = 2 * n + 1 := by
  induction n with
  | zero => simp [emlExprIterExp, EMLExpr.size]
  | succ n ih => simp [emlExprIterExp, EMLExpr.size, ih]; ring

/-! ## Depth bounds size from below -/

/-- EML depth is at most size minus 1. -/
theorem EMLExpr.emlDepth_le_size_sub_one (e : EMLExpr) : e.emlDepth ≤ e.size - 1 := by
  induction e with
  | var => simp [emlDepth, size]
  | const _ => simp [emlDepth, size]
  | add a b iha ihb =>
    simp only [emlDepth, size]
    omega
  | mul a b iha ihb =>
    simp only [emlDepth, size]
    omega
  | neg a ih =>
    simp only [emlDepth, size]
    omega
  | inv a ih =>
    simp only [emlDepth, size]
    omega
  | eml a b iha ihb =>
    simp only [emlDepth, size]
    have := a.size_pos
    have := b.size_pos
    omega

/-- EML depth is strictly less than size for expressions with at least one eml node. -/
theorem EMLExpr.emlDepth_lt_size (e : EMLExpr) : e.emlDepth < e.size := by
  have h := e.emlDepth_le_size_sub_one
  have hs := e.size_pos
  omega

/-- The number of `eml` nodes in an expression. -/
def EMLExpr.emlCount : EMLExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => a.emlCount + b.emlCount
  | .mul a b => a.emlCount + b.emlCount
  | .neg a => a.emlCount
  | .inv a => a.emlCount
  | .eml a b => 1 + a.emlCount + b.emlCount

/-- The eml count is bounded by size. -/
theorem EMLExpr.emlCount_le_size (e : EMLExpr) : e.emlCount ≤ e.size := by
  induction e <;> simp [emlCount, size] <;> omega

/-- Depth is bounded by eml count. -/
theorem EMLExpr.emlDepth_le_emlCount (e : EMLExpr) : e.emlDepth ≤ e.emlCount := by
  induction e with
  | var => simp [emlDepth, emlCount]
  | const _ => simp [emlDepth, emlCount]
  | add a b iha ihb => simp only [emlDepth, emlCount]; omega
  | mul a b iha ihb => simp only [emlDepth, emlCount]; omega
  | neg a ih => simp only [emlDepth, emlCount]; omega
  | inv a ih => simp only [emlDepth, emlCount]; omega
  | eml a b iha ihb => simp only [emlDepth, emlCount]; omega

end