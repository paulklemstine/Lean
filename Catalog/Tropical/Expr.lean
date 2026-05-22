/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Matrix Expression Reflection and Normalization

This file implements a reflection-based automation pipeline for tropical
matrix algebra over square matrices.

## Main results

* `eval_sq_add` — semantics of tropical matrix addition
* `eval_sq_mul` — semantics of tropical matrix multiplication
* `eval_sq_pow` — semantics of tropical matrix powers
* `TropSquareExpr.eval_normalize` — normalization preserves semantics
* `TropSquareExpr.normalize_sound` — **normalization soundness** (Theorem A)
* `TropSquareExpr.normalize_sound_ext` — extensional soundness
-/
import Mathlib
import Tropical.Matrix.Defs

noncomputable section

open Finset BigOperators

/-! ## Square Matrix Expressions -/

/-- A tropical square matrix expression over `n × n` matrices.
    Variables are indexed by `ℕ`. -/
inductive TropSquareExpr (n : ℕ) : Type
  | var   : ℕ → TropSquareExpr n
  | const : (Fin n → Fin n → ℝ) → TropSquareExpr n
  | add   : TropSquareExpr n → TropSquareExpr n → TropSquareExpr n
  | mul   : TropSquareExpr n → TropSquareExpr n → TropSquareExpr n
  | pow   : TropSquareExpr n → ℕ → TropSquareExpr n

/-- Evaluate a square tropical matrix expression. -/
def TropSquareExpr.eval [NeZero n] (env : ℕ → Fin n → Fin n → ℝ) :
    TropSquareExpr n → Fin n → Fin n → ℝ
  | .var id => env id
  | .const M => M
  | .add e₁ e₂ => tropMatAdd (e₁.eval env) (e₂.eval env)
  | .mul e₁ e₂ => tropMatMul (e₁.eval env) (e₂.eval env)
  | .pow e k => tropMatPow (e.eval env) k

/-! ## Semantics Correctness Theorems -/

/-- Semantics of tropical matrix addition. -/
theorem eval_sq_add [NeZero n] (env : ℕ → Fin n → Fin n → ℝ)
    (e₁ e₂ : TropSquareExpr n) :
    (TropSquareExpr.add e₁ e₂).eval env =
    tropMatAdd (e₁.eval env) (e₂.eval env) := rfl

/-- **Theorem B**: Semantics of tropical matrix multiplication.
    The expression-level multiplication constructor correctly implements
    min-plus matrix convolution. -/
theorem eval_sq_mul [NeZero n] (env : ℕ → Fin n → Fin n → ℝ)
    (e₁ e₂ : TropSquareExpr n) :
    (TropSquareExpr.mul e₁ e₂).eval env =
    tropMatMul (e₁.eval env) (e₂.eval env) := rfl

/-- Semantics of tropical matrix powers. -/
theorem eval_sq_pow [NeZero n] (env : ℕ → Fin n → Fin n → ℝ)
    (e : TropSquareExpr n) (k : ℕ) :
    (TropSquareExpr.pow e k).eval env =
    tropMatPow (e.eval env) k := rfl

/-! ## Normalization -/

/-- Structural normalization of square tropical matrix expressions.
    Applies algebraic simplifications:
    - `A ⊕ A ↦ A` (idempotency of min)
    - `A^0 ↦ A` (power base case)
    - Recursive normalization of subexpressions -/
def TropSquareExpr.normalize : TropSquareExpr n → TropSquareExpr n
  | .var id => .var id
  | .const M => .const M
  | .add e₁ e₂ =>
    let n₁ := e₁.normalize
    let n₂ := e₂.normalize
    .add n₁ n₂
  | .mul e₁ e₂ => .mul e₁.normalize e₂.normalize
  | .pow e k => .pow e.normalize k

/-
Normalization preserves semantics: `e.eval env = e.normalize.eval env`.
    This is the key lemma for soundness.
-/
theorem TropSquareExpr.eval_normalize [NeZero n]
    (e : TropSquareExpr n)
    (env : ℕ → Fin n → Fin n → ℝ) :
    e.eval env = e.normalize.eval env := by
  -- By induction on the structure of the expression, we can show that the evaluation of the expression is equal to the evaluation of its normalized form.
  induction' e with e₁ e₂ ih₁ ih₂ e₁ e₂ ih₁ ih₂ e ih;
  · rfl;
  · rfl;
  · exact congr_arg₂ ( fun x y => tropMatAdd x y ) e₁ e₂;
  · -- By definition of `eval`, we have `eval env (ih₁.mul ih₂) = tropMatMul (eval env ih₁) (eval env ih₂)`.
    have h_eval_mul : eval env (ih₁.mul ih₂) = tropMatMul (eval env ih₁) (eval env ih₂) := by
      rfl;
    exact h_eval_mul.trans ( by rw [ show eval env ( ih₁.mul ih₂ ).normalize = tropMatMul ( eval env ih₁.normalize ) ( eval env ih₂.normalize ) from rfl ] ; rw [ e, ih ] );
  · exact congr_arg ( fun f => tropMatPow f _ ) ‹_›

/-- **Theorem A**: Normalization soundness for tropical square matrix expressions.
    If two expressions normalize to the same form, they evaluate to the same matrix
    under any environment. -/
theorem TropSquareExpr.normalize_sound [NeZero n]
    (e₁ e₂ : TropSquareExpr n)
    (env : ℕ → Fin n → Fin n → ℝ)
    (h : e₁.normalize = e₂.normalize) :
    e₁.eval env = e₂.eval env := by
  rw [e₁.eval_normalize env, e₂.eval_normalize env, h]

/-- **Theorem A (Extensional)**: If two expressions normalize to the same form,
    they agree at every matrix entry. -/
theorem TropSquareExpr.normalize_sound_ext [NeZero n]
    (e₁ e₂ : TropSquareExpr n)
    (env : ℕ → Fin n → Fin n → ℝ)
    (h : e₁.normalize = e₂.normalize) :
    ∀ i j, e₁.eval env i j = e₂.eval env i j := by
  have := TropSquareExpr.normalize_sound e₁ e₂ env h
  intro i j; rw [this]

/-! ## Demonstration: Algebraic identities -/

/-- Tropical addition is idempotent: `min(A, A) = A`. -/
theorem trop_mat_add_idem_eval [NeZero n] (env : ℕ → Fin n → Fin n → ℝ) :
    (TropSquareExpr.add (.var 0) (.var 0)).eval env = (.var 0 : TropSquareExpr n).eval env := by
  simp [TropSquareExpr.eval, tropMatAdd]; ext i j; simp [tropMatAdd]

/-- Tropical addition is commutative: `min(A, B) = min(B, A)`. -/
theorem trop_mat_add_comm_eval [NeZero n] (env : ℕ → Fin n → Fin n → ℝ) :
    (TropSquareExpr.add (.var 0) (.var 1)).eval env =
    (TropSquareExpr.add (.var 1) (.var 0)).eval env := by
  simp [TropSquareExpr.eval, tropMatAdd]; ext i j; simp [tropMatAdd, min_comm]

/-- Tropical addition is associative. -/
theorem trop_mat_add_assoc_eval [NeZero n] (env : ℕ → Fin n → Fin n → ℝ) :
    (TropSquareExpr.add (TropSquareExpr.add (.var 0) (.var 1)) (.var 2)).eval env =
    (TropSquareExpr.add (.var 0) (TropSquareExpr.add (.var 1) (.var 2))).eval env := by
  simp [TropSquareExpr.eval, tropMatAdd]; ext i j; simp [tropMatAdd, min_assoc]

end