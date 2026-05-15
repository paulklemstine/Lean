/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Finite Information Complexity: Definitions

Core definitions for the bridge between finite-state realizability,
information-theoretic entropy bounds, and proof coding complexity.

## Key definitions

* `shannonEntropy` — Shannon entropy of a finite probability distribution
* `FiniteProb` — a probability distribution on a finite type
* `uniformProb` — the uniform distribution on a nonempty finite type

## Mathematical context

These definitions support the central thesis:
**bounded information complexity forces bounded realizability complexity**,
and conversely, realizability/compression theorems induce entropy-style
structural constraints.

Application keywords: information bottleneck, finite-state complexity,
entropy bound, proof compression, coding complexity, latent dimension,
semantic capacity, formal information theory.
-/

import Mathlib

open scoped BigOperators
open Finset Real Classical

noncomputable section

namespace FiniteInformationComplexity

/-! ## Shannon Entropy for Finite Distributions -/

/-- Shannon entropy of a probability distribution `p` on a finite type `α`.
    Defined as `H(p) = -∑ₐ p(a) · log(p(a))`, with the convention `0 · log 0 = 0`.

    This is the fundamental measure of information content that bridges
    state-space complexity to information-theoretic bounds. -/
def shannonEntropy {α : Type*} [Fintype α] (p : α → ℝ) : ℝ :=
  -∑ a : α, if p a = 0 then 0 else p a * Real.log (p a)

/-- A probability distribution on a finite type: nonneg and sums to 1. -/
structure FiniteProb (α : Type*) [Fintype α] where
  prob : α → ℝ
  nonneg : ∀ a, 0 ≤ prob a
  sum_one : ∑ a : α, prob a = 1

/-- The uniform distribution on a nonempty finite type. -/
def uniformProb (α : Type*) [Fintype α] [Nonempty α] : FiniteProb α where
  prob := fun _ => (1 : ℝ) / Fintype.card α
  nonneg := fun _ => by positivity
  sum_one := by simp [Finset.card_univ]

/-- Shannon entropy of a FiniteProb. -/
def FiniteProb.entropy {α : Type*} [Fintype α] (P : FiniteProb α) : ℝ :=
  shannonEntropy P.prob

end FiniteInformationComplexity