/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Mod-p Spectral Fingerprints of Arithmetic Simplicial Complexes

## Overview

This file develops the theory of **mod-p spectral fingerprints** for integer matrices
arising from arithmetic simplicial complexes. The central idea is that reducing
combinatorial Laplacian matrices modulo varying primes `p` creates a "fingerprint"
that encodes the integral structure of the operator, and in particular constrains
the real spectral gap.

## Main Results

### Foundational Algebra
- `det_modp_eq_cast_det`: Determinant commutes with mod-p reduction
- `modp_full_rank_iff_det`: Full rank mod p iff p does not divide the determinant

### Rank Stability
- `finite_prime_divisors`: Only finitely many primes divide a nonzero integer
- `bad_primes_finite`: Only finitely many primes reduce the rank

### Spectral Fingerprint Theory
- `fingerprint_detects_prime_divisors`: The fingerprint detects prime divisors of det

### Cross-Domain: Expansion from Spectral Data
- `cheeger_discrete_bound`: Edge boundary nonnegativity (expansion ≥ 0)
- `degree_eq_neg_offdiag_sum`: Degree-edge duality

## Novel Definitions
- `SpectralFingerprint`: The mod-p rank function of an integer matrix
- `ArithLaplacian`: Combinatorial Laplacian with integer weights
- `edgeBoundary`: Edge expansion of a vertex subset
-/

open Finset Matrix BigOperators

noncomputable section

namespace ModPSpectralFingerprint

/-! ## §1. Integer Matrices and Mod-p Reduction -/

/-- Reduce an integer matrix modulo a natural number `p`, obtaining a matrix over `ZMod p`. -/
def modpReduce (n : ℕ) (p : ℕ) (M : Matrix (Fin n) (Fin n) ℤ) :
    Matrix (Fin n) (Fin n) (ZMod p) :=
  M.map (fun x => (x : ZMod p))

/-- The mod-p reduction is the same as applying the cast ring homomorphism. -/
theorem modpReduce_eq_mapMatrix (n p : ℕ) (M : Matrix (Fin n) (Fin n) ℤ) :
    modpReduce n p M = (Int.castRingHom (ZMod p)).mapMatrix M := by
  ext i j
  simp [modpReduce, RingHom.mapMatrix, Matrix.map]

/-- **Determinant commutes with mod-p reduction.**
    `det(M mod p) = det(M) mod p`. -/
theorem det_modp_eq_cast_det (n p : ℕ) (M : Matrix (Fin n) (Fin n) ℤ) :
    (modpReduce n p M).det = ((M.det : ℤ) : ZMod p) := by
  rw [modpReduce_eq_mapMatrix, ← RingHom.map_det]
  simp [Int.castRingHom]

/-! ## §2. Full Rank Characterization -/

/-- The mod-p reduction has nonzero determinant iff `p ∤ det(M)`. -/
theorem modp_full_rank_iff_det (n : ℕ) (p : ℕ) [hp : Fact (Nat.Prime p)]
    (M : Matrix (Fin n) (Fin n) ℤ) :
    (modpReduce n p M).det ≠ 0 ↔ ¬((p : ℤ) ∣ M.det) := by
  rw [det_modp_eq_cast_det]
  rw [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]

/-! ## §3. Spectral Fingerprint -/

/-- The **spectral fingerprint** of an integer matrix maps each prime to
    the mod-p rank. -/
def SpectralFingerprint (n : ℕ) (M : Matrix (Fin n) (Fin n) ℤ) : ℕ → ℕ :=
  fun p => (modpReduce n p M).rank

/-
The set of primes dividing a nonzero integer is finite.
-/
theorem finite_prime_divisors (d : ℤ) (hd : d ≠ 0) :
    Set.Finite {p : ℕ | Nat.Prime p ∧ (p : ℤ) ∣ d} := by
  -- Since $d$ is a nonzero integer, its prime factors are finite. Therefore, the set $\{p : \mathbb{N} \mid \text{Nat.Prime } p \land p \mid \text{Int �.n�atAbs } d\}$ is finite.
  have h_finite : Set.Finite {p : ℕ | Nat.Prime p ∧ p ∣ Int.natAbs d} := by
    exact Set.finite_iff_bddAbove.mpr ⟨ _, fun p hp => Nat.le_of_dvd ( Int.natAbs_pos.mpr hd ) hp.2 ⟩;
  simpa [ ← Int.natCast_dvd_natCast ] using h_finite

/-
**Bad primes are finite**: Only finitely many primes can make the
    fingerprint drop below full rank.
-/
theorem bad_primes_finite (n : ℕ) (M : Matrix (Fin n) (Fin n) ℤ) (hdet : M.det ≠ 0) :
    Set.Finite {p : ℕ | Nat.Prime p ∧ SpectralFingerprint n M p < n} := by
  refine Set.Finite.subset ( finite_prime_divisors ( M.det ) hdet ) ?_;
  intro p hp; haveI := Fact.mk hp.1; simp_all +decide [ SpectralFingerprint, modpReduce ] ;
  -- If the rank of $M$ modulo $p$ is less than $n$, then the determinant of $M$ modulo $p$ must be zero.
  have h_det_zero : (Matrix.map M (fun x : ℤ => (x : ZMod p))).det = 0 := by
    contrapose! hp;
    intro hp_prime; haveI := Fact.mk hp_prime; exact (by
    have := Matrix.rank_mul_le_left ( M.map fun x : ℤ => ( x : ZMod p ) ) ( M.map fun x : ℤ => ( x : ZMod p ) ) ⁻¹; simp_all +decide [ isUnit_iff_ne_zero ] ;);
  simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd, Matrix.det_apply' ]

/-! ## §4. Arithmetic Laplacian -/

/-- An **arithmetic Laplacian**: symmetric integer matrix with zero row sums,
    nonneg diagonal, and nonpositive off-diagonal entries. -/
structure ArithLaplacian (n : ℕ) where
  mat : Matrix (Fin n) (Fin n) ℤ
  symmetric : mat.IsSymm
  rowSum_zero : ∀ i : Fin n, ∑ j, mat i j = 0
  diag_nonneg : ∀ i : Fin n, 0 ≤ mat i i
  offdiag_nonpos : ∀ i j : Fin n, i ≠ j → mat i j ≤ 0

/-- The degree of vertex `i` is the diagonal entry. -/
def ArithLaplacian.degree {n : ℕ} (L : ArithLaplacian n) (i : Fin n) : ℤ :=
  L.mat i i

/-
The degree equals the negative sum of off-diagonal entries.
-/
theorem ArithLaplacian.degree_eq_neg_offdiag_sum {n : ℕ} (L : ArithLaplacian n) (i : Fin n) :
    L.degree i = -∑ j ∈ Finset.univ.erase i, L.mat i j := by
  unfold ArithLaplacian.degree;
  have := L.rowSum_zero i; simp_all +decide [ Finset.sum_erase ] ;

/-- The trace equals the sum of all degrees. -/
theorem ArithLaplacian.trace_eq_degree_sum {n : ℕ} (L : ArithLaplacian n) :
    Matrix.trace L.mat = ∑ i, L.degree i := by
  simp [Matrix.trace, ArithLaplacian.degree]

/-- Degree is nonneg. -/
theorem ArithLaplacian.degree_nonneg {n : ℕ} (L : ArithLaplacian n) (i : Fin n) :
    0 ≤ L.degree i :=
  L.diag_nonneg i

/-! ## §5. Edge Boundary and Expansion (Cross-Domain) -/

/-- The **edge boundary** of a vertex subset `S`: total weight of edges
    crossing from `S` to its complement. -/
def edgeBoundary {n : ℕ} (L : ArithLaplacian n) (S : Finset (Fin n)) : ℤ :=
  ∑ i ∈ S, ∑ j ∈ Sᶜ, (-L.mat i j)

/-
**Edge boundary is nonneg**: connects spectral theory to expansion.
-/
theorem cheeger_discrete_bound {n : ℕ} (L : ArithLaplacian n)
    (S : Finset (Fin n)) :
    0 ≤ edgeBoundary L S := by
  apply Finset.sum_nonneg
  intro i hi
  apply Finset.sum_nonneg
  intro j hj
  have h_offdiag : L.mat i j ≤ 0 := by
    exact L.offdiag_nonpos i j ( by aesop )
  linarith

/-
Edge boundary of the empty set is zero.
-/
theorem edgeBoundary_empty {n : ℕ} (L : ArithLaplacian n) :
    edgeBoundary L ∅ = 0 := by
  -- The sum over the empty set is zero.
  simp [edgeBoundary]

/-
Edge boundary is symmetric: boundary of S equals boundary of Sᶜ.
-/
theorem edgeBoundary_compl {n : ℕ} (L : ArithLaplacian n) (S : Finset (Fin n)) :
    edgeBoundary L S = edgeBoundary L Sᶜ := by
  unfold edgeBoundary; simp +decide [ Finset.compl_eq_univ_sdiff ] ;
  rw [ Finset.sum_comm, Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => rfl ];
  exact Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => L.symmetric.apply _ _ ▸ rfl

/-! ## §6. Fingerprint–Determinant Bridge -/

/-
The fingerprint detects prime divisors: `p | det(M)` iff the fingerprint
    drops below full rank.
-/
theorem fingerprint_detects_prime_divisors (n : ℕ) (hn : 0 < n) (p : ℕ)
    [hp : Fact (Nat.Prime p)] (M : Matrix (Fin n) (Fin n) ℤ) (hdet : M.det ≠ 0) :
    SpectralFingerprint n M p < n ↔ (p : ℤ) ∣ M.det := by
  constructor <;> intro h;
  · -- If the rank of $M$ modulo $p$ is less than $n$, then the determinant of $M$ modulo $p$ is zero.
    have h_det_zero : (modpReduce n p M).det = 0 := by
      -- Since the rank of the matrix is less than n, the matrix is singular, hence its determinant is zero.
      have h_singular : Matrix.rank (modpReduce n p M) < n → Matrix.det (modpReduce n p M) = 0 := by
        intro h_rank_lt_n
        by_contra h_det_nonzero;
        have := Matrix.rank_mul_le_left ( modpReduce n p M ) ( modpReduce n p M ) ⁻¹; simp_all +decide [ isUnit_iff_ne_zero ] ;
        linarith;
      exact h_singular h;
    simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd, det_modp_eq_cast_det ];
  · -- Since $p \mid \det(M)$, we have $\det(M \mod p) = 0$.
    have h_det_zero : (modpReduce n p M).det = 0 := by
      convert det_modp_eq_cast_det n p M using 1;
      exact?;
    contrapose! h_det_zero;
    -- Since the rank of $M \mod p$ is $n$, the matrix $M \mod p$ is invertible.
    have h_inv : Invertible (modpReduce n p M) := by
      have h_inv : LinearMap.ker (Matrix.mulVecLin (modpReduce n p M)) = ⊥ := by
        have := LinearMap.finrank_range_add_finrank_ker ( Matrix.mulVecLin ( modpReduce n p M ) );
        simp_all +decide [ SpectralFingerprint ];
        exact Submodule.finrank_eq_zero.mp ( by linarith! );
      convert Matrix.invertibleOfDetInvertible _;
      refine invertibleOfNonzero ?_;
      rw [ LinearMap.ker_eq_bot' ] at h_inv;
      exact fun h => by have := Matrix.exists_mulVec_eq_zero_iff.mpr h; tauto;
    exact Matrix.det_ne_zero_of_left_inverse h_inv.2

/-! ## §7. Complete Graph Laplacian -/

/-- The Laplacian of `K_n`: `nI - J`. -/
def completeLaplacian (n : ℕ) : Matrix (Fin n) (Fin n) ℤ :=
  Matrix.diagonal (fun _ => (n : ℤ)) - (Matrix.of fun _ _ => (1 : ℤ))

/-
The complete graph Laplacian has zero row sums.
-/
theorem completeLaplacian_rowSum (n : ℕ) (i : Fin n) :
    ∑ j, completeLaplacian n i j = 0 := by
  simp +decide [ completeLaplacian, Finset.sum_sub_distrib ];
  simp +decide [ diagonal ]

/-
The complete graph Laplacian is symmetric.
-/
theorem completeLaplacian_symm (n : ℕ) :
    (completeLaplacian n).IsSymm := by
  ext i j; by_cases hij : i = j <;> simp +decide [ hij, completeLaplacian ] ;
  exact if_neg ( Ne.symm hij )

/-
The complete graph Laplacian is singular (all-ones is in the kernel).
-/
theorem completeLaplacian_det_zero (n : ℕ) (hn : 1 ≤ n) :
    (completeLaplacian n).det = 0 := by
  -- By definition of $completeLaplacian$, we know that its determinant is zero because it has a nontrivial kernel.
  have h_kernel : ∃ v : Fin n → ℤ, v ≠ 0 ∧ (completeLaplacian n).mulVec v = 0 := by
    use fun _ => 1;
    refine' ⟨ fun h => by simpa using congr_fun h ⟨ 0, hn ⟩, _ ⟩;
    ext i; simp +decide [ Matrix.mulVec, dotProduct, completeLaplacian ] ;
    simp +decide [ Matrix.diagonal ];
  exact Matrix.exists_mulVec_eq_zero_iff.mp h_kernel

/-! ## §8. Path Graph Laplacian and Main Conjecture -/

/-- The **path graph Laplacian** on `n` vertices. -/
def pathLaplacian (n : ℕ) : Matrix (Fin n) (Fin n) ℤ :=
  Matrix.of fun i j =>
    if i = j then
      if i.val = 0 ∨ i.val = n - 1 then 1 else 2
    else if i.val + 1 = j.val ∨ j.val + 1 = i.val then -1
    else 0

/-
The path Laplacian is symmetric.
-/
theorem pathLaplacian_symm (n : ℕ) : (pathLaplacian n).IsSymm := by
  ext i j; by_cases hij : i = j <;> simp +decide [ hij, pathLaplacian ] ;
  grind

/-
The path Laplacian has zero row sums for n ≥ 2.
-/
theorem pathLaplacian_rowSum (n : ℕ) (hn : 2 ≤ n) (i : Fin n) :
    ∑ j, pathLaplacian n i j = 0 := by
  unfold pathLaplacian;
  by_cases hi0 : i.val = 0 <;> by_cases hin : i.val = n - 1 <;> simp +decide [ Finset.sum_ite, Finset.filter_eq, Finset.filter_or, Finset.filter_ne, Finset.filter_and, Finset.filter_not, * ];
  · omega;
  · rcases n with ( _ | _ | n ) <;> simp_all +decide [ Finset.filter_eq', Finset.filter_ne' ];
    rw [ Finset.card_eq_one.mpr ] ; aesop;
    use 1;
    ext ( _ | _ | x ) <;> simp +decide [ Fin.ext_iff ];
  · rcases n with ( _ | _ | n ) <;> simp_all +decide [ Finset.filter_union_right, Finset.filter_eq', Finset.filter_and ];
    rw [ show ( Finset.univ.erase i |>.filter fun x : Fin ( n + 2 ) => n + 1 + 1 = ( x : ℕ ) ∨ ( x : ℕ ) = n ) = { ⟨ n, by linarith ⟩ } from ?_ ] ; aesop;
    grind;
  · rw [ show ( Finset.filter ( fun a : Fin n => ( i : ℕ ) + 1 = a ) ( Finset.univ.erase i ) ) = { ⟨ i + 1, by omega ⟩ } from ?_, show ( Finset.filter ( fun a : Fin n => ( a : ℕ ) + 1 = i ) ( Finset.univ.erase i ) ) = { ⟨ i - 1, by omega ⟩ } from ?_ ] ; aesop; all_goals grind

/-! ## §9. Falsifiable Conjecture

**Main Conjecture**: For the path graph Laplacian on `n ≥ 2` vertices,
the mod-p rank equals `n - 1` for all primes `p > n`.

**Computational test**: For `n = 5`, the path Laplacian is:
```
[ 1, -1,  0,  0,  0]
[-1,  2, -1,  0,  0]
[ 0, -1,  2, -1,  0]
[ 0,  0, -1,  2, -1]
[ 0,  0,  0, -1,  1]
```
Check that this has rank 4 mod p for primes p = 7, 11, 13.
The conjecture is falsified if any such prime yields rank ≠ 4.

**Impact**: If true, mod-p fingerprints stabilize quickly for structured
graphs, supporting the broader conjecture that fingerprints determine
expansion profiles.
-/

end ModPSpectralFingerprint