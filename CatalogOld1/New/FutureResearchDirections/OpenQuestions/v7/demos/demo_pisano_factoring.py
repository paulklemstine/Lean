#!/usr/bin/env python3
"""
Pisano Period Factoring Demo (E28)

Demonstrates how Pisano periods can be used to constrain and find factors.
The Pisano period π(N) = lcm(π(p), π(q)) for N = pq, so computing π(N)
and analyzing its divisors reveals information about p and q.
"""

import math
from functools import lru_cache

def fib_mod(n, m):
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
    def mat_pow(M, n, mod):
        result = [[1,0],[0,1]]  # Identity
        while n > 0:
            if n % 2 == 1:
                result = mat_mul(result, M, mod)
            M = mat_mul(M, M, mod)
            n //= 2
        return result
    M = [[1,1],[1,0]]
    R = mat_pow(M, n, m)
    return R[0][1]

def pisano_period(m):
    """Compute the Pisano period π(m): smallest T>0 with F(n+T) ≡ F(n) mod m for all n."""
    if m <= 1:
        return 1
    # Find T such that F(T) ≡ 0 and F(T+1) ≡ 1 mod m
    prev, curr = 0, 1
    for i in range(1, m * m + 1):
        prev, curr = curr, (prev + curr) % m
        if prev == 0 and curr == 1:
            return i
    return m * m  # Fallback

def factor_via_pisano(N):
    """Attempt to factor N using Pisano period analysis."""
    pi_N = pisano_period(N)
    print(f"\n  N = {N}")
    print(f"  π(N) = {pi_N}")

    # The key insight: π(N) = lcm(π(p), π(q)) for N = pq
    # So π(p) | π(N) and π(q) | π(N)
    # For each divisor d of π(N), check if gcd(F(d), N) gives a factor
    factors_found = set()
    divisors = [d for d in range(1, pi_N + 1) if pi_N % d == 0]

    for d in divisors:
        f_d = fib_mod(d, N)
        g = math.gcd(f_d, N)
        if 1 < g < N:
            factors_found.add(g)
            factors_found.add(N // g)

    if factors_found:
        p, q = min(factors_found), max(factors_found)
        print(f"  Factors found: {p} × {q} = {p*q}")
        print(f"  π({p}) = {pisano_period(p)}, π({q}) = {pisano_period(q)}")
        print(f"  lcm(π({p}), π({q})) = {math.lcm(pisano_period(p), pisano_period(q))}")
        return p, q
    else:
        print(f"  No factors found via Pisano period")
        return None

def demo_pisano_periods():
    """Show Pisano periods for small primes."""
    print("=" * 60)
    print("PISANO PERIOD TABLE FOR SMALL PRIMES")
    print("=" * 60)
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    for p in primes:
        pi_p = pisano_period(p)
        # Verify: π(p) | p² - 1
        divides = (p*p - 1) % pi_p == 0
        print(f"  π({p:2d}) = {pi_p:4d}  |  p²-1 = {p*p-1:4d}  |  π(p) | p²-1: {divides}")

def demo_factoring():
    """Demonstrate Pisano period factoring on semiprimes."""
    print("\n" + "=" * 60)
    print("PISANO PERIOD FACTORING DEMO")
    print("=" * 60)

    semiprimes = [
        (3, 7), (5, 11), (7, 13), (11, 17), (13, 19),
        (7, 11), (3, 13), (5, 7), (11, 23), (17, 19)
    ]
    successes = 0
    for p, q in semiprimes:
        result = factor_via_pisano(p * q)
        if result:
            successes += 1

    print(f"\n  Success rate: {successes}/{len(semiprimes)}")

def demo_fib_compositeness():
    """Fibonacci compositeness test."""
    print("\n" + "=" * 60)
    print("FIBONACCI COMPOSITENESS TEST")
    print("=" * 60)
    print("  Testing F(n)² mod n for various n:")
    print(f"  {'n':>5} {'F(n) mod n':>12} {'F(n)² mod n':>14} {'1 mod n':>8} {'Verdict':>12}")
    print("  " + "-" * 55)

    for n in range(3, 50):
        if n == 5:
            continue  # Skip n=5 (special case)
        fn = fib_mod(n, n)
        fn2 = (fn * fn) % n
        one_mod = 1 % n
        is_prime = all(n % i != 0 for i in range(2, int(n**0.5) + 1))
        if fn2 != one_mod:
            verdict = "COMPOSITE ✓" if not is_prime else "FALSE POS"
        else:
            verdict = "passes" if is_prime else "PSEUDOPRIME!"
        if not is_prime or fn2 != one_mod:
            print(f"  {n:5d} {fn:12d} {fn2:14d} {one_mod:8d} {verdict:>12}")

if __name__ == "__main__":
    print("╔" + "═" * 58 + "╗")
    print("║  PISANO PERIOD FACTORING — Gravitational Factoring v7   ║")
    print("╚" + "═" * 58 + "╝")

    demo_pisano_periods()
    demo_factoring()
    demo_fib_compositeness()
