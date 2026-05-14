"""
Tropical Wormhole Surgery: Algorithms

Implements the core algorithms from the tropical discrete relativity framework:
1. Bellman-Ford shortest paths (tropical geodesics)
2. Wormhole surgery on weighted graphs
3. Min-plus Ricci curvature computation
4. Tropical Einstein equation verification

All algorithms operate on weighted adjacency matrices represented as numpy arrays.
"""

import numpy as np
from typing import List, Tuple, Optional, Dict


def bellman_ford(W: np.ndarray, source: int) -> Tuple[np.ndarray, np.ndarray]:
    """Compute single-source shortest paths via Bellman-Ford relaxation.

    This implements the tropical geodesic computation: the min-plus analogue
    of solving the Einstein field equation on a discrete spacetime.

    Args:
        W: (n x n) weight matrix. W[i][j] = cost of edge i -> j.
           Use np.inf for absent edges.
        source: Source vertex index.

    Returns:
        dist: Array of shortest distances from source.
        pred: Predecessor array for path reconstruction. pred[i] = -1 if unreachable.

    Time complexity: O(n^3) for dense graphs, O(n * m) for sparse.
    Space complexity: O(n).
    """
    n = W.shape[0]
    dist = np.full(n, np.inf)
    pred = np.full(n, -1, dtype=int)
    dist[source] = 0.0

    for iteration in range(n - 1):
        updated = False
        for u in range(n):
            if dist[u] == np.inf:
                continue
            for v in range(n):
                if dist[u] + W[u][v] < dist[v]:
                    dist[v] = dist[u] + W[u][v]
                    pred[v] = u
                    updated = True
        if not updated:
            break  # Early termination — already converged

    return dist, pred


def reconstruct_path(pred: np.ndarray, source: int, target: int) -> List[int]:
    """Reconstruct shortest path from predecessor array.

    Args:
        pred: Predecessor array from bellman_ford.
        source: Source vertex.
        target: Target vertex.

    Returns:
        List of vertices from source to target, or empty list if unreachable.
    """
    if pred[target] == -1 and target != source:
        return []
    path = []
    v = target
    while v != source:
        path.append(v)
        v = pred[v]
        if v == -1:
            return []
    path.append(source)
    path.reverse()
    return path


def all_pairs_shortest_paths(W: np.ndarray) -> np.ndarray:
    """Compute all-pairs shortest paths (tropical distance matrix).

    This is the full tropical metric on the discrete spacetime.

    Args:
        W: (n x n) weight matrix.

    Returns:
        D: (n x n) distance matrix where D[i][j] = tropicalDistance(W, i, j).

    Time complexity: O(n^4) via repeated Bellman-Ford, or O(n^3) via Floyd-Warshall.
    """
    n = W.shape[0]
    # Use Floyd-Warshall for efficiency
    D = W.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if D[i][k] + D[k][j] < D[i][j]:
                    D[i][j] = D[i][k] + D[k][j]
    return D


def wormhole_surgery(W: np.ndarray, u: int, v: int, tau: float) -> np.ndarray:
    """Perform wormhole surgery: insert a bridge edge of cost τ.

    Replaces W[u][v] and W[v][u] with min(W[u][v], τ) and min(W[v][u], τ).

    Args:
        W: (n x n) weight matrix (not modified in place).
        u, v: Bridge endpoint vertices.
        tau: Bridge cost parameter.

    Returns:
        W_new: Modified weight matrix after surgery.
    """
    W_new = W.copy()
    W_new[u][v] = min(W[u][v], tau)
    W_new[v][u] = min(W[v][u], tau)
    return W_new


def min_plus_ricci(W: np.ndarray, x: int) -> float:
    """Compute min-plus Ricci curvature at vertex x.

    R(x) = min_y (W[x][y] + W[y][x]) / 2

    This is a discrete curvature surrogate measuring the tightness
    of local geometry around vertex x.

    Args:
        W: (n x n) weight matrix.
        x: Vertex index.

    Returns:
        Ricci curvature value at x.
    """
    n = W.shape[0]
    return min((W[x][y] + W[y][x]) / 2 for y in range(n))


def throat_bound(W: np.ndarray, u: int, v: int) -> float:
    """Compute the throat bound for surgery between u and v.

    TB(u,v) = (R(u) + R(v)) / 2

    This bounds the admissible throat radius of a wormhole.

    Args:
        W: (n x n) weight matrix.
        u, v: Surgery endpoint vertices.

    Returns:
        Throat bound value.
    """
    return (min_plus_ricci(W, u) + min_plus_ricci(W, v)) / 2


def throat_radius(W: np.ndarray, u: int, v: int, tau: float) -> float:
    """Compute the effective throat radius.

    TR(u,v,τ) = min(τ, TB(u,v))

    Args:
        W: (n x n) weight matrix.
        u, v: Surgery endpoint vertices.
        tau: Bridge cost parameter.

    Returns:
        Effective throat radius.
    """
    return min(tau, throat_bound(W, u, v))


def verify_tropical_einstein(W: np.ndarray, source: int,
                              phi: np.ndarray, tol: float = 1e-10) -> bool:
    """Verify whether φ satisfies the tropical Einstein equation.

    Checks: φ[source] = 0 and for x ≠ source,
    φ[x] = min_y (φ[y] + W[y][x]).

    Args:
        W: (n x n) weight matrix.
        source: Source vertex.
        phi: Potential function to verify.
        tol: Numerical tolerance.

    Returns:
        True if φ satisfies the equation within tolerance.
    """
    n = W.shape[0]
    if abs(phi[source]) > tol:
        return False
    for x in range(n):
        if x == source:
            continue
        relaxed = min(phi[y] + W[y][x] for y in range(n))
        if abs(phi[x] - relaxed) > tol:
            return False
    return True


def relaxation_step(W: np.ndarray, d: np.ndarray) -> np.ndarray:
    """Single Bellman-Ford relaxation step.

    d_new[x] = min_y (d[y] + W[y][x])

    Args:
        W: (n x n) weight matrix.
        d: Current distance estimates.

    Returns:
        Updated distance estimates after one relaxation.
    """
    n = W.shape[0]
    d_new = np.empty(n)
    for x in range(n):
        d_new[x] = min(d[y] + W[y][x] for y in range(n))
    return d_new


def iterate_relax(W: np.ndarray, d0: np.ndarray, k: int) -> np.ndarray:
    """Iterate relaxation k times.

    Args:
        W: (n x n) weight matrix.
        d0: Initial distance estimates.
        k: Number of iterations.

    Returns:
        Distance estimates after k relaxation steps.
    """
    d = d0.copy()
    for _ in range(k):
        d = relaxation_step(W, d)
    return d


def surgery_distance_analysis(W: np.ndarray, s: int, t: int,
                               u: int, v: int, tau: float) -> Dict:
    """Complete analysis of wormhole surgery effect on s-t distance.

    Args:
        W: (n x n) weight matrix.
        s, t: Source and target vertices.
        u, v: Surgery bridge endpoints.
        tau: Bridge cost.

    Returns:
        Dictionary with analysis results including distances before/after,
        improvement ratio, path through wormhole, etc.
    """
    # Before surgery
    dist_before, pred_before = bellman_ford(W, s)
    d_st_before = dist_before[t]
    path_before = reconstruct_path(pred_before, s, t)

    # After surgery
    W_new = wormhole_surgery(W, u, v, tau)
    dist_after, pred_after = bellman_ford(W_new, s)
    d_st_after = dist_after[t]
    path_after = reconstruct_path(pred_after, s, t)

    # Wormhole path cost: s -> u -> v -> t
    d_su = dist_before[u]
    d_vt_dist, _ = bellman_ford(W, v)
    d_vt = d_vt_dist[t]
    wormhole_path_cost = d_su + tau + d_vt

    # Curvature analysis
    ricci_u = min_plus_ricci(W, u)
    ricci_v = min_plus_ricci(W, v)
    tb = throat_bound(W, u, v)
    tr = throat_radius(W, u, v, tau)

    return {
        "distance_before": d_st_before,
        "distance_after": d_st_after,
        "improvement": d_st_before - d_st_after,
        "improvement_ratio": (d_st_before - d_st_after) / d_st_before if d_st_before > 0 else 0,
        "path_before": path_before,
        "path_after": path_after,
        "wormhole_path_cost": wormhole_path_cost,
        "d_su": d_su,
        "d_vt": d_vt,
        "ricci_u": ricci_u,
        "ricci_v": ricci_v,
        "throat_bound": tb,
        "throat_radius": tr,
        "surgery_effective": d_st_after < d_st_before,
        "einstein_satisfied": verify_tropical_einstein(W_new, s, dist_after),
    }
