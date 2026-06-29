"""
Algorithms for Tropical Spectral Theory
========================================
Efficient implementations of key algorithms from the research paper.
"""
import numpy as np
from typing import Tuple, Optional, List


def karp_max_cycle_mean(W: np.ndarray) -> Tuple[float, List[int]]:
    """Compute the maximum cycle mean using Karp's algorithm.

    Time complexity: O(n^3)
    Space complexity: O(n^2)

    Args:
        W: n×n weight matrix

    Returns:
        (rho, cycle): the maximum cycle mean and a witnessing cycle
    """
    n = W.shape[0]

    # D[k][i] = max weight of a walk of length k from vertex i
    D = np.full((n + 1, n), -np.inf)
    D[0, :] = 0.0
    # pred[k][i] = predecessor achieving the max for D[k][i]
    pred = np.full((n + 1, n), -1, dtype=int)

    for k in range(1, n + 1):
        for i in range(n):
            for j in range(n):
                val = W[i, j] + D[k - 1, j]
                if val > D[k, i]:
                    D[k, i] = val
                    pred[k, i] = j

    # Karp's formula: rho = max_i min_{0 <= k < n} (D[n][i] - D[k][i]) / (n - k)
    rho = -np.inf
    best_i = 0
    best_k = 0
    for i in range(n):
        min_ratio = np.inf
        curr_k = 0
        for k in range(n):
            if D[k, i] > -np.inf:
                ratio = (D[n, i] - D[k, i]) / (n - k)
                if ratio < min_ratio:
                    min_ratio = ratio
                    curr_k = k
        if min_ratio > rho and min_ratio < np.inf:
            rho = min_ratio
            best_i = i
            best_k = curr_k

    # Extract witnessing cycle (backtrack from best_i)
    cycle = [best_i]
    curr = best_i
    for step in range(n, best_k, -1):
        curr = pred[step, curr]
        cycle.append(curr)
    cycle.reverse()

    return rho, cycle


def bellman_ford_potential(W: np.ndarray, lam: float) -> Optional[np.ndarray]:
    """Construct a subeigenvector using Bellman-Ford-style iteration.

    Computes the potential x_i = max_{m=0,...,n-1} (best walk weight of length m)
    in the shifted matrix A = W - λ.

    Time complexity: O(n^3)
    Space complexity: O(n)

    Args:
        W: n×n weight matrix
        lam: the subeigenvalue parameter

    Returns:
        x: subeigenvector if feasible (ρ ≤ λ), or None if infeasible
    """
    n = W.shape[0]
    A = W - lam

    # Bellman iteration
    best = np.zeros(n)  # best walk weight of length 0
    potential = best.copy()

    for m in range(1, n):
        new_best = np.array([np.max(A[i, :] + best) for i in range(n)])
        potential = np.maximum(potential, new_best)
        best = new_best

    # Check if lambda is feasible
    # Need: A_ij + potential_j ≤ potential_i for all i, j
    for i in range(n):
        for j in range(n):
            if A[i, j] + potential[j] > potential[i] + 1e-10:
                return None

    return potential


def tropical_mat_pow(W: np.ndarray, k: int) -> np.ndarray:
    """Compute the k-th tropical matrix power.

    (W^{⊗k})_{ij} = max over walks of length k from i to j of total weight.

    Time complexity: O(n^3 * k)

    Args:
        W: n×n weight matrix
        k: power

    Returns:
        W^{⊗k}: the k-th tropical power
    """
    n = W.shape[0]
    if k == 0:
        # Tropical identity: 0 on diagonal, -inf off diagonal
        result = np.full((n, n), -np.inf)
        np.fill_diagonal(result, 0.0)
        return result

    result = W.copy()
    for _ in range(k - 1):
        new_result = np.full((n, n), -np.inf)
        for i in range(n):
            for j in range(n):
                for m in range(n):
                    new_result[i, j] = max(new_result[i, j], result[i, m] + W[m, j])
        result = new_result
    return result


def verify_collatz_wielandt(W: np.ndarray) -> dict:
    """Verify the Collatz-Wielandt theorem for a given matrix.

    Returns a dictionary with verification results.
    """
    n = W.shape[0]

    # Compute spectral radius
    rho, cycle = karp_max_cycle_mean(W)

    # Construct potential at lambda = rho
    x = bellman_ford_potential(W, rho)

    # Check subeigenvector condition
    if x is not None:
        Wx = np.array([np.max(W[i, :] + x) for i in range(n)])
        residual = np.max(Wx - x - rho)
        subeig_ok = residual <= 1e-10
    else:
        subeig_ok = False
        residual = float('inf')

    # Check at lambda = rho - epsilon (should fail)
    eps = 0.1
    x_fail = bellman_ford_potential(W, rho - eps)

    return {
        'n': n,
        'rho': rho,
        'cycle': cycle,
        'potential': x,
        'subeig_verified': subeig_ok,
        'residual': residual,
        'infeasible_below_rho': x_fail is None,
    }


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("Karp's Algorithm Demo")
    print("=" * 50)

    W = np.array([
        [0, 5, 1],
        [2, 0, 4],
        [3, 1, 0]
    ], dtype=float)

    rho, cycle = karp_max_cycle_mean(W)
    print(f"Matrix W:\n{W}")
    print(f"Max cycle mean (Karp): {rho:.4f}")
    print(f"Witnessing cycle: {cycle}")

    print("\nBellman-Ford Potential Construction")
    print("=" * 50)
    x = bellman_ford_potential(W, rho)
    print(f"Potential at λ = ρ = {rho:.4f}: {x}")

    print("\nCollatz-Wielandt Verification")
    print("=" * 50)
    result = verify_collatz_wielandt(W)
    for key, val in result.items():
        print(f"  {key}: {val}")

    print("\nTropical Matrix Powers")
    print("=" * 50)
    for k in range(1, 5):
        Wk = tropical_mat_pow(W, k)
        diag_mean = max(Wk[i, i] / k for i in range(W.shape[0]))
        print(f"  k={k}: max_i W^{{⊗{k}}}[i,i]/{k} = {diag_mean:.4f}")
    print(f"  Converges to ρ = {rho:.4f}")
