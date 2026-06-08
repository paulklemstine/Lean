/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Valuated Matroid Depth via Iterated Directional Log-Concavity

This file defines a **depth filtration** on nonnegative functions
`f : (α → ℕ) → ℝ` based on iterated directional log-concavity.

## Mathematical Overview

Given a function `f` on multi-indices, the **directional log-concavity** condition
states that for all pairs of directions `(i, j)` and all multi-indices `m`:

  `f(m + eᵢ) · f(m + eⱼ) ≥ f(m) · f(m + eᵢ + eⱼ)`

When `i = j`, this gives ordinary log-concavity along coordinate axes.
When `i ≠ j`, this gives a mixed condition equivalent to supermodularity of `-log f`.

The **ratio transform** in direction `i` is:

  `Rᵢf(m) = f(m + eᵢ) / f(m)`

**Directional depth** is defined recursively:
- depth 0: always holds
- depth (k+1): directionally log-concave AND all ratio transforms have depth k

This creates a filtration:
  `depth 0 ⊃ depth 1 ⊃ depth 2 ⊃ ⋯`

## Main Definitions

* `DirectionalLogConcave` — mixed/directional log-concavity for multivariate functions
* `RatioTransform` — the directional ratio transform operator
* `DirectionalDepthAtLeast` — the recursive depth predicate
* `Supermodular` — supermodularity on lattice points
* `DegreeSlice` — fixed-degree hypersurface condition
* `ExchangeClosedSupport` — matroid-like exchange on the support
* `ExchangeMove` — elementary exchange operation on multi-indices

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Murota, "Discrete Convex Analysis", SIAM, 2003
-/

noncomputable section

open Finset BigOperators

variable {α : Type*} [DecidableEq α]

/-! ## Core Definitions -/

/-- The unit basis vector `eᵢ` as a function `α → ℕ`. -/
def basisVec (i : α) : α → ℕ := Pi.single i 1

/-- **Directional log-concavity** for a function on multi-indices.
    For all directions `i, j` and all multi-indices `m`:
    `f(m + eᵢ) · f(m + eⱼ) ≥ f(m) · f(m + eᵢ + eⱼ)`.

    When `i = j`, this gives same-direction log-concavity.
    When `i ≠ j`, this gives the mixed log-concavity / log-submodularity condition. -/
def DirectionalLogConcave (f : (α → ℕ) → ℝ) : Prop :=
  ∀ (i j : α) (m : α → ℕ),
    f (m + basisVec i) * f (m + basisVec j) ≥ f m * f (m + basisVec i + basisVec j)

/-- The **ratio transform** of `f` in direction `i`:
    `Rᵢf(m) = f(m + eᵢ) / f(m)`. -/
def RatioTransform (i : α) (f : (α → ℕ) → ℝ) : (α → ℕ) → ℝ :=
  fun m => f (m + basisVec i) / f m

/-- **Directional depth at least `k`**: the recursive filtration.
    - depth 0: trivially satisfied
    - depth (k+1): `f` is directionally log-concave AND every ratio transform
      `Rᵢf` has depth at least `k`. -/
def DirectionalDepthAtLeast : ℕ → ((α → ℕ) → ℝ) → Prop
  | 0, _ => True
  | k + 1, f => DirectionalLogConcave f ∧ ∀ i : α, DirectionalDepthAtLeast k (RatioTransform i f)

/-- A function has **exact depth** `k` if it has depth at least `k` but not `k+1`. -/
def HasExactDepth (k : ℕ) (f : (α → ℕ) → ℝ) : Prop :=
  DirectionalDepthAtLeast k f ∧ ¬ DirectionalDepthAtLeast (k + 1) f

/-- **Supermodularity** of a function on multi-indices:
    `g(m + eᵢ + eⱼ) + g(m) ≥ g(m + eᵢ) + g(m + eⱼ)` for all `i ≠ j`. -/
def MultiSupermodular (g : (α → ℕ) → ℝ) : Prop :=
  ∀ (i j : α) (m : α → ℕ), i ≠ j →
    g (m + basisVec i + basisVec j) + g m ≥ g (m + basisVec i) + g (m + basisVec j)

/-- A multi-index `m` lies on the **degree slice** of degree `d`. -/
def DegreeSlice [Fintype α] (d : ℕ) (m : α → ℕ) : Prop :=
  ∑ i, m i = d

/-- The **exchange move**: given multi-index `m`, increment at `i` and decrement at `j`.
    Uses natural number truncation (so `m j = 0` gives `m j - 1 = 0`). -/
def ExchangeMove (m : α → ℕ) (i j : α) : α → ℕ :=
  Function.update (Function.update m i (m i + 1)) j (Function.update m i (m i + 1) j - 1)

/-- **Exchange-closed support**: for any two multi-indices on a degree slice with
    positive values, any excess in one direction can be compensated by an exchange. -/
def ExchangeClosedSupport [Fintype α] (f : (α → ℕ) → ℝ) (d : ℕ) : Prop :=
  ∀ ⦃m n : α → ℕ⦄, DegreeSlice d m → DegreeSlice d n →
    0 < f m → 0 < f n →
    ∀ ⦃i : α⦄, m i < n i →
      ∃ j, n j < m j ∧ 0 < f (ExchangeMove m i j)

end