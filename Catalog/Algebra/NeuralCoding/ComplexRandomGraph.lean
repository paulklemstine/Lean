import Mathlib

/-!
# Complex Weighted Random Graphs: Spectral Theory

## Overview

We formalize the theory of complex-weighted graphs, extending the classical
Erdős-Rényi random graph model G(n,p) to complex edge weights. In a complex
weighted graph G(n,z), each edge carries weight `z ∈ ℂ` instead of 1.

The key structural insight is the **scalar factorization**: the adjacency
matrix `A_z` factors as `z • B`, where `B` is the {0,1} Boolean adjacency
matrix. This has profound consequences:

1. **Normality**: `A_z` is always a normal matrix, hence unitarily
   diagonalizable over ℂ.
2. **Spectral Collinearity**: Eigenvalues of `A_z` lie on a single line
   through the origin in ℂ, contradicting circular law predictions for
   symmetric graphs.
3. **Walk Phase Accumulation**: k-step walks accumulate phase `z^k`,
   creating interference patterns in the complex plane.

## Main Results

- `adjMatrix_eq_smul_boolMatrix`: A_z = z • B
- `trace_adjMatrix_eq_zero`: tr(A_z) = 0  (no self-loops)
- `boolMatrix_conjTranspose_eq_self`: B is Hermitian (real + symmetric)
- `adjMatrix_is_normal`: A_z · A_z* = A_z* · A_z
- `adjMatrix_pow_eq_smul_pow`: A_z^k = z^k • B^k  (walk interference)
- `eigenvector_scaling`: eigenvectors of B are eigenvectors of A_z
- `frobenius_eq_normSq_mul_edgePairs`: ‖A_z‖²_F = |z|² · #edges
-/

open Matrix Complex Finset

/-- A complex weighted graph on `Fin n` vertices with uniform edge weight `z ∈ ℂ`.
Each undirected edge is either present (weight `z`) or absent (weight `0`).
The graph is simple: symmetric edge relation with no self-loops.

This extends the Erdős-Rényi model: when `z = 1`, this recovers the classical
unweighted adjacency matrix; when `z ∈ ℂ \ ℝ`, edges carry both amplitude and phase. -/
structure ComplexWeightedGraph (n : ℕ) where
  /-- The complex edge weight shared by all edges -/
  z : ℂ
  /-- Edge indicator: `edge i j = true` iff {i,j} is an edge -/
  edge : Fin n → Fin n → Bool
  /-- The edge relation is symmetric (undirected graph) -/
  edge_symm : ∀ i j, edge i j = edge j i
  /-- No vertex has a self-loop -/
  no_loop : ∀ i, edge i i = false

/-- A directed complex weighted graph, where the edge relation need not
be symmetric. This is the natural setting for the circular law: when
edges are i.i.d. Bernoulli, the centered matrix converges to the
Ginibre ensemble as n → ∞. -/
structure DirectedComplexGraph (n : ℕ) where
  /-- The complex edge weight -/
  z : ℂ
  /-- Edge indicator (not necessarily symmetric) -/
  edge : Fin n → Fin n → Bool
  /-- No self-loops -/
  no_loop : ∀ i, edge i i = false

namespace ComplexWeightedGraph

variable {n : ℕ} (G : ComplexWeightedGraph n)

/-! ### Matrix Definitions -/

/-- The Boolean adjacency matrix with entries in ℂ.
Entry `(i,j)` is `1` if edge `{i,j}` is present, `0` otherwise. -/
def boolMatrix : Matrix (Fin n) (Fin n) ℂ :=
  fun i j => if G.edge i j then 1 else 0

/-- The complex-weighted adjacency matrix.
Entry `(i,j)` is `z` if edge `{i,j}` is present, `0` otherwise. -/
def adjMatrix : Matrix (Fin n) (Fin n) ℂ :=
  fun i j => if G.edge i j then G.z else 0

/-- Number of ordered edge pairs `(i,j)` with the edge present.
For a symmetric graph, this equals twice the number of undirected edges. -/
def edgePairCount : ℕ :=
  (Finset.univ.filter (fun p : Fin n × Fin n => G.edge p.1 p.2)).card

/-- The degree of a vertex: number of neighbors. -/
def degree (i : Fin n) : ℕ :=
  (Finset.univ.filter (fun j : Fin n => G.edge i j)).card

/-! ### Scalar Factorization -/

/-
**Scalar Factorization**: The complex adjacency matrix equals `z`
times the Boolean adjacency matrix. This is the key structural identity
from which all spectral results follow.
-/
theorem adjMatrix_eq_smul_boolMatrix :
    G.adjMatrix = G.z • G.boolMatrix := by
      exact funext fun i => funext fun j => by unfold ComplexWeightedGraph.adjMatrix ComplexWeightedGraph.boolMatrix; aesop;

/-! ### Trace and Diagonal Properties -/

/-
The diagonal of the adjacency matrix is zero (no self-loops).
-/
theorem adjMatrix_diag_zero (i : Fin n) :
    G.adjMatrix i i = 0 := by
      exact if_neg ( by rw [ G.no_loop ] ; simp +decide )

/-
**Trace Identity**: The trace of the adjacency matrix is zero.
This holds because the graph has no self-loops.
-/
theorem trace_adjMatrix_eq_zero :
    Matrix.trace G.adjMatrix = 0 := by
      exact Finset.sum_eq_zero fun i _ => G.adjMatrix_diag_zero i

/-! ### Hermitian Structure of the Boolean Matrix -/

/-
The Boolean matrix is Hermitian: `B* = B`.
This holds because `B` has real entries (0 or 1) and is symmetric.
-/
theorem boolMatrix_conjTranspose_eq_self :
    G.boolMatrix.conjTranspose = G.boolMatrix := by
      ext i j; simp +decide [ G.edge_symm i j ] ;
      unfold ComplexWeightedGraph.boolMatrix;
      split_ifs <;> simp_all +decide [ Complex.ext_iff, G.edge_symm ]

/-! ### Conjugate Transpose of the Adjacency Matrix -/

/-
The conjugate transpose of `A_z` equals `z̄ • B`.
This follows from the scalar factorization and Hermitianness of `B`.
-/
theorem adjMatrix_conjTranspose :
    G.adjMatrix.conjTranspose = starRingEnd ℂ G.z • G.boolMatrix := by
      -- Apply the conjugate transpose to both sides of the scalar factorization.
      have h_conjTranspose : (G.z • G.boolMatrix)ᴴ = (starRingEnd ℂ) G.z • G.boolMatrix := by
        simp +decide [ Matrix.conjTranspose_smul ];
        exact congr_arg _ ( boolMatrix_conjTranspose_eq_self G );
      rw [ ← h_conjTranspose, adjMatrix_eq_smul_boolMatrix ]

/-! ### Normality Theorem -/

/-
**Normality Theorem**: The complex adjacency matrix is normal.
`A_z · A_z* = A_z* · A_z`.
Proof: Both sides equal `|z|² • B²` using commutativity of ℂ.
Normal matrices are unitarily diagonalizable — this is the gateway
to the full spectral analysis of complex weighted graphs.
-/
theorem adjMatrix_is_normal :
    G.adjMatrix * G.adjMatrix.conjTranspose =
    G.adjMatrix.conjTranspose * G.adjMatrix := by
      have adjMatrix_eq_smul_boolMatrix := G.adjMatrix_eq_smul_boolMatrix
      have adjMatrix_conjTranspose := G.adjMatrix_conjTranspose
      simp_all +decide [ mul_comm, mul_assoc, mul_left_comm, Algebra.smul_mul_assoc ];
      rw [ SMulCommClass.smul_comm ]

/-! ### Walk Phase Accumulation -/

/-
**Walk Phase Theorem**: The k-th power of the adjacency matrix
equals `z^k` times the k-th power of the Boolean matrix.
A walk of length `k` accumulates complex phase `z^k`, creating
constructive and destructive interference between different-length paths.
-/
theorem adjMatrix_pow_eq_smul_pow (k : ℕ) :
    G.adjMatrix ^ k = G.z ^ k • G.boolMatrix ^ k := by
      induction k <;> simp_all +decide [ pow_succ', Matrix.mul_assoc, smul_smul ];
      rw [ adjMatrix_eq_smul_boolMatrix, Matrix.smul_mul ] ; ring;
      rw [ smul_smul, mul_comm ]

/-! ### Eigenvector Scaling -/

/-
**Eigenvector Scaling**: If `v` is an eigenvector of the
Boolean matrix `B` with eigenvalue `μ`, then `v` is an eigenvector of `A_z`
with eigenvalue `z · μ`.

The spectrum of `A_z` is `{z · μ : μ ∈ spec(B)}`.
Since `B` is real symmetric, its eigenvalues are real, so all eigenvalues
of `A_z` lie on the line through the origin with direction `arg(z)` —
the **spectral collinearity** phenomenon.
-/
theorem eigenvector_scaling (v : Fin n → ℂ) (μ : ℂ)
    (hv : G.boolMatrix.mulVec v = μ • v) :
    G.adjMatrix.mulVec v = (G.z * μ) • v := by
      -- Substitute $G.adjMatrix = G.z • G.boolMatrix$ into the left-hand side of the equation.
      have h_subst : G.adjMatrix *ᵥ v = (G.z • G.boolMatrix) *ᵥ v := by
        rw [ ComplexWeightedGraph.adjMatrix_eq_smul_boolMatrix ];
      rw [ h_subst, Matrix.smul_mulVec, hv, smul_smul, mul_comm ]

/-! ### Frobenius Norm Identity -/

/-
**Frobenius Norm Identity**: `tr(A_z* · A_z) = |z|² · edgePairCount`.
This connects the spectral energy to graph topology:
since `tr(A* · A) = Σ|λ_i|²` for normal matrices, the sum of squared
eigenvalue moduli is determined by the edge count alone.
-/
theorem frobenius_eq_normSq_mul_edgePairs :
    Matrix.trace (G.adjMatrix.conjTranspose * G.adjMatrix) =
    (star G.z * G.z) * (↑G.edgePairCount : ℂ) := by
      unfold ComplexWeightedGraph.edgePairCount;
      simp +decide [ ComplexWeightedGraph.adjMatrix, ComplexWeightedGraph.boolMatrix, Matrix.trace ];
      -- Let's simplify the expression using the fact that multiplication by a constant out of the sum can be taken outside.
      have h_simp : ∑ x : Fin n, (starRingEnd ℂ G.z * G.z) * (Finset.filter (fun y : Fin n => G.edge x y) Finset.univ).card = (starRingEnd ℂ G.z * G.z) * ∑ x : Fin n, (Finset.filter (fun y : Fin n => G.edge x y) Finset.univ).card := by
        rw [ Nat.cast_sum, Finset.mul_sum _ _ _ ];
      convert h_simp using 2;
      · unfold ComplexWeightedGraph.adjMatrix; simp +decide [ Matrix.mul_apply, Finset.sum_ite ] ; ring;
        rw [ Finset.sum_congr rfl fun x hx => by rw [ if_pos ( Finset.mem_filter.mp hx |>.2 ) ] ] ; simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ];
        exact Or.inl ( by rw [ Finset.card_filter, Finset.card_filter ] ; exact Finset.sum_congr rfl fun _ _ => by rw [ G.edge_symm ] );
      · rw [ Finset.card_filter ];
        erw [ Finset.sum_product ] ; aesop

/-! ### Degree-Weight Connection -/

/-
The row sum at vertex `i` equals `z` times the degree.
Complex flow through a vertex is proportional to topological degree.
-/
theorem row_sum_eq_z_mul_degree (i : Fin n) :
    ∑ j : Fin n, G.adjMatrix i j = G.z * (↑(G.degree i) : ℂ) := by
      have h_sum : ∑ j, G.adjMatrix i j = ∑ j ∈ Finset.univ.filter (fun j => G.edge i j), G.z := by
        rw [ Finset.sum_filter, Finset.sum_congr rfl ] ; aesop;
      simp_all +decide [ mul_comm, ComplexWeightedGraph.degree ]

end ComplexWeightedGraph

/-! ## Spectral Collinearity Structure -/

/-- **Spectral Collinearity**: A matrix `M` has collinear spectrum with
direction `w ∈ ℂ` if `M = w • H` for some Hermitian matrix `H`.
Eigenvalues are of the form `w · λ` for real `λ`, lying on
the line `{t · w : t ∈ ℝ}` in the complex plane. -/
structure ComplexSpectralCollinearity (n : ℕ) where
  /-- The matrix with collinear spectrum -/
  M : Matrix (Fin n) (Fin n) ℂ
  /-- The direction of spectral collinearity -/
  direction : ℂ
  /-- The underlying Hermitian matrix -/
  H : Matrix (Fin n) (Fin n) ℂ
  /-- H is Hermitian -/
  h_hermitian : H.conjTranspose = H
  /-- M factors as direction • H -/
  h_factored : M = direction • H

/-
Every undirected complex weighted graph has collinear spectrum:
the adjacency matrix factors as `z • B` where `B` is Hermitian.
-/
theorem ComplexWeightedGraph.has_spectral_collinearity
    {n : ℕ} (G : ComplexWeightedGraph n) :
    ∃ c : ComplexSpectralCollinearity n,
      c.M = G.adjMatrix ∧ c.direction = G.z := by
        refine' ⟨ ⟨ _, _, _, _, _ ⟩, _, _ ⟩;
        exact G.z • G.boolMatrix;
        exact G.z
        exact G.boolMatrix
        exact G.boolMatrix_conjTranspose_eq_self
        exact rfl
        exact G.adjMatrix_eq_smul_boolMatrix.symm
        exact rfl