/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical (Min-Plus) Matrix Algebra: Core Definitions

This file defines the fundamental operations of tropical matrix algebra
over ℝ using the min-plus convention:
- Tropical addition = entrywise min
- Tropical multiplication = min-plus matrix product (shortest-path composition)
- Tropical powers = iterated tropical multiplication
- Tropical trace = minimum diagonal entry

These form the algebraic substrate for shortest-path algorithms,
discrete-event systems, and tropical spectral theory.

## Main definitions

* `tropMatAdd` — entrywise minimum of two matrices
* `tropMatMul` — min-plus matrix product: `(A ⊗ B)ᵢⱼ = min_k (Aᵢₖ + Bₖⱼ)`
* `tropMatPow` — iterated tropical multiplication (1-indexed)
* `tropTrace` — minimum diagonal entry (tropical trace)
* `tropicalEigenvalue` — infimum of `tropTrace(A^k)/k` over k ≥ 1
-/
import Mathlib

noncomputable section

open Finset BigOperators

variable {n : ℕ}

/-! ## Core Matrix Operations -/

/-- Tropical (min-plus) entrywise addition: `(A ⊕ B)ᵢⱼ = min(Aᵢⱼ, Bᵢⱼ)`. -/
def tropMatAdd (A B : Fin n → Fin m → ℝ) : Fin n → Fin m → ℝ :=
  fun i j => min (A i j) (B i j)

/-- Min-plus (tropical) matrix multiplication:
    `(A ⊗ B)ᵢⱼ = min_k (Aᵢₖ + Bₖⱼ)`.
    This is the algebraic core of shortest-path composition. -/
def tropMatMul [NeZero n] (A : Fin n → Fin k → ℝ) (B : Fin k → Fin m → ℝ)
    [NeZero k] : Fin n → Fin m → ℝ :=
  fun i j => Finset.inf' Finset.univ (Finset.univ_nonempty) (fun t => A i t + B t j)

/-- Tropical matrix power (1-indexed):
    `tropMatPow A 1 = A`, `tropMatPow A (k+1) = tropMatMul (tropMatPow A k) A`.
    For square matrices with `NeZero n`. -/
def tropMatPow [NeZero n] (A : Fin n → Fin n → ℝ) : ℕ → Fin n → Fin n → ℝ
  | 0 => A  -- We define tropMatPow A 0 = A (so tropMatPow A k represents A^{k+1})
  | k + 1 => tropMatMul (tropMatPow A k) A

/-- Tropical trace: minimum diagonal entry `min_i A_{ii}`.
    This captures the minimum-weight closed walk of length 1. -/
def tropTrace [NeZero n] (A : Fin n → Fin n → ℝ) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty (fun i => A i i)

/-- Tropical eigenvalue (minimum cycle mean):
    `λ(A) = inf_{k ≥ 1} tropTrace(A^{k}) / k`.
    This uses our 0-indexed power convention where `tropMatPow A k` = A^{k+1}. -/
def tropicalEigenvalue [NeZero n] (A : Fin n → Fin n → ℝ) : ℝ :=
  sInf {x : ℝ | ∃ k : ℕ, x = tropTrace (tropMatPow A k) / (↑k + 1)}

/-! ## Basic Properties -/

/-- Tropical multiplication is bounded by any witness. -/
theorem tropMatMul_le_witness [NeZero n] [NeZero k]
    (A : Fin n → Fin k → ℝ) (B : Fin k → Fin m → ℝ) (i : Fin n) (j : Fin m) (t : Fin k) :
    tropMatMul A B i j ≤ A i t + B t j :=
  Finset.inf'_le _ (Finset.mem_univ _)

/-- Tropical trace is at most any diagonal entry. -/
theorem tropTrace_le_diag [NeZero n] (A : Fin n → Fin n → ℝ) (i : Fin n) :
    tropTrace A ≤ A i i :=
  Finset.inf'_le _ (Finset.mem_univ _)

/-- The tropical trace of a matrix is at most any diagonal entry. -/
theorem tropTrace_le_entry [NeZero n] (A : Fin n → Fin n → ℝ) (i : Fin n) :
    tropTrace A ≤ A i i :=
  Finset.inf'_le _ (Finset.mem_univ _)

/-- Diagonal of tropical product bounded by sum of diagonals. -/
theorem tropMatMul_diag_le [NeZero n]
    (A B : Fin n → Fin n → ℝ) (i : Fin n) :
    tropMatMul A B i i ≤ A i i + B i i :=
  tropMatMul_le_witness A B i i i

end