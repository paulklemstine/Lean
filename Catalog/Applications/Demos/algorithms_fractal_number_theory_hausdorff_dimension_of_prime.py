"""
Algorithms for Fractal Number Theory: Prime Logarithmic Image Analysis

Type-hinted implementations of all key algorithms.
"""

import math
from typing import List, Tuple, Dict, Optional


def sieve_of_eratosthenes(n: int) -> List[int]:
    """
    Generate all primes up to n using the Sieve of Eratosthenes.

    Args:
        n: Upper bound for prime generation.

    Returns:
        Sorted list of primes up to n.

    Time complexity: O(n log log n)
    Space complexity: O(n)
    """
    if n < 2:
        return []
    is_prime = bytearray(b'\x01') * (n + 1)
    is_prime[0] = is_prime[1] = 0
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            is_prime[i*i::i] = bytearray(len(is_prime[i*i::i]))
    return [i for i in range(2, n + 1) if is_prime[i]]


def log_prime_transform(primes: List[int]) -> List[float]:
    """
    Apply the logarithmic transform p ↦ 1/log(p) to a list of primes.

    This is the isometry from (Primes, d_log) to (S, |·|) ⊂ ℝ.

    Args:
        primes: List of prime numbers (each ≥ 2).

    Returns:
        List of values 1/log(p), in the same order.
    """
    return [1.0 / math.log(p) for p in primes]


def log_prime_metric(p: int, q: int) -> float:
    """
    Compute the logarithmic prime metric d(p, q) = |1/log(p) - 1/log(q)|.

    Satisfies:
    - Symmetry: d(p, q) = d(q, p)
    - Triangle inequality: d(p, r) ≤ d(p, q) + d(q, r)
    - Separation: d(p, q) = 0 ⟺ p = q (for primes)

    Also equals |log(q) - log(p)| / (log(p) · log(q)).

    Args:
        p, q: Positive integers ≥ 2.

    Returns:
        The logarithmic prime distance.
    """
    return abs(1.0 / math.log(p) - 1.0 / math.log(q))


def box_counting(values: List[float], epsilon: float) -> int:
    """
    Count the number of ε-boxes needed to cover a set of real values.

    For a set S ⊂ ℝ and ε > 0, N(S, ε) counts how many intervals
    [kε, (k+1)ε) contain at least one point of S.

    Args:
        values: List of real numbers (the set S).
        epsilon: Box width (must be positive).

    Returns:
        N(S, ε) = number of occupied boxes.
    """
    if epsilon <= 0:
        raise ValueError("epsilon must be positive")
    occupied_boxes: set = set()
    for v in values:
        occupied_boxes.add(int(math.floor(v / epsilon)))
    return len(occupied_boxes)


def estimate_box_dimension(
    values: List[float],
    eps_min: float = 1e-5,
    eps_max: float = 1e-1,
    n_samples: int = 100
) -> Tuple[float, float, List[Tuple[float, float]]]:
    """
    Estimate the box-counting dimension via log-log linear regression.

    dim_B ≈ slope of log(N(ε)) vs log(1/ε) plot.

    Args:
        values: The set S as a list of real numbers.
        eps_min: Minimum box size.
        eps_max: Maximum box size.
        n_samples: Number of ε values to sample.

    Returns:
        Tuple of (dimension_estimate, r_squared, log_log_data).
    """
    eps_values = [
        eps_min * (eps_max / eps_min) ** (i / (n_samples - 1))
        for i in range(n_samples)
    ]

    log_data: List[Tuple[float, float]] = []
    for eps in eps_values:
        n_boxes = box_counting(values, eps)
        if n_boxes > 1:  # Need at least 2 boxes for meaningful log
            log_data.append((math.log(1.0 / eps), math.log(n_boxes)))

    if len(log_data) < 2:
        return 0.0, 0.0, log_data

    # Ordinary least squares
    n = len(log_data)
    sx = sum(x for x, _ in log_data)
    sy = sum(y for _, y in log_data)
    sxx = sum(x**2 for x, _ in log_data)
    sxy = sum(x * y for x, y in log_data)
    syy = sum(y**2 for _, y in log_data)

    denom = n * sxx - sx**2
    slope = (n * sxy - sx * sy) / denom
    intercept = (sy - slope * sx) / n

    # R-squared
    ss_res = sum((y - slope * x - intercept)**2 for x, y in log_data)
    ss_tot = syy - sy**2 / n
    r_squared = 1.0 - ss_res / ss_tot if ss_tot > 0 else 0.0

    return slope, r_squared, log_data


def prime_gap_energy(primes: List[int], s: float) -> float:
    """
    Compute the prime log-gap energy at exponent s.

    E_s(N) = Σ |1/log(p_k) - 1/log(p_{k+1})|^s

    For s = 1: total variation of the log-prime image.
    For s < 1: emphasizes small gaps (twin primes).
    For s > 1: emphasizes large gaps.

    Args:
        primes: Sorted list of primes.
        s: Exponent (positive real number).

    Returns:
        The energy E_s.
    """
    energy = 0.0
    values = log_prime_transform(primes)
    for i in range(len(values) - 1):
        gap = abs(values[i] - values[i + 1])
        energy += gap ** s
    return energy


def twin_prime_analysis(primes: List[int]) -> Dict[str, object]:
    """
    Analyze twin primes in the logarithmic metric.

    Returns statistics about twin prime pairs (p, p+2):
    - count: number of twin prime pairs
    - distances: list of (p, d(p, p+2))
    - mean_distance: average log-metric distance
    - distance_decay_rate: estimated rate of distance decay

    Args:
        primes: Sorted list of primes.

    Returns:
        Dictionary of twin prime statistics.
    """
    pairs: List[Tuple[int, float]] = []
    for i in range(len(primes) - 1):
        if primes[i + 1] - primes[i] == 2:
            p = primes[i]
            d = log_prime_metric(p, p + 2)
            pairs.append((p, d))

    if not pairs:
        return {"count": 0, "distances": [], "mean_distance": 0.0}

    distances = [d for _, d in pairs]
    mean_dist = sum(distances) / len(distances)

    return {
        "count": len(pairs),
        "distances": pairs,
        "mean_distance": mean_dist,
        "min_distance": min(distances),
        "max_distance": max(distances),
    }


def bertrand_interval_coverage(n_max: int) -> List[Tuple[float, float]]:
    """
    Compute the Bertrand intervals [1/log(2n), 1/log(n+1)] for n = 1, ..., n_max.

    By Bertrand's postulate, each interval contains at least one 1/log(p)
    for some prime p. The overlap of these intervals shows how the log-prime
    image covers (0, 1/log(2)].

    Args:
        n_max: Maximum value of n.

    Returns:
        List of (lower, upper) pairs for each interval.
    """
    intervals: List[Tuple[float, float]] = []
    for n in range(1, n_max + 1):
        lower = 1.0 / math.log(2 * n)
        upper = 1.0 / math.log(n + 1)
        intervals.append((lower, upper))
    return intervals


if __name__ == "__main__":
    # Quick demonstration
    primes = sieve_of_eratosthenes(1_000_000)
    values = log_prime_transform(primes)

    print(f"Primes up to 1,000,000: {len(primes)} found")
    print(f"Log-prime image range: ({min(values):.6f}, {max(values):.6f}]")

    dim, r2, _ = estimate_box_dimension(values)
    print(f"Box-counting dimension estimate: {dim:.4f} (R² = {r2:.6f})")

    energy_1 = prime_gap_energy(primes[:1000], 1.0)
    energy_half = prime_gap_energy(primes[:1000], 0.5)
    print(f"Gap energy E_1 (first 1000 primes): {energy_1:.6f}")
    print(f"Gap energy E_0.5 (first 1000 primes): {energy_half:.6f}")

    twin_stats = twin_prime_analysis(primes)
    print(f"Twin primes found: {twin_stats['count']}")
    print(f"Mean twin distance: {twin_stats['mean_distance']:.2e}")
