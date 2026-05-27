"""
Algorithms for Certificate Complexity of Graphic Matroids

Implements:
1. Kirchhoff's Matrix Tree Theorem (spanning tree count via Laplacian determinant)
2. Certificate complexity lower bound via information-theoretic argument
3. Matroid independence oracle (acyclicity test)
4. Random graph generation (Erdős–Rényi model)
"""

import numpy as np
from typing import List, Tuple, Set, Optional
import math


def adjacency_matrix(n: int, edges: List[Tuple[int, int]]) -> np.ndarray:
    """Compute the adjacency matrix of a graph.

    Args:
        n: Number of vertices (labeled 0..n-1).
        edges: List of (u, v) edges.

    Returns:
        n×n symmetric adjacency matrix.
    """
    A = np.zeros((n, n), dtype=float)
    for u, v in edges:
        A[u][v] = 1.0
        A[v][u] = 1.0
    return A


def laplacian_matrix(n: int, edges: List[Tuple[int, int]]) -> np.ndarray:
    """Compute the Laplacian matrix L = D - A.

    Args:
        n: Number of vertices.
        edges: List of edges.

    Returns:
        n×n Laplacian matrix.
    """
    A = adjacency_matrix(n, edges)
    D = np.diag(A.sum(axis=1))
    return D - A


def spanning_tree_count(n: int, edges: List[Tuple[int, int]]) -> float:
    """Compute the number of spanning trees using Kirchhoff's Matrix Tree Theorem.

    The number of spanning trees equals any cofactor of the Laplacian matrix,
    which equals the determinant of the reduced Laplacian (any row and column deleted).

    Args:
        n: Number of vertices.
        edges: List of edges.

    Returns:
        Number of spanning trees (as float for large values).
        Returns 0 if the graph is disconnected.

    Complexity: O(n³) for the determinant computation.

    Example:
        >>> # Complete graph K4 has 4^2 = 16 spanning trees
        >>> edges = [(i, j) for i in range(4) for j in range(i+1, 4)]
        >>> spanning_tree_count(4, edges)
        16.0
    """
    if n <= 1:
        return 1.0
    L = laplacian_matrix(n, edges)
    # Delete first row and column to get reduced Laplacian
    L_reduced = L[1:, 1:]
    det = np.linalg.det(L_reduced)
    return max(0.0, round(det, 6))


def cert_complexity_lower_bound(n: int, edges: List[Tuple[int, int]]) -> float:
    """Compute a lower bound on certificate complexity via the information-theoretic bound.

    By Theorem 5.2, cert_complexity >= log2(spanning_tree_count).
    Each edge query reveals 1 bit, so we need at least log2(τ(G)) queries
    to distinguish all spanning trees.

    Args:
        n: Number of vertices.
        edges: List of edges.

    Returns:
        Lower bound on certificate complexity (log2 of spanning tree count).

    Example:
        >>> edges = [(i, j) for i in range(4) for j in range(i+1, 4)]
        >>> cert_complexity_lower_bound(4, edges)  # log2(16) = 4.0
        4.0
    """
    tau = spanning_tree_count(n, edges)
    if tau <= 0:
        return 0.0
    return math.log2(tau)


def is_acyclic(n: int, edges: List[Tuple[int, int]]) -> bool:
    """Test if a graph is acyclic (a forest) using DFS.

    This is the independence oracle for the graphic matroid: a set of edges
    is independent iff it forms a forest (no cycles).

    Args:
        n: Number of vertices.
        edges: List of edges.

    Returns:
        True if the graph is acyclic.

    Complexity: O(n + |edges|).

    Example:
        >>> is_acyclic(4, [(0,1), (1,2), (2,3)])  # Path = tree = acyclic
        True
        >>> is_acyclic(3, [(0,1), (1,2), (2,0)])  # Triangle = cycle
        False
    """
    adj: dict[int, list[int]] = {i: [] for i in range(n)}
    for u, v in edges:
        adj[u].append(v)
        adj[v].append(u)

    visited = [False] * n
    for start in range(n):
        if visited[start]:
            continue
        stack = [(start, -1)]
        while stack:
            node, parent = stack.pop()
            if visited[node]:
                return False  # Cycle detected
            visited[node] = True
            for neighbor in adj[node]:
                if not visited[neighbor]:
                    stack.append((neighbor, node))
                elif neighbor != parent:
                    return False  # Cycle detected
    return True


def is_connected(n: int, edges: List[Tuple[int, int]]) -> bool:
    """Test if a graph is connected using BFS.

    Args:
        n: Number of vertices.
        edges: List of edges.

    Returns:
        True if the graph is connected.

    Example:
        >>> is_connected(3, [(0,1), (1,2)])
        True
        >>> is_connected(3, [(0,1)])
        False
    """
    if n <= 1:
        return True
    adj: dict[int, list[int]] = {i: [] for i in range(n)}
    for u, v in edges:
        adj[u].append(v)
        adj[v].append(u)

    visited = set([0])
    queue = [0]
    while queue:
        node = queue.pop(0)
        for neighbor in adj[node]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)
    return len(visited) == n


def generate_gnp(n: int, p: float, rng: Optional[np.random.Generator] = None) -> List[Tuple[int, int]]:
    """Generate an Erdős–Rényi random graph G(n, p).

    Each potential edge is included independently with probability p.

    Args:
        n: Number of vertices.
        p: Edge probability.
        rng: Random number generator (optional).

    Returns:
        List of edges.

    Example:
        >>> rng = np.random.default_rng(42)
        >>> edges = generate_gnp(10, 0.3, rng)
        >>> len(edges)  # Approximately 0.3 * C(10,2) = 13.5
        15
    """
    if rng is None:
        rng = np.random.default_rng()
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j))
    return edges


def circuit_rank(n: int, edges: List[Tuple[int, int]]) -> int:
    """Compute the circuit rank (cyclomatic number) of a graph.

    The circuit rank = |E| - |V| + c, where c is the number of connected components.
    For a connected graph, circuit rank = |E| - |V| + 1.
    This equals the dimension of the cycle space.

    Args:
        n: Number of vertices.
        edges: List of edges.

    Returns:
        Circuit rank.

    Example:
        >>> circuit_rank(4, [(0,1), (1,2), (2,3), (3,0)])  # Square: 4-4+1=1
        1
        >>> circuit_rank(4, [(0,1), (1,2), (2,0), (2,3)])  # Triangle+edge: 4-4+1=1
        1
    """
    # Count connected components via union-find
    parent = list(range(n))

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> None:
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py

    for u, v in edges:
        union(u, v)

    num_components = len(set(find(i) for i in range(n)))
    return len(edges) - n + num_components


def matroid_rank(n: int, edges: List[Tuple[int, int]], subset: List[Tuple[int, int]]) -> int:
    """Compute the rank of an edge subset in the graphic matroid.

    The rank of S in M(G) is the size of the largest forest in S,
    which equals |V(S)| - c(S) where c(S) is the number of connected
    components of the subgraph induced by S.

    Args:
        n: Number of vertices.
        edges: List of all graph edges (for context).
        subset: Subset of edges to compute rank for.

    Returns:
        Matroid rank of the subset.

    Example:
        >>> edges = [(0,1), (1,2), (2,0)]
        >>> matroid_rank(3, edges, edges)  # Triangle: rank = 3-1 = 2
        2
    """
    # Find vertices involved
    vertices = set()
    for u, v in subset:
        vertices.add(u)
        vertices.add(v)
    if not vertices:
        return 0

    # Count components using union-find
    parent = {v: v for v in vertices}

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    components = len(vertices)
    for u, v in subset:
        pu, pv = find(u), find(v)
        if pu != pv:
            parent[pu] = pv
            components -= 1

    return len(vertices) - components


if __name__ == "__main__":
    print("=== Certificate Complexity Algorithms ===\n")

    # Example 1: Complete graph K5
    n = 5
    edges = [(i, j) for i in range(n) for j in range(i+1, n)]
    tau = spanning_tree_count(n, edges)
    lb = cert_complexity_lower_bound(n, edges)
    cr = circuit_rank(n, edges)
    print(f"K5: {len(edges)} edges, τ(G) = {tau:.0f}, cert_complexity ≥ {lb:.2f}, circuit_rank = {cr}")

    # Example 2: Path graph P5
    path_edges = [(i, i+1) for i in range(n-1)]
    tau_path = spanning_tree_count(n, path_edges)
    lb_path = cert_complexity_lower_bound(n, path_edges)
    print(f"P5: {len(path_edges)} edges, τ(G) = {tau_path:.0f}, cert_complexity ≥ {lb_path:.2f}")

    # Example 3: Random graph
    rng = np.random.default_rng(42)
    p = 2.0 * math.log(20) / 20
    rand_edges = generate_gnp(20, p, rng)
    tau_rand = spanning_tree_count(20, rand_edges)
    lb_rand = cert_complexity_lower_bound(20, rand_edges)
    conn = is_connected(20, rand_edges)
    print(f"G(20, 2ln(20)/20): {len(rand_edges)} edges, connected={conn}, "
          f"τ(G) = {tau_rand:.2e}, cert_complexity ≥ {lb_rand:.2f}")
