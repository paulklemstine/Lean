#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for finite-temperature tropical margin theory.

Implements the mathematical objects and computational methods from the
positive-temperature tropicalization framework:
  - Log-sum-exp (free energy / soft maximum)
  - Gibbs weights (softmax / Boltzmann probabilities)
  - Diagonal-exclusion slack and tropical margin
  - Soft margin (finite-temperature tropical margin)
  - Phase width estimation

All algorithms include docstrings, type hints, and numerical stability
considerations.
"""

from __future__ import annotations
import numpy as np
from typing import Optional


def log_sum_exp(beta: float, a: np.ndarray) -> float:
    """
    Compute the log-sum-exp functional (free energy / soft maximum).

    LSE_β(a) = (1/β) * log(∑ᵢ exp(β * aᵢ))

    Uses the max-subtraction trick for numerical stability.

    Parameters
    ----------
    beta : float
        Inverse temperature parameter (must be > 0).
    a : np.ndarray
        Array of real values.

    Returns
    -------
    float
        The log-sum-exp value.

    Complexity
    ----------
    Time: O(n) where n = len(a)
    Space: O(n)

    Examples
    --------
    >>> log_sum_exp(1.0, np.array([1.0, 2.0, 3.0]))  # ≈ 3.41
    >>> log_sum_exp(100.0, np.array([1.0, 2.0, 3.0]))  # ≈ 3.0 (approaches max)
    """
    assert beta > 0, "β must be positive"
    scaled = beta * a
    max_val = np.max(scaled)
    return (1.0 / beta) * (max_val + np.log(np.sum(np.exp(scaled - max_val))))


def gibbs_weights(beta: float, a: np.ndarray) -> np.ndarray:
    """
    Compute Gibbs/Boltzmann weights (softmax probabilities).

    p_i = exp(β * a_i) / ∑_j exp(β * a_j)

    These form a probability distribution that concentrates on the
    maximizers of a as β → ∞.

    Parameters
    ----------
    beta : float
        Inverse temperature parameter (must be > 0).
    a : np.ndarray
        Array of real values.

    Returns
    -------
    np.ndarray
        Probability vector (nonneg, sums to 1).

    Complexity
    ----------
    Time: O(n)
    Space: O(n)
    """
    assert beta > 0, "β must be positive"
    scaled = beta * a
    scaled -= np.max(scaled)  # numerical stability
    w = np.exp(scaled)
    return w / np.sum(w)


def diag_ex_slack(W: np.ndarray, i: int, j: int) -> float:
    """
    Diagonal-exclusion slack: 2*W[i,j] - W[i,i] - W[j,j].

    Measures how far the (i,j) entry is from violating the diagonal
    dominance condition. The tropical margin is the minimum of these
    slacks over all distinct pairs.

    Parameters
    ----------
    W : np.ndarray
        Square matrix.
    i, j : int
        Row and column indices.

    Returns
    -------
    float
        The slack value.
    """
    return 2.0 * W[i, j] - W[i, i] - W[j, j]


def all_slacks(W: np.ndarray) -> np.ndarray:
    """
    Compute all diagonal-exclusion slacks for distinct pairs.

    Parameters
    ----------
    W : np.ndarray
        Square matrix of shape (n, n).

    Returns
    -------
    np.ndarray
        Array of slacks for all n*(n-1) distinct pairs.
    """
    n = W.shape[0]
    slacks = []
    for i in range(n):
        for j in range(n):
            if i != j:
                slacks.append(diag_ex_slack(W, i, j))
    return np.array(slacks)


def trop_margin(W: np.ndarray) -> float:
    """
    Tropical margin: minimum diagonal-exclusion slack over distinct pairs.

    This is the zero-temperature limit of the soft margin.

    Parameters
    ----------
    W : np.ndarray
        Square matrix.

    Returns
    -------
    float
        The tropical margin.

    Complexity
    ----------
    Time: O(n²)
    Space: O(1)
    """
    n = W.shape[0]
    if n < 2:
        return 0.0
    return float(np.min(all_slacks(W)))


def soft_margin(beta: float, W: np.ndarray) -> float:
    """
    Soft margin (finite-temperature tropical margin).

    Defined as -LSE_β(-slacks), i.e., the soft minimum of the slack family.
    Converges to trop_margin(W) as β → ∞.

    Satisfies the certified bounds:
        trop_margin(W) - log(num_pairs)/β ≤ soft_margin(β, W) ≤ trop_margin(W)

    Parameters
    ----------
    beta : float
        Inverse temperature (must be > 0).
    W : np.ndarray
        Square matrix.

    Returns
    -------
    float
        The soft margin.

    Complexity
    ----------
    Time: O(n²)
    Space: O(n²)
    """
    slacks = all_slacks(W)
    if len(slacks) == 0:
        return 0.0
    return -log_sum_exp(beta, -slacks)


def soft_margin_error_bound(beta: float, W: np.ndarray) -> float:
    """
    Certified error bound: |soft_margin(β, W) - trop_margin(W)| ≤ this value.

    The bound is log(num_distinct_pairs) / β.

    Parameters
    ----------
    beta : float
        Inverse temperature.
    W : np.ndarray
        Square matrix.

    Returns
    -------
    float
        Upper bound on the approximation error.
    """
    n = W.shape[0]
    num_pairs = n * (n - 1)
    return np.log(num_pairs) / beta if num_pairs > 0 else 0.0


def phase_width_estimate(beta: float, k: float = 1.0) -> float:
    """
    Thermal broadening width estimate: k/β.

    The transition layer around a tropical phase boundary has width
    proportional to 1/β, controlled by the constant k which depends
    on the local geometry of the slack crossing.

    Parameters
    ----------
    beta : float
        Inverse temperature.
    k : float
        Geometric constant (default 1.0).

    Returns
    -------
    float
        Estimated phase transition width.
    """
    return k / beta


def gibbs_entropy(beta: float, a: np.ndarray) -> float:
    """
    Shannon entropy of the Gibbs distribution: H(p) = -∑ p_i log(p_i).

    This measures the "thermal uncertainty" in the soft maximum.
    H → 0 as β → ∞ (concentration) and H → log(n) as β → 0 (uniform).

    Parameters
    ----------
    beta : float
        Inverse temperature.
    a : np.ndarray
        Array of values.

    Returns
    -------
    float
        Shannon entropy of the Gibbs weights.
    """
    p = gibbs_weights(beta, a)
    # Avoid log(0)
    p_safe = p[p > 1e-300]
    return -np.sum(p_safe * np.log(p_safe))


def free_energy_decomposition(beta: float, a: np.ndarray) -> dict:
    """
    Decompose log-sum-exp into energy and entropy terms.

    LSE_β(a) = ⟨a⟩_Gibbs + (1/β) H(p)

    where ⟨a⟩_Gibbs = ∑ p_i a_i is the Gibbs average (expected energy)
    and H(p) is the Shannon entropy.

    Parameters
    ----------
    beta : float
        Inverse temperature.
    a : np.ndarray
        Array of values.

    Returns
    -------
    dict
        Dictionary with keys 'lse', 'energy', 'entropy_term', 'entropy'.
    """
    lse = log_sum_exp(beta, a)
    p = gibbs_weights(beta, a)
    energy = np.sum(p * a)
    entropy = gibbs_entropy(beta, a)
    return {
        'lse': lse,
        'energy': energy,
        'entropy_term': entropy / beta,
        'entropy': entropy,
        'max': np.max(a),
    }


def sweep_beta(W: np.ndarray, betas: Optional[np.ndarray] = None) -> dict:
    """
    Sweep over inverse temperatures and compute margin data.

    Parameters
    ----------
    W : np.ndarray
        Square matrix.
    betas : np.ndarray, optional
        Array of β values (default: logspace from 0.1 to 100).

    Returns
    -------
    dict
        Dictionary with arrays 'betas', 'soft_margins', 'trop_margin',
        'errors', 'bounds'.
    """
    if betas is None:
        betas = np.logspace(-1, 2, 100)
    tm = trop_margin(W)
    sms = np.array([soft_margin(b, W) for b in betas])
    errors = np.abs(sms - tm)
    bounds = np.array([soft_margin_error_bound(b, W) for b in betas])
    return {
        'betas': betas,
        'soft_margins': sms,
        'trop_margin': tm,
        'errors': errors,
        'bounds': bounds,
    }


# ─── Example usage ──────────────────────────────────────────────────────

if __name__ == '__main__':
    # Example: 4x4 matrix
    W = np.array([
        [3.0, 1.0, 0.5, 0.2],
        [1.0, 2.5, 0.8, 0.3],
        [0.5, 0.8, 2.8, 0.6],
        [0.2, 0.3, 0.6, 2.2]
    ])

    print("Matrix W:")
    print(W)
    print(f"\nTropical margin: {trop_margin(W):.6f}")

    for beta in [1, 5, 10, 50]:
        sm = soft_margin(beta, W)
        eb = soft_margin_error_bound(beta, W)
        print(f"β={beta:3d}: soft_margin={sm:.6f}, error_bound={eb:.6f}")

    print("\nFree energy decomposition at β=5:")
    slacks = all_slacks(W)
    decomp = free_energy_decomposition(5.0, -slacks)
    for k, v in decomp.items():
        print(f"  {k}: {v:.6f}")
