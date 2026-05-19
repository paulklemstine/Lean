/-
  # Spectral Proof Universality — Definitions and Basic Results

  This file establishes the combinatorial and linear-algebraic foundations for
  spectral universality of proof graphs.

  ## Key definitions
  - `normalizedTrace`: the trace of a matrix divided by its dimension
  - `empiricalSpectralMoment`: the k-th moment of the empirical spectral measure

  ## Key results
  - `trace_conj_unitary`: trace is invariant under unitary conjugation
  - `trace_hermitian_pow_eq_sum_eigenvalues_pow`: tr(A^k) = Σ eigenvalue_i^k
  - `adjMatrix_isHermitian`: adjacency matrices are Hermitian
-/
import Mathlib

open Matrix Finset BigOperators

noncomputable section

/-! ## Normalized Trace -/

/-- The normalized trace of an `n × n` matrix: `tr(A) / n`. -/
def normalizedTrace {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  A.trace / n

/-! ## Trace is Invariant Under Unitary Conjugation -/

/-
Trace is invariant under conjugation by a unitary matrix:
    `tr(U * A * star U) = tr(A)`.
-/
theorem trace_conj_unitary {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℝ) (U : ↥(Matrix.unitaryGroup n ℝ)) :
    ((↑U : Matrix n n ℝ) * A * star (↑U : Matrix n n ℝ)).trace = A.trace := by
  convert Matrix.trace_mul_comm _ _ using 2;
  simp +decide [ ← mul_assoc, U.2.1 ]

/-! ## Trace of Powers Equals Sum of Eigenvalue Powers -/

/-
For a Hermitian (real symmetric) matrix, the trace of `A ^ k` equals
    the sum of the `k`-th powers of its eigenvalues. This is the fundamental
    identity connecting matrix analysis to spectral moments.
-/
theorem trace_hermitian_pow_eq_sum_eigenvalues_pow
    {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℝ) (hA : A.IsHermitian) (k : ℕ) :
    (A ^ k).trace = ∑ i, (hA.eigenvalues i) ^ k := by
  -- By the spectral theorem, A = U * diagonal(eigenvalues) * star U. Then A^k = U * diagonal(eigenvalues)^k * star U.
  have h_spectral : A ^ k = ((hA.eigenvectorUnitary : Matrix n n ℝ) * (Matrix.diagonal (fun i => (hA.eigenvalues i) ^ k)) * star (hA.eigenvectorUnitary : Matrix n n ℝ)) := by
    refine' Nat.recOn k _ _ <;> simp_all +decide [ pow_succ, mul_assoc ];
    intro m hm
    have h_spectral : A = (hA.eigenvectorUnitary : Matrix n n ℝ) * (Matrix.diagonal (fun i => (hA.eigenvalues i))) * star (hA.eigenvectorUnitary : Matrix n n ℝ) := by
      convert hA.spectral_theorem using 1;
    replace h_spectral := congr_arg ( fun x => hA.eigenvectorUnitary.val * ( diagonal ( fun i => hA.eigenvalues i ^ m ) * star ( hA.eigenvectorUnitary.val ) * x ) ) h_spectral ; simp_all +decide [ ← mul_assoc ];
    simp +decide [ Matrix.mul_assoc, Matrix.mul_diagonal ];
  rw [ h_spectral, Matrix.trace_mul_comm ];
  simp +decide [ ← mul_assoc, mul_eq_one_comm ]

/-! ## Adjacency Matrix Properties -/

/-
The trace of any square matrix is the sum of its diagonal entries.
-/
theorem trace_eq_sum_diag {V : Type*} [Fintype V] [DecidableEq V]
    (M : Matrix V V ℝ) :
    M.trace = ∑ v, M v v := by
  -- By definition of Matrix.trace, we have Matrix.trace M = ∑ i, M i i.
  simp [Matrix.trace]

/-
The adjacency matrix of a simple graph is symmetric (Hermitian over ℝ).
-/
theorem adjMatrix_isHermitian {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    (G.adjMatrix ℝ).IsHermitian := by
  ext i j; simp +decide [ SimpleGraph.adjMatrix_apply ] ;
  -- Since adjacency is symmetric, we have G.Adj j i ↔ G.Adj i j.
  simp [SimpleGraph.adj_comm]

/-! ## Empirical Spectral Moments -/

/-- The `k`-th empirical spectral moment of a Hermitian matrix: the average of the
    `k`-th powers of its eigenvalues. -/
def empiricalSpectralMoment {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℝ) (hA : A.IsHermitian) (k : ℕ) : ℝ :=
  (∑ i, (hA.eigenvalues i) ^ k) / Fintype.card n

/-
The empirical spectral moment equals the normalized trace of A^k.
-/
theorem empiricalSpectralMoment_eq_normalizedTrace
    {n : ℕ} [NeZero n] (A : Matrix (Fin n) (Fin n) ℝ) (hA : A.IsHermitian) (k : ℕ) :
    empiricalSpectralMoment A hA k = normalizedTrace (A ^ k) := by
  unfold empiricalSpectralMoment normalizedTrace;
  rw [ ← @trace_hermitian_pow_eq_sum_eigenvalues_pow ];
  norm_num

/-! ## Eigenvalue Bound from Degree Bound -/

/-
For a simple graph with maximum degree at most `D`, all eigenvalues
    of the adjacency matrix have absolute value at most `D`.
-/
theorem eigenvalue_bound_of_degree_bound
    {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (D : ℕ) (hdeg : ∀ v, G.degree v ≤ D) :
    ∀ i, |(adjMatrix_isHermitian G).eigenvalues i| ≤ D := by
  intro i;
  -- Let $v$ be an eigenvector corresponding to the eigenvalue $\lambda$.
  obtain ⟨v, hv⟩ : ∃ v : V → ℝ, v ≠ 0 ∧ (G.adjMatrix ℝ).mulVec v = (Matrix.IsHermitian.eigenvalues (adjMatrix_isHermitian G) i) • v := by
    refine' ⟨ _, _, _ ⟩;
    exact fun j => ( Matrix.IsHermitian.eigenvectorBasis ( adjMatrix_isHermitian G ) i ) j;
    · intro h; have := Orthonormal.ne_zero ( show Orthonormal ℝ ( fun i => ( Matrix.IsHermitian.eigenvectorBasis ( adjMatrix_isHermitian G ) i ) ) from by exact? ) i; simp_all +decide ;
    · convert Matrix.IsHermitian.mulVec_eigenvectorBasis ( adjMatrix_isHermitian G ) i using 1;
  -- Let $j$ be a vertex such that $|v_j|$ is maximal.
  obtain ⟨j, hj⟩ : ∃ j : V, ∀ k : V, |v k| ≤ |v j| := by
    simpa using Finset.exists_max_image Finset.univ ( fun k => |v k| ) ⟨ i, Finset.mem_univ i ⟩;
  -- Since $v$ is an eigenvector, we have $\sum_{k \in N(j)} v_k = \lambda v_j$, where $N(j)$ is the set of neighbors of $j$.
  have h_eigenvector : ∑ k ∈ G.neighborFinset j, v k = (Matrix.IsHermitian.eigenvalues (adjMatrix_isHermitian G) i) * v j := by
    convert congr_fun hv.2 j using 1;
    simp +decide [ Finset.sum_ite, SimpleGraph.neighborSet ];
  -- Taking the absolute value of both sides of the equation $\sum_{k \in N(j)} v_k = \lambda v_j$, we get $|\lambda| |v_j| \leq \sum_{k \in N(j)} |v_k|$.
  have h_abs_eigenvector : |(Matrix.IsHermitian.eigenvalues (adjMatrix_isHermitian G) i)| * |v j| ≤ ∑ k ∈ G.neighborFinset j, |v k| := by
    simpa only [ ← abs_mul, ← h_eigenvector ] using Finset.abs_sum_le_sum_abs _ _;
  -- Since $|v_k| \leq |v_j|$ for all $k$, we have $\sum_{k \in N(j)} |v_k| \leq D |v_j|$.
  have h_sum_abs_eigenvector : ∑ k ∈ G.neighborFinset j, |v k| ≤ D * |v j| := by
    exact le_trans ( Finset.sum_le_sum fun _ _ => hj _ ) ( by simpa using mul_le_mul_of_nonneg_right ( Nat.cast_le.mpr ( hdeg j ) ) ( abs_nonneg ( v j ) ) );
  exact le_of_mul_le_mul_right ( h_abs_eigenvector.trans h_sum_abs_eigenvector ) ( abs_pos.mpr ( show v j ≠ 0 from fun h => hv.1 <| funext fun k => by simpa [ h ] using hj k ) )

end