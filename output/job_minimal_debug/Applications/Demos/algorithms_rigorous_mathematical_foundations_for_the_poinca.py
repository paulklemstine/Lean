"""
Algorithms for Poincaré Threshold Computation

Type-hinted implementations of the key algorithms from the Poincaré threshold
theory: Rips graph construction, filtration threshold computation, approximate
isometry checking, and stability bounds.
"""

from typing import List, Tuple, Set, Callable, Optional
import numpy as np
from scipy.spatial.distance import pdist, squareform


def rips_graph(points: np.ndarray, epsilon: float) -> List[Tuple[int, int]]:
    """
    Construct the Rips graph at scale epsilon.

    Returns list of edges (i, j) where dist(points[i], points[j]) <= epsilon.

    Args:
        points: (n, d) array of n points in R^d
        epsilon: scale parameter

    Returns:
        List of edge tuples (i, j) with i < j
    """
    n = len(points)
    D = squareform(pdist(points))
    edges: List[Tuple[int, int]] = []
    for i in range(n):
        for j in range(i + 1, n):
            if D[i, j] <= epsilon:
                edges.append((i, j))
    return edges


def rips_filtration(points: np.ndarray, num_scales: int = 100) -> List[Tuple[float, List[Tuple[int, int]]]]:
    """
    Compute the full Rips filtration: edges at each scale.

    Args:
        points: (n, d) array
        num_scales: number of scale samples

    Returns:
        List of (epsilon, edges) pairs, sorted by epsilon
    """
    D = squareform(pdist(points))
    max_dist = D.max()
    scales = np.linspace(0, max_dist * 1.1, num_scales)
    filtration: List[Tuple[float, List[Tuple[int, int]]]] = []
    for eps in scales:
        edges = rips_graph(points, eps)
        filtration.append((eps, edges))
    return filtration


def connected_components(n: int, edges: List[Tuple[int, int]]) -> int:
    """
    Count connected components using union-find.

    Args:
        n: number of vertices
        edges: list of edge tuples

    Returns:
        Number of connected components
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


def connectivity_threshold(points: np.ndarray, tol: float = 1e-6) -> float:
    """
    Compute the connectivity threshold: the minimum epsilon at which
    the Rips graph becomes connected.

    Uses binary search on the sorted edge weights.

    Args:
        points: (n, d) array
        tol: tolerance for binary search

    Returns:
        The connectivity threshold epsilon*
    """
    n = len(points)
    if n <= 1:
        return 0.0

    D = squareform(pdist(points))
    # The connectivity threshold equals the weight of the maximum edge
    # in the minimum spanning tree (Kruskal's algorithm insight)
    edge_weights = sorted(set(D[i, j] for i in range(n) for j in range(i + 1, n)))

    # Binary search
    lo, hi = 0, len(edge_weights) - 1
    while lo < hi:
        mid = (lo + hi) // 2
        eps = edge_weights[mid]
        edges = rips_graph(points, eps)
        if connected_components(n, edges) == 1:
            hi = mid
        else:
            lo = mid + 1

    return edge_weights[lo]


def approx_isometry_distortion(
    points_x: np.ndarray,
    points_y: np.ndarray,
    f: Callable[[np.ndarray], np.ndarray]
) -> float:
    """
    Compute the distortion of a map f: X -> Y as an approximate isometry.

    delta = max_{i,j} |d_Y(f(x_i), f(x_j)) - d_X(x_i, x_j)|

    Args:
        points_x: source point cloud
        points_y: not used directly (target space is implicit in f)
        f: the map from X to Y

    Returns:
        The distortion delta
    """
    n = len(points_x)
    D_x = squareform(pdist(points_x))
    mapped = np.array([f(p) for p in points_x])
    D_y = squareform(pdist(mapped))

    delta = 0.0
    for i in range(n):
        for j in range(i + 1, n):
            delta = max(delta, abs(D_y[i, j] - D_x[i, j]))
    return delta


def stability_bound(
    points_x: np.ndarray,
    points_y: np.ndarray,
    f: Callable[[np.ndarray], np.ndarray]
) -> Tuple[float, float, float]:
    """
    Compute the stability bound for connectivity thresholds.

    Returns (threshold_X, threshold_Y, distortion_delta).
    The stability theorem guarantees |threshold_X - threshold_Y| <= delta.

    Args:
        points_x: first point cloud
        points_y: second point cloud
        f: approximate isometry from X to Y

    Returns:
        (threshold_X, threshold_Y, delta)
    """
    t_x = connectivity_threshold(points_x)
    t_y = connectivity_threshold(points_y)
    delta = approx_isometry_distortion(points_x, points_y, f)
    return t_x, t_y, delta


def edge_count_profile(points: np.ndarray, num_scales: int = 200) -> Tuple[np.ndarray, np.ndarray]:
    """
    Compute the edge count as a function of scale epsilon.
    Returns monotonically non-decreasing counts (by the edge count monotonicity theorem).

    Args:
        points: (n, d) array
        num_scales: number of scale samples

    Returns:
        (scales, counts) arrays
    """
    D = squareform(pdist(points))
    max_dist = D.max()
    scales = np.linspace(0, max_dist * 1.1, num_scales)
    counts = np.zeros(num_scales, dtype=int)

    for k, eps in enumerate(scales):
        count = 0
        n = len(points)
        for i in range(n):
            for j in range(i + 1, n):
                if D[i, j] <= eps:
                    count += 1
        counts[k] = count

    return scales, counts


def covering_number(points: np.ndarray, epsilon: float) -> int:
    """
    Greedy approximation of the epsilon-covering number.

    Args:
        points: (n, d) array
        epsilon: covering radius

    Returns:
        Size of the greedy epsilon-cover
    """
    n = len(points)
    if n == 0:
        return 0

    covered = np.zeros(n, dtype=bool)
    centers: List[int] = []

    for i in range(n):
        if not covered[i]:
            centers.append(i)
            for j in range(n):
                if np.linalg.norm(points[i] - points[j]) <= epsilon:
                    covered[j] = True

    return len(centers)
