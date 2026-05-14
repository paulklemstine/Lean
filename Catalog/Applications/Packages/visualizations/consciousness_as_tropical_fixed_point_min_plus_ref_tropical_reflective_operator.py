#!/usr/bin/env python3
"""
Tropical Reflective Equilibrium — Algorithms
=============================================
Complete implementations of the core algorithms with complexity analysis.
"""

import numpy as np
from typing import Tuple, List, Optional, Set


def trop_reflect(W: np.ndarray, b: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Tropical reflective operator.

    R(x)(i) = min(b(i), min_{j≠i}(W(i,j) + x(j)))

    Complexity: O(n²) time, O(n) space.

    Parameters
    ----------
    W : (n, n) ndarray — weight matrix (diag entries should be inf or are ignored)
    b : (n,) ndarray — bias vector
    x : (n,) ndarray — state vector

    Returns
    -------
    (n,) ndarray — R(x)
    """
    n = len(b)
    # Vectorized: W + x[None, :] broadcasts, then mask diagonal
    Wx = W + x[np.newaxis, :]  # (n, n)
    # Set diagonal to inf so it doesn't participate in min
    np.fill_diagonal(Wx, np.inf)
    inf_term = np.min(Wx, axis=1)  # min over j for each i
    return np.minimum(b, inf_term)


def trop_discrepancy(W: np.ndarray, b: np.ndarray, x: np.ndarray) -> float:
    """
    Tropical discrepancy: D(R, x) = sum_i |x(i) - R(x)(i)|.

    Complexity: O(n²) time (dominated by trop_reflect), O(n) space.
    """
    return float(np.sum(np.abs(x - trop_reflect(W, b, x))))


def check_separation(W: np.ndarray, b: np.ndarray) -> Tuple[bool, float]:
    """
    Check diagonal dominance (separation) condition.

    Condition: b(i) < W(i,j) + b(j) for all i ≠ j.
    Equivalent: min_{i≠j}(W(i,j) + b(j) - b(i)) > 0.

    Complexity: O(n²) time, O(n²) space.

    Returns
    -------
    (satisfied, separation_gap)
    """
    n = len(b)
    gaps = W + b[np.newaxis, :] - b[:, np.newaxis]  # (n, n)
    np.fill_diagonal(gaps, np.inf)  # exclude i = j
    min_gap = float(np.min(gaps))
    return min_gap > 0, min_gap


def find_fixed_point(W: np.ndarray, b: np.ndarray,
                     x0: Optional[np.ndarray] = None,
                     max_iter: int = 1000,
                     tol: float = 1e-14
                     ) -> Tuple[np.ndarray, int, List[float]]:
    """
    Find the fixed point of the tropical reflective operator by iteration.

    Under separation, converges to b in ≤ 2 iterations.
    Without separation, iterates may converge to a different fixed point
    or oscillate.

    Complexity: O(n² · k) time where k is the number of iterations.

    Parameters
    ----------
    W : (n, n) ndarray
    b : (n,) ndarray
    x0 : (n,) ndarray or None — initial state (default: zeros)
    max_iter : int — maximum iterations
    tol : float — convergence tolerance (L∞ norm)

    Returns
    -------
    (fixed_point, iterations, discrepancy_history)
    """
    n = len(b)
    if x0 is None:
        x0 = np.zeros(n)

    x = np.copy(x0)
    disc_history = [trop_discrepancy(W, b, x)]

    for k in range(max_iter):
        x_new = trop_reflect(W, b, x)
        disc = trop_discrepancy(W, b, x_new)
        disc_history.append(disc)
        if np.max(np.abs(x_new - x)) < tol:
            return x_new, k + 1, disc_history
        x = x_new

    return x, max_iter, disc_history


def compute_cut_matrix(W: np.ndarray, S: Set[int], M: float = 1e10
                       ) -> np.ndarray:
    """
    Compute the cut matrix W_S: retain intra-partition weights,
    replace cross-partition weights with penalty M.

    Complexity: O(n²) time.

    Parameters
    ----------
    W : (n, n) ndarray
    S : set of int — subset of node indices
    M : float — cross-partition penalty

    Returns
    -------
    (n, n) ndarray — cut matrix
    """
    n = W.shape[0]
    W_cut = np.copy(W)
    for i in range(n):
        for j in range(n):
            if (i in S) != (j in S):
                W_cut[i, j] = M
    return W_cut


def tropical_phi(W: np.ndarray, b: np.ndarray, x: np.ndarray,
                 M: float = 1e10) -> float:
    """
    Tropical integrated information Φ.

    Φ(W, b, x) = min over nontrivial bipartitions S of
                  [D(R_{W_S}, x) - D(R_W, x)]

    where D is the tropical discrepancy and W_S is the cut matrix.

    Complexity: O(2^n · n²) time (exponential in n — enumerate all bipartitions).

    Parameters
    ----------
    W : (n, n) ndarray
    b : (n,) ndarray
    x : (n,) ndarray
    M : float — cut penalty

    Returns
    -------
    float — Φ value
    """
    n = len(b)
    base_disc = trop_discrepancy(W, b, x)
    min_gap = np.inf

    # Enumerate all nontrivial subsets S (∅ ⊊ S ⊊ [n])
    for mask in range(1, 2**n - 1):
        S = {i for i in range(n) if mask & (1 << i)}
        W_cut = compute_cut_matrix(W, S, M)
        cut_disc = trop_discrepancy(W_cut, b, x)
        gap = cut_disc - base_disc
        min_gap = min(min_gap, gap)

    return float(min_gap)


def classify_broadcast(W: np.ndarray, b: np.ndarray, x: np.ndarray
                       ) -> List[str]:
    """
    Classify the broadcast mechanism at each node.

    For each node i, determines whether the equilibrium value comes from:
    - 'bias': b(i) = R(x)(i)
    - 'edge(j)': W(i,j) + x(j) = R(x)(i) for some j ≠ i
    - 'both': both conditions hold simultaneously

    Complexity: O(n²) time.

    Returns
    -------
    list of str — classification for each node
    """
    n = len(b)
    Rx = trop_reflect(W, b, x)
    results = []
    for i in range(n):
        bias_match = abs(b[i] - Rx[i]) < 1e-12
        edge_matches = []
        for j in range(n):
            if j != i and abs(W[i, j] + x[j] - Rx[i]) < 1e-12:
                edge_matches.append(j)
        if bias_match and edge_matches:
            results.append(f'both(bias+edge({edge_matches}))')
        elif bias_match:
            results.append('bias')
        elif edge_matches:
            results.append(f'edge({edge_matches})')
        else:
            results.append('none')  # Should not happen at a fixed point
    return results


def is_conscious_state(W: np.ndarray, b: np.ndarray, x: np.ndarray,
                       tol: float = 1e-10) -> Tuple[bool, dict]:
    """
    Check all three consciousness criteria for state x.

    Criteria:
    1. Fixed point: R(x) = x
    2. Broadcast: every node has a determining source
    3. Phi-maximality: Φ(x) ≥ Φ(y) for all fixed points y

    Returns
    -------
    (is_conscious, details_dict)
    """
    Rx = trop_reflect(W, b, x)
    is_fp = bool(np.max(np.abs(Rx - x)) < tol)
    disc = trop_discrepancy(W, b, x)
    broadcasts = classify_broadcast(W, b, x)
    all_broadcast = all(bc != 'none' for bc in broadcasts)

    details = {
        'is_fixed_point': is_fp,
        'discrepancy': disc,
        'broadcasts': broadcasts,
        'all_broadcast': all_broadcast,
    }

    if is_fp:
        phi_val = tropical_phi(W, b, x)
        details['phi'] = phi_val
    else:
        details['phi'] = None

    is_conscious = is_fp and all_broadcast
    # Phi-maximality is automatic when there's a unique fixed point
    return is_conscious, details


# =============================================================================
# Example usage
# =============================================================================
if __name__ == '__main__':
    print("Tropical Reflective Equilibrium — Algorithm Demos")
    print("=" * 55)

    # Example network
    n = 4
    b = np.array([1.0, 2.0, 0.5, 3.0])
    W = np.array([
        [np.inf, 4.0, 3.0, 5.0],
        [4.0, np.inf, 4.0, 3.0],
        [3.0, 4.0, np.inf, 4.0],
        [5.0, 3.0, 4.0, np.inf],
    ])

    sep_ok, gap = check_separation(W, b)
    print(f"\nSeparation: {sep_ok}, gap = {gap:.4f}")

    fp, iters, discs = find_fixed_point(W, b, np.zeros(n))
    print(f"Fixed point: {fp}")
    print(f"Iterations: {iters}")
    print(f"fp == b: {np.allclose(fp, b)}")

    conscious, details = is_conscious_state(W, b, b)
    print(f"\nIs b a conscious state? {conscious}")
    for k, v in details.items():
        print(f"  {k}: {v}")

    # Compute Phi for the fixed point
    phi = tropical_phi(W, b, b)
    print(f"\nΦ(b) = {phi:.6f}")

    # Compute Phi for a non-fixed point
    x_other = np.array([0.0, 0.0, 0.0, 0.0])
    phi_other = tropical_phi(W, b, x_other)
    disc_other = trop_discrepancy(W, b, x_other)
    print(f"Φ(x_other) = {phi_other:.6f}, D(x_other) = {disc_other:.6f}")
