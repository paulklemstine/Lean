#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for concavity depth mixing analysis.

Implements:
1. k-fold log-concavity verification
2. Birth-death chain construction from stationary distributions
3. Spectral gap computation via tridiagonal eigenvalue methods
4. Concavity-depth profiling of distributions
5. Mixing time estimation from spectral gap

All algorithms have documented complexity bounds and type hints.
"""

import numpy as np
from typing import Tuple, List, Optional, Dict


# ============================================================================
# Algorithm 1: k-fold Log-Concavity Verification
# ============================================================================

def ratio_sequence(a: np.ndarray) -> np.ndarray:
    """
    Compute the ratio sequence r[i] = a[i+1] / a[i].

    Args:
        a: Positive sequence of length n+1

    Returns:
        Ratio sequence of length n

    Complexity: O(n) time, O(n) space
    """
    assert np.all(a > 0), "Sequence must be strictly positive"
    return a[1:] / a[:-1]


def is_log_concave(a: np.ndarray, tol: float = 1e-10) -> bool:
    """
    Check if a positive sequence satisfies the log-concavity inequality:
        a[i]^2 >= a[i-1] * a[i+1]  for all interior i.

    Equivalently, the ratio sequence r[i] = a[i+1]/a[i] is nonincreasing.

    Args:
        a: Positive sequence
        tol: Numerical tolerance

    Returns:
        True if log-concave

    Complexity: O(n) time, O(1) space
    """
    for i in range(1, len(a) - 1):
        if a[i] ** 2 < a[i - 1] * a[i + 1] - tol:
            return False
    return True


def verify_klc(a: np.ndarray, k: int, tol: float = 1e-10) -> Tuple[bool, List[np.ndarray]]:
    """
    Verify k-fold log-concavity and return all iterated ratio sequences.

    Algorithm:
        1. Check a is positive
        2. For depth d = 0, 1, ..., k-1:
           a. Compute ratio sequence at depth d
           b. Check log-concavity
        3. Return (result, list of ratio sequences at each depth)

    Args:
        a: Positive sequence
        k: Concavity depth to verify
        tol: Numerical tolerance

    Returns:
        (is_klc, ratio_tower) where ratio_tower[d] is the d-th iterated ratio

    Complexity: O(k * n) time, O(k * n) space
    """
    if not np.all(a > 0):
        return False, []

    tower = [a.copy()]
    current = a.copy()

    for depth in range(k):
        if not is_log_concave(current, tol):
            return False, tower
        if len(current) <= 2:
            # Too short to compute ratio; trivially LC at deeper levels
            break
        current = ratio_sequence(current)
        tower.append(current.copy())

    return True, tower


def concavity_depth_profile(a: np.ndarray, max_depth: int = 10) -> int:
    """
    Compute the concavity depth of a positive sequence:
    the maximum k such that a is k-fold log-concave.

    Args:
        a: Positive sequence
        max_depth: Maximum depth to check

    Returns:
        Maximum k such that a is k-fold log-concave

    Complexity: O(max_depth * n) time
    """
    if not np.all(a > 0):
        return -1

    depth = 0
    current = a.copy()

    for d in range(max_depth):
        if len(current) <= 2:
            return max_depth  # Trivially LC at all deeper levels
        if not is_log_concave(current):
            return depth
        depth = d + 1
        current = ratio_sequence(current)

    return depth


# ============================================================================
# Algorithm 2: Birth-Death Chain Construction
# ============================================================================

def metropolis_birth_death(pi: np.ndarray) -> np.ndarray:
    """
    Construct the Metropolis birth-death chain reversible w.r.t. pi.

    Transition probabilities:
        P(i, i+1) = min(1, pi[i+1]/pi[i]) / 2
        P(i, i-1) = min(1, pi[i-1]/pi[i]) / 2
        P(i, i) = 1 - P(i, i+1) - P(i, i-1)

    The chain is reversible: pi[i] P(i,j) = pi[j] P(j,i).

    Args:
        pi: Stationary distribution (positive, sums to 1)

    Returns:
        Transition matrix P of shape (n+1, n+1)

    Complexity: O(n) time, O(n^2) space
    """
    n = len(pi) - 1
    P = np.zeros((n + 1, n + 1))

    for i in range(n + 1):
        right = 0.0
        left = 0.0
        if i < n:
            right = min(1.0, pi[i + 1] / pi[i]) / 2
            P[i, i + 1] = right
        if i > 0:
            left = min(1.0, pi[i - 1] / pi[i]) / 2
            P[i, i - 1] = left
        P[i, i] = 1.0 - right - left

    return P


def heat_bath_birth_death(pi: np.ndarray) -> np.ndarray:
    """
    Construct the heat-bath (Glauber) birth-death chain reversible w.r.t. pi.

    Transition probabilities:
        P(i, i+1) = pi[i+1] / (pi[i] + pi[i+1]) / 2  (for i < n)
        P(i, i-1) = pi[i-1] / (pi[i] + pi[i-1]) / 2  (for i > 0)
        P(i, i) = 1 - P(i, i+1) - P(i, i-1)

    Args:
        pi: Stationary distribution

    Returns:
        Transition matrix P

    Complexity: O(n) time, O(n^2) space
    """
    n = len(pi) - 1
    P = np.zeros((n + 1, n + 1))

    for i in range(n + 1):
        right = 0.0
        left = 0.0
        if i < n:
            right = pi[i + 1] / (pi[i] + pi[i + 1]) / 2
            P[i, i + 1] = right
        if i > 0:
            left = pi[i - 1] / (pi[i] + pi[i - 1]) / 2
            P[i, i - 1] = left
        P[i, i] = 1.0 - right - left

    return P


def edge_conductances(pi: np.ndarray, P: np.ndarray) -> np.ndarray:
    """
    Compute edge conductances c_i = pi[i] * P[i, i+1].

    For a reversible chain, c_i = pi[i] P(i,i+1) = pi[i+1] P(i+1,i).

    Args:
        pi: Stationary distribution
        P: Transition matrix

    Returns:
        Array of edge conductances of length n

    Complexity: O(n) time
    """
    n = len(pi) - 1
    return np.array([pi[i] * P[i, i + 1] for i in range(n)])


# ============================================================================
# Algorithm 3: Spectral Gap Computation
# ============================================================================

def spectral_gap_dense(P: np.ndarray) -> float:
    """
    Compute spectral gap of P using dense eigenvalue decomposition.

    gap = 1 - max{|λ| : λ eigenvalue of P, λ ≠ 1}

    For a reversible chain with transition matrix P, this equals
    1 - λ_2 where λ_2 is the second-largest eigenvalue.

    Args:
        P: Transition matrix

    Returns:
        Spectral gap γ > 0

    Complexity: O(n^3) time (eigenvalue decomposition)
    """
    eigenvalues = np.sort(np.real(np.linalg.eigvals(P)))[::-1]
    return 1.0 - eigenvalues[1]


def spectral_gap_tridiagonal(pi: np.ndarray, P: np.ndarray) -> float:
    """
    Compute spectral gap using the symmetrized tridiagonal form.

    For a reversible birth-death chain, define the similarity transform
    S = D^{1/2} P D^{-1/2} where D = diag(pi). S is symmetric tridiagonal,
    so eigenvalues can be computed in O(n) time using the QR algorithm.

    Args:
        pi: Stationary distribution
        P: Transition matrix

    Returns:
        Spectral gap

    Complexity: O(n^2) time with optimized tridiagonal solver
    """
    n = len(pi) - 1
    sqrt_pi = np.sqrt(pi)

    # Symmetrized matrix: S[i,j] = sqrt(pi[i]/pi[j]) * P[i,j]
    S = np.zeros_like(P)
    for i in range(n + 1):
        for j in range(n + 1):
            S[i, j] = sqrt_pi[i] / sqrt_pi[j] * P[i, j]

    eigenvalues = np.sort(np.real(np.linalg.eigvalsh(S)))[::-1]
    return 1.0 - eigenvalues[1]


def dirichlet_form(pi: np.ndarray, P: np.ndarray, f: np.ndarray) -> float:
    """
    Compute the Dirichlet form E(f,f) = (1/2) Σ_{i,j} pi[i] P[i,j] (f[i]-f[j])^2.

    For a nearest-neighbor chain, this simplifies to:
        E(f,f) = Σ_{i=0}^{n-1} c_i (f[i+1] - f[i])^2

    Args:
        pi: Stationary distribution
        P: Transition matrix
        f: Test function

    Returns:
        Dirichlet form value E(f,f)

    Complexity: O(n^2) in general, O(n) for nearest-neighbor
    """
    n = len(pi)
    result = 0.0
    for i in range(n):
        for j in range(n):
            result += pi[i] * P[i, j] * (f[i] - f[j]) ** 2
    return result / 2


def variance_pi(pi: np.ndarray, f: np.ndarray) -> float:
    """
    Compute Var_π(f) = E_π[f^2] - (E_π[f])^2.

    Args:
        pi: Probability distribution
        f: Test function

    Returns:
        Variance

    Complexity: O(n) time
    """
    mean_f = np.sum(pi * f)
    return np.sum(pi * (f - mean_f) ** 2)


# ============================================================================
# Algorithm 4: Mixing Time Estimation
# ============================================================================

def mixing_time_bound(gap: float, pi_min: float, eps: float = 0.25) -> float:
    """
    Upper bound on total-variation mixing time from spectral gap.

    t_mix(ε) ≤ (1/γ) · log(1/(ε · π_min))

    This follows from the standard bound:
        d_TV(P^t(x,·), π) ≤ (1/π_min)^{1/2} · (1-γ)^t

    Args:
        gap: Spectral gap γ
        pi_min: Minimum stationary probability
        eps: Desired total variation distance

    Returns:
        Upper bound on mixing time

    Complexity: O(1)
    """
    if gap <= 0 or pi_min <= 0 or eps <= 0:
        return float('inf')
    return (1.0 / gap) * np.log(1.0 / (eps * pi_min))


def concavity_mixing_exponent(k: int) -> float:
    """
    The concavity-mixing exponent: 2/k.

    For k-fold log-concave distributions, the conjectured spectral gap
    lower bound is Ω(n^{-2/k}), giving mixing time O(n^{2/k} log n).

    Args:
        k: Concavity depth (≥ 1)

    Returns:
        Exponent 2/k
    """
    return 2.0 / k


def rescaled_spectral_gap(gap: float, n: int, k: int) -> float:
    """
    Compute the rescaled spectral gap: γ · n^{2/k}.

    If this quantity stays bounded away from zero as n → ∞ for all
    k-fold log-concave distributions, the concavity-depth conjecture holds.

    Args:
        gap: Spectral gap
        n: State space size parameter
        k: Concavity depth

    Returns:
        Rescaled gap
    """
    return gap * (n ** concavity_mixing_exponent(k))


# ============================================================================
# Algorithm 5: Distribution Families
# ============================================================================

def discrete_gaussian(n: int, a: float = 1.0, center: float = None) -> np.ndarray:
    """Generate discrete Gaussian: pi(i) ∝ exp(-a(i-center)²)."""
    if center is None:
        center = n / 2
    x = np.arange(n + 1, dtype=float)
    logpi = -a * (x - center) ** 2
    pi = np.exp(logpi - logpi.max())
    return pi / pi.sum()


def stretched_exponential(n: int, p: float, a: float = 1.0,
                          center: float = None) -> np.ndarray:
    """Generate stretched exponential: pi(i) ∝ exp(-a|i-center|^p)."""
    if center is None:
        center = n / 2
    x = np.arange(n + 1, dtype=float)
    logpi = -a * np.abs(x - center) ** p
    pi = np.exp(logpi - logpi.max())
    return pi / pi.sum()


def truncated_binomial(n: int, p_param: float = 0.5) -> np.ndarray:
    """Generate truncated binomial: pi(i) ∝ C(n,i) p^i (1-p)^{n-i}."""
    from math import comb
    pi = np.array([comb(n, i) * p_param ** i * (1 - p_param) ** (n - i)
                   for i in range(n + 1)], dtype=float)
    return pi / pi.sum()


def uniform_distribution(n: int) -> np.ndarray:
    """Generate uniform distribution on {0,...,n}."""
    return np.ones(n + 1) / (n + 1)


# ============================================================================
# Example usage
# ============================================================================

if __name__ == "__main__":
    print("=== Concavity Depth Algorithms ===\n")

    n = 20
    pi = discrete_gaussian(n, a=0.1)

    print(f"Distribution: Discrete Gaussian on {{0,...,{n}}} with a=0.1")
    print(f"Concavity depth: {concavity_depth_profile(pi)}")

    is_klc, tower = verify_klc(pi, k=2)
    print(f"2-fold log-concave: {is_klc}")
    if is_klc:
        print(f"  Ratio tower depths: {[len(t) for t in tower]}")

    P = metropolis_birth_death(pi)
    gap = spectral_gap_dense(P)
    print(f"\nMetropolis chain spectral gap: {gap:.6f}")

    t_mix = mixing_time_bound(gap, pi.min())
    print(f"Mixing time upper bound (ε=0.25): {t_mix:.1f}")

    for k in [1, 2, 3]:
        rg = rescaled_spectral_gap(gap, n, k)
        print(f"Rescaled gap (k={k}): γ·n^(2/{k}) = {rg:.6f}")
