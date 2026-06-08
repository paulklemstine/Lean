/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Matrix Algebra: Core Algebraic Theorems

This file proves the fundamental algebraic identities of tropical (min-plus)
matrix algebra, collecting results from `Defs.lean` and `Spectral.lean`
and adding additional algebraic properties.

## Main results

* `tropMatAdd_idem` — idempotency: `A ⊕ A = A`
* `tropMatAdd_comm` — commutativity of entrywise min
* `tropMatAdd_assoc` — associativity of entrywise min
* `tropMatMul_assoc'` — associativity of tropical multiplication
* `tropMatPow_add'` — power splitting
* `tropMatPow_diag_subadditive'` — subadditivity of diagonal entries
* `tropMatMul_tropMatAdd_left'` — left distributivity
-/
import Mathlib
import Tropical.Matrix.Defs
import Tropical.Matrix.Spectral

noncomputable section

open Finset BigOperators

variable {n : ℕ}

/-! ## Tropical Addition Properties -/

/-- Tropical addition is idempotent: `A ⊕ A = A` (min is idempotent). -/
theorem tropMatAdd_idem (A : Fin n → Fin m → ℝ) :
    tropMatAdd A A = A := by
  ext i j; simp [tropMatAdd]

/-- Tropical addition is commutative. -/
theorem tropMatAdd_comm (A B : Fin n → Fin m → ℝ) :
    tropMatAdd A B = tropMatAdd B A := by
  ext i j; simp [tropMatAdd, min_comm]

/-- Tropical addition is associative. -/
theorem tropMatAdd_assoc (A B C : Fin n → Fin m → ℝ) :
    tropMatAdd (tropMatAdd A B) C = tropMatAdd A (tropMatAdd B C) := by
  ext i j; simp [tropMatAdd, min_assoc]

/-! ## Re-exports from Spectral.lean -/

/-- Associativity of tropical matrix multiplication (re-export). -/
theorem tropMatMul_assoc' [NeZero n]
    (A B C : Fin n → Fin n → ℝ) :
    tropMatMul (tropMatMul A B) C = tropMatMul A (tropMatMul B C) :=
  tropMatMul_assoc A B C

/-- Power splitting (re-export). -/
theorem tropMatPow_add' [NeZero n]
    (A : Fin n → Fin n → ℝ) (m k : ℕ) :
    tropMatPow A (m + k + 1) = tropMatMul (tropMatPow A m) (tropMatPow A k) :=
  tropMatPow_add A m k

/-- Subadditivity of diagonal entries (re-export). -/
theorem tropMatPow_diag_subadditive' [NeZero n]
    (A : Fin n → Fin n → ℝ) (i : Fin n) (m k : ℕ) :
    tropMatPow A (m + k + 1) i i ≤ tropMatPow A m i i + tropMatPow A k i i :=
  tropMatPow_diag_subadditive A i m k

/-- Left distributivity (re-export). -/
theorem tropMatMul_tropMatAdd_left' [NeZero n]
    (A B₁ B₂ : Fin n → Fin n → ℝ) :
    tropMatMul A (tropMatAdd B₁ B₂) =
    tropMatAdd (tropMatMul A B₁) (tropMatMul A B₂) :=
  tropMatMul_tropMatAdd_left A B₁ B₂

end