/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Expression Normalization: A Verified Tactic Kernel

This file implements a certified normalizer for tropical (min-plus) expressions over ℝ.
We define:
- `TropExpr`: a small expression language with constants, variables, min, and addition
- `eval`: semantic evaluation in an environment
- `size`: syntactic complexity measure
- `normalize`: a recursive normalizer performing constant folding and idempotence elimination

We prove the following main theorems:
1. `normalize_preserves_semantics`: normalization preserves evaluation semantics
2. `normalize_nonincreasing_size`: normalization does not increase expression size
3. `normalize_idempotent`: normalization is idempotent (a closure operator)
4. `normalize_isNormalized`: normalization outputs normal forms
5. `normalize_certified`: the combined certified normalizer theorem

Together these constitute a **verified tactic kernel**: an executable normalization
procedure with machine-checked correctness, suitable as the trusted core of
proof-producing automation for tropical algebra.
-/

import Mathlib

open Classical

noncomputable section

/-! ## Expression Language -/

/-- A tropical expression over ℝ with constants, variables, min, and addition. -/
inductive TropExpr where
  | const : ℝ → TropExpr
  | var   : ℕ → TropExpr
  | tmin  : TropExpr → TropExpr → TropExpr
  | add   : TropExpr → TropExpr → TropExpr

namespace TropExpr

instance : DecidableEq TropExpr := fun a b => Classical.dec (a = b)

/-! ## Semantic Evaluation -/

/-- Evaluate a tropical expression in environment `σ`. -/
def eval (σ : ℕ → ℝ) : TropExpr → ℝ
  | .const r   => r
  | .var n     => σ n
  | .tmin a b  => min (eval σ a) (eval σ b)
  | .add a b   => eval σ a + eval σ b

/-! ## Syntactic Complexity -/

/-- Size of a tropical expression (number of nodes). -/
def size : TropExpr → Nat
  | .const _   => 1
  | .var _     => 1
  | .tmin a b  => size a + size b + 1
  | .add a b   => size a + size b + 1

/-! ## Normalization -/

/-- Normalize a tropical expression by constant folding and idempotence elimination. -/
def normalize : TropExpr → TropExpr
  | .const r => .const r
  | .var n => .var n
  | .add a b =>
      let a' := normalize a
      let b' := normalize b
      match a', b' with
      | .const x, .const y => .const (x + y)
      | _, _ => .add a' b'
  | .tmin a b =>
      let a' := normalize a
      let b' := normalize b
      if a' = b' then a'
      else
        match a', b' with
        | .const x, .const y => .const (min x y)
        | _, _ => .tmin a' b'

/-! ## Normal Form Predicate -/

/-- A predicate recognizing expressions in normal form. -/
def isNormalized : TropExpr → Bool
  | .const _ => true
  | .var _ => true
  | .add (.const _) (.const _) => false
  | .add a b => isNormalized a && isNormalized b
  | .tmin a b =>
      if a = b then false
      else match a, b with
        | .const _, .const _ => false
        | _, _ => isNormalized a && isNormalized b

/-! ## Main Theorems -/

/-
Normalization preserves semantic evaluation.
-/
theorem normalize_preserves_semantics (σ : ℕ → ℝ) (e : TropExpr) :
    eval σ (normalize e) = eval σ e := by
  -- By induction on the structure of the expression, we can show that the evaluation of the normalized expression is equal to the evaluation of the original expression.
  induction' e with a b ih_a ih_b;
  · rfl;
  · rfl;
  · grind +locals;
  · unfold TropExpr.normalize;
    rename_i a b ha hb;
    cases h : a.normalize <;> cases h' : b.normalize <;> simp_all +decide [ TropExpr.eval ]

/-
Normalization does not increase expression size.
-/
theorem normalize_nonincreasing_size (e : TropExpr) :
    size (normalize e) ≤ size e := by
  induction' e using TropExpr.recOn with a b ih_a ih_b;
  · rfl;
  · rfl;
  · grind +locals;
  · grind +locals

/-- The combined semantics-and-size theorem: the minimum viable reflective theorem. -/
theorem normalize_preserves_semantics_and_size (σ : ℕ → ℝ) (e : TropExpr) :
    eval σ (normalize e) = eval σ e ∧ size (normalize e) ≤ size e :=
  ⟨normalize_preserves_semantics σ e, normalize_nonincreasing_size e⟩

/-
Normalization is idempotent: normalizing twice equals normalizing once.
-/
theorem normalize_idempotent (e : TropExpr) :
    normalize (normalize e) = normalize e := by
  induction' e using TropExpr.recOn with e ih;
  · rfl;
  · rfl;
  · grind +locals;
  · grind +locals

/-
Normalization produces expressions in normal form.
-/
theorem normalize_isNormalized (e : TropExpr) :
    isNormalized (normalize e) = true := by
  -- We'll use induction on the structure of the expression.
  induction' e with e ih;
  · -- In the base case, when the expression is a constant, the normalization is just the constant itself.
    simp [normalize, isNormalized] at *;
  · -- The normalize of a variable is the variable itself, which is trivially normalized.
    simp [TropExpr.normalize, TropExpr.isNormalized];
  · grind +locals;
  · unfold TropExpr.normalize;
    rename_i a b ha hb;
    cases a' : a.normalize <;> cases b' : b.normalize <;> simp_all +decide;
    all_goals exact Bool.and_eq_true_iff.mpr ⟨ ha, hb ⟩ ;

/-- The certified normalizer theorem: output is in normal form and preserves semantics. -/
theorem normalize_certified (σ : ℕ → ℝ) (e : TropExpr) :
    isNormalized (normalize e) = true ∧ eval σ (normalize e) = eval σ e :=
  ⟨normalize_isNormalized e, normalize_preserves_semantics σ e⟩

/-
Extensional uniqueness: expressions with the same normal form have the same semantics.
-/
theorem normalize_extensional_uniqueness (e₁ e₂ : TropExpr)
    (h : normalize e₁ = normalize e₂) (σ : ℕ → ℝ) :
    eval σ e₁ = eval σ e₂ := by
  -- By the semantics-preserving property of normalization, we have that `eval σ (normalize e₁) = eval σ (normalize e₂)`.
  have h_eval_eq : eval σ (normalize e₁) = eval σ (normalize e₂) := by
    rw [h];
  rw [ ← normalize_preserves_semantics σ e₁, ← normalize_preserves_semantics σ e₂, h_eval_eq ]

/-! ## One-Step Rewrite Soundness -/

/-- A single rewrite step applied at the top level. -/
def rewriteStep : TropExpr → TropExpr
  | .tmin (.const x) (.const y) => .const (min x y)
  | .add (.const x) (.const y) => .const (x + y)
  | .tmin a b => if a = b then a else .tmin a b
  | e => e

/-
One-step rewriting preserves semantics.
-/
theorem rewrite_step_sound (σ : ℕ → ℝ) (e : TropExpr) :
    eval σ (rewriteStep e) = eval σ e := by
  -- By definition of `eval`, we can split into cases based on the structure of `e`.
  cases e <;> simp [eval, rewriteStep];
  · rename_i a b;
    cases a <;> cases b <;> simp +decide [ eval ];
    · split_ifs <;> simp +decide [ *, TropExpr.eval ];
    · split_ifs <;> simp +decide [ *, eval ];
    · split_ifs <;> simp +decide [ *, TropExpr.eval ];
  · rename_i a b;
    cases a <;> cases b <;> simp +decide [ eval ]

/-! ## Semantic Bounds Preservation -/

/-
Normalization preserves any upper bound on evaluation.
-/
theorem normalize_preserves_upper_bound (σ : ℕ → ℝ) (e : TropExpr) (B : ℝ)
    (h : eval σ e ≤ B) :
    eval σ (normalize e) ≤ B := by
  exact le_trans ( by exact ( normalize_preserves_semantics σ e ) ▸ h ) le_rfl

end TropExpr

end