"""
Tropical Truth Geometry: Algorithms

Implementations of the core algorithms from the Tropical Truth Geometry framework,
including growth exponent computation, density-exponent duality verification,
tropical spectrum operations, and computable approximation.
"""

import math
from typing import Callable, List, Optional, Tuple


def growth_exponent(count: int, n: int) -> float:
    """
    Compute the growth exponent α(n) = log₂(N(n)) / n.

    Args:
        count: Number of true strings of length n (N(n))
        n: String length level

    Returns:
        The growth exponent α(n) ∈ [0, 1]

    Raises:
        ValueError: If count ≤ 0 or n < 0, or count > 2^n
    """
    if count <= 0:
        raise ValueError(f"Count must be positive, got {count}")
    if n < 0:
        raise ValueError(f"Level must be non-negative, got {n}")
    if n == 0:
        return 1.0
    if count > 2**n:
        raise ValueError(f"Count {count} exceeds 2^{n} = {2**n}")
    return math.log2(count) / n


def truth_density(count: int, n: int) -> float:
    """
    Compute the truth density d(n) = N(n) / 2^n.

    Args:
        count: Number of true strings of length n
        n: String length level

    Returns:
        The truth density d(n) ∈ (0, 1]
    """
    if count <= 0:
        raise ValueError(f"Count must be positive, got {count}")
    if n < 0:
        raise ValueError(f"Level must be non-negative, got {n}")
    return count / (2**n)


def density_exponent_duality_check(count: int, n: int, tol: float = 1e-12) -> Tuple[float, float, bool]:
    """
    Verify the density-exponent duality: log(d(n)) = n · (α(n) - 1) · log 2.

    Args:
        count: Number of true strings of length n
        n: String length level (must be ≥ 1)
        tol: Numerical tolerance for equality check

    Returns:
        Tuple of (lhs, rhs, equal) where lhs = log(d(n)), rhs = n(α-1)log2
    """
    if n == 0:
        raise ValueError("Duality requires n ≥ 1")

    d = truth_density(count, n)
    alpha = growth_exponent(count, n)

    lhs = math.log(d)
    rhs = n * (alpha - 1) * math.log(2)

    return lhs, rhs, abs(lhs - rhs) < tol


def tropical_density_functional(n: int, alpha: float) -> float:
    """
    The tropical density functional F_n(α) = n · (α - 1) · log 2.

    In the tropical (max-plus) semiring, this is a linear map.

    Args:
        n: Scale parameter
        alpha: Growth exponent value

    Returns:
        The tropical density value
    """
    return n * (alpha - 1) * math.log(2)


def tropical_sum_spectrum(
    counts1: List[int], counts2: List[int]
) -> List[int]:
    """
    Compute the tropical sum of two truth density spectra.

    The tropical sum takes the pointwise maximum of counts,
    corresponding to tropical addition in the max-plus semiring.

    Args:
        counts1: First spectrum [N₁(0), N₁(1), ...]
        counts2: Second spectrum [N₂(0), N₂(1), ...]

    Returns:
        Tropical sum spectrum [max(N₁(0),N₂(0)), max(N₁(1),N₂(1)), ...]
    """
    max_len = max(len(counts1), len(counts2))
    result = []
    for i in range(max_len):
        c1 = counts1[i] if i < len(counts1) else 1
        c2 = counts2[i] if i < len(counts2) else 1
        result.append(max(c1, c2))
    return result


def binary_entropy(p: float) -> float:
    """
    Compute binary entropy H(p) = -p log(p) - (1-p) log(1-p).

    Args:
        p: Probability in (0, 1)

    Returns:
        Binary entropy value
    """
    if p <= 0 or p >= 1:
        return 0.0
    return -p * math.log(p) - (1 - p) * math.log(1 - p)


def computable_approximation(
    oracle: Callable[[int, int], int],
    n: int,
    max_steps: int = 1000
) -> List[Tuple[int, float]]:
    """
    Iterative computable approximation of the growth exponent.

    Given an approximation oracle A(k, n) that monotonically increases
    toward the true count N(n), computes successive lower bounds on α(n).

    Args:
        oracle: Function A(k, n) returning the k-th approximation at level n
        n: String length level
        max_steps: Maximum number of approximation steps

    Returns:
        List of (step, approximate_exponent) pairs
    """
    if n == 0:
        return [(0, 1.0)]

    results = []
    prev_approx = 0

    for k in range(max_steps):
        approx = oracle(k, n)
        if approx <= 0:
            results.append((k, 0.0))
        else:
            alpha_k = math.log2(approx) / n
            results.append((k, alpha_k))

        if approx == prev_approx and k > 0:
            break  # Converged
        prev_approx = approx

    return results


def spectrum_comparison(
    counts1: List[int], counts2: List[int]
) -> List[Tuple[int, float, float, bool]]:
    """
    Verify the spectrum comparison principle:
    if N₁(n) ≤ N₂(n) for all n, then α₁(n) ≤ α₂(n).

    Args:
        counts1: First spectrum (should be ≤ second pointwise)
        counts2: Second spectrum

    Returns:
        List of (n, α₁(n), α₂(n), α₁≤α₂) for each level
    """
    results = []
    for n in range(1, min(len(counts1), len(counts2))):
        if counts1[n] <= 0 or counts2[n] <= 0:
            continue
        alpha1 = growth_exponent(counts1[n], n)
        alpha2 = growth_exponent(counts2[n], n)
        results.append((n, alpha1, alpha2, alpha1 <= alpha2 + 1e-15))
    return results


def generate_example_spectrum(
    alpha_target: float, max_n: int = 20
) -> List[int]:
    """
    Generate a truth density spectrum with approximate growth exponent α.

    N(n) = max(1, round(2^(α·n)))

    Args:
        alpha_target: Target growth exponent in (0, 1)
        max_n: Maximum level

    Returns:
        List of counts [N(0), N(1), ..., N(max_n)]
    """
    counts = []
    for n in range(max_n + 1):
        raw = 2 ** (alpha_target * n)
        count = max(1, min(round(raw), 2**n))
        counts.append(count)
    return counts
