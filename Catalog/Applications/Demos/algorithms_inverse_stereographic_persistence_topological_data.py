"""
Stereographic Persistence: Algorithms for Topological Data Analysis on Spheres

Type-hinted implementations of the core algorithms for computing persistent
homology on spheres via stereographic projection.
"""

import numpy as np
from typing import List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class PersistencePair:
    """A birth-death pair in a persistence diagram."""
    birth: float
    death: float
    dimension: int = 0

    @property
    def lifetime(self) -> float:
        return self.death - self.birth

    def is_significant(self, threshold: float) -> bool:
        return self.lifetime >= threshold

    def scale(self, c: float) -> 'PersistencePair':
        return PersistencePair(c * self.birth, c * self.death, self.dimension)


def stereo_conformal_factor(x: np.ndarray) -> float:
    """Compute the stereographic conformal factor w(x) = 2/(1 + ||x||²).

    Args:
        x: Point in R^n

    Returns:
        The conformal weight at x
    """
    return 2.0 / (1.0 + np.dot(x, x))


def stereo_weighted_dist(x: np.ndarray, y: np.ndarray) -> float:
    """Compute the conformally weighted distance d_w(x,y) = w(x)·w(y)·||x-y||.

    Args:
        x, y: Points in R^n

    Returns:
        The conformally weighted Euclidean distance
    """
    wx = stereo_conformal_factor(x)
    wy = stereo_conformal_factor(y)
    return wx * wy * np.linalg.norm(x - y)


def stereographic_project(p: np.ndarray) -> np.ndarray:
    """Stereographic projection from S^n to R^n.

    Projects from the north pole (0,...,0,1) to the equatorial plane.

    Args:
        p: Point on S^n (unit sphere in R^{n+1})

    Returns:
        Projected point in R^n
    """
    n = len(p) - 1
    denom = 1.0 - p[-1]
    if abs(denom) < 1e-15:
        return np.full(n, np.inf)
    return p[:n] / denom


def inverse_stereographic(x: np.ndarray) -> np.ndarray:
    """Inverse stereographic projection from R^n to S^n.

    Args:
        x: Point in R^n

    Returns:
        Point on S^n (unit sphere in R^{n+1})
    """
    norm_sq = np.dot(x, x)
    denom = 1.0 + norm_sq
    result = np.zeros(len(x) + 1)
    result[:len(x)] = 2.0 * x / denom
    result[-1] = (norm_sq - 1.0) / denom
    return result


def geodesic_dist(p: np.ndarray, q: np.ndarray) -> float:
    """Compute geodesic distance between two points on S^n.

    Args:
        p, q: Points on S^n (unit sphere)

    Returns:
        Geodesic (great-circle) distance
    """
    dot = np.clip(np.dot(p, q), -1.0, 1.0)
    return np.arccos(dot)


def compute_pairwise_distances(
    points: np.ndarray,
    metric: str = 'euclidean',
    weights: Optional[np.ndarray] = None
) -> np.ndarray:
    """Compute pairwise distance matrix.

    Args:
        points: N x d array of points
        metric: 'euclidean', 'geodesic', or 'weighted'
        weights: Optional conformal weights for 'weighted' metric

    Returns:
        N x N distance matrix
    """
    n = len(points)
    D = np.zeros((n, n))

    for i in range(n):
        for j in range(i + 1, n):
            if metric == 'euclidean':
                d = np.linalg.norm(points[i] - points[j])
            elif metric == 'geodesic':
                d = geodesic_dist(points[i], points[j])
            elif metric == 'weighted':
                if weights is None:
                    weights = np.array([stereo_conformal_factor(p) for p in points])
                d = weights[i] * weights[j] * np.linalg.norm(points[i] - points[j])
            else:
                raise ValueError(f"Unknown metric: {metric}")
            D[i, j] = d
            D[j, i] = d

    return D


def cech_filtration_value(
    simplex: List[int],
    dist_matrix: np.ndarray
) -> float:
    """Compute the filtration value (birth time) of a simplex in the Čech complex.

    The birth time is max(d(i,j)) / 2 over all pairs in the simplex.

    Args:
        simplex: List of vertex indices
        dist_matrix: Pairwise distance matrix

    Returns:
        Filtration value (half of maximum pairwise distance)
    """
    max_dist = 0.0
    for i in range(len(simplex)):
        for j in range(i + 1, len(simplex)):
            d = dist_matrix[simplex[i], simplex[j]]
            if d > max_dist:
                max_dist = d
    return max_dist / 2.0


def vietoris_rips_persistence(
    dist_matrix: np.ndarray,
    max_dim: int = 1,
    max_epsilon: float = np.inf
) -> List[PersistencePair]:
    """Compute Vietoris-Rips persistence diagram (simplified version).

    Uses a greedy approach for edges to compute H_0 persistence
    (connected components).

    Args:
        dist_matrix: N x N pairwise distance matrix
        max_dim: Maximum homological dimension
        max_epsilon: Maximum filtration parameter

    Returns:
        List of persistence pairs
    """
    n = len(dist_matrix)
    pairs: List[PersistencePair] = []

    # H_0: Connected components via minimum spanning tree
    parent = list(range(n))

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> bool:
        rx, ry = find(x), find(y)
        if rx == ry:
            return False
        parent[rx] = ry
        return True

    # Sort edges by distance
    edges: List[Tuple[float, int, int]] = []
    for i in range(n):
        for j in range(i + 1, n):
            if dist_matrix[i, j] <= max_epsilon:
                edges.append((dist_matrix[i, j], i, j))
    edges.sort()

    # Process edges
    components = n
    for dist, i, j in edges:
        if union(i, j):
            pairs.append(PersistencePair(0.0, dist / 2.0, dimension=0))
            components -= 1

    # The last surviving component has infinite death
    # (we represent as death = max_epsilon)
    if components > 0:
        pairs.append(PersistencePair(0.0, max_epsilon, dimension=0))

    return pairs


def compare_persistence_diagrams(
    dgm1: List[PersistencePair],
    dgm2: List[PersistencePair],
    threshold: float = 0.01
) -> Tuple[float, bool]:
    """Compare two persistence diagrams using bottleneck-like distance.

    Args:
        dgm1, dgm2: Persistence diagrams
        threshold: Tolerance for equality

    Returns:
        (distance, is_close) tuple
    """
    # Sort by lifetime
    s1 = sorted(dgm1, key=lambda p: -p.lifetime)
    s2 = sorted(dgm2, key=lambda p: -p.lifetime)

    # Pad to same length
    max_len = max(len(s1), len(s2))
    while len(s1) < max_len:
        s1.append(PersistencePair(0.0, 0.0))
    while len(s2) < max_len:
        s2.append(PersistencePair(0.0, 0.0))

    # Compute max difference in lifetimes
    max_diff = 0.0
    for p1, p2 in zip(s1, s2):
        diff = abs(p1.lifetime - p2.lifetime)
        max_diff = max(max_diff, diff)

    return max_diff, max_diff < threshold


def stereo_persistence_interleaving_bound(
    R: float,
    epsilon: float
) -> Tuple[float, float]:
    """Compute the interleaving bounds for stereographic persistence.

    For points with norms bounded by R, the weighted and unweighted
    Čech complexes are interleaved with parameters:
    - Forward: ε/4 (universal bound from w ≤ 2)
    - Reverse: ε/(2/(1+R²))² (depends on R)

    Args:
        R: Bound on point norms in R^n
        epsilon: Filtration parameter

    Returns:
        (forward_param, reverse_param) bounds
    """
    c_max = 2.0
    c_min = 2.0 / (1.0 + R**2)
    forward = epsilon / c_max**2
    reverse = epsilon / c_min**2
    return forward, reverse


def generate_spherical_points(
    n_points: int,
    dim: int = 2,
    seed: Optional[int] = None
) -> np.ndarray:
    """Generate random points uniformly on S^dim.

    Args:
        n_points: Number of points
        dim: Dimension of sphere (S^dim lives in R^{dim+1})
        seed: Random seed

    Returns:
        N x (dim+1) array of points on S^dim
    """
    if seed is not None:
        np.random.seed(seed)
    points = np.random.randn(n_points, dim + 1)
    norms = np.linalg.norm(points, axis=1, keepdims=True)
    return points / norms
