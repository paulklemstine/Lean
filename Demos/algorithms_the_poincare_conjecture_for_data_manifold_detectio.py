#!/usr/bin/env python3
"""
Algorithms for the Poincaré Conjecture for Data.

Type-hinted implementations of the core algorithms for manifold detection
via persistent homology of Vietoris-Rips complexes.
"""

from typing import Dict, List, Set, Tuple, Optional
import numpy as np
from itertools import combinations
from collections import defaultdict


def generate_sphere_points(n: int, d: int, seed: Optional[int] = None) -> np.ndarray:
    """Generate n points uniformly on the unit d-sphere S^d ⊂ R^{d+1}.

    Algorithm: Sample from N(0, I_{d+1}) and project to the unit sphere.
    This produces uniform distribution on S^d by rotational invariance of Gaussian.

    Args:
        n: Number of points
        d: Dimension of sphere (embedded in R^{d+1})
        seed: Random seed for reproducibility

    Returns:
        Array of shape (n, d+1) with each row on the unit sphere
    """
    rng = np.random.default_rng(seed)
    X = rng.standard_normal((n, d + 1))
    norms = np.linalg.norm(X, axis=1, keepdims=True)
    return X / norms


def pairwise_distance_matrix(X: np.ndarray) -> np.ndarray:
    """Compute the full pairwise distance matrix.

    Args:
        X: Point cloud, shape (n, d)

    Returns:
        Distance matrix D where D[i,j] = ||X[i] - X[j]||
    """
    n = X.shape[0]
    diff = X[:, np.newaxis, :] - X[np.newaxis, :, :]
    return np.sqrt(np.sum(diff ** 2, axis=-1))


def vietoris_rips_complex(
    D: np.ndarray, epsilon: float, max_dim: int = 3
) -> Dict[int, List[Tuple[int, ...]]]:
    """Build the Vietoris-Rips complex at scale epsilon.

    A k-simplex {v_0, ..., v_k} is included iff all pairwise distances ≤ epsilon.

    Pseudocode:
        for k = 0 to max_dim:
            for each (k+1)-subset S of vertices:
                if max_{i,j in S} d(i,j) <= epsilon:
                    add S as a k-simplex

    Args:
        D: Pairwise distance matrix
        epsilon: Scale parameter
        max_dim: Maximum simplex dimension to compute

    Returns:
        Dict mapping dimension k to list of k-simplices (as tuples of vertex indices)
    """
    n = D.shape[0]
    simplices: Dict[int, List[Tuple[int, ...]]] = defaultdict(list)

    for i in range(n):
        simplices[0].append((i,))

    for k in range(1, min(max_dim + 1, n)):
        for subset in combinations(range(n), k + 1):
            if all(D[i][j] <= epsilon for i, j in combinations(subset, 2)):
                simplices[k].append(subset)

    return dict(simplices)


def euler_characteristic(simplices: Dict[int, List[Tuple[int, ...]]]) -> int:
    """Compute the Euler characteristic χ = Σ_k (-1)^k · f_k.

    This is a topological invariant computable from the face counts.
    For S^d: χ = 1 + (-1)^d (proved formally in our Lean formalization).

    Args:
        simplices: Dict mapping dimension to list of simplices

    Returns:
        The Euler characteristic (integer)
    """
    return sum((-1) ** k * len(faces) for k, faces in simplices.items())


class UnionFind:
    """Union-Find data structure for computing connected components."""

    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.num_components = n

    def find(self, x: int) -> int:
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, x: int, y: int) -> bool:
        px, py = self.find(x), self.find(y)
        if px == py:
            return False
        if self.rank[px] < self.rank[py]:
            px, py = py, px
        self.parent[py] = px
        if self.rank[px] == self.rank[py]:
            self.rank[px] += 1
        self.num_components -= 1
        return True


def connectivity_threshold(D: np.ndarray) -> float:
    """Compute the connectivity threshold (minimum spanning tree diameter).

    This is the Poincaré threshold for H_0: the smallest epsilon such that
    the VR graph is connected.

    Algorithm: Kruskal's MST algorithm — sort edges by weight, add until
    the graph becomes connected.

    Pseudocode:
        Sort all edges (i,j) by distance d(i,j)
        Initialize Union-Find on n vertices
        For each edge (i,j) in sorted order:
            If i,j in different components:
                Union(i,j)
                Update threshold = d(i,j)
                If 1 component remains: return threshold

    Args:
        D: Pairwise distance matrix

    Returns:
        The connectivity threshold epsilon_star
    """
    n = D.shape[0]
    if n <= 1:
        return 0.0

    edges: List[Tuple[float, int, int]] = []
    for i in range(n):
        for j in range(i + 1, n):
            edges.append((D[i, j], i, j))
    edges.sort()

    uf = UnionFind(n)
    threshold = 0.0

    for dist_val, i, j in edges:
        if uf.union(i, j):
            threshold = dist_val
            if uf.num_components == 1:
                break

    return threshold


def poincare_threshold_scan(
    D: np.ndarray, epsilon_range: np.ndarray, target_dim: int
) -> Dict[str, np.ndarray]:
    """Scan across scales to find the Poincaré threshold.

    For each epsilon, compute the Euler characteristic and compare with
    the expected value for S^d (which is 1 + (-1)^d).

    Args:
        D: Pairwise distance matrix
        epsilon_range: Array of epsilon values to scan
        target_dim: Target sphere dimension d

    Returns:
        Dict with keys 'epsilon', 'euler_char', 'target_chi', 'num_components'
    """
    target_chi = 1 + (-1) ** target_dim
    results = {
        'epsilon': epsilon_range,
        'euler_char': np.zeros(len(epsilon_range), dtype=int),
        'target_chi': np.full(len(epsilon_range), target_chi, dtype=int),
        'num_components': np.zeros(len(epsilon_range), dtype=int),
    }

    n = D.shape[0]
    for idx, eps in enumerate(epsilon_range):
        simplices = vietoris_rips_complex(D, eps, max_dim=min(target_dim + 1, 4))
        chi = euler_characteristic(simplices)
        results['euler_char'][idx] = chi

        # Count connected components from 0-simplices and 1-simplices
        uf = UnionFind(n)
        for i, j in simplices.get(1, []):
            uf.union(i, j)
        results['num_components'][idx] = uf.num_components

    return results


def hausdorff_distance(X: np.ndarray, Y: np.ndarray) -> float:
    """Compute the Hausdorff distance between point clouds X and Y.

    d_H(X,Y) = max(max_i min_j d(x_i, y_j), max_j min_i d(x_i, y_j))

    Args:
        X: First point cloud, shape (n, d)
        Y: Second point cloud, shape (m, d)

    Returns:
        The Hausdorff distance
    """
    # Compute all pairwise distances between X and Y
    diff = X[:, np.newaxis, :] - Y[np.newaxis, :, :]
    D_cross = np.sqrt(np.sum(diff ** 2, axis=-1))

    forward = np.max(np.min(D_cross, axis=1))  # max_i min_j
    backward = np.max(np.min(D_cross, axis=0))  # max_j min_i

    return max(forward, backward)


def verify_interleaving(
    X: np.ndarray, Y: np.ndarray, epsilon: float
) -> Dict[str, float]:
    """Verify the Hausdorff VR interleaving theorem numerically.

    If d_H(X,Y) ≤ δ, then edges at scale ε in X correspond to
    edges at scale ε + 2δ in Y.

    Args:
        X, Y: Point clouds
        epsilon: Scale parameter

    Returns:
        Dict with Hausdorff distance and interleaving verification
    """
    delta = hausdorff_distance(X, Y)
    D_X = pairwise_distance_matrix(X)
    D_Y = pairwise_distance_matrix(Y)

    # For each edge in VR_ε(X), check if nearest-neighbor image
    # is an edge in VR_{ε+2δ}(Y)
    n = X.shape[0]
    m = Y.shape[0]
    D_cross = pairwise_distance_matrix(
        np.vstack([X, Y])
    )[:n, n:]  # distances from X to Y

    # Map each point of X to nearest point of Y
    nn_map = np.argmin(D_cross, axis=1)

    violations = 0
    total_edges = 0
    for i in range(n):
        for j in range(i + 1, n):
            if D_X[i, j] <= epsilon:
                total_edges += 1
                j1, j2 = nn_map[i], nn_map[j]
                if D_Y[j1, j2] > epsilon + 2 * delta + 1e-10:
                    violations += 1

    return {
        'hausdorff_distance': delta,
        'epsilon': epsilon,
        'interleaving_scale': epsilon + 2 * delta,
        'total_edges': total_edges,
        'violations': violations,
        'theorem_verified': violations == 0,
    }
