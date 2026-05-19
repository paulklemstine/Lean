/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Symmetric Power Euler Factors: Core Definitions

This file defines the fundamental objects in the invariant-theoretic approach
to symmetric-power Euler factors for GL₂.

## Main definitions

- `e1SymmPower n α β`: The first coefficient ∑_{k=0}^{n} α^{n-k} β^k.
- `symmTraceRec t d n`: Chebyshev recurrence P(0)=1, P(1)=t, P(n+2)=t·P(n+1)−d·P(n).
- `powerSumTwo t d n`: Power sum recurrence S(0)=2, S(1)=t, S(n+2)=t·S(n+1)−d·S(n).
  When t=α+β, d=αβ, this gives α^n + β^n.
- `symmPowerEulerDen n α β X`: The Euler denominator ∏_{k=0}^{n} (1 − α^{n−k} β^k X).
- `eulerPhiRec t d X n`: Recursive definition of the Euler denominator using only t, d, X.
-/

open Finset BigOperators

/-- The first coefficient of the Sym^n Euler factor: ∑_{k=0}^{n} α^{n-k} β^k. -/
def e1SymmPower {R : Type*} [CommRing R] (n : ℕ) (α β : R) : R :=
  ∑ k ∈ Finset.range (n + 1), α ^ (n - k) * β ^ k

/-- Recursive trace polynomial: P(0)=1, P(1)=t, P(n+2)=t·P(n+1)−d·P(n).
When evaluated at t=α+β, d=αβ, this equals e1SymmPower n α β. -/
def symmTraceRec {R : Type*} [CommRing R] (t d : R) : ℕ → R
  | 0 => 1
  | 1 => t
  | n + 2 => t * symmTraceRec t d (n + 1) - d * symmTraceRec t d n

/-- Power sum recurrence: S(0)=2, S(1)=t, S(n+2)=t·S(n+1)−d·S(n).
When t=α+β, d=αβ, this gives α^n + β^n. -/
def powerSumTwo {R : Type*} [CommRing R] (t d : R) : ℕ → R
  | 0 => 2
  | 1 => t
  | n + 2 => t * powerSumTwo t d (n + 1) - d * powerSumTwo t d n

/-- The symmetric-power Euler denominator: ∏_{k=0}^{n} (1 − α^{n−k} β^k X). -/
def symmPowerEulerDen {R : Type*} [CommRing R] (n : ℕ) (α β X : R) : R :=
  ∏ k ∈ Finset.range (n + 1), (1 - α ^ (n - k) * β ^ k * X)

/-- Recursive definition of the Euler denominator using only trace t, determinant d, and X.
Uses the recursion: Φ(0) = 1-X, Φ(1) = 1-tX+dX²,
Φ(n+2) = (1 - S(n+2)·X + d^{n+2}·X²) · Φ(n, t, d, d·X). -/
def eulerPhiRec {R : Type*} [CommRing R] (t d X : R) : ℕ → R
  | 0 => 1 - X
  | 1 => 1 - t * X + d * X ^ 2
  | n + 2 => (1 - powerSumTwo t d (n + 2) * X + d ^ (n + 2) * X ^ 2) *
              eulerPhiRec t d (d * X) n