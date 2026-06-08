/-
Copyright (c) 2025 Harmonic. All rights reserved.

# Spectral Depth-Efficiency of qEML Networks: Core Definitions

This file establishes the foundational definitions for the spectral approximation
theory of quantum Extended Machine Learning (qEML) networks on compact groups.

The key insight is that qEML layers act as spectral filters on harmonic expansions
(Peter–Weyl modes), and depth corresponds to the number of effective representation
bands that can be synthesized.

## Main definitions

* `SpectralApprox` — A spectral approximant with bounded frequency support
* `HasCoefficientDecay` — Pointwise polynomial decay of spectral coefficients
* `spectralTailSum` — The squared L² truncation error (tail of coefficient series)
-/
import Mathlib

open Finset BigOperators

/-- A spectral qEML approximant on a compact group, modeled by a finite-depth
family of spectral coefficients with bounded frequency support.

In the Peter–Weyl decomposition of L²(G), each irreducible representation π_n
contributes modes at "frequency" n. A depth-d qEML network can synthesize modes
up to frequency d, so a spectral approximant of depth d has coefficients supported
on {0, 1, ..., d}. -/
structure SpectralApprox where
  /-- The depth (maximum frequency/representation degree) of the approximant -/
  depth : ℕ
  /-- The spectral coefficients -/
  coeffs : ℕ → ℝ
  /-- Coefficients vanish beyond the depth -/
  supported : ∀ n, depth < n → coeffs n = 0

/-- A coefficient sequence has polynomial decay of order k with constant C if
|a(n)| ≤ C / n^k for all n ≥ 1. This models Sobolev-type spectral regularity:
higher k means smoother target functions on the compact group.

For class functions on SU(2), the coefficients a(n) are the character expansion
coefficients, and k controls the rate of decay in the Peter–Weyl expansion. -/
def HasCoefficientDecay (a : ℕ → ℝ) (C : ℝ) (k : ℕ) : Prop :=
  0 < C ∧ 0 < k ∧ ∀ n : ℕ, 1 ≤ n → |a n| ≤ C / (n : ℝ) ^ k

/-- The spectral tail sum: the sum of squared coefficients from index (d+1) to N.
This equals ‖f - T_d f‖²_{L²} when the coefficients come from an orthonormal
expansion (by Parseval/Plancherel). -/
noncomputable def spectralTailSum (a : ℕ → ℝ) (d N : ℕ) : ℝ :=
  ∑ n ∈ Finset.Icc (d + 1) N, (a n) ^ 2

/-- A class function on a group is one that is constant on conjugacy classes.
On SU(2), class functions are determined by their character expansion. -/
def IsClassFunction {G : Type*} [Group G] (f : G → ℝ) : Prop :=
  ∀ g h : G, f (h * g * h⁻¹) = f g

/-- The spectral approximant constructed from truncating a coefficient sequence
at depth d. This is the canonical "best depth-d approximant" in the spectral model. -/
def truncateCoeffs (a : ℕ → ℝ) (d : ℕ) : SpectralApprox where
  depth := d
  coeffs := fun n => if n ≤ d then a n else 0
  supported := fun n hn => by simp [Nat.not_le.mpr hn]

/-- The approximation error (squared) between a coefficient sequence and a
spectral approximant, measured over the first N modes. -/
noncomputable def approxErrorSq (a : ℕ → ℝ) (A : SpectralApprox) (N : ℕ) : ℝ :=
  ∑ n ∈ Finset.range (N + 1), (a n - A.coeffs n) ^ 2