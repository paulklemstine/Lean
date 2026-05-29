"""
Algorithms for Prime Fractal Analysis
======================================
Implements box-counting dimension estimation, entropy computation,
and fractal analysis of prime distributions under the logarithmic metric.
"""

import math
from typing import List, Dict, Tuple, Optional
from collections import Counter


def sieve_primes(N: int) -> List[int]:
    """
    Sieve of Eratosthenes.

    Time: O(N log log N)
    Space: O(N)

    Args:
        N: Upper bound for primes.

    Returns:
        Sorted list of primes up to N.
    """
    if N < 2:
        return []
    sieve = [True] * (N + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(N**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, N + 1, i):
                sieve[j] = False
    return [i for i in range(2, N + 1) if sieve[i]]


def log_embed(p: int) -> float:
    """
    Logarithmic embedding: p ↦ 1/log(p).

    Maps primes into (0, 1/log(2)] ≈ (0, 1.4427].
    Larger primes map closer to 0.

    Args:
        p: A prime number (must be ≥ 2).

    Returns:
        1/log(p).
    """
    return 1.0 / math.log(p)


def prime_fractal_dist(p: int, q: int) -> float:
    """
    Prime fractal metric: d(p,q) = |1/log(p) - 1/log(q)|.

    Properties (proved in Lean):
    - Symmetric: d(p,q) = d(q,p)
    - Triangle inequality: d(p,r) ≤ d(p,q) + d(q,r)
    - Positive definite on primes: d(p,q) = 0 ↔ p = q

    Args:
        p, q: Prime numbers (must be ≥ 2).

    Returns:
        The fractal distance between p and q.
    """
    return abs(log_embed(p) - log_embed(q))


def box_counting_dimension(
    primes: List[int],
    epsilon_range: Optional[List[float]] = None,
    num_scales: int = 20
) -> Tuple[List[float], List[float], float]:
    """
    Estimate the box-counting (Minkowski) dimension of the prime fractal.

    Algorithm:
    1. Embed primes via p ↦ 1/log(p) into [0, 1/log(2)].
    2. For each scale ε, count distinct boxes [kε, (k+1)ε) containing embeddings.
    3. Fit log(box_count) vs log(1/ε) to estimate dimension.

    Time: O(|primes| × num_scales)
    Space: O(|primes|)

    Args:
        primes: List of primes.
        epsilon_range: List of ε values to use. If None, auto-generated.
        num_scales: Number of scales if epsilon_range is None.

    Returns:
        (epsilons, dimensions, slope): Lists of ε values, dimension estimates,
        and the fitted slope (overall dimension estimate).
    """
    if not primes:
        return [], [], 0.0

    embeddings = [log_embed(p) for p in primes]

    if epsilon_range is None:
        max_embed = max(embeddings)
        min_eps = max_embed / (len(primes) * 10)
        max_eps = max_embed / 2
        epsilon_range = [
            min_eps * (max_eps / min_eps) ** (i / (num_scales - 1))
            for i in range(num_scales)
        ]

    log_inv_eps = []
    log_counts = []
    dimensions = []

    for eps in sorted(epsilon_range):
        boxes = set()
        for e in embeddings:
            boxes.add(int(math.floor(e / eps)))
        bc = len(boxes)
        if bc > 0 and eps < 1:
            lie = math.log(1.0 / eps)
            lbc = math.log(bc)
            log_inv_eps.append(lie)
            log_counts.append(lbc)
            dimensions.append(lbc / lie if lie > 0 else 0.0)

    # Linear regression for slope
    if len(log_inv_eps) >= 2:
        n = len(log_inv_eps)
        sx = sum(log_inv_eps)
        sy = sum(log_counts)
        sxx = sum(x * x for x in log_inv_eps)
        sxy = sum(x * y for x, y in zip(log_inv_eps, log_counts))
        slope = (n * sxy - sx * sy) / (n * sxx - sx * sx) if (n * sxx - sx * sx) > 0 else 0.0
    else:
        slope = dimensions[0] if dimensions else 0.0

    return sorted(epsilon_range), dimensions, slope


def prime_log_entropy(primes: List[int], epsilon: float) -> float:
    """
    Shannon entropy of the prime distribution in the logarithmic metric.

    Partitions the embedding space into intervals of width ε and computes
    H = -Σ (freq_i × log(freq_i)).

    Properties (proved in Lean):
    - H ≥ 0 (non-negativity of entropy)
    - H = 0 iff all primes fall in the same box
    - H ≤ log(box_count) (maximum entropy bound)

    Time: O(|primes|)
    Space: O(box_count)

    Args:
        primes: List of primes.
        epsilon: Box width.

    Returns:
        Shannon entropy value.
    """
    boxes = [int(math.floor(log_embed(p) / epsilon)) for p in primes]
    counts = Counter(boxes)
    total = len(primes)
    entropy = 0.0
    for count in counts.values():
        freq = count / total
        if freq > 0:
            entropy -= freq * math.log(freq)
    return entropy


def twin_prime_analysis(N: int) -> Dict:
    """
    Analyze twin prime pairs under the fractal metric.

    For each twin prime pair (p, p+2):
    - Compute fractal distance d(p, p+2)
    - Compute theoretical bound 1/log²(p)
    - Track the ratio d/bound

    Time: O(N log log N)
    Space: O(π(N))

    Args:
        N: Upper bound.

    Returns:
        Dictionary with analysis results.
    """
    primes = sieve_primes(N)
    prime_set = set(primes)

    twins = [(p, p + 2) for p in primes if p + 2 in prime_set]
    distances = []
    bounds = []
    ratios = []

    for p, q in twins:
        d = prime_fractal_dist(p, q)
        bound = 1.0 / math.log(p) ** 2
        distances.append(d)
        bounds.append(bound)
        ratios.append(d / bound if bound > 0 else 0)

    return {
        "twin_count": len(twins),
        "twins": twins,
        "distances": distances,
        "bounds": bounds,
        "ratios": ratios,
        "mean_ratio": sum(ratios) / len(ratios) if ratios else 0,
        "max_ratio": max(ratios) if ratios else 0,
        "all_satisfy_bound": all(d < b for d, b in zip(distances, bounds)),
    }


def multiscale_dimension_analysis(N: int) -> Dict:
    """
    Multi-scale analysis of the prime fractal dimension.

    Computes box-counting dimension at multiple scales to detect
    scale-dependent fractal behavior that might indicate twin prime effects.

    Time: O(π(N) × num_scales)
    Space: O(π(N))

    Args:
        N: Upper bound for primes.

    Returns:
        Dictionary with dimension estimates at each scale.
    """
    primes = sieve_primes(N)

    # Define scales
    scales = [10**(-k / 2) for k in range(2, 14)]

    results = []
    for eps in scales:
        bc = len(set(int(math.floor(log_embed(p) / eps)) for p in primes))
        dim = math.log(bc) / math.log(1.0 / eps) if bc > 0 and eps < 1 else 0
        H = prime_log_entropy(primes, eps)
        results.append({
            "epsilon": eps,
            "box_count": bc,
            "dimension": dim,
            "entropy": H,
        })

    return {
        "N": N,
        "num_primes": len(primes),
        "scales": results,
    }


if __name__ == "__main__":
    print("=== Box-Counting Dimension Analysis ===\n")
    for N_exp in [5, 6]:
        N = 10**N_exp
        primes = sieve_primes(N)
        eps_range = [10**(-k/2) for k in range(2, 12)]
        epsilons, dims, slope = box_counting_dimension(primes, eps_range)
        print(f"N = 10^{N_exp} ({len(primes)} primes)")
        print(f"  Fitted dimension (slope): {slope:.6f}")
        for eps, d in zip(epsilons, dims):
            print(f"  ε = {eps:.6f}: dim ≈ {d:.6f}")
        print()

    print("\n=== Twin Prime Analysis ===\n")
    result = twin_prime_analysis(100000)
    print(f"Twin primes up to 100000: {result['twin_count']}")
    print(f"All satisfy d < 1/log²(p): {result['all_satisfy_bound']}")
    print(f"Mean ratio d/(1/log²(p)): {result['mean_ratio']:.6f}")
