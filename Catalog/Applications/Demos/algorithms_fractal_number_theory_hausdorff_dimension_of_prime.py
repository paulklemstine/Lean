#!/usr/bin/env python3
"""
Algorithms for Fractal Number Theory: Hausdorff-Minkowski Dimension Gap

Type-hinted implementations of the core algorithms used in the research.
"""

import math
from typing import List, Tuple, Dict, Optional, Callable


def sieve_of_eratosthenes(n: int) -> List[int]:
    """
    Generate all primes up to n using the Sieve of Eratosthenes.
    
    Time complexity: O(n log log n)
    Space complexity: O(n)
    """
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [p for p in range(2, n + 1) if is_prime[p]]


def log_inverse_embedding(x: float) -> float:
    """
    The log-inverse embedding φ(x) = 1/log(x).
    
    Maps (1, ∞) → (0, ∞) strictly decreasingly.
    Key property: φ is a metric deformation that compresses large primes
    together while keeping small primes well-separated.
    """
    if x <= 1:
        raise ValueError(f"log_inverse_embedding requires x > 1, got {x}")
    return 1.0 / math.log(x)


def log_prime_distance(p: int, q: int) -> float:
    """
    The log-prime metric: d(p, q) = |1/log(p) - 1/log(q)|.
    
    This is the absolute difference of the log-inverse embeddings.
    Properties:
    - d(p, q) = d(q, p) (symmetry)
    - d(p, r) ≤ d(p, q) + d(q, r) (triangle inequality)
    - d(p, q) = 0 iff p = q (for primes)
    """
    return abs(log_inverse_embedding(p) - log_inverse_embedding(q))


def box_counting_number(
    points: List[float], 
    epsilon: float,
    bounds: Optional[Tuple[float, float]] = None
) -> int:
    """
    Count the number of ε-boxes that intersect a set of points.
    
    N(ε) = |{k ∈ ℤ : ∃ x ∈ points, kε ≤ x < (k+1)ε}|
    
    This is the fundamental quantity for computing box-counting dimension:
    dim_M = lim_{ε→0} log(N(ε)) / log(1/ε)
    """
    if epsilon <= 0:
        raise ValueError("epsilon must be positive")
    boxes = set()
    for x in points:
        boxes.add(int(math.floor(x / epsilon)))
    return len(boxes)


def estimate_minkowski_dimension(
    points: List[float],
    epsilon_range: Tuple[float, float] = (1e-6, 0.1),
    num_scales: int = 20
) -> Tuple[float, List[Tuple[float, int, float]]]:
    """
    Estimate the Minkowski (box-counting) dimension of a point set.
    
    Returns (estimated_dimension, detailed_results) where detailed_results
    is a list of (epsilon, box_count, local_dimension) triples.
    
    Algorithm:
    1. For each ε in a geometric sequence from ε_max to ε_min:
       - Count N(ε) = number of occupied ε-boxes
    2. Estimate dim = slope of log(N) vs log(1/ε) regression
    """
    eps_min, eps_max = epsilon_range
    log_ratio = math.log(eps_max / eps_min)
    
    results = []
    for i in range(num_scales):
        eps = eps_max * math.exp(-log_ratio * i / (num_scales - 1))
        N = box_counting_number(points, eps)
        if N > 1:
            dim = math.log(N) / math.log(1.0 / eps)
            results.append((eps, N, dim))
    
    # Linear regression on log-log plot for final estimate
    if len(results) >= 2:
        xs = [math.log(1.0 / r[0]) for r in results]
        ys = [math.log(r[1]) for r in results]
        n = len(xs)
        sx = sum(xs)
        sy = sum(ys)
        sxy = sum(x * y for x, y in zip(xs, ys))
        sxx = sum(x * x for x in xs)
        slope = (n * sxy - sx * sy) / (n * sxx - sx * sx)
        return slope, results
    
    return 0.0, results


def gap_energy(
    points: List[float],
    s: float,
    sorted_descending: bool = True
) -> float:
    """
    Compute the s-energy of gaps between consecutive points.
    
    E_s = Σ_{k} |x_{k+1} - x_k|^s
    
    The critical exponent s* where E_s transitions from divergent to
    convergent (as the number of points → ∞) equals the Minkowski dimension.
    
    For the prime log-image:
    - s < 1: E_s → ∞ (diverges)
    - s = 1: E_s = 1/log(2) - 1/log(p_max) (telescopes, → 1/log(2))
    - s > 1: E_s < ∞ (converges)
    
    Critical exponent s* = 1 = dim_M.
    """
    if len(points) < 2:
        return 0.0
    
    pts = sorted(points, reverse=sorted_descending)
    energy = 0.0
    for i in range(len(pts) - 1):
        gap = abs(pts[i] - pts[i + 1])
        if gap > 0:
            energy += gap ** s
    return energy


def twin_prime_log_distance(p: int) -> float:
    """
    Compute the log-metric distance between twin primes (p, p+2).
    
    d(p, p+2) = (log(p+2) - log(p)) / (log(p) · log(p+2))
             = log(1 + 2/p) / (log(p) · log(p+2))
             ≈ 2 / (p · log²(p))  for large p
    
    This shows twin primes are exponentially compressed in the log metric.
    """
    return (math.log(p + 2) - math.log(p)) / (math.log(p) * math.log(p + 2))


def dimension_gap_certificate(
    primes: List[int],
    num_scales: int = 20
) -> Dict[str, float]:
    """
    Compute a certificate demonstrating the Hausdorff-Minkowski dimension gap.
    
    Returns a dictionary with:
    - hausdorff_dim: 0 (proved theorem)
    - minkowski_dim: estimated from box counting
    - gap: minkowski_dim - hausdorff_dim
    - critical_exponent: estimated from gap energy
    - max_log_inv: supremum of the image (= 1/log(2))
    """
    image = [log_inverse_embedding(p) for p in primes]
    
    mink_dim, _ = estimate_minkowski_dimension(image, num_scales=num_scales)
    
    # Find critical exponent via bisection
    s_low, s_high = 0.5, 2.0
    small_primes = primes[:min(len(primes), 50000)]
    small_image = [log_inverse_embedding(p) for p in small_primes]
    
    for _ in range(20):
        s_mid = (s_low + s_high) / 2
        E = gap_energy(small_image, s_mid)
        if E > 100:  # "diverges"
            s_low = s_mid
        else:
            s_high = s_mid
    
    return {
        "hausdorff_dim": 0.0,
        "minkowski_dim": mink_dim,
        "gap": mink_dim,
        "critical_exponent": (s_low + s_high) / 2,
        "max_log_inv": 1.0 / math.log(2),
        "num_primes": len(primes),
    }


if __name__ == "__main__":
    primes = sieve_of_eratosthenes(1_000_000)
    cert = dimension_gap_certificate(primes)
    print("Dimension Gap Certificate:")
    for k, v in cert.items():
        print(f"  {k}: {v}")
