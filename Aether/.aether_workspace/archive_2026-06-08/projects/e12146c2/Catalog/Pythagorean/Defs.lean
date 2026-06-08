/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Valuated Matroid Depth: Core Definitions

This file provides the core definitions for the directional depth filtration
theory on valuated matroids. The central idea is to measure "higher-order
discrete curvature" by iterating ratio transforms and checking whether
directional log-concavity persists at each level.

## Main Definitions

* `MultiDirLogConcave` — directional log-concavity for functions `(α → ℕ) → ℝ`
* `MixedLogConcave` — mixed (two-direction) log-concavity
* `ratioTransform` — the ratio transform `Rᵢf(m) = f(m + eᵢ) / f(m)`
* `DirectionalDepthAtLeast` — recursive depth predicate
* `HasInfiniteDepth` — infinite depth (all levels hold)
* `IsSupermodular` — supermodularity on lattice points
* `degreeSlice` — fixed-degree slice predicate
* `exchangeClosedSupport` — exchange-closed support condition
* `exchangeMove` — single exchange operation on multisets
* `HasExactDepth` — exact depth predicate

## References

* Murota, "Discrete Convex Analysis", SIAM, 2003
* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

noncomputable section

open Finset BigOperators Function

namespace ValuatedMatroidDepth

variable {α : Type*}

/-! ## Shift Operations -/

/-- Shift `m` up at coordinate `i` by 1. -/
def shiftUp [DecidableEq α] (i : α) (m : α → ℕ) : α → ℕ :=
  m + Pi.single i 1

/-- Shift `m` up at coordinates `i` and `j` by 1 each. -/
def shiftUp2 [DecidableEq α] (i j : α) (m : α → ℕ) : α → ℕ :=
  m + Pi.single i 1 + Pi.single j 1

/-! ## Log-Concavity Predicates -/

/-- **Directional log-concavity**: for every direction `i` and every point `m`,
    `f(m + eᵢ)² ≥ f(m) · f(m + 2eᵢ)`. -/
def MultiDirLogConcave [DecidableEq α] (f : (α → ℕ) → ℝ) : Prop :=
  ∀ (i : α) (m : α → ℕ),
    f m * f (m + Pi.single i 1 + Pi.single i 1) ≤
    f (m + Pi.single i 1) * f (m + Pi.single i 1)

/-- **Mixed log-concavity**: for every pair of directions `i, j` and point `m`,
    `f(m) · f(m + eᵢ + eⱼ) ≤ f(m + eᵢ) · f(m + eⱼ)`. -/
def MixedLogConcave [DecidableEq α] (f : (α → ℕ) → ℝ) : Prop :=
  ∀ (i j : α) (m : α → ℕ),
    f m * f (m + Pi.single i 1 + Pi.single j 1) ≤
    f (m + Pi.single i 1) * f (m + Pi.single j 1)

/-! ## Ratio Transform -/

/-- The **ratio transform** in direction `i`:
    `Rᵢf(m) = f(m + eᵢ) / f(m)`. -/
def ratioTransform [DecidableEq α] (i : α) (f : (α → ℕ) → ℝ) : (α → ℕ) → ℝ :=
  fun m => f (m + Pi.single i 1) / f m

/-! ## Directional Depth -/

/-- **Directional depth at least `k`**: recursive predicate.
    - Depth ≥ 0 is vacuously true.
    - Depth ≥ k+1 means `f` is directionally log-concave AND every ratio
      transform `Rᵢf` has depth ≥ k. -/
def DirectionalDepthAtLeast [DecidableEq α] : ℕ → ((α → ℕ) → ℝ) → Prop
  | 0, _ => True
  | k + 1, f => MultiDirLogConcave f ∧ ∀ i : α, DirectionalDepthAtLeast k (ratioTransform i f)

/-- **Infinite depth**: `f` has depth ≥ k for every k. -/
def HasInfiniteDepth [DecidableEq α] (f : (α → ℕ) → ℝ) : Prop :=
  ∀ k : ℕ, DirectionalDepthAtLeast k f

/-- **Exact depth k**: depth ≥ k but not depth ≥ k+1. -/
def HasExactDepth [DecidableEq α] (k : ℕ) (f : (α → ℕ) → ℝ) : Prop :=
  DirectionalDepthAtLeast k f ∧ ¬ DirectionalDepthAtLeast (k + 1) f

/-! ## Supermodularity -/

/-- **Supermodularity** for functions on `(α → ℕ)`:
    for all `i ≠ j` and all `m`,
    `g(m + eᵢ + eⱼ) + g(m) ≥ g(m + eᵢ) + g(m + eⱼ)`. -/
def IsSupermodular [DecidableEq α] (g : (α → ℕ) → ℝ) : Prop :=
  ∀ (i j : α) (m : α → ℕ), i ≠ j →
    g (m + Pi.single i 1) + g (m + Pi.single j 1) ≤
    g m + g (m + Pi.single i 1 + Pi.single j 1)

/-! ## Degree Slice and Exchange Operations -/

/-- A multiset `m : α → ℕ` lies in the **degree-d slice** when `∑ᵢ m(i) = d`. -/
def degreeSlice [Fintype α] (d : ℕ) (m : α → ℕ) : Prop :=
  (∑ i, m i) = d

/-- **Exchange move**: decrease `m` at `j` by 1 (truncating) and increase at `i` by 1. -/
def exchangeMove [DecidableEq α] (m : α → ℕ) (i j : α) : α → ℕ :=
  Function.update (Function.update m j (m j - 1)) i (Function.update m j (m j - 1) i + 1)

/-- **Exchange-closed support** on a degree slice: for any two positive-weight
    multisets `m, n` and a coordinate where `m i < n i`, there exists a
    complementary coordinate `j` with `n j < m j` such that the exchange
    move produces a positive-weight multiset. -/
def exchangeClosedSupport [Fintype α] [DecidableEq α]
    (f : (α → ℕ) → ℝ) (d : ℕ) : Prop :=
  ∀ ⦃m n : α → ℕ⦄, degreeSlice d m → degreeSlice d n →
    0 < f m → 0 < f n →
    ∀ ⦃i : α⦄, m i < n i →
      ∃ j, n j < m j ∧ 0 < f (exchangeMove m i j)

end ValuatedMatroidDepth

end