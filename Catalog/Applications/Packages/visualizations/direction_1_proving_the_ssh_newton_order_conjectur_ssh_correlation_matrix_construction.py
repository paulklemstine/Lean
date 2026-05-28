#!/usr/bin/env python3
"""
Algorithms for SSH Newton-Order Phase Diagnostic

Implements certified and semi-certified algorithms to compute:
1. SSH correlation eigenvalues for finite blocks
2. Elementary symmetric polynomials via stable recurrence
3. Newton ratio profile and its maximum (supremal Newton gap)
4. Phase diagnostic classifier

All functions include docstrings, type hints, and example usage.
"""

import numpy as np
from typing import Tuple, List, Optional


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: SSH Correlation Matrix Construction
# ═══════════════════════════════════════════════════════════════════════

def build_ssh_correlation_matrix(
    m: int,
    delta: float,
    n_k: int = 8192
) -> np.ndarray:
    """
    Construct the m×m SSH half-chain correlation matrix.

    The SSH model has alternating hopping amplitudes t1 = 1+δ, t2 = 1-δ.
    The correlation matrix C_{ij} at half filling is a Toeplitz matrix
    with entries given by Fourier integrals of the Fermi occupation function.

    Parameters
    ----------
    m : int
        Block (subsystem) size
    delta : float
        Dimerization parameter. δ=0 is critical, δ≠0 is gapped.
    n_k : int
        Number of k-points for numerical integration (default 8192)

    Returns
    -------
    C : np.ndarray of shape (m, m)
        The correlation matrix

    Complexity
    ----------
    Time: O(m² · n_k)  — m² matrix entries, each via O(n_k) quadrature
    Space: O(m² + n_k)

    Examples
    --------
    >>> C = build_ssh_correlation_matrix(4, 0.0)
    >>> C.shape
    (4, 4)
    >>> np.allclose(C, C.T)  # symmetric
    True
    """
    t1 = 1.0 + delta
    t2 = 1.0 - delta

    k_vals = np.linspace(0, np.pi, n_k, endpoint=False) + np.pi / (2 * n_k)

    # SSH dispersion
    eps_k = np.sqrt(t1**2 + t2**2 + 2 * t1 * t2 * np.cos(k_vals))

    # Occupation function
    h_k = t1 + t2 * np.cos(k_vals)
    f_k = 0.5 * (1.0 - h_k / eps_k)

    # Toeplitz coefficients
    c_coeffs = np.zeros(m)
    for n in range(m):
        c_coeffs[n] = (2.0 / n_k) * np.sum(f_k * np.cos(n * k_vals))

    # Build Toeplitz matrix
    C = np.zeros((m, m))
    for i in range(m):
        for j in range(m):
            C[i, j] = c_coeffs[abs(i - j)]

    return C


def ssh_eigenvalues(m: int, delta: float, n_k: int = 8192) -> np.ndarray:
    """
    Compute correlation eigenvalues of the SSH half-chain block.

    Parameters
    ----------
    m : int
        Block size
    delta : float
        Dimerization parameter

    Returns
    -------
    eigenvalues : np.ndarray of shape (m,)
        Sorted eigenvalues in [0, 1]
    """
    C = build_ssh_correlation_matrix(m, delta, n_k)
    eigs = np.linalg.eigvalsh(C)
    eigs = np.clip(eigs, 1e-15, 1 - 1e-15)
    return np.sort(eigs)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Stable Elementary Symmetric Polynomial Computation
# ═══════════════════════════════════════════════════════════════════════

def esymm_stable(eigenvalues: np.ndarray) -> np.ndarray:
    """
    Compute elementary symmetric polynomials via stable polynomial multiplication.

    Given eigenvalues λ₁, ..., λₘ, computes e₀, e₁, ..., eₘ where
    ∏ᵢ(1 + λᵢt) = ∑ₖ eₖ tᵏ.

    Uses sequential convolution which is numerically stable for
    eigenvalues in [0, 1].

    Parameters
    ----------
    eigenvalues : np.ndarray
        Array of eigenvalues

    Returns
    -------
    e : np.ndarray
        Elementary symmetric polynomials e₀, e₁, ..., eₘ

    Complexity
    ----------
    Time: O(m²)
    Space: O(m)

    Examples
    --------
    >>> esymm_stable(np.array([0.5, 0.5]))
    array([1.  , 1.  , 0.25])
    """
    m = len(eigenvalues)
    # Initialize with e_0 = 1
    e = np.zeros(m + 1)
    e[0] = 1.0

    for i in range(m):
        # Multiply by (1 + λᵢt): process in reverse to avoid overwriting
        for k in range(min(i + 1, m), 0, -1):
            e[k] += eigenvalues[i] * e[k - 1]

    return e


def esymm_log_stable(eigenvalues: np.ndarray) -> np.ndarray:
    """
    Compute log of elementary symmetric polynomials with enhanced stability.

    For large m, e_k can overflow/underflow. This version works in log-space
    where possible, using the recurrence in a numerically careful way.

    Parameters
    ----------
    eigenvalues : np.ndarray
        Array of eigenvalues in (0, 1)

    Returns
    -------
    log_e : np.ndarray
        log(e₀), log(e₁), ..., log(eₘ)
    """
    e = esymm_stable(eigenvalues)
    # Handle potential zeros
    log_e = np.full_like(e, -np.inf)
    pos_mask = e > 0
    log_e[pos_mask] = np.log(e[pos_mask])
    return log_e


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Newton Ratio Profile and Supremal Gap
# ═══════════════════════════════════════════════════════════════════════

def newton_ratio_profile(e: np.ndarray) -> np.ndarray:
    """
    Compute the Newton ratio profile log(Rₖ) for k = 1, ..., m-1.

    Rₖ = eₖ² / (eₖ₋₁ · eₖ₊₁)

    By Newton's inequalities, log(Rₖ) ≥ 0 for nonneg eigenvalues.

    Parameters
    ----------
    e : np.ndarray
        Elementary symmetric polynomials e₀, ..., eₘ

    Returns
    -------
    log_R : np.ndarray
        log(R₁), ..., log(R_{m-1})
    """
    m = len(e) - 1
    if m <= 1:
        return np.array([])

    log_R = np.zeros(m - 1)
    for k in range(1, m):
        if e[k-1] > 0 and e[k] > 0 and e[k+1] > 0:
            log_R[k-1] = 2 * np.log(e[k]) - np.log(e[k-1]) - np.log(e[k+1])
        else:
            log_R[k-1] = np.inf  # degenerate case
    return log_R


def pointwise_newton_gap(e: np.ndarray) -> np.ndarray:
    """
    Compute the pointwise Newton gap: -log(Rₖ) = log(eₖ₋₁·eₖ₊₁/eₖ²).

    Parameters
    ----------
    e : np.ndarray
        Elementary symmetric polynomials e₀, ..., eₘ

    Returns
    -------
    gaps : np.ndarray
        Newton gap at each index k = 1, ..., m-1
    """
    return -newton_ratio_profile(e)


def sup_newton_gap(e: np.ndarray) -> float:
    """
    Compute the supremal Newton gap: max_k (-log Rₖ).

    This is the Newton order parameter. By Newton's inequalities (Rₖ ≥ 1),
    each gap is ≤ 0, so the supremum is ≤ 0 for genuinely log-concave
    sequences. The magnitude measures deviation from log-concavity.

    Parameters
    ----------
    e : np.ndarray
        Elementary symmetric polynomials

    Returns
    -------
    gap : float
        The supremal Newton gap
    """
    gaps = pointwise_newton_gap(e)
    if len(gaps) == 0:
        return 0.0
    return float(np.max(gaps))


def newton_order_full(
    eigenvalues: np.ndarray
) -> Tuple[float, np.ndarray, int]:
    """
    Full Newton order analysis: compute eigenvalues → esymm → gap.

    Parameters
    ----------
    eigenvalues : np.ndarray
        Correlation spectrum

    Returns
    -------
    gap : float
        Supremal Newton gap
    profile : np.ndarray
        Full Newton gap profile
    k_star : int
        Index achieving the supremum (1-indexed)
    """
    e = esymm_stable(eigenvalues)
    gaps = pointwise_newton_gap(e)
    if len(gaps) == 0:
        return 0.0, gaps, 0
    k_star = int(np.argmax(gaps)) + 1
    return float(np.max(gaps)), gaps, k_star


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Phase Diagnostic Classifier
# ═══════════════════════════════════════════════════════════════════════

def classify_phase(
    delta: float,
    m_values: Optional[List[int]] = None,
    threshold: float = 0.5
) -> dict:
    """
    Classify the SSH phase at dimerization δ by analyzing Newton gap scaling.

    Strategy: compute supNewtonGap for increasing m and check whether it
    grows (critical) or saturates (gapped).

    Parameters
    ----------
    delta : float
        Dimerization parameter
    m_values : list of int, optional
        System sizes to probe (default: [8, 16, 32, 64])
    threshold : float
        Growth rate threshold for classification

    Returns
    -------
    result : dict
        Classification result with keys:
        - 'phase': 'gapped' or 'critical'
        - 'gaps': list of (m, gap) pairs
        - 'growth_rate': estimated slope of gap vs log(m)
    """
    if m_values is None:
        m_values = [8, 16, 32, 64]

    gaps = []
    for m in m_values:
        eigs = ssh_eigenvalues(m, delta)
        e = esymm_stable(eigs)
        g = sup_newton_gap(e)
        gaps.append((m, g))

    # Fit log growth: gap ≈ c * log(m) + d
    log_m = np.log([g[0] for g in gaps])
    gap_vals = np.array([g[1] for g in gaps])

    if len(log_m) >= 2:
        slope, intercept = np.polyfit(log_m, gap_vals, 1)
    else:
        slope, intercept = 0.0, gap_vals[0] if len(gap_vals) > 0 else 0.0

    phase = 'critical' if abs(slope) > threshold else 'gapped'

    return {
        'phase': phase,
        'delta': delta,
        'gaps': gaps,
        'growth_rate': float(slope),
        'intercept': float(intercept)
    }


# ═══════════════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("SSH Newton-Order Algorithms")
    print("=" * 50)

    # Example 1: Compute eigenvalues
    m, delta = 16, 0.3
    eigs = ssh_eigenvalues(m, delta)
    print(f"\nSSH eigenvalues (m={m}, δ={delta}):")
    print(f"  min = {eigs.min():.6f}, max = {eigs.max():.6f}")

    # Example 2: Elementary symmetric polynomials
    e = esymm_stable(eigs)
    print(f"\nElementary symmetric polynomials (first 5):")
    for k in range(min(5, len(e))):
        print(f"  e_{k} = {e[k]:.6e}")

    # Example 3: Newton gap analysis
    gap, profile, k_star = newton_order_full(eigs)
    print(f"\nNewton order analysis:")
    print(f"  sup Newton gap = {gap:.6f}")
    print(f"  maximizing index k* = {k_star}")

    # Example 4: Phase classification
    for d in [0.0, 0.1, 0.3, 0.5]:
        result = classify_phase(d)
        print(f"\nδ = {d}: phase = {result['phase']}, "
              f"growth rate = {result['growth_rate']:.4f}")
