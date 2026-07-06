/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# EML Term Algebra: Formal Syntax and Semantics for Exp-Log-Multiply Networks

We define the **EML Term Algebra** — an inductive type representing finite compositions
of `exp`, `log`, `+`, `×`, and constants. We work primarily with the log-free fragment
`EMLTermLF` (exp + polynomials), which evaluates to continuous functions on all of ℝ and
is rich enough for the Stone-Weierstrass density theorem.

## Main Definitions

- `EMLTerm` : Full EML expressions (with log)
- `EMLTermLF` : Log-free fragment (var, const, add, mul, exp)

## Main Results

- `EMLTermLF.continuous_eval` : Every log-free EML term is continuous
- `EMLTermLF.width_pos` : Width is always positive
- `EMLTermLF.eval_exp_separates` : exp(ax) separates distinct points for a ≠ 0
-/
import Mathlib

open Real Set Filter Topology

noncomputable section

/-! ## Full EML Term Type -/

/-- The inductive type of EML (Exp-Log-Multiply) expressions. -/
inductive EMLTerm : Type where
  | var : EMLTerm
  | const (c : ℝ) : EMLTerm
  | add (t₁ t₂ : EMLTerm) : EMLTerm
  | mul (t₁ t₂ : EMLTerm) : EMLTerm
  | expOf (t : EMLTerm) : EMLTerm
  | logOf (t : EMLTerm) : EMLTerm
  deriving Inhabited

namespace EMLTerm

/-- Evaluate an EML term at a real number. -/
def eval : EMLTerm → ℝ → ℝ
  | var, x => x
  | const c, _ => c
  | add t₁ t₂, x => t₁.eval x + t₂.eval x
  | mul t₁ t₂, x => t₁.eval x * t₂.eval x
  | expOf t, x => Real.exp (t.eval x)
  | logOf t, x => Real.log (t.eval x)

/-- Width: number of leaf nodes. -/
def width : EMLTerm → ℕ
  | var => 1
  | const _ => 1
  | add t₁ t₂ => t₁.width + t₂.width
  | mul t₁ t₂ => t₁.width + t₂.width
  | expOf t => t.width
  | logOf t => t.width

/-- Depth: maximum nesting. -/
def depth : EMLTerm → ℕ
  | var => 0
  | const _ => 0
  | add t₁ t₂ => max t₁.depth t₂.depth + 1
  | mul t₁ t₂ => max t₁.depth t₂.depth + 1
  | expOf t => t.depth + 1
  | logOf t => t.depth + 1

/-- Exp-log depth: counts only exp/log nesting. -/
def elDepth : EMLTerm → ℕ
  | var => 0
  | const _ => 0
  | add t₁ t₂ => max t₁.elDepth t₂.elDepth
  | mul t₁ t₂ => max t₁.elDepth t₂.elDepth
  | expOf t => t.elDepth + 1
  | logOf t => t.elDepth + 1

@[simp] theorem eval_const (c x : ℝ) : (const c).eval x = c := rfl
@[simp] theorem eval_var (x : ℝ) : var.eval x = x := rfl

/-- `exp(log(x)) = x` for positive x. -/