"""
Tropical Transfer Operator Algorithms
======================================

Implementation of core algorithms from tropical (max-plus) spectral theory
for finite-state transfer operators.

Key algorithms:
- Tropical matrix-vector multiplication (Bellman step)
- Max cycle mean computation (Karp's algorithm)
- Tropical eigenvector construction
- Universality cell classification
- Critical exponent computation
"""

import numpy as np
from typing import Tuple, List, Optional, Dict, Set
from itertools import product


def trop_transfer(M: np.ndarray, v: np.ndarray) -> np.ndarray:
    """
    Apply the tropical (max-plus) transfer operator.

    T_M(v)[i] = max_j (M[i,j] + v[j])

    This is the Bellman operator for deterministic finite-state
    optimal control / dynamic programming.

    Parameters
    ----------
    M : np.ndarray, shape (n, n)
        Transfer matrix.
    v : np.ndarray, shape (n,)
        Potential vector.

    Returns
    -------
    np.ndarray, shape (n,)
        The transferred potential.

    Examples
    --------
    >>> M = np.array([[1.0, 2.0], [3.0, 0.0]])
    >>> v = np.array([0.0, 0.0])
    >>> trop_transfer(M, v)
    array([2., 3.])
    """
    n = M.shape[0]
    result = np.zeros(n)
    for i in range(n):
        result[i] = np.max(M[i, :] + v)
    return result


def normalized_trop_transfer(M: np.ndarray, v: np.ndarray) -> np.ndarray:
    """
    Apply the normalized tropical transfer: subtract the value at index 0.

    This gauge-fixes the operator so fixed points are genuine fixed points
    modulo the additive symmetry of max-plus algebra.

    Parameters
    ----------
    M : np.ndarray, shape (n, n)
    v : np.ndarray, shape (n,)

    Returns
    -------
    np.ndarray, shape (n,)
    """
    w = trop_transfer(M, v)
    return w - w[0]


def osc_norm(v: np.ndarray) -> float:
    """
    Oscillation seminorm: max(v) - min(v).

    Parameters
    ----------
    v : np.ndarray, shape (n,)

    Returns
    -------
    float
    """
    return float(np.max(v) - np.min(v))


def karp_max_cycle_mean(M: np.ndarray) -> float:
    """
    Compute the maximum cycle mean of matrix M using Karp's algorithm.

    The max cycle mean lambda* satisfies:
        lambda* = max over cycles c of (sum of edge weights on c) / |c|

    This is the tropical eigenvalue of M (when the digraph is strongly connected).

    Complexity: O(n^3) time, O(n^2) space.

    Parameters
    ----------
    M : np.ndarray, shape (n, n)

    Returns
    -------
    float
        The maximum cycle mean.

    Examples
    --------
    >>> M = np.array([[2.0, 1.0], [1.0, 2.0]])
    >>> karp_max_cycle_mean(M)
    2.0
    """
    n = M.shape[0]
    # F[k][i] = max weight of a path of length k ending at i
    F = np.full((n + 1, n), -np.inf)
    F[0, :] = 0.0

    for k in range(1, n + 1):
        for i in range(n):
            for j in range(n):
                val = F[k - 1][j] + M[j][i]
                if val > F[k][i]:
                    F[k][i] = val

    # Karp's formula: lambda* = max_i min_k (F[n][i] - F[k][i]) / (n - k)
    result = -np.inf
    for i in range(n):
        min_val = np.inf
        for k in range(n):
            if F[k][i] > -np.inf:
                val = (F[n][i] - F[k][i]) / (n - k)
                if val < min_val:
                    min_val = val
        if min_val < np.inf:
            result = max(result, min_val)

    return float(result)


def find_tropical_eigenpair(M: np.ndarray, max_iter: int = 1000,
                             tol: float = 1e-10) -> Tuple[float, np.ndarray]:
    """
    Find a tropical eigenpair (lambda, v) such that T_M(v) = lambda + v.

    Uses iterative power method on the normalized transfer operator,
    combined with Karp's algorithm for the eigenvalue.

    Parameters
    ----------
    M : np.ndarray, shape (n, n)
    max_iter : int
    tol : float

    Returns
    -------
    Tuple[float, np.ndarray]
        (eigenvalue, eigenvector)

    Examples
    --------
    >>> M = np.array([[1.0, 3.0], [2.0, 1.0]])
    >>> lam, v = find_tropical_eigenpair(M)
    >>> np.allclose(trop_transfer(M, v), lam + v, atol=1e-8)
    True
    """
    n = M.shape[0]
    lam = karp_max_cycle_mean(M)

    # Iterative method: start from zero, apply normalized transfer
    v = np.zeros(n)
    for _ in range(max_iter):
        v_new = normalized_trop_transfer(M, v)
        if np.max(np.abs(v_new - v)) < tol:
            v = v_new
            break
        v = v_new

    # Verify and refine eigenvalue
    w = trop_transfer(M, v)
    lam_refined = w[0]  # Since v is normalized with v[0]-like gauge

    return float(lam_refined), v


def tropical_spectral_gap(M: np.ndarray) -> Tuple[float, float, float]:
    """
    Compute the tropical spectral gap.

    Returns the top cycle mean lambda_1, the second cycle mean lambda_2,
    and the gap delta = lambda_1 - lambda_2.

    Parameters
    ----------
    M : np.ndarray, shape (n, n)

    Returns
    -------
    Tuple[float, float, float]
        (lambda_1, lambda_2, gap)
    """
    n = M.shape[0]
    lam1 = karp_max_cycle_mean(M)

    # Find all cycle means up to length n
    cycle_means = set()
    for length in range(1, n + 1):
        for start in range(n):
            _find_cycle_means(M, start, start, length, 0.0, 0, cycle_means)

    cycle_means_list = sorted(cycle_means, reverse=True)

    if len(cycle_means_list) >= 2:
        lam2 = cycle_means_list[1]
    else:
        lam2 = lam1  # Only one cycle mean

    return lam1, lam2, lam1 - lam2


def _find_cycle_means(M: np.ndarray, start: int, current: int,
                      target_len: int, weight_sum: float, depth: int,
                      results: set):
    """Helper to enumerate cycle means by DFS."""
    n = M.shape[0]
    if depth == target_len:
        if current == start:
            results.add(weight_sum / target_len)
        return
    for next_node in range(n):
        _find_cycle_means(M, start, next_node, target_len,
                         weight_sum + M[current][next_node],
                         depth + 1, results)


def critical_exponent(lam1: float, lam2: float) -> float:
    """
    Compute the critical exponent xi = 1 / (lambda_1 - lambda_2).

    Parameters
    ----------
    lam1 : float
        Top cycle mean.
    lam2 : float
        Second cycle mean.

    Returns
    -------
    float
        Critical exponent. Returns inf if gap is zero.
    """
    gap = lam1 - lam2
    if abs(gap) < 1e-15:
        return float('inf')
    return 1.0 / gap


def universality_invariant(M: np.ndarray) -> Dict[int, List[int]]:
    """
    Compute the universality invariant: for each row i,
    the set of column indices achieving the row maximum.

    Parameters
    ----------
    M : np.ndarray, shape (n, n)

    Returns
    -------
    Dict[int, List[int]]
        Maps row index to list of argmax column indices.

    Examples
    --------
    >>> M = np.array([[3.0, 1.0, 3.0], [2.0, 5.0, 1.0]])
    >>> universality_invariant(M)
    {0: [0, 2], 1: [1]}
    """
    n = M.shape[0]
    result = {}
    for i in range(n):
        row_max = np.max(M[i, :])
        argmaxes = [j for j in range(n) if abs(M[i, j] - row_max) < 1e-12]
        result[i] = argmaxes
    return result


def same_argmax_pattern(M: np.ndarray, N: np.ndarray) -> bool:
    """
    Check if two matrices have the same argmax pattern.

    Parameters
    ----------
    M, N : np.ndarray, shape (n, n)

    Returns
    -------
    bool
    """
    n = M.shape[0]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if (M[i, j] >= M[i, k]) != (N[i, j] >= N[i, k]):
                    return False
    return True


def classify_universality_cell(M: np.ndarray) -> Tuple[Tuple[int, ...], ...]:
    """
    Classify a matrix into its universality cell by computing
    the complete ordering pattern of each row.

    Returns a hashable representation of the cell.

    Parameters
    ----------
    M : np.ndarray, shape (n, n)

    Returns
    -------
    Tuple of tuples
        The sorted-rank pattern for each row.
    """
    n = M.shape[0]
    cell = []
    for i in range(n):
        # Get the rank ordering of row i
        order = tuple(np.argsort(-M[i, :]))
        cell.append(order)
    return tuple(cell)


def convergence_analysis(M: np.ndarray, v0: np.ndarray,
                         num_steps: int = 50) -> Dict:
    """
    Analyze convergence of the normalized tropical transfer iteration.

    Parameters
    ----------
    M : np.ndarray, shape (n, n)
    v0 : np.ndarray, shape (n,)
        Initial potential.
    num_steps : int

    Returns
    -------
    Dict with keys:
        'eigenvalue': float
        'eigenvector': np.ndarray
        'oscillations': List[float] - oscillation norm at each step
        'defects': List[float] - distance from fixed point at each step
        'gap': float
        'critical_exponent': float
    """
    lam, v_star = find_tropical_eigenpair(M)
    lam1, lam2, gap = tropical_spectral_gap(M)
    xi = critical_exponent(lam1, lam2)

    v = v0.copy()
    oscillations = [osc_norm(v)]
    defects = [np.max(np.abs(normalized_trop_transfer(M, v) - v))]

    for _ in range(num_steps):
        v = normalized_trop_transfer(M, v)
        oscillations.append(osc_norm(v))
        defects.append(np.max(np.abs(normalized_trop_transfer(M, v) - v)))

    return {
        'eigenvalue': lam,
        'eigenvector': v_star,
        'oscillations': oscillations,
        'defects': defects,
        'gap': gap,
        'critical_exponent': xi,
        'lam1': lam1,
        'lam2': lam2,
    }


if __name__ == "__main__":
    # Quick test
    M = np.array([[1.0, 3.0], [2.0, 1.0]])
    lam, v = find_tropical_eigenpair(M)
    print(f"Eigenvalue: {lam:.4f}")
    print(f"Eigenvector: {v}")
    print(f"Verification: T_M(v) = {trop_transfer(M, v)}, lam + v = {lam + v}")
    print(f"Max cycle mean (Karp): {karp_max_cycle_mean(M):.4f}")

    lam1, lam2, gap = tropical_spectral_gap(M)
    print(f"Spectral gap: {gap:.4f} (lam1={lam1:.4f}, lam2={lam2:.4f})")
    print(f"Critical exponent: {critical_exponent(lam1, lam2):.4f}")
    print(f"Universality invariant: {universality_invariant(M)}")
