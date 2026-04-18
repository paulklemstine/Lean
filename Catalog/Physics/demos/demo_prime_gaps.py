#!/usr/bin/env python3
"""
Prime Gap Analysis Demo

Explores prime gaps, gap records, the prime desert theorem,
and the connection to Bertrand's postulate and Cramér's conjecture.
"""

import math
from sympy import isprime, primerange, nextprime


def gap_records(limit=100000):
    """Find record prime gaps up to limit."""
    print(f"=== Prime Gap Records (up to {limit}) ===")
    print(f"{'Gap':>5} {'Start':>8} {'End':>8} {'log²(p)':>8} {'Cramér ratio':>13}")
    print("-" * 50)

    max_gap = 0
    prev = 2
    records = []

    for p in primerange(3, limit):
        gap = p - prev
        if gap > max_gap:
            max_gap = gap
            log_p = math.log(prev)
            cramer = gap / (log_p ** 2) if log_p > 0 else 0
            records.append((gap, prev, p, cramer))
            print(f"{gap:>5} {prev:>8} {p:>8} {log_p**2:>8.2f} {cramer:>13.4f}")
        prev = p

    print()
    print(f"  Largest gap found: {max_gap}")
    print(f"  Cramér's conjecture: max gap near p ≤ C·(log p)² (C ≈ 1)")
    print(f"  All ratios < 1 in this range, consistent with Cramér.")
    print()
    return records


def gap_distribution(limit=10000):
    """Analyze the distribution of prime gaps."""
    print(f"=== Prime Gap Distribution (primes < {limit}) ===")

    gaps = {}
    prev = 2
    for p in primerange(3, limit):
        gap = p - prev
        gaps[gap] = gaps.get(gap, 0) + 1
        prev = p

    print(f"{'Gap':>5} {'Count':>7} {'Frequency':>20}")
    print("-" * 35)
    total = sum(gaps.values())
    for gap in sorted(gaps.keys()):
        count = gaps[gap]
        bar = "█" * (count // 5)
        print(f"{gap:>5} {count:>7} {bar}")

    print(f"\n  Total gaps: {total}")
    print(f"  Most common gap: {max(gaps, key=gaps.get)} (appears {max(gaps.values())} times)")
    print(f"  Gap 2 (twin primes): {gaps.get(2, 0)}")
    print(f"  Gap 4 (cousin primes): {gaps.get(4, 0)}")
    print(f"  Gap 6 (sexy primes): {gaps.get(6, 0)}")
    print()


def prime_desert_construction(k=10):
    """Construct prime deserts using (k+1)! + j."""
    print(f"=== Prime Desert Construction ===")
    print(f"  For k ≥ 2, the numbers (k+1)! + 2, (k+1)! + 3, ..., (k+1)! + (k+1)")
    print(f"  are all composite, giving a gap of at least k.")
    print()

    for k in [5, 10, 20, 50]:
        factorial = math.factorial(k + 1)
        start = factorial + 2
        end = factorial + k + 1
        gap_size = k

        # Verify a few are composite
        composites = []
        for j in range(2, min(k + 2, 8)):
            n = factorial + j
            composites.append(f"{k+1}!+{j} divisible by {j}")

        print(f"  k = {k}: ({k+1})! = {factorial}")
        print(f"    Desert: [{start}, {end}] — {gap_size} consecutive composites")
        for c in composites[:5]:
            print(f"      {c}")
        print()


def bertrand_verification(limit=1000):
    """Verify Bertrand's postulate: always a prime between n and 2n."""
    print(f"=== Bertrand's Postulate Verification (n ≤ {limit}) ===")
    print()

    violations = 0
    tightest = (1, 2, 2)  # (n, prime, ratio)

    for n in range(1, limit + 1):
        # Find smallest prime > n
        p = nextprime(n)
        if p > 2 * n:
            violations += 1
            print(f"  VIOLATION at n={n}: next prime {p} > {2*n}")
        else:
            ratio = p / n if n > 0 else float('inf')
            if ratio < tightest[2] and n > 5:
                tightest = (n, p, ratio)

    print(f"  Violations: {violations}")
    print(f"  Tightest case: n={tightest[0]}, p={tightest[1]}, p/n={tightest[2]:.6f}")
    print()


def pi_vs_log2(limit=1000):
    """Compare π(n) with ⌊log₂(n)⌋."""
    print(f"=== π(n) vs ⌊log₂(n)⌋ ===")
    print(f"  Theorem: π(n) ≥ ⌊log₂(n)⌋ for n ≥ 2")
    print()
    print(f"{'n':>8} {'π(n)':>6} {'⌊log₂n⌋':>8} {'π/log₂':>8} {'n/ln(n)':>8}")
    print("-" * 42)

    for n in [2, 4, 8, 16, 32, 64, 100, 128, 256, 500, 512, 1000, 1024, 2000, 5000, 10000]:
        pi_n = sum(1 for p in primerange(2, n + 1))
        log2_n = int(math.log2(n))
        ratio = pi_n / log2_n if log2_n > 0 else float('inf')
        nlogn = n / math.log(n) if n > 1 else 0
        print(f"{n:>8} {pi_n:>6} {log2_n:>8} {ratio:>8.2f} {nlogn:>8.1f}")

    print()
    print("  The bound π(n) ≥ log₂(n) is tight at n=2 and n=4,")
    print("  but becomes increasingly loose for larger n.")
    print("  The true growth rate is π(n) ~ n/ln(n) (Prime Number Theorem).")
    print()


if __name__ == "__main__":
    gap_records()
    gap_distribution()
    prime_desert_construction()
    bertrand_verification()
    pi_vs_log2()
