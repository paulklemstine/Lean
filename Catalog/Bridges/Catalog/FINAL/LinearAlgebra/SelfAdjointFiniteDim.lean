/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-! # Spectral Theory of Self-Adjoint Operators in Finite Dimensions

This file formalizes the spectral theorem and related results for Hermitian (self-adjoint)
matrices in finite dimensions, building on Mathlib's `Matrix.IsHermitian` infrastructure.

## Main results

* `exists_orthonormalBasis_eigenvectors_of_isHermitian` — A Hermitian matrix admits a
  unitary diagonalization `A = U * D * Uᴴ` where `D` is a real diagonal matrix.
* `eigenvalue_real_of_isHermitian` — Every element of the spectrum of a Hermitian matrix is real.
* `orthogonal_eigenvectors_of_distinct_eigenvalues` — Eigenvectors of distinct eigenvalues
  of a Hermitian matrix are orthogonal.
* `exists_orthogonal_diagonalization_of_isSymmetric` — A real symmetric matrix admits an
  orthogonal diagonalization `A = Q * D * Qᵀ`.
* `expectation_nonneg_of_posSemidef` — The quadratic form `⟨x, Ax⟩` is nonneg for PSD matrices.

## References

* [Axler, *Linear Algebra Done Right*]
* [Horn, Johnson, *Matrix Analysis*]

## Tags

spectral theorem, Hermitian matrix, self-adjoint, eigenvalue, diagonalization, positive semidefinite
-/

open Matrix Finset Complex

noncomputable section

namespace SpectralTheory

/-! ## Hermitian Diagonalization -/

/-
**Spectral Theorem (Hermitian case)**: Every Hermitian matrix over `ℂ` admits a unitary
diagonalization. There exists a unitary matrix `U` and real eigenvalues `d` such that
`A = U * diagonal(d) * Uᴴ`.
-/
theorem exists_orthonormalBasis_eigenvectors_of_isHermitian
    {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℂ)
    (hA : A.IsHermitian) :
    ∃ (U : Matrix n n ℂ) (d : n → ℝ),
      U ∈ Matrix.unitaryGroup n ℂ ∧
      A = U * (Matrix.diagonal fun i => (d i : ℂ)) * star U := by
  exact ⟨ _, _, hA.eigenvectorUnitary.2, hA.spectral_theorem ⟩

/-
**Spectral Theorem (Real Symmetric case)**: Every real symmetric matrix admits an
orthogonal diagonalization. There exists an orthogonal matrix `Q` and real eigenvalues `d`
such that `A = Q * diagonal(d) * Qᵀ`.
-/
theorem exists_orthogonal_diagonalization_of_isSymmetric
    {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℝ)
    (hA : A.IsHermitian) :
    ∃ (Q : Matrix n n ℝ) (d : n → ℝ),
      Q * Qᵀ = 1 ∧ Q ∈ Matrix.unitaryGroup n ℝ ∧
      A = Q * Matrix.diagonal d * Qᵀ := by
  -- Apply the spectral theorem for Hermitian matrices to obtain the unitary matrix Q and the diagonal matrix D.
  obtain ⟨Q, d, hQ⟩ : ∃ Q : Matrix n n ℝ, ∃ d : n → ℝ, Q ∈ Matrix.unitaryGroup n ℝ ∧ A = Q * (Matrix.diagonal d) * Qᵀ := by
    -- Apply the spectral theorem for Hermitian matrices to obtain the unitary matrix Q and the diagonal matrix D. The eigenvalues are real.
    have h_spectral : ∃ (Q : Matrix n n ℝ) (d : n → ℝ), Q ∈ Matrix.unitaryGroup n ℝ ∧ A = Q * (Matrix.diagonal d) * Q.transpose := by
      have := hA.spectral_theorem
      refine' ⟨ hA.eigenvectorUnitary, fun i => hA.eigenvalues i, _, this ⟩;
      exact?;
    exact h_spectral;
  cases' hQ with hQ₁ hQ₂;
  exact ⟨ Q, d, by simpa [ Matrix.IsHermitian ] using hQ₁.2, hQ₁, hQ₂ ⟩

/-! ## Reality of Eigenvalues -/

/-
Every element of the spectrum of a Hermitian matrix is real.
-/
theorem eigenvalue_real_of_isHermitian
    {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℂ)
    (hA : A.IsHermitian)
    {μ : ℂ} (hμ : μ ∈ spectrum ℂ A) :
    ∃ r : ℝ, μ = (r : ℂ) := by
  rw [ ( hA.spectrum_eq_image_range ) ] at hμ;
  aesop

/-
The eigenvalues of a Hermitian matrix, as provided by Mathlib, are real-valued.
-/
theorem eigenvalues_are_real
    {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℂ)
    (hA : A.IsHermitian) (i : n) :
    (hA.eigenvalues i : ℂ) ∈ spectrum ℂ A := by
  have := Matrix.IsHermitian.spectrum_eq_image_range hA;
  exact this.symm.subset ⟨ _, ⟨ i, rfl ⟩, rfl ⟩

/-! ## Orthogonality of Eigenvectors -/

/-
Eigenvectors of a Hermitian matrix corresponding to distinct eigenvalues are orthogonal
in `EuclideanSpace`.
-/
theorem orthogonal_eigenvectors_of_distinct_eigenvalues
    {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℂ)
    (hA : A.IsHermitian)
    {x y : EuclideanSpace ℂ n} {μ ν : ℝ}
    (hx : A.mulVec x = (μ : ℂ) • x)
    (hy : A.mulVec y = (ν : ℂ) • y)
    (hμν : μ ≠ ν)
    (hx0 : x ≠ 0) (hy0 : y ≠ 0) :
    @inner ℂ _ _ x y = 0 := by
  -- By definition of the inner product, we know that
  have h_inner : dotProduct (star x.ofLp) (A.mulVec y.ofLp) = dotProduct (star (A.mulVec x.ofLp)) y.ofLp := by
    simp +decide [ Matrix.mulVec, dotProduct, Finset.mul_sum _ _ _, mul_comm ];
    rw [ Finset.sum_comm ];
    exact Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => by rw [ ← congr_fun ( congr_fun hA j ) i ] ; simp +decide [ mul_assoc, mul_comm, mul_left_comm ] ;
  simp_all +decide [ dotProduct_comm, inner ];
  exact h_inner.resolve_left ( Ne.symm hμν )

/-! ## Positive Semidefinite Matrices -/

/-
The quadratic form of a positive semidefinite real matrix is nonneg.
-/
theorem expectation_nonneg_of_posSemidef_real
    {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℝ) (hA : A.PosSemidef) (x : n → ℝ) :
    0 ≤ dotProduct (star x) (A.mulVec x) := by
  convert hA.dotProduct_mulVec_nonneg x

/-! ## Spectrum of Diagonal Matrices -/

/-
The spectrum of a diagonal matrix is the range of its diagonal entries.
-/
theorem spectrum_diagonal
    {n : Type*} [Fintype n] [DecidableEq n]
    (d : n → ℂ) :
    spectrum ℂ (Matrix.diagonal d) = Set.range d := by
  simp +decide [ spectrum.mem_iff, Matrix.isUnit_iff_isUnit_det ]

/-! ## Trace and Determinant from Eigenvalues -/

/-
The trace of a Hermitian matrix equals the sum of its eigenvalues.
-/
theorem trace_eq_sum_eigenvalues
    {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℂ)
    (hA : A.IsHermitian) :
    A.trace = ∑ i, (hA.eigenvalues i : ℂ) := by
  -- Apply the theorem that states the trace of a Hermitian matrix is equal to the sum of its eigenvalues.
  apply hA.trace_eq_sum_eigenvalues

/-
The determinant of a Hermitian matrix equals the product of its eigenvalues.
-/
theorem det_eq_prod_eigenvalues
    {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℂ)
    (hA : A.IsHermitian) :
    A.det = ∏ i, (hA.eigenvalues i : ℂ) := by
  convert hA.det_eq_prod_eigenvalues using 1

end SpectralTheory