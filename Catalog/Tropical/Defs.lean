/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Expression Language and Computable ACI Normalizer

This file defines:
- `CTropExpr`: a fully computable tropical expression AST
- `eval`: semantic evaluation into ℝ
- `cnormalize_ca`: an ACI (associative-commutative-idempotent for min, AC for +) normalizer
- Helper list evaluation functions and their properties

## Design

We use a computable expression type (no `ℝ` constants, only `ℕ`-indexed variables)
with a derived `DecidableEq` instance. This enables `native_decide` to check equality
of normalized forms at elaboration time, powering a reflection-based decision procedure.
-/

import Mathlib

/-! ## Computable Tropical Expression Type -/

/-- A fully computable tropical expression type.
Variables are indexed by `ℕ`; the supported operations are
tropical addition (`tmin`, i.e. `min`) and tropical multiplication (`add`, i.e. `+`). -/
inductive CTropExpr where
  | var  : ℕ → CTropExpr
  | tmin : CTropExpr → CTropExpr → CTropExpr
  | add  : CTropExpr → CTropExpr → CTropExpr
  deriving DecidableEq, Repr

namespace CTropExpr

/-! ## Computable Total Order -/

/-- Computable total order on `CTropExpr` for canonical sorting. -/
def cmp : CTropExpr → CTropExpr → Ordering
  | .var n₁, .var n₂ => compare n₁ n₂
  | .var _, _ => .lt
  | .tmin _ _, .var _ => .gt
  | .tmin a₁ b₁, .tmin a₂ b₂ =>
    match cmp a₁ a₂ with | .eq => cmp b₁ b₂ | r => r
  | .tmin _ _, .add _ _ => .lt
  | .add _ _, .var _ => .gt
  | .add _ _, .tmin _ _ => .gt
  | .add a₁ b₁, .add a₂ b₂ =>
    match cmp a₁ a₂ with | .eq => cmp b₁ b₂ | r => r

/-- Boolean ≤ derived from `cmp`. -/
def ble (e₁ e₂ : CTropExpr) : Bool :=
  match cmp e₁ e₂ with | .gt => false | _ => true

/-! ## Flatten, Build, Dedup -/

/-- Flatten nested `tmin` into a list of summands. -/
def flattenMin : CTropExpr → List CTropExpr
  | .tmin a b => flattenMin a ++ flattenMin b
  | e => [e]

/-- Flatten nested `add` into a list of factors. -/
def flattenAdd : CTropExpr → List CTropExpr
  | .add a b => flattenAdd a ++ flattenAdd b
  | e => [e]

/-- Remove consecutive duplicates from a sorted list (for idempotence of min). -/
def dedup : List CTropExpr → List CTropExpr
  | [] => []
  | [x] => [x]
  | x :: y :: rest =>
    if x = y then dedup (y :: rest) else x :: dedup (y :: rest)

/-- Build a right-associated `tmin` chain from a nonempty list. -/
def buildMin : List CTropExpr → CTropExpr
  | [] => .var 0  -- dummy; never reached on valid input
  | [e] => e
  | e :: es => .tmin e (buildMin es)

/-- Build a right-associated `add` chain from a nonempty list. -/
def buildAdd : List CTropExpr → CTropExpr
  | [] => .var 0
  | [e] => e
  | e :: es => .add e (buildAdd es)

/-! ## The ACI Normalizer -/

/-- **Computable ACI normalizer**: idempotent-commutative-associative for `min`,
associative-commutative for `+`.

For `tmin`: flatten → sort → dedup → rebuild.
For `add`:  flatten → sort → rebuild. -/
def cnormalize_ca : CTropExpr → CTropExpr
  | .var n => .var n
  | .tmin a b =>
    let a' := cnormalize_ca a
    let b' := cnormalize_ca b
    buildMin (dedup ((flattenMin (.tmin a' b')).mergeSort ble))
  | .add a b =>
    let a' := cnormalize_ca a
    let b' := cnormalize_ca b
    buildAdd ((flattenAdd (.add a' b')).mergeSort ble)

/-! ## Semantic Evaluation -/

/-- Evaluate a tropical expression given a variable assignment `σ : ℕ → ℝ`. -/
noncomputable def eval (σ : ℕ → ℝ) : CTropExpr → ℝ
  | .var n => σ n
  | .tmin a b => min (eval σ a) (eval σ b)
  | .add a b => eval σ a + eval σ b

/-- Evaluate a list as a `min`-chain. -/
noncomputable def evalMinList (σ : ℕ → ℝ) : List CTropExpr → ℝ
  | [] => 0
  | [e] => eval σ e
  | e :: es => min (eval σ e) (evalMinList σ es)

/-- Evaluate a list as a `+`-chain. -/
noncomputable def evalAddList (σ : ℕ → ℝ) : List CTropExpr → ℝ
  | [] => 0
  | [e] => eval σ e
  | e :: es => eval σ e + evalAddList σ es

end TropicalDistributed