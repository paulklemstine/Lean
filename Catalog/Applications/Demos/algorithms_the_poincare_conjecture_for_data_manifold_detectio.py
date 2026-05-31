"""
Algorithms for Manifold Detection via Persistent Homology.

Implements Vietoris-Rips graph construction, connected component tracking,
and Poincaré threshold estimation for point clouds.
"""

import numpy as np
from typing import List, Tuple, Optional
from scipy.spatial.distance import pdist, squareform


def generate_sphere_points(d: int, n: int, seed: Optional[int] = None) -> np.ndarray:
    """Generate n uniformly random points on the d-sphere S^d in R^{d+1}.

    Uses the standard method: sample from N(0,I) in R^{d+1}, then normalize.

    Args:
        d: Dimension of the sphere (S^d lives in R^{d+1}).
        n: Number of points.
        seed: Random seed for reproducibility.

    Returns:
        Array of shape (n, d+1) with points on S^d.
    """
    rng = np.random.default_rng(seed)
    X = rng.standard_normal((n, d + 1))
    norms = np.linalg.norm(X, axis=1, keepdims=True)
    return X / norms


def vietoris_rips_edges(X: np.ndarray, epsilon: float) -> List[Tuple[int, int]]:
    """Compute edges of the Vietoris-Rips graph at scale epsilon.

    Args:
        X: Point cloud, shape (n, d).
        epsilon: Scale parameter.

    Returns:
        List of (i, j) pairs with i < j such that dist(X[i], X[j]) <= epsilon.
    """
    D = squareform(pdist(X))
    n = len(X)
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if D[i, j] <= epsilon:
                edges.append((i, j))
    return edges


def connected_components(n: int, edges: List[Tuple[int, int]]) -> int:
    """Count connected components using union-find.

    Args:
        n: Number of vertices.
        edges: List of (i, j) edge pairs.

    Returns:
        Number of connected components.
    """
    parent = list(range(n))
    rank = [0] * n

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]  # path compression
            x = parent[x]
        return x

    def union(x: int, y: int) -> None:
        rx, ry = find(x), find(y)
        if rx == ry:
            return
        if rank[rx] < rank[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]:
            rank[rx] += 1

    for i, j in edges:
        union(i, j)

    return len(set(find(i) for i in range(n)))


def poincare_threshold(X: np.ndarray, num_steps: int = 200) -> float:
    """Estimate the Poincaré threshold: smallest epsilon where VR graph is connected.

    Uses binary search on epsilon to find the connectivity threshold.

    Args:
        X: Point cloud, shape (n, d).
        num_steps: Number of binary search steps.

    Returns:
        Estimated Poincaré threshold epsilon*.
    """
    D = squareform(pdist(X))
    lo, hi = 0.0, float(np.max(D))

    for _ in range(num_steps):
        mid = (lo + hi) / 2
        edges = []
        n = len(X)
        for i in range(n):
            for j in range(i + 1, n):
                if D[i, j] <= mid:
                    edges.append((i, j))
        cc = connected_components(n, edges)
        if cc == 1:
            hi = mid
        else:
            lo = mid

    return hi


def poincare_threshold_fast(X: np.ndarray) -> float:
    """Compute the exact Poincaré threshold using minimum spanning tree.

    The connectivity threshold equals the maximum edge weight in the MST.

    Args:
        X: Point cloud, shape (n, d).

    Returns:
        Exact Poincaré threshold epsilon*.
    """
    from scipy.sparse.csgraph import minimum_spanning_tree
    D = squareform(pdist(X))
    mst = minimum_spanning_tree(D)
    return float(mst.max())


def estimate_scaling_exponent(
    d: int,
    n_values: List[int],
    num_trials: int = 20,
    seed: int = 42
) -> Tuple[float, float, List[float], List[float]]:
    """Estimate the scaling exponent of the Poincaré threshold.

    For each n in n_values, generates num_trials random point clouds on S^d,
    computes the Poincaré threshold, and fits log(eps*) = a * log(n) + b.
    The predicted slope is -1/d.

    Args:
        d: Sphere dimension.
        n_values: List of sample sizes to test.
        num_trials: Number of trials per sample size.
        seed: Random seed.

    Returns:
        Tuple of (estimated_slope, predicted_slope, log_n_values, log_eps_values).
    """
    rng = np.random.default_rng(seed)
    log_n = []
    log_eps = []

    for n in n_values:
        eps_vals = []
        for trial in range(num_trials):
            X = generate_sphere_points(d, n, seed=seed + trial * 1000 + n)
            eps = poincare_threshold_fast(X)
            eps_vals.append(eps)
        mean_eps = np.mean(eps_vals)
        log_n.append(np.log(n))
        log_eps.append(np.log(mean_eps))

    # Linear regression
    log_n_arr = np.array(log_n)
    log_eps_arr = np.array(log_eps)
    slope, intercept = np.polyfit(log_n_arr, log_eps_arr, 1)

    predicted_slope = -1.0 / d
    return slope, predicted_slope, log_n, log_eps


def theoretical_threshold(d: int, n: int, C: float = 1.0) -> float:
    """Compute the theoretical Poincaré threshold: C * sqrt(d) * n^(-1/d).

    Args:
        d: Sphere dimension.
        n: Number of points.
        C: Universal constant.

    Returns:
        Theoretical threshold value.
    """
    return C * np.sqrt(d) * n ** (-1.0 / d)
