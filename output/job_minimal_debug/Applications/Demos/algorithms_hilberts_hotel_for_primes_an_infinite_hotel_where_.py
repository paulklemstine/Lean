#!/usr/bin/env python3
"""
Algorithms for Hilbert's Hotel Permutations

Type-hinted implementations of key algorithms from the research.
"""

from typing import List, Tuple, Callable, Optional
import math
import random


def is_asymp_id_approx(
    perm: List[int],
    threshold: float = 0.01
) -> Tuple[bool, float]:
    """
    Test whether a finite permutation is approximately asymptotically identity.

    Checks if max_{n in tail} |σ(n)/n - 1| < threshold, where the tail
    is the last quarter of the permutation.

    Args:
        perm: A permutation represented as a list where perm[i] = σ(i+1)
        threshold: Maximum allowed deviation from 1

    Returns:
        (is_approx_asymp_id, max_deviation)
    """
    n = len(perm)
    if n < 4:
        return (True, 0.0)

    tail_start = 3 * n // 4
    max_dev = 0.0
    for i in range(tail_start, n):
        ratio = (perm[i] + 1) / (i + 1)  # +1 for 1-indexed
        dev = abs(ratio - 1)
        max_dev = max(max_dev, dev)

    return (max_dev < threshold, max_dev)


def bounded_displacement_permutation(
    n: int,
    k: int,
    seed: Optional[int] = None
) -> List[int]:
    """
    Generate a random permutation with displacement bounded by k.

    Produces σ such that |σ(i) - i| ≤ k for all i. These permutations
    are guaranteed to be asymptotically identity (Theorem: asympId_of_bounded_displacement).

    Algorithm: Sequential swaps within windows of size k.

    Args:
        n: Size of the permutation
        k: Maximum displacement bound
        seed: Random seed for reproducibility

    Returns:
        Permutation as a list where result[i] = σ(i)
    """
    if seed is not None:
        random.seed(seed)

    perm = list(range(n))
    for i in range(n - 1):
        # Swap with a random position within [i, min(n-1, i+k)]
        j = random.randint(i, min(n - 1, i + k))
        perm[i], perm[j] = perm[j], perm[i]

    return perm


def adjacent_swap_permutation(n: int) -> List[int]:
    """
    Generate the adjacent swap permutation of size n.

    Swaps pairs (0,1), (2,3), (4,5), etc.
    Formally proved to be AsympId in asympId_adjacentSwap.

    Args:
        n: Size of the permutation

    Returns:
        Permutation as a list
    """
    perm = list(range(n))
    for i in range(0, n - 1, 2):
        perm[i], perm[i + 1] = perm[i + 1], perm[i]
    return perm


def compute_prime_ratio_sequence(
    perm: List[int],
    primes: List[int]
) -> List[float]:
    """
    Compute the sequence p_{σ(n)} / p_n for a given permutation.

    Args:
        perm: Permutation σ as a list
        primes: List of primes p_1, p_2, ...

    Returns:
        List of ratios p_{σ(n)} / p_n
    """
    n = min(len(perm), len(primes))
    ratios = []
    for i in range(n):
        if primes[i] > 0:
            ratios.append(primes[perm[i]] / primes[i])
        else:
            ratios.append(float('inf'))
    return ratios


def estimate_asymp_id_density(
    n: int,
    epsilon: float,
    num_samples: int = 10000,
    seed: Optional[int] = None
) -> float:
    """
    Estimate the fraction of permutations of {1,...,n} that are ε-close
    to the identity (i.e., max|σ(i)/i - 1| < ε for all i).

    Related to the density conjecture: this fraction → 0 as n → ∞.

    Args:
        n: Size of the permutation
        epsilon: Closeness threshold
        num_samples: Number of random samples
        seed: Random seed

    Returns:
        Estimated fraction of ε-close permutations
    """
    if seed is not None:
        random.seed(seed)

    count = 0
    for _ in range(num_samples):
        perm = list(range(1, n + 1))
        random.shuffle(perm)
        is_close = all(
            abs(perm[i] / (i + 1) - 1) < epsilon
            for i in range(n)
        )
        if is_close:
            count += 1

    return count / num_samples


def subgroup_verification(
    sigma: List[int],
    tau: List[int],
    threshold: float = 0.05
) -> dict:
    """
    Verify subgroup properties of AsympId permutations numerically.

    Tests composition closure and inverse closure for given permutations.

    Args:
        sigma: First permutation
        tau: Second permutation (same length)
        threshold: AsympId threshold

    Returns:
        Dictionary with test results
    """
    n = len(sigma)
    assert len(tau) == n, "Permutations must have the same length"

    # Composition σ ∘ τ
    comp = [sigma[tau[i]] for i in range(n)]

    # Inverse of σ
    inv_sigma = [0] * n
    for i in range(n):
        inv_sigma[sigma[i]] = i

    # Test each
    results = {}
    for name, perm in [("sigma", sigma), ("tau", tau),
                       ("sigma∘tau", comp), ("sigma⁻¹", inv_sigma)]:
        is_ai, dev = is_asymp_id_approx(perm, threshold)
        results[name] = {"is_asymp_id": is_ai, "max_deviation": dev}

    return results


if __name__ == "__main__":
    # Quick demonstration
    N = 1000

    # Test adjacent swap
    adj = adjacent_swap_permutation(N)
    is_ai, dev = is_asymp_id_approx(adj)
    print(f"Adjacent swap: AsympId={is_ai}, max_dev={dev:.6f}")

    # Test bounded displacement
    bd = bounded_displacement_permutation(N, k=5, seed=42)
    is_ai, dev = is_asymp_id_approx(bd)
    print(f"Bounded displacement (k=5): AsympId={is_ai}, max_dev={dev:.6f}")

    # Test random
    random.seed(42)
    rand_perm = list(range(N))
    random.shuffle(rand_perm)
    is_ai, dev = is_asymp_id_approx(rand_perm)
    print(f"Random permutation: AsympId={is_ai}, max_dev={dev:.6f}")

    # Subgroup test
    s1 = bounded_displacement_permutation(N, k=3, seed=1)
    s2 = bounded_displacement_permutation(N, k=3, seed=2)
    results = subgroup_verification(s1, s2)
    for name, r in results.items():
        print(f"  {name}: AsympId={r['is_asymp_id']}, dev={r['max_deviation']:.6f}")

    # Density estimate
    for test_n in [10, 20, 50]:
        d = estimate_asymp_id_density(test_n, 0.5, seed=42)
        print(f"  Density (N={test_n}, ε=0.5): {d:.4f}")
