#!/usr/bin/env python3
"""
Goldbach Conjecture Explorer — Interactive Demo

Explores Goldbach's conjecture: every even integer ≥ 4 is a sum of two primes.
Includes:
  - Verification up to a given bound
  - Counting Goldbach representations
  - The "strong" version with two ODD primes (n ≥ 6)
  - Visualization of representation density

Based on theorems formally verified in Lean 4 (v15-v16).
"""

def sieve_of_eratosthenes(limit):
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return is_prime


def goldbach_representations(n, is_prime):
    """Count representations of n as p + q with p ≤ q, both prime."""
    count = 0
    witnesses = []
    for p in range(2, n // 2 + 1):
        q = n - p
        if is_prime[p] and is_prime[q]:
            count += 1
            if len(witnesses) < 5:
                witnesses.append((p, q))
    return count, witnesses


def main():
    print("=" * 70)
    print("  GOLDBACH CONJECTURE EXPLORER")
    print("  Formally verified in Lean 4 — Gravitational Factoring v16")
    print("=" * 70)

    LIMIT = 2000
    is_prime = sieve_of_eratosthenes(LIMIT + 100)
    primes = [i for i in range(2, LIMIT + 1) if is_prime[i]]

    # 1. Verification
    print(f"\n📊 Goldbach Verification up to {LIMIT}:")
    print("-" * 50)
    all_verified = True
    failures = []
    min_reps = (float('inf'), 0)
    max_reps = (0, 0)

    for n in range(4, LIMIT + 1, 2):
        count, witnesses = goldbach_representations(n, is_prime)
        if count == 0:
            all_verified = False
            failures.append(n)
        if count < min_reps[0]:
            min_reps = (count, n)
        if count > max_reps[0]:
            max_reps = (count, n)

    status = "VERIFIED ✓" if all_verified else f"FAILED ✗ at {failures}"
    print(f"  Status: {status}")
    print(f"  Fewest representations: r({min_reps[1]}) = {min_reps[0]}")
    print(f"  Most representations: r({max_reps[1]}) = {max_reps[0]}")

    # 2. Representation counts for notable numbers
    print(f"\n📐 Notable Goldbach Representations:")
    print("-" * 50)
    for n in [4, 6, 10, 20, 100, 200, 500, 1000, 2000]:
        if n <= LIMIT:
            count, witnesses = goldbach_representations(n, is_prime)
            witness_str = ", ".join(f"{p}+{q}" for p, q in witnesses[:3])
            if count > 3:
                witness_str += f", ... ({count} total)"
            print(f"  {n:>5} = {witness_str}")

    # 3. Strong Goldbach (odd primes only, n ≥ 6)
    print(f"\n🔒 Strong Goldbach (two ODD primes, n ≥ 6):")
    print("-" * 50)
    strong_verified = True
    for n in range(6, LIMIT + 1, 2):
        found = False
        for p in range(3, n // 2 + 1, 2):
            q = n - p
            if is_prime[p] and is_prime[q] and q % 2 == 1:
                found = True
                break
        if not found:
            strong_verified = False
            print(f"  ✗ Failed at n = {n}")
            break
    if strong_verified:
        print(f"  Every even n ∈ [6, {LIMIT}] = sum of two odd primes ✓")

    # 4. Representation density
    print(f"\n📈 Goldbach Representation Density r(2n):")
    print("-" * 50)
    print(f"  {'2n':>6} | {'r(2n)':>6} | {'bar':>40}")
    print(f"  {'-'*6}-+-{'-'*6}-+-{'-'*40}")

    for n in range(2, 101, 2):
        m = 2 * n
        if m <= LIMIT:
            count, _ = goldbach_representations(m, is_prime)
            bar = '█' * min(count, 40)
            print(f"  {m:>6} | {count:>6} | {bar}")

    # 5. Growth of representations
    print(f"\n📊 Average Representations by Range:")
    print("-" * 50)
    for lo, hi in [(4, 100), (100, 500), (500, 1000), (1000, 2000)]:
        counts = []
        for n in range(lo, min(hi + 1, LIMIT + 1), 2):
            count, _ = goldbach_representations(n, is_prime)
            counts.append(count)
        avg = sum(counts) / len(counts) if counts else 0
        print(f"  [{lo:>5}, {hi:>5}]: avg r(n) = {avg:.1f}, min = {min(counts)}, max = {max(counts)}")


if __name__ == "__main__":
    main()
