/-
Copyright (c) 2025. All rights reserved.

# Spectral Arithmetic: Tensor-Product Spectral Multiplicativity

## Overview

This file proves the **spectral multiplicativity theorem for Kronecker products**:
if `A` has eigenvalue `α` and `B` has eigenvalue `β`, then the Kronecker product
`A ⊗ₖ B` has eigenvalue `α * β`. This is then iterated to finite families of matrices,
and finally connected to number-theoretic prime-power factorization.

The key insight is that arithmetic factorization of matrix indices induces multiplicative
factorization of spectra — a formal bridge between prime factorization in number theory
and spectral decomposition in linear algebra.

## Main results

* `kron_mulVec_vecTensor` — The Kronecker product acting on tensor vectors factors.
* `isEigenvalue_kron` — Binary Kronecker spectral multiplicativity.
* `isEigenvalue_kron_list` — Iterated Kronecker eigenvalue theorem for lists.
* `isEigenvalue_of_prime_factorization` — Prime-power factorization spectral theorem.
-/
import Mathlib

open Matrix BigOperators Finset

/-! ## Eigenvalue and eigenvector predicates for matrices -/

/-- A matrix `A` has eigenvalue `μ` if there exists a nonzero vector `v` with `A *ᵥ v = μ • v`. -/
def Matrix.IsEigenvalue {n : Type*} [Fintype n] [DecidableEq n] {K : Type*} [Field K]
    (A : Matrix n n K) (μ : K) : Prop :=
  ∃ v : n → K, v ≠ 0 ∧ A *ᵥ v = μ • v

/-- A vector `v` is an eigenvector of `A` for eigenvalue `μ`. -/
def Matrix.IsEigenvector {n : Type*} [Fintype n] [DecidableEq n] {K : Type*} [Field K]
    (A : Matrix n n K) (μ : K) (v : n → K) : Prop :=
  v ≠ 0 ∧ A *ᵥ v = μ • v

/-! ## Kronecker product -/

/-- The Kronecker product of two matrices. -/
noncomputable abbrev Matrix.kron {m n m' n' : Type*} {K : Type*} [Mul K]
    (A : Matrix m n K) (B : Matrix m' n' K) : Matrix (m × m') (n × n') K :=
  Matrix.kroneckerMap (· * ·) A B

/-! ## Tensor product of vectors -/

/-- The tensor product of two vectors, as a function on the product type. -/
def vecTensor {m n : Type*} {K : Type*} [Mul K] (v : m → K) (w : n → K) :
    m × n → K :=
  fun p => v p.1 * w p.2

/-- The tensor product of nonzero vectors is nonzero. -/
theorem vecTensor_ne_zero {m n : Type*} {K : Type*} [MulZeroClass K] [NoZeroDivisors K]
    {v : m → K} {w : n → K} (hv : v ≠ 0) (hw : w ≠ 0) :
    vecTensor v w ≠ 0 := by
  intro h
  simp only [funext_iff, vecTensor] at h
  rw [ne_eq, funext_iff] at hv hw
  push_neg at hv hw
  obtain ⟨i, hi⟩ := hv
  obtain ⟨j, hj⟩ := hw
  have := h ⟨i, j⟩
  rcases mul_eq_zero.mp this with h1 | h1 <;> contradiction

/-! ## Core computational lemma -/

/-
The Kronecker product of `A` and `B` acting on the tensor product `v ⊗ w` equals
    the tensor product of `A *ᵥ v` and `B *ᵥ w`.
-/
theorem kron_mulVec_vecTensor
    {m n : Type*} [Fintype m] [Fintype n] [DecidableEq m] [DecidableEq n]
    {K : Type*} [CommSemiring K]
    (A : Matrix m m K) (B : Matrix n n K)
    (v : m → K) (w : n → K) :
    (A.kron B) *ᵥ (vecTensor v w) = vecTensor (A *ᵥ v) (B *ᵥ w) := by
  -- Expanding both sides pointwise using `ext ⟨i, j⟩`.
  ext ⟨i, j⟩
  simp [Matrix.mulVec, vecTensor];
  simp +decide only [dotProduct, vecTensor, Fintype.sum_prod_type, mul_comm (B _ _)];
  simp +decide only [mul_left_comm, mul_comm];
  simp +decide only [Finset.sum_mul _ _ _, Finset.mul_sum _ _ _, mul_left_comm, mul_assoc]

/-! ## Binary Kronecker spectral multiplicativity -/

/-
**Kronecker Spectral Multiplicativity Theorem (Binary).**
    If `α` is an eigenvalue of `A` and `β` is an eigenvalue of `B`, then `α * β` is
    an eigenvalue of their Kronecker product `A.kron B`.
-/
theorem isEigenvalue_kron
    {m n : Type*} [Fintype m] [Fintype n] [DecidableEq m] [DecidableEq n]
    {K : Type*} [Field K]
    (A : Matrix m m K) (B : Matrix n n K)
    {α β : K}
    (hA : A.IsEigenvalue α)
    (hB : B.IsEigenvalue β) :
    (A.kron B).IsEigenvalue (α * β) := by
  -- By definition of eigenvalues, we know there exist nonzero vectors `v` and `w` such that `A *ᵥ v = α • v` and `B *ᵥ w = β • w`.
  obtain ⟨v, hv⟩ := hA
  obtain ⟨w, hw⟩ := hB;
  -- Consider the vector `vecTensor v w`. This is a nonzero vector in `n × m`.
  have h_nonzero : vecTensor v w ≠ 0 := by
    exact vecTensor_ne_zero hv.1 hw.1;
  refine' ⟨ vecTensor v w, h_nonzero, _ ⟩;
  rw [ kron_mulVec_vecTensor, hv.2, hw.2 ];
  exact funext fun x => by simp +decide [ vecTensor, mul_assoc, mul_left_comm ] ;

/-! ## Iterated Kronecker product for lists -/

/-- Bundled matrix: a type together with a square matrix over it. -/
structure BundledMatrix (K : Type*) where
  ι : Type*
  [finι : Fintype ι]
  [decι : DecidableEq ι]
  mat : Matrix ι ι K

attribute [instance] BundledMatrix.finι BundledMatrix.decι

/-- The Kronecker product of a list of bundled matrices. -/
noncomputable def kronList {K : Type*} [CommSemiring K] :
    List (BundledMatrix K) → BundledMatrix K
  | [] => ⟨Unit, (1 : Matrix Unit Unit K)⟩
  | [M] => M
  | M :: Ms =>
    let rest := kronList Ms
    ⟨M.ι × rest.ι, M.mat.kron rest.mat⟩

/-
An eigenvalue of the identity matrix is 1.
-/
theorem isEigenvalue_one {K : Type*} [Field K] :
    (1 : Matrix Unit Unit K).IsEigenvalue 1 := by
  refine' ⟨ 1, _, _ ⟩ <;> simp +decide

/-
**Iterated Kronecker Spectral Multiplicativity.**
    Given a list of matrices with corresponding eigenvalues, the iterated Kronecker product
    has as eigenvalue the product of all eigenvalues.
-/
theorem isEigenvalue_kron_list {K : Type*} [Field K]
    (Ms : List (BundledMatrix K))
    (μs : List K)
    (hlen : Ms.length = μs.length)
    (hμs : ∀ i (hi : i < Ms.length),
      (Ms[i]).mat.IsEigenvalue (μs[i]'(hlen ▸ hi))) :
    (kronList Ms).mat.IsEigenvalue (μs.prod) := by
  induction' Ms with M Ms ih generalizing μs;
  · cases μs <;> simp_all +decide;
    · exact isEigenvalue_one;
    · cases hlen;
  · rcases μs with ( _ | ⟨ μ, μs ⟩ ) <;> simp_all +decide;
    · cases hlen;
    · rcases Ms with ( _ | ⟨ M', Ms' ⟩ ) <;> simp_all +decide;
      · cases μs <;> simp_all +decide [ List.length ];
        · exact hμs 0 rfl;
        · cases hlen;
      · convert isEigenvalue_kron M.mat ( kronList ( M' :: Ms' ) ).mat _ _ using 1;
        · simpa using hμs 0 bot_le;
        · grind

/-! ## Arithmetic spectral theorem via prime-power factorization -/

/-- **Arithmetic Spectral Multiplicativity.**
    Given:
    - A family `T` of matrices indexed by prime powers,
    - A natural number `n ≠ 0` with prime factorization `n = ∏ p^a`,
    - Eigenvalues `μ p` for each prime-power operator `T (p ^ a_p)`,

    then the Kronecker product of the family over the primes dividing `n`
    has eigenvalue `∏ p ∈ support, μ p`. -/
noncomputable def kronPrimePower {K : Type*} [CommSemiring K]
    (T : ∀ p : ℕ, p.Prime → BundledMatrix K)
    (n : ℕ) (_hn : n ≠ 0) : BundledMatrix K :=
  kronList (n.primeFactors.sort (· ≤ ·) |>.map (fun p =>
    if hp : p.Prime then T p hp
    else ⟨Unit, (1 : Matrix Unit Unit K)⟩))

/-
**Prime-Power Spectral Multiplicativity Theorem.**
    If for each prime `p` dividing `n`, the operator `T p` has eigenvalue `μ p`,
    then the Kronecker product over the prime factorization has eigenvalue
    `∏ p in n.primeFactors, μ p`.
-/
theorem isEigenvalue_of_prime_factorization {K : Type*} [Field K]
    (T : ∀ p : ℕ, p.Prime → BundledMatrix K)
    (μ : ∀ p : ℕ, p.Prime → K)
    (n : ℕ) (hn : n ≠ 0)
    (hμ : ∀ p (hp : p.Prime), p ∈ n.primeFactors →
      (T p hp).mat.IsEigenvalue (μ p hp)) :
    (kronPrimePower T n hn).mat.IsEigenvalue
      (∏ p ∈ n.primeFactors, if hp : p.Prime then μ p hp else 1) := by
  convert isEigenvalue_kron_list ( List.map ( fun p => if hp : p.Prime then ( T p hp ) else ⟨ Unit, 1 ⟩ ) ( n.primeFactors.sort ( · ≤ · ) ) ) ( List.map ( fun p => if hp : p.Prime then μ p hp else 1 ) ( n.primeFactors.sort ( · ≤ · ) ) ) _ _ using 1;
  all_goals norm_num;
  · rw [ ← Finset.prod_map_toList ];
    have h_perm : List.Perm (n.primeFactors.toList) (n.primeFactors.sort (· ≤ ·)) := by
      rw [ ← Multiset.coe_eq_coe ] ; aesop;
    exact h_perm.map _ |> List.Perm.prod_eq;
  · intro i hi;
    split_ifs <;> simp_all +decide;
    · convert hμ _ _ _;
      · grind;
      · exact Nat.dvd_of_mem_primeFactors <| Finset.mem_sort ( α := ℕ ) ( · ≤ · ) |>.1 <| by simp;
    · grind +suggestions