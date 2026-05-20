/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Schanuel's Conjecture: Formal Framework

This file provides a precise formalization of Schanuel's conjecture over ℂ,
together with the algebraic infrastructure needed to state and derive
conditional consequences.

## Main Definitions

* `SchanuelProp n` — Schanuel's conjecture for families of size `n`
* `SchanuelConjecture` — The full conjecture (for all `n`)

## Mathematical Background

Schanuel's conjecture (1960s) states: if `z₁, …, zₙ ∈ ℂ` are linearly
independent over `ℚ`, then the transcendence degree of
`ℚ(z₁, …, zₙ, exp(z₁), …, exp(zₙ))` over `ℚ` is at least `n`.

This is one of the central open problems in transcendence theory,
generalizing the Lindemann–Weierstrass theorem, the Gelfond–Schneider
theorem, and implying the algebraic independence of `e` and `π`.
-/

import Mathlib

open Complex
open scoped BigOperators

namespace Schanuel

/-! ## Core definitions -/

/-- The set of values `{z i | i} ∪ {exp(z i) | i}` adjoined to `ℚ` in Schanuel's conjecture. -/
noncomputable def adjoinedSet {n : ℕ} (z : Fin n → ℂ) : Set ℂ :=
  Set.range z ∪ Set.range (fun i => exp (z i))

/-- The subalgebra `ℚ(z₁, …, zₙ, exp(z₁), …, exp(zₙ))` of `ℂ`. -/
noncomputable def adjoinedAlgebra {n : ℕ} (z : Fin n → ℂ) : Subalgebra ℚ ℂ :=
  Algebra.adjoin ℚ (adjoinedSet z)

/-- Schanuel's conjecture for families of size `n`:
if `z : Fin n → ℂ` is ℚ-linearly independent, then the transcendence degree of
`ℚ(z₁, …, zₙ, exp(z₁), …, exp(zₙ))` over `ℚ` is at least `n`. -/
def SchanuelProp (n : ℕ) : Prop :=
  ∀ z : Fin n → ℂ,
    LinearIndependent ℚ z →
      (n : Cardinal) ≤ Algebra.trdeg ℚ (adjoinedAlgebra z)

/-- The full Schanuel conjecture: `SchanuelProp n` for all `n`. -/
def SchanuelConjecture : Prop :=
  ∀ n, SchanuelProp n

/-! ## Basic properties -/

/-- `SchanuelProp 0` is trivially true: the empty family has no linear independence
constraint and the transcendence degree is at least 0. -/
theorem schanuelProp_zero : SchanuelProp 0 := by
  intro z _
  simp

/-- The full Schanuel conjecture implies `SchanuelProp n` for any `n`. -/
theorem SchanuelConjecture.prop (hSC : SchanuelConjecture) (n : ℕ) : SchanuelProp n :=
  hSC n

end