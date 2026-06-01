"""
Algorithms for computing and analyzing truth density profiles.

This module implements the core algorithms for:
- Computing truth density at each string length
- Estimating box-counting dimension exponents
- Approximating the fractal dimension of truth sets
- Computing binary Shannon entropy
"""

import math
from typing import Callable, List, Tuple, Optional
from itertools import product as itertools_product


def binary_strings(n: int) -> List[Tuple[int, ...]]:
    """Generate all binary strings of length n."""
    if n == 0:
        return [()]
    return list(itertools_product([0, 1], repeat=n))


def truth_count(n: int, predicate: Callable[[Tuple[int, ...]], bool]) -> int:
    """Count the number of binary strings of length n satisfying the predicate."""
    return sum(1 for s in binary_strings(n) if predicate(s))


def truth_density(n: int, predicate: Callable[[Tuple[int, ...]], bool]) -> float:
    """Compute truth density at level n."""
    if n == 0:
        return 1.0 if predicate(()) else 0.0
    return truth_count(n, predicate) / (2 ** n)


def binary_entropy(p: float) -> float:
    """Compute binary Shannon entropy H(p) = -p log2(p) - (1-p) log2(1-p)."""
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log2(p) - (1 - p) * math.log2(1 - p)


def estimate_density_exponent(
    counts: List[int],
    start_n: int = 1
) -> float:
    """
    Estimate the density exponent d such that count(n) ≈ 2^(d*n).

    Uses least-squares regression of log2(count) against n.

    Args:
        counts: List of truth counts for n = start_n, start_n+1, ...
        start_n: Starting string length

    Returns:
        Estimated density exponent d
    """
    valid_points: List[Tuple[float, float]] = []
    for i, c in enumerate(counts):
        n = start_n + i
        if c > 0:
            valid_points.append((float(n), math.log2(c)))

    if len(valid_points) < 2:
        return 0.0

    # Simple linear regression
    xs = [p[0] for p in valid_points]
    ys = [p[1] for p in valid_points]
    n_pts = len(xs)
    mean_x = sum(xs) / n_pts
    mean_y = sum(ys) / n_pts
    cov_xy = sum((x - mean_x) * (y - mean_y) for x, y in zip(xs, ys))
    var_x = sum((x - mean_x) ** 2 for x in xs)

    if var_x < 1e-15:
        return 0.0

    slope = cov_xy / var_x
    return slope


def compute_density_profile(
    predicate: Callable[[Tuple[int, ...]], bool],
    max_n: int = 16
) -> List[Tuple[int, float, float]]:
    """
    Compute a full density profile for a predicate.

    Returns:
        List of (n, count, density) triples
    """
    profile: List[Tuple[int, float, float]] = []
    for n in range(1, max_n + 1):
        c = truth_count(n, predicate)
        d = c / (2 ** n)
        profile.append((n, float(c), d))
    return profile


def approximate_box_dimension(
    predicate: Callable[[Tuple[int, ...]], bool],
    max_n: int = 16,
    window: int = 5
) -> List[Tuple[int, float]]:
    """
    Compute running estimates of the box-counting dimension.

    Returns a list of (n, estimated_dimension) pairs using a sliding window.
    """
    profile = compute_density_profile(predicate, max_n)
    counts = [int(p[1]) for p in profile]
    estimates: List[Tuple[int, float]] = []

    for i in range(window, len(counts) + 1):
        window_counts = counts[i - window:i]
        start = i - window + 1
        est = estimate_density_exponent(window_counts, start)
        estimates.append((i, est))

    return estimates


def is_sparse_empirical(
    predicate: Callable[[Tuple[int, ...]], bool],
    max_n: int = 16,
    threshold: float = 0.01
) -> bool:
    """
    Empirically test if a predicate's truth set is sparse.

    Checks if density falls below threshold for the last few levels.
    """
    for n in range(max(1, max_n - 3), max_n + 1):
        d = truth_density(n, predicate)
        if d >= threshold:
            return False
    return True


def dimension_gap_test(
    predicate: Callable[[Tuple[int, ...]], bool],
    max_n: int = 16
) -> Tuple[float, float]:
    """
    Test the Density Dimension Gap Conjecture by computing
    upper and lower density exponents.

    Returns (lower_exponent, upper_exponent).
    """
    pointwise_exponents: List[float] = []
    for n in range(1, max_n + 1):
        c = truth_count(n, predicate)
        if c > 0 and n > 0:
            pointwise_exponents.append(math.log2(c) / n)
        elif c == 0:
            pointwise_exponents.append(0.0)

    if not pointwise_exponents:
        return (0.0, 0.0)

    # Use the last half as "large n" estimates
    tail = pointwise_exponents[len(pointwise_exponents) // 2:]
    lower = min(tail)
    upper = max(tail)
    return (lower, upper)


# Example predicates for demonstration

def predicate_first_bit_zero(s: Tuple[int, ...]) -> bool:
    """True iff the first bit is 0 (the half profile)."""
    return len(s) == 0 or s[0] == 0


def predicate_even_weight(s: Tuple[int, ...]) -> bool:
    """True iff the Hamming weight is even."""
    return sum(s) % 2 == 0


def predicate_palindrome(s: Tuple[int, ...]) -> bool:
    """True iff the string is a palindrome."""
    return s == s[::-1]


def predicate_no_consecutive_ones(s: Tuple[int, ...]) -> bool:
    """True iff no two consecutive bits are both 1 (Fibonacci-like)."""
    for i in range(len(s) - 1):
        if s[i] == 1 and s[i + 1] == 1:
            return False
    return True


if __name__ == "__main__":
    # Quick self-test
    for name, pred in [
        ("first_bit_zero", predicate_first_bit_zero),
        ("even_weight", predicate_even_weight),
        ("palindrome", predicate_palindrome),
        ("no_consecutive_ones", predicate_no_consecutive_ones),
    ]:
        print(f"\n=== {name} ===")
        profile = compute_density_profile(pred, max_n=12)
        for n, c, d in profile:
            print(f"  n={n:2d}  count={c:6.0f}  density={d:.6f}  entropy={binary_entropy(d):.6f}")
        counts = [int(p[1]) for p in profile]
        exp = estimate_density_exponent(counts)
        print(f"  Estimated exponent: {exp:.4f}")
        lo, hi = dimension_gap_test(pred, max_n=12)
        print(f"  Dimension gap: [{lo:.4f}, {hi:.4f}]")
