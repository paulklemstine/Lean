/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Perron–Frobenius: Definitions

Core definitions for the max-plus tropical spectral theory of finite real matrices.
This file provides the foundational layer for certifying throughput of
discrete-event systems via tropical eigenvalues.

## Main definitions

- `tropMatVec A x`: the max-plus matrix-vector product `(T_A x)_i = max_j (A_{ij} + x_j)`
- `IsTropicalEigenpair A λ v`: the eigenpair relation `T_A v = λ + v`
- `tropIterate A x k`: the k-step system evolution
- `tropMatMul A B`: max-plus matrix multiplication
- `maxCycleMean_2 A`: maximum cycle mean for 2×2 matrices

These definitions support direct application to scheduling and performance
verification: the tropical eigenvalue is the asymptotic cycle time of a
discrete-event system, and its inverse is the throughput.
-/
import Mathlib

open Finset Matrix

/-! ## Max-Plus Tropical Matrix-Vector Action -/

/-- The max-plus tropical matrix-vector product:
    `(T_A x)_i = max_j (A_{ij} + x_j)`.
    This is the one-step state evolution of a discrete-event system:
    task `i` completes at the latest of all predecessor completions plus transit times. -/
noncomputable def tropMatVec {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => Finset.sup' Finset.univ Finset.univ_nonempty (fun j => A i j + x j)

/-! ## Tropical Eigenpairs -/

/-- A tropical eigenpair `(λ, v)` of `A` satisfies `T_A v = λ + v` pointwise.
    The scalar `λ` is the tropical eigenvalue (= cycle time = inverse throughput).
    The vector `v` is the tropical eigenvector (= phase offsets of tasks). -/
def IsTropicalEigenpair {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (lam : ℝ) (v : Fin n → ℝ) : Prop :=
  ∀ i, tropMatVec A v i = lam + v i

/-! ## Iteration -/

/-- The k-th iterate of the tropical matrix-vector action. -/
noncomputable def tropIterate {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℕ → Fin n → ℝ
  | 0 => x
  | k + 1 => tropMatVec A (tropIterate A x k)

/-! ## Max-Plus Matrix Multiplication -/

/-- Max-plus matrix multiplication: `(A ⊗ B)_{ij} = max_k (A_{ik} + B_{kj})`. -/
noncomputable def tropMatMul {n : ℕ} [NeZero n]
    (A B : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => Finset.sup' Finset.univ Finset.univ_nonempty (fun k => A i k + B k j)

/-! ## Spectral Quantities -/

/-- Maximum diagonal entry of A (maximum self-loop weight). -/
noncomputable def maxSelfLoopWeight {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun v : Fin n => A v v)

/-- For a 2×2 matrix, the max cycle mean is
    `max(A₀₀, A₁₁, (A₀₁ + A₁₀)/2)`.
    This accounts for self-loops and the unique 2-cycle. -/
noncomputable def maxCycleMean_2 (A : Matrix (Fin 2) (Fin 2) ℝ) : ℝ :=
  max (max (A 0 0) (A 1 1)) ((A 0 1 + A 1 0) / 2)