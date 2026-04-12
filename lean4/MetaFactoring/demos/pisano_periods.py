#!/usr/bin/env python3
"""
MetaFactoring Demo: Pisano Period Computation and Visualization

Demonstrates the unified Pisano divisibility theorem: for every prime p ≠ 5,
p | F(p²-1). Also computes Pisano periods and shows the period structure.

This is formally verified in Lean 4 — see MetaFactoring/OpenQuestions.lean
"""

import math
from functools import lru_cache


def fib_mod(n: int, m: int) -> int:
    """Compute F(n) mod m efficiently using matrix exponentiation."""
    if m == 1:
        return 0
    if n <= 1:
        return n % m

    # Matrix exponentiation: [[1,1],[1,0]]^n
    def mat_mul(A, B, mod):
        return [
            [(A[0][0]*B[0][0] + A[0][1]*B[1][0]) % mod,
             (A[0][0]*B[0][1] + A[0][1]*B[1][1]) % mod],
            [(A[1][0]*B[0][0] + A[1][1]*B[1][0]) % mod,
             (A[1][0]*B[0][1] + A[1][1]*B[1][1]) % mod]
        ]

    def mat_pow(M, p, mod):
        result = [[1, 0], [0, 1]]
        base = M
        while p > 0:
            if p % 2 == 1:
                result = mat_mul(result, base, mod)
            base = mat_mul(base, base, mod)
            p //= 2
        return result

    M = [[1, 1], [1, 0]]
    result = mat_pow(M, n, m)
    return result[0][1]


def pisano_period(m: int) -> int:
    """Compute π(m), the Pisano period of Fibonacci numbers mod m."""
    if m <= 1:
        return 1
    prev, curr = 0, 1
    for i in range(1, m * m + 1):
        prev, curr = curr, (prev + curr) % m
        if prev == 0 and curr == 1:
            return i
    return -1  # Should not happen


def is_prime(n: int) -> bool:
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


def verify_pisano_divisibility():
    """Verify the unified Pisano theorem: p | F(p²-1) for all primes p ≠ 5."""
    print("=" * 70)
    print("UNIFIED PISANO DIVISIBILITY THEOREM")
    print("For every prime p ≠ 5: p | F(p² - 1)")
    print("=" * 70)

    primes = [p for p in range(2, 200) if is_prime(p) and p != 5]

    print(f"\nVerifying for {len(primes)} primes up to 200...")
    print(f"{'p':>5} {'p mod 5':>8} {'Case':>8} {'π(p)':>6} {'p²-1':>10} "
          f"{'π(p)|(p²-1)':>12} {'p|F(p²-1)':>10}")
    print("-" * 70)

    all_pass = True
    for p in primes:
        p_mod_5 = p % 5
        case = "split" if p_mod_5 in [1, 4] else "inert"
        pi_p = pisano_period(p)
        p_sq_m1 = p * p - 1
        divides_period = (p_sq_m1 % pi_p == 0)
        fib_val = fib_mod(p_sq_m1, p)
        divides_fib = (fib_val == 0)

        if not divides_fib:
            all_pass = False

        if p < 50 or not divides_fib:
            print(f"{p:>5} {p_mod_5:>8} {case:>8} {pi_p:>6} {p_sq_m1:>10} "
                  f"{'✓' if divides_period else '✗':>12} "
                  f"{'✓' if divides_fib else '✗':>10}")

    print("-" * 70)
    print(f"Result: {'ALL VERIFIED ✓' if all_pass else 'SOME FAILED ✗'}")
    print()


def show_pisano_periods():
    """Display Pisano periods for small primes."""
    print("=" * 70)
    print("PISANO PERIODS π(m) FOR m = 2..30")
    print("=" * 70)
    print(f"{'m':>4} {'π(m)':>6} {'F(0..π(m)-1) mod m'}")
    print("-" * 70)

    for m in range(2, 31):
        pi = pisano_period(m)
        seq = [fib_mod(i, m) for i in range(pi)]
        seq_str = str(seq) if len(seq) <= 20 else str(seq[:15]) + "..."
        print(f"{m:>4} {pi:>6} {seq_str}")


def demonstrate_lens_advantage():
    """Demonstrate multi-lens advantage with different correlation levels."""
    print("\n" + "=" * 70)
    print("MULTI-LENS ADVANTAGE")
    print("S / β^k for different bases β and number of lenses k")
    print("=" * 70)

    S = 2**64  # 64-bit search space
    betas = [2.0, 1.92, 1.5, 1.2]
    labels = ["Ideal (β=2.0)", "Measured (β≈1.92)", "Correlated (β=1.5)", "Heavy (β=1.2)"]

    print(f"\nSearch space S = 2^64 = {S:.2e}")
    print(f"\n{'k lenses':>10}", end="")
    for label in labels:
        print(f"{label:>22}", end="")
    print()
    print("-" * 100)

    for k in range(1, 15):
        print(f"{k:>10}", end="")
        for beta in betas:
            reduced = S / beta**k
            print(f"{reduced:>22.2e}", end="")
        print()


def fibonacci_factoring_demo():
    """Demo: Using Fibonacci arithmetic for trial division."""
    print("\n" + "=" * 70)
    print("FIBONACCI FACTORING DEMO")
    print("Using gcd(F(m), N) to find factors")
    print("=" * 70)

    test_cases = [
        (15, "3 × 5"),
        (91, "7 × 13"),
        (221, "13 × 17"),
        (1517, "37 × 41"),
        (10403, "101 × 103"),
    ]

    for N, desc in test_cases:
        print(f"\nN = {N} = {desc}")
        for k in range(2, 100):
            fk = fib_mod(k, N)
            g = math.gcd(fk, N)
            if 1 < g < N:
                print(f"  Found: gcd(F({k}), {N}) = {g} → factors: {g} × {N//g}")
                break


def norm_channel_demo():
    """Demo: Sum-of-squares representations for factoring."""
    print("\n" + "=" * 70)
    print("NORM CHANNEL FACTORING DEMO")
    print("Two sum-of-squares reps → factor extraction")
    print("=" * 70)

    def find_two_square_reps(N):
        reps = []
        a = 0
        while a * a <= N:
            b_sq = N - a * a
            b = int(math.isqrt(b_sq))
            if b * b == b_sq and a <= b:
                reps.append((a, b))
            a += 1
        return reps

    test_cases = [5*13, 5*17, 5*29, 13*17, 13*29, 5*37, 5*41]

    for N in test_cases:
        reps = find_two_square_reps(N)
        if len(reps) >= 2:
            a1, b1 = reps[0]
            a2, b2 = reps[1]
            # (a1-a2)(a1+a2) = (b2-b1)(b2+b1)
            # Try gcd(a1*b2 - a2*b1, N) and gcd(a1*b2 + a2*b1, N)
            g1 = math.gcd(a1 * b2 - a2 * b1, N)
            g2 = math.gcd(a1 * b2 + a2 * b1, N)
            factor = None
            for g in [g1, g2]:
                if 1 < g < N:
                    factor = g
                    break
            if factor:
                print(f"N = {N}: {a1}² + {b1}² = {a2}² + {b2}² = {N}")
                print(f"  → gcd extraction gives factor {factor}, "
                      f"so {N} = {factor} × {N // factor}")


if __name__ == "__main__":
    verify_pisano_divisibility()
    show_pisano_periods()
    demonstrate_lens_advantage()
    fibonacci_factoring_demo()
    norm_channel_demo()
