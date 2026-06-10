#!/usr/bin/env python3
"""
Algorithms for DPP-Lorentzian Entanglement Entropy Analysis

Implements verified algorithms for computing coefficient-based entropy
surrogates from a spectrum or subsystem kernel, and provides certified
entropy bounds.
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Optional


def elementary_symmetric(spectrum: np.ndarray, k: int) -> float:
    """
    Compute the k-th elementary symmetric polynomial e_k(λ₁,...,λₘ).

    e_k = Σ_{|S|=k} Π_{i∈S} λᵢ

    Args:
        spectrum: Array of eigenvalues
        k: Degree of the elementary symmetric polynomial

    Returns:
        Value of e_k(spectrum)

    Time complexity: O(C(m,k) * k) where m = len(spectrum)
    Space complexity: O(k) for each combination

    >>> elementary_symmetric(np.array([1.0, 2.0, 3.0]), 2)
    11.0
    """
    m = len(spectrum)
    if k < 0 or k > m:
        return 0.0
    if k == 0:
        return 1.0
    return sum(np.prod([spectrum[i] for i in S]) for S in combinations(range(m), k))


def elementary_symmetric_dp(spectrum: np.ndarray, max_k: Optional[int] = None) -> np.ndarray:
    """
    Compute all elementary symmetric polynomials e_0,...,e_m using dynamic programming.

    Uses the recurrence: e_k(x_1,...,x_m) = e_k(x_1,...,x_{m-1}) + x_m · e_{k-1}(x_1,...,x_{m-1})

    Args:
        spectrum: Array of eigenvalues
        max_k: Maximum degree to compute (default: m)

    Returns:
        Array [e_0, e_1, ..., e_{max_k}]

    Time complexity: O(m * max_k)
    Space complexity: O(max_k)

    >>> elementary_symmetric_dp(np.array([1.0, 2.0, 3.0]))
    array([1., 6., 11., 6.])
    """
    m = len(spectrum)
    if max_k is None:
        max_k = m

    e = np.zeros(max_k + 1)
    e[0] = 1.0

    for i in range(m):
        # Update from right to left to avoid using updated values
        for k in range(min(i + 1, max_k), 0, -1):
            e[k] += spectrum[i] * e[k - 1]

    return e


def binary_entropy(x: float) -> float:
    """
    Binary entropy h(x) = -x log x - (1-x) log(1-x).

    Args:
        x: Value in [0, 1]

    Returns:
        Binary entropy value

    >>> abs(binary_entropy(0.5) - np.log(2)) < 1e-10
    True
    """
    if x <= 0 or x >= 1:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def fermion_entropy(spectrum: np.ndarray) -> float:
    """
    Free-fermion entanglement entropy S = Σ h(λᵢ).

    Args:
        spectrum: Eigenvalues of the correlation kernel K_A, in [0,1]

    Returns:
        Entanglement entropy

    >>> fermion_entropy(np.array([0.5, 0.5]))
    1.3862943611198906
    """
    return sum(binary_entropy(x) for x in spectrum)


def subsystem_variance(spectrum: np.ndarray) -> float:
    """
    Particle-number variance Var(N_A) = Σ λᵢ(1-λᵢ) = tr(K_A - K_A²).

    Args:
        spectrum: Eigenvalues in [0,1]

    Returns:
        Variance

    >>> subsystem_variance(np.array([0.5, 0.5]))
    0.5
    """
    return np.sum(spectrum * (1 - spectrum))


def entropy_bounds(spectrum: np.ndarray) -> dict:
    """
    Compute all proven entropy bounds for a given spectrum.

    Returns a dictionary with:
      - 'entropy': exact entropy S
      - 'variance': Var(N_A)
      - 'lower_bound': 2 * Var (proven: S ≥ 2·Var)
      - 'upper_bound': m * log(2) (proven: S ≤ m·log(2))
      - 'e1': first elementary symmetric sum
      - 'e2': second elementary symmetric sum
      - 'coeff_lower': 2(e₁ - e₁² + 2e₂) (proven: S ≥ this)
      - 'newton_ratios': ρ_k = e_k²/(e_{k-1}·e_{k+1})

    All bounds are formally verified in Lean 4.
    """
    m = len(spectrum)
    S = fermion_entropy(spectrum)
    V = subsystem_variance(spectrum)

    e = elementary_symmetric_dp(spectrum)

    ratios = []
    for k in range(1, m):
        if k + 1 <= m:
            denom = e[k-1] * e[k+1]
            if abs(denom) > 1e-15:
                ratios.append(e[k]**2 / denom)
            else:
                ratios.append(float('inf'))

    return {
        'entropy': S,
        'variance': V,
        'lower_bound': 2 * V,
        'upper_bound': m * np.log(2),
        'e1': e[1] if len(e) > 1 else 0,
        'e2': e[2] if len(e) > 2 else 0,
        'coeff_lower': 2 * (e[1] - e[1]**2 + 2 * e[2]) if len(e) > 2 else 0,
        'newton_ratios': ratios,
        'esymm_profile': e.tolist(),
    }


def verify_newton_inequality(spectrum: np.ndarray) -> List[Tuple[int, float, bool]]:
    """
    Verify Newton's inequality e_k² ≥ e_{k-1}·e_{k+1} for all valid k.

    Returns list of (k, ratio, holds) tuples.
    """
    m = len(spectrum)
    e = elementary_symmetric_dp(spectrum)
    results = []
    for k in range(1, m):
        ek2 = e[k]**2
        prod = e[k-1] * e[k+1]
        ratio = ek2 / prod if abs(prod) > 1e-15 else float('inf')
        results.append((k, ratio, ek2 >= prod - 1e-12))
    return results


def entropy_from_kernel(K: np.ndarray) -> dict:
    """
    Compute entropy bounds directly from a PSD contraction kernel K.

    Args:
        K: Symmetric PSD matrix with eigenvalues in [0,1]

    Returns:
        Dictionary of bounds (same as entropy_bounds)
    """
    eigenvalues = np.linalg.eigvalsh(K)
    eigenvalues = np.clip(eigenvalues, 0, 1)
    return entropy_bounds(eigenvalues)


if __name__ == "__main__":
    print("=== Algorithm Tests ===")

    # Test elementary symmetric polynomial
    spec = np.array([1.0, 2.0, 3.0])
    e = elementary_symmetric_dp(spec)
    print(f"e_k for {spec}: {e}")
    assert abs(e[0] - 1) < 1e-10
    assert abs(e[1] - 6) < 1e-10
    assert abs(e[2] - 11) < 1e-10
    assert abs(e[3] - 6) < 1e-10

    # Test entropy bounds
    spec = np.array([0.5, 0.5, 0.5, 0.5])
    bounds = entropy_bounds(spec)
    print(f"\nSpectrum: {spec}")
    print(f"  Entropy: {bounds['entropy']:.4f}")
    print(f"  Lower bound (2*Var): {bounds['lower_bound']:.4f}")
    print(f"  Coeff lower bound: {bounds['coeff_lower']:.4f}")
    print(f"  Upper bound (m*log2): {bounds['upper_bound']:.4f}")
    print(f"  Newton ratios: {bounds['newton_ratios']}")

    # Verify all bounds hold
    assert bounds['entropy'] >= bounds['lower_bound'] - 1e-10
    assert bounds['entropy'] <= bounds['upper_bound'] + 1e-10
    assert bounds['entropy'] >= bounds['coeff_lower'] - 1e-10
    assert all(r >= 1 - 1e-10 for r in bounds['newton_ratios'])
    print("  All bounds verified ✓")

    # Test with random kernel
    m = 5
    A = np.random.randn(m, m)
    K = A @ A.T
    eigenvalues = np.linalg.eigvalsh(K)
    K = K / (max(eigenvalues) + 0.1)  # scale to make eigenvalues < 1

    bounds = entropy_from_kernel(K)
    print(f"\nRandom kernel (m={m}):")
    print(f"  Entropy: {bounds['entropy']:.4f}")
    print(f"  Bounds: [{bounds['lower_bound']:.4f}, {bounds['upper_bound']:.4f}]")
    print(f"  e₁={bounds['e1']:.4f}, e₂={bounds['e2']:.4f}")

    print("\nAll tests passed ✓")
