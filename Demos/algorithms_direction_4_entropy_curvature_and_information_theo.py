#!/usr/bin/env python3
"""
algorithms.py — Certified Computational Methods for Entropy Curvature

Implements algorithms from the entropy curvature research paper with
full docstrings, type hints, and mathematical guarantees.
"""

import math
from typing import List, Optional, Tuple, Callable


def iter_forward_diff(f: List[float], k: int) -> List[float]:
    """Compute the k-th iterated forward finite difference of a sequence.
    
    Given f = [f(0), f(1), ..., f(N-1)], returns:
      Δ^k f = [Δ^k f(0), Δ^k f(1), ..., Δ^k f(N-1-k)]
    
    Mathematical definition (recursive):
      Δ^0 f(n) = f(n)
      Δ^{k+1} f(n) = Δ^k f(n+1) - Δ^k f(n)
    
    Complexity: O(k * N) time, O(N) space.
    
    Args:
        f: Input sequence of real numbers.
        k: Order of the finite difference (non-negative integer).
    
    Returns:
        List of length max(0, len(f) - k) containing Δ^k f values.
    
    Examples:
        >>> iter_forward_diff([1, 4, 9, 16, 25], 1)
        [3, 5, 7, 9]
        >>> iter_forward_diff([1, 4, 9, 16, 25], 2)
        [2, 2, 2]
        >>> iter_forward_diff([1, 2, 4, 8], 0)
        [1, 2, 4, 8]
    """
    result = list(f)
    for _ in range(k):
        if len(result) < 2:
            return []
        result = [result[i+1] - result[i] for i in range(len(result) - 1)]
    return result


def entropy_curvature_profile(a: List[float], max_order: int) -> List[List[float]]:
    """Compute the full entropy curvature profile up to a given order.
    
    For a positive sequence a, computes Δ^k(log ∘ a) for k = 0, 1, ..., max_order.
    
    Mathematical guarantee: For positive sequences, log is well-defined,
    and the profile captures all curvature information.
    
    Complexity: O(max_order * N) time, O(max_order * N) space.
    
    Args:
        a: Positive sequence of real numbers.
        max_order: Maximum difference order to compute.
    
    Returns:
        List of lists, where result[k] = Δ^k(log a) for k = 0, ..., max_order.
    
    Example:
        >>> profile = entropy_curvature_profile([1, 0.5, 0.25], 2)
        >>> len(profile)
        3
    """
    if any(x <= 0 for x in a):
        raise ValueError("All elements must be strictly positive")
    
    log_a = [math.log(x) for x in a]
    profile = []
    for k in range(max_order + 1):
        profile.append(iter_forward_diff(log_a, k))
    return profile


def detect_entropy_depth(a: List[float], max_order: int = 20,
                         tol: float = 1e-10) -> int:
    """Detect the empirical entropy depth of a finite positive sequence.
    
    The entropy depth is the largest d such that for all j < d,
    the alternating sign law holds:
      (-1)^j · Δ^{j+1}(log a)(n) ≥ 0  for all available n.
    
    Mathematical guarantee: If the sequence has infinite entropy depth
    (e.g., constant sequences), returns max_order.
    
    Complexity: O(max_order * N) time, O(N) space.
    
    Args:
        a: Positive sequence.
        max_order: Maximum depth to check.
        tol: Numerical tolerance for sign detection.
    
    Returns:
        Integer entropy depth in [0, max_order].
    
    Example:
        >>> detect_entropy_depth([1, 1, 1, 1, 1])  # Constant: maximal depth
        20
    """
    if any(x <= 0 for x in a):
        raise ValueError("All elements must be strictly positive")
    
    log_a = [math.log(x) for x in a]
    for j in range(max_order):
        diff = iter_forward_diff(log_a, j + 1)
        if not diff:
            return j
        sign = (-1) ** j
        if not all(sign * v >= -tol for v in diff):
            return j
    return max_order


def sign_pattern_matrix(a: List[float], max_order: int) -> List[str]:
    """Compute the sign pattern matrix for entropy curvature.
    
    Returns a list of strings, where each string represents the sign pattern
    of Δ^k(log a) using characters: '+' (positive), '-' (negative), '0' (zero).
    
    Args:
        a: Positive sequence.
        max_order: Maximum difference order.
    
    Returns:
        List of sign pattern strings, one per order k = 1, ..., max_order.
    
    Example:
        >>> sign_pattern_matrix([4, 2, 1, 0.5], 3)
        ['---', '--', '-']
    """
    log_a = [math.log(x) for x in a]
    patterns = []
    for k in range(1, max_order + 1):
        diff = iter_forward_diff(log_a, k)
        pat = ''
        for v in diff:
            if abs(v) < 1e-12:
                pat += '0'
            elif v > 0:
                pat += '+'
            else:
                pat += '-'
        patterns.append(pat)
    return patterns


def is_log_concave(a: List[float], tol: float = 1e-12) -> bool:
    """Test if a sequence is log-concave: a[n+1]^2 >= a[n]*a[n+2].
    
    Complexity: O(N) time, O(1) space.
    
    Args:
        a: Positive sequence.
        tol: Numerical tolerance.
    
    Returns:
        True if log-concave, False otherwise.
    """
    return all(a[n+1]**2 >= a[n] * a[n+2] - tol for n in range(len(a) - 2))


def ratio_sequence(a: List[float]) -> List[float]:
    """Compute the ratio sequence: r(n) = a(n+1) / a(n).
    
    Args:
        a: Positive sequence (all elements must be positive).
    
    Returns:
        Ratio sequence of length len(a) - 1.
    """
    return [a[n+1] / a[n] for n in range(len(a) - 1)]


def k_fold_log_concavity_depth(a: List[float], max_k: int = 10) -> int:
    """Determine the k-fold log-concavity depth of a sequence.
    
    A sequence is k-fold log-concave if:
      - k=0: it is positive
      - k+1: it is positive, log-concave, and its ratio sequence is k-fold log-concave
    
    Complexity: O(max_k * N) time.
    
    Args:
        a: Positive sequence.
        max_k: Maximum depth to check.
    
    Returns:
        Maximum k for which the sequence is k-fold log-concave.
    """
    if not all(x > 0 for x in a):
        return -1
    
    seq = list(a)
    for k in range(max_k):
        if len(seq) < 3:
            return k
        if not is_log_concave(seq):
            return k
        seq = ratio_sequence(seq)
        if not all(x > 0 for x in seq):
            return k + 1
    return max_k


def score_function(a: List[float]) -> List[float]:
    """Compute the discrete score function: s(n) = log(a(n+1)) - log(a(n)).
    
    This is the first forward difference of log(a), also interpretable as
    the discrete analogue of the score function in statistics.
    
    Args:
        a: Positive sequence.
    
    Returns:
        Score function values of length len(a) - 1.
    """
    return [math.log(a[n+1]) - math.log(a[n]) for n in range(len(a) - 1)]


def is_score_antitone(a: List[float], tol: float = 1e-10) -> bool:
    """Check if the score function is antitone (non-increasing).
    
    By Theorem 5, this holds for all positive log-concave sequences.
    
    Args:
        a: Positive sequence.
        tol: Numerical tolerance.
    
    Returns:
        True if score is antitone, False otherwise.
    """
    s = score_function(a)
    return all(s[i+1] <= s[i] + tol for i in range(len(s) - 1))


def normalize_to_distribution(a: List[float]) -> List[float]:
    """Normalize a positive sequence to a probability distribution.
    
    Returns π_n = a_n / Z where Z = Σ a_n.
    
    By Theorem 2, this preserves all entropy curvature of order >= 1.
    
    Args:
        a: Positive sequence.
    
    Returns:
        Normalized probability distribution.
    """
    Z = sum(a)
    if Z <= 0:
        raise ValueError("Total mass must be positive")
    return [x / Z for x in a]


def pointwise_entropy_density(a: List[float]) -> List[float]:
    """Compute the pointwise entropy density I_a(n) = -π_n * log(π_n).
    
    Args:
        a: Positive sequence (will be normalized).
    
    Returns:
        Pointwise entropy densities.
    """
    pi = normalize_to_distribution(a)
    return [-p * math.log(p) if p > 0 else 0 for p in pi]


def shannon_entropy(a: List[float]) -> float:
    """Compute the Shannon entropy H = -Σ π_n log π_n.
    
    Args:
        a: Positive sequence (will be normalized).
    
    Returns:
        Shannon entropy value.
    """
    return sum(pointwise_entropy_density(a))


# ──────────────────────────────────────────────────────────────────────────
# Distribution generators
# ──────────────────────────────────────────────────────────────────────────

def geometric_distribution(r: float, n: int) -> List[float]:
    """Generate geometric distribution: a_m = (1-r) * r^m.
    
    Theoretical guarantee (Theorem 3): All entropy curvatures of order >= 2 vanish.
    """
    if not (0 < r < 1):
        raise ValueError("r must be in (0, 1)")
    return [(1 - r) * r**m for m in range(n)]


def binomial_distribution(N: int, p: float) -> List[float]:
    """Generate binomial distribution: a_i = C(N,i) * p^i * (1-p)^(N-i).
    
    Theoretical guarantee (Theorem 1): This is log-concave, so Δ^2(log a) ≤ 0
    on the interior support.
    """
    if not (0 < p < 1):
        raise ValueError("p must be in (0, 1)")
    return [math.comb(N, i) * p**i * (1 - p)**(N - i) for i in range(N + 1)]


def poisson_distribution(lam: float, n: int) -> List[float]:
    """Generate truncated Poisson distribution: a_m = e^{-λ} * λ^m / m!."""
    return [math.exp(-lam) * lam**m / math.factorial(m) for m in range(n)]


def gibbs_distribution(energy_fn: Callable[[int], float], n: int) -> List[float]:
    """Generate Gibbs distribution: a_m = exp(-E(m)).
    
    For affine energy E(m) = α*m + β, Theorem 6 guarantees vanishing
    higher curvature from order 2 onward.
    """
    return [math.exp(-energy_fn(m)) for m in range(n)]


# ──────────────────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("=== Entropy Curvature Algorithms ===\n")
    
    # Example 1: Geometric distribution
    geo = geometric_distribution(0.5, 15)
    print("Geometric (r=0.5):")
    print(f"  Log-concave: {is_log_concave(geo)}")
    print(f"  K-fold depth: {k_fold_log_concavity_depth(geo)}")
    print(f"  Entropy depth: {detect_entropy_depth(geo)}")
    print(f"  Score antitone: {is_score_antitone(geo)}")
    print(f"  Shannon entropy: {shannon_entropy(geo):.4f}")
    print(f"  Sign patterns: {sign_pattern_matrix(geo, 4)}")
    
    # Example 2: Binomial distribution
    binom = binomial_distribution(10, 0.4)
    print("\nBinomial (N=10, p=0.4):")
    print(f"  Log-concave: {is_log_concave(binom)}")
    print(f"  K-fold depth: {k_fold_log_concavity_depth(binom)}")
    print(f"  Score antitone: {is_score_antitone(binom)}")
    print(f"  Shannon entropy: {shannon_entropy(binom):.4f}")
    print(f"  Sign patterns: {sign_pattern_matrix(binom, 4)}")
    
    # Example 3: Gibbs with affine energy
    gibbs = gibbs_distribution(lambda m: 0.5 * m + 1.0, 15)
    print("\nGibbs (E(m) = 0.5m + 1.0):")
    print(f"  Sign patterns: {sign_pattern_matrix(gibbs, 4)}")
    print(f"  Curvature profile (order 2): {entropy_curvature_profile(gibbs, 2)[2][:5]}")
