#!/usr/bin/env python3
"""
Applications of Carmichael's Primitive Divisor Theorem

This module demonstrates practical applications of Fibonacci primitive
divisor theory in number theory, cryptography, and algorithms.
"""

from functools import lru_cache
import math

@lru_cache(maxsize=None)
def fib(n):
    if n <= 1:
        return n
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b

def prime_factors(n):
    if n <= 1:
        return {}
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors

def entry_point(p, limit=10000):
    for k in range(1, limit + 1):
        if fib(k) % p == 0:
            return k
    return None

# ─── Application 1: Fibonacci Primality Certificates ────────────────

def app_primality():
    """
    APPLICATION: Fibonacci-based primality witnesses

    By Carmichael's theorem, F(n) for n > 12 always has a prime factor
    that didn't appear in any earlier F(k). This means that for each
    composite n ≥ 13, there exists a prime p such that the multiplicative
    order of the golden ratio modulo p is exactly n.

    This provides a NUMBER-THEORETIC CERTIFICATE: if you can exhibit a
    prime p with α(p) = n, you've proven that n has a specific algebraic
    property (it's the "Fibonacci period" of p).
    """
    print("=" * 65)
    print("APPLICATION 1: Fibonacci Primality Certificates")
    print("=" * 65)
    print()
    print("For each n > 12, Carmichael guarantees a prime p with α(p) = n.")
    print("This prime p serves as a 'witness' for the index n.")
    print()

    print(f"{'n':>4s}  {'Witness prime p':>16s}  {'F(n) mod p':>12s}  {'Entry point':>12s}")
    print("-" * 50)
    for n in range(13, 51):
        fn = fib(n)
        factors = prime_factors(fn)
        for p in sorted(factors.keys()):
            ep = entry_point(p)
            if ep == n:
                print(f"{n:4d}  {p:16d}  {fn % p:12d}  {ep:12d}")
                break
    print()

# ─── Application 2: Large Prime Generation ──────────────────────────

def app_large_primes():
    """
    APPLICATION: Generating large primes via Fibonacci factorization

    Primitive prime divisors of F(n) tend to be large — often much larger
    than n itself. For prime n, ALL prime factors of F(n) are primitive,
    giving a natural source of primes in specific arithmetic progressions.

    Key property: If p is a primitive divisor of F(n), then p ≡ ±1 (mod n)
    when n is prime and n ≠ 5. This means Fibonacci numbers are a source
    of primes in specific residue classes.
    """
    print("=" * 65)
    print("APPLICATION 2: Large Prime Generation from Fibonacci Numbers")
    print("=" * 65)
    print()
    print("Primitive primes of F(n) satisfy p ≡ ±1 (mod n) for prime n ≠ 5.")
    print()

    print(f"{'n (prime)':>10s}  {'Primitive prime p':>18s}  {'p mod n':>8s}  {'p/n ratio':>10s}")
    print("-" * 55)
    for n in [13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71]:
        fn = fib(n)
        factors = prime_factors(fn)
        for p in sorted(factors.keys(), reverse=True):
            ep = entry_point(p)
            if ep == n:
                print(f"{n:10d}  {p:18d}  {p % n:8d}  {p/n:10.1f}")
                break
    print()

# ─── Application 3: GCD Algorithms ──────────────────────────────────

def app_gcd():
    """
    APPLICATION: Fibonacci GCD identity in algorithm design

    The identity gcd(F(m), F(n)) = F(gcd(m,n)) has algorithmic implications:
    - Computing gcd of Fibonacci numbers reduces to gcd of indices
    - This gives O(log min(m,n)) time for Fibonacci GCD
    - Used in analysis of the Euclidean algorithm (Fibonacci numbers are
      worst-case inputs for the Euclidean algorithm)
    """
    print("=" * 65)
    print("APPLICATION 3: Fibonacci GCD Identity")
    print("=" * 65)
    print()
    print("gcd(F(m), F(n)) = F(gcd(m, n))")
    print()

    pairs = [(6, 9), (10, 15), (12, 18), (20, 30), (15, 25), (14, 21)]
    print(f"{'m':>4s}  {'n':>4s}  {'gcd(m,n)':>8s}  {'F(m)':>10s}  {'F(n)':>10s}  "
          f"{'gcd(F(m),F(n))':>15s}  {'F(gcd(m,n))':>12s}  {'Match':>6s}")
    print("-" * 80)
    for m, n in pairs:
        g = math.gcd(m, n)
        fm, fn, fg = fib(m), fib(n), fib(g)
        gcd_fib = math.gcd(fm, fn)
        match = "✓" if gcd_fib == fg else "✗"
        print(f"{m:4d}  {n:4d}  {g:8d}  {fm:10d}  {fn:10d}  "
              f"{gcd_fib:15d}  {fg:12d}  {match:>6s}")
    print()

# ─── Application 4: Cryptographic Hardness ───────────────────────────

def app_crypto():
    """
    APPLICATION: Implications for Fibonacci-based cryptographic constructions

    The existence of primitive divisors constrains the algebraic structure
    of Fibonacci numbers modulo primes. This has implications for:

    1. The Pisano period π(p): the period of F(n) mod p.
       Carmichael's theorem ensures that for each n > 12, there exist
       primes with Pisano period exactly 2n (or n, depending on conditions).

    2. Discrete logarithm in Fibonacci groups:
       The group Z/pZ under "Fibonacci multiplication" has order related
       to α(p). Primitive divisors ensure diverse group structures.
    """
    print("=" * 65)
    print("APPLICATION 4: Pisano Periods and Fibonacci Cryptography")
    print("=" * 65)
    print()

    def pisano_period(p):
        """Compute the Pisano period π(p) = period of F(n) mod p."""
        prev, curr = 0, 1
        for i in range(1, p * p + 1):
            prev, curr = curr, (prev + curr) % p
            if prev == 0 and curr == 1:
                return i
        return None

    print("Pisano periods π(p) for small primes:")
    print(f"{'p':>5s}  {'α(p)':>5s}  {'π(p)':>6s}  {'π(p)/α(p)':>10s}")
    print("-" * 35)
    for p in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
              53, 59, 61, 67, 71, 73, 79, 83, 89, 97]:
        ep = entry_point(p)
        pp = pisano_period(p)
        if ep and pp:
            print(f"{p:5d}  {ep:5d}  {pp:6d}  {pp/ep:10.0f}")
    print()
    print("Note: π(p) is always a multiple of α(p), and π(p)/α(p) ∈ {1, 2, 4}")
    print("(a consequence of the structure of the Fibonacci group mod p).")
    print()

if __name__ == "__main__":
    app_primality()
    app_large_primes()
    app_gcd()
    app_crypto()


#!/usr/bin/env python3
"""
Carmichael's Primitive Divisor Theorem — Interactive Demonstration

Carmichael's theorem (1913): Every Fibonacci number F(n) with n > 12
has at least one prime factor that does not divide any earlier Fibonacci
number F(k) for 0 < k < n.
"""

import math
from functools import lru_cache

@lru_cache(maxsize=None)
def fib(n):
    if n <= 1:
        return n
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b

def prime_factors(n):
    if n <= 1:
        return {}
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors

def entry_point(p, limit=10000):
    for k in range(1, limit + 1):
        if fib(k) % p == 0:
            return k
    return None

def primitive_primes(n):
    fn = fib(n)
    if fn <= 1:
        return []
    return [p for p in prime_factors(fn) if entry_point(p) == n]

def v_p(n, p):
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v

def demo_theorem():
    print("=" * 70)
    print("CARMICHAEL'S PRIMITIVE DIVISOR THEOREM (1913)")
    print("=" * 70)
    print()
    print("Exceptions (F(n) has NO primitive prime divisor):")
    for n in [1, 2, 6, 12]:
        fn = fib(n)
        prims = primitive_primes(n)
        print(f"  F({n}) = {fn}, primes: {list(prime_factors(fn).keys())}, "
              f"primitive: {prims if prims else 'NONE'}")
    print()
    print("Verification for n = 13..40:")
    for n in range(13, 41):
        fn = fib(n)
        prims = primitive_primes(n)
        print(f"  F({n:2d}) = {fn:>12d}  primitive primes: {prims}")
    print()

def demo_wall():
    print("=" * 70)
    print("WALL'S THEOREM (1960): v_p(F(mk)) = v_p(F(m)) + v_p(k)")
    print("=" * 70)
    for p, m in [(5, 5), (3, 4), (7, 8)]:
        print(f"\np = {p}, α(p) = {m}:")
        for k in range(1, 11):
            actual = v_p(fib(m * k), p)
            predicted = v_p(fib(m), p) + v_p(k, p)
            print(f"  k={k:2d}: v_{p}(F({m*k:3d})) = {actual} "
                  f"= v_{p}(F({m})) + v_{p}({k}) = {predicted}  "
                  f"{'✓' if actual == predicted else '✗'}")

def demo_growth():
    print("\n" + "=" * 70)
    print("FIBONACCI MULTIPLICATION INEQUALITY: F(ab) > F(a)·F(b)")
    print("=" * 70)
    for a in [2, 3, 5, 7]:
        for b in [a, a + 1, a + 3]:
            fa, fb, fab = fib(a), fib(b), fib(a * b)
            ratio = fab / (fa * fb) if fa * fb > 0 else float('inf')
            print(f"  F({a}·{b}) = F({a*b}) = {fab}, "
                  f"F({a})·F({b}) = {fa*fb}, ratio = {ratio:.2f}")

if __name__ == "__main__":
    demo_theorem()
    demo_wall()
    demo_growth()
