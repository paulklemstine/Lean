/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# EML Single-Operator Representability: Core Grammar and Semantics

This file provides the foundational grammar and denotational semantics for the
**EML Single-Operator Church–Turing** program. We introduce two expression
languages over the reals in finitely many real variables:

* `EMLExpr`  — the *two-operator* elementary language with the field operations
  `+, ×, neg, inv`, real constants, variables, and **both** transcendental
  primitives `exp` and `log`.
* `EMLOnlyExpr` — the *single-operator* language with the same field operations,
  real constants, variables, and the **sole** transcendental primitive
  `eml(x, y) = exp(x) − log(y)`.

The thesis under investigation (formalised downstream in
`EML.SingleOperatorCompilation`) is that the single binary operator `eml`
generates exactly the same function class as the pair `{exp, log}` — a
"single-operator Church–Turing thesis" for the elementary real functions.

## Main definitions

* `EMLExpr`, `EMLExpr.eval`, `EMLExpr.size`
* `EMLOnlyExpr`, `EMLOnlyExpr.eval`, `EMLOnlyExpr.size`
* `EMLRepresentable`, `EMLOnlyRepresentable` — representability of a function
  `f : (Fin n → ℝ) → ℝ` in each language.

## Main results

* `EMLExpr.size_pos`, `EMLOnlyExpr.size_pos` — sizes are positive.
* `EMLOnlyExpr.eval_eml` — the defining identity of the `eml` node.
* `EMLOnlyExpr.exp_eq_eml_one`, `EMLOnlyExpr.log_eq_one_sub_eml` — `exp` and
  `log` are each recovered semantically from `eml`.
-/
import Mathlib

noncomputable section

open Real

/-! ## §1. The two-operator language `EMLExpr` -/

/-- The two-operator EML grammar: field operations, constants, variables
    (indexed by `ℕ`), and the two transcendental primitives `exp` and `log`. -/
inductive EMLExpr : Type where
  | const (c : ℝ) : EMLExpr
  | var (n : ℕ) : EMLExpr
  | add (e₁ e₂ : EMLExpr) : EMLExpr
  | mul (e₁ e₂ : EMLExpr) : EMLExpr
  | neg (e : EMLExpr) : EMLExpr
  | inv (e : EMLExpr) : EMLExpr
  | exp (e : EMLExpr) : EMLExpr
  | log (e : EMLExpr) : EMLExpr
  deriving Inhabited

namespace EMLExpr

/-- Total denotational semantics for `EMLExpr` in an environment `env : ℕ → ℝ`.
    We use Mathlib's total junk-value conventions: `x⁻¹ = 0` at `0` and
    `Real.log x = 0` for `x ≤ 0`. -/
def eval : EMLExpr → (ℕ → ℝ) → ℝ
  | const c, _ => c
  | var n, env => env n
  | add e₁ e₂, env => e₁.eval env + e₂.eval env
  | mul e₁ e₂, env => e₁.eval env * e₂.eval env
  | neg e, env => -(e.eval env)
  | inv e, env => (e.eval env)⁻¹
  | exp e, env => Real.exp (e.eval env)
  | log e, env => Real.log (e.eval env)

/-- The number of nodes in an `EMLExpr` syntax tree. -/
def size : EMLExpr → ℕ
  | const _ => 1
  | var _ => 1
  | add e₁ e₂ => 1 + e₁.size + e₂.size
  | mul e₁ e₂ => 1 + e₁.size + e₂.size
  | neg e => 1 + e.size
  | inv e => 1 + e.size
  | exp e => 1 + e.size
  | log e => 1 + e.size

@[simp] theorem eval_const (c : ℝ) (env : ℕ → ℝ) : (const c).eval env = c := rfl
@[simp] theorem eval_var (n : ℕ) (env : ℕ → ℝ) : (var n).eval env = env n := rfl

/-- Every `EMLExpr` has at least one node. -/
theorem size_pos (e : EMLExpr) : 0 < e.size := by
  induction e <;> simp [size]

end EMLExpr

/-! ## §2. The single-operator language `EMLOnlyExpr` -/

/-- The single-operator EML grammar: field operations, constants, variables,
    and the *sole* transcendental primitive `eml(x, y) = exp(x) − log(y)`. -/
inductive EMLOnlyExpr : Type where
  | const (c : ℝ) : EMLOnlyExpr
  | var (n : ℕ) : EMLOnlyExpr
  | add (e₁ e₂ : EMLOnlyExpr) : EMLOnlyExpr
  | mul (e₁ e₂ : EMLOnlyExpr) : EMLOnlyExpr
  | neg (e : EMLOnlyExpr) : EMLOnlyExpr
  | inv (e : EMLOnlyExpr) : EMLOnlyExpr
  | eml (e₁ e₂ : EMLOnlyExpr) : EMLOnlyExpr
  deriving Inhabited

namespace EMLOnlyExpr

/-- Total denotational semantics for `EMLOnlyExpr`. The `eml` node realises
    `eml(x, y) = exp(x) − log(y)`. -/
def eval : EMLOnlyExpr → (ℕ → ℝ) → ℝ
  | const c, _ => c
  | var n, env => env n
  | add e₁ e₂, env => e₁.eval env + e₂.eval env
  | mul e₁ e₂, env => e₁.eval env * e₂.eval env
  | neg e, env => -(e.eval env)
  | inv e, env => (e.eval env)⁻¹
  | eml e₁ e₂, env => Real.exp (e₁.eval env) - Real.log (e₂.eval env)

/-- The number of nodes in an `EMLOnlyExpr` syntax tree. -/
def size : EMLOnlyExpr → ℕ
  | const _ => 1
  | var _ => 1
  | add e₁ e₂ => 1 + e₁.size + e₂.size
  | mul e₁ e₂ => 1 + e₁.size + e₂.size
  | neg e => 1 + e.size
  | inv e => 1 + e.size
  | eml e₁ e₂ => 1 + e₁.size + e₂.size

@[simp] theorem eval_const (c : ℝ) (env : ℕ → ℝ) : (const c).eval env = c := rfl
@[simp] theorem eval_var (n : ℕ) (env : ℕ → ℝ) : (var n).eval env = env n := rfl

@[simp] theorem eval_eml (e₁ e₂ : EMLOnlyExpr) (env : ℕ → ℝ) :
    (eml e₁ e₂).eval env = Real.exp (e₁.eval env) - Real.log (e₂.eval env) := rfl

/-- Every `EMLOnlyExpr` has at least one node. -/
theorem size_pos (e : EMLOnlyExpr) : 0 < e.size := by
  induction e <;> simp [size]

/-- `exp` is recovered from `eml`: `eml(x, 1) = exp(x)`. -/
theorem exp_eq_eml_one (e : EMLOnlyExpr) (env : ℕ → ℝ) :
    (eml e (const 1)).eval env = Real.exp (e.eval env) := by
  simp

/-- `log` is recovered from `eml`: `1 − eml(0, y) = log(y)`. -/
theorem log_eq_one_sub_eml (e : EMLOnlyExpr) (env : ℕ → ℝ) :
    1 - (eml (const 0) e).eval env = Real.log (e.eval env) := by
  simp

end EMLOnlyExpr

/-! ## §3. Representability -/

/-- The canonical environment associated to a point `x : Fin n → ℝ`:
    variable `i` reads coordinate `i` when `i < n`, and is `0` otherwise. -/
def emlEnv {n : ℕ} (x : Fin n → ℝ) : ℕ → ℝ :=
  fun i => if h : i < n then x ⟨i, h⟩ else 0

@[simp] theorem emlEnv_coe {n : ℕ} (x : Fin n → ℝ) (i : Fin n) :
    emlEnv x (i : ℕ) = x i := by
  simp [emlEnv, i.2]

/-- A function `f : (Fin n → ℝ) → ℝ` is **EML-representable** if some two-operator
    `EMLExpr` computes it on the canonical environment. -/
def EMLRepresentable {n : ℕ} (f : (Fin n → ℝ) → ℝ) : Prop :=
  ∃ e : EMLExpr, ∀ x : Fin n → ℝ, e.eval (emlEnv x) = f x

/-- A function `f : (Fin n → ℝ) → ℝ` is **EML-only representable** if some
    single-operator `EMLOnlyExpr` computes it on the canonical environment. -/
def EMLOnlyRepresentable {n : ℕ} (f : (Fin n → ℝ) → ℝ) : Prop :=
  ∃ e : EMLOnlyExpr, ∀ x : Fin n → ℝ, e.eval (emlEnv x) = f x

end