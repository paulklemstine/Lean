/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# PF₂ Log-Concavity: Main Theorems

This file proves that coefficient sequences of products of linear polynomials
with nonneg coefficients are log-concave, and applies this to binomial coefficients,
partition matroids, and fermionic partition functions.

## Main results

* `choose_logConcave` — Binomial coefficients `C(n,k)` satisfy the log-concavity
  inequality `C(n,k+1)² ≥ C(n,k) · C(n,k+2)`.
* `prodLinear_coeff_ratioDecreasing` — The coefficient sequence of `∏(1 + wᵢX)`
  is ratio-decreasing (hence log-concave) when all `wᵢ ≥ 0`.
* `fermionPartition_logConcave` — Fermionic partition function coefficients are
  log-concave (cross-domain bridge to statistical mechanics).
* `PF2CertifiedSeq.logConcave` — Any PF₂-certified sequence is log-concave.

## Proof strategy

We use **Route B (convolution/induction)**: each factor `(1 + wᵢX)` multiplies the
generating polynomial, and we prove that this operation preserves the ratio-decreasing
property. The base case is the constant polynomial `1`. This gives an algorithmic,
factorization-driven proof of log-concavity that is computable and extensible.

This approach provides a **second axis of explanation** for combinatorial log-concavity:
instead of the deep algebraic-geometric machinery of Adiprasito–Huh–Katz (hard Lefschetz
on Chow rings), we use elementary analytic/algebraic properties of generating functions.
The result is an effective, machine-checkable certificate system.
-/

import Mathlib
import Pythagorean.PF2Defs

open Polynomial Finset

/-! ## Theorem 1: Binomial coefficients are log-concave -/

/-
**Binomial log-concavity (ℕ version)**: For all `n, k`,
    `C(n,k+1)² ≥ C(n,k) · C(n,k+2)`.

    Proof: Use `Nat.choose_succ_right_eq` to write
    `C(n,k+1)·(k+1) = C(n,k)·(n-k)` and
    `C(n,k+2)·(k+2) = C(n,k+1)·(n-k-1)`.
    Then `C(n,k+1)²·(k+1)·(k+2) = C(n,k)·C(n,k+1)·(n-k)·(k+2)`
    and `C(n,k)·C(n,k+2)·(k+1)·(k+2) = C(n,k)·C(n,k+1)·(n-k-1)·(k+1)`.
    The difference is `C(n,k)·C(n,k+1)·(n+1) ≥ 0`.
-/
theorem choose_logConcave_nat (n k : ℕ) :
    Nat.choose n (k + 1) * Nat.choose n (k + 1) ≥
    Nat.choose n k * Nat.choose n (k + 2) := by
  by_cases h : n < k + 1;
  · simp +arith +decide [ Nat.choose_eq_zero_of_lt h ];
    exact Or.inr ( Nat.choose_eq_zero_of_lt ( by linarith ) );
  · have := Nat.choose_succ_right_eq n k; have := Nat.choose_succ_right_eq n ( k + 1 ) ; simp_all +decide [ mul_assoc, mul_comm, mul_left_comm ] ;
    nlinarith [ Nat.sub_add_cancel h.le, Nat.sub_add_cancel ( by linarith : k + 1 ≤ n ), Nat.choose_pos h.le ]

/-- **Binomial log-concavity (ℝ version)**: The sequence `k ↦ C(n,k)` is log-concave. -/
theorem choose_logConcave (n : ℕ) :
    IsLogConcaveSeq (fun k => (Nat.choose n k : ℝ)) := by
  intro k
  rw [sq]
  have := choose_logConcave_nat n k
  simp only
  exact_mod_cast this

/-! ## Coefficient extraction for products with linear factors -/

/-- The coefficient of `X^(k+1)` in `P * (1 + w·X)` equals
    `P.coeff (k+1) + w · P.coeff k`. -/
theorem coeff_mul_one_add_wX (P : Polynomial ℝ) (w : ℝ) (k : ℕ) :
    (P * (C 1 + C w * X)).coeff (k + 1) = P.coeff (k + 1) + w * P.coeff k := by
  have : P * (C 1 + C w * X) = P * C 1 + P * (C w * X) := mul_add P _ _
  rw [this, coeff_add]
  have h1 : (P * C 1).coeff (k + 1) = P.coeff (k + 1) := by simp
  have h2 : (P * (C w * X)).coeff (k + 1) = w * P.coeff k := by
    have : P * (C w * X) = C w * (P * X) := by ring
    rw [this, coeff_C_mul, coeff_mul_X]
  rw [h1, h2]

/-- The constant coefficient of `P * (1 + w·X)` equals `P.coeff 0`. -/
theorem coeff_mul_one_add_wX_zero (P : Polynomial ℝ) (w : ℝ) :
    (P * (C 1 + C w * X)).coeff 0 = P.coeff 0 := by
  have : P * (C 1 + C w * X) = P * C 1 + P * (C w * X) := mul_add P _ _
  rw [this, coeff_add]
  have h1 : (P * C 1).coeff 0 = P.coeff 0 := by simp
  have h2 : (P * (C w * X)).coeff 0 = 0 := by
    have : P * (C w * X) = C w * (P * X) := by ring
    rw [this, coeff_C_mul, coeff_mul_X_zero, mul_zero]
  rw [h1, h2, add_zero]

/-! ## Theorem 2: Products of linear factors have ratio-decreasing coefficients -/

/-
The constant polynomial `1` has ratio-decreasing coefficients.
-/
theorem ratioDecreasing_one :
    IsRatioDecreasing (fun k => (1 : Polynomial ℝ).coeff k) := by
  constructor <;> simp_all +decide [ Polynomial.coeff_one ];
  exact fun n => by split_ifs <;> norm_num;

/-
**Key inductive step**: If `P` has nonneg, ratio-decreasing coefficients and `w ≥ 0`,
    then `P * (1 + w·X)` also has nonneg, ratio-decreasing coefficients.

    The proof decomposes the product `b(j+1)·b(k+1) - b(j)·b(k+2)` where
    `b` are the coefficients of `P * (1 + wX)`, into a sum of three nonneg terms
    using the ratio-decreasing property of the original coefficients.
-/
theorem ratioDecreasing_mul_linear (P : Polynomial ℝ) (w : ℝ) (hw : 0 ≤ w)
    (hP : IsRatioDecreasing (fun k => P.coeff k)) :
    IsRatioDecreasing (fun k => (P * (C 1 + C w * X)).coeff k) := by
  -- By definition of `IsRatioDecreasing`, we need to show that the coefficients of `P * (C 1 + C w * X)` are nonneg and ratio-decreasing.
  constructor;
  · intro n; induction' n with n ih <;> simp_all +decide [ Polynomial.coeff_eq_zero_of_natDegree_lt ] ;
    · exact hP.1 0;
    · simp_all +decide [ mul_add, add_mul, Polynomial.coeff_eq_zero_of_natDegree_lt ];
      exact add_nonneg ( hP.1 _ ) ( by rw [ show ( P * ( C w * X ) ) = ( C w * X ) * P by ring ] ; rw [ Polynomial.coeff_mul ] ; exact Finset.sum_nonneg fun _ _ => mul_nonneg ( by cases ‹ℕ × ℕ› ; aesop ) ( hP.1 _ ) );
  · -- Let's choose any $j$ and $k$ such that $j \leq k$.
    intro j k hjk
    by_cases hj : j = 0;
    · rcases k with ( _ | k ) <;> simp_all +decide [ Polynomial.coeff_eq_zero_of_natDegree_lt ];
      · have := hP.2 0 0; have := hP.2 0 1; have := hP.2 1 1; simp_all +decide [ Polynomial.coeff_mul ] ;
        norm_num [ Finset.Nat.sum_antidiagonal_succ, Polynomial.coeff_one, Polynomial.coeff_X, Polynomial.coeff_C ] at *;
        have := hP.1 0; have := hP.1 1; have := hP.1 2; have := hP.1 3; norm_num at *; nlinarith [ mul_nonneg hw ( hP.1 0 ), mul_nonneg hw ( hP.1 1 ), mul_nonneg hw ( hP.1 2 ), mul_nonneg hw ( hP.1 3 ) ] ;
      · have := hP.2 0 ( k + 1 ) ; simp_all +decide [ Polynomial.coeff_mul ];
        simp_all +decide [ Finset.Nat.sum_antidiagonal_succ', Polynomial.coeff_one, Polynomial.coeff_X, Polynomial.coeff_C ];
        nlinarith [ mul_nonneg hw ( hP.1 0 ), mul_nonneg hw ( hP.1 1 ), mul_nonneg hw ( hP.1 ( k + 1 ) ), mul_nonneg hw ( hP.1 ( k + 2 ) ), mul_nonneg hw ( hP.1 ( k + 3 ) ), hP.1 0, hP.1 1, hP.1 ( k + 1 ), hP.1 ( k + 2 ), hP.1 ( k + 3 ) ];
    · -- Apply the coefficient formulas from `coeff_mul_one_add_wX` and `coeff_mul_one_add_wX_zero`.
      have h_coeff : ∀ k, (P * (C 1 + C w * X)).coeff k = P.coeff k + w * P.coeff (k - 1) * (if k > 0 then 1 else 0) := by
        intro k; rcases k with ( _ | k ) <;> simp_all +decide [ Polynomial.coeff_eq_zero_of_natDegree_lt ] ;
        convert coeff_mul_one_add_wX P w k using 1;
      have := hP.2 ( j - 1 ) ( k - 1 ) ; rcases j with ( _ | j ) <;> rcases k with ( _ | k ) <;> simp_all +decide [ Nat.succ_eq_add_one ] ;
      have := hP.2 ( j + 1 ) ( k + 1 ) ; have := hP.2 j ( k + 1 ) ; have := hP.2 j k ; have := hP.2 ( j + 1 ) k ; have := hP.2 ( j + 1 ) ( k + 2 ) ; have := hP.2 j ( k + 2 ) ; have := hP.2 ( j + 1 ) ( k + 3 ) ; have := hP.2 j ( k + 3 ) ; norm_num at * ;
      by_cases hjk' : j < k <;> simp_all +decide [ Nat.succ_eq_add_one ];
      · nlinarith [ mul_nonneg hw hw, hP.1 j, hP.1 ( j + 1 ), hP.1 ( j + 2 ), hP.1 k, hP.1 ( k + 1 ), hP.1 ( k + 2 ), ‹j ≤ k + 1 → P.coeff j * P.coeff ( k + 1 + 2 ) ≤ P.coeff ( j + 1 ) * P.coeff ( k + 1 + 1 ) › ( by linarith ), ‹j ≤ k + 2 → P.coeff j * P.coeff ( k + 2 + 2 ) ≤ P.coeff ( j + 1 ) * P.coeff ( k + 2 + 1 ) › ( by linarith ) ];
      · cases le_antisymm hjk hjk' ; simp_all +decide [ Nat.succ_eq_add_one ];
        nlinarith [ mul_nonneg hw ( sq_nonneg w ), mul_nonneg hw ( hP.1 j ), mul_nonneg hw ( hP.1 ( j + 1 ) ), mul_nonneg hw ( hP.1 ( j + 2 ) ), mul_nonneg hw ( hP.1 ( j + 3 ) ), mul_nonneg hw ( hP.1 ( j + 4 ) ) ]

/-- The unfolding of `fermionPartitionPoly` at `m + 1`. -/
theorem fermionPartitionPoly_succ (w : ℕ → ℝ) (m : ℕ) :
    fermionPartitionPoly w (m + 1) =
    fermionPartitionPoly w m * (C 1 + C (w m) * X) := by
  unfold fermionPartitionPoly
  rw [Finset.prod_range_succ]

/-- **Product-family PF₂ theorem**: The coefficient sequence of
    `∏_{i < m} (1 + w(i) · X)` is ratio-decreasing when all `w(i) ≥ 0`. -/
theorem prodLinear_coeff_ratioDecreasing (w : ℕ → ℝ) (m : ℕ)
    (hw : ∀ i < m, 0 ≤ w i) :
    IsRatioDecreasing (fun k => (fermionPartitionPoly w m).coeff k) := by
  induction m with
  | zero =>
    unfold fermionPartitionPoly
    simp only [Finset.prod_range_zero]
    exact ratioDecreasing_one
  | succ m ih =>
    rw [fermionPartitionPoly_succ]
    apply ratioDecreasing_mul_linear
    · exact hw m (Nat.lt_succ_iff.mpr le_rfl)
    · exact ih (fun i hi => hw i (Nat.lt_of_lt_of_le hi (Nat.le_succ m)))

/-- **Product-family log-concavity theorem**: The coefficient sequence of
    `∏_{i < m} (1 + w(i) · X)` is log-concave when all `w(i) ≥ 0`. -/
theorem prodLinear_coeff_logConcave (w : ℕ → ℝ) (m : ℕ)
    (hw : ∀ i < m, 0 ≤ w i) :
    IsLogConcaveSeq (fun k => (fermionPartitionPoly w m).coeff k) :=
  (prodLinear_coeff_ratioDecreasing w m hw).isLogConcaveSeq

/-! ## Theorem 3: Partition matroid rank sequences are log-concave -/

/-- **Partition matroid log-concavity**: For a partition matroid with blocks of
    sizes `b 0, ..., b (m-1)` and capacity 1 per block, the rank sequence
    (number of independent sets of each size) is log-concave.

    This is a certified special case of Mason's conjecture. -/
theorem partitionMatroid_rankSeq_logConcave (b : ℕ → ℝ) (m : ℕ)
    (hb : ∀ i < m, 0 ≤ b i) (k : ℕ) :
    ((fermionPartitionPoly b m).coeff (k + 1)) ^ 2 ≥
    ((fermionPartitionPoly b m).coeff k) *
    ((fermionPartitionPoly b m).coeff (k + 2)) :=
  prodLinear_coeff_logConcave b m hb k

/-! ## Theorem 4: Cross-domain bridge — Fermionic partition functions -/

/-- **Fermionic partition function log-concavity**: In a noninteracting fermionic
    system with `m` modes and single-particle activities `w 0, ..., w (m-1) ≥ 0`,
    the particle-number distribution is log-concave.

    The coefficient of `X^k` in `∏(1 + wᵢX)` gives the weighted degeneracy of
    k-particle states. Log-concavity implies unimodality and concentration.

    This reveals PF₂ log-concavity as a discrete shadow of thermodynamic stability
    in noninteracting exclusion systems. -/
theorem fermionPartition_logConcave (w : ℕ → ℝ) (m : ℕ)
    (hw : ∀ i < m, 0 ≤ w i) :
    IsLogConcaveSeq (fun k => (fermionPartitionPoly w m).coeff k) :=
  prodLinear_coeff_logConcave w m hw

/-- **PF₂-certified sequences are log-concave**. -/
theorem PF2CertifiedSeq.logConcave (S : PF2CertifiedSeq) :
    IsLogConcaveSeq S.seq := by
  intro k
  rw [S.seq_eq, S.seq_eq, S.seq_eq]
  exact prodLinear_coeff_logConcave S.weights S.numFactors S.weights_nonneg k

/-- **PF₂-certified sequences are nonneg**. -/
theorem PF2CertifiedSeq.nonneg (S : PF2CertifiedSeq) :
    ∀ k, 0 ≤ S.seq k := by
  intro k
  rw [S.seq_eq]
  exact (prodLinear_coeff_ratioDecreasing S.weights S.numFactors S.weights_nonneg).1 k

/-- **PF₂-certified sequences have ratio-decreasing coefficients**. -/
theorem PF2CertifiedSeq.ratioDecreasing (S : PF2CertifiedSeq) :
    IsRatioDecreasing S.seq := by
  constructor
  · exact S.nonneg
  · intro j k hjk
    rw [S.seq_eq, S.seq_eq, S.seq_eq, S.seq_eq]
    exact (prodLinear_coeff_ratioDecreasing S.weights S.numFactors S.weights_nonneg).2 j k hjk

/-! ## Constructing PF₂-certified sequences -/

/-- Construct a PF₂-certified sequence from weights. -/
noncomputable def PF2CertifiedSeq.ofWeights (w : ℕ → ℝ) (m : ℕ)
    (hw : ∀ i < m, 0 ≤ w i) : PF2CertifiedSeq where
  seq := fun k => (fermionPartitionPoly w m).coeff k
  numFactors := m
  weights := w
  weights_nonneg := hw
  seq_eq := fun _ => rfl