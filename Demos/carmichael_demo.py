#!/usr/bin/env python3
"""
Carmichael's Primitive Divisor Theorem — Interactive Demo

Demonstrates that every Fibonacci number F(n) with n > 12 has a
"primitive" prime divisor: a prime p that divides F(n) but does NOT
divide F(k) for any 0 < k < n.
"""

import math
import sys

# ─── Fibonacci (iterative) ──────────────────────────────────────────

_fib_cache = {0: 0, 1: 1}

def fib(n):
    if n in _fib_cache:
        return _fib_cache[n]
    for i in range(2, n + 1):
        if i not in _fib_cache:
            _fib_cache[i] = _fib_cache[i-1] + _fib_cache[i-2]
    return _fib_cache[n]

# ─── Number theory helpers ──────────────────────────────────────────

def prime_factors(n):
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

def divisors(n):
    divs = set()
    for d in range(1, int(math.isqrt(n)) + 1):
        if n % d == 0:
            divs.add(d)
            divs.add(n // d)
    return sorted(divs)

def entry_point(p, max_k=500):
    """Smallest k > 0 with p | F(k), using modular arithmetic."""
    if p <= 1:
        return None
    a, b = 0, 1  # F(0), F(1) mod p
    for k in range(1, max_k + 1):
        a, b = b, (a + b) % p
        if a == 0:
            return k
    return None

def find_primitive_primes(n, max_n=200):
    """Find all primitive prime divisors of F(n)."""
    fn = fib(n)
    if fn <= 1:
        return []
    pf = prime_factors(fn)
    proper_divs = [d for d in divisors(n) if 0 < d < n]
    primitive = []
    for p in pf:
        is_prim = all(fib(d) % p != 0 for d in proper_divs)
        if is_prim:
            primitive.append(p)
    return primitive

# ─── Main demo ──────────────────────────────────────────────────────

def demo():
    # Precompute Fibonacci numbers
    for i in range(201):
        fib(i)

    print("=" * 72)
    print("  CARMICHAEL'S PRIMITIVE DIVISOR THEOREM FOR FIBONACCI NUMBERS")
    print("=" * 72)
    print()
    print("Theorem (Carmichael, 1913): For every n > 12, F(n) has at least")
    print("one primitive prime divisor — a prime p dividing F(n) that does")
    print("NOT divide F(k) for any 0 < k < n.")
    print()

    # Exceptions
    print("─" * 72)
    print("EXCEPTIONS (n ≤ 12 where F(n) > 1 but no primitive divisor):")
    print("─" * 72)
    for n in range(1, 13):
        fn = fib(n)
        if fn <= 1:
            continue
        prims = find_primitive_primes(n)
        if not prims:
            pf = prime_factors(fn)
            eps = {p: entry_point(p) for p in pf}
            info = ", ".join(f"{p} (enters at F({eps[p]}))" for p in sorted(pf))
            print(f"  n={n:2d}: F({n}) = {fn}, factors: {info}")

    # Verification table
    print()
    print("─" * 72)
    print("VERIFICATION for n = 13..35:")
    print("─" * 72)
    print(f"{'n':>3s}  {'F(n)':>12s}  {'Factorization':>28s}  {'Primitive':>18s}")
    print("─" * 72)
    for n in range(13, 36):
        fn = fib(n)
        pf = prime_factors(fn)
        prims = find_primitive_primes(n)
        fact = " · ".join(f"{p}^{e}" if e > 1 else str(p) for p, e in sorted(pf.items()))
        prim_str = ", ".join(map(str, sorted(prims)))
        print(f"{n:3d}  {fn:12d}  {fact:>28s}  {prim_str:>18s}")

    # Entry point examples
    print()
    print("─" * 72)
    print("ENTRY POINTS of small primes:")
    print("─" * 72)
    print("α(p) = smallest k > 0 with p | F(k)")
    print()
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    for p in primes:
        ep = entry_point(p)
        print(f"  α({p:2d}) = {ep:3d}   →  p is primitive for F({ep})")

    # Why n=12 fails
    print()
    print("─" * 72)
    print("WHY n = 12 IS THE LAST EXCEPTION:")
    print("─" * 72)
    print(f"  F(12) = 144 = 2⁴ · 3²")
    print(f"  • 2 first divides F(3) = 2  →  α(2) = 3 ≠ 12")
    print(f"  • 3 first divides F(4) = 3  →  α(3) = 4 ≠ 12")
    print(f"  Both primes enter before index 12. No primitive divisor!")
    print()
    print(f"  F(13) = 233 (prime)")
    print(f"  • 233 first divides F(13)   →  α(233) = 13 = n  ✓")
    print(f"  233 IS a primitive prime divisor of F(13).")

    # Applications
    print()
    print("─" * 72)
    print("APPLICATIONS:")
    print("─" * 72)
    print("""
  1. CRYPTOGRAPHY: Primitive primes of F(n) provide fresh randomness
     at each Fibonacci index — useful for key derivation.

  2. ALGEBRAIC NUMBER THEORY: Carmichael's theorem is the Fibonacci
     special case of Zsygmondy's theorem for Lucas sequences.

  3. PRIMALITY TESTING: If p is primitive for F(n), then the
     multiplicative order of φ mod p is exactly n, giving a
     certificate that n | (p ± 1).
    """)

if __name__ == "__main__":
    demo()


