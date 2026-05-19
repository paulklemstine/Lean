#!/usr/bin/env python3
"""
Applications of Benford Renormalization Theory.

This module demonstrates practical applications of the Benford renormalization
framework for prime-generated dynamical orbits:

1. Anomaly detection in dynamical orbit data
2. Structural classification of polynomial maps
3. Digit-based chaos indicator
"""

import math
from collections import Counter
from typing import List, Tuple, Dict, Callable


def sieve_primes(n: int) -> List[int]:
    """Return all primes up to n."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def leading_digit(n: int, base: int = 10) -> int:
    """Leading digit of |n| in given base."""
    n = abs(n)
    if n == 0:
        return 0
    while n >= base:
        n //= base
    return n


def benford_target(m: int, base: int = 10) -> float:
    """Benford probability for digit m in base b."""
    return math.log(1 + 1/m) / math.log(base)


# ============================================================
# Application 1: Anomaly Detection in Orbit Data
# ============================================================

def benford_anomaly_score(
    data: List[int],
    base: int = 10
) -> Tuple[float, str]:
    """
    Compute a Benford anomaly score for a list of integers.

    Uses chi-squared test against Benford's law to detect
    anomalous digit distributions that might indicate:
    - Fabricated/synthetic data
    - Hidden algebraic structure in the generating process
    - Computational errors in orbit generation

    Args:
        data: List of positive integers
        base: Number base for digit analysis

    Returns:
        Tuple of (chi_squared_score, assessment_string)

    >>> score, msg = benford_anomaly_score([10**i for i in range(1, 100)])
    >>> score > 10  # All leading digits are 1 — highly anomalous
    True
    """
    counts = Counter()
    total = 0
    for x in data:
        d = leading_digit(x, base)
        if d > 0:
            counts[d] += 1
            total += 1

    if total == 0:
        return 0.0, "NO_DATA"

    chi_sq = 0.0
    for m in range(1, base):
        observed = counts[m] / total
        expected = benford_target(m, base)
        chi_sq += total * (observed - expected) ** 2 / expected

    # Degrees of freedom = base - 2
    df = base - 2
    # Critical values (approximate) for common bases
    critical_01 = {8: 18.48, 9: 20.09, 14: 27.69, 15: 29.14}
    crit = critical_01.get(df, 3.0 * df)

    if chi_sq < crit * 0.1:
        assessment = "STRONGLY_BENFORD"
    elif chi_sq < crit:
        assessment = "BENFORD_COMPATIBLE"
    elif chi_sq < crit * 3:
        assessment = "MILDLY_ANOMALOUS"
    else:
        assessment = "HIGHLY_ANOMALOUS"

    return chi_sq, assessment


def detect_orbit_anomalies(
    map_fn: Callable[[int], int],
    prime_bound: int = 2000,
    max_iterates: int = 10,
    base: int = 10
) -> Dict:
    """
    Detect anomalies in dynamical orbit digit distributions.

    Generates orbits from prime seeds, computes digit distributions,
    and flags any deviations from Benford's law.

    Args:
        map_fn: The dynamical map T: ℤ → ℤ
        prime_bound: Upper bound for prime seeds
        max_iterates: Number of iterations
        base: Number base

    Returns:
        Dictionary with analysis results
    """
    primes = sieve_primes(prime_bound)
    orbit_values = []

    for p in primes:
        x = p
        for n in range(1, max_iterates + 1):
            x = map_fn(x)
            if abs(x) > 0:
                orbit_values.append(abs(x))

    score, assessment = benford_anomaly_score(orbit_values, base)

    return {
        'map_description': map_fn.__doc__ or 'unknown',
        'num_primes': len(primes),
        'num_orbit_values': len(orbit_values),
        'chi_squared': score,
        'assessment': assessment,
        'base': base
    }


# ============================================================
# Application 2: Structural Classification of Maps
# ============================================================

def classify_map_structure(
    map_fn: Callable[[int], int],
    prime_bound: int = 1000,
    max_iterates: int = 8
) -> Dict:
    """
    Classify a polynomial map as 'generic' or 'exceptional' based on
    its digit distribution from prime seeds.

    Theory: Generic nonlinear maps (with no semiconjugacy to monomials)
    produce Benford-distributed digits. Exceptional maps (monomial-like)
    may show structured deviations.

    Args:
        map_fn: The dynamical map
        prime_bound: Upper bound for prime seeds
        max_iterates: Number of iterations

    Returns:
        Classification results
    """
    # Test in multiple bases
    results = {}
    for base in [2, 3, 5, 10]:
        r = detect_orbit_anomalies(map_fn, prime_bound, max_iterates, base)
        results[base] = r

    all_benford = all(r['assessment'] in ['STRONGLY_BENFORD', 'BENFORD_COMPATIBLE']
                     for r in results.values())

    any_anomalous = any(r['assessment'] in ['MILDLY_ANOMALOUS', 'HIGHLY_ANOMALOUS']
                       for r in results.values())

    classification = 'GENERIC' if all_benford else ('EXCEPTIONAL' if any_anomalous else 'INDETERMINATE')

    return {
        'classification': classification,
        'base_results': {b: r['assessment'] for b, r in results.items()},
        'recommendation': (
            'Map appears generic (non-exceptional). Benford behavior confirmed.'
            if classification == 'GENERIC' else
            'Map may have exceptional algebraic structure. Investigate semiconjugacy to monomials.'
            if classification == 'EXCEPTIONAL' else
            'Inconclusive. Increase sample size or try additional bases.'
        )
    }


# ============================================================
# Application 3: Digit-Based Chaos Indicator
# ============================================================

def chaos_indicator(
    map_fn: Callable[[int], int],
    prime_bound: int = 1000,
    max_iterates: int = 10,
    base: int = 10
) -> Tuple[float, str]:
    """
    Use digit distributions as a chaos indicator for dynamical maps.

    The idea: Benford-distributed digits indicate chaotic (mixing) behavior
    on the logarithmic scale. Deviation from Benford suggests regularity
    or algebraic structure.

    The chaos index ranges from 0 (perfectly Benford = maximally chaotic
    on log scale) to 1 (maximally structured).

    Args:
        map_fn: The dynamical map
        prime_bound: Upper bound for prime seeds
        max_iterates: Number of iterations
        base: Number base

    Returns:
        Tuple of (chaos_index, description)
    """
    primes = sieve_primes(prime_bound)
    orbit_values = []

    for p in primes:
        x = p
        for n in range(1, max_iterates + 1):
            x = map_fn(x)
            if abs(x) > 0:
                orbit_values.append(abs(x))

    if not orbit_values:
        return 0.0, "No orbit data"

    # Compute KL divergence from Benford distribution
    counts = Counter()
    total = 0
    for x in orbit_values:
        d = leading_digit(x, base)
        if d > 0:
            counts[d] += 1
            total += 1

    if total == 0:
        return 0.0, "No valid digits"

    kl_div = 0.0
    for m in range(1, base):
        p_obs = max(counts[m] / total, 1e-10)
        p_ben = benford_target(m, base)
        kl_div += p_obs * math.log(p_obs / p_ben)

    # Normalize: max KL divergence is log(base-1) (uniform vs Benford)
    max_kl = sum(
        (1/(base-1)) * math.log((1/(base-1)) / benford_target(m, base))
        for m in range(1, base)
    )
    chaos_index = 1.0 - min(kl_div / max_kl, 1.0) if max_kl > 0 else 1.0

    if chaos_index > 0.99:
        desc = "Highly chaotic (perfect Benford)"
    elif chaos_index > 0.95:
        desc = "Chaotic (near-Benford)"
    elif chaos_index > 0.8:
        desc = "Moderately chaotic"
    elif chaos_index > 0.5:
        desc = "Weakly chaotic / structured"
    else:
        desc = "Highly structured (non-Benford)"

    return chaos_index, desc


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Orbit Anomaly Detection")
    print("=" * 70)
    print()

    # Test with quadratic maps
    maps = [
        (lambda x: x*x + 1, "x² + 1 (generic)"),
        (lambda x: x*x + 0, "x² (monomial)"),
        (lambda x: x*x - 1, "x² - 1 (generic)"),
        (lambda x: x*x*x + 1, "x³ + 1 (cubic generic)"),
    ]

    for map_fn, desc in maps:
        result = detect_orbit_anomalies(map_fn, prime_bound=2000, max_iterates=8)
        print(f"Map: {desc}")
        print(f"  χ² = {result['chi_squared']:.4f}, Assessment: {result['assessment']}")
        print()

    print("=" * 70)
    print("APPLICATION 2: Structural Classification")
    print("=" * 70)
    print()

    test_maps = [
        (lambda x: x*x + 1, "x² + 1"),
        (lambda x: x*x, "x² (monomial)"),
        (lambda x: x*x + 7, "x² + 7"),
    ]

    for map_fn, desc in test_maps:
        result = classify_map_structure(map_fn, prime_bound=1000, max_iterates=6)
        print(f"Map: {desc}")
        print(f"  Classification: {result['classification']}")
        print(f"  Base results: {result['base_results']}")
        print(f"  {result['recommendation']}")
        print()

    print("=" * 70)
    print("APPLICATION 3: Chaos Indicator")
    print("=" * 70)
    print()

    for map_fn, desc in maps:
        index, description = chaos_indicator(map_fn, prime_bound=1000, max_iterates=8)
        print(f"Map: {desc}")
        print(f"  Chaos index: {index:.4f} — {description}")
        print()
