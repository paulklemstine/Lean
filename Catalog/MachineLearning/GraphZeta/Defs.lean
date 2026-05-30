import Mathlib

/-!
# Graph Zeta Functions: Definitions

The Ihara zeta function of a finite graph is a graph-theoretic analog of the Riemann zeta
function. For a (q+1)-regular graph on n vertices with adjacency matrix A, the reciprocal
of the Ihara zeta function is given by:

  ζ_G(u)⁻¹ = (1 - u²)^{r-1} · det(I - Au + qu²I)

where r = |E| - |V| + 1 is the rank of the fundamental group.

This module defines the core structures and the key matrices involved.
-/

noncomputable section

open Matrix Finset BigOperators

/-! ## Core Graph Structure -/

/-- A finite graph on `n` vertices represented by a real-valued adjacency matrix.
    We require symmetry and non-negative entries. For simple graphs, entries are 0 or 1. -/
structure FinGraph (n : ℕ) where
  /-- The adjacency matrix -/
  adj : Fin n → Fin n → ℝ
  /-- Adjacency is symmetric -/
  adj_symm : ∀ i j, adj i j = adj j i
  /-- Adjacency entries are non-negative -/
  adj_nonneg : ∀ i j, 0 ≤ adj i j

namespace FinGraph

variable {n : ℕ} (G : FinGraph n)

/-- The degree of vertex i: sum of adjacency entries in row i. -/
def degree (i : Fin n) : ℝ := ∑ j, G.adj i j

/-- The adjacency matrix as a Mathlib Matrix. -/
def adjMatrix : Matrix (Fin n) (Fin n) ℝ := Matrix.of G.adj

/-- The degree matrix (diagonal matrix of degrees). -/
def degMatrix : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.diagonal (fun i => G.degree i)

/-- A graph is (q+1)-regular if every vertex has degree q+1. -/
def IsRegular (q : ℕ) : Prop :=
  ∀ i, G.degree i = (q + 1 : ℝ)

/-- The Ihara matrix: I - u·A + u²·(D - I), whose determinant gives ζ_G(u)⁻¹
    (up to the (1-u²) factor). -/
def iharaMatrix (u : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  1 - u • G.adjMatrix + u ^ 2 • (G.degMatrix - 1)

/-- Number of edges: half the sum of all adjacency entries. -/
def numEdges : ℝ := (∑ i, ∑ j, G.adj i j) / 2

/-- Rank of the fundamental group: |E| - |V| + 1. -/
def graphRank : ℝ := G.numEdges - n + 1

/-- A graph is Ramanujan if it is (q+1)-regular and all non-trivial eigenvalues λ
    satisfy |λ| ≤ 2√q. The trivial eigenvalue is ±(q+1). -/
def IsRamanujan (q : ℕ) : Prop :=
  G.IsRegular q ∧
  ∀ ev : ℝ,
    (∃ v : Fin n → ℝ, v ≠ 0 ∧ G.adjMatrix.mulVec v = ev • v) →
    |ev| = (q + 1 : ℝ) ∨ |ev| ≤ 2 * Real.sqrt q

/-! ## Ihara Zeta Polynomial

For a (q+1)-regular graph, the Ihara determinant polynomial is
  det(I - uA + qu²I) = ∏ᵢ (1 - λᵢu + qu²)
where λᵢ are the eigenvalues of A. We define the characteristic-style polynomial
directly. -/

/-- The Ihara characteristic polynomial evaluated at u, for a regular graph:
    p(u) = det((1 + qu²)I - uA). This is the determinantal part of ζ_G(u)⁻¹. -/
def iharaCharPoly (q : ℕ) (u : ℝ) : ℝ :=
  (((1 + (q : ℝ) * u ^ 2) • (1 : Matrix (Fin n) (Fin n) ℝ)) - u • G.adjMatrix).det

/-! ## Prime Cycle Counting

The graph analog of the prime counting function π(x). A prime cycle of length ℓ
contributes to N_ℓ (the number of closed walks of length ℓ), and the prime cycle
counting function Π_G(x) counts the number of prime cycles of length ≤ x. -/

/-- The number of closed walks of length k, given by Tr(A^k). -/
def closedWalkCount (k : ℕ) : ℝ :=
  (G.adjMatrix ^ k).trace

/-- The adjacency matrix is symmetric (as a Mathlib Matrix). -/
theorem adjMatrix_symm : G.adjMatrix.transpose = G.adjMatrix := by
  ext i j
  simp [adjMatrix, Matrix.of, Matrix.transpose]
  exact G.adj_symm j i

/-! ## Spectral Radius

The spectral radius ρ(A) bounds eigenvalues. For a (q+1)-regular graph,
ρ(A) = q+1. -/

/-- An eigenvalue of the adjacency matrix. -/
def IsEigenvalue (ev : ℝ) : Prop :=
  ∃ v : Fin n → ℝ, v ≠ 0 ∧ G.adjMatrix.mulVec v = ev • v

/-- The Ramanujan bound for non-trivial eigenvalues. -/
def RamanujanBound (q : ℕ) : ℝ := 2 * Real.sqrt q

end FinGraph

/-! ## Cross-Domain: Chebyshev Polynomials and Graph Spectra

The connection between graph spectra and number theory passes through Chebyshev
polynomials. For a (q+1)-regular tree, the spectral measure is the Kesten-McKay
distribution, whose moments are given by Chebyshev polynomials of the second kind.

The Chebyshev polynomial U_n(x) satisfies:
  U_n(cos θ) = sin((n+1)θ) / sin(θ)

For a Ramanujan graph, all non-trivial eigenvalues lie in [-2√q, 2√q], which is
the support of the Kesten-McKay distribution. -/

/-- Chebyshev polynomial of the second kind, defined recursively:
    U_0(x) = 1, U_1(x) = 2x, U_{n+2}(x) = 2x·U_{n+1}(x) - U_n(x). -/
def chebyshevU : ℕ → ℝ → ℝ
  | 0, _ => 1
  | 1, x => 2 * x
  | n + 2, x => 2 * x * chebyshevU (n + 1) x - chebyshevU n x

end