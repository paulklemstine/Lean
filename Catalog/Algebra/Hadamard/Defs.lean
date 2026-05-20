/-
  # Hadamard Matrix Theory — Core Definitions

  This file establishes the foundational definitions for Hadamard matrix theory:
  - `IsHadamard`: a ±1 matrix H such that H * Hᵀ = n • I
  - `IsNormalizedHadamard`: a Hadamard matrix with first row and column all 1s
  - `HadamardOrder`: existence predicate on orders
  - `HadamardEquivalent`: equivalence up to row/column sign flips and permutations
  - `hadamardExcess`: total sum of entries
-/
import Mathlib

open Matrix Finset BigOperators

/-! ## Core Definitions -/

/-- A matrix is Hadamard if all entries are ±1 and H * Hᵀ = n • I. -/
def IsHadamard {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  (∀ i j, H i j = 1 ∨ H i j = -1) ∧
  H * H.transpose = (n : ℤ) • (1 : Matrix (Fin n) (Fin n) ℤ)

/-- A normalized Hadamard matrix has first row and column all 1s. -/
def IsNormalizedHadamard {n : ℕ} [NeZero n] (H : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  IsHadamard H ∧
  (∀ j, H 0 j = 1) ∧
  (∀ i, H i 0 = 1)

/-- An order n admits a Hadamard matrix. -/
def HadamardOrder (n : ℕ) : Prop :=
  ∃ H : Matrix (Fin n) (Fin n) ℤ, IsHadamard H

/-- The excess of a ±1 matrix is the sum of all its entries. -/
def hadamardExcess {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) : ℤ :=
  ∑ i, ∑ j, H i j

/-- Hadamard equivalence: H and K are equivalent if K can be obtained from H
    by permuting rows/columns and flipping signs of rows/columns. -/
def HadamardEquivalent {n : ℕ}
    (H K : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  ∃ (σ τ : Equiv.Perm (Fin n)) (d₁ d₂ : Fin n → ℤ),
    (∀ i, d₁ i = 1 ∨ d₁ i = -1) ∧
    (∀ j, d₂ j = 1 ∨ d₂ j = -1) ∧
    (∀ i j, K i j = d₁ i * H (σ i) (τ j) * d₂ j)

/-- Bundled Hadamard matrix. -/
structure HadamardMatrix (n : ℕ) where
  toMatrix : Matrix (Fin n) (Fin n) ℤ
  entries_pm_one : ∀ i j, toMatrix i j = 1 ∨ toMatrix i j = -1
  orthogonal : toMatrix * toMatrix.transpose = (n : ℤ) • (1 : Matrix (Fin n) (Fin n) ℤ)

theorem HadamardMatrix.isHadamard {n : ℕ} (H : HadamardMatrix n) : IsHadamard H.toMatrix :=
  ⟨H.entries_pm_one, H.orthogonal⟩

/-! ## Basic lemmas about entries -/

/-- Every entry of a Hadamard matrix squares to 1. -/
theorem IsHadamard.entry_sq {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamard H) (i j : Fin n) : H i j ^ 2 = 1 := by
  rcases hH.1 i j with h | h <;> simp [h]

/-- The absolute value of every entry of a Hadamard matrix is 1. -/
theorem IsHadamard.entry_abs {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamard H) (i j : Fin n) : |H i j| = 1 := by
  rcases hH.1 i j with h | h <;> simp [h]

/-- Each row has self-dot-product equal to n. -/
theorem IsHadamard.row_dot_self {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamard H) (i : Fin n) :
    ∑ k, H i k * H i k = (n : ℤ) := by
  have h := congr_fun (congr_fun hH.2 i) i
  simp [Matrix.mul_apply, Matrix.transpose_apply, Matrix.smul_apply] at h
  exact h

/-- Distinct rows are orthogonal. -/
theorem IsHadamard.row_orthogonal {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamard H) (i j : Fin n) (hij : i ≠ j) :
    ∑ k, H i k * H j k = 0 := by
  have h := congr_fun (congr_fun hH.2 i) j
  simp [Matrix.mul_apply, Matrix.transpose_apply, Matrix.smul_apply, hij] at h
  exact h

/-! ## Trivial orders -/

/-- Order 1 is a Hadamard order. -/
theorem hadamardOrder_one : HadamardOrder 1 := by
  refine ⟨fun _ _ => 1, fun i j => Or.inl rfl, ?_⟩
  ext i j
  have hi := Subsingleton.elim i j
  subst hi
  simp [Matrix.mul_apply]

/-- Order 2 is a Hadamard order. -/
theorem hadamardOrder_two : HadamardOrder 2 :=
  ⟨!![1, 1; 1, -1], fun i j => by fin_cases i <;> fin_cases j <;> simp,
    by ext i j; fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_two]⟩