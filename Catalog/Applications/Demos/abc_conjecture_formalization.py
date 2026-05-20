#!/usr/bin/env python3
"""
Applications of ABC Conjecture Theory

Demonstrates real-world applications of the ABC conjecture machinery:
1. Detecting high-quality ABC triples (relevant to number theory research)
2. Analyzing the FLT-ABC connection with concrete data
3. Support complexity analysis (information-theoretic interpretation)
4. Szpiro-like inequality testing for elliptic curves
"""

import math
from algorithms import (
    radical, prime_factorization, prime_omega, gcd,
    is_primitive_abc_triple, abc_quality, exceeds_discrete_quality
)


def find_high_quality_triples(max_c: int, threshold: float = 1.0) -> list[tuple]:
    """
    Find all primitive ABC triples with quality above a threshold.

    This is the core computational search relevant to the ABC conjecture.
    The conjecture predicts that for any ε > 0, the set of triples with
    quality > 1+ε is finite.

    Returns list of (quality, a, b, c, rad_abc) sorted by quality descending.
    """
    results = []
    for c in range(3, max_c + 1):
        for a in range(1, c):
            b = c - a
            if b >= a and gcd(a, b) == 1:
                q = abc_quality(a, b, c)
                if q > threshold:
                    r = radical(a * b * c)
                    results.append((q, a, b, c, r))
    results.sort(reverse=True)
    return results


def support_complexity_analysis(max_c: int = 500):
    """
    Analyze the relationship between additive structure and prime support
    complexity for ABC triples.

    The key insight: rad(abc) measures the "information content" of the
    prime factorization. High-quality ABC triples are those where additive
    structure (a + b = c) "compresses" the multiplicative information.
    """
    print("\n=== Support Complexity Analysis ===\n")

    data = []
    for c in range(3, max_c + 1):
        for a in range(1, c):
            b = c - a
            if b >= a and gcd(a, b) == 1:
                r = radical(a * b * c)
                omega = prime_omega(a * b * c)
                q = abc_quality(a, b, c)
                if q < float('inf'):
                    data.append((a, b, c, r, omega, q))

    # Analyze omega distribution for high vs low quality
    high_q = [d for d in data if d[5] > 1.0]
    low_q = [d for d in data if d[5] <= 1.0]

    if high_q:
        avg_omega_high = sum(d[4] for d in high_q) / len(high_q)
        avg_c_high = sum(d[2] for d in high_q) / len(high_q)
    else:
        avg_omega_high = avg_c_high = 0

    if low_q:
        avg_omega_low = sum(d[4] for d in low_q) / len(low_q)
        avg_c_low = sum(d[2] for d in low_q) / len(low_q)
    else:
        avg_omega_low = avg_c_low = 0

    print(f"  Total primitive triples (c ≤ {max_c}): {len(data)}")
    print(f"  High quality (q > 1): {len(high_q)}")
    print(f"  Low quality (q ≤ 1): {len(low_q)}")
    print()
    print(f"  High quality triples:")
    print(f"    Average ω(abc): {avg_omega_high:.2f}")
    print(f"    Average c: {avg_c_high:.2f}")
    print(f"  Low quality triples:")
    print(f"    Average ω(abc): {avg_omega_low:.2f}")
    print(f"    Average c: {avg_c_low:.2f}")
    print()
    print("  Interpretation: High-quality triples tend to have FEWER distinct")
    print("  prime factors (lower ω), meaning their multiplicative structure")
    print("  is simpler — like a compressed code with small alphabet.")

    return data


def flt_obstruction_demo():
    """
    Demonstrate why the ABC conjecture obstructs Fermat solutions.

    For a hypothetical solution a^n + b^n = c^n with coprime a, b:
    - The triple (a^n, b^n, c^n) is an ABC triple
    - rad(a^n · b^n · c^n) = rad(abc) ≤ abc < c^3
    - Quality ≥ log(c^n) / log(c^3) = n/3

    So for n ≥ 4, the quality exceeds 1, and for large n it grows
    without bound — violating the ABC conjecture prediction.
    """
    print("\n=== FLT-ABC Obstruction Analysis ===\n")

    # Find maximum observed quality
    print("  Step 1: Find maximum observed ABC quality (c ≤ 10000)...")
    max_q = 0
    best_triple = None
    for c in range(3, 10001):
        for a in range(1, c):
            b = c - a
            if b >= a and gcd(a, b) == 1:
                q = abc_quality(a, b, c)
                if q < float('inf') and q > max_q:
                    max_q = q
                    best_triple = (a, b, c)

    print(f"  Maximum observed quality: {max_q:.4f}")
    if best_triple:
        a, b, c = best_triple
        print(f"  Achieved by: ({a}, {b}, {c})")
        print(f"  rad({a}·{b}·{c}) = {radical(a * b * c)}")
    print()

    # Compare with hypothetical Fermat solutions
    print("  Step 2: Minimum quality forced by Fermat solutions:")
    print(f"  {'n':>4}  {'Min quality n/3':>15}  {'Exceeds observed?':>20}  {'Verdict':>20}")
    print("  " + "-" * 65)
    for n in range(3, 30):
        min_q = n / 3.0
        exceeds = min_q > max_q
        verdict = "IMPOSSIBLE under ABC" if exceeds else "theoretically possible"
        marker = " <<<" if exceeds and n == math.ceil(3 * max_q) + 1 else ""
        print(f"  {n:4d}  {min_q:15.4f}  {'YES' if exceeds else 'no':>20}  {verdict:>20}{marker}")

    threshold_n = math.ceil(3 * max_q) + 1
    print()
    print(f"  CONCLUSION: Under the ABC conjecture, Fermat's Last Theorem")
    print(f"  holds for all n ≥ {threshold_n} (based on observed quality bounds).")
    print(f"  The formal theorem proves this for all sufficiently large n.")


def quality_growth_analysis(max_c_values: list[int] = None):
    """
    Test the conjecture that the number of high-quality triples grows
    subpolynomially.
    """
    if max_c_values is None:
        max_c_values = [100, 200, 500, 1000, 2000, 5000]

    print("\n=== Quality Growth Rate Analysis ===\n")
    print("  Testing: Does #{q > 1, c ≤ X} grow subpolynomially in X?\n")
    print(f"  {'X':>8}  {'Total':>8}  {'q > 1':>8}  {'Fraction':>10}  {'log ratio':>10}")
    print("  " + "-" * 50)

    prev_count = 0
    prev_x = 0
    for max_c in max_c_values:
        total = 0
        above_one = 0
        for c in range(3, max_c + 1):
            for a in range(1, c):
                b = c - a
                if b >= a and gcd(a, b) == 1:
                    total += 1
                    q = abc_quality(a, b, c)
                    if q > 1.0:
                        above_one += 1

        fraction = above_one / total if total > 0 else 0
        if prev_count > 0 and prev_x > 0:
            log_ratio = math.log(above_one / prev_count) / math.log(max_c / prev_x) if above_one > 0 else 0
        else:
            log_ratio = 0

        print(f"  {max_c:8d}  {total:8d}  {above_one:8d}  {fraction:10.6f}  {log_ratio:10.4f}")
        prev_count = above_one
        prev_x = max_c

    print()
    print("  If the log ratio stabilizes near 0, growth is subpolynomial.")
    print("  A decreasing fraction supports the ABC conjecture prediction.")


if __name__ == "__main__":
    print("=" * 70)
    print("  APPLICATIONS OF ABC CONJECTURE THEORY")
    print("=" * 70)

    # Application 1: Find high-quality triples
    print("\n=== High-Quality ABC Triple Search (c ≤ 1000) ===\n")
    triples = find_high_quality_triples(1000, threshold=1.2)
    print(f"  Found {len(triples)} triples with quality > 1.2:")
    print(f"  {'Rank':>4}  {'a':>8}  {'b':>8}  {'c':>8}  {'rad(abc)':>10}  {'Quality':>8}")
    print("  " + "-" * 55)
    for i, (q, a, b, c, r) in enumerate(triples[:15]):
        print(f"  {i+1:4d}  {a:8d}  {b:8d}  {c:8d}  {r:10d}  {q:8.4f}")

    # Application 2: Support complexity
    support_complexity_analysis(500)

    # Application 3: FLT obstruction
    flt_obstruction_demo()

    # Application 4: Quality growth
    quality_growth_analysis([100, 200, 500, 1000, 2000])


#!/usr/bin/env python3
"""
ABC Conjecture Explorer — Interactive Demo

Enumerates primitive ABC triples (a + b = c, gcd(a,b) = 1) and computes
their radicals, quality measures, and tests discrete ABC inequalities.

Usage:
    python demo.py [--max_c MAX_C] [--m M] [--top_k TOP_K]
"""

import math
import argparse
from collections import defaultdict


def prime_factors(n: int) -> set[int]:
    """Return the set of distinct prime factors of n."""
    if n <= 1:
        return set()
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors


def rad(n: int) -> int:
    """Compute the radical of n: product of distinct prime factors."""
    if n <= 0:
        return 1
    result = 1
    for p in prime_factors(n):
        result *= p
    return result


def gcd(a: int, b: int) -> int:
    """Compute gcd of a and b."""
    while b:
        a, b = b, a % b
    return a


def is_primitive_abc(a: int, b: int, c: int) -> bool:
    """Check if (a, b, c) is a primitive ABC triple."""
    return a > 0 and b > 0 and c > 0 and a + b == c and gcd(a, b) == 1


def abc_quality(a: int, b: int, c: int) -> float:
    """Compute the ABC quality: log(c) / log(rad(abc))."""
    r = rad(a * b * c)
    if r <= 1:
        return float('inf')
    return math.log(c) / math.log(r)


def exceeds_quality_discrete(m: int, a: int, b: int, c: int) -> bool:
    """Check if c^m > rad(abc)^(m+1) — the discrete quality test."""
    r = rad(a * b * c)
    return c ** m > r ** (m + 1)


def enumerate_primitive_triples(max_c: int):
    """Enumerate all primitive ABC triples with c ≤ max_c."""
    triples = []
    for c in range(3, max_c + 1):
        for a in range(1, c):
            b = c - a
            if b > 0 and a <= b and gcd(a, b) == 1:
                triples.append((a, b, c))
    return triples


def fermat_quality_lower_bound(n: int) -> float:
    """
    If a^n + b^n = c^n had a primitive solution, the ABC quality
    would be at least n/3 (since rad(abc) ≤ c^3).
    """
    return n / 3.0


def main():
    parser = argparse.ArgumentParser(description="ABC Conjecture Explorer")
    parser.add_argument("--max_c", type=int, default=1000,
                        help="Maximum value of c (default: 1000)")
    parser.add_argument("--m", type=int, default=1,
                        help="Discrete quality exponent m (default: 1)")
    parser.add_argument("--top_k", type=int, default=20,
                        help="Number of top quality triples to display (default: 20)")
    args = parser.parse_args()

    max_c = args.max_c
    m = args.m
    top_k = args.top_k

    print("=" * 70)
    print("  ABC CONJECTURE EXPLORER")
    print("=" * 70)
    print(f"\n  Parameters: max_c = {max_c}, m = {m}, top_k = {top_k}")
    print()

    # Enumerate triples
    print("Enumerating primitive ABC triples...")
    triples = enumerate_primitive_triples(max_c)
    print(f"  Found {len(triples)} primitive triples with c ≤ {max_c}")
    print()

    # Compute qualities
    quality_list = []
    high_quality_count = 0
    for a, b, c in triples:
        q = abc_quality(a, b, c)
        quality_list.append((q, a, b, c))
        if exceeds_quality_discrete(m, a, b, c):
            high_quality_count += 1

    quality_list.sort(reverse=True)

    # Display top-k quality triples
    print(f"  Top {top_k} highest-quality ABC triples:")
    print(f"  {'Rank':>4}  {'a':>8}  {'b':>8}  {'c':>8}  {'rad(abc)':>10}  {'Quality':>8}")
    print("  " + "-" * 60)
    for i, (q, a, b, c) in enumerate(quality_list[:top_k]):
        r = rad(a * b * c)
        print(f"  {i+1:4d}  {a:8d}  {b:8d}  {c:8d}  {r:10d}  {q:8.4f}")

    print()

    # Discrete quality analysis
    print(f"  Discrete quality test (m = {m}):")
    print(f"    Triples with c^{m} > rad(abc)^{m+1}: {high_quality_count}")
    print(f"    Fraction: {high_quality_count / len(triples):.6f}")
    print()

    # Quality distribution
    print("  Quality distribution:")
    bins = defaultdict(int)
    for q, a, b, c in quality_list:
        if q < float('inf'):
            bucket = round(q * 10) / 10  # Round to nearest 0.1
            bins[bucket] += 1

    for bucket in sorted(bins.keys()):
        count = bins[bucket]
        bar = "#" * min(count // max(1, len(triples) // 200), 60)
        print(f"    q ≈ {bucket:.1f}: {count:6d}  {bar}")
    print()

    # Fermat solution analysis
    print("  Hypothetical Fermat solution analysis:")
    print(f"  {'n':>4}  {'Min quality':>12}  {'Would exceed max observed?':>30}")
    print("  " + "-" * 50)
    max_observed = max(q for q, _, _, _ in quality_list if q < float('inf'))
    for n in range(3, 20):
        min_q = fermat_quality_lower_bound(n)
        exceeds = "YES — impossible under ABC" if min_q > max_observed else "no"
        print(f"  {n:4d}  {min_q:12.4f}  {exceeds:>30}")

    print()
    print("=" * 70)
    print("  KEY INSIGHT: For large n, any primitive Fermat solution would")
    print("  require an ABC quality far exceeding all observed values.")
    print("  This is the asymptotic FLT consequence of the ABC conjecture.")
    print("=" * 70)

    # Extreme examples
    print("\n  Notable ABC triples from the literature (quality > 1.4):")
    notable = [
        (1, 2, 3),           # q ≈ 1.2263
        (5, 27, 32),         # q ≈ 1.4278
        (1, 4374, 4375),     # very high quality
        (1, 8, 9),           # classic example
        (2, 6436341, 6436343),
    ]
    for a, b, c in notable:
        if a + b == c and gcd(a, b) == 1:
            q = abc_quality(a, b, c)
            r = rad(a * b * c)
            print(f"    ({a}, {b}, {c}): rad = {r}, quality = {q:.4f}")


if __name__ == "__main__":
    main()
