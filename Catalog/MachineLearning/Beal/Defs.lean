/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Beal Conjecture: Definitions and Core Statements

This file provides the formal definitions for the obstruction theory
around Beal's conjecture:
- The formal statement of Beal's conjecture
- An abstract ABC-statement schema
- Notation for the Mathlib radical (`UniqueFactorizationMonoid.radical`)
-/
import Mathlib

open Finset Nat UniqueFactorizationMonoid

/-! ## Beal's Conjecture: formal statement -/

/-- **Beal's Conjecture** (formal statement):
For all positive integers `A, B, C` and exponents `x, y, z > 2`,
if `A^x + B^y = C^z`, then `A, B, C` share a common prime factor. -/
def BealConjecture : Prop :=
  ∀ A B C x y z : ℕ,
    0 < A → 0 < B → 0 < C →
    2 < x → 2 < y → 2 < z →
    A ^ x + B ^ y = C ^ z →
    ∃ p : ℕ, Nat.Prime p ∧ p ∣ A ∧ p ∣ B ∧ p ∣ C

/-! ## ABC Conjecture: formal schema -/

/-- An **ABC-style hypothesis** at strength `1 + ε`:
For all coprime positive `a, b, c` with `a + b = c`,
we have `c ≤ rad(abc)^(1 + ε)`. -/
def ABCStatement (ε : ℝ) : Prop :=
  ∀ a b c : ℕ,
    0 < a → 0 < b → 0 < c →
    Nat.Coprime a b →
    a + b = c →
    (c : ℝ) ≤ ((radical (a * b * c) : ℕ) : ℝ) ^ (1 + ε)