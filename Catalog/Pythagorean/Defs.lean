/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Valuated Matroid Depth: Core Definitions

This file introduces the **directional depth filtration** for multivariate functions
`f : (α → ℕ) → ℝ`, building a higher-order curvature hierarchy that refines
classical M-convexity and tropical convexity notions.

## Mathematical Overview

Given a finite type `α` and a function `f : (α → ℕ) → ℝ`, we define:

1. **Directional log-concavity**: `f(m + eᵢ)² ≥ f(m) · f(m + 2eᵢ)` for all `m` and `i`.
2. **Ratio transform**: `Rᵢf(m) = f(m + eᵢ) / f(m)`, the discrete logarithmic derivative.
3. **Directional depth**: recursively, `f` has depth ≥ k+1 if it has directional
   log-concavity and all ratio transforms `Rᵢf` have depth ≥ k.

The depth filtration
  `depth 0 ⊃ depth 1 ⊃ depth 2 ⊃ ⋯`
provides a strictly finer invariant than first-order log-concavity alone.

## Main Definitions

* `MultiDirLogConcave` — multivariate directional log-concavity
* `ratioTransform` — the ratio transform operator Rᵢ
* `DirectionalDepthAtLeast` — recursive depth filtration
* `HasExactDepth` — a function has exactly depth k
* `degreeSlice` — the degree slice predicate
* `exchangeMove` — the exchange operation on multiindices
* `ExchangeClosedSupport` — exchange-closed support property
* `IsSupermodular` — supermodularity for functions on multiindices

## References

* Murota, "Discrete Convex Analysis", SIAM, 2003
* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

noncomputable section

open Finset BigOperators Function

namespace ValuatedMatroidDepth

variable {α : Type*} [Fintype α] [DecidableEq α]

/-! ## Degree Slices and Multiindex Operations -/

/-- The **degree slice** predicate: `m` has total degree `d`. -/
def degreeSlice (d : ℕ) (m : α → ℕ) : Prop :=
  ∑ i, m i = d

/-- Shift a multiindex by adding `eᵢ = Pi.single i 1`. -/
def shiftUp (m : α → ℕ) (i : α) : α → ℕ := m + Pi.single i 1

/-- Shift a multiindex by adding `2 · eᵢ`. -/
def shiftUp2 (m : α → ℕ) (i : α) : α → ℕ := m + Pi.single i 1 + Pi.single i 1

omit [Fintype α] in
@[simp]
theorem shiftUp_apply (m : α → ℕ) (i j : α) :
    shiftUp m i j = m j + if j = i then 1 else 0 := by
  simp [shiftUp, Pi.add_apply, Pi.single_apply]

omit [Fintype α] in
@[simp]
theorem shiftUp2_apply (m : α → ℕ) (i j : α) :
    shiftUp2 m i j = m j + if j = i then 2 else 0 := by
  simp [shiftUp2, Pi.add_apply, Pi.single_apply]
  split <;> omega

/-! ## Core Predicates -/

/-- **Multivariate directional log-concavity**: for every direction `i` and
    every multiindex `m`, `f(m + eᵢ)² ≥ f(m) · f(m + 2eᵢ)`. -/
def MultiDirLogConcave (f : (α → ℕ) → ℝ) : Prop :=
  ∀ (i : α) (m : α → ℕ), f (shiftUp m i) ^ 2 ≥ f m * f (shiftUp2 m i)

/-- **Mixed log-concavity**: the stronger multivariate condition that for all
    directions `i, j` (possibly equal) and every multiindex `m`,
    `f(m + eᵢ) · f(m + eⱼ) ≥ f(m) · f(m + eᵢ + eⱼ)`. When `i = j` this
    reduces to the single-direction condition. This is the natural multivariate
    generalization corresponding to Lorentzian polynomial theory. -/
def MixedLogConcave (f : (α → ℕ) → ℝ) : Prop :=
  ∀ (i j : α) (m : α → ℕ),
    f (m + Pi.single i 1) * f (m + Pi.single j 1) ≥
    f m * f (m + Pi.single i 1 + Pi.single j 1)

omit [Fintype α] in
/-- Mixed log-concavity implies single-direction log-concavity. -/
theorem MixedLogConcave.toMultiDir {f : (α → ℕ) → ℝ}
    (hf : MixedLogConcave f) : MultiDirLogConcave f := by
  intro i m
  have h := hf i i m
  simp only [shiftUp, shiftUp2]
  nlinarith [h]

/-- The **ratio transform** in direction `i`: `Rᵢf(m) = f(m + eᵢ) / f(m)`. -/
def ratioTransform (i : α) (f : (α → ℕ) → ℝ) : (α → ℕ) → ℝ :=
  fun m => f (shiftUp m i) / f m

/-- **Directional depth at least `k`**: a recursive definition.
    - Depth ≥ 0: trivially true.
    - Depth ≥ k+1: directionally log-concave AND every ratio transform
      `Rᵢf` has depth ≥ k. -/
def DirectionalDepthAtLeast : ℕ → ((α → ℕ) → ℝ) → Prop
  | 0, _ => True
  | k + 1, f => MultiDirLogConcave f ∧ ∀ i : α, DirectionalDepthAtLeast k (ratioTransform i f)

/-- A function has **exact depth** `k` if it has depth ≥ k but not depth ≥ k+1. -/
def HasExactDepth (k : ℕ) (f : (α → ℕ) → ℝ) : Prop :=
  DirectionalDepthAtLeast k f ∧ ¬ DirectionalDepthAtLeast (k + 1) f

/-- A function has **infinite depth** if it has depth ≥ k for all k. -/
def HasInfiniteDepth (f : (α → ℕ) → ℝ) : Prop :=
  ∀ k, DirectionalDepthAtLeast k f

/-! ## Exchange Operations -/

/-- The **exchange move**: given multiindex `m`, increment coordinate `i` and
    decrement coordinate `j` (when `m j > 0`). Uses `Nat` subtraction. -/
def exchangeMove (m : α → ℕ) (i j : α) : α → ℕ :=
  fun k => if k = i then m k + 1 else if k = j then m k - 1 else m k

/-- **Exchange-closed support**: for any two multiindices on the same degree
    slice with positive `f`-value, if `m i < n i` then there exists `j` with `n j < m j`
    such that the exchange move also has positive `f`-value. -/
def ExchangeClosedSupport (f : (α → ℕ) → ℝ) (d : ℕ) : Prop :=
  ∀ ⦃m n : α → ℕ⦄, degreeSlice d m → degreeSlice d n →
    0 < f m → 0 < f n →
    ∀ ⦃i : α⦄, m i < n i →
      ∃ j, n j < m j ∧ 0 < f (exchangeMove m i j)

/-! ## Supermodularity -/

/-- **Supermodularity** for functions on multiindices: for all `m` and distinct `i ≠ j`,
    `g(m + eᵢ + eⱼ) + g(m) ≥ g(m + eᵢ) + g(m + eⱼ)`. -/
def IsSupermodular (g : (α → ℕ) → ℝ) : Prop :=
  ∀ (i j : α) (m : α → ℕ), i ≠ j →
    g (m + Pi.single i 1 + Pi.single j 1) + g m ≥
    g (m + Pi.single i 1) + g (m + Pi.single j 1)

end ValuatedMatroidDepth

end