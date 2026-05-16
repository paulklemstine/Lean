/-
Copyright (c) 2025 Spectral Theorem Formalization. All rights reserved.
Released under Apache 2.0 license.

# Finite-Dimensional Spectral Theorem for Real Symmetric Matrices

This file establishes the finite-dimensional spectral theorem infrastructure:
- Bridge between `Matrix.IsSymm` and `LinearMap.IsSymmetric`
- Orthogonality of eigenvectors for distinct eigenvalues
- Existence of orthonormal eigenbasis (via Mathlib's spectral theorem)
- Orthogonal diagonalization: `A = Q * D * Qᵀ`
- Invariance of orthogonal complement under symmetric operators
- Rayleigh quotient characterization

## Main results

* `matrix_isSymm_toEuclideanLin_isSymmetric` : symmetric matrix → self-adjoint linear map
* `symmetric_eigenvectors_orthogonal` : eigenvectors for distinct eigenvalues are orthogonal
* `symmetric_preserves_orthogonal_complement` : orthogonal complement of eigenspace is invariant
* `exists_orthogonal_diagonalization` : orthogonal diagonalization exists for symmetric matrices
* `rayleighQuotient_eigenvector` : Rayleigh quotient at eigenvector equals the eigenvalue
* `simpleGraph_adj_isSymm` : graph adjacency matrices are symmetric

## References

* Axler, *Linear Algebra Done Right*, Chapter 7
* Horn & Johnson, *Matrix Analysis*, Chapter 4
-/

import Mathlib

open Matrix BigOperators

noncomputable section

/-! ## Section 1: The Symmetry–Self-Adjointness Bridge -/

/-- A real symmetric matrix gives rise to a symmetric linear map on Euclidean space.
This is the fundamental bridge between the matrix world and the operator world. -/
theorem matrix_isSymm_toEuclideanLin_isSymmetric
    {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ}
    (hA : A.IsSymm) :
    (Matrix.toEuclideanLin A).IsSymmetric :=
  isHermitian_iff_isSymmetric.mp hA

/-! ## Section 2: Orthogonality of Eigenvectors -/

/-- Eigenvectors of a symmetric linear map for distinct eigenvalues are orthogonal.
From `T v = μ v` and `T w = ν w`, compute `⟪T v, w⟫ = μ ⟪v, w⟫` and
`⟪v, T w⟫ = ν ⟪v, w⟫`. By symmetry, `(μ - ν) ⟪v, w⟫ = 0`, hence `⟪v, w⟫ = 0`. -/
theorem symmetric_linearmap_eigenvectors_orthogonal
    {n : ℕ} {T : EuclideanSpace ℝ (Fin n) →ₗ[ℝ] EuclideanSpace ℝ (Fin n)}
    (hT : T.IsSymmetric)
    {μ ν : ℝ} {v w : EuclideanSpace ℝ (Fin n)}
    (hv : T v = μ • v) (hw : T w = ν • w)
    (hμν : μ ≠ ν) :
    @inner ℝ _ _ v w = 0 := by
  have h_symm : inner ℝ (T v) w = inner ℝ v (T w) :=
    Real.ext_cauchy (congrArg Real.cauchy (hT v w))
  simp_all +decide [inner_smul_left, inner_smul_right]

/-- Matrix-level eigenvector orthogonality: if `A` is symmetric and `v`, `w` are
eigenvectors with distinct eigenvalues, then `⟪v, w⟫ = 0`. -/
theorem symmetric_eigenvectors_orthogonal
    {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ}
    (hA : A.IsSymm)
    {μ ν : ℝ} {v w : EuclideanSpace ℝ (Fin n)}
    (hv : (Matrix.toEuclideanLin A) v = μ • v)
    (hw : (Matrix.toEuclideanLin A) w = ν • w)
    (hμν : μ ≠ ν) :
    @inner ℝ _ _ v w = 0 :=
  symmetric_linearmap_eigenvectors_orthogonal
    (matrix_isSymm_toEuclideanLin_isSymmetric hA) hv hw hμν

/-! ## Section 3: Orthogonal Complement Invariance -/

/-- The orthogonal complement of an eigenvector of a symmetric map is invariant.
If `T v = μ v` and `⟪w, v⟫ = 0`, then `⟪T w, v⟫ = ⟪w, T v⟫ = μ ⟪w, v⟫ = 0`. -/
theorem symmetric_preserves_orthogonal_complement
    {n : ℕ} {T : EuclideanSpace ℝ (Fin n) →ₗ[ℝ] EuclideanSpace ℝ (Fin n)}
    (hT : T.IsSymmetric)
    {v : EuclideanSpace ℝ (Fin n)} {μ : ℝ}
    (hv : T v = μ • v) :
    ∀ w, @inner ℝ _ _ w v = 0 →
      @inner ℝ _ _ (T w) v = 0 := by
  intro w hw
  have h_symm : inner ℝ (T w) v = inner ℝ w (T v) := hT w v
  simp_all +decide [inner_smul_right]

/-! ## Section 4: Orthonormal Eigenbasis -/

/-- The finrank of `EuclideanSpace ℝ (Fin n)` is `n`. -/
theorem euclideanSpace_finrank (n : ℕ) :
    Module.finrank ℝ (EuclideanSpace ℝ (Fin n)) = n := by
  norm_num +zetaDelta

/-- A symmetric matrix has an orthonormal eigenbasis with real eigenvalues.
This packages Mathlib's spectral theorem for the matrix setting. -/
theorem symmetric_matrix_has_orthonormal_eigenbasis
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (hA : A.IsSymm) :
    ∃ (b : OrthonormalBasis (Fin n) ℝ (EuclideanSpace ℝ (Fin n)))
      (eigenvals : Fin n → ℝ),
      ∀ i, (Matrix.toEuclideanLin A) (b i) = eigenvals i • (b i) := by
  have hS := matrix_isSymm_toEuclideanLin_isSymmetric hA
  have hn := euclideanSpace_finrank n
  exact ⟨hS.eigenvectorBasis hn, fun i => hS.eigenvalues hn i,
    fun i => by convert hS.apply_eigenvectorBasis hn i using 1⟩

/-! ## Section 5: Orthogonal Diagonalization -/

/-- **Finite-dimensional spectral theorem (matrix form).**
Every real symmetric matrix admits an orthogonal diagonalization:
there exist an orthogonal matrix `Q` and a diagonal matrix `D` such that
`A = Q * D * Qᵀ`. -/
theorem exists_orthogonal_diagonalization
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (hA : A.IsSymm) :
    ∃ Q D : Matrix (Fin n) (Fin n) ℝ,
      Qᵀ * Q = 1 ∧
      Q * Qᵀ = 1 ∧
      D.IsDiag ∧
      A = Q * D * Qᵀ := by
  have := Matrix.IsHermitian.spectral_theorem hA
  refine ⟨_, _, ?_, ?_, ?_, this⟩
  · simp +decide [← Matrix.ext_iff, Matrix.mul_apply]
    intro i j
    have := (IsHermitian.eigenvectorBasis hA).orthonormal
    simp +decide [orthonormal_iff_ite] at this
    convert this i j using 1
    exact Finset.sum_congr rfl fun _ _ => mul_comm _ _
  · exact (IsHermitian.eigenvectorUnitary hA).2.2
  · exact fun i j hij => if_neg hij

/-! ## Section 6: Rayleigh Quotient -/

/-- The Rayleigh quotient of a matrix `A` at a vector `v`:
`R_A(v) = ⟪v, Av⟫ / ⟪v, v⟫`. -/
def rayleighQuotient {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (v : EuclideanSpace ℝ (Fin n)) : ℝ :=
  @inner ℝ _ _ v ((Matrix.toEuclideanLin A) v) / @inner ℝ _ _ v v

/-- For a symmetric matrix, the Rayleigh quotient at an eigenvector equals
the eigenvalue. This is the key identity linking variational and algebraic
spectral characterizations. -/
theorem rayleighQuotient_eigenvector
    {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ}
    (_hA : A.IsSymm)
    {v : EuclideanSpace ℝ (Fin n)} {μ : ℝ}
    (hv : v ≠ 0)
    (heig : (Matrix.toEuclideanLin A) v = μ • v) :
    rayleighQuotient A v = μ := by
  unfold rayleighQuotient
  simp_all +decide [inner_smul_right]

/-! ## Section 7: Graph Spectral Corollaries -/

/-- The adjacency matrix of a simple graph is symmetric, because graph
adjacency is a symmetric relation. -/
theorem simpleGraph_adj_isSymm {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] :
    ((SimpleGraph.adjMatrix ℝ G) : Matrix (Fin n) (Fin n) ℝ).IsSymm := by
  ext i j
  simp [SimpleGraph.adjMatrix, SimpleGraph.adj_comm]

/-- Corollary: graph adjacency matrices have orthonormal eigenbases. -/
theorem simpleGraph_has_orthonormal_eigenbasis {n : ℕ}
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] :
    ∃ (b : OrthonormalBasis (Fin n) ℝ (EuclideanSpace ℝ (Fin n)))
      (eigenvals : Fin n → ℝ),
      ∀ i, (Matrix.toEuclideanLin (SimpleGraph.adjMatrix ℝ G)) (b i) =
        eigenvals i • (b i) :=
  symmetric_matrix_has_orthonormal_eigenbasis _ (simpleGraph_adj_isSymm G)

/-- Corollary: the adjacency matrix of a simple graph admits orthogonal
diagonalization. This is the formal gateway to spectral graph theory. -/
theorem simpleGraph_orthogonal_diagonalization {n : ℕ}
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] :
    ∃ Q D : Matrix (Fin n) (Fin n) ℝ,
      Qᵀ * Q = 1 ∧ Q * Qᵀ = 1 ∧ D.IsDiag ∧
      (SimpleGraph.adjMatrix ℝ G : Matrix _ _ ℝ) = Q * D * Qᵀ :=
  exists_orthogonal_diagonalization _ (simpleGraph_adj_isSymm G)

end