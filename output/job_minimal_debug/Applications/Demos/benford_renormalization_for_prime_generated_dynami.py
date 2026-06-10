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


#!/usr/bin/env python3
"""
Demonstration of Benford's Law for Prime-Generated Dynamical Orbits.

This script demonstrates the key theorems from the research:
1. Growth-renormalization estimate for T_c(x) = x^2 + c
2. Leading digit distributions follow Benford's law
3. Monomial maps produce exact (non-perturbed) logarithmic evolution
"""

import math
from collections import Counter
from typing import List, Tuple


def sieve_primes(n: int) -> List[int]:
    """Return all primes up to n using the Sieve of Eratosthenes."""
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
    """Return the leading digit of |n| in the given base."""
    n = abs(n)
    if n == 0:
        return 0
    while n >= base:
        n //= base
    return n


def benford_probability(m: int, base: int = 10) -> float:
    """Benford target probability for digit m in base b."""
    return math.log(1 + 1/m) / math.log(base)


def iterate_quad(x: int, c: int, n: int) -> int:
    """Compute T_c^[n](x) where T_c(x) = x^2 + c."""
    for _ in range(n):
        x = x * x + c
    return x


def demo_growth_estimate():
    """
    Demo 1: Growth-Renormalization Estimate

    Verify that |log|T_c^[n](p)| - 2^n * log(p)| <= C * 2^n / p
    for T_c(x) = x^2 + c.
    """
    print("=" * 70)
    print("DEMO 1: Growth-Renormalization Estimate")
    print("=" * 70)
    print()
    print("Theorem: For T_c(x) = x² + c, there exist C, P > 0 such that")
    print("for all primes p ≥ P and all n ≥ 0:")
    print("  |log|T_c^[n](p)| - 2^n · log(p)| ≤ C · 2^n / p")
    print()

    for c in [0, 1, -1, 5, -10]:
        print(f"--- c = {c} ---")
        primes = sieve_primes(100)
        max_normalized_error = 0.0

        for p in primes:
            x = p
            for n in range(1, 8):
                x = x * x + c
                if x <= 0:
                    break
                predicted = (2 ** n) * math.log(p)
                actual = math.log(abs(x))
                error = abs(actual - predicted)
                normalized = error * p / (2 ** n) if 2 ** n > 0 else 0
                max_normalized_error = max(max_normalized_error, normalized)

        print(f"  Max normalized error (C estimate): {max_normalized_error:.4f}")
        print()


def demo_benford_digits():
    """
    Demo 2: Benford's Law for Quadratic Prime Orbits

    Compute empirical digit frequencies and compare to Benford targets.
    """
    print("=" * 70)
    print("DEMO 2: Benford's Law for Quadratic Prime Orbits")
    print("=" * 70)
    print()

    c = 1
    base = 10
    X = 5000
    N_max = 12
    primes = sieve_primes(X)

    print(f"Map: T(x) = x² + {c}")
    print(f"Base: {base}")
    print(f"Primes up to {X}: {len(primes)} primes")
    print(f"Iterates: 1 to {N_max}")
    print()

    digit_counts = Counter()
    total = 0

    for p in primes:
        x = p
        for n in range(1, N_max + 1):
            x = x * x + c
            d = leading_digit(x, base)
            if d > 0:
                digit_counts[d] += 1
                total += 1

    print(f"{'Digit':>6} {'Observed':>10} {'Benford':>10} {'Deviation':>10}")
    print("-" * 40)
    chi_sq = 0.0
    for m in range(1, base):
        observed = digit_counts[m] / total if total > 0 else 0
        expected = benford_probability(m, base)
        deviation = observed - expected
        chi_sq += (observed - expected) ** 2 / expected
        print(f"{m:>6} {observed:>10.4f} {expected:>10.4f} {deviation:>+10.4f}")

    print()
    print(f"Chi-squared statistic: {chi_sq:.6f}")
    print(f"(Critical value at 1% for 8 df: 20.09)")
    print(f"Benford's law: {'CONFIRMED' if chi_sq < 20.09 else 'REJECTED'}")
    print()


def demo_benford_probabilities():
    """
    Demo 3: Benford Probabilities Sum to 1

    Verify the telescoping sum: sum_{m=1}^{b-1} log_b(1 + 1/m) = 1.
    """
    print("=" * 70)
    print("DEMO 3: Benford Probabilities Sum to 1")
    print("=" * 70)
    print()

    for base in [2, 3, 5, 10, 16]:
        probs = [benford_probability(m, base) for m in range(1, base)]
        total = sum(probs)
        print(f"Base {base:>2}: sum = {total:.15f}  (digits: {', '.join(f'{p:.4f}' for p in probs)})")

    print()


def demo_monomial_obstruction():
    """
    Demo 4: Monomial Map - Exact Logarithmic Evolution

    Show that for T(x) = x^d, log|T^[n](p)| = d^n * log(p) exactly.
    """
    print("=" * 70)
    print("DEMO 4: Monomial Obstruction (Exact Logarithmic Evolution)")
    print("=" * 70)
    print()
    print("For the monomial map T(x) = x^d:")
    print("  log|T^[n](p)| = d^n · log(p)  (EXACT, no error term)")
    print()

    d = 2
    for p in [2, 3, 5, 7, 11]:
        print(f"  p = {p}, d = {d}:")
        x = p
        for n in range(1, 6):
            x = x ** d
            exact = (d ** n) * math.log(p)
            actual = math.log(x)
            error = abs(actual - exact)
            print(f"    n={n}: log(x^(2^{n})) = {actual:.6f}, "
                  f"2^{n}·log({p}) = {exact:.6f}, "
                  f"error = {error:.2e}")
        print()

    print("Compare with quadratic map T(x) = x² + 1 (non-zero error):")
    for p in [2, 3, 5]:
        print(f"  p = {p}:")
        x = p
        for n in range(1, 6):
            x = x * x + 1
            predicted = (2 ** n) * math.log(p)
            actual = math.log(abs(x))
            error = abs(actual - predicted)
            print(f"    n={n}: error = {error:.6f}, "
                  f"normalized (×p/2^n) = {error * p / (2**n):.6f}")
        print()


def demo_eventually_periodic():
    """
    Demo 5: Eventually Periodic Orbits on the Torus

    Show that fract(d^n * a/q) is eventually periodic.
    """
    print("=" * 70)
    print("DEMO 5: Eventually Periodic Torus Orbits (Rational Phase)")
    print("=" * 70)
    print()

    d = 2
    a, q = 1, 4
    print(f"d = {d}, a/q = {a}/{q}")
    print(f"Sequence of fract(d^n * a/q):")
    values = []
    for n in range(15):
        val = ((d ** n) * a / q) % 1
        values.append(val)
        print(f"  n={n:>2}: fract({d**n:>6} * {a}/{q}) = {val:.4f}")

    distinct = set(round(v, 10) for v in values)
    print(f"\nDistinct values: {len(distinct)} (bounded by q = {q})")

    print()
    d = 3
    a, q = 1, 7
    print(f"d = {d}, a/q = {a}/{q}, gcd(d,q) = {math.gcd(d,q)}")
    print(f"Purely periodic since gcd(d,q) = 1:")
    for n in range(15):
        val = ((d ** n) * a / q) % 1
        print(f"  n={n:>2}: fract({d**n:>6} * {a}/{q}) = {val:.6f}")
    print()


def demo_multi_base():
    """
    Demo 6: Base Independence

    Test Benford's law in multiple bases for the same dynamical system.
    """
    print("=" * 70)
    print("DEMO 6: Base Independence of Benford's Law")
    print("=" * 70)
    print()

    c = 1
    X = 3000
    N_max = 10
    primes = sieve_primes(X)

    for base in [2, 3, 5, 10, 16]:
        digit_counts = Counter()
        total = 0
        for p in primes:
            x = p
            for n in range(1, N_max + 1):
                x = x * x + c
                d = leading_digit(x, base)
                if d > 0:
                    digit_counts[d] += 1
                    total += 1

        chi_sq = 0.0
        for m in range(1, base):
            observed = digit_counts[m] / total if total > 0 else 0
            expected = benford_probability(m, base)
            chi_sq += (observed - expected) ** 2 / expected

        print(f"Base {base:>2}: χ² = {chi_sq:.6f}  "
              f"({'BENFORD' if chi_sq < 0.1 else 'DEVIANT'})")

    print()


if __name__ == "__main__":
    demo_growth_estimate()
    demo_benford_digits()
    demo_benford_probabilities()
    demo_monomial_obstruction()
    demo_eventually_periodic()
    demo_multi_base()
