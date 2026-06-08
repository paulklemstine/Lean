import Mathlib

/-!
# Ihara Zeta Functions: Core Definitions

This file defines the fundamental objects in the theory of Ihara zeta functions
for finite graphs. The Ihara zeta function encodes the distribution of prime
cycles in a graph, analogous to how the Riemann zeta function encodes prime
numbers. The key bridge is the **Ihara-Bass determinant formula**, which
relates the zeta function to the adjacency and degree matrices.

## Main Definitions

* `ClosedWalkCount` — Number of closed walks of length k from vertex v
* `TotalClosedWalkCount` — Total closed walks of length k (= trace of A^k)
* `IharaMatrix` — The matrix I - uA + u²(D - I) appearing in the Ihara-Bass formula
* `GraphSpectralGap` — The spectral gap of a regular graph
* `IsRamanujanBound` — A graph satisfies the Ramanujan eigenvalue bound

## References

* Ihara, Y. "On discrete subgroups of the two by two projective linear group
  over p-adic fields" (1966)
* Bass, H. "The Ihara-Selberg zeta function of a tree lattice" (1992)
* Terras, A. "Zeta Functions of Graphs: A Stroll through the Garden" (2010)
-/

noncomputable section

open Matrix Finset BigOperators

variable {n : ℕ}

/-- The number of closed walks of length `k` starting and ending at vertex `v`
    in a graph with adjacency matrix `A`. This equals the diagonal entry `(A^k)_{v,v}`.

    This is the fundamental counting quantity in graph zeta function theory:
    the Ihara zeta function is built from prime (non-backtracking, primitive)
    cycles, but the total closed walk count provides the analytic handle via
    the trace formula. -/
def ClosedWalkCount (A : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) (v : Fin n) : ℝ :=
  (A ^ k) v v

/-- Total number of closed walks of length `k` in a graph with adjacency matrix `A`.
    Equals `tr(A^k)`, the trace of the k-th power of the adjacency matrix.

    For a graph with eigenvalues λ₁, ..., λₙ, this equals Σᵢ λᵢᵏ. -/
def TotalClosedWalkCount (A : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) : ℝ :=
  Matrix.trace (A ^ k)

/-- The **Ihara matrix** `I - u·A + u²·(D - I)` for a graph with adjacency matrix `A`
    and degree matrix `D`. This matrix appears in the Ihara-Bass determinant formula:

    ζ_G(u)⁻¹ = (1 - u²)^{m-n} · det(I - u·A + u²·(D - I))

    where m is the number of edges and n is the number of vertices.
    For a (q+1)-regular graph, D = (q+1)·I, so this simplifies to
    I - u·A + q·u²·I = (1 + q·u²)·I - u·A. -/
def IharaMatrix (A D : Matrix (Fin n) (Fin n) ℝ) (u : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  1 - u • A + u ^ 2 • (D - 1)

/-- The Ihara matrix for a regular graph of degree `q + 1`. In this case
    D = (q+1)·I, so the Ihara matrix simplifies to `(1 + q·u²)·I - u·A`. -/
def IharaMatrixRegular (A : Matrix (Fin n) (Fin n) ℝ) (q : ℕ) (u : ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  (1 + (q : ℝ) * u ^ 2) • (1 : Matrix (Fin n) (Fin n) ℝ) - u • A

/-- A real symmetric matrix `A` satisfies the **Ramanujan eigenvalue bound** with
    parameter `q` if every eigenvalue `λ` of `A` with `|λ| < q + 1` satisfies
    `|λ| ≤ 2√q`.

    For the adjacency matrix of a (q+1)-regular connected graph, the trivial
    eigenvalues are `±(q+1)`. The Ramanujan bound on the remaining eigenvalues
    is the graph-theoretic analogue of the Ramanujan-Petersson conjecture for
    automorphic forms. -/
def IsRamanujanBound (A : Matrix (Fin n) (Fin n) ℝ) (hA : A.IsHermitian) (q : ℕ) : Prop :=
  ∀ i : Fin n, |hA.eigenvalues i| < (q : ℝ) + 1 → |hA.eigenvalues i| ≤ 2 * Real.sqrt q

/-- The **spectral gap** of a matrix, defined as the difference between the largest
    eigenvalue and the second-largest eigenvalue in absolute value.
    For expander graphs, a large spectral gap implies rapid mixing. -/
def SpectralGap (A : Matrix (Fin n) (Fin n) ℝ) (hA : A.IsHermitian) (hn : 0 < n) : ℝ :=
  haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  let evals := hA.eigenvalues
  let maxEval := Finset.sup' Finset.univ (Finset.univ_nonempty) (fun i => |evals i|)
  let secondMax := Finset.sup' Finset.univ (Finset.univ_nonempty)
    (fun i => if |evals i| < maxEval then |evals i| else 0)
  maxEval - secondMax

/-- The **Ihara determinant** `det(I - u·A + u²·(D - I))`, whose zeros encode
    the poles of the Ihara zeta function. For a (q+1)-regular graph on n vertices
    with m edges, the Ihara-Bass formula states:
    ζ_G(u)⁻¹ = (1-u²)^{m-n} · det(IharaMatrix A D u) -/
def IharaDet (A D : Matrix (Fin n) (Fin n) ℝ) (u : ℝ) : ℝ :=
  (IharaMatrix A D u).det

/-- The **edge zeta function factor** `(1-u²)^{m-n}` appearing in the Ihara-Bass formula.
    Here `m - n` equals the first Betti number (cycle rank) of the graph when the graph
    is connected, measuring the "excess" edges beyond a spanning tree. -/
def EdgeZetaFactor (m n_vertices : ℕ) (u : ℝ) : ℝ :=
  (1 - u ^ 2) ^ (m - n_vertices)

/-- The **non-backtracking matrix** (or Hashimoto edge adjacency matrix) of a directed
    graph. For an undirected graph with m edges, this is a 2m × 2m matrix indexed by
    oriented edges, where B_{e,f} = 1 if the terminal vertex of e equals the initial
    vertex of f and f is not the reverse of e.

    The Ihara-Bass formula can be proved by showing that
    det(I - u·B) = (1-u²)^{m-n} · det(I - u·A + u²·(D-I))
    where B is this non-backtracking matrix. -/
def NonBacktrackingCondition (n_edges : ℕ)
    (B : Matrix (Fin (2 * n_edges)) (Fin (2 * n_edges)) ℝ)
    (A D : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ u : ℝ, (1 - u ^ 2) ^ (n_edges - n) * (IharaMatrix A D u).det =
    ((1 : Matrix (Fin (2 * n_edges)) (Fin (2 * n_edges)) ℝ) - u • B).det

end