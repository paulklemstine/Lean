#!/usr/bin/env python3
"""
algorithms.py — Tropical Persistent Homology Algorithms

Implements the core algorithms from the research paper with full
docstrings, type hints, and example usage.
"""

import numpy as np
from typing import List, Tuple, Set, Optional


def pairwise_distances(X: np.ndarray) -> np.ndarray:
    """Compute pairwise Euclidean distance matrix.
    
    Args:
        X: Point cloud of shape (n, d).
    
    Returns:
        Distance matrix of shape (n, n).
    
    Time complexity: O(n² d)
    Space complexity: O(n²)
    
    Example:
        >>> X = np.array([[0, 0], [1, 0], [0, 1]])
        >>> D = pairwise_distances(X)
        >>> D[0, 1]  # distance between first two points
        1.0
    """
    diff = X[:, np.newaxis, :] - X[np.newaxis, :, :]
    return np.sqrt(np.sum(diff ** 2, axis=-1))


def vietoris_rips_edges(D: np.ndarray, threshold: float) -> List[Tuple[int, int]]:
    """Build Vietoris-Rips graph edges at a given threshold.
    
    Args:
        D: Distance matrix of shape (n, n).
        threshold: Distance threshold for edge inclusion.
    
    Returns:
        List of edges (i, j) with i < j and D[i,j] <= threshold.
    
    Time complexity: O(n²)
    
    Example:
        >>> D = np.array([[0, 1, 3], [1, 0, 2], [3, 2, 0]])
        >>> vietoris_rips_edges(D, 2.0)
        [(0, 1), (1, 2)]
    """
    n = D.shape[0]
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if D[i, j] <= threshold:
                edges.append((i, j))
    return edges


class UnionFind:
    """Union-Find data structure with path compression and union by rank.
    
    Time complexity per operation: O(α(n)) amortized, where α is the
    inverse Ackermann function.
    """
    
    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.n_components = n
    
    def find(self, x: int) -> int:
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x
    
    def union(self, x: int, y: int) -> bool:
        """Union two elements. Returns True if they were in different components."""
        px, py = self.find(x), self.find(y)
        if px == py:
            return False
        if self.rank[px] < self.rank[py]:
            px, py = py, px
        self.parent[py] = px
        if self.rank[px] == self.rank[py]:
            self.rank[px] += 1
        self.n_components -= 1
        return True


def count_components(n_vertices: int, edges: List[Tuple[int, int]]) -> int:
    """Count connected components of a graph.
    
    Args:
        n_vertices: Number of vertices.
        edges: List of edges (i, j).
    
    Returns:
        Number of connected components.
    
    Time complexity: O(|V| + |E| α(|V|))
    """
    uf = UnionFind(n_vertices)
    for u, v in edges:
        uf.union(u, v)
    return uf.n_components


def tropical_nullity(n_vertices: int, edges: List[Tuple[int, int]]) -> int:
    """Compute tropical nullity (cycle rank) of a graph.
    
    The tropical nullity is defined as:
        tropNullity(G) = |E(G)| + c(G) - |V(G)|
    where c(G) is the number of connected components.
    
    This equals the first Betti number / cycle rank of the graph,
    and coincides with the graph genus for connected graphs.
    
    Args:
        n_vertices: Number of vertices.
        edges: List of edges.
    
    Returns:
        Tropical nullity (non-negative integer).
    
    Time complexity: O(|V| + |E| α(|V|))
    
    Example:
        >>> # Triangle: 3 vertices, 3 edges, 1 component → nullity = 1
        >>> tropical_nullity(3, [(0,1), (1,2), (0,2)])
        1
        >>> # Path: 3 vertices, 2 edges, 1 component → nullity = 0
        >>> tropical_nullity(3, [(0,1), (1,2)])
        0
    """
    cc = count_components(n_vertices, edges)
    return len(edges) + cc - n_vertices


def tropical_barcode_profile(
    D: np.ndarray,
    thresholds: np.ndarray
) -> np.ndarray:
    """Compute the tropical barcode profile of a Vietoris-Rips filtration.
    
    Algorithm:
        1. For each threshold r_i, build the Vietoris-Rips graph G_i
        2. Compute tropNullity(G_i) = |E(G_i)| + c(G_i) - |V|
        3. Output the profile (tropNullity(G_0), ..., tropNullity(G_N))
    
    The profile is guaranteed to be monotone non-decreasing by the
    tropBarcode_monotone theorem.
    
    Args:
        D: Distance matrix of shape (n, n).
        thresholds: Sorted array of threshold values.
    
    Returns:
        Array of tropical nullity values, one per threshold.
    
    Time complexity: O(N · n²) where N = len(thresholds)
    Space complexity: O(n²)
    """
    n = D.shape[0]
    profile = np.zeros(len(thresholds), dtype=int)
    for idx, t in enumerate(thresholds):
        edges = vietoris_rips_edges(D, t)
        profile[idx] = tropical_nullity(n, edges)
    return profile


def tropical_barcode_distance(
    profile1: np.ndarray,
    profile2: np.ndarray
) -> int:
    """Compute the tropical barcode distance between two profiles.
    
    Defined as:
        d_tb(F, H; N) = max_{0 ≤ i ≤ N} |tropBarcode_F(i) - tropBarcode_H(i)|
    
    By the tropBarcodeDist_le_edgePerturbation theorem, this is bounded
    by the maximum edge symmetric difference across all filtration indices.
    
    Args:
        profile1: First tropical barcode profile.
        profile2: Second tropical barcode profile.
    
    Returns:
        Non-negative integer distance.
    """
    return int(np.max(np.abs(profile1.astype(int) - profile2.astype(int))))


def edge_symmetric_difference(
    D1: np.ndarray,
    D2: np.ndarray,
    threshold: float
) -> int:
    """Compute |E(G1) Δ E(G2)| at a given threshold.
    
    Args:
        D1: First distance matrix.
        D2: Second distance matrix.
        threshold: Distance threshold.
    
    Returns:
        Size of the symmetric difference of edge sets.
    """
    edges1 = set(vietoris_rips_edges(D1, threshold))
    edges2 = set(vietoris_rips_edges(D2, threshold))
    return len(edges1.symmetric_difference(edges2))


def graph_laplacian(n_vertices: int, edges: List[Tuple[int, int]]) -> np.ndarray:
    """Compute the combinatorial graph Laplacian.
    
    L(i,i) = deg(i), L(i,j) = -1 if {i,j} is an edge, 0 otherwise.
    
    Args:
        n_vertices: Number of vertices.
        edges: List of edges.
    
    Returns:
        Laplacian matrix of shape (n, n).
    """
    L = np.zeros((n_vertices, n_vertices))
    for u, v in edges:
        L[u, u] += 1
        L[v, v] += 1
        L[u, v] -= 1
        L[v, u] -= 1
    return L


def fiedler_eigenvalue(n_vertices: int, edges: List[Tuple[int, int]]) -> float:
    """Compute the algebraic connectivity (Fiedler value).
    
    The Fiedler value λ₂ is the second smallest eigenvalue of the
    graph Laplacian. It is positive iff the graph is connected.
    
    Args:
        n_vertices: Number of vertices.
        edges: List of edges.
    
    Returns:
        Fiedler eigenvalue (≥ 0).
    """
    L = graph_laplacian(n_vertices, edges)
    eigenvalues = np.sort(np.linalg.eigvalsh(L))
    if len(eigenvalues) < 2:
        return 0.0
    return max(eigenvalues[1], 0.0)


# ---------------------------------------------------------------------------
# Example usage
# ---------------------------------------------------------------------------

if __name__ == '__main__':
    print("=== Tropical Persistent Homology Algorithms ===\n")
    
    # Example 1: Simple triangle
    print("Example 1: Triangle graph (3 vertices, 3 edges)")
    tn = tropical_nullity(3, [(0,1), (1,2), (0,2)])
    print(f"  Tropical nullity = {tn} (expected: 1, one independent cycle)\n")
    
    # Example 2: Point cloud
    print("Example 2: Random point cloud in R²")
    rng = np.random.RandomState(42)
    X = rng.randn(10, 2)
    D = pairwise_distances(X)
    thresholds = np.linspace(0, np.max(D) * 0.6, 15)
    profile = tropical_barcode_profile(D, thresholds)
    print(f"  Thresholds: {np.round(thresholds, 2)}")
    print(f"  Profile:    {profile}")
    print(f"  Monotone:   {all(profile[i] <= profile[i+1] for i in range(len(profile)-1))}\n")
    
    # Example 3: Stability
    print("Example 3: Perturbation stability")
    noise = rng.randn(10, 2) * 0.1
    X_pert = X + noise
    D_pert = pairwise_distances(X_pert)
    profile_pert = tropical_barcode_profile(D_pert, thresholds)
    dist = tropical_barcode_distance(profile, profile_pert)
    max_sd = max(edge_symmetric_difference(D, D_pert, t) for t in thresholds)
    print(f"  Tropical barcode distance: {dist}")
    print(f"  Max edge symm. diff:       {max_sd}")
    print(f"  Stability holds: {dist <= max_sd}")
