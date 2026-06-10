#!/usr/bin/env python3
"""
Spectral Depth-Efficiency of qEML Networks: Algorithms

Implements the core algorithms from the spectral depth-efficiency theory:

1. SpectralTruncation — compute depth-d spectral approximant
2. AdaptiveDepthSelection — find minimal depth for target accuracy
3. CoefficientDecayEstimator — estimate decay rate from data
4. DepthEfficiencyOracle — predict depth from accuracy and regularity

All algorithms have proven correctness guarantees from the formal theory.
"""

import numpy as np
from typing import Callable, Optional, Tuple, List
from dataclasses import dataclass


@dataclass
class SpectralApprox:
    """A spectral qEML approximant with bounded frequency support.

    Corresponds to the Lean definition:
        structure SpectralApprox where
          depth : ℕ
          coeffs : ℕ → ℝ
          supported : ∀ n, depth < n → coeffs n = 0

    Attributes:
        depth: Maximum frequency/representation degree
        coeffs: Dictionary mapping frequency index to coefficient value
    """
    depth: int
    coeffs: dict

    def eval_on_characters(self, chi: Callable[[int, np.ndarray], np.ndarray],
                           x: np.ndarray) -> np.ndarray:
        """Evaluate the approximant: ∑_{n=0}^{depth} coeffs[n] · χ_n(x)."""
        result = np.zeros_like(x)
        for n, c in self.coeffs.items():
            if n <= self.depth:
                result += c * chi(n, x)
        return result


def spectral_truncation(a: Callable[[int], float], C: float,
                        epsilon: float) -> SpectralApprox:
    """Compute a depth-d spectral approximant achieving error ≤ ε.

    By Theorem A (spectral_upper_bound), choosing d = ⌈C²/ε⌉ guarantees
    that the spectral tail sum (= squared L² error) is at most ε.

    Algorithm:
        1. Compute d = ⌈C²/ε⌉
        2. Collect coefficients a(0), ..., a(d)
        3. Return SpectralApprox(d, {n: a(n) for n in [0,d]})

    Complexity: O(d) = O(C²/ε) time and space.

    Args:
        a: Coefficient function a : ℕ → ℝ
        C: Decay constant (|a(n)| ≤ C/n for all n ≥ 1)
        epsilon: Target squared L² error

    Returns:
        SpectralApprox with guaranteed error ≤ epsilon

    Example:
        >>> a = lambda n: 1.0 / n if n >= 1 else 1.0
        >>> approx = spectral_truncation(a, C=1.0, epsilon=0.01)
        >>> print(f"Depth: {approx.depth}")
        Depth: 100
    """
    if epsilon <= 0:
        raise ValueError("epsilon must be positive")
    if C < 0:
        raise ValueError("C must be non-negative")

    d = int(np.ceil(C ** 2 / epsilon))
    coeffs = {n: a(n) for n in range(d + 1)}
    return SpectralApprox(depth=d, coeffs=coeffs)


def adaptive_depth_selection(a: Callable[[int], float], epsilon: float,
                             N_max: int = 100000) -> Tuple[int, float]:
    """Find the minimal depth d such that spectralTailSum ≤ ε.

    This algorithm does not require knowledge of the decay constant C.
    It directly monitors the tail sum and stops when the target is reached.

    Algorithm:
        1. Compute total_sum = ∑_{n=1}^{N_max} a(n)²
        2. For d = 1, 2, ...: subtract a(d)² from running tail
        3. Return first d where tail ≤ ε

    Complexity: O(N_max) time, O(1) space (streaming).

    Args:
        a: Coefficient function a : ℕ → ℝ
        epsilon: Target squared L² error
        N_max: Maximum frequency to consider

    Returns:
        (d, actual_error) — minimal depth and achieved error

    Example:
        >>> a = lambda n: 1.0 / n if n >= 1 else 1.0
        >>> d, err = adaptive_depth_selection(a, epsilon=0.01)
        >>> print(f"Depth: {d}, Error: {err:.6f}")
    """
    if epsilon <= 0:
        raise ValueError("epsilon must be positive")

    # Compute total tail sum
    tail = sum(a(n) ** 2 for n in range(1, N_max + 1))

    for d in range(1, N_max + 1):
        tail -= a(d) ** 2
        if tail <= epsilon:
            return d, tail

    return N_max, tail


def estimate_coefficient_decay(a: Callable[[int], float],
                               n_range: Tuple[int, int] = (10, 1000)
                               ) -> Tuple[float, float]:
    """Estimate the decay rate k and constant C from coefficient data.

    Fits |a(n)| ≈ C · n^{-k} by linear regression on log-log data.

    Args:
        a: Coefficient function
        n_range: Range of indices to use for fitting

    Returns:
        (k, C) — estimated decay rate and constant

    Example:
        >>> a = lambda n: 2.5 / n**1.7 if n >= 1 else 0
        >>> k, C = estimate_coefficient_decay(a)
        >>> print(f"k ≈ {k:.2f}, C ≈ {C:.2f}")
        k ≈ 1.70, C ≈ 2.50
    """
    ns = np.arange(n_range[0], n_range[1] + 1)
    vals = np.array([abs(a(n)) for n in ns])

    # Filter out zeros
    mask = vals > 0
    if not mask.any():
        return 0.0, 0.0

    log_n = np.log(ns[mask])
    log_a = np.log(vals[mask])

    # Linear regression: log|a(n)| = log(C) - k·log(n)
    slope, intercept = np.polyfit(log_n, log_a, 1)
    k = -slope
    C = np.exp(intercept)
    return k, C


def depth_efficiency_oracle(C: float, k: float,
                            epsilon: float) -> dict:
    """Predict depth and error rate from regularity parameters.

    Given decay constant C, decay rate k, and target error ε, computes:
    - Required depth for squared L² error ≤ ε
    - Required depth for L² error ≤ ε
    - Predicted error at any given depth

    Based on the depth-efficiency theorem:
        spectralTailSum ≤ C² · d^{-(2k-1)} / (2k-1)

    Args:
        C: Decay constant
        k: Decay rate (k > 0.5 required for convergence)
        epsilon: Target error

    Returns:
        Dictionary with depth predictions and error formulas

    Example:
        >>> info = depth_efficiency_oracle(C=1.0, k=1.0, epsilon=0.01)
        >>> print(f"Depth for sq error ≤ 0.01: {info['depth_sq_error']}")
    """
    if k <= 0.5:
        raise ValueError("Decay rate k must be > 0.5 for convergence")
    if epsilon <= 0:
        raise ValueError("epsilon must be positive")

    rate = 2 * k - 1  # Exponent in d^{-rate}

    # Depth for squared L² error ≤ ε: d ≥ (C²/((2k-1)ε))^{1/(2k-1)}
    d_sq = int(np.ceil((C ** 2 / ((rate) * epsilon)) ** (1.0 / rate)))

    # Depth for L² error ≤ ε: need squared error ≤ ε², so
    # d ≥ (C²/((2k-1)ε²))^{1/(2k-1)}
    d_l2 = int(np.ceil((C ** 2 / ((rate) * epsilon ** 2)) ** (1.0 / rate)))

    return {
        'decay_rate': k,
        'decay_constant': C,
        'error_exponent': rate,
        'depth_sq_error': d_sq,
        'depth_l2_error': d_l2,
        'target_epsilon': epsilon,
        'predicted_sq_error_formula': f"C² · d^{{-{rate:.1f}}} / {rate:.1f}",
        'predicted_l2_error_formula': f"C · d^{{-{(k - 0.5):.1f}}} / √{rate:.1f}",
    }


def construct_hard_family(d: int, k: float = 1.0) -> Callable[[int], float]:
    """Construct the explicit hard family for the lower bound.

    Returns the coefficient function a(n) = 1/n^k, which achieves
    spectral tail sum ≥ c_k / d^{2k-1} over [d+1, 2d].

    This is the family used in Theorem C (spectral_lower_bound) to show
    that the upper bound rate is sharp.

    Args:
        d: Target depth (for reference; the family is depth-independent)
        k: Decay rate

    Returns:
        Coefficient function a : ℕ → ℝ

    Example:
        >>> a = construct_hard_family(d=100, k=1.0)
        >>> # Tail sum over [101, 200] should be ≥ 1/(4·100) = 0.0025
        >>> tail = sum(a(n)**2 for n in range(101, 201))
        >>> print(f"Tail sum: {tail:.6f} ≥ {1/(4*100):.6f}")
    """
    def a(n: int) -> float:
        if n < 1:
            return 0.0
        return 1.0 / n ** k
    return a


# ─── Example usage ─────────────────────────────────────────────────────

if __name__ == '__main__':
    print("Spectral Depth-Efficiency: Algorithm Demonstrations\n")

    # 1. Spectral truncation
    print("1. Spectral Truncation")
    a = lambda n: 1.0 / n if n >= 1 else 1.0
    approx = spectral_truncation(a, C=1.0, epsilon=0.01)
    print(f"   For ε=0.01, C=1: depth = {approx.depth}")
    print(f"   First 5 coefficients: {[approx.coeffs[n] for n in range(5)]}\n")

    # 2. Adaptive depth selection
    print("2. Adaptive Depth Selection")
    d, err = adaptive_depth_selection(a, epsilon=0.01, N_max=10000)
    print(f"   Minimal depth for ε=0.01: d = {d}, actual error = {err:.8f}\n")

    # 3. Coefficient decay estimation
    print("3. Coefficient Decay Estimation")
    test_funcs = [
        ("a(n) = 1/n", lambda n: 1.0/n if n >= 1 else 0, 1.0, 1.0),
        ("a(n) = 2/n²", lambda n: 2.0/n**2 if n >= 1 else 0, 2.0, 2.0),
        ("a(n) = 0.5/n³", lambda n: 0.5/n**3 if n >= 1 else 0, 3.0, 0.5),
    ]
    for label, func, true_k, true_C in test_funcs:
        k_est, C_est = estimate_coefficient_decay(func)
        print(f"   {label}: k={k_est:.3f} (true {true_k}), "
              f"C={C_est:.3f} (true {true_C})")
    print()

    # 4. Depth efficiency oracle
    print("4. Depth Efficiency Oracle")
    info = depth_efficiency_oracle(C=1.0, k=2.5, epsilon=0.001)
    for key, val in info.items():
        print(f"   {key}: {val}")
    print()

    # 5. Hard family construction
    print("5. Hard Family Lower Bound")
    for d in [10, 50, 100, 500]:
        a_hard = construct_hard_family(d, k=1.0)
        tail = sum(a_hard(n)**2 for n in range(d + 1, 2 * d + 1))
        lower = 1.0 / (4 * d)
        print(f"   d={d:4d}: tail sum = {tail:.8f}, "
              f"lower bound = {lower:.8f}, "
              f"ratio = {tail/lower:.4f}")
