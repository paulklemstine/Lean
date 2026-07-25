import Mathlib

/-!
# The Ihara Zeta Function of a Graph — Definitions

This file establishes the foundational definitions for the Ihara zeta function
theory on finite graphs. The Ihara zeta function is the graph-theoretic analog
of the Riemann zeta function, where prime cycles in the graph play the role of
prime numbers.

## Main Definitions

* `RegularGraph` — A finite simple graph that is (q+1)-regular
* `IharaMatrix` — The matrix I - uA + u²(q-1)I for regular graphs
* `IsRamanujan` — The Ramanujan property: all non-trivial eigenvalues satisfy |λ| ≤ 2√q
* `GraphRH` — The graph-theoretic Riemann Hypothesis
* `PrimeCycleCountingFn` — Analog of the prime counting function π(x)

## References

* Ihara, Y. "On discrete subgroups of the two by two projective linear group
  over p-adic fields" (1966)
* Sunada, T. "L-functions in geometry and some applications" (1986)
* Hashimoto, K. "Zeta functions of finite graphs and representations of p-adic groups" (1989)
-/

noncomputable section

open Matrix Finset BigOperators

/-! ## Graph Structure -/

/-- A finite graph on n vertices with real-valued adjacency matrix.
    We use ℝ-valued adjacency to interface with spectral theory. -/
structure FinGraph (n : ℕ) where
  /-- The adjacency function. -/
  adj : Fin n → Fin n → ℝ
  /-- The adjacency matrix is symmetric. -/
  adj_symm : ∀ i j, adj i j = adj j i
  /-- No self-loops. -/
  no_loops : ∀ i, adj i i = 0
  /-- Adjacency values are 0 or 1 (simple graph). -/
  adj_zero_one : ∀ i j, adj i j = 0 ∨ adj i j = 1

/-- The degree of vertex i. -/
def FinGraph.degree {n : ℕ} (G : FinGraph n) (i : Fin n) : ℝ :=
  ∑ j, G.adj i j

/-- The adjacency matrix as a Mathlib Matrix. -/
def FinGraph.adjMat {n : ℕ} (G : FinGraph n) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of G.adj

/-- A graph is (q+1)-regular if every vertex has degree q+1. -/
def FinGraph.IsRegular {n : ℕ} (G : FinGraph n) (q : ℕ) : Prop :=
  ∀ i, G.degree i = (q + 1 : ℝ)

/-- A graph has non-negative adjacency entries. -/
lemma FinGraph.adj_nonneg {n : ℕ} (G : FinGraph n) (i j : Fin n) : 0 ≤ G.adj i j := by
  rcases G.adj_zero_one i j with h | h <;> simp [h]

/-! ## The Ihara Matrix -/

/-- The Ihara matrix for a (q+1)-regular graph:
    H(u) = (1 + (q-1)u²)I - uA
    When G is (q+1)-regular, this equals I - uA + u²(D - I) where D = (q+1)I. -/
def iharaMatrixReg {n : ℕ} (G : FinGraph n) (q : ℕ) (u : ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  (1 + ((q : ℝ) - 1) * u ^ 2) • (1 : Matrix (Fin n) (Fin n) ℝ) - u • G.adjMat

/-- The general Ihara matrix: I - uA + u²(D - I). -/
def iharaMatrixGen {n : ℕ} (G : FinGraph n) (u : ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  (1 : Matrix (Fin n) (Fin n) ℝ) - u • G.adjMat +
    u ^ 2 • (Matrix.diagonal (fun i => G.degree i) - 1)

/-! ## Eigenvalues and Spectral Theory -/

/-- λ is an eigenvalue of the adjacency matrix of G. -/
def FinGraph.IsEigenvalue {n : ℕ} (G : FinGraph n) (ev : ℝ) : Prop :=
  ∃ v : Fin n → ℝ, v ≠ 0 ∧ G.adjMat.mulVec v = ev • v

/-- A non-trivial eigenvalue: not equal to ±(q+1). -/
def FinGraph.IsNontrivialEigenvalue {n : ℕ} (G : FinGraph n) (q : ℕ) (ev : ℝ) : Prop :=
  G.IsEigenvalue ev ∧ |ev| ≠ (q + 1 : ℝ)

/-! ## The Ramanujan Property -/

/-- A (q+1)-regular graph is Ramanujan if all non-trivial eigenvalues
    satisfy |λ| ≤ 2√q. This is the spectral gap condition that is
    equivalent to the Riemann Hypothesis for the Ihara zeta function. -/
def FinGraph.IsRamanujan {n : ℕ} (G : FinGraph n) (q : ℕ) : Prop :=
  G.IsRegular q ∧
  ∀ ev : ℝ, G.IsNontrivialEigenvalue q ev → |ev| ≤ 2 * Real.sqrt q

/-! ## The Graph Riemann Hypothesis -/

/-- The "Riemann Hypothesis" for a regular graph's Ihara zeta function:
    all zeros of det(H(u)) with |u| < 1 lie on the circle |u| = 1/√q.

    Equivalently, if u₀ is a zero of det(I - uA + (q-1)u²I) and |u₀| < 1,
    then the corresponding eigenvalue λ of A satisfies |λ| ≤ 2√q.

    We formalize this as: for every eigenvalue λ of A, the reciprocal roots
    u of 1 - λu + (q-1)u² = 0 either have |u| ≥ 1 or |u| = 1/√q. -/
def GraphRH {n : ℕ} (G : FinGraph n) (q : ℕ) : Prop :=
  G.IsRegular q ∧
  ∀ ev : ℝ, G.IsEigenvalue ev →
    |ev| = (q + 1 : ℝ) ∨ |ev| ≤ 2 * Real.sqrt q

/-! ## Cycle Counting -/

/-- The number of closed walks of length k in graph G, computed as Tr(A^k). -/
def FinGraph.closedWalkCount {n : ℕ} (G : FinGraph n) (k : ℕ) : ℝ :=
  (G.adjMat ^ k).trace

/-- The edge count of a graph. -/
def FinGraph.edgeCount {n : ℕ} (G : FinGraph n) : ℝ :=
  (∑ i, ∑ j, G.adj i j) / 2

/-- The rank of the fundamental group: r = |E| - |V| + 1.
    For a connected graph, this equals the number of independent cycles. -/
def FinGraph.fundamentalRank {n : ℕ} (G : FinGraph n) : ℝ :=
  G.edgeCount - n + 1

end