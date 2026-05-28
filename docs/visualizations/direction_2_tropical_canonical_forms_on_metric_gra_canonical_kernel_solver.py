"""
Canonical Kernel Solver on Metric Graph Models

Implements the verified computational pipeline for tropical canonical forms:
- Weighted Laplacian construction from edge lengths
- Canonical kernel generator computation
- S-supported Jacobian quotient calculation
- Pendant-tree pruning reduction
- Dirichlet energy computation

The algorithm solves for normalized harmonic representatives on finite
metric graph models, computing the canonical kernel matrix and energy pairing.
"""

import numpy as np
from typing import List, Tuple, Dict, Optional, Set
from dataclasses import dataclass, field


@dataclass
class MetricGraphModel:
    """A finite metric graph model: vertices, edges with positive lengths.

    Attributes:
        n_vertices: Number of vertices
        edges: List of (i, j, length) triples
        adj: Adjacency dict mapping vertex -> list of (neighbor, edge_length)
    """
    n_vertices: int
    edges: List[Tuple[int, int, float]]
    adj: Dict[int, List[Tuple[int, float]]] = field(default_factory=dict)

    def __post_init__(self):
        self.adj = {i: [] for i in range(self.n_vertices)}
        for i, j, length in self.edges:
            assert length > 0, f"Edge length must be positive, got {length}"
            self.adj[i].append((j, length))
            self.adj[j].append((i, length))

    def degree(self, v: int) -> int:
        """Degree of vertex v."""
        return len(self.adj[v])

    def is_leaf(self, v: int) -> bool:
        """Whether v is a leaf (degree 1)."""
        return self.degree(v) == 1

    def leaves(self) -> List[int]:
        """All leaf vertices."""
        return [v for v in range(self.n_vertices) if self.is_leaf(v)]

    def conductance(self, i: int, j: int) -> float:
        """Conductance weight = 1/length for adjacent vertices."""
        for nb, length in self.adj[i]:
            if nb == j:
                return 1.0 / length
        return 0.0


def build_weighted_laplacian(M: MetricGraphModel) -> np.ndarray:
    """Build the weighted Laplacian matrix L with conductance weights.

    L(i,i) = sum of conductances of incident edges
    L(i,j) = -conductance(i,j) if i ~ j
    L(i,j) = 0 otherwise

    Args:
        M: A metric graph model

    Returns:
        n×n numpy array, the weighted Laplacian matrix

    Time complexity: O(n + m) where m = number of edges
    Space complexity: O(n²)
    """
    n = M.n_vertices
    L = np.zeros((n, n))
    for i, j, length in M.edges:
        c = 1.0 / length
        L[i, j] = -c
        L[j, i] = -c
        L[i, i] += c
        L[j, j] += c
    return L


def solve_normalized_kernel(
    M: MetricGraphModel,
    S: List[int],
    D: np.ndarray,
    normalization: str = "mean_zero"
) -> Optional[np.ndarray]:
    """Solve for the unique normalized vertex potential f such that:
    - f is harmonic on V \\ S (i.e., Lf(v) = 0 for v not in S)
    - Lf restricted to S equals D
    - f satisfies the chosen normalization

    Args:
        M: Metric graph model
        S: Support set (list of vertex indices)
        D: Degree-zero divisor supported on S (array of length |S|)
        normalization: "mean_zero" for sum(f) = 0

    Returns:
        Vertex potential f as numpy array, or None if no solution exists

    Time complexity: O(n³) for the linear solve
    Space complexity: O(n²)
    """
    n = M.n_vertices
    L = build_weighted_laplacian(M)

    # Check degree zero
    if abs(np.sum(D)) > 1e-10:
        return None

    S_set = set(S)
    S_comp = [v for v in range(n) if v not in S_set]

    # Build the system: Lf = D_extended
    # where D_extended(v) = D[S.index(v)] if v in S, else 0
    # But we also need harmonicity on S^c: Lf(v) = 0 for v not in S
    # This is automatically satisfied by Lf = D_extended

    # The full system is Lf = b where b(v) = D[idx] if v in S, 0 otherwise
    b = np.zeros(n)
    for idx, v in enumerate(S):
        b[v] = D[idx]

    # Add mean-zero constraint: replace last row with all-ones
    A = L.copy()
    A[-1, :] = 1.0
    b[-1] = 0.0

    try:
        f = np.linalg.solve(A, b)
        return f
    except np.linalg.LinAlgError:
        return None


def compute_canonical_kernel_matrix(
    M: MetricGraphModel,
    S: List[int]
) -> np.ndarray:
    """Compute the canonical kernel matrix K on support set S.

    For each s in S, compute the normalized kernel generator k_s:
    the unique mean-zero function harmonic on V\\S with unit source at s
    and distributed sink at s₀ (the first element of S).

    The kernel matrix K[i,j] = k_{S[i]}(S[j]).

    Args:
        M: Metric graph model
        S: Support set (list of vertex indices)

    Returns:
        |S| × |S| kernel matrix

    Time complexity: O(|S| · n³)
    Space complexity: O(n² + |S|²)
    """
    m = len(S)
    K = np.zeros((m, m))

    for idx in range(1, m):
        # Unit source at S[idx], unit sink at S[0]
        D = np.zeros(m)
        D[idx] = 1.0
        D[0] = -1.0

        f = solve_normalized_kernel(M, S, D)
        if f is not None:
            for j in range(m):
                K[idx, j] = f[S[j]]

    return K


def compute_dirichlet_energy(M: MetricGraphModel, f: np.ndarray) -> float:
    """Compute the Dirichlet energy E(f) = f^T L f = (1/2) sum_{i~j} c(i,j)(f(i)-f(j))².

    This is the total power dissipation in the electrical network interpretation.

    Args:
        M: Metric graph model
        f: Vertex potential

    Returns:
        Non-negative real number

    Time complexity: O(m) where m = number of edges
    """
    energy = 0.0
    for i, j, length in M.edges:
        c = 1.0 / length
        energy += c * (f[i] - f[j]) ** 2
    return energy / 2.0


def compute_energy_pairing(
    M: MetricGraphModel,
    S: List[int]
) -> np.ndarray:
    """Compute the energy pairing matrix Q on kernel generators.

    Q[i,j] = B(k_i, k_j) where B is the energy bilinear form
    and k_i are canonical kernel generators.

    This matrix descends to the tropical polarization on the Jacobian.

    Args:
        M: Metric graph model
        S: Support set

    Returns:
        (|S|-1) × (|S|-1) symmetric positive semidefinite matrix
    """
    m = len(S)
    K_generators = []

    for idx in range(1, m):
        D = np.zeros(m)
        D[idx] = 1.0
        D[0] = -1.0
        f = solve_normalized_kernel(M, S, D)
        if f is not None:
            K_generators.append(f)

    r = len(K_generators)
    Q = np.zeros((r, r))
    L = build_weighted_laplacian(M)

    for i in range(r):
        for j in range(r):
            Q[i, j] = K_generators[i] @ L @ K_generators[j]

    return Q


def prune_pendant_trees(M: MetricGraphModel) -> Tuple[MetricGraphModel, Dict[int, int]]:
    """Prune all pendant trees from the graph, returning the 2-core.

    This implements the core-pruning reduction: pendant trees carry no
    independent Jacobian classes, so they can be removed without changing
    the Jacobian structure. Harmonic functions are constant on pruned edges.

    Args:
        M: Metric graph model

    Returns:
        (core_model, vertex_map) where vertex_map maps core vertex indices
        to original vertex indices

    Time complexity: O(n + m)
    """
    n = M.n_vertices
    degree = [M.degree(v) for v in range(n)]
    removed = [False] * n

    # Iteratively remove leaves
    queue = [v for v in range(n) if degree[v] <= 1]
    while queue:
        v = queue.pop()
        if removed[v]:
            continue
        if degree[v] > 1:
            continue
        removed[v] = True
        for nb, _ in M.adj[v]:
            if not removed[nb]:
                degree[nb] -= 1
                if degree[nb] <= 1:
                    queue.append(nb)

    # Build core model
    core_vertices = [v for v in range(n) if not removed[v]]
    if len(core_vertices) == 0:
        # Graph is a tree - core is empty, Jacobian is trivial
        return MetricGraphModel(0, []), {}

    vertex_map = {new_idx: old_idx for new_idx, old_idx in enumerate(core_vertices)}
    inv_map = {old_idx: new_idx for new_idx, old_idx in enumerate(core_vertices)}

    core_edges = []
    seen = set()
    for i, j, length in M.edges:
        if not removed[i] and not removed[j]:
            edge_key = (min(i, j), max(i, j))
            if edge_key not in seen:
                seen.add(edge_key)
                core_edges.append((inv_map[i], inv_map[j], length))

    core_model = MetricGraphModel(len(core_vertices), core_edges)
    return core_model, vertex_map


def compute_jacobian_rank(M: MetricGraphModel, S: List[int]) -> int:
    """Compute the rank of the S-supported Jacobian quotient.

    For a connected graph, this equals min(|S|-1, first_betti_number).

    Args:
        M: Metric graph model
        S: Support set

    Returns:
        Rank of the Jacobian quotient
    """
    L = build_weighted_laplacian(M)

    # Extract the S-restricted Laplacian
    S_arr = np.array(S)
    L_S = L[np.ix_(S_arr, S_arr)]

    # Rank = number of non-zero eigenvalues
    eigenvalues = np.linalg.eigvalsh(L_S)
    rank = np.sum(np.abs(eigenvalues) > 1e-10)
    return int(rank)


def first_betti_number(M: MetricGraphModel) -> int:
    """Compute the first Betti number (cycle rank) of the graph.

    β₁ = |E| - |V| + number of connected components

    For a connected graph, β₁ = |E| - |V| + 1.
    """
    n_edges = len(M.edges)
    # Count connected components via BFS
    visited = [False] * M.n_vertices
    components = 0
    for start in range(M.n_vertices):
        if visited[start]:
            continue
        components += 1
        queue = [start]
        visited[start] = True
        while queue:
            v = queue.pop()
            for nb, _ in M.adj[v]:
                if not visited[nb]:
                    visited[nb] = True
                    queue.append(nb)
    return n_edges - M.n_vertices + components


def subdivide_edge(
    M: MetricGraphModel,
    edge_idx: int,
    n_subdivisions: int = 1
) -> MetricGraphModel:
    """Subdivide a single edge into n_subdivisions + 1 equal parts.

    Args:
        M: Original metric graph model
        edge_idx: Index of the edge to subdivide
        n_subdivisions: Number of new vertices to insert

    Returns:
        New metric graph model with the edge subdivided
    """
    i, j, length = M.edges[edge_idx]
    new_length = length / (n_subdivisions + 1)

    # Keep all other edges
    new_edges = [e for idx, e in enumerate(M.edges) if idx != edge_idx]

    # Add new vertices and edges
    n = M.n_vertices
    prev = i
    for k in range(n_subdivisions):
        new_v = n + k
        new_edges.append((prev, new_v, new_length))
        prev = new_v
    new_edges.append((prev, j, new_length))

    return MetricGraphModel(n + n_subdivisions, new_edges)


def uniform_subdivision(M: MetricGraphModel, n_per_edge: int) -> MetricGraphModel:
    """Uniformly subdivide all edges, inserting n_per_edge new vertices per edge.

    Args:
        M: Original metric graph model
        n_per_edge: Number of subdivision points per edge

    Returns:
        Subdivided metric graph model
    """
    new_edges = []
    n = M.n_vertices
    next_v = n

    for i, j, length in M.edges:
        seg_length = length / (n_per_edge + 1)
        prev = i
        for _ in range(n_per_edge):
            new_edges.append((prev, next_v, seg_length))
            prev = next_v
            next_v += 1
        new_edges.append((prev, j, seg_length))

    return MetricGraphModel(next_v, new_edges)


# ─── Example graph constructors ───────────────────────────────────────────

def cycle_graph(n: int, lengths: Optional[List[float]] = None) -> MetricGraphModel:
    """Construct a cycle graph C_n with given edge lengths.

    Args:
        n: Number of vertices
        lengths: Edge lengths (default: all 1.0)
    """
    if lengths is None:
        lengths = [1.0] * n
    assert len(lengths) == n
    edges = [(i, (i + 1) % n, lengths[i]) for i in range(n)]
    return MetricGraphModel(n, edges)


def theta_graph(l1: float, l2: float, l3: float) -> MetricGraphModel:
    """Construct a theta graph: two vertices connected by three paths.

    The three paths have lengths l1, l2, l3 respectively.
    Each path is a single edge (the metric is encoded in edge lengths).

    Args:
        l1, l2, l3: Lengths of the three paths
    """
    # Vertices 0 and 1, connected by three edges
    # We need intermediate vertices for multi-edges in a simple graph
    edges = [
        (0, 2, l1 / 2), (2, 1, l1 / 2),  # path 1 through vertex 2
        (0, 3, l2 / 2), (3, 1, l2 / 2),  # path 2 through vertex 3
        (0, 4, l3 / 2), (4, 1, l3 / 2),  # path 3 through vertex 4
    ]
    return MetricGraphModel(5, edges)


def lollipop_graph(
    cycle_size: int,
    stick_length: float,
    cycle_lengths: Optional[List[float]] = None
) -> MetricGraphModel:
    """Construct a lollipop graph: a cycle with a pendant path attached.

    Args:
        cycle_size: Number of vertices in the cycle
        stick_length: Length of the pendant edge
        cycle_lengths: Edge lengths in the cycle (default: all 1.0)
    """
    if cycle_lengths is None:
        cycle_lengths = [1.0] * cycle_size

    edges = [(i, (i + 1) % cycle_size, cycle_lengths[i]) for i in range(cycle_size)]
    # Attach pendant edge at vertex 0
    edges.append((0, cycle_size, stick_length))
    return MetricGraphModel(cycle_size + 1, edges)


if __name__ == "__main__":
    print("=== Canonical Kernel Solver Demo ===\n")

    # Cycle graph example
    M = cycle_graph(4, [1.0, 2.0, 1.0, 2.0])
    S = [0, 1, 2, 3]
    print(f"Cycle graph C_4 with lengths [1, 2, 1, 2]")
    print(f"  Betti number: {first_betti_number(M)}")

    L = build_weighted_laplacian(M)
    print(f"  Weighted Laplacian:\n{np.round(L, 4)}\n")

    K = compute_canonical_kernel_matrix(M, S)
    print(f"  Canonical kernel matrix:\n{np.round(K, 4)}\n")

    Q = compute_energy_pairing(M, S)
    print(f"  Energy pairing matrix:\n{np.round(Q, 4)}\n")

    # Lollipop - pendant pruning
    M_lol = lollipop_graph(3, 5.0)
    print(f"Lollipop graph (triangle + pendant of length 5)")
    print(f"  Original Betti number: {first_betti_number(M_lol)}")

    core, vmap = prune_pendant_trees(M_lol)
    print(f"  Core vertices: {list(vmap.values())}")
    print(f"  Core Betti number: {first_betti_number(core)}")
