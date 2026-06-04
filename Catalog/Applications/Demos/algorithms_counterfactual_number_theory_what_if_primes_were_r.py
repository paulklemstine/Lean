#!/usr/bin/env python3
"""
Algorithms for Counterfactual Number Theory

Type-hinted implementations of the core algorithms used in the
counterfactual prime number theory research.
"""

import math
import random
from typing import Set, List, Tuple, Dict, Optional, FrozenSet
from collections import defaultdict


# === Algorithm 1: Cramér Random Prime Generator ===

def cramer_random_primes(N: int, seed: Optional[int] = None) -> Set[int]:
    """Generate a Cramér random pseudo-prime set up to N.

    Each integer n ≥ 2 is included independently with probability 1/ln(n),
    matching the asymptotic density of actual primes.

    Args:
        N: Upper bound for generation
        seed: Random seed for reproducibility

    Returns:
        Set of "pseudo-primes" up to N

    Time complexity: O(N)
    Space complexity: O(N/log N) expected
    """
    if seed is not None:
        random.seed(seed)
    S: Set[int] = set()
    for n in range(2, N + 1):
        if random.random() < 1.0 / math.log(n):
            S.add(n)
    return S


# === Algorithm 2: Product Witness Finder ===

def find_product_witnesses(S: Set[int], N: int) -> List[Tuple[int, int, int]]:
    """Find all product witnesses (a, b, a*b) in S with a*b ≤ N.

    A product witness proves that S is NOT product-free, and therefore
    cannot support unique factorization.

    Args:
        S: The pseudo-prime set
        N: Upper bound for products

    Returns:
        List of triples (a, b, c) with a ≤ b, c = a*b, all in S

    Time complexity: O(|S|² log |S|)
    Space complexity: O(witness_count)
    """
    witnesses: List[Tuple[int, int, int]] = []
    S_sorted = sorted(S)
    S_set = set(S)  # ensure O(1) lookup

    for i, a in enumerate(S_sorted):
        if a * a > N:
            break
        for b in S_sorted[i:]:
            product = a * b
            if product > N:
                break
            if product in S_set:
                witnesses.append((a, b, product))

    return witnesses


# === Algorithm 3: S-Factorization Enumerator ===

def enumerate_factorizations(
    S: Set[int], n: int, max_depth: int = 20
) -> List[List[int]]:
    """Enumerate all S-factorizations of n.

    An S-factorization is a multiset of elements from S whose product is n.
    Returns factorizations as sorted lists (representing multisets).

    Args:
        S: The pseudo-prime set
        n: Number to factorize
        max_depth: Maximum recursion depth

    Returns:
        List of factorizations, each a sorted list of S-elements

    Note: Exponential worst case, but bounded by max_depth.
    """
    if max_depth <= 0:
        return []

    results: List[List[int]] = []

    # Base case: n itself is in S
    if n in S:
        results.append([n])

    # Recursive case: split n = a * (n/a) for a ∈ S, a | n, a ≤ √n
    S_sorted = sorted(x for x in S if 2 <= x * x <= n)

    for a in S_sorted:
        if n % a == 0:
            remainder = n // a
            sub_facts = enumerate_factorizations(S, remainder, max_depth - 1)
            for sf in sub_facts:
                if sf and a <= sf[0]:  # canonical ordering to avoid duplicates
                    results.append([a] + sf)

    return results


# === Algorithm 4: Product-Free Density Estimator ===

def estimate_product_free_density(
    N: int, trials: int = 100, seed: int = 42
) -> Dict[str, float]:
    """Estimate the fraction of Cramér random sets that are product-free.

    For each trial, generates a Cramér random set and checks product-freeness.

    Args:
        N: Size parameter
        trials: Number of random trials
        seed: Base random seed

    Returns:
        Dictionary with 'product_free_fraction', 'mean_witnesses', etc.
    """
    random.seed(seed)
    pf_count = 0
    total_witnesses = 0
    total_size = 0

    for _ in range(trials):
        S = cramer_random_primes(N)
        witnesses = find_product_witnesses(S, N)
        if not witnesses:
            pf_count += 1
        total_witnesses += len(witnesses)
        total_size += len(S)

    return {
        'N': N,
        'trials': trials,
        'product_free_fraction': pf_count / trials,
        'mean_witnesses': total_witnesses / trials,
        'mean_set_size': total_size / trials,
        'expected_size': N / math.log(N) if N > 1 else 0,
    }


# === Algorithm 5: Shadow Size Calculator ===

def compute_shadow_statistics(
    S: Set[int], N: int
) -> Dict[str, int]:
    """Compute shadow statistics for a pseudo-prime set.

    For each p ∈ S, computes the shadow {p*k : k ∈ S, p*k ≤ N}
    and its overlap with S.

    Args:
        S: The pseudo-prime set
        N: Upper bound

    Returns:
        Dictionary with shadow sizes and overlap counts
    """
    total_shadow = 0
    total_overlap = 0
    max_overlap = 0
    worst_p = 0

    for p in sorted(S):
        if p * min(S) > N:
            break
        shadow = {p * k for k in S if p * k <= N and k != p}
        overlap = shadow & S
        total_shadow += len(shadow)
        total_overlap += len(overlap)
        if len(overlap) > max_overlap:
            max_overlap = len(overlap)
            worst_p = p

    return {
        'set_size': len(S),
        'total_shadow_size': total_shadow,
        'total_overlap': total_overlap,
        'max_overlap_element': worst_p,
        'max_overlap_size': max_overlap,
    }


# === Algorithm 6: Factorization Length Spectrum ===

def factorization_length_spectrum(
    S: Set[int], N: int
) -> Dict[int, Dict[str, int]]:
    """Compute the factorization length spectrum for numbers up to N.

    For each number n ≤ N, finds all S-factorizations and records
    which lengths appear.

    Args:
        S: The pseudo-prime set
        N: Upper bound

    Returns:
        Mapping from factorization length to count of numbers
        having a factorization of that length
    """
    spectrum: Dict[int, int] = defaultdict(int)
    multi_count = 0

    for n in range(2, N + 1):
        facts = enumerate_factorizations(S, n, max_depth=6)
        lengths = set(len(f) for f in facts)
        for l in lengths:
            spectrum[l] += 1
        if len(lengths) > 1:
            multi_count += 1

    return {
        'spectrum': dict(spectrum),
        'numbers_with_multiple_lengths': multi_count,
        'total_checked': N - 1,
    }


if __name__ == "__main__":
    print("=== Product-Free Density Estimates ===")
    for N in [50, 100, 500, 1000]:
        stats = estimate_product_free_density(N, trials=200)
        print(f"N={N:>5}: PF fraction={stats['product_free_fraction']:.3f}, "
              f"mean witnesses={stats['mean_witnesses']:.1f}, "
              f"mean |S|={stats['mean_set_size']:.1f}")

    print("\n=== Shadow Statistics ===")
    S = cramer_random_primes(1000, seed=42)
    stats = compute_shadow_statistics(S, 1000)
    print(f"|S| = {stats['set_size']}")
    print(f"Total shadow overlap: {stats['total_overlap']}")
    print(f"Worst element: {stats['max_overlap_element']} with {stats['max_overlap_size']} overlaps")
