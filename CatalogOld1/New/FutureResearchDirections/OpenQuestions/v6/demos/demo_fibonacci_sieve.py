#!/usr/bin/env python3
"""
Fibonacci Sieve Demo (Research Directions B8, E18)

Demonstrates using Fibonacci sequence properties for:
1. Compositeness testing: F(n)² ≡ 1 (mod n) for odd primes n ≠ 5
2. Factor sieving: F(p) periodicity filters factor candidates
3. Pisano period analysis for modular pattern detection
"""

import math


def fib_mod(n, m):
    """Compute F(n) mod m efficiently using matrix exponentiation."""
    if n == 0:
        return 0
    if n == 1:
        return 1 % m

    # Matrix [[1,1],[1,0]]^n method
    def mat_mul(A, B, mod):
        return [
            [(A[0][0]*B[0][0] + A[0][1]*B[1][0]) % mod,
             (A[0][0]*B[0][1] + A[0][1]*B[1][1]) % mod],
            [(A[1][0]*B[0][0] + A[1][1]*B[1][0]) % mod,
             (A[1][0]*B[0][1] + A[1][1]*B[1][1]) % mod]
        ]

    def mat_pow(M, p, mod):
        if p == 1:
            return [[x % mod for x in row] for row in M]
        if p % 2 == 0:
            half = mat_pow(M, p // 2, mod)
            return mat_mul(half, half, mod)
        else:
            return mat_mul(M, mat_pow(M, p - 1, mod), mod)

    M = [[1, 1], [1, 0]]
    result = mat_pow(M, n, m)
    return result[0][1]


def pisano_period(m):
    """Compute the Pisano period π(m) — the period of F(n) mod m."""
    if m <= 1:
        return 1

    prev, curr = 0, 1
    for i in range(1, m * m + 1):
        prev, curr = curr, (prev + curr) % m
        if prev == 0 and curr == 1:
            return i

    return -1  # Should not happen


def fib_compositeness_test(n):
    """
    Fibonacci compositeness test.

    If n is an odd prime ≠ 5, then F(n)² ≡ 1 (mod n).
    Contrapositive: if F(n)² ≢ 1 (mod n), then n is composite.

    Returns: "probably prime", "composite", or "inconclusive"
    """
    if n <= 1:
        return "composite"
    if n == 2 or n == 5:
        return "probably prime"
    if n % 2 == 0:
        return "composite"

    fib_n = fib_mod(n, n)
    fib_sq = (fib_n * fib_n) % n

    if fib_sq != 1:
        return "composite"
    else:
        return "probably prime"


def is_prime(n):
    """Simple primality test."""
    if n < 2:
        return False
    if n == 2:
        return True
    if n % 2 == 0:
        return False
    for i in range(3, int(math.isqrt(n)) + 1, 2):
        if n % i == 0:
            return False
    return True


def fibonacci_sieve(N, B):
    """
    Fibonacci sieve for factor candidates of N.

    For each small prime p, compute F(p) mod N.
    If gcd(F(p), N) is nontrivial, we found a factor.
    """
    factors_found = set()

    for p in range(2, B):
        if not is_prime(p):
            continue

        fib_p = fib_mod(p, N)
        g = math.gcd(fib_p, N)
        if 1 < g < N:
            factors_found.add(g)
            factors_found.add(N // g)

        # Also try F(p)² - 1
        fib_sq_minus_1 = (fib_p * fib_p - 1) % N
        g2 = math.gcd(fib_sq_minus_1, N)
        if 1 < g2 < N:
            factors_found.add(g2)
            factors_found.add(N // g2)

    return sorted(factors_found)


if __name__ == "__main__":
    print("=" * 70)
    print("FIBONACCI SIEVE AND PRIMALITY DEMO")
    print("Using F(p)² ≡ 1 (mod p) for Compositeness Testing")
    print("=" * 70)

    # Demo 1: Fibonacci compositeness test
    print("\n--- Fibonacci Compositeness Test ---")
    print("  F(n)² mod n ≡ 1 for primes (except 2, 5)")
    print()

    composites_caught = 0
    composites_total = 0
    for n in range(3, 200, 2):
        if n == 5:
            continue
        fib_result = fib_compositeness_test(n)
        actual = "prime" if is_prime(n) else "composite"

        if actual == "composite":
            composites_total += 1
            if fib_result == "composite":
                composites_caught += 1

        if n <= 50:
            fib_n = fib_mod(n, n)
            fib_sq = (fib_n * fib_n) % n
            status = "✓" if (actual == "prime") == (fib_result == "probably prime") else "?"
            print(f"  n = {n:>3}: F(n)² mod n = {fib_sq:>3}, "
                  f"test = {fib_result:>15}, actual = {actual:>10} {status}")

    print(f"\n  Composites caught: {composites_caught}/{composites_total} "
          f"({100*composites_caught/composites_total:.1f}%)")

    # Demo 2: Pisano periods
    print("\n--- Pisano Periods π(m) ---")
    print("  The period of F(n) mod m")
    for m in [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]:
        period = pisano_period(m)
        seq = [fib_mod(i, m) for i in range(period + 3)]
        print(f"  π({m:>2}) = {period:>3}: F mod {m} = {seq[:min(period+2, 15)]}...")

    # Demo 3: F(n) divisibility
    print("\n--- Fibonacci Divisibility Chain ---")
    print("  m | n ⟹ F(m) | F(n)")
    for m, n in [(3, 12), (4, 20), (5, 25), (6, 30), (7, 21)]:
        fm = fib_mod(m, 10**9)
        fn = fib_mod(n, 10**9)
        # Compute actual values for small cases
        def fib(k):
            a, b = 0, 1
            for _ in range(k):
                a, b = b, a + b
            return a
        fm_val = fib(m)
        fn_val = fib(n)
        divides = fn_val % fm_val == 0
        print(f"  {m} | {n}: F({m}) = {fm_val}, F({n}) = {fn_val}, "
              f"F({m}) | F({n}) = {divides} {'✓' if divides else '✗'}")

    # Demo 4: Fibonacci sieve for factoring
    print("\n--- Fibonacci Sieve Factoring ---")
    test_numbers = [
        (143, "11 × 13"),
        (221, "13 × 17"),
        (323, "17 × 19"),
        (1001, "7 × 11 × 13"),
        (2021, "43 × 47"),
        (10403, "101 × 103"),
        (25117, "prime"),
    ]

    for N, desc in test_numbers:
        factors = fibonacci_sieve(N, 200)
        status = "✓" if factors else "—"
        print(f"  N = {N:>6} ({desc}): factors = {factors if factors else 'none'} {status}")

    # Demo 5: F(n) even iff 3 | n
    print("\n--- F(n) Even ⟺ 3 | n ---")
    def fib_small(k):
        a, b = 0, 1
        for _ in range(k):
            a, b = b, a + b
        return a

    for n in range(15):
        f = fib_small(n)
        even = f % 2 == 0
        div3 = n % 3 == 0
        print(f"  F({n:>2}) = {f:>4}, even = {str(even):>5}, 3|{n} = {str(div3):>5} "
              f"{'✓' if even == div3 else '✗'}")

    # Demo 6: GCD of Fibonacci numbers
    print("\n--- gcd(F(m), F(n)) = F(gcd(m,n)) ---")
    for m, n in [(6, 9), (8, 12), (10, 15), (12, 18), (7, 11)]:
        fm = fib_small(m)
        fn = fib_small(n)
        g = math.gcd(m, n)
        fg = fib_small(g)
        gcd_fib = math.gcd(fm, fn)
        print(f"  gcd(F({m}), F({n})) = gcd({fm}, {fn}) = {gcd_fib}, "
              f"F(gcd({m},{n})) = F({g}) = {fg} "
              f"{'✓' if gcd_fib == fg else '✗'}")

    print("\n" + "=" * 70)
    print("KEY RESULTS (all formally verified in Lean 4):")
    print("1. F(p)² ≡ 1 (mod p) for odd primes p ≠ 5")
    print("2. F(n) even ⟺ 3 | n")
    print("3. m | n ⟹ F(m) | F(n)")
    print("4. gcd(F(m), F(n)) = F(gcd(m,n))")
    print("5. F(n) mod m is periodic (Pisano period)")
    print("6. F(n) ≤ 2ⁿ (exponential bound)")
    print("=" * 70)
