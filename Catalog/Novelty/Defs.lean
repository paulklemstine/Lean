/-
Copyright (c) 2024. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Non-Archimedean Probability: Definitions

This module defines the framework for finitely additive measures valued in
ordered algebraic structures, with emphasis on the non-Archimedean case
where infinitesimal probabilities become meaningful.

## Main Definitions

* `IsAdditivelyInfinitesimal` — an element is infinitesimal if it is positive but
  all natural multiples are bounded by a given element.
* `HasInfinitesimal` — a structure has infinitesimal elements.
* `uniformFinsetMeasure` — the uniform finitely additive measure assigning
  weight `ε` to each singleton.
* `FinAddMeasure` — a structure for finitely additive measures on
  `Finset α` valued in an ordered additive commutative monoid.

## Key Insight

The Archimedean property is *exactly* the obstruction to assigning uniform
positive infinitesimal probability to points. In an Archimedean ordered field,
any positive element ε satisfies n·ε > 1 for some n, so a uniform measure
on n points would exceed total mass 1. In a non-Archimedean ordered field
(like the surreals), infinitesimals exist that never accumulate past any
standard positive number, enabling genuine infinitesimal probability.
-/

open Finset

/-! ## Infinitesimal Elements -/

/-- An element `x` of an ordered additive commutative monoid is **additively
infinitesimal** with respect to a bound `b` if `x` is positive and
`n • x ≤ b` for every natural number `n`. -/
def IsAdditivelyInfinitesimal {M : Type*} [AddCommMonoid M] [PartialOrder M] (x b : M) : Prop :=
  0 < x ∧ ∀ n : ℕ, n • x ≤ b

/-- The non-Archimedean condition: there exist positive elements whose
natural multiples never exceed a given bound. -/
def HasInfinitesimal {M : Type*} [AddCommMonoid M] [PartialOrder M] (b : M) : Prop :=
  ∃ x : M, IsAdditivelyInfinitesimal x b

/-! ## Uniform Finset Measure -/

/-- The uniform Finset measure assigning weight `ε` to each element.
For a finite set S, μ(S) = |S| • ε. -/
def uniformFinsetMeasure {M : Type*} [AddCommMonoid M]
    (ε : M) {α : Type*} (S : Finset α) : M :=
  S.card • ε

/-! ## Finitely Additive Measure -/

/-- A finitely additive measure on `Finset α` valued in an ordered
additive commutative monoid. -/
structure FinAddMeasure (α : Type*) (M : Type*)
    [DecidableEq α] [AddCommMonoid M] [PartialOrder M] where
  /-- The measure function -/
  toFun : Finset α → M
  /-- Empty set has measure zero -/
  empty : toFun ∅ = 0
  /-- Finite additivity: measure of disjoint union is sum of measures -/
  add_disjoint : ∀ (S T : Finset α), Disjoint S T → toFun (S ∪ T) = toFun S + toFun T
  /-- Non-negativity -/
  nonneg : ∀ (S : Finset α), 0 ≤ toFun S

/-- A finitely additive measure is a **probability premeasure** if its values
are bounded by a total mass. -/
def FinAddMeasure.IsBoundedBy {α : Type*} {M : Type*}
    [DecidableEq α] [AddCommMonoid M] [PartialOrder M]
    (μ : FinAddMeasure α M) (b : M) : Prop :=
  ∀ S : Finset α, μ.toFun S ≤ b