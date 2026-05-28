"""
Canonical Kernel Solver for Metric Graph Models

Implements the verified computational pipeline for computing canonical harmonic
representatives, Dirichlet energy pairings, and S-supported Jacobian quotients
on metric graph models.

Mathematical foundation: For a compact connected metric graph Γ with a finite
separated set S of support points, the canonical kernel family {k_s : s ∈ S}
consists of normalized piecewise-linear functions harmonic off S, with unit
sources at each support point.

References:
- Baker & Faber, "Metrized graphs, Laplacian operators, and electrical networks" (2006)
- Baker & Norine, "Riemann-Roch and Abel-Jacobi theory on a finite graph" (2007)
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass


@dataclass
class MetricGraphModel:
    """A finite metric graph model: vertices, adjacency, and edge lengths.

    Attributes:
        n_vertices: Number of vertices
        adjacency: n×n adjacency matrix (0/1)
        edge_lengths: n×n matrix of edge lengths (positive where adjacent)
    """
    n_vertices: int
    adjacency: np.ndarray
    edge_lengths: np.ndarray

    def validate(self) -> bool:
        """Check model invariants: symmetry, positivity on edges."""
        n = self.n_vertices
        assert self.adjacency.shape == (n, n)
        assert self.edge_lengths.shape == (n, n)
        assert np.allclose(self.adjacency, self.adjacency.T), "Adjacency must be symmetric"
        assert np.allclose(self.edge_lengths, self.edge_lengths.T), "Lengths must be symmetric"
        for i in range(n):
            assert self.adjacency[i, i] == 0, "No self-loops"
            for j in range(n):
                if self.adjacency[i, j]:
                    assert self.edge_lengths[i, j] > 0, f"Edge ({i},{j}) has non-positive length"
        return True

    @property
    def conductance_matrix(self) -> np.ndarray:
        """Conductance = 1/length for adjacent pairs, 0 otherwise."""
        C = np.zeros_like(self.edge_lengths)
        mask = self.adjacency > 0
        C[mask] = 1.0 / self.edge_lengths[mask]
        return C

    @property
    def laplacian(self) -> np.ndarray:
        """Weighted Laplacian matrix L with entries:
        L[i,i] = sum of conductances of edges incident to i
        L[i,j] = -conductance(i,j) if adjacent, 0 otherwise.

        Satisfies: row-sum-zero, symmetry, positive semi-definiteness.
        """
        C = self.conductance_matrix
        L = -C.copy()
        np.fill_diagonal(L, C.sum(axis=1))
        return L

    @property
    def genus(self) -> int:
        """First Betti number = |E| - |V| + 1 for connected graphs."""
        n_edges = int(self.adjacency.sum()) // 2
        return n_edges - self.n_vertices + 1

    def is_leaf(self, v: int) -> bool:
        """Check if vertex v is a leaf (degree 1)."""
        return int(self.adjacency[v].sum()) == 1

    def leaf_vertices(self) -> List[int]:
        """Return list of leaf vertices."""
        return [v for v in range(self.n_vertices) if self.is_leaf(v)]

    def degree(self, v: int) -> int:
        """Degree of vertex v."""
        return int(self.adjacency[v].sum())


def build_cycle_graph(edge_lengths: List[float]) -> MetricGraphModel:
    """Build a cycle graph with given edge lengths.

    Args:
        edge_lengths: List of n positive real numbers for the n edges of C_n.

    Returns:
        MetricGraphModel for the cycle.
    """
    n = len(edge_lengths)
    adj = np.zeros((n, n))
    lengths = np.zeros((n, n))
    for i in range(n):
        j = (i + 1) % n
        adj[i, j] = adj[j, i] = 1
        lengths[i, j] = lengths[j, i] = edge_lengths[i]
    return MetricGraphModel(n, adj, lengths)


def build_theta_graph(lengths: Tuple[float, float, float]) -> MetricGraphModel:
    """Build a theta graph (two vertices connected by 3 parallel paths).

    For simplicity, each path has one intermediate vertex, giving 5 vertices total
    with 3 internal vertices on the paths.

    Args:
        lengths: Tuple (l1, l2, l3) for the three path lengths.

    Returns:
        MetricGraphModel for the theta graph.
    """
    # Vertices: 0 = left hub, 1 = right hub, 2,3,4 = midpoints of paths
    n = 5
    adj = np.zeros((n, n))
    edge_len = np.zeros((n, n))

    for k, mid in enumerate([2, 3, 4]):
        half = lengths[k] / 2.0
        adj[0, mid] = adj[mid, 0] = 1
        adj[mid, 1] = adj[1, mid] = 1
        edge_len[0, mid] = edge_len[mid, 0] = half
        edge_len[mid, 1] = edge_len[1, mid] = half

    return MetricGraphModel(n, adj, edge_len)


def build_lollipop_graph(cycle_lengths: List[float], tail_length: float) -> MetricGraphModel:
    """Build a lollipop graph: a cycle with a pendant tail attached.

    Args:
        cycle_lengths: Edge lengths for the cycle part.
        tail_length: Length of the pendant edge.

    Returns:
        MetricGraphModel for the lollipop.
    """
    n_cycle = len(cycle_lengths)
    n = n_cycle + 1
    adj = np.zeros((n, n))
    lengths = np.zeros((n, n))

    # Cycle edges
    for i in range(n_cycle):
        j = (i + 1) % n_cycle
        adj[i, j] = adj[j, i] = 1
        lengths[i, j] = lengths[j, i] = cycle_lengths[i]

    # Pendant edge from vertex 0 to vertex n_cycle
    adj[0, n_cycle] = adj[n_cycle, 0] = 1
    lengths[0, n_cycle] = lengths[n_cycle, 0] = tail_length

    return MetricGraphModel(n, adj, lengths)


def solve_canonical_kernel(
    model: MetricGraphModel,
    support: List[int],
    divisor: np.ndarray,
    normalization: str = "mean_zero"
) -> Dict:
    """Solve for the canonical kernel representative.

    Given a metric graph model M, a support set S, and a degree-zero
    S-supported divisor D, find the unique normalized potential f such that
    L f = D (on S) and f is harmonic off S.

    Algorithm:
    1. Build weighted Laplacian L with conductance weights 1/ℓ(e).
    2. Impose mean-zero normalization (remove one degree of freedom).
    3. Solve the constrained linear system.

    Args:
        model: The metric graph model.
        support: List of support vertex indices.
        divisor: Degree-zero divisor values at support vertices.
        normalization: "mean_zero" or "pin_first" (pin f(S[0]) = 0).

    Returns:
        Dictionary with potential, energy, kernel_matrix, and certificate.

    Complexity: O(n³) for the linear solve, where n = |V|.
    """
    n = model.n_vertices
    L = model.laplacian

    # Full RHS: D at support, 0 elsewhere
    rhs = np.zeros(n)
    for i, s in enumerate(support):
        rhs[s] = divisor[i]

    if normalization == "mean_zero":
        # Augmented system: [L, 1; 1^T, 0] [f; λ] = [D; 0]
        A = np.zeros((n + 1, n + 1))
        A[:n, :n] = L
        A[:n, n] = 1.0
        A[n, :n] = 1.0
        b = np.zeros(n + 1)
        b[:n] = rhs
        sol = np.linalg.lstsq(A, b, rcond=None)[0]
        f = sol[:n]
    elif normalization == "pin_first":
        # Pin f(support[0]) = 0, solve reduced system
        pin = support[0]
        idx = [i for i in range(n) if i != pin]
        L_red = L[np.ix_(idx, idx)]
        rhs_red = rhs[idx]
        f_red = np.linalg.solve(L_red, rhs_red)
        f = np.zeros(n)
        f[idx] = f_red
    else:
        raise ValueError(f"Unknown normalization: {normalization}")

    # Compute Dirichlet energy
    energy = f @ L @ f

    # Verify harmonicity off support
    Lf = L @ f
    harmonic_residual = max(abs(Lf[v]) for v in range(n) if v not in support)

    # Certificate
    certificate = {
        "is_harmonic_off_S": harmonic_residual < 1e-10,
        "degree_zero": abs(sum(divisor)) < 1e-10,
        "mean_zero": abs(sum(f)) < 1e-10 if normalization == "mean_zero" else None,
        "energy": energy,
    }

    return {
        "potential": f,
        "energy": energy,
        "laplacian_image": Lf,
        "certificate": certificate,
    }


def compute_kernel_matrix(
    model: MetricGraphModel,
    support: List[int],
    normalization: str = "mean_zero"
) -> np.ndarray:
    """Compute the canonical kernel matrix K on support set S.

    K[i,j] = k_i(s_j) where k_i is the canonical kernel generator for
    source s_i. The kernel matrix encodes the Green's function / effective
    resistance structure of the metric graph.

    Args:
        model: The metric graph model.
        support: List of support vertex indices.
        normalization: Normalization scheme.

    Returns:
        |S| × |S| kernel matrix.
    """
    k = len(support)
    K = np.zeros((k, k))

    for i in range(k):
        # Unit source at support[i], distributed sink at other support vertices
        D = np.zeros(k)
        D[i] = k - 1
        for j in range(k):
            if j != i:
                D[j] = -1

        result = solve_canonical_kernel(model, support, D, normalization)
        for j in range(k):
            K[i, j] = result["potential"][support[j]]

    return K


def compute_dirichlet_energy_form(
    model: MetricGraphModel,
    support: List[int]
) -> np.ndarray:
    """Compute the Dirichlet energy bilinear form on S-supported divisors.

    Q[i,j] = E(k_i, k_j) where E is the Dirichlet energy and k_i are
    canonical kernel generators.

    This is the tropical polarization on the Jacobian, and equals the
    effective resistance form in electrical network theory.

    Args:
        model: The metric graph model.
        support: List of support vertex indices.

    Returns:
        |S| × |S| energy form matrix (symmetric, positive semidefinite).
    """
    L = model.laplacian
    k = len(support)
    Q = np.zeros((k, k))

    kernels = []
    for i in range(k):
        D = np.zeros(k)
        D[i] = k - 1
        for j in range(k):
            if j != i:
                D[j] = -1
        result = solve_canonical_kernel(model, support, D)
        kernels.append(result["potential"])

    for i in range(k):
        for j in range(k):
            Q[i, j] = kernels[i] @ L @ kernels[j]

    return Q


def prune_pendant_trees(model: MetricGraphModel) -> Tuple[MetricGraphModel, List[int], Dict[int, int]]:
    """Prune pendant trees from the metric graph, reducing to the 2-core.

    Pendant vertices (leaves) and their edges carry no Jacobian freedom
    (by pendant-edge rigidity). This function iteratively removes leaves
    until only the 2-core remains.

    Returns:
        core_model: The pruned 2-core model.
        core_vertices: Original vertex indices of the core.
        leaf_to_attachment: Map from pruned leaf to its attachment vertex.

    Complexity: O(n) where n = |V|.
    """
    n = model.n_vertices
    adj = model.adjacency.copy()
    lengths = model.edge_lengths.copy()
    active = list(range(n))
    leaf_to_attachment = {}

    changed = True
    while changed:
        changed = False
        to_remove = []
        for v in active:
            deg = int(adj[v].sum())
            if deg == 1:
                # Find the unique neighbor
                neighbor = int(np.where(adj[v] > 0)[0][0])
                leaf_to_attachment[v] = neighbor
                to_remove.append(v)
                changed = True
            elif deg == 0 and v in active:
                to_remove.append(v)
                changed = True

        for v in to_remove:
            adj[v, :] = 0
            adj[:, v] = 0
            if v in active:
                active.remove(v)

    if not active:
        # Degenerate: the entire graph is a tree
        active = [0]

    core_vertices = sorted(active)
    k = len(core_vertices)
    idx_map = {v: i for i, v in enumerate(core_vertices)}

    core_adj = np.zeros((k, k))
    core_len = np.zeros((k, k))
    for i, vi in enumerate(core_vertices):
        for j, vj in enumerate(core_vertices):
            core_adj[i, j] = model.adjacency[vi, vj]
            core_len[i, j] = model.edge_lengths[vi, vj]

    core_model = MetricGraphModel(k, core_adj, core_len)
    return core_model, core_vertices, leaf_to_attachment


def subdivide_edge(
    model: MetricGraphModel,
    u: int,
    v: int,
    ratio: float = 0.5
) -> MetricGraphModel:
    """Subdivide edge (u,v) by inserting a new vertex at position ratio ∈ (0,1).

    This is the fundamental refinement operation for resolution-stable
    canonical kernels. The resulting model has one more vertex and one
    more edge.

    Args:
        model: The metric graph model.
        u, v: Endpoints of the edge to subdivide.
        ratio: Position of new vertex (0 = at u, 1 = at v).

    Returns:
        New MetricGraphModel with the subdivided edge.
    """
    assert model.adjacency[u, v] == 1, f"No edge between {u} and {v}"
    assert 0 < ratio < 1

    n = model.n_vertices
    new_n = n + 1
    new_vertex = n

    new_adj = np.zeros((new_n, new_n))
    new_len = np.zeros((new_n, new_n))

    # Copy existing structure
    new_adj[:n, :n] = model.adjacency
    new_len[:n, :n] = model.edge_lengths

    # Remove edge (u, v)
    new_adj[u, v] = new_adj[v, u] = 0
    new_len[u, v] = new_len[v, u] = 0

    # Add edges (u, new) and (new, v)
    orig_length = model.edge_lengths[u, v]
    l1 = orig_length * ratio
    l2 = orig_length * (1 - ratio)

    new_adj[u, new_vertex] = new_adj[new_vertex, u] = 1
    new_adj[new_vertex, v] = new_adj[v, new_vertex] = 1
    new_len[u, new_vertex] = new_len[new_vertex, u] = l1
    new_len[new_vertex, v] = new_len[v, new_vertex] = l2

    return MetricGraphModel(new_n, new_adj, new_len)


def uniform_subdivision(model: MetricGraphModel, n_subdivisions: int) -> MetricGraphModel:
    """Uniformly subdivide all edges n times.

    Each edge is divided into 2^n equal segments by inserting new vertices.

    Args:
        model: The metric graph model.
        n_subdivisions: Number of subdivision rounds.

    Returns:
        Refined MetricGraphModel.
    """
    current = model
    for _ in range(n_subdivisions):
        edges = []
        for i in range(current.n_vertices):
            for j in range(i + 1, current.n_vertices):
                if current.adjacency[i, j] == 1:
                    edges.append((i, j))

        for u, v in edges:
            current = subdivide_edge(current, u, v, 0.5)

    return current


def compute_jacobian_rank(
    model: MetricGraphModel,
    support: List[int]
) -> int:
    """Compute the rank of the S-supported Jacobian quotient.

    For a connected graph with genus g and |S| support points meeting
    every cycle, this should equal g (the first Betti number).

    Returns:
        Rank of the Jacobian quotient.
    """
    L = model.laplacian
    S = support
    k = len(S)

    # The S-restricted Laplacian
    L_S = L[np.ix_(S, S)]

    # The rank of Div^0_S / Prin_S = |S| - 1 - dim(ker(L_S restricted))
    # For connected graphs, this equals min(|S|-1, genus)
    rank = np.linalg.matrix_rank(L_S, tol=1e-10)

    return rank


def test_refinement_convergence(
    model: MetricGraphModel,
    support: List[int],
    max_refinements: int = 4
) -> Dict:
    """Test whether canonical kernels converge under refinement.

    This implements the falsifiable conjecture test: compute kernel matrices
    on progressively finer subdivisions and check for convergence.

    Returns:
        Dictionary with convergence data and potential counterexample flag.
    """
    results = []
    current = model

    for level in range(max_refinements + 1):
        # Map support vertices (they keep their original indices)
        K = compute_kernel_matrix(current, support)
        results.append({
            "level": level,
            "n_vertices": current.n_vertices,
            "kernel_matrix": K.copy(),
        })

        if level < max_refinements:
            current = uniform_subdivision(current, 1)

    # Check convergence
    diffs = []
    for i in range(1, len(results)):
        diff = np.max(np.abs(results[i]["kernel_matrix"] - results[i-1]["kernel_matrix"]))
        diffs.append(diff)

    converging = all(diffs[i] < diffs[i-1] * 1.5 for i in range(1, len(diffs))) if len(diffs) > 1 else True

    return {
        "results": results,
        "diffs": diffs,
        "converging": converging,
        "potential_counterexample": not converging,
    }


if __name__ == "__main__":
    # Example: cycle graph with 4 vertices
    print("=== Cycle Graph C4 ===")
    C4 = build_cycle_graph([1.0, 2.0, 1.5, 0.8])
    print(f"Laplacian:\n{C4.laplacian}")
    print(f"Genus: {C4.genus}")

    support = [0, 1, 2]
    D = np.array([1.0, -1.0, 0.0])
    result = solve_canonical_kernel(C4, support, D)
    print(f"Potential: {result['potential']}")
    print(f"Energy: {result['energy']:.6f}")
    print(f"Certificate: {result['certificate']}")

    print("\n=== Kernel Matrix ===")
    K = compute_kernel_matrix(C4, support)
    print(f"K =\n{K}")

    print("\n=== Pendant Tree Pruning ===")
    lollipop = build_lollipop_graph([1.0, 1.0, 1.0], 2.0)
    core, core_verts, leaves = prune_pendant_trees(lollipop)
    print(f"Original vertices: {lollipop.n_vertices}")
    print(f"Core vertices: {core_verts}")
    print(f"Pruned leaves: {leaves}")

    print("\n=== Refinement Convergence ===")
    conv = test_refinement_convergence(C4, [0, 1], max_refinements=3)
    print(f"Converging: {conv['converging']}")
    for i, d in enumerate(conv['diffs']):
        print(f"  Level {i} -> {i+1}: max diff = {d:.8f}")
