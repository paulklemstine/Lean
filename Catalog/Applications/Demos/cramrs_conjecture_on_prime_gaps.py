#!/usr/bin/env python3
"""
Prime Gap Theory — Applications

Real-world applications of prime gap analysis, including:
- Cryptographic prime generation timing estimates
- Prime gap statistics for random number generation
- Cramér model accuracy assessment
- Spacing distribution analysis (Poisson vs Wigner-Dyson)
"""

import math
import time
from typing import List, Tuple, Dict
from collections import Counter


def sieve_of_eratosthenes(limit: int) -> List[int]:
    """Return all primes up to limit."""
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


# =============================================================================
# Application 1: Cryptographic Prime Search Estimates
# =============================================================================

def estimate_prime_search_time(bit_length: int) -> Dict[str, float]:
    """
    Estimate the expected number of candidates to test when generating
    a random prime of given bit length.

    By the Prime Number Theorem, the density of primes near n is 1/ln(n).
    For a b-bit number, n ≈ 2^b, so ln(n) ≈ b·ln(2).

    The Cramér model predicts that the maximum gap is about (b·ln 2)²,
    so in the worst case you might need to test that many candidates.

    Args:
        bit_length: Desired bit length of the prime.

    Returns:
        Dictionary with estimates.
    """
    n = 2 ** bit_length
    log_n = bit_length * math.log(2)

    return {
        "bit_length": bit_length,
        "approximate_n": f"2^{bit_length}",
        "expected_candidates_avg": log_n,
        "cramer_worst_case": log_n ** 2,
        "bertrand_worst_case": float(n),
        "ratio_cramer_to_bertrand": (log_n ** 2) / n,
    }


# =============================================================================
# Application 2: Model Accuracy Assessment
# =============================================================================

def assess_cramer_model_accuracy(limit: int) -> Dict[str, object]:
    """
    Compare Cramér model predictions to actual prime distribution.

    For intervals of various lengths around sample points, compare:
    - Actual number of primes
    - Cramér model expected number

    Args:
        limit: Upper bound for analysis.

    Returns:
        Assessment results.
    """
    primes_set = set(sieve_of_eratosthenes(limit))
    sample_points = [10**k for k in range(3, int(math.log10(limit)) + 1)]
    results = []

    for N in sample_points:
        if N >= limit:
            continue
        for H in [100, 1000]:
            if N + H > limit:
                continue

            # Actual count
            actual = sum(1 for m in range(N, N + H + 1) if m in primes_set)

            # Cramér expectation
            expected = sum(1.0 / math.log(m) for m in range(max(2, N), N + H + 1))

            # Certified bounds
            log_N = math.log(N)
            log_NH = math.log(N + H)
            lower = (H + 1) / log_NH
            upper = (H + 1) / log_N

            results.append({
                "N": N, "H": H,
                "actual": actual,
                "expected": round(expected, 2),
                "lower_bound": round(lower, 2),
                "upper_bound": round(upper, 2),
                "relative_error": round(abs(actual - expected) / max(expected, 1), 4),
            })

    return {"comparisons": results}


# =============================================================================
# Application 3: Gap Distribution Analysis
# =============================================================================

def analyze_gap_distribution(limit: int) -> Dict[str, object]:
    """
    Analyze the distribution of prime gaps and compare to theoretical predictions.

    Computes:
    - Gap histogram
    - Mean and variance
    - Maximum gap and normalized maximum
    - Comparison to Poisson spacing predictions

    Args:
        limit: Upper bound for prime search.

    Returns:
        Statistical analysis of gaps.
    """
    primes = sieve_of_eratosthenes(limit)
    gaps = [primes[i + 1] - primes[i] for i in range(len(primes) - 1)]

    # Basic statistics
    mean_gap = sum(gaps) / len(gaps)
    variance = sum((g - mean_gap) ** 2 for g in gaps) / len(gaps)
    max_gap = max(gaps)
    max_idx = gaps.index(max_gap)
    max_prime = primes[max_idx]

    # Normalized gaps
    normalized = []
    for i in range(len(gaps)):
        p = primes[i]
        if p >= 3:
            log_p = math.log(p)
            normalized.append(gaps[i] / (log_p ** 2))

    max_normalized = max(normalized) if normalized else 0

    # Gap histogram (even gaps dominate for p > 2)
    gap_counts = Counter(gaps)
    top_gaps = gap_counts.most_common(10)

    # Poisson comparison: in a Poisson process with rate 1/log(n),
    # gaps should be approximately exponentially distributed with
    # mean log(n). Normalized gaps g/(log p)² should cluster near 0.
    mean_normalized = sum(normalized) / len(normalized) if normalized else 0

    return {
        "num_primes": len(primes),
        "num_gaps": len(gaps),
        "mean_gap": round(mean_gap, 4),
        "variance": round(variance, 4),
        "max_gap": max_gap,
        "max_gap_at_prime": max_prime,
        "max_normalized_gap": round(max_normalized, 6),
        "mean_normalized_gap": round(mean_normalized, 6),
        "top_10_gap_frequencies": top_gaps,
    }


# =============================================================================
# Application 4: Spacing Statistics (Poisson vs Wigner-Dyson)
# =============================================================================

def spacing_analysis(limit: int) -> Dict[str, object]:
    """
    Compute spacing statistics for prime gaps and compare to
    Poisson and Wigner-Dyson predictions.

    The Cramér model predicts Poisson (exponential) spacing.
    Random matrix theory (GUE) predicts Wigner-Dyson spacing.

    Args:
        limit: Upper bound for analysis.

    Returns:
        Spacing statistics and comparison metrics.
    """
    primes = sieve_of_eratosthenes(limit)

    # Compute normalized spacings: gap / mean_local_gap
    # Use local windows for normalization
    window = 100
    spacings = []

    for i in range(window, len(primes) - window - 1):
        local_gaps = [primes[j + 1] - primes[j]
                      for j in range(i - window, i + window)]
        local_mean = sum(local_gaps) / len(local_gaps)
        if local_mean > 0:
            s = (primes[i + 1] - primes[i]) / local_mean
            spacings.append(s)

    if not spacings:
        return {"error": "Not enough primes for analysis"}

    # Empirical CDF
    spacings.sort()
    n = len(spacings)

    # Kolmogorov-Smirnov statistics
    # Poisson: P(s) = 1 - exp(-s)
    # Wigner: P(s) = 1 - exp(-π s²/4)
    ks_poisson = 0.0
    ks_wigner = 0.0

    for i, s in enumerate(spacings):
        ecdf = (i + 1) / n
        poisson_cdf = 1.0 - math.exp(-s)
        wigner_cdf = 1.0 - math.exp(-math.pi * s * s / 4.0)
        ks_poisson = max(ks_poisson, abs(ecdf - poisson_cdf))
        ks_wigner = max(ks_wigner, abs(ecdf - wigner_cdf))

    return {
        "num_spacings": n,
        "mean_spacing": round(sum(spacings) / n, 4),
        "ks_poisson": round(ks_poisson, 6),
        "ks_wigner": round(ks_wigner, 6),
        "closer_to": "Poisson" if ks_poisson < ks_wigner else "Wigner-Dyson",
        "poisson_better_by": round(ks_wigner - ks_poisson, 6),
    }


# =============================================================================
# Application 5: Prime Generation Benchmark
# =============================================================================

def benchmark_prime_generation(bit_lengths: List[int],
                               trials: int = 100) -> List[Dict]:
    """
    Benchmark how many candidates are tested to find primes of various sizes.

    Args:
        bit_lengths: List of desired bit lengths.
        trials: Number of primes to generate per bit length.

    Returns:
        Benchmark results.
    """
    import random
    results = []

    for bits in bit_lengths:
        lo = 2 ** (bits - 1)
        hi = 2 ** bits - 1
        candidates_tested = []

        for _ in range(trials):
            n = random.randint(lo, hi)
            if n % 2 == 0:
                n += 1
            count = 0
            m = n
            while True:
                count += 1
                # Simple trial division for small sizes
                if bits <= 20:
                    is_p = True
                    if m < 2:
                        is_p = False
                    elif m > 3:
                        if m % 2 == 0 or m % 3 == 0:
                            is_p = False
                        else:
                            j = 5
                            while j * j <= m:
                                if m % j == 0 or m % (j + 2) == 0:
                                    is_p = False
                                    break
                                j += 6
                    if is_p:
                        break
                else:
                    # For larger sizes, just count expected candidates
                    break
                m += 2

            candidates_tested.append(count)

        avg = sum(candidates_tested) / len(candidates_tested)
        theoretical = bits * math.log(2) / 2  # divide by 2 since we skip evens
        results.append({
            "bits": bits,
            "avg_candidates": round(avg, 1),
            "theoretical_expected": round(theoretical, 1),
            "max_candidates": max(candidates_tested),
            "cramer_predicted_max": round((bits * math.log(2)) ** 2 / 2, 1),
        })

    return results


if __name__ == "__main__":
    print("=" * 70)
    print("  PRIME GAP THEORY — APPLICATIONS")
    print("=" * 70)

    # App 1: Cryptographic estimates
    print("\n--- Application 1: Cryptographic Prime Search Estimates ---\n")
    for bits in [256, 512, 1024, 2048, 4096]:
        est = estimate_prime_search_time(bits)
        print(f"  {bits}-bit prime:")
        print(f"    Expected candidates (average): {est['expected_candidates_avg']:.1f}")
        print(f"    Cramér worst case: {est['cramer_worst_case']:.0f}")
        print(f"    Ratio Cramér/Bertrand: {est['ratio_cramer_to_bertrand']:.2e}")
        print()

    # App 2: Model accuracy
    print("--- Application 2: Cramér Model Accuracy ---\n")
    accuracy = assess_cramer_model_accuracy(1_000_000)
    for r in accuracy["comparisons"]:
        print(f"  N={r['N']}, H={r['H']}: actual={r['actual']}, "
              f"expected={r['expected']}, error={r['relative_error']:.1%}")
    print()

    # App 3: Gap distribution
    print("--- Application 3: Gap Distribution Analysis ---\n")
    dist = analyze_gap_distribution(1_000_000)
    print(f"  Primes: {dist['num_primes']:,}")
    print(f"  Mean gap: {dist['mean_gap']}")
    print(f"  Max gap: {dist['max_gap']} at prime {dist['max_gap_at_prime']}")
    print(f"  Max normalized gap: {dist['max_normalized_gap']}")
    print(f"  Mean normalized gap: {dist['mean_normalized_gap']}")
    print(f"  Top gap frequencies: {dist['top_10_gap_frequencies'][:5]}")
    print()

    # App 4: Spacing analysis
    print("--- Application 4: Spacing Statistics ---\n")
    spacing = spacing_analysis(1_000_000)
    print(f"  Spacings analyzed: {spacing['num_spacings']:,}")
    print(f"  K-S statistic (Poisson): {spacing['ks_poisson']}")
    print(f"  K-S statistic (Wigner-Dyson): {spacing['ks_wigner']}")
    print(f"  Closer to: {spacing['closer_to']}")
    print()

    # App 5: Prime generation benchmark
    print("--- Application 5: Prime Generation Benchmark ---\n")
    bench = benchmark_prime_generation([8, 10, 12, 14, 16, 18, 20])
    print(f"  {'Bits':>5s} | {'Avg':>6s} | {'Theory':>7s} | {'Max':>5s} | {'Cramér':>7s}")
    print("  " + "-" * 45)
    for r in bench:
        print(f"  {r['bits']:>5d} | {r['avg_candidates']:>6.1f} | "
              f"{r['theoretical_expected']:>7.1f} | {r['max_candidates']:>5d} | "
              f"{r['cramer_predicted_max']:>7.1f}")

    print("\nAll applications completed!")


#!/usr/bin/env python3
"""
Prime Gap Theory — Demonstration

Concrete numerical demonstrations of the theorems formalized in the
Certified Prime Gap Theory framework.
"""

import math
from typing import List, Tuple


def sieve_of_eratosthenes(limit: int) -> List[int]:
    """Return all primes up to `limit` using the Sieve of Eratosthenes."""
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def next_prime_after(n: int) -> int:
    """Find the smallest prime strictly greater than n."""
    m = n + 1
    while True:
        if is_prime_trial(m):
            return m
        m += 1


def is_prime_trial(n: int) -> bool:
    """Trial division primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def prime_gap_after(n: int) -> int:
    """The prime gap after n: distance to the next prime."""
    return next_prime_after(n) - n


def cramer_weight(m: int) -> float:
    """Cramér weight: 1/log(m) for m >= 2, else 0."""
    if m >= 2:
        return 1.0 / math.log(m)
    return 0.0


def expected_prime_likes(N: int, H: int) -> float:
    """Expected number of model-primes in [N, N+H]."""
    return sum(cramer_weight(m) for m in range(N, N + H + 1))


def demo_theorem_a():
    """Theorem A: Existence of next prime after any n."""
    print("=" * 60)
    print("THEOREM A: Next prime exists after every natural number")
    print("=" * 60)
    test_values = [0, 1, 10, 100, 1000, 10000, 100000]
    for n in test_values:
        p = next_prime_after(n)
        gap = p - n
        print(f"  nextPrimeAfter({n:>6d}) = {p:>6d}  (gap = {gap})")
    print()


def demo_theorem_b():
    """Theorem B: Prime gaps are always positive."""
    print("=" * 60)
    print("THEOREM B: Prime gap is always positive")
    print("=" * 60)
    for n in range(20):
        gap = prime_gap_after(n)
        assert gap > 0, f"Gap at {n} is {gap}, not positive!"
    print("  Verified: primeGapAfter(n) > 0 for all n in [0, 19]")
    print()


def demo_theorem_c():
    """Theorem C: Bertrand-based bound — gap ≤ n for n ≥ 1."""
    print("=" * 60)
    print("THEOREM C: primeGapAfter(n) ≤ n for n ≥ 1 (Bertrand)")
    print("=" * 60)
    violations = 0
    for n in range(1, 100001):
        gap = prime_gap_after(n)
        if gap > n:
            violations += 1
            print(f"  VIOLATION at n={n}: gap={gap}")
    print(f"  Tested n = 1 to 100000: {violations} violations")
    # Show how loose the bound is
    print("\n  How loose is Bertrand's bound?")
    for n in [100, 1000, 10000, 100000]:
        gap = prime_gap_after(n)
        ratio = gap / n
        print(f"    n={n:>6d}: gap={gap:>3d}, gap/n = {ratio:.6f}")
    print()


def demo_theorem_f():
    """Theorem F: Cramér model expectation bounds."""
    print("=" * 60)
    print("THEOREM F: Cramér model expectation sandwich bounds")
    print("=" * 60)
    N = 10000
    for H in [10, 50, 100, 500, 1000]:
        E = expected_prime_likes(N, H)
        upper = (H + 1) / math.log(N)
        lower = (H + 1) / math.log(N + H)

        # Count actual primes in [N, N+H]
        actual = sum(1 for m in range(N, N + H + 1) if is_prime_trial(m))

        print(f"  N={N}, H={H}:")
        print(f"    Lower bound:  {lower:.4f}")
        print(f"    Expectation:  {E:.4f}")
        print(f"    Upper bound:  {upper:.4f}")
        print(f"    Actual primes: {actual}")
        assert lower <= E + 1e-10, "Lower bound violated!"
        assert E <= upper + 1e-10, "Upper bound violated!"
    print()


def demo_cramer_conjecture():
    """Demonstrate Cramér's conjecture numerically."""
    print("=" * 60)
    print("CRAMÉR'S CONJECTURE: Normalized gaps g(n)/(log n)²")
    print("=" * 60)
    primes = sieve_of_eratosthenes(10_000_000)
    max_normalized = 0.0
    max_gap = 0
    max_gap_prime = 0

    for i in range(len(primes) - 1):
        p = primes[i]
        gap = primes[i + 1] - p
        if p >= 3:
            log_p = math.log(p)
            normalized = gap / (log_p ** 2)
            if normalized > max_normalized:
                max_normalized = normalized
                max_gap = gap
                max_gap_prime = p

    print(f"  Primes tested: up to {primes[-1]:,}")
    print(f"  Largest normalized gap: {max_normalized:.6f}")
    print(f"    at prime p = {max_gap_prime:,}, gap = {max_gap}")
    print(f"    (log p)² = {math.log(max_gap_prime)**2:.2f}")
    print()

    # Show normalized gaps in dyadic ranges
    print("  Dyadic range analysis:")
    for k in range(10, 24):
        lo, hi = 2**k, 2**(k + 1)
        range_primes = [p for p in primes if lo <= p <= hi]
        if len(range_primes) < 2:
            continue
        gaps = [range_primes[i + 1] - range_primes[i]
                for i in range(len(range_primes) - 1)]
        max_g = max(gaps)
        log_lo = math.log(lo)
        normalized_max = max_g / (log_lo ** 2)
        print(f"    [2^{k}, 2^{k+1}]: max gap = {max_g:>4d}, "
              f"max g/(log n)² = {normalized_max:.4f}")
    print()


def demo_transfer_principle():
    """Demonstrate the transfer principle with different F(n)."""
    print("=" * 60)
    print("TRANSFER PRINCIPLE: gap ≤ F(n) from interval-prime theorems")
    print("=" * 60)
    test_n = [100, 1000, 10000, 100000, 1000000]

    print(f"  {'n':>10s} | {'gap':>5s} | {'F=n':>10s} | "
          f"{'F=n^0.525':>10s} | {'F=C(ln n)²':>10s}")
    print("  " + "-" * 60)

    for n in test_n:
        gap = prime_gap_after(n)
        bertrand = n
        bhp = int(n ** 0.525) + 1
        cramer = int(2 * math.log(n) ** 2) + 1
        print(f"  {n:>10d} | {gap:>5d} | {bertrand:>10d} | "
              f"{bhp:>10d} | {cramer:>10d}")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  CERTIFIED PRIME GAP THEORY — NUMERICAL DEMONSTRATIONS")
    print("=" * 60 + "\n")

    demo_theorem_a()
    demo_theorem_b()
    demo_theorem_c()
    demo_theorem_f()
    demo_cramer_conjecture()
    demo_transfer_principle()

    print("All demonstrations completed successfully!")
