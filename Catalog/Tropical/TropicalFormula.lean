/-
# Tropical Formulas and Monotonicity

This file defines tropical formulas over the semiring (ℕ, min, +) and proves
that evaluation is monotone in the pointwise order on assignments. The key
consequence is that every sublevel set {a | evalTrop φ a ≤ k} is a lower set
(downward closed) in the product order on ℕⁿ.

This monotonicity is a fundamental structural property: it means tropical
min-plus computation cannot break the order-theoretic regularity of its
input space, forming a barrier against encoding problems whose solution
sets are not downward closed.
-/

import Mathlib

/-- A tropical formula over `n` variables, built from constants, variables,
    binary addition (+), and binary minimum (min). -/
inductive TropFormula (n : ℕ) where
  | const : ℕ → TropFormula n
  | var   : Fin n → TropFormula n
  | add   : TropFormula n → TropFormula n → TropFormula n
  | min   : TropFormula n → TropFormula n → TropFormula n
  deriving Repr, DecidableEq

namespace TropFormula

/-- Evaluate a tropical formula at an assignment `a : Fin n → ℕ`.
    Constants evaluate to themselves, variables look up the assignment,
    `add` is natural number addition, and `min` is natural number minimum. -/
def eval : TropFormula n → (Fin n → ℕ) → ℕ
  | const c, _ => c
  | var i, a => a i
  | add φ ψ, a => eval φ a + eval ψ a
  | min φ ψ, a => Nat.min (eval φ a) (eval ψ a)

/-- The size of a tropical formula (number of nodes in the syntax tree). -/
def size : TropFormula n → ℕ
  | const _ => 1
  | var _ => 1
  | add φ ψ => 1 + φ.size + ψ.size
  | min φ ψ => 1 + φ.size + ψ.size

/-
Evaluation of tropical formulas is monotone: if `b i ≤ a i` for all `i`,
    then `eval φ b ≤ eval φ a`. This follows by structural induction, using
    that both `+` and `min` on `ℕ` are monotone in each argument.
-/
theorem eval_mono (φ : TropFormula n) {a b : Fin n → ℕ}
    (h : ∀ i, b i ≤ a i) : eval φ b ≤ eval φ a := by
  induction' φ with φ₁ φ₂ h₁ h₂ <;> simp_all +decide [ TropFormula.eval ];
  grind

/-
The sublevel set `{a | eval φ a ≤ k}` is downward closed (a lower set)
    in the pointwise order on `Fin n → ℕ`. This is an immediate corollary
    of monotonicity: if `b ≤ a` pointwise and `eval φ a ≤ k`, then
    `eval φ b ≤ eval φ a ≤ k`.
-/
theorem sublevel_isLowerSet (φ : TropFormula n) (k : ℕ) :
    IsLowerSet {a : Fin n → ℕ | eval φ a ≤ k} := by
  intro a b hab;
  exact fun h => le_trans ( eval_mono φ hab ) h

/-- Boolean-vector predicate: every coordinate is 0 or 1. -/
def IsBoolVec {n : ℕ} (a : Fin n → ℕ) : Prop :=
  ∀ i, a i = 0 ∨ a i = 1

end TropFormula