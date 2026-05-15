"""
Algorithms for Tropical Wormhole Surgery.

Implements the core algorithms from the tropical discrete relativity framework:
- Bellman-Ford tropical geodesic computation
- Wormhole surgery operations
- Min-plus Ricci curvature computation
- Optimal wormhole placement
- Bellman-Ford relaxation iteration
"""

import numpy as np
from typing import Tuple, List, Optional


def tropical_geodesic(W: np.ndarray, source: int) -> np.ndarray:
    """
    Compute tropical distances (shortest paths) from a source vertex
    using Bellman-Ford algorithm.
    
    This is the computational realization of tropicalDistance from the formal theory.
    
    Args:
        W: Weight matrix of shape (n, n) with non-negative entries.
        source: Source vertex index.
    
    Returns:
        Array of distances from source to each vertex.
    
    Time complexity: O(n^3)
    Space complexity: O(n)
    """
    n = W.shape[0]
    dist = np.full(n, np.inf)
    dist[source] = 0.0
    
    for _ in range(n - 1):
        for x in range(n):
            for y in range(n):
                if dist[y] + W[y, x] < dist[x]:
                    dist[x] = dist[y] + W[y, x]
    
    return dist


def wormhole_surgery(W: np.ndarray, u: int, v: int, tau: float) -> np.ndarray:
    """
    Perform wormhole surgery: reduce bridge edge weights to at most tau.
    
    Implements wormholeSurgery from the formal theory.
    
    Args:
        W: Original weight matrix.
        u, v: Bridge endpoint vertices.
        tau: Surgery parameter (new maximum cost for bridge edges).
    
    Returns:
        Modified weight matrix.
    """
    W_new = W.copy()
    W_new[u, v] = min(W[u, v], tau)
    W_new[v, u] = min(W[v, u], tau)
    return W_new


def min_plus_ricci(W: np.ndarray) -> np.ndarray:
    """
    Compute min-plus Ricci curvature at each vertex.
    
    minPlusRicci(W, x) = min_y (W(x,y) + W(y,x)) / 2
    
    Args:
        W: Weight matrix.
    
    Returns:
        Array of curvature values, one per vertex.
    """
    n = W.shape[0]
    curvature = np.zeros(n)
    for x in range(n):
        roundtrip_costs = (W[x, :] + W[:, x]) / 2.0
        curvature[x] = np.min(roundtrip_costs)
    return curvature


def throat_bound(W: np.ndarray, u: int, v: int) -> float:
    """
    Compute the throat bound for a potential wormhole at (u, v).
    
    throatBound(W, u, v) = (minPlusRicci(W, u) + minPlusRicci(W, v)) / 2
    """
    R = min_plus_ricci(W)
    return (R[u] + R[v]) / 2.0


def throat_radius(W: np.ndarray, u: int, v: int, tau: float) -> float:
    """
    Compute the effective throat radius of a wormhole surgery.
    
    throatRadius(W, u, v, τ) = min(τ/2, throatBound(W, u, v))
    """
    tb = throat_bound(W, u, v)
    return min(tau / 2.0, tb)


def bellman_relax(W: np.ndarray, d: np.ndarray) -> np.ndarray:
    """
    One step of Bellman-Ford relaxation.
    
    relax(W, d)(x) = min_y (d(y) + W(y, x))
    """
    n = W.shape[0]
    d_new = np.full(n, np.inf)
    for x in range(n):
        for y in range(n):
            d_new[x] = min(d_new[x], d[y] + W[y, x])
    return d_new


def iterate_relax(W: np.ndarray, d0: np.ndarray, k: int) -> np.ndarray:
    """
    Apply k iterations of Bellman-Ford relaxation.
    
    iterateRelax(k, W, d0) = relax(W)^k(d0)
    """
    d = d0.copy()
    for _ in range(k):
        d = bellman_relax(W, d)
    return d


def optimal_wormhole_placement(
    W: np.ndarray, s: int, t: int, tau: float
) -> Tuple[int, int, float, float]:
    """
    Find the optimal bridge placement to minimize post-surgery distance from s to t.
    
    Args:
        W: Weight matrix.
        s: Source vertex.
        t: Target vertex.
        tau: Surgery cost parameter.
    
    Returns:
        Tuple of (u*, v*, new_distance, original_distance).
    """
    n = W.shape[0]
    
    # Compute distances from s and to t
    dist_from_s = tropical_geodesic(W, s)
    
    # For distances to t, use reverse graph
    W_T = W.T.copy()
    dist_to_t = tropical_geodesic(W_T, t)
    
    original_dist = dist_from_s[t]
    best_cost = original_dist
    best_u, best_v = s, t
    
    for u in range(n):
        for v in range(n):
            candidate = dist_from_s[u] + tau + dist_to_t[v]
            if candidate < best_cost:
                best_cost = candidate
                best_u, best_v = u, v
    
    return best_u, best_v, best_cost, original_dist


def verify_surgery_theorem(
    W: np.ndarray, s: int, t: int, u: int, v: int, tau: float
) -> dict:
    """
    Verify the surgery distance bound theorem on a concrete example.
    
    Returns a dictionary with all relevant quantities and verification results.
    """
    n = W.shape[0]
    
    # Original distances
    dist_orig = tropical_geodesic(W, s)
    dist_from_v = tropical_geodesic(W, v)
    
    a = dist_orig[u]  # tropicalDistance(W, s, u)
    b = dist_from_v[t]  # tropicalDistance(W, v, t)
    D = dist_orig[t]  # tropicalDistance(W, s, t)
    
    # Perform surgery
    W_surgery = wormhole_surgery(W, u, v, tau)
    dist_surgery = tropical_geodesic(W_surgery, s)
    new_dist = dist_surgery[t]
    
    # Check theorem conditions
    bridge_cost = a + tau + b
    theorem_holds = new_dist <= bridge_cost + 1e-10  # numerical tolerance
    strict_decrease = new_dist < D - 1e-10 if bridge_cost < D else None
    
    return {
        "n": n,
        "source": s,
        "target": t,
        "bridge_u": u,
        "bridge_v": v,
        "tau": tau,
        "original_distance": D,
        "distance_s_u": a,
        "distance_v_t": b,
        "bridge_path_cost": bridge_cost,
        "post_surgery_distance": new_dist,
        "distance_reduction": D - new_dist,
        "reduction_percent": (D - new_dist) / D * 100 if D > 0 else 0,
        "theorem_bound_holds": theorem_holds,
        "strict_decrease": strict_decrease,
    }


def compute_all_curvatures(W: np.ndarray) -> dict:
    """
    Compute curvature information for all vertices and potential bridges.
    """
    n = W.shape[0]
    R = min_plus_ricci(W)
    
    bridges = []
    for u in range(n):
        for v in range(u + 1, n):
            tb = (R[u] + R[v]) / 2.0
            bridges.append({
                "u": u,
                "v": v,
                "throat_bound": tb,
                "ricci_u": R[u],
                "ricci_v": R[v],
            })
    
    return {
        "curvatures": R.tolist(),
        "bridges": sorted(bridges, key=lambda x: x["throat_bound"]),
    }


if __name__ == "__main__":
    # Example: 5-vertex spacetime graph
    W = np.array([
        [0, 10, 50, 100, 200],
        [10, 0,  10,  50, 100],
        [50, 10,  0,  10,  50],
        [100, 50, 10,  0,  10],
        [200, 100, 50, 10,  0],
    ], dtype=float)
    
    print("=== Tropical Wormhole Surgery Demo ===\n")
    
    # Compute original distances
    print("Original distances from vertex 0:")
    dist = tropical_geodesic(W, 0)
    for i, d in enumerate(dist):
        print(f"  d(0, {i}) = {d}")
    
    # Perform surgery
    u, v, tau = 0, 4, 5.0
    result = verify_surgery_theorem(W, 0, 4, u, v, tau)
    print(f"\nSurgery: bridge ({u}, {v}) with τ = {tau}")
    print(f"  Original distance: {result['original_distance']}")
    print(f"  Bridge path cost:  {result['bridge_path_cost']}")
    print(f"  Post-surgery dist: {result['post_surgery_distance']}")
    print(f"  Reduction: {result['reduction_percent']:.1f}%")
    print(f"  Theorem holds: {result['theorem_bound_holds']}")
    
    # Compute curvatures
    print("\nMin-plus Ricci curvatures:")
    R = min_plus_ricci(W)
    for i, r in enumerate(R):
        print(f"  R({i}) = {r}")
    
    # Optimal placement
    u_opt, v_opt, best, orig = optimal_wormhole_placement(W, 0, 4, 5.0)
    print(f"\nOptimal bridge placement for 0→4 with τ=5:")
    print(f"  Bridge: ({u_opt}, {v_opt})")
    print(f"  New distance: {best}")
    print(f"  Original: {orig}")
