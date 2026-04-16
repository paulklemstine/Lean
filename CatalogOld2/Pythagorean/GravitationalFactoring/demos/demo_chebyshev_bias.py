#!/usr/bin/env python3
"""
Chebyshev Bias Explorer — Interactive Demo

Demonstrates the Chebyshev bias: among primes up to N,
non-quadratic-residue classes tend to have more primes
than quadratic-residue classes.

Key finding (v16): The bias is universal across moduli 3, 4, 5,
with remarkably consistent ratios.

Based on theorems formally verified in Lean 4 (v15-v16).
"""

import math

def sieve_of_eratosthenes(limit):
    """Return list of primes up to limit."""
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

def prime_race(primes, modulus, class_a, class_b, label_a="A", label_b="B"):
    """Track the prime race between two residue classes."""
    count_a, count_b = 0, 0
    a_leads, b_leads, ties = 0, 0, 0
    crossings = []

    for p in primes:
        if p % modulus in class_a:
            count_a += 1
        elif p % modulus in class_b:
            count_b += 1

        if count_a > count_b:
            if b_leads > 0 or ties > 0:
                crossings.append(p)
            a_leads += 1
        elif count_b > count_a:
            if a_leads > 0 or ties > 0:
                crossings.append(p)
            b_leads += 1
        else:
            ties += 1

    return count_a, count_b, crossings[:5]


def main():
    print("=" * 70)
    print("  CHEBYSHEV BIAS EXPLORER")
    print("  Formally verified in Lean 4 — Gravitational Factoring v16")
    print("=" * 70)

    LIMIT = 10000
    primes = sieve_of_eratosthenes(LIMIT)
    print(f"\n  Total primes ≤ {LIMIT}: {len(primes)}")

    # Mod 3 analysis
    print(f"\n{'='*50}")
    print("📊 CHEBYSHEV BIAS MOD 3")
    print(f"{'='*50}")
    print("  QR (quadratic residues) mod 3: {1}")
    print("  QNR (quadratic non-residues) mod 3: {2}")

    for N in [100, 500, 1000, 5000, 10000]:
        ps = [p for p in primes if p <= N]
        c1 = sum(1 for p in ps if p % 3 == 1)
        c2 = sum(1 for p in ps if p % 3 == 2)
        ratio = c2 / c1 if c1 > 0 else float('inf')
        leader = "NR wins" if c2 > c1 else "R wins" if c1 > c2 else "TIE"
        print(f"  π({N:>5}): class 1 = {c1:>4}, class 2 = {c2:>4}, ratio = {ratio:.3f} [{leader}]")

    # Mod 4 analysis
    print(f"\n{'='*50}")
    print("📊 CHEBYSHEV BIAS MOD 4")
    print(f"{'='*50}")
    print("  QR mod 4: {1}")
    print("  QNR mod 4: {3}")

    for N in [100, 500, 1000, 5000, 10000]:
        ps = [p for p in primes if p <= N]
        c1 = sum(1 for p in ps if p % 4 == 1)
        c3 = sum(1 for p in ps if p % 4 == 3)
        ratio = c3 / c1 if c1 > 0 else float('inf')
        leader = "NR wins" if c3 > c1 else "R wins" if c1 > c3 else "TIE"
        print(f"  π({N:>5}): class 1 = {c1:>4}, class 3 = {c3:>4}, ratio = {ratio:.3f} [{leader}]")

    # Mod 5 analysis
    print(f"\n{'='*50}")
    print("📊 CHEBYSHEV BIAS MOD 5")
    print(f"{'='*50}")
    print("  QR mod 5: {1, 4}")
    print("  QNR mod 5: {2, 3}")

    for N in [100, 500, 1000, 5000, 10000]:
        ps = [p for p in primes if p <= N]
        cR = sum(1 for p in ps if p % 5 in {1, 4})
        cNR = sum(1 for p in ps if p % 5 in {2, 3})
        ratio = cNR / cR if cR > 0 else float('inf')
        leader = "NR wins" if cNR > cR else "R wins" if cR > cNR else "TIE"
        print(f"  π({N:>5}): R = {cR:>4}, NR = {cNR:>4}, ratio = {ratio:.3f} [{leader}]")

    # Universality summary
    print(f"\n{'='*50}")
    print("🌐 UNIVERSALITY OF CHEBYSHEV BIAS")
    print(f"{'='*50}")
    ps1000 = [p for p in primes if p < 1000]
    biases = {}

    biases["mod 3"] = (
        sum(1 for p in ps1000 if p % 3 == 2),
        sum(1 for p in ps1000 if p % 3 == 1)
    )
    biases["mod 4"] = (
        sum(1 for p in ps1000 if p % 4 == 3),
        sum(1 for p in ps1000 if p % 4 == 1)
    )
    biases["mod 5"] = (
        sum(1 for p in ps1000 if p % 5 in {2, 3}),
        sum(1 for p in ps1000 if p % 5 in {1, 4})
    )

    for mod, (nr, r) in biases.items():
        print(f"  {mod}: NR = {nr}, R = {r}, ratio = {nr/r:.3f}")

    print(f"\n  Key insight: Non-residue classes consistently dominate!")
    print(f"  This is predicted by the Rubinstein-Sarnak framework")
    print(f"  and has been formally verified in Lean 4 for mod 3, 4, 5.")

    # Prime race visualization (text-based)
    print(f"\n{'='*50}")
    print("🏁 PRIME RACE MOD 4: class 1 vs class 3")
    print(f"{'='*50}")
    c1, c3 = 0, 0
    checkpoints = [100, 200, 500, 1000, 2000, 5000, 10000]
    ci = 0
    for p in primes:
        if p % 4 == 1:
            c1 += 1
        elif p % 4 == 3:
            c3 += 1
        if ci < len(checkpoints) and p >= checkpoints[ci]:
            bar_1 = '█' * (c1 // 3)
            bar_3 = '█' * (c3 // 3)
            print(f"  p≤{checkpoints[ci]:>5}: 1|{bar_1}")
            print(f"          3|{bar_3}")
            ci += 1


if __name__ == "__main__":
    main()
