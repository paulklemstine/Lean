/-
  # Hadamard Matrices and Balanced Block Designs

  This file establishes the bridge between Hadamard matrices and combinatorial
  design theory:
  - Definition of symmetric BIBD parameters
  - Row properties of normalized Hadamard matrices
  - The fundamental counting that connects orthogonality to design parameters

  The key result: row-pair intersection counting in a normalized Hadamard matrix
  yields the parameters of a symmetric 2-(4t-1, 2t-1, t-1) design.
-/
import Mathlib

open Matrix Finset BigOperators

/-! ## Core definitions -/

def IsHadamardD {n : ℕ} (H : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  (∀ i j, H i j = 1 ∨ H i j = -1) ∧
  H * H.transpose = (n : ℤ) • (1 : Matrix (Fin n) (Fin n) ℤ)

/-- A normalized Hadamard matrix has first row and column all 1. -/
def IsNormalizedHadamardD {n : ℕ} [NeZero n] (H : Matrix (Fin n) (Fin n) ℤ) : Prop :=
  IsHadamardD H ∧
  (∀ j, H 0 j = 1) ∧
  (∀ i, H i 0 = 1)

/-! ## Symmetric BIBD structure -/

/-- A symmetric balanced incomplete block design with parameters (v, k, λ).
    - v points and v blocks
    - each block contains exactly k points
    - every pair of distinct points appears in exactly λ blocks -/
structure SymmetricBIBD where
  v : ℕ
  k : ℕ
  lam : ℕ
  /-- Incidence matrix: entry (i,j) is 1 if point i is in block j, else 0 -/
  inc : Matrix (Fin v) (Fin v) ℕ
  inc_binary : ∀ i j, inc i j = 0 ∨ inc i j = 1
  block_size : ∀ j, ∑ i, inc i j = k
  point_replication : ∀ i, ∑ j, inc i j = k
  pair_count : ∀ i₁ i₂, i₁ ≠ i₂ → ∑ j, inc i₁ j * inc i₂ j = lam

/-! ## Row dot product extraction -/

theorem row_dot_eq_D {n : ℕ} {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsHadamardD H) (i j : Fin n) :
    ∑ k, H i k * H j k = if i = j then (n : ℤ) else 0 := by
      have := congr_fun ( congr_fun hH.2 i ) j; simp_all +decide [ Matrix.mul_apply, Matrix.one_apply ] ;

/-! ## Row properties of normalized Hadamard matrices -/

/-
In a normalized Hadamard matrix, non-first rows sum to 0.
-/
theorem normalized_row_sum_zero {n : ℕ} [NeZero n] {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsNormalizedHadamardD H) (i : Fin n) (hi : i ≠ 0) :
    ∑ j, H i j = 0 := by
      -- By definition of IsHadamardD, we know that ∑ k, H i k * H 0 k = 0.
      have h_dot_zero : ∑ k, H i k * H 0 k = 0 := by
        convert row_dot_eq_D hH.1 i 0 using 1 ; aesop;
      have := hH.2.1; aesop;

/-
In a normalized Hadamard matrix, each non-first row has
    exactly n/2 entries equal to 1.
-/
theorem normalized_row_ones_count {n : ℕ} [NeZero n]
    {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsNormalizedHadamardD H) (i : Fin n) (hi : i ≠ 0) :
    (Finset.univ.filter fun j => H i j = 1).card = n / 2 := by
      -- By normalized_row_sum_zero, we have ∑ j, H i j = 0. Since each H i j is ±1, we can write this sum as (number of +1s) - (number of -1s) = 0.
      have h_sum_zero : ∑ j, (if H i j = 1 then 1 else -1) = 0 := by
        convert normalized_row_sum_zero hH i hi using 2;
        cases hH.1.1 i ‹_› <;> aesop;
      simp_all +decide [ Finset.sum_ite ];
      exact Eq.symm ( Nat.div_eq_of_eq_mul_left zero_lt_two ( by linarith [ show ( Finset.card ( Finset.filter ( fun x => H i x = 1 ) Finset.univ ) : ℕ ) + Finset.card ( Finset.filter ( fun x => ¬H i x = 1 ) Finset.univ ) = n by rw [ Finset.card_filter_add_card_filter_not ] ; simp +decide ] ) )

/-
In a normalized Hadamard matrix, distinct non-first rows agree on +1
    in exactly n/4 positions. This is the key design parameter.
-/
theorem normalized_row_pair_ones {n : ℕ} [NeZero n]
    {H : Matrix (Fin n) (Fin n) ℤ}
    (hH : IsNormalizedHadamardD H) (i₁ i₂ : Fin n)
    (hi₁ : i₁ ≠ 0) (hi₂ : i₂ ≠ 0) (hij : i₁ ≠ i₂) :
    (Finset.univ.filter fun j => H i₁ j = 1 ∧ H i₂ j = 1).card = n / 4 := by
      -- By definition of $IsHadamardD$, we know that $\sum_{k=0}^{n-1} (H_{i₁k})(H_{i₂k}) = 0$.
      have h_dot : ∑ k, (H i₁ k) * (H i₂ k) = 0 := by
        convert row_dot_eq_D hH.1 i₁ i₂ using 1 ; aesop;
      -- Let's count the number of positions where $H_{i₁k} = 1$ and $H_{i₂k} = 1$.
      have h_count_1_1 : Finset.card (Finset.filter (fun j => H i₁ j = 1 ∧ H i₂ j = 1) Finset.univ) =
        (∑ k, (H i₁ k + 1) * (H i₂ k + 1)) / 4 := by
          have h_count_1_1 : ∀ k, (H i₁ k + 1) * (H i₂ k + 1) = if H i₁ k = 1 ∧ H i₂ k = 1 then 4 else 0 := by
            intro k; rcases hH.1.1 i₁ k with ha | ha <;> rcases hH.1.1 i₂ k with hb | hb <;> norm_num [ ha, hb ] ;
          simp +decide [ Finset.sum_ite, h_count_1_1 ];
      -- Since $\sum_{k=0}^{n-1} H_{i₁k} = 0$ and $\sum_{k=0}^{n-1} H_{i₂k} = 0$, we have:
      have h_sum_zero : ∑ k, H i₁ k = 0 ∧ ∑ k, H i₂ k = 0 := by
        exact ⟨ normalized_row_sum_zero hH i₁ hi₁, normalized_row_sum_zero hH i₂ hi₂ ⟩;
      simp_all +decide [ add_mul, mul_add, Finset.sum_add_distrib ];
      grind