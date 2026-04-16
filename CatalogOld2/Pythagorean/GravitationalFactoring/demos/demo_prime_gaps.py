#!/usr/bin/env python3
"""
Prime Gap & Desert Explorer — Interactive Demo

Explores prime gaps, deserts, and distribution:
  - Prime gap statistics
  - Maximal gaps and records
  - Prime desert construction via factorials
  - Legendre's conjecture verification
  - Bertrand's postulate and π(n) ≥ log₂(n)

Based on theorems formally verified in Lean 4 (v15-v16).
"""

import math

def sieve_of_eratosthenes(limit):
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return is_prime


def main():
    print("=" * 70)
    print("  PRIME GAP & DESERT EXPLORER")
    print("  Formally verified in Lean 4 — Gravitational Factoring v16")
    print("=" * 70)

    LIMIT = 50000
    is_prime = sieve_of_eratosthenes(LIMIT)
    primes = [i for i in range(2, LIMIT + 1) if is_prime[i]]

    # 1. Prime gap records
    print(f"\n📊 Prime Gap Records up to {LIMIT}:")
    print("-" * 60)
    print(f"  {'Gap':>5} | {'p':>7} | {'q':>7} | {'Primes ≤ p':>10}")

    max_gap = 0
    gap_records = []
    for i in range(1, len(primes)):
        gap = primes[i] - primes[i-1]
        if gap > max_gap:
            max_gap = gap
            gap_records.append((gap, primes[i-1], primes[i], i))
            print(f"  {gap:>5} | {primes[i-1]:>7} | {primes[i]:>7} | {i:>10}")

    # 2. First gaps of various sizes
    print(f"\n📐 First Occurrence of Gap Size g:")
    print("-" * 60)
    first_gap = {}
    for i in range(1, len(primes)):
        gap = primes[i] - primes[i-1]
        if gap not in first_gap:
            first_gap[gap] = (primes[i-1], primes[i])

    for g in [2, 4, 6, 8, 10, 14, 18, 20, 30, 34, 36, 44, 52, 72]:
        if g in first_gap:
            p, q = first_gap[g]
            print(f"  Gap {g:>3}: between {p:>7} and {q:>7}")

    # 3. Prime desert via factorials
    print(f"\n🏜️ Prime Deserts via Factorials:")
    print("  (k+1)! + j is composite for 2 ≤ j ≤ k+1")
    print("-" * 60)
    for k in [2, 3, 5, 7, 10]:
        factorial = math.factorial(k + 1)
        desert = [(factorial + j, j) for j in range(2, k + 2)]
        print(f"\n  k = {k}: {k+1}! = {factorial}")
        print(f"  Desert of {k} consecutive composites:")
        for val, j in desert[:min(8, len(desert))]:
            print(f"    {k+1}! + {j} = {val} = {j} × {val // j}")
        if len(desert) > 8:
            print(f"    ... ({len(desert)} terms total)")

    # 4. Legendre's conjecture verification
    print(f"\n📊 Legendre's Conjecture: ∃ prime between n² and (n+1)²")
    print("-" * 60)
    max_check = 200
    all_verified = True
    for n in range(1, max_check + 1):
        lo, hi = n * n, (n + 1) * (n + 1)
        found = False
        for p in range(lo + 1, hi):
            if p <= LIMIT and is_prime[p]:
                found = True
                break
        if not found:
            all_verified = False
            print(f"  ✗ Failed at n = {n}: no prime in ({lo}, {hi})")
            break

    if all_verified:
        print(f"  Verified for all n ≤ {max_check} ✓")

    # Count primes in each interval
    print(f"\n  Number of primes between n² and (n+1)²:")
    for n in [1, 2, 5, 10, 20, 50, 100, 200]:
        lo, hi = n * n, (n + 1) * (n + 1)
        count = sum(1 for p in range(lo + 1, hi) if p <= LIMIT and is_prime[p])
        print(f"    n = {n:>3}: [{lo:>5}, {hi:>5}] → {count} primes")

    # 5. Bertrand's postulate verification
    print(f"\n🎯 Bertrand's Postulate: ∃ prime p with n < p ≤ 2n")
    print("-" * 60)
    for n in [1, 2, 5, 10, 50, 100, 500, 1000, 5000]:
        best_p = None
        for p in range(n + 1, 2 * n + 1):
            if p <= LIMIT and is_prime[p]:
                best_p = p
                break
        if best_p:
            print(f"  n = {n:>5}: smallest prime in ({n}, {2*n}] is {best_p} ✓")

    # 6. π(n) ≥ log₂(n) — from iterated Bertrand (proved in v16)
    print(f"\n📈 π(n) ≥ log₂(n) (proved from Bertrand in v16):")
    print("-" * 60)
    pi_count = 0
    pi_index = 0
    checkpoints = [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 10000]
    ci = 0
    for n in range(2, LIMIT + 1):
        if is_prime[n]:
            pi_count += 1
        if ci < len(checkpoints) and n == checkpoints[ci]:
            log2_n = math.floor(math.log2(n))
            ratio = pi_count / log2_n if log2_n > 0 else float('inf')
            print(f"  n = {n:>5}: π(n) = {pi_count:>5}, ⌊log₂(n)⌋ = {log2_n:>3}, "
                  f"ratio = {ratio:.1f} ✓" if pi_count >= log2_n else "✗")
            ci += 1

    # 7. Gap distribution histogram
    print(f"\n📊 Gap Size Distribution (primes < 10000):")
    print("-" * 60)
    gap_counts = {}
    small_primes = [p for p in primes if p < 10000]
    for i in range(1, len(small_primes)):
        gap = small_primes[i] - small_primes[i-1]
        gap_counts[gap] = gap_counts.get(gap, 0) + 1

    for gap in sorted(gap_counts.keys()):
        count = gap_counts[gap]
        bar = '█' * min(count // 2, 40)
        print(f"  gap {gap:>3}: {count:>4} {bar}")


if __name__ == "__main__":
    main()
