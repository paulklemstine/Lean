#!/usr/bin/env python3
"""
Tropical Time Travel: Algorithms for Min-Plus CTC Consistency

Implements algorithms from the research paper:
  1. Tropical affine fixed-point iteration (Bellman-Ford style)
  2. Discounted tropical contraction solver
  3. Cycle-mean computation for chronology protection verification
  4. Consistency checker for causal graphs
"""

import numpy as np
from typing import Tuple, List, Optional
from dataclasses import dataclass


# ─────────────────────────────────────────────────
# Algorithm 1: Tropical Affine Fixed-Point Iteration
# ─────────────────────────────────────────────────

def tropical_fixed_point_iteration(
    A: np.ndarray,
    b: np.ndarray,
    x0: Optional[np.ndarray] = None,
    lam: float = 1.0,
    max_iter: int = 1000,
    tol: float = 1e-12
) -> Tuple[np.ndarray, int, bool]:
    """
    Compute the fixed point of the (discounted) tropical affine map:
        F(x)_i = min( min_j(A[i,j] + λ·x[j]), b[i] )

    Uses Picard iteration (equivalent to Bellman-Ford for shortest paths).

    Parameters
    ----------
    A : (n, n) array — min-plus weight matrix
    b : (n,) array — bias / boundary vector
    x0 : (n,) array or None — initial state (defaults to b)
    lam : float — discount factor, 0 ≤ λ ≤ 1
    max_iter : int — maximum iterations
    tol : float — convergence tolerance (sup-norm)

    Returns
    -------
    x : (n,) array — approximate fixed point
    iters : int — number of iterations used
    converged : bool — whether convergence was achieved

    Complexity
    ----------
    Time:  O(max_iter · n²)
    Space: O(n²) for A, O(n) for x

    Example
    -------
    >>> A = np.array([[0, 2], [3, 0]], dtype=float)
    >>> b = np.array([1.0, 0.5])
    >>> x, iters, ok = tropical_fixed_point_iteration(A, b, lam=0.5)
    >>> print(f"Fixed point: {x}, converged in {iters} steps")
    """
    n = A.shape[0]
    x = x0.copy() if x0 is not None else b.copy()

    for it in range(1, max_iter + 1):
        # Compute tropical matrix-vector product with discount
        Tx = np.array([np.min(A[i, :] + lam * x) for i in range(n)])
        x_new = np.minimum(Tx, b)

        if np.max(np.abs(x_new - x)) < tol:
            return x_new, it, True
        x = x_new

    return x, max_iter, False


# ─────────────────────────────────────────────────
# Algorithm 2: Minimum Cycle Mean (Karp's Algorithm)
# ─────────────────────────────────────────────────

def minimum_cycle_mean(A: np.ndarray) -> float:
    """
    Compute the minimum cycle mean of a weighted directed graph.

    Uses Karp's algorithm:
        λ* = min_v max_k (d[n][v] - d[k][v]) / (n - k)

    where d[k][v] is the minimum weight of a walk of length k ending at v.

    The minimum cycle mean is the tropical analogue of the spectral radius.
    Positive minimum cycle mean ↔ chronology protection (no zero-cost loops).

    Parameters
    ----------
    A : (n, n) array — weight matrix (use np.inf for absent edges)

    Returns
    -------
    float — minimum cycle mean (np.inf if graph is acyclic)

    Complexity
    ----------
    Time:  O(n³)
    Space: O(n²)

    Example
    -------
    >>> A = np.array([[np.inf, 1, np.inf],
    ...               [np.inf, np.inf, 2],
    ...               [3, np.inf, np.inf]])
    >>> print(f"Min cycle mean: {minimum_cycle_mean(A)}")  # (1+2+3)/3 = 2.0
    """
    n = A.shape[0]
    INF = np.inf

    # d[k][v] = min weight of a walk of exactly k edges ending at v
    d = np.full((n + 1, n), INF)
    # Start: walks of length 0 from every vertex have weight 0
    for v in range(n):
        d[0][v] = 0.0

    for k in range(1, n + 1):
        for v in range(n):
            for u in range(n):
                if d[k-1][u] < INF and A[u][v] < INF:
                    d[k][v] = min(d[k][v], d[k-1][u] + A[u][v])

    # Karp's formula
    mcm = INF
    for v in range(n):
        if d[n][v] < INF:
            max_ratio = -INF
            for k in range(n):
                if d[k][v] < INF:
                    ratio = (d[n][v] - d[k][v]) / (n - k)
                    max_ratio = max(max_ratio, ratio)
            mcm = min(mcm, max_ratio)

    return mcm


# ─────────────────────────────────────────────────
# Algorithm 3: Chronology Protection Checker
# ─────────────────────────────────────────────────

@dataclass
class ChronologyReport:
    """Result of chronology protection analysis."""
    is_protected: bool
    min_cycle_mean: float
    has_unique_fixed_point: bool
    fixed_point: Optional[np.ndarray]
    iterations: int
    explanation: str


def check_chronology_protection(
    A: np.ndarray,
    b: np.ndarray,
    lam: float = 1.0,
    tol: float = 1e-10
) -> ChronologyReport:
    """
    Analyze a tropical CTC system for chronology protection.

    Checks:
    1. Minimum cycle mean of A (positive → no zero-cost loops)
    2. Whether the (discounted) tropical affine map converges
    3. Uniqueness of the fixed point

    Parameters
    ----------
    A : (n, n) array — causal weight matrix
    b : (n,) array — bias vector
    lam : float — discount factor
    tol : float — numerical tolerance

    Returns
    -------
    ChronologyReport with analysis results

    Example
    -------
    >>> A = np.array([[0, 2], [3, 0]], dtype=float)
    >>> b = np.array([1.0, 0.5])
    >>> report = check_chronology_protection(A, b, lam=0.8)
    >>> print(report.explanation)
    """
    n = A.shape[0]

    # Step 1: Compute minimum cycle mean
    mcm = minimum_cycle_mean(A)

    # Step 2: Try to find fixed point from multiple starting points
    fps = []
    total_iters = 0
    for trial in range(5):
        x0 = np.random.randn(n) * 10
        fp, iters, converged = tropical_fixed_point_iteration(
            A, b, x0=x0, lam=lam, tol=tol
        )
        total_iters += iters
        if converged:
            # Check if this is a genuinely new fixed point
            is_new = True
            for existing_fp in fps:
                if np.max(np.abs(fp - existing_fp)) < tol * 100:
                    is_new = False
                    break
            if is_new:
                fps.append(fp)

    # Step 3: Assess protection
    is_protected = (mcm > 0 or lam < 1.0) and len(fps) <= 1
    has_unique = len(fps) == 1

    # Build explanation
    parts = []
    if mcm == np.inf:
        parts.append("Graph is acyclic (no directed cycles).")
    elif mcm > 0:
        parts.append(f"Minimum cycle mean = {mcm:.4f} > 0: no zero-cost causal loops.")
    else:
        parts.append(f"Minimum cycle mean = {mcm:.4f} ≤ 0: potential causal instability.")

    if lam < 1.0:
        parts.append(f"Discount factor λ={lam} < 1: system is contractive.")

    if has_unique:
        parts.append(f"Unique fixed point found: {np.round(fps[0], 6)}.")
    elif len(fps) > 1:
        parts.append(f"Multiple fixed points detected ({len(fps)} found). Not chronology-protected.")
    else:
        parts.append("No fixed point found within iteration budget.")

    if is_protected:
        parts.append("VERDICT: System is chronology-protected.")
    else:
        parts.append("VERDICT: System may NOT be chronology-protected.")

    return ChronologyReport(
        is_protected=is_protected,
        min_cycle_mean=mcm,
        has_unique_fixed_point=has_unique,
        fixed_point=fps[0] if fps else None,
        iterations=total_iters,
        explanation="\n".join(parts)
    )


# ─────────────────────────────────────────────────
# Algorithm 4: Paradox-Free Path Finder
# ─────────────────────────────────────────────────

def find_consistent_history(
    A: np.ndarray,
    b: np.ndarray,
    lam: float = 0.9,
    max_iter: int = 500
) -> Tuple[np.ndarray, List[np.ndarray]]:
    """
    Find a self-consistent history for a tropical CTC system.

    Returns the fixed point (consistent history) and the full
    trajectory of iterates for visualization.

    Parameters
    ----------
    A : (n, n) array — causal weight matrix
    b : (n,) array — bias / initial history
    lam : float — discount factor for stability
    max_iter : int — iteration budget

    Returns
    -------
    fixed_point : (n,) array
    trajectory : list of (n,) arrays — iterates x₀, x₁, ..., x_T

    Complexity
    ----------
    Time:  O(max_iter · n²)
    Space: O(max_iter · n) for trajectory storage
    """
    n = A.shape[0]
    x = b.copy()
    trajectory = [x.copy()]

    for _ in range(max_iter):
        Tx = np.array([np.min(A[i, :] + lam * x) for i in range(n)])
        x_new = np.minimum(Tx, b)
        trajectory.append(x_new.copy())
        if np.max(np.abs(x_new - x)) < 1e-14:
            break
        x = x_new

    return x, trajectory


# ─────────────────────────────────────────────────
# Demo / self-test
# ─────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Tests")
    print("=" * 60)

    # Test 1: Fixed-point iteration
    A = np.array([[0, 2, 5], [3, 0, 2], [4, 3, 0]], dtype=float)
    b = np.array([1.0, 0.5, 2.0])
    fp, iters, ok = tropical_fixed_point_iteration(A, b, lam=0.5)
    print(f"\nFixed-point iteration: converged={ok}, iters={iters}")
    print(f"  Fixed point: {np.round(fp, 8)}")

    # Test 2: Minimum cycle mean
    A_cycle = np.array([[np.inf, 1, np.inf],
                         [np.inf, np.inf, 2],
                         [3, np.inf, np.inf]])
    mcm = minimum_cycle_mean(A_cycle)
    print(f"\nMinimum cycle mean: {mcm}")  # Should be 2.0

    # Test 3: Chronology protection
    report = check_chronology_protection(A, b, lam=0.5)
    print(f"\nChronology report:\n{report.explanation}")

    # Test 4: Consistent history
    fp2, traj = find_consistent_history(A, b, lam=0.5)
    print(f"\nConsistent history found in {len(traj)-1} steps")
    print(f"  Final state: {np.round(fp2, 8)}")
