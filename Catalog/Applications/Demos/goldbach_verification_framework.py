#!/usr/bin/env python3
"""
Applications of the Additive Prime Decomposition Framework.

Demonstrates real-world applications:
1. Scalable certificate-based verification
2. Goldbach graph analysis and visualization
3. Representation density and Hardy-Littlewood prediction
4. Least witness prime distribution
5. Ternary Goldbach (odd integers as sums of three primes)
"""

import math
import collections
from algorithms import (
    sieve_of_eratosthenes,
    find_goldbach_pair,
    find_all_goldbach_pairs,
    AdditiveBasisCertificate,
    goldbach_representation_count,
    least_goldbach_prime,
    goldbach_graph_edges,
)


def application_1_scalable_verification():
    """Application 1: Scalable certificate-based Goldbach verification.

    Demonstrates the monotone extension architecture:
    verify in blocks, compose certificates, achieve large ranges efficiently.
    """
    print("=" * 70)
    print("APPLICATION 1: Scalable Certificate-Based Verification")
    print("=" * 70)
    print()

    block_size = 1000
    total = 10000

    # Build incrementally
    cert = AdditiveBasisCertificate.generate(block_size)
    print(f"  Block 1: GoldbachUpTo({block_size}) — {len(cert.witnesses)} witnesses")

    for start in range(block_size, total, block_size):
        end = start + block_size
        cert = cert.extend(end)
        print(f"  Block {start // block_size + 1}: "
              f"GoldbachUpTo({end}) — {len(cert.witnesses)} total witnesses")

    assert cert.validate()
    print(f"\n  ✓ GoldbachUpTo({total}) verified with {len(cert.witnesses)} certificates")
    print(f"  Certificate compression: {len(cert.witnesses)} entries for "
          f"{total // 2 - 1} even numbers = {len(cert.witnesses) / (total // 2 - 1):.2%} overhead")


def application_2_goldbach_graph_analysis():
    """Application 2: Goldbach graph structural analysis.

    Analyzes the graph where primes are vertices and edges connect pairs
    summing to even numbers. Studies coverage, connectivity, and multiplicity.
    """
    print()
    print("=" * 70)
    print("APPLICATION 2: Goldbach Graph Analysis")
    print("=" * 70)
    print()

    for N in [100, 500, 1000, 5000]:
        sieve = sieve_of_eratosthenes(N)
        primes = [p for p in range(2, N + 1) if sieve[p]]
        edges = goldbach_graph_edges(N)

        # Coverage analysis
        covered_sums = set(s for _, _, s in edges)
        evens = set(range(4, N + 1, 2))
        coverage = len(covered_sums & evens) / len(evens) * 100

        # Multiplicity distribution
        mult = collections.Counter(s for _, _, s in edges)
        avg_mult = sum(mult[n] for n in evens) / len(evens)

        print(f"  N = {N:5d}: {len(primes):4d} primes, {len(edges):6d} edges, "
              f"coverage = {coverage:.1f}%, avg multiplicity = {avg_mult:.1f}")


def application_3_hardy_littlewood_prediction():
    """Application 3: Hardy-Littlewood conjecture comparison.

    The Hardy-Littlewood conjecture predicts the asymptotic density of
    Goldbach representations. We compare actual counts with the prediction:

    r(n) ≈ 2 C₂ · n / (ln n)² · ∏_{p|n, p>2} (p-1)/(p-2)

    where C₂ = ∏_{p>2} (1 - 1/(p-1)²) ≈ 0.6601...  (twin prime constant)
    """
    print()
    print("=" * 70)
    print("APPLICATION 3: Hardy-Littlewood Prediction vs. Actual Counts")
    print("=" * 70)
    print()

    N = 5000
    sieve = sieve_of_eratosthenes(N)

    # Compute twin prime constant C₂
    C2 = 1.0
    for p in range(3, 200):
        if sieve[p]:
            C2 *= (1 - 1 / (p - 1) ** 2)

    print(f"  Twin prime constant C₂ ≈ {C2:.6f}")
    print()
    print(f"  {'n':>6s}  {'Actual':>8s}  {'HL Pred':>8s}  {'Ratio':>8s}")
    print(f"  {'-'*6}  {'-'*8}  {'-'*8}  {'-'*8}")

    for n in [100, 200, 500, 1000, 2000, 3000, 4000, 5000]:
        if n % 2 != 0 or n < 4:
            continue
        actual = goldbach_representation_count(n, sieve)
        if n > 2:
            ln_n = math.log(n)
            # Singular series factor
            singular = 1.0
            for p in range(3, n):
                if p < len(sieve) and sieve[p] and n % p == 0:
                    singular *= (p - 1) / (p - 2)
            prediction = 2 * C2 * singular * n / (ln_n ** 2)
        else:
            prediction = 0

        ratio = actual / prediction if prediction > 0 else float('inf')
        print(f"  {n:6d}  {actual:8d}  {prediction:8.1f}  {ratio:8.3f}")


def application_4_least_witness_distribution():
    """Application 4: Distribution of the least Goldbach witness prime.

    Studies the distribution of the smallest prime p such that n - p is prime.
    Tests the conjecture that p = O((log n)²).
    """
    print()
    print("=" * 70)
    print("APPLICATION 4: Least Witness Prime Distribution")
    print("=" * 70)
    print()

    N = 50000
    sieve = sieve_of_eratosthenes(N)

    # Collect least primes
    least_primes = []
    max_ratio = 0
    max_ratio_n = 0

    for n in range(4, N + 1, 2):
        lp = least_goldbach_prime(n, sieve)
        if lp is not None:
            least_primes.append((n, lp))
            if n > 10:
                ratio = lp / (math.log(n) ** 2)
                if ratio > max_ratio:
                    max_ratio = ratio
                    max_ratio_n = n

    # Distribution statistics
    lp_values = [lp for _, lp in least_primes]
    print(f"  Range: [4, {N}]")
    print(f"  Total even numbers checked: {len(least_primes)}")
    print(f"  Least prime = 2: {sum(1 for lp in lp_values if lp == 2)} times")
    print(f"  Least prime = 3: {sum(1 for lp in lp_values if lp == 3)} times")
    print(f"  Least prime = 5: {sum(1 for lp in lp_values if lp == 5)} times")
    print(f"  Least prime = 7: {sum(1 for lp in lp_values if lp == 7)} times")
    print(f"  Maximum least prime: {max(lp_values)}")
    print(f"  Average least prime: {sum(lp_values) / len(lp_values):.2f}")
    print(f"  Max p/(log n)²: {max_ratio:.4f} at n = {max_ratio_n}")

    # Histogram
    buckets = collections.Counter()
    for lp in lp_values:
        if lp <= 10:
            buckets[lp] += 1
        elif lp <= 50:
            buckets["11-50"] += 1
        elif lp <= 100:
            buckets["51-100"] += 1
        else:
            buckets[">100"] += 1

    print(f"\n  Distribution histogram:")
    for key in sorted(k for k in buckets if isinstance(k, int)):
        pct = buckets[key] / len(lp_values) * 100
        bar = "█" * int(pct)
        print(f"    p = {key:>3}: {buckets[key]:6d} ({pct:5.1f}%) {bar}")
    for key in ["11-50", "51-100", ">100"]:
        if key in buckets:
            pct = buckets[key] / len(lp_values) * 100
            bar = "█" * int(pct)
            print(f"    p ∈ {key:>5}: {buckets[key]:6d} ({pct:5.1f}%) {bar}")


def application_5_ternary_goldbach():
    """Application 5: Ternary Goldbach decomposition.

    Every odd number > 5 can be written as 3 + (even number),
    and if binary Goldbach holds for the even part, we get a three-prime sum.
    """
    print()
    print("=" * 70)
    print("APPLICATION 5: Ternary Goldbach via Binary Transfer")
    print("=" * 70)
    print()

    N = 1000
    sieve = sieve_of_eratosthenes(N)

    successes = 0
    failures = 0

    for n in range(7, N + 1, 2):
        # n = 3 + (n - 3), where n - 3 is even and ≥ 4
        m = n - 3
        pair = find_goldbach_pair(m, sieve)
        if pair:
            successes += 1
        else:
            failures += 1
            print(f"  FAILURE: {n} cannot be decomposed via 3 + binary Goldbach")

    print(f"  Tested odd numbers in [7, {N}]: {successes + failures}")
    print(f"  Successfully decomposed: {successes}")
    print(f"  Failures: {failures}")

    if failures == 0:
        print(f"  ✓ Every odd number in [7, {N}] is a sum of three primes!")

    # Show some examples with multiple decompositions
    print(f"\n  Examples of ternary decompositions:")
    for n in [7, 11, 21, 101, 501, 999]:
        if n % 2 == 0:
            continue
        decomps = []
        for a in range(2, n):
            if a < len(sieve) and sieve[a]:
                rem = n - a
                if rem >= 4 and rem % 2 == 0:
                    pair = find_goldbach_pair(rem, sieve)
                    if pair:
                        decomps.append((a, pair[0], pair[1]))
                        if len(decomps) >= 3:
                            break
        print(f"    {n} = " + " = ".join(
            f"{a}+{b}+{c}" for a, b, c in decomps))


def main():
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║   ADDITIVE PRIME DECOMPOSITION FRAMEWORK — APPLICATIONS        ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    application_1_scalable_verification()
    application_2_goldbach_graph_analysis()
    application_3_hardy_littlewood_prediction()
    application_4_least_witness_distribution()
    application_5_ternary_goldbach()

    print()
    print("=" * 70)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Goldbach Verification Framework — Interactive Demo

Demonstrates:
1. Verified Goldbach pair search
2. Certificate generation and validation
3. Goldbach graph coverage visualization
4. Parity obstruction illustration
5. Least Goldbach prime statistics
"""

import math
import collections
from typing import Optional


def is_prime(n: int) -> bool:
    """Primality test."""
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


def find_goldbach_pair(n: int) -> Optional[tuple[int, int]]:
    """Find a Goldbach pair (p, q) with p + q = n, searching from p = 2 upward.

    This mirrors the verified Lean algorithm `findGoldbachPair`.
    Returns None if no pair is found (which would disprove Goldbach for n).
    """
    if n < 4:
        return None
    for p in range(2, n):
        if is_prime(p) and is_prime(n - p):
            return (p, n - p)
    return None


def find_all_goldbach_pairs(n: int) -> list[tuple[int, int]]:
    """Find all ordered pairs (p, q) of primes with p + q = n."""
    pairs = []
    for p in range(2, n):
        q = n - p
        if q >= 2 and is_prime(p) and is_prime(q):
            pairs.append((p, q))
    return pairs


def generate_certificate(N: int) -> dict[int, tuple[int, int]]:
    """Generate an AdditiveBasisCertificate for GoldbachUpTo(N).

    Returns a dictionary mapping each even n in [4, N] to a witness pair (p, q).
    This corresponds to the `witness` field of AdditiveBasisCertificate in Lean.
    """
    cert = {}
    for n in range(4, N + 1, 2):
        pair = find_goldbach_pair(n)
        if pair is not None:
            cert[n] = pair
        else:
            print(f"WARNING: No Goldbach pair found for {n}!")
    return cert


def validate_certificate(cert: dict[int, tuple[int, int]], N: int) -> bool:
    """Validate a certificate — mirrors certificate_implies_GoldbachUpTo.

    Checks:
    1. Coverage: every even n in [4, N] has a witness
    2. Sound_prime_left: left component is prime
    3. Sound_prime_right: right component is prime
    4. Sound_sum: components sum to n
    """
    for n in range(4, N + 1, 2):
        if n not in cert:
            print(f"FAIL: No witness for n = {n}")
            return False
        p, q = cert[n]
        if not is_prime(p):
            print(f"FAIL: Left component {p} is not prime for n = {n}")
            return False
        if not is_prime(q):
            print(f"FAIL: Right component {q} is not prime for n = {n}")
            return False
        if p + q != n:
            print(f"FAIL: {p} + {q} != {n}")
            return False
    return True


def goldbach_graph_coverage(N: int) -> dict:
    """Compute Goldbach graph coverage statistics.

    The Goldbach graph has primes ≤ N as vertices.
    An edge (p, q) covers the even number p + q.
    """
    primes = [p for p in range(2, N + 1) if is_prime(p)]
    covered = set()
    edge_count = 0
    multiplicity = collections.Counter()

    for i, p in enumerate(primes):
        for q in primes[i:]:
            s = p + q
            if s <= N:
                covered.add(s)
                edge_count += 1
                multiplicity[s] += 1

    evens_in_range = set(range(4, N + 1, 2))
    uncovered = evens_in_range - covered

    return {
        "num_primes": len(primes),
        "num_edges": edge_count,
        "num_covered": len(covered & evens_in_range),
        "num_evens": len(evens_in_range),
        "uncovered": sorted(uncovered),
        "avg_multiplicity": (
            sum(multiplicity[n] for n in evens_in_range) / len(evens_in_range)
            if evens_in_range else 0
        ),
        "max_multiplicity": (
            max((multiplicity[n] for n in evens_in_range), default=0)
        ),
    }


def parity_obstruction_demo():
    """Demonstrate the parity obstruction theorem.

    Shows that for odd n, any two-prime representation must include 2.
    """
    print("=" * 60)
    print("PARITY OBSTRUCTION DEMO")
    print("=" * 60)
    print()
    print("Theorem: If odd n = p + q with p, q prime, then p = 2 or q = 2.")
    print()

    for n in [5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31]:
        if n % 2 == 0:
            continue
        pairs = find_all_goldbach_pairs(n)
        if pairs:
            has_two = all(p == 2 or q == 2 for p, q in pairs)
            print(f"  n = {n:3d}: pairs = {pairs[:5]}{'...' if len(pairs) > 5 else ''}"
                  f"  — all include 2: {has_two}")
        else:
            print(f"  n = {n:3d}: no prime pair representation")

    print()
    print("For even numbers, both primes can be odd (when n > 4):")
    for n in [6, 8, 10, 12, 14, 20, 30]:
        pairs = find_all_goldbach_pairs(n)
        odd_pairs = [(p, q) for p, q in pairs if p != 2 and q != 2]
        print(f"  n = {n:3d}: {len(pairs)} total pairs, {len(odd_pairs)} odd-odd pairs")


def least_goldbach_prime_stats(N: int):
    """Compute statistics on the least Goldbach prime.

    Tests the conjecture: for all even n in [4, N],
    the least prime p such that n - p is prime is O((log n)^2).
    """
    print()
    print("=" * 60)
    print(f"LEAST GOLDBACH PRIME STATISTICS (up to {N})")
    print("=" * 60)
    print()

    max_p = 0
    max_n = 0
    max_ratio = 0.0
    violations_1000 = []

    for n in range(4, N + 1, 2):
        pair = find_goldbach_pair(n)
        if pair is None:
            print(f"  GOLDBACH VIOLATION at n = {n}!")
            continue
        p = pair[0]
        if p > max_p:
            max_p = p
            max_n = n
        log_n = math.log(n) if n > 1 else 1
        ratio = p / (log_n ** 2)
        if ratio > max_ratio:
            max_ratio = ratio
        if p > 1000:
            violations_1000.append((n, p))

    print(f"  Maximum least prime: p = {max_p} at n = {max_n}")
    print(f"  Maximum p / (log n)^2 ratio: {max_ratio:.4f}")
    print(f"  Violations of p ≤ 1000: {len(violations_1000)}")
    if violations_1000:
        print(f"  First violations: {violations_1000[:5]}")
    else:
        print(f"  Conjecture 'least p ≤ 1000 for n ≤ {N}' HOLDS")


def monotone_extension_demo():
    """Demonstrate the monotone extension theorem.

    Shows how GoldbachUpTo(N) + new witnesses → GoldbachUpTo(M).
    """
    print()
    print("=" * 60)
    print("MONOTONE EXTENSION DEMO")
    print("=" * 60)
    print()

    # Stage 1: verify up to 100
    cert1 = generate_certificate(100)
    valid1 = validate_certificate(cert1, 100)
    print(f"  Stage 1: GoldbachUpTo(100) — certificate valid: {valid1}")

    # Stage 2: extend to 200
    cert_ext = {}
    for n in range(102, 201, 2):
        pair = find_goldbach_pair(n)
        if pair:
            cert_ext[n] = pair
    valid_ext = all(
        n in cert_ext and is_prime(cert_ext[n][0]) and is_prime(cert_ext[n][1])
        and cert_ext[n][0] + cert_ext[n][1] == n
        for n in range(102, 201, 2)
    )
    print(f"  Stage 2: Extension witnesses (100, 200] — valid: {valid_ext}")

    # Combine
    cert_combined = {**cert1, **cert_ext}
    valid_combined = validate_certificate(cert_combined, 200)
    print(f"  Combined: GoldbachUpTo(200) — certificate valid: {valid_combined}")
    print()
    print("  This demonstrates GoldbachUpTo.extend:")
    print("    GoldbachUpTo(100) + witnesses for (100,200] → GoldbachUpTo(200)")


def ternary_goldbach_demo():
    """Demonstrate binary → ternary Goldbach transfer."""
    print()
    print("=" * 60)
    print("BINARY → TERNARY GOLDBACH TRANSFER")
    print("=" * 60)
    print()
    print("Theorem: If binary Goldbach holds for all even n ≥ 4,")
    print("         then every odd n > 5 is a sum of three primes.")
    print()
    print("Method: n = 3 + (n - 3), where n - 3 is even ≥ 4.")
    print()

    for n in [7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 101, 1001]:
        if n % 2 == 0 or n <= 5:
            continue
        m = n - 3
        pair = find_goldbach_pair(m)
        if pair:
            p, q = pair
            print(f"  {n} = 3 + {p} + {q}  (3 prime, {p} prime, {q} prime)")
        else:
            print(f"  {n}: failed to decompose {m} = n - 3")


def graph_coverage_demo(N: int):
    """Show Goldbach graph coverage statistics."""
    print()
    print("=" * 60)
    print(f"GOLDBACH GRAPH COVERAGE (N = {N})")
    print("=" * 60)
    print()

    stats = goldbach_graph_coverage(N)
    print(f"  Primes ≤ {N}: {stats['num_primes']}")
    print(f"  Prime-pair edges with sum ≤ {N}: {stats['num_edges']}")
    print(f"  Even numbers in [4, {N}]: {stats['num_evens']}")
    print(f"  Covered by at least one edge: {stats['num_covered']}")
    print(f"  Uncovered: {stats['uncovered'] if stats['uncovered'] else 'NONE'}")
    print(f"  Average edge multiplicity: {stats['avg_multiplicity']:.2f}")
    print(f"  Maximum edge multiplicity: {stats['max_multiplicity']}")

    if not stats['uncovered']:
        print(f"\n  ✓ GoldbachUpTo({N}) holds!")


def representation_count_demo(N: int):
    """Show Goldbach representation counts (convolution identity demo)."""
    print()
    print("=" * 60)
    print(f"GOLDBACH REPRESENTATION COUNTS (up to {N})")
    print("=" * 60)
    print()
    print("  goldbachCount(n) = #{(p,q) : p,q prime, p+q=n}")
    print("                   = Σ_{k=0}^{n} 1_P(k) · 1_P(n-k)")
    print()

    for n in range(4, min(N + 1, 52), 2):
        pairs = find_all_goldbach_pairs(n)
        count = len(pairs)
        # Verify convolution identity
        conv = sum(
            (1 if is_prime(k) else 0) * (1 if is_prime(n - k) else 0)
            for k in range(n + 1)
        )
        assert count == conv, f"Convolution mismatch at n={n}"
        bar = "█" * (count // 2) if count > 0 else ""
        print(f"  n = {n:4d}: count = {count:3d}  {bar}")


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   ADDITIVE PRIME DECOMPOSITION FRAMEWORK — DEMO        ║")
    print("║   Certified Goldbach Verification Architecture         ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    # Demo 1: Parity obstruction
    parity_obstruction_demo()

    # Demo 2: Certificate generation and validation
    print()
    print("=" * 60)
    print("CERTIFICATE GENERATION & VALIDATION")
    print("=" * 60)
    print()
    N = 1000
    cert = generate_certificate(N)
    valid = validate_certificate(cert, N)
    print(f"  Generated certificate for GoldbachUpTo({N})")
    print(f"  Certificate size: {len(cert)} entries")
    print(f"  Certificate valid: {valid}")
    print()
    print("  Sample entries:")
    for n in [4, 6, 8, 10, 100, 500, 998, 1000]:
        if n in cert:
            p, q = cert[n]
            print(f"    {n} = {p} + {q}")

    # Demo 3: Monotone extension
    monotone_extension_demo()

    # Demo 4: Binary → ternary transfer
    ternary_goldbach_demo()

    # Demo 5: Graph coverage
    graph_coverage_demo(1000)

    # Demo 6: Representation counts
    representation_count_demo(50)

    # Demo 7: Least Goldbach prime statistics
    least_goldbach_prime_stats(10000)

    print()
    print("=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)


if __name__ == "__main__":
    main()
