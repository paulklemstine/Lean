#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Thermodynamic Formalism of Arithmetic Orbits

Implements the core computational algorithms:
1. Efficient free energy computation via tail decomposition
2. Tail exponent estimation via regression
3. Critical exponent classification
4. Polylog partition function evaluation
"""

import numpy as np
from typing import Callable, Tuple, Optional, List


def compute_stopping_times(step: Callable[[int], int],
                           target: Callable[[int], bool],
                           N: int,
                           max_iter: int = 100000) -> np.ndarray:
    """
    Compute stopping times tau(n) for n = 1, ..., N.

    Parameters
    ----------
    step : callable
        One-step map T: N -> N.
    target : callable
        Target predicate (e.g., lambda x: x <= 1 for Collatz).
    N : int
        Upper bound on the range of n.
    max_iter : int
        Maximum iterations before declaring non-convergence.

    Returns
    -------
    taus : ndarray of shape (N+1,)
        taus[n] = stopping time of n. taus[0] is unused.

    Complexity: O(N * max_tau) time, O(N) space.
    """
    taus = np.zeros(N + 1, dtype=int)
    for n in range(1, N + 1):
        x = n
        k = 0
        while not target(x) and k < max_iter:
            x = step(x)
            k += 1
        taus[n] = k
    return taus


def compute_tail_masses(taus: np.ndarray, w: np.ndarray,
                        M: Optional[int] = None) -> np.ndarray:
    """
    Compute tail masses T(m) = sum_{n: tau(n) > m} w(n) for m = 0, ..., M-1.

    Uses a cumulative histogram for O(N + M) efficiency instead of
    naive O(N * M).

    Parameters
    ----------
    taus : ndarray
        Stopping times, taus[n] for n = 1, ..., N.
    w : ndarray
        Weights, w[n] for n = 1, ..., N. Same shape as taus.
    M : int, optional
        Maximum m value. Defaults to max(taus) + 1.

    Returns
    -------
    tail : ndarray of shape (M,)
        tail[m] = sum of w[n] for n with taus[n] > m.

    Complexity: O(N + M) time, O(M) space.
    """
    N = len(taus) - 1
    if M is None:
        M = int(np.max(taus)) + 1

    # Build histogram: hist[k] = sum of w[n] for n with taus[n] == k
    hist = np.zeros(M + 1)
    for n in range(1, N + 1):
        k = min(int(taus[n]), M)
        hist[k] += w[n]

    # Tail mass: tail[m] = sum_{k > m} hist[k] = total - sum_{k <= m} hist[k]
    cumsum = np.cumsum(hist)
    total = cumsum[-1]
    tail = np.zeros(M)
    for m in range(M):
        tail[m] = total - cumsum[m]

    return tail


def compute_free_energy_via_tails(tail: np.ndarray, gamma: float) -> float:
    """
    Compute F_N(gamma) = sum_{m=0}^{M-1} gamma^m * tail[m].

    This is the efficient O(M) algorithm using the tail decomposition
    (Theorem: freeEnergyTrunc_eq_tail_sum).

    Parameters
    ----------
    tail : ndarray
        Tail masses from compute_tail_masses.
    gamma : float
        Discount factor in [0, 1).

    Returns
    -------
    F : float
        Free energy value.
    """
    M = len(tail)
    powers = gamma ** np.arange(M)
    return float(np.dot(powers, tail))


def compute_free_energy_direct(taus: np.ndarray, w: np.ndarray,
                               gamma: float) -> float:
    """
    Compute F_N(gamma) directly: sum_{n=1}^{N} w(n) * V_gamma(n).

    Complexity: O(N * max_tau).
    """
    N = len(taus) - 1
    F = 0.0
    for n in range(1, N + 1):
        if abs(gamma - 1.0) < 1e-15:
            V = float(taus[n])
        else:
            V = (1.0 - gamma**taus[n]) / (1.0 - gamma)
        F += w[n] * V
    return F


def estimate_tail_exponent(tail: np.ndarray,
                           m_min: int = 5,
                           m_max: Optional[int] = None) -> Tuple[float, float, float]:
    """
    Estimate the tail exponent beta from tail mass data.

    Fits log(tail[m]) ~ -beta * log(m+1) + C via least squares.

    Parameters
    ----------
    tail : ndarray
        Tail masses.
    m_min : int
        Minimum m for the fit (avoid boundary effects).
    m_max : int, optional
        Maximum m for the fit.

    Returns
    -------
    beta : float
        Estimated tail exponent.
    C : float
        Estimated log-constant.
    r_squared : float
        R² of the fit.
    """
    if m_max is None:
        # Find last nonzero tail mass
        nonzero = np.where(tail > 0)[0]
        if len(nonzero) == 0:
            return 0.0, 0.0, 0.0
        m_max = int(nonzero[-1])

    ms = np.arange(m_min, m_max + 1)
    valid = tail[ms] > 0
    ms = ms[valid]
    if len(ms) < 3:
        return 0.0, 0.0, 0.0

    log_m1 = np.log(ms + 1)
    log_tail = np.log(tail[ms])

    # Linear regression: log_tail = -beta * log_m1 + C
    A = np.vstack([log_m1, np.ones_like(log_m1)]).T
    result = np.linalg.lstsq(A, log_tail, rcond=None)
    slope, intercept = result[0]

    # R²
    predicted = slope * log_m1 + intercept
    ss_res = np.sum((log_tail - predicted) ** 2)
    ss_tot = np.sum((log_tail - np.mean(log_tail)) ** 2)
    r_squared = 1.0 - ss_res / ss_tot if ss_tot > 0 else 0.0

    return -slope, intercept, r_squared


def classify_divergence(beta: float) -> str:
    """
    Classify the divergence regime of F_N(gamma) as gamma -> 1.

    Parameters
    ----------
    beta : float
        Tail exponent.

    Returns
    -------
    classification : str
        One of 'power_divergence', 'log_divergence', 'bounded'.
    """
    if beta < 1.0 - 1e-6:
        return f"power_divergence: F ~ (1-gamma)^({beta-1:.3f})"
    elif abs(beta - 1.0) < 1e-6:
        return "log_divergence: F ~ log(1/(1-gamma))"
    else:
        return f"bounded: F stays finite as gamma -> 1 (beta={beta:.3f} > 1)"


def polylog_partition(gamma: float, beta: float, M: int) -> float:
    """
    Compute Phi_beta(gamma) = sum_{m=0}^{M-1} gamma^m / (m+1)^beta.

    Parameters
    ----------
    gamma : float
        Discount factor.
    beta : float
        Exponent.
    M : int
        Truncation level.

    Returns
    -------
    Phi : float
        Polylog partition value.
    """
    ms = np.arange(M)
    return float(np.sum(gamma**ms / (ms + 1)**beta))


def sandwich_bounds(tail: np.ndarray, gamma: float, beta: float,
                    M: int) -> Tuple[float, float, float]:
    """
    Compute sandwich bounds: A * Phi <= F <= B * Phi.

    Estimates A, B from the tail masses and returns (A*Phi, F, B*Phi).

    Parameters
    ----------
    tail : ndarray
        Tail masses.
    gamma : float
        Discount factor.
    beta : float
        Exponent.
    M : int
        Truncation level.

    Returns
    -------
    lower : float
        A * Phi_beta(gamma, M).
    F : float
        Actual free energy.
    upper : float
        B * Phi_beta(gamma, M).
    """
    ms = np.arange(min(M, len(tail)))
    refs = 1.0 / (ms + 1)**beta

    # Compute ratios tail[m] / ref[m]
    valid = refs > 0
    ratios = tail[ms[valid]] / refs[valid]

    A = float(np.min(ratios)) if len(ratios) > 0 else 0.0
    B = float(np.max(ratios)) if len(ratios) > 0 else 0.0

    Phi = polylog_partition(gamma, beta, M)
    F = compute_free_energy_via_tails(tail[:M], gamma)

    return A * Phi, F, B * Phi


# ═══════════════════════════════════════════════════════════════════
# Example usage
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    # Collatz setup
    collatz = lambda n: n // 2 if n % 2 == 0 else 3 * n + 1
    target = lambda x: x <= 1

    N = 1000
    print(f"Computing stopping times for n = 1..{N}...")
    taus = compute_stopping_times(collatz, target, N)
    w = np.ones(N + 1) / N  # Uniform weights
    w[0] = 0

    M = int(np.max(taus)) + 1
    print(f"Max stopping time: {M - 1}")

    print("\nComputing tail masses...")
    tail = compute_tail_masses(taus, w, M)

    print("\nEstimating tail exponent...")
    beta, C, r2 = estimate_tail_exponent(tail)
    print(f"  beta = {beta:.4f}, C = {C:.4f}, R² = {r2:.6f}")
    print(f"  Classification: {classify_divergence(beta)}")

    print("\nFree energy comparison (tail decomposition vs direct):")
    for gamma in [0.5, 0.9, 0.95, 0.99]:
        F_tail = compute_free_energy_via_tails(tail, gamma)
        F_direct = compute_free_energy_direct(taus, w, gamma)
        print(f"  gamma={gamma:.2f}: tail={F_tail:.8f}, direct={F_direct:.8f}, "
              f"diff={abs(F_tail - F_direct):.2e}")

    print("\nSandwich bounds (beta estimated from data):")
    for gamma in [0.5, 0.8, 0.9, 0.95, 0.99]:
        lo, F, hi = sandwich_bounds(tail, gamma, beta, M)
        print(f"  gamma={gamma:.2f}: {lo:.6f} <= {F:.6f} <= {hi:.6f}")
