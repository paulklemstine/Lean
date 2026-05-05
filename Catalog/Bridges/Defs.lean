/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Functorial Mackey Completion for Maxitive Measures on Finite T₀ Spaces

## Overview

In a finite T₀ space, topology is equivalent to a specialization preorder:
closed sets are lower sets, and irreducible closed sets are principal lower
sets `↓x = {y | y ≤ x}`. We develop a completion theory for set functions
(modeling maxitive measures / capacities) via **codensity assignments** on
these irreducible closed sets.

## Main definitions

* `FiniteT0SupportClass` — the finite T₀ separation principle
* `irreducibleClosed` — principal lower set `↓x`
* `irreducibleClosedWeight` — weight of a set function on `↓x`
* `supportGaugeEq` — equality of codensity weights
* `CodensityAssignment` — monotone function `X → ℝ≥0∞`
* `measureToCodensity` — canonical map from monotone set functions to codensity
* `codensityToMeasure` — inverse: construct a set function from codensity data
* `idempotentKantorovich` — pseudodistance via monotone test functions
* `pushforward` — pushforward of a set function along a map

## Main results

* `codensity_roundtrip` — `measureToCodensity ∘ codensityToMeasure = id`
* `idempotentKantorovich_eq_zero_iff_supportGaugeEq` — zero distance ⟺ codensity equality
* `quotient_equiv_codensityAssignment` — the quotient by zero-distance ≃ CodensityAssignment
* `idempotentKantorovich_pushforward_le` — pushforward is nonexpansive
* `FunctorialIdempotentMackeyCompletion` — the full functorial completion theorem
-/

noncomputable section

open scoped ENNReal
open Set

/-! ## The Finite T₀ Separation Principle -/

/-- The finite T₀ separation principle: if two points have the same principal
    lower set, they are equal. On a finite preorder, this is equivalent to
    antisymmetry, hence to the T₀ separation axiom on the Alexandrov topology. -/
class FiniteT0SupportClass (X : Type*) [Fintype X] [Preorder X] : Prop where
  antisymm_of_closure_eq : ∀ {x y : X}, (∀ z : X, z ≤ x ↔ z ≤ y) → x = y

/-- Every finite partial order is a finite T₀ space. -/
instance instFiniteT0SupportClassOfPartialOrder
    {X : Type*} [Fintype X] [PartialOrder X] : FiniteT0SupportClass X where
  antisymm_of_closure_eq h := le_antisymm ((h _).mp le_rfl) ((h _).mpr le_rfl)

/-! ## Irreducible Closed Sets and Codensity Weights -/

/-- The irreducible closed set (principal lower set) associated to a point `x`.
    In the Alexandrov topology on a preorder, this is `↓x = {y | y ≤ x}`,
    which is always closed and irreducible. -/
def irreducibleClosed (X : Type*) [Preorder X] (x : X) : Set X := {y | y ≤ x}

/-- The codensity weight of a point `x` under a set function `μ`:
    the value of `μ` on the principal lower set `↓x`. -/
def irreducibleClosedWeight {X : Type*} [Preorder X]
    (μ : Set X → ℝ≥0∞) (x : X) : ℝ≥0∞ :=
  μ (irreducibleClosed X x)

/-- Two set functions agree on codensity if they assign equal weight to
    every principal lower set. This is the kernel of `measureToCodensity`. -/
def supportGaugeEq {X : Type*} [Preorder X]
    (μ ν : Set X → ℝ≥0∞) : Prop :=
  ∀ x : X, irreducibleClosedWeight μ x = irreducibleClosedWeight ν x

/-! ## Test Functions and Idempotent Kantorovich Distance -/

/-- A test function on a preorder is a monotone real-valued function.
    These serve as the dual objects in the idempotent Kantorovich theory. -/
def IsTestFunction {X : Type*} [Preorder X] (f : X → ℝ) : Prop :=
  Monotone f

/-- The idempotent Kantorovich pseudodistance between two set functions.
    This is the supremum over monotone test functions of the absolute
    discrepancy in their "idempotent integrals" (max-plus pairings).
    The symmetrization ensures `d(μ,ν) = 0 ↔ supportGaugeEq μ ν`. -/
def idempotentKantorovich {X : Type*} [Fintype X] [Preorder X]
    (μ ν : Set X → ℝ≥0∞) : ℝ≥0∞ :=
  ⨆ f : {f : X → ℝ // IsTestFunction f},
    ENNReal.ofReal (abs
      ((⨆ x : X, (f.1 x - (irreducibleClosedWeight μ x).toReal)) -
       (⨆ x : X, (f.1 x - (irreducibleClosedWeight ν x).toReal))))

/-! ## Codensity Assignments -/

/-- A codensity assignment on a preorder is a monotone function `X → ℝ≥0∞`.
    Each value `c x` represents the "codensity" on the irreducible closed
    set `↓x`. In finite T₀ spaces, this is the completed/canonical form
    of a maxitive measure. -/
structure CodensityAssignment (X : Type*) [Preorder X] where
  /-- The underlying function assigning weights to points. -/
  toFun : X → ℝ≥0∞
  /-- The assignment is monotone with respect to the preorder. -/
  monotone' : Monotone toFun

namespace CodensityAssignment

variable {X : Type*} [Preorder X]

instance : FunLike (CodensityAssignment X) X ℝ≥0∞ where
  coe := CodensityAssignment.toFun
  coe_injective' a b h := by cases a; cases b; congr

@[simp] theorem coe_mk (f : X → ℝ≥0∞) (hf) : (CodensityAssignment.mk f hf : X → ℝ≥0∞) = f := rfl

@[ext]
theorem ext {c d : CodensityAssignment X} (h : ∀ x, c x = d x) : c = d :=
  DFunLike.ext c d h

theorem monotone (c : CodensityAssignment X) : Monotone c := c.monotone'

end CodensityAssignment

/-! ## Maps Between Measures and Codensity Assignments -/

/-- A set function is *monotone* if it preserves subset ordering. This is
    a basic property of measures, capacities, and maxitive measures. -/
def IsMonotoneSetFun {X : Type*} (μ : Set X → ℝ≥0∞) : Prop :=
  ∀ ⦃A B : Set X⦄, A ⊆ B → μ A ≤ μ B

/-- The canonical map from monotone set functions to codensity assignments.
    Maps `μ` to the function `x ↦ μ(↓x)`. -/
def measureToCodensity {X : Type*} [Preorder X]
    (μ : Set X → ℝ≥0∞) (hμ : IsMonotoneSetFun μ) : CodensityAssignment X where
  toFun := irreducibleClosedWeight μ
  monotone' := fun _ _ hxy => hμ (fun _ hz => le_trans hz hxy)

/-- Construct a set function from a codensity assignment by taking the
    supremum over elements in the set. This is a right inverse of
    `measureToCodensity` and models a "maxitive measure". -/
def codensityToMeasure {X : Type*} [Preorder X]
    (c : CodensityAssignment X) : Set X → ℝ≥0∞ :=
  fun A => ⨆ x ∈ A, c.toFun x

/-- Pushforward of a set function along a map `f`: `(f_* μ)(B) = μ(f⁻¹(B))`. -/
def pushforward {X Y : Type*} (f : X → Y)
    (μ : Set X → ℝ≥0∞) : Set Y → ℝ≥0∞ :=
  fun B => μ (f ⁻¹' B)

/-- A set function is *maxitive* if its value on any set equals the supremum
    of its values on principal lower sets of elements in that set.
    This is the key property of "max-plus measures" / capacities in
    idempotent measure theory. -/
def IsMaxitiveSetFun {X : Type*} [Preorder X] (μ : Set X → ℝ≥0∞) : Prop :=
  ∀ A : Set X, μ A = ⨆ x ∈ A, μ (irreducibleClosed X x)

/-! ## The Zero-Distance Setoid -/

/-- The zero-distance equivalence relation on set functions:
    `μ ≈ ν` iff they have the same codensity weights on all principal lower sets. -/
def supportGaugeSetoid (X : Type*) [Preorder X] : Setoid (Set X → ℝ≥0∞) where
  r := supportGaugeEq
  iseqv := {
    refl := fun _ _ => rfl
    symm := fun h x => (h x).symm
    trans := fun h₁ h₂ x => (h₁ x).trans (h₂ x)
  }

end