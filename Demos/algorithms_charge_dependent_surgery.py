"""
Algorithms for Charged Wormhole Surgery on Graphs

Implements the core algorithms described in the research paper,
with full docstrings, type hints, and example usage.
"""

import numpy as np
from typing import Tuple, List, Optional


def floyd_warshall(W: np.ndarray) -> np.ndarray:
    """
    Compute all-pairs shortest paths using the Floyd-Warshall algorithm.
    
    This is the standard O(n³) dynamic programming algorithm for APSP.
    In the tropical (min-plus) setting, this computes the Kleene star
    of the weight matrix.
    
    Args:
        W: n×n nonneg weight matrix. W[i][j] = weight of edge (i,j).
           Use large values (e.g., float('inf')) for missing edges.
           Diagonal should be 0.
    
    Returns:
        n×n distance matrix D where D[i][j] is the shortest path distance.
    
    Example:
        >>> W = np.array([[0, 1, 100], [1, 0, 2], [100, 2, 0]], dtype=float)
        >>> D = floyd_warshall(W)
        >>> D[0][2]  # shortest 0→2 is 0→1→2 = 3
        3.0
    """
    n = W.shape[0]
    D = W.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if D[i][k] + D[k][j] < D[i][j]:
                    D[i][j] = D[i][k] + D[k][j]
    return D


def charged_penalty(A: np.ndarray, u: int, v: int, 
                     lam: float, kap: float) -> float:
    """
    Compute the charged penalty for a wormhole between vertices u and v.
    
    The charged penalty is:  λ + κ · |A(u) - A(v)|
    
    This models the additional cost incurred when connecting vertices
    with different gauge potentials (voltages, elevations, etc.).
    
    Args:
        A: Gauge potential array. A[i] = potential at vertex i.
        u: First wormhole endpoint.
        v: Second wormhole endpoint.
        lam: Base tunnel cost (≥ 0).
        kap: Coupling constant (≥ 0).
    
    Returns:
        The charged penalty value.
    
    Properties (proved formally):
        - Gauge invariant: penalty(A+c, u, v) = penalty(A, u, v)
        - Symmetric: penalty(A, u, v) = penalty(A, v, u)
        - Monotone in κ: κ₁ ≤ κ₂ ⟹ penalty(κ₁) ≤ penalty(κ₂)
        - When A is constant: penalty = λ
    
    Example:
        >>> A = np.array([0.0, 5.0, 3.0])
        >>> charged_penalty(A, 0, 1, 2.0, 1.0)
        7.0
    """
    return lam + kap * abs(A[u] - A[v])


def wormhole_surgery(W: np.ndarray, u: int, v: int, 
                     tau: float) -> np.ndarray:
    """
    Apply standard wormhole surgery to a weight matrix.
    
    Inserts a bidirectional wormhole edge (u,v) with cost τ.
    The new weight is min(original_weight, τ) for edges (u,v) and (v,u).
    
    Args:
        W: n×n weight matrix.
        u: First wormhole endpoint.
        v: Second wormhole endpoint.
        tau: Wormhole tunnel cost.
    
    Returns:
        Modified weight matrix.
    
    Example:
        >>> W = np.array([[0, 100], [100, 0]], dtype=float)
        >>> W_new = wormhole_surgery(W, 0, 1, 5.0)
        >>> W_new[0][1]
        5.0
    """
    W_mod = W.copy()
    W_mod[u][v] = min(W[u][v], tau)
    W_mod[v][u] = min(W[v][u], tau)
    return W_mod


def charged_wormhole_surgery(W: np.ndarray, A: np.ndarray,
                              u: int, v: int,
                              lam: float, kap: float) -> np.ndarray:
    """
    Apply charged wormhole surgery to a weight matrix.
    
    This is wormhole surgery with the charged penalty as tunnel cost:
    chargedWormholeSurgery = wormholeSurgery(W, u, v, chargedPenalty(A, u, v, λ, κ))
    
    Args:
        W: n×n nonneg weight matrix.
        A: Gauge potential array.
        u, v: Wormhole endpoints.
        lam: Base tunnel cost (≥ 0).
        kap: Coupling constant (≥ 0).
    
    Returns:
        Modified weight matrix with charged wormhole.
    """
    penalty = charged_penalty(A, u, v, lam, kap)
    return wormhole_surgery(W, u, v, penalty)


def compute_charged_distances(W: np.ndarray, A: np.ndarray,
                               u: int, v: int,
                               lam: float, kap: float) -> np.ndarray:
    """
    Compute all-pairs shortest-path distances after charged wormhole surgery.
    
    Time complexity: O(n³)
    Space complexity: O(n²)
    
    Args:
        W: n×n nonneg weight matrix.
        A: Gauge potential array.
        u, v: Wormhole endpoints.
        lam: Base tunnel cost.
        kap: Coupling constant.
    
    Returns:
        n×n distance matrix for the charged surgery graph.
    """
    W_charged = charged_wormhole_surgery(W, A, u, v, lam, kap)
    return floyd_warshall(W_charged)


def verify_surgery_bound(W: np.ndarray, A: np.ndarray,
                          u: int, v: int,
                          lam: float, kap: float,
                          tol: float = 1e-10) -> bool:
    """
    Verify the main charged surgery bound (Theorem 3.1) numerically.
    
    Checks that for all x, y:
        d_charged(x,y) ≤ min(d(x,y), d(x,u)+P+d(v,y), d(x,v)+P+d(u,y))
    where P = chargedPenalty(A, u, v, λ, κ).
    
    Args:
        W, A, u, v, lam, kap: Surgery parameters.
        tol: Numerical tolerance.
    
    Returns:
        True if the bound holds for all vertex pairs.
    """
    n = W.shape[0]
    penalty = charged_penalty(A, u, v, lam, kap)
    D_W = floyd_warshall(W)
    D_ch = compute_charged_distances(W, A, u, v, lam, kap)
    
    for x in range(n):
        for y in range(n):
            bound = min(
                D_W[x][y],
                D_W[x][u] + penalty + D_W[v][y],
                D_W[x][v] + penalty + D_W[u][y]
            )
            if D_ch[x][y] > bound + tol:
                return False
    return True


def verify_sandwich(W: np.ndarray, A: np.ndarray,
                     u: int, v: int,
                     lam: float, kap: float,
                     tol: float = 1e-10) -> bool:
    """
    Verify the sandwich inequality (Theorem 3.6) numerically.
    
    Checks: d_uncharged ≤ d_charged ≤ d_original for all vertex pairs.
    """
    n = W.shape[0]
    D_W = floyd_warshall(W)
    D_unch = floyd_warshall(wormhole_surgery(W, u, v, lam))
    D_ch = compute_charged_distances(W, A, u, v, lam, kap)
    
    for x in range(n):
        for y in range(n):
            if D_unch[x][y] > D_ch[x][y] + tol:
                return False
            if D_ch[x][y] > D_W[x][y] + tol:
                return False
    return True


def optimal_wormhole_placement(W: np.ndarray, A: np.ndarray,
                                lam: float, kap: float,
                                metric: str = "max_dist"
                                ) -> Tuple[int, int, float]:
    """
    Find the optimal wormhole placement minimizing a given metric.
    
    Time complexity: O(n⁵) (n² pairs × n³ Floyd-Warshall)
    
    Args:
        W: n×n nonneg weight matrix.
        A: Gauge potential array.
        lam: Base tunnel cost.
        kap: Coupling constant.
        metric: "max_dist" (minimize maximum distance) or
                "avg_dist" (minimize average distance).
    
    Returns:
        (u*, v*, cost): Optimal wormhole endpoints and resulting cost.
    """
    n = W.shape[0]
    best_cost = float('inf')
    best_u, best_v = 0, 1
    
    for u_cand in range(n):
        for v_cand in range(n):
            if u_cand == v_cand:
                continue
            D = compute_charged_distances(W, A, u_cand, v_cand, lam, kap)
            
            if metric == "max_dist":
                cost = np.max(D)
            elif metric == "avg_dist":
                cost = np.mean(D)
            else:
                raise ValueError(f"Unknown metric: {metric}")
            
            if cost < best_cost:
                best_cost = cost
                best_u, best_v = u_cand, v_cand
    
    return best_u, best_v, best_cost


def charge_sensitivity_analysis(W: np.ndarray, A: np.ndarray,
                                 u: int, v: int,
                                 lam: float,
                                 kap_values: np.ndarray
                                 ) -> np.ndarray:
    """
    Analyze how the charged surgery distance varies with coupling κ.
    
    For each κ value, computes the maximum distance in the charged
    surgery graph.
    
    Args:
        W: Weight matrix.
        A: Gauge potential.
        u, v: Wormhole endpoints.
        lam: Base cost.
        kap_values: Array of κ values to test.
    
    Returns:
        Array of maximum distances, one per κ value.
    """
    results = []
    for kap in kap_values:
        D = compute_charged_distances(W, A, u, v, lam, kap)
        results.append(np.max(D))
    return np.array(results)


if __name__ == "__main__":
    # Example usage
    n = 5
    np.random.seed(42)
    W = np.random.uniform(1, 20, (n, n))
    W = (W + W.T) / 2
    np.fill_diagonal(W, 0)
    A = np.array([0.0, 3.0, 7.0, 1.0, 5.0])
    
    u, v = 1, 3
    lam, kap = 2.0, 1.0
    
    print(f"Charged penalty: {charged_penalty(A, u, v, lam, kap):.2f}")
    
    D = compute_charged_distances(W, A, u, v, lam, kap)
    print(f"Charged distance matrix:\n{np.round(D, 2)}")
    
    bound_ok = verify_surgery_bound(W, A, u, v, lam, kap)
    print(f"Surgery bound verified: {bound_ok}")
    
    sandwich_ok = verify_sandwich(W, A, u, v, lam, kap)
    print(f"Sandwich inequality verified: {sandwich_ok}")
    
    u_opt, v_opt, cost = optimal_wormhole_placement(W, A, lam, kap)
    print(f"Optimal wormhole: ({u_opt}, {v_opt}), cost: {cost:.2f}")
