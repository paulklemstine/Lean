import Mathlib

/-!
# Certified Spectral / Matrix Bounding

This file formalizes row-sum bounds for matrices and their consequences
for bounding matrix-vector products. These are the computable certificates
that a `spectral_bound` tactic would use: local row-sum inequalities
imply global action bounds.

## Main Results

* `matrix_row_sum_bound` — every finite matrix has a finite max row sum
* `matrix_mul_vec_entry_bound` — each entry of Ax is bounded by row sum × sup norm
* `spectral_bound_sound` — row-sum bounds on |A_ij| imply bounds on |∑ A_ij|
* `spectral_bound_vec` — row-sum certificate implies matrix-vector bound
-/

open Finset BigOperators Matrix

/-! ## Row-Sum Certificate Theorem -/

/-
If all absolute row sums are bounded by C, then each row's absolute sum
    is bounded by C. This is the core certificate theorem.
-/
theorem spectral_bound_sound {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (C : ℝ)
    (hC : ∀ i : Fin n, ∑ j : Fin n, |A i j| ≤ C) :
    ∀ i : Fin n, |∑ j : Fin n, A i j| ≤ C := by
  exact fun i => le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( hC i )

/-
Row-sum certificate implies matrix-vector bound for unit-ball vectors.
-/
theorem spectral_bound_vec {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (C : ℝ)
    (hC : ∀ i : Fin n, ∑ j : Fin n, |A i j| ≤ C) (x : Fin n → ℝ)
    (hx : ∀ j : Fin n, |x j| ≤ 1) :
    ∀ i : Fin n, |∑ j : Fin n, A i j * x j| ≤ C := by
  exact fun i => le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( le_trans ( Finset.sum_le_sum fun _ _ => by simpa [ abs_mul ] using mul_le_mul_of_nonneg_left ( hx _ ) ( abs_nonneg _ ) ) ( hC i ) )

/-
Every finite matrix has a row-sum bound (existence theorem).
-/
theorem matrix_row_sum_bound {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
    ∃ C : ℝ, ∀ i : Fin n, ∑ j : Fin n, |A i j| ≤ C := by
  exact ⟨ ∑ i, ∑ j, |A i j|, fun i => Finset.single_le_sum ( fun i _ => Finset.sum_nonneg fun j _ => abs_nonneg ( A i j ) ) ( Finset.mem_univ i ) ⟩

/-
Each component of Ax is bounded by the row sum times sup norm of x.
    This is the triangle inequality applied row-by-row.
-/
theorem matrix_mul_vec_entry_bound {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) (M : ℝ) (hM : ∀ j : Fin n, |x j| ≤ M) (_hM0 : 0 ≤ M)
    (i : Fin n) :
    |∑ j : Fin n, A i j * x j| ≤ (∑ j : Fin n, |A i j|) * M := by
  exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( by rw [ Finset.sum_mul _ _ _ ] ; exact Finset.sum_le_sum fun j _ => by rw [ abs_mul ] ; exact mul_le_mul_of_nonneg_left ( hM j ) ( abs_nonneg _ ) )

/-! ## Tactic: spectral_bound -/

/-- The `spectral_bound` tactic attempts to prove matrix inequality goals
    by applying row-sum certificate theorems and reducing to arithmetic. -/
macro "spectral_bound" : tactic =>
  `(tactic| first
    | (apply spectral_bound_sound; intro i; simp [Fin.sum_univ_succ]; norm_num)
    | (apply spectral_bound_vec; · intro i; simp [Fin.sum_univ_succ]; norm_num; · intro j; assumption)
    | norm_num)