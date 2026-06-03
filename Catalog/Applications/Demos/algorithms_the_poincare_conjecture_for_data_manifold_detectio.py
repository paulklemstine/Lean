"""
Algorithms for Manifold Detection via Persistent Homology

Implements the Vietoris-Rips complex construction, Betti number estimation,
and Poincaré threshold computation for point cloud data.
"""

from typing import List, Tuple, Set, FrozenSet, Optional
import numpy as np
from itertools import combinations
from collections import defaultdict


def pairwise_distances(points: np.ndarray) -> np.ndarray:
    """Compute the pairwise distance matrix for a point cloud.

    Args:
        points: (n, d) array of n points in R^d

    Returns:
        (n, n) symmetric distance matrix
    """
    diff = points[:, np.newaxis, :] - points[np.newaxis, :, :]
    return np.sqrt(np.sum(diff ** 2, axis=-1))


def vietoris_rips_edges(dist_matrix: np.ndarray, epsilon: float) -> List[Tuple[int, int]]:
    """Compute the 1-skeleton (edge list) of the Vietoris-Rips complex.

    Args:
        dist_matrix: (n, n) pairwise distance matrix
        epsilon: scale parameter

    Returns:
        List of edges (i, j) with i < j and dist(i, j) <= epsilon
    """
    n = dist_matrix.shape[0]
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if dist_matrix[i, j] <= epsilon:
                edges.append((i, j))
    return edges


def vietoris_rips_complex(dist_matrix: np.ndarray, epsilon: float,
                          max_dim: int = 2) -> List[FrozenSet[int]]:
    """Construct the Vietoris-Rips complex up to given dimension.

    A simplex sigma is included iff all pairwise distances in sigma are <= epsilon.

    Args:
        dist_matrix: (n, n) pairwise distance matrix
        epsilon: scale parameter
        max_dim: maximum simplex dimension to compute

    Returns:
        List of simplices (as frozensets of vertex indices)
    """
    n = dist_matrix.shape[0]
    simplices: List[FrozenSet[int]] = []

    # Add vertices
    for i in range(n):
        simplices.append(frozenset([i]))

    # Build clique complex from edges
    edges = vietoris_rips_edges(dist_matrix, epsilon)
    adj: dict[int, Set[int]] = defaultdict(set)
    for i, j in edges:
        adj[i].add(j)
        adj[j].add(i)
        simplices.append(frozenset([i, j]))

    # Extend to higher simplices by finding cliques
    if max_dim >= 2:
        for i, j in edges:
            common = adj[i] & adj[j]
            for k in common:
                if k > j:
                    simplices.append(frozenset([i, j, k]))
                    if max_dim >= 3:
                        for l in adj[i] & adj[j] & adj[k]:
                            if l > k:
                                simplices.append(frozenset([i, j, k, l]))

    return simplices


def connected_components(n: int, edges: List[Tuple[int, int]]) -> int:
    """Count connected components using union-find.

    Args:
        n: number of vertices
        edges: list of edges

    Returns:
        Number of connected components (= beta_0)
    """
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

    for i, j in edges:
        union(i, j)

    return len(set(find(i) for i in range(n)))


def euler_characteristic(simplices: List[FrozenSet[int]]) -> int:
    """Compute the Euler characteristic from a list of simplices.

    chi = sum_{k>=0} (-1)^k * f_k where f_k = number of k-simplices.

    Args:
        simplices: list of simplices

    Returns:
        Euler characteristic
    """
    chi = 0
    for s in simplices:
        dim = len(s) - 1
        chi += (-1) ** dim
    return chi


def estimate_betti_numbers(dist_matrix: np.ndarray, epsilon: float,
                           max_dim: int = 2) -> List[int]:
    """Estimate Betti numbers of the Vietoris-Rips complex.

    Uses connected components for beta_0 and Euler characteristic relations.

    Args:
        dist_matrix: (n, n) pairwise distance matrix
        epsilon: scale parameter
        max_dim: maximum dimension

    Returns:
        List [beta_0, beta_1, ...] of estimated Betti numbers
    """
    n = dist_matrix.shape[0]
    edges = vietoris_rips_edges(dist_matrix, epsilon)
    simplices = vietoris_rips_complex(dist_matrix, epsilon, max_dim)

    beta_0 = connected_components(n, edges)

    # Count simplices by dimension
    f_vector = defaultdict(int)
    for s in simplices:
        f_vector[len(s) - 1] += 1

    # For dimension 1: beta_1 = f_1 - f_0 + beta_0 (from Euler char)
    # More precisely: chi = beta_0 - beta_1 + beta_2 - ...
    chi = euler_characteristic(simplices)

    betti = [beta_0]
    if max_dim >= 1:
        # beta_1 = beta_0 - chi + beta_2 - beta_3 + ...
        # Approximate: beta_1 = beta_0 - chi (ignoring higher)
        beta_1 = max(0, beta_0 - chi)
        betti.append(beta_1)

    if max_dim >= 2:
        # beta_2 from Euler relation
        beta_2 = max(0, chi - beta_0 + betti[1])
        betti.append(beta_2)

    return betti


def poincare_threshold(dist_matrix: np.ndarray, d: int,
                       epsilon_range: Optional[np.ndarray] = None,
                       n_steps: int = 100) -> Tuple[float, List[Tuple[float, List[int]]]]:
    """Compute the Poincaré threshold: smallest epsilon where VR has S^d homology.

    S^d homology means beta_0 = 1, beta_d = 1, and beta_k = 0 for 0 < k < d.

    Args:
        dist_matrix: (n, n) pairwise distance matrix
        d: expected manifold dimension
        epsilon_range: range of epsilon values to search
        n_steps: number of epsilon values to try

    Returns:
        (threshold, profile) where profile is [(epsilon, betti_numbers), ...]
    """
    if epsilon_range is None:
        max_dist = np.max(dist_matrix)
        epsilon_range = np.linspace(0.01 * max_dist, max_dist, n_steps)

    profile = []
    threshold = float('inf')

    for eps in epsilon_range:
        betti = estimate_betti_numbers(dist_matrix, eps, max_dim=max(d, 2))
        profile.append((eps, betti))

        # Check sphere-like homology
        if len(betti) > d:
            is_sphere = (betti[0] == 1 and
                         betti[d] == 1 if d < len(betti) else False)
            if d > 1:
                is_sphere = is_sphere and all(betti[k] == 0
                                              for k in range(1, min(d, len(betti))))
            if is_sphere and eps < threshold:
                threshold = eps

    return threshold, profile


def predicted_threshold(n: int, d: int, C: float = 1.0) -> float:
    """Compute the predicted Poincaré threshold: C * sqrt(d) * n^{-1/d}.

    Args:
        n: number of points
        d: manifold dimension
        C: scaling constant

    Returns:
        Predicted threshold value
    """
    return C * np.sqrt(d) * n ** (-1.0 / d)


def sample_sphere(n: int, d: int) -> np.ndarray:
    """Sample n points uniformly from the unit d-sphere S^d in R^{d+1}.

    Args:
        n: number of points
        d: dimension of the sphere (lives in R^{d+1})

    Returns:
        (n, d+1) array of points on S^d
    """
    points = np.random.randn(n, d + 1)
    norms = np.linalg.norm(points, axis=1, keepdims=True)
    return points / norms


def covering_number_estimate(dist_matrix: np.ndarray, epsilon: float) -> int:
    """Estimate the covering number N(X, epsilon) using a greedy algorithm.

    Args:
        dist_matrix: (n, n) pairwise distance matrix
        epsilon: covering radius

    Returns:
        Size of the greedy cover (upper bound on covering number)
    """
    n = dist_matrix.shape[0]
    covered = np.zeros(n, dtype=bool)
    centers = []

    for i in range(n):
        if not covered[i]:
            centers.append(i)
            covered |= (dist_matrix[i] <= epsilon)

    return len(centers)
