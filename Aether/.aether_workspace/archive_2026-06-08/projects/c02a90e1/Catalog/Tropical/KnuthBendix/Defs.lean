/-
Copyright (c) 2026 Harmonic. All rights reserved.

# Tropical Normal Forms: Definitions

Tropical expressions in variables `Fin n` with constants from `ℝ`,
binary `min`, and binary `+`. We define a normal form representation
as finite minima of affine forms (constant + linear combination with
natural multiplicities), and a normalization procedure.
-/

import Mathlib

noncomputable section

open Finset BigOperators

/-! ## Tropical Expression Syntax -/

/-- Tropical expressions in variables `Fin n`. -/
inductive TropExpr (n : ℕ) where
  | const : ℝ → TropExpr n
  | var   : Fin n → TropExpr n
  | tmin  : TropExpr n → TropExpr n → TropExpr n
  | add   : TropExpr n → TropExpr n → TropExpr n
  deriving Inhabited

namespace TropExpr

/-- Semantics of tropical expressions. -/
def eval {n : ℕ} : TropExpr n → (Fin n → ℝ) → ℝ
  | const c, _   => c
  | var i, x     => x i
  | tmin e₁ e₂, x => min (eval e₁ x) (eval e₂ x)
  | add e₁ e₂, x  => eval e₁ x + eval e₂ x

end TropExpr

/-! ## Affine Forms and Tropical Normal Forms -/

/-- An affine tropical monomial: constant plus multiplicities of variables. -/
structure AffineForm (n : ℕ) where
  constant : ℝ
  coeff    : Fin n → ℕ
  deriving Inhabited

namespace AffineForm

/-- Evaluate an affine form at a point. -/
def eval {n : ℕ} (a : AffineForm n) (x : Fin n → ℝ) : ℝ :=
  a.constant + ∑ i : Fin n, (a.coeff i : ℝ) * x i

/-- The constant affine form `c`. -/
def ofConst {n : ℕ} (c : ℝ) : AffineForm n :=
  ⟨c, fun _ => 0⟩

/-- The affine form for a single variable `x_i`. -/
def ofVar {n : ℕ} (i : Fin n) : AffineForm n :=
  ⟨0, fun j => if j = i then 1 else 0⟩

/-- Add two affine forms (pointwise). -/
def add {n : ℕ} (a b : AffineForm n) : AffineForm n :=
  ⟨a.constant + b.constant, fun i => a.coeff i + b.coeff i⟩

end AffineForm

/-! ## Tropical Normal Forms -/

/-- A tropical normal form is a nonempty list of affine forms,
    representing their pointwise minimum. -/
abbrev TropNF (n : ℕ) := List (AffineForm n)

namespace TropNF

/-- Evaluate a tropical normal form as the minimum of its affine forms.
    Empty list evaluates to 0 (a sentinel; in practice we maintain nonemptiness). -/
def eval {n : ℕ} : TropNF n → (Fin n → ℝ) → ℝ
  | [], _      => 0
  | [a], x     => a.eval x
  | a :: as, x => min (a.eval x) (eval as x)

/-- Merge two normal forms (corresponds to `min`): just concatenate. -/
def mergeMin {n : ℕ} (N₁ N₂ : TropNF n) : TropNF n := N₁ ++ N₂

/-- Add two normal forms (corresponds to `+`): form all pairwise sums.
    This implements the distributive expansion:
    (min_i a_i) + (min_j b_j) = min_{i,j} (a_i + b_j). -/
def addNF {n : ℕ} (N₁ N₂ : TropNF n) : TropNF n :=
  (N₁.flatMap (fun a => N₂.map (fun b => AffineForm.add a b)))

end TropNF

/-! ## Normalization -/

/-- Normalize a tropical expression into a tropical normal form. -/
def TropExpr.normalize {n : ℕ} : TropExpr n → TropNF n
  | .const c    => [AffineForm.ofConst c]
  | .var i      => [AffineForm.ofVar i]
  | .tmin e₁ e₂ => TropNF.mergeMin (normalize e₁) (normalize e₂)
  | .add e₁ e₂  => TropNF.addNF (normalize e₁) (normalize e₂)

end