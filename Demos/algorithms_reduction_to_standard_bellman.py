"""
algorithms.py — Implementations of algorithms derived from the Charged Tropical Reweighting theorem.

Includes:
- Charged Value Iteration
- Charged Shortest Path (Dijkstra with gauge absorption)
- Tropical eigenvalue computation for charged systems
"""

import numpy as np
from typing import Tuple, List, Optional
import heapq


def charged_weight(W: np.ndarray, A: np.ndarray, q: float) -> np.ndarray:
    """
    Compute the effective charged weight matrix.

    W_eff[i,j] = W[i,j] + q * A[i,j]

    By the Gauge Elimination Theorem, any optimization problem with costs
    (W, A, q) is exactly equivalent to optimization with costs W_eff.

    Parameters
    ----------
    W : np.ndarray, shape (n, n)
        Base transition weight matrix.
    A : np.ndarray, shape (n, n)
        Gauge potential matrix.
    q : float
        Charge (coupling constant).

    Returns
    -------
    np.ndarray, shape (n, n)
        Effective charged weight matrix.
    """
    return W + q * A


def charged_value_iteration(
    W: np.ndarray,
    A: np.ndarray,
    q: float,
    Phi0: Optional[np.ndarray] = None,
    max_iter: int = 1000,
    tol: float = 1e-10
) -> Tuple[np.ndarray, int, List[np.ndarray]]:
    """
    Value iteration for a charged tropical system.

    By the Dynamics Equivalence Theorem, this produces exactly the same
    trajectory as iterating the Maxwell-Bellman operator directly.

    Algorithm:
    1. Precompute W_eff = W + q * A          (O(n²) preprocessing)
    2. Iterate Φ_{k+1}[i] = max_j(W_eff[i,j] + Φ_k[j])   (O(n²) per step)
    3. Stop when ||Φ_{k+1} - Φ_k||_∞ < tol

    Parameters
    ----------
    W : np.ndarray, shape (n, n)
        Base weight matrix.
    A : np.ndarray, shape (n, n)
        Gauge potential matrix.
    q : float
        Charge parameter.
    Phi0 : np.ndarray, optional
        Initial value function. Defaults to zeros.
    max_iter : int
        Maximum number of iterations.
    tol : float
        Convergence tolerance (L∞ norm).

    Returns
    -------
    Phi : np.ndarray
        Converged value function (or last iterate).
    iterations : int
        Number of iterations performed.
    trajectory : list of np.ndarray
        Full trajectory of value functions.
    """
    n = W.shape[0]
    W_eff = charged_weight(W, A, q)

    Phi = Phi0.copy() if Phi0 is not None else np.zeros(n)
    trajectory = [Phi.copy()]

    for k in range(max_iter):
        Phi_new = np.max(W_eff + Phi[np.newaxis, :], axis=1)
        trajectory.append(Phi_new.copy())

        if np.max(np.abs(Phi_new - Phi)) < tol:
            return Phi_new, k + 1, trajectory

        Phi = Phi_new

    return Phi, max_iter, trajectory


def charged_dijkstra(
    W: np.ndarray,
    A: np.ndarray,
    q: float,
    source: int
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Shortest path with charged weights using Dijkstra's algorithm.

    Computes shortest paths from `source` under combined cost W + q*A.
    By the Gauge Elimination Theorem, this solves the charged shortest-path
    problem exactly.

    Requires all effective weights to be non-negative.

    Parameters
    ----------
    W : np.ndarray, shape (n, n)
        Base edge weight matrix (non-negative).
    A : np.ndarray, shape (n, n)
        Gauge potential matrix.
    q : float
        Charge parameter.
    source : int
        Source node index.

    Returns
    -------
    dist : np.ndarray
        Shortest distances from source.
    pred : np.ndarray
        Predecessor array for path reconstruction.

    Complexity
    ----------
    Time: O(n² log n) with binary heap, O(n²) per iteration.
    Space: O(n).
    """
    n = W.shape[0]
    W_eff = charged_weight(W, A, q)

    dist = np.full(n, np.inf)
    dist[source] = 0.0
    pred = np.full(n, -1, dtype=int)
    visited = np.zeros(n, dtype=bool)

    heap = [(0.0, source)]

    while heap:
        d, u = heapq.heappop(heap)
        if visited[u]:
            continue
        visited[u] = True

        for v in range(n):
            if W_eff[u, v] < np.inf and not visited[v]:
                new_dist = d + W_eff[u, v]
                if new_dist < dist[v]:
                    dist[v] = new_dist
                    pred[v] = u
                    heapq.heappush(heap, (new_dist, v))

    return dist, pred


def tropical_eigenvalue_charged(
    W: np.ndarray,
    A: np.ndarray,
    q: float
) -> float:
    """
    Compute the tropical (max-plus) eigenvalue of a charged system.

    The tropical eigenvalue is the maximum cycle mean of the effective
    weight matrix W_eff = W + q*A. By the gauge elimination theorem,
    this equals the charged tropical eigenvalue of (W, A, q).

    Uses Karp's algorithm: λ = max_i min_k (d_n[i] - d_k[i]) / (n - k)
    where d_k[i] is the maximum weight of a k-length walk ending at i.

    Parameters
    ----------
    W : np.ndarray, shape (n, n)
        Base weight matrix.
    A : np.ndarray, shape (n, n)
        Gauge potential matrix.
    q : float
        Charge parameter.

    Returns
    -------
    float
        Maximum cycle mean (tropical eigenvalue) of the charged system.

    Complexity
    ----------
    Time: O(n³). Space: O(n²).
    """
    n = W.shape[0]
    W_eff = charged_weight(W, A, q)

    # d[k][i] = max weight of a walk of length k ending at i
    # Using dynamic programming
    d = np.full((n + 1, n), -np.inf)
    # Start from any node with weight 0
    d[0, :] = 0.0

    for k in range(1, n + 1):
        for i in range(n):
            for j in range(n):
                if d[k-1][j] > -np.inf:
                    d[k][i] = max(d[k][i], d[k-1][j] + W_eff[j, i])

    # Karp's formula
    eigenvalue = -np.inf
    for i in range(n):
        if d[n][i] > -np.inf:
            min_ratio = np.inf
            for k in range(n):
                if d[k][i] > -np.inf:
                    ratio = (d[n][i] - d[k][i]) / (n - k)
                    min_ratio = min(min_ratio, ratio)
            eigenvalue = max(eigenvalue, min_ratio)

    return eigenvalue


def reconstruct_path(pred: np.ndarray, source: int, target: int) -> List[int]:
    """Reconstruct shortest path from predecessor array."""
    if pred[target] == -1 and target != source:
        return []  # No path
    path = []
    node = target
    while node != -1:
        path.append(node)
        if node == source:
            break
        node = pred[node]
    return path[::-1]


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)

    # --- Charged Value Iteration ---
    print("\n--- Charged Value Iteration ---")
    n = 4
    W = np.array([[-1, 2, 0, -3],
                  [1, -2, 3, 0],
                  [0, 1, -1, 2],
                  [2, 0, 1, -2]], dtype=float)
    A = np.array([[0.5, 0.1, 0.3, 0.2],
                  [0.1, 0.4, 0.2, 0.3],
                  [0.3, 0.2, 0.5, 0.1],
                  [0.2, 0.3, 0.1, 0.4]], dtype=float)
    q = 1.0

    Phi, iters, traj = charged_value_iteration(W, A, q, max_iter=20)
    print(f"Converged in {iters} iterations")
    print(f"Value function: {Phi.round(4)}")

    # --- Charged Dijkstra ---
    print("\n--- Charged Shortest Path (Dijkstra) ---")
    W_graph = np.array([[np.inf, 10, 15, np.inf],
                        [np.inf, np.inf, 5, 20],
                        [np.inf, np.inf, np.inf, 3],
                        [np.inf, np.inf, np.inf, np.inf]])
    A_graph = np.array([[0, 2, 0, 0],
                        [0, 0, 3, 1],
                        [0, 0, 0, 0],
                        [0, 0, 0, 0]])
    q = 1.0

    dist, pred = charged_dijkstra(W_graph, A_graph, q, source=0)
    print(f"Distances from node 0: {dist}")
    for target in range(1, 4):
        path = reconstruct_path(pred, 0, target)
        print(f"  Path to {target}: {' → '.join(map(str, path))}, cost = {dist[target]:.1f}")

    # --- Tropical Eigenvalue ---
    print("\n--- Charged Tropical Eigenvalue ---")
    W_eig = np.array([[0, 3, -np.inf],
                      [-np.inf, 0, 2],
                      [1, -np.inf, 0]], dtype=float)
    A_eig = np.array([[0, 1, 0],
                      [0, 0, 0.5],
                      [0.5, 0, 0]], dtype=float)

    for q_val in [0.0, 1.0, 2.0]:
        ev = tropical_eigenvalue_charged(W_eig, A_eig, q_val)
        print(f"  q = {q_val:.1f}: tropical eigenvalue = {ev:.4f}")

    print("\nAll algorithm demos completed ✓")
