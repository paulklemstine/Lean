"""
Canonical Kernel Solver for Metric Graph Models

Implements the canonical kernel calculus for computing harmonic representatives,
Jacobian classes, and energy pairings on metric graph models (finite weighted graphs
with positive edge lengths).

The core algorithm solves the metric Laplacian system to find normalized harmonic
potentials, which serve as canonical representatives of divisor classes in the
S-supported Jacobian quotient.

Cross-domain applications:
  - Electrical networks: computes effective resistances via Dirichlet energy
  - Tropical geometry: realizes the tropical Abel-Jacobi map on finite support sets
  - Quantum graphs: provides combinatorial Green's functions
  - Statistical mechanics: computes Gaussian free field covariance kernels
"""

import numpy as np
from typing import Optional


class MetricGraphModel:
    """A finite weighted graph model for a compact metric graph.

    Attributes:
        n_vertices: Number of vertices.
        adj: Adjacency matrix (boolean).
        edge_lengths: Matrix of positive edge lengths (symmetric).
        conductance: Matrix of conductances 1/ℓ(e).
        laplacian: The metric Laplacian matrix L.
    """

    def __init__(self, n_vertices: int, edges: list[tuple[int, int, float]]):
        """Initialize a metric graph model.

        Args:
            n_vertices: Number of vertices.
            edges: List of (i, j, length) tuples with length > 0.
        """
        self.n_vertices = n_vertices
        self.adj = np.zeros((n_vertices, n_vertices), dtype=bool)
        self.edge_lengths = np.zeros((n_vertices, n_vertices))
        self.conductance = np.zeros((n_vertices, n_vertices))

        for i, j, length in edges:
            assert length > 0, f"Edge length must be positive, got {length}"
            self.adj[i, j] = True
            self.adj[j, i] = True
            self.edge_lengths[i, j] = length
            self.edge_lengths[j, i] = length
            self.conductance[i, j] = 1.0 / length
            self.conductance[j, i] = 1.0 / length

        self.laplacian = self._build_laplacian()

    def _build_laplacian(self) -> np.ndarray:
        """Build the metric Laplacian matrix.

        L[i,j] = -cond(i,j) if i != j and i ~ j
        L[i,i] = sum_{k ~ i} cond(i,k)
        L[i,j] = 0 otherwise
        """
        n = self.n_vertices
        L = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                if i != j and self.adj[i, j]:
                    L[i, j] = -self.conductance[i, j]
                    L[i, i] += self.conductance[i, j]
        return L

    def apply_laplacian(self, f: np.ndarray) -> np.ndarray:
        """Apply the Laplacian to a vertex potential. Lf(v) = sum_j L[v,j]*f[j]."""
        return self.laplacian @ f

    def dirichlet_energy(self, f: np.ndarray) -> float:
        """Compute Dirichlet energy E(f) = f^T L f."""
        return float(f @ self.laplacian @ f)

    def energy_form(self, f: np.ndarray, g: np.ndarray) -> float:
        """Compute the energy bilinear form <f,g>_L = f^T L g."""
        return float(f @ self.laplacian @ g)

    def is_leaf(self, v: int) -> bool:
        """Check if vertex v is a leaf (degree 1)."""
        return int(np.sum(self.adj[v])) == 1

    def degree(self, v: int) -> int:
        """Return the degree of vertex v."""
        return int(np.sum(self.adj[v]))

    def neighbors(self, v: int) -> list[int]:
        """Return the neighbors of vertex v."""
        return [j for j in range(self.n_vertices) if self.adj[v, j]]

    def first_betti_number(self) -> int:
        """Compute the first Betti number (cycle rank) = |E| - |V| + components."""
        n_edges = int(np.sum(self.adj)) // 2
        # Count connected components via BFS
        visited = set()
        components = 0
        for start in range(self.n_vertices):
            if start not in visited:
                components += 1
                queue = [start]
                while queue:
                    v = queue.pop(0)
                    if v in visited:
                        continue
                    visited.add(v)
                    queue.extend(self.neighbors(v))
        return n_edges - self.n_vertices + components


def solve_normalized_kernel(
    model: MetricGraphModel,
    support_set: list[int],
    divisor: np.ndarray,
    normalization: str = "mean_zero"
) -> Optional[np.ndarray]:
    """Solve for the unique normalized harmonic potential with prescribed Laplacian.

    Given a degree-zero divisor D supported on S, finds the unique function f such that:
      1. f is harmonic on V \\ S (i.e., Lf(v) = 0 for v not in S)
      2. Lf(v) = D(v) for v in S
      3. f satisfies normalization (mean-zero or f(s0) = 0)

    This implements the canonical kernel correspondence: the normalized harmonic
    representative is uniquely determined by its source divisor.

    Args:
        model: The metric graph model.
        support_set: The support set S (list of vertex indices).
        divisor: Degree-zero divisor D (array of length n_vertices).
        normalization: "mean_zero" or "base_zero" (pin f(S[0]) = 0).

    Returns:
        The normalized potential f, or None if no solution exists.

    Complexity:
        Time: O(n^3) for solving the linear system.
        Space: O(n^2) for the Laplacian matrix.
    """
    n = model.n_vertices
    S = set(support_set)

    # Check degree zero
    if abs(np.sum(divisor)) > 1e-10:
        return None

    # Build the augmented system:
    # For v not in S: Lf(v) = 0 (harmonicity)
    # For v in S: Lf(v) = D(v) (source condition)
    # Plus one normalization constraint replacing one equation

    # The full system is just Lf = D where D is zero outside S
    # But L is singular (kernel = constants), so we add normalization

    A = model.laplacian.copy()
    b = divisor.copy()

    if normalization == "mean_zero":
        # Replace last row with mean-zero constraint: sum f(v) = 0
        A[-1, :] = 1.0
        b[-1] = 0.0
    elif normalization == "base_zero":
        # Replace row for S[0] with f(S[0]) = 0
        s0 = support_set[0]
        A[s0, :] = 0.0
        A[s0, s0] = 1.0
        b[s0] = 0.0

    try:
        f = np.linalg.solve(A, b)
        return f
    except np.linalg.LinAlgError:
        return None


def compute_kernel_matrix(
    model: MetricGraphModel,
    support_set: list[int],
    normalization: str = "mean_zero"
) -> np.ndarray:
    """Compute the canonical kernel matrix on the support set S.

    For each s in S, computes the normalized harmonic function k_s whose
    Laplacian is the unit source divisor delta_s - delta_{s0}.

    The kernel matrix K[i,j] = k_{s_i}(s_j) encodes all canonical kernel data.

    Args:
        model: The metric graph model.
        support_set: The support set S.
        normalization: Normalization method.

    Returns:
        Kernel matrix of shape (|S|, |S|).
    """
    n = model.n_vertices
    S = support_set
    k = len(S)
    K = np.zeros((k, k))

    s0 = S[0]  # Base point

    for idx, s in enumerate(S):
        if idx == 0:
            continue  # k_{s0} = 0 by convention

        # Divisor: +1 at s, -1 at s0
        D = np.zeros(n)
        D[s] = 1.0
        D[s0] = -1.0

        f = solve_normalized_kernel(model, S, D, normalization)
        if f is not None:
            for jdx, t in enumerate(S):
                K[idx, jdx] = f[t]

    return K


def compute_energy_pairing(
    model: MetricGraphModel,
    support_set: list[int],
    normalization: str = "mean_zero"
) -> np.ndarray:
    """Compute the Dirichlet energy pairing matrix on S-supported divisor classes.

    Q[i,j] = <k_i, k_j>_L where k_i are canonical kernel generators.
    This matrix is positive semidefinite and symmetric.

    In electrical network theory, Q encodes effective resistances.
    In tropical geometry, Q is the tropical polarization form.

    Args:
        model: The metric graph model.
        support_set: The support set S.
        normalization: Normalization method.

    Returns:
        Energy pairing matrix of shape (|S|-1, |S|-1).
    """
    n = model.n_vertices
    S = support_set
    k = len(S)
    s0 = S[0]

    # Compute all kernel generators
    kernels = []
    for idx in range(1, k):
        s = S[idx]
        D = np.zeros(n)
        D[s] = 1.0
        D[s0] = -1.0
        f = solve_normalized_kernel(model, S, D, normalization)
        kernels.append(f)

    # Build energy pairing matrix
    Q = np.zeros((k - 1, k - 1))
    for i in range(k - 1):
        for j in range(k - 1):
            if kernels[i] is not None and kernels[j] is not None:
                Q[i, j] = model.energy_form(kernels[i], kernels[j])

    return Q


def prune_pendant_trees(model: MetricGraphModel) -> tuple[list[int], dict[int, int]]:
    """Prune pendant trees from the graph, returning the 2-core vertices.

    Pendant tree pruning is justified by the leaf rigidity theorem:
    harmonic functions are constant on pendant edges, so pendant trees
    carry no independent Jacobian information.

    This is a key algorithmic optimization: the Jacobian computation
    reduces to the cycle core.

    Args:
        model: The metric graph model.

    Returns:
        core_vertices: List of vertices in the 2-core.
        leaf_map: Maps each pruned leaf to its attachment vertex.

    Complexity:
        Time: O(|V| + |E|) via iterative leaf removal.
    """
    degrees = np.array([model.degree(v) for v in range(model.n_vertices)])
    leaf_map = {}
    pruned = set()

    # Iteratively remove leaves
    changed = True
    while changed:
        changed = False
        for v in range(model.n_vertices):
            if v in pruned:
                continue
            # Recompute effective degree (excluding pruned vertices)
            eff_deg = sum(1 for j in model.neighbors(v) if j not in pruned)
            if eff_deg <= 1 and eff_deg > 0:
                # v is effectively a leaf; find its attachment
                attachment = [j for j in model.neighbors(v) if j not in pruned][0]
                leaf_map[v] = attachment
                pruned.add(v)
                changed = True
            elif eff_deg == 0 and model.n_vertices > 1:
                pruned.add(v)
                changed = True

    core_vertices = [v for v in range(model.n_vertices) if v not in pruned]
    return core_vertices, leaf_map


def subdivide_edge(
    model: MetricGraphModel,
    edge: tuple[int, int],
    ratio: float = 0.5
) -> MetricGraphModel:
    """Subdivide an edge by inserting a new vertex.

    The edge (u, v) with length ℓ is replaced by two edges:
      (u, w) with length ratio * ℓ
      (w, v) with length (1 - ratio) * ℓ

    This preserves harmonic functions: if f was harmonic at interior points,
    the subdivided model has f(w) = linear interpolation.

    Args:
        model: The original metric graph model.
        edge: The edge (u, v) to subdivide.
        ratio: Where to place the new vertex (0 < ratio < 1).

    Returns:
        A new MetricGraphModel with the subdivision.
    """
    u, v = edge
    assert model.adj[u, v], f"Edge ({u}, {v}) does not exist"
    assert 0 < ratio < 1

    orig_length = model.edge_lengths[u, v]
    n_new = model.n_vertices + 1
    w = model.n_vertices  # New vertex index

    # Collect edges, replacing (u,v) with (u,w) and (w,v)
    new_edges = []
    for i in range(model.n_vertices):
        for j in range(i + 1, model.n_vertices):
            if model.adj[i, j]:
                if (i, j) == (u, v) or (i, j) == (v, u):
                    continue  # Skip the subdivided edge
                new_edges.append((i, j, model.edge_lengths[i, j]))

    new_edges.append((u, w, ratio * orig_length))
    new_edges.append((w, v, (1 - ratio) * orig_length))

    return MetricGraphModel(n_new, new_edges)


# ─── Standard Graph Constructors ───

def cycle_graph(n: int, lengths: Optional[list[float]] = None) -> MetricGraphModel:
    """Create a cycle graph C_n with specified edge lengths.

    Args:
        n: Number of vertices (>= 3).
        lengths: Edge lengths (default: all 1.0).
    """
    if lengths is None:
        lengths = [1.0] * n
    assert len(lengths) == n
    edges = [(i, (i + 1) % n, lengths[i]) for i in range(n)]
    return MetricGraphModel(n, edges)


def theta_graph(lengths: tuple[float, float, float]) -> MetricGraphModel:
    """Create a theta graph (two vertices connected by 3 parallel paths).

    The theta graph has genus 2 and is a fundamental test case for
    tropical Jacobian computation.

    Args:
        lengths: Lengths of the three paths (each subdivided into a single edge).
    """
    # Vertices 0 and 1 are the poles; vertices 2, 3, 4 are midpoints of the three paths
    edges = [
        (0, 2, lengths[0] / 2), (2, 1, lengths[0] / 2),
        (0, 3, lengths[1] / 2), (3, 1, lengths[1] / 2),
        (0, 4, lengths[2] / 2), (4, 1, lengths[2] / 2),
    ]
    return MetricGraphModel(5, edges)


def lollipop_graph(cycle_length: float, stick_length: float, n_cycle: int = 4) -> MetricGraphModel:
    """Create a lollipop graph: a cycle with a pendant stick attached.

    This is the key test case for pendant tree pruning: the stick contributes
    nothing to the Jacobian.

    Args:
        cycle_length: Total length of the cycle.
        stick_length: Length of the pendant stick.
        n_cycle: Number of vertices in the cycle.
    """
    edge_len = cycle_length / n_cycle
    edges = [(i, (i + 1) % n_cycle, edge_len) for i in range(n_cycle)]
    # Attach pendant stick at vertex 0
    edges.append((0, n_cycle, stick_length))
    return MetricGraphModel(n_cycle + 1, edges)


if __name__ == "__main__":
    # Quick test
    C4 = cycle_graph(4, [1.0, 2.0, 1.0, 2.0])
    S = [0, 1, 2, 3]
    K = compute_kernel_matrix(C4, S)
    Q = compute_energy_pairing(C4, S)
    print("Kernel matrix on C4:")
    print(K)
    print("\nEnergy pairing matrix on C4:")
    print(Q)
    print(f"\nEnergy pairing eigenvalues: {np.linalg.eigvalsh(Q)}")
    print(f"First Betti number: {C4.first_betti_number()}")
