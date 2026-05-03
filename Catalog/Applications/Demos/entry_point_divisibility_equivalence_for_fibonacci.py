#!/usr/bin/env python3
"""
Fibonacci Entry Point Divisibility — Interactive Demo

Demonstrates the key mathematical results formalized in Lean:
    For every positive integer n, the entry point z(n) is the least positive
    index where n | F(k). The fundamental equivalence is:
        n | F(m)  ↔  z(n) | m

Also demonstrates:
    - The strong divisibility property: gcd(F(m), F(n)) = F(gcd(m,n))
    - The Fibonacci LTE: v_p(F(mk)) = v_p(F(m)) + v_p(k)
    - Primitive prime divisor existence for composite indices
"""

import math
from functools import lru_cache

# ─── Core Fibonacci functions ────────────────────────────────────────────────

def fib(n: int) -> int:
    """Compute F(n) iteratively."""
    if n <= 0:
        return 0
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def fib_entry_point(n: int) -> int:
    """Compute the Fibonacci entry point z(n): smallest k > 0 with n | F(k)."""
    if n <= 1:
        return 0
    for k in range(1, 6 * n + 2):
        if fib(k) % n == 0:
            return k
    return -1


def prime_factorization(n: int) -> dict:
    """Return prime factorization as {prime: exponent}."""
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


def is_prime(n: int) -> bool:
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def padic_val(p: int, n: int) -> int:
    """Compute v_p(n), the p-adic valuation of n."""
    if n == 0: return float('inf')
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


# ─── Demo 1: Entry Point Table ──────────────────────────────────────────────

def demo_entry_point_table():
    print("=" * 70)
    print("DEMO 1: Fibonacci Entry Points")
    print("=" * 70)
    print()
    print("The entry point z(n) is the smallest k > 0 such that n | F(k).")
    print()
    print(f"{'n':>4}  {'z(n)':>5}  {'F(z(n))':>12}  {'F(z(n))/n':>12}")
    print("-" * 40)
    for n in range(2, 26):
        z = fib_entry_point(n)
        fz = fib(z)
        print(f"{n:>4}  {z:>5}  {fz:>12}  {fz // n:>12}")
    print()


# ─── Demo 2: Entry Point Divisibility Equivalence ───────────────────────────

def demo_dvd_equivalence():
    print("=" * 70)
    print("DEMO 2: The Entry Point Divisibility Equivalence")
    print("=" * 70)
    print()
    print("THEOREM: For n > 0:  n | F(m)  <->  z(n) | m")
    print()

    test_cases = [(7, 50), (11, 60), (13, 50), (5, 30), (8, 50)]
    for n, max_m in test_cases:
        z = fib_entry_point(n)
        multiples = [m for m in range(1, max_m + 1) if fib(m) % n == 0]
        expected = [m for m in range(1, max_m + 1) if m % z == 0]
        match = multiples == expected
        print(f"n = {n}, z(n) = {z}")
        print(f"  Indices m <= {max_m} with {n} | F(m): {multiples}")
        print(f"  Multiples of z(n) = {z}:            {expected}")
        print(f"  Match: {'✓' if match else '✗ MISMATCH!'}")
        print()


# ─── Demo 3: Strong Divisibility (GCD Identity) ────────────────────────────

def demo_gcd_identity():
    print("=" * 70)
    print("DEMO 3: Strong Divisibility — gcd(F(m), F(n)) = F(gcd(m,n))")
    print("=" * 70)
    print()
    
    pairs = [(6, 9), (8, 12), (10, 15), (12, 18), (14, 21), (20, 30), (15, 25)]
    print(f"{'m':>4}  {'n':>4}  {'gcd(m,n)':>8}  {'gcd(F(m),F(n))':>16}  {'F(gcd(m,n))':>12}  {'Match':>6}")
    print("-" * 60)
    for m, n in pairs:
        g = math.gcd(m, n)
        fg = fib(g)
        gcd_fib = math.gcd(fib(m), fib(n))
        match = gcd_fib == fg
        print(f"{m:>4}  {n:>4}  {g:>8}  {gcd_fib:>16}  {fg:>12}  {'✓' if match else '✗':>6}")
    print()


# ─── Demo 4: Fibonacci LTE ─────────────────────────────────────────────────

def demo_fibonacci_lte():
    print("=" * 70)
    print("DEMO 4: Fibonacci Lifting the Exponent (LTE)")
    print("=" * 70)
    print()
    print("THEOREM: For odd prime p != 5 with p | F(m):")
    print("  v_p(F(mk)) = v_p(F(m)) + v_p(k)")
    print()

    cases = [
        (3, 4, "p=3, z(3)=4"),
        (7, 8, "p=7, z(7)=8"),
        (11, 10, "p=11, z(11)=10"),
        (13, 7, "p=13, z(13)=7"),
    ]

    for p, z, label in cases:
        print(f"  {label}: v_{p}(F({z})) = {padic_val(p, fib(z))}")
        for k in range(1, 8):
            mk = z * k
            v_fmk = padic_val(p, fib(mk))
            v_fm = padic_val(p, fib(z))
            v_k = padic_val(p, k)
            expected = v_fm + v_k
            match = v_fmk == expected
            print(f"    k={k}: v_{p}(F({mk})) = {v_fmk} = {v_fm} + {v_k} {'✓' if match else '✗'}")
        print()


# ─── Demo 5: Primitive Prime Divisors ──────────────────────────────────────

def demo_primitive_divisors():
    print("=" * 70)
    print("DEMO 5: Primitive Prime Divisors of F(n) for Composite n")
    print("=" * 70)
    print()
    print("THEOREM (Carmichael 1913): For n >= 13, F(n) has a primitive prime")
    print("divisor — a prime p | F(n) with p does not divide F(k) for 0 < k < n.")
    print()

    def find_primitive_divisors(n):
        fn = fib(n)
        if fn <= 1: return []
        factors = prime_factorization(fn)
        primitives = []
        for p in factors:
            is_prim = True
            for k in range(1, n):
                if fib(k) % p == 0:
                    is_prim = False
                    break
            if is_prim:
                primitives.append(p)
        return primitives

    composite_ns = [n for n in range(13, 41) if not is_prime(n)]
    print(f"{'n':>4}  {'F(n)':>16}  {'Factors':>30}  {'Primitive primes':>20}")
    print("-" * 75)
    for n in composite_ns:
        fn = fib(n)
        factors = prime_factorization(fn)
        factor_str = " * ".join(f"{p}^{e}" if e > 1 else str(p)
                                for p, e in sorted(factors.items()))
        prims = find_primitive_divisors(n)
        prim_str = ", ".join(str(p) for p in prims) if prims else "NONE"
        fn_str = str(fn) if fn < 10**15 else f"{fn:.3e}"
        print(f"{n:>4}  {fn_str:>16}  {factor_str:>30}  {prim_str:>20}")
    print()
    print("Note: n = 12 is the LAST index without a primitive prime divisor:")
    print(f"  F(12) = {fib(12)} = 2^4 * 3^2, but 2 | F(3) and 3 | F(4)")
    print()


# ─── Demo 6: Entry Point Bridge ────────────────────────────────────────────

def demo_bridge():
    print("=" * 70)
    print("DEMO 6: The Entry Point Bridge for Carmichael's Theorem")
    print("=" * 70)
    print()
    print("Key insight: If p is a primitive prime divisor of F(n), then")
    print("the entry point z(p) = n. This is because:")
    print("  - p | F(n), so z(p) | n  (by the divisibility equivalence)")
    print("  - If z(p) < n, then p | F(z(p)), contradicting primitivity")
    print()

    for n in [14, 15, 18, 20, 21, 25, 30]:
        fn = fib(n)
        factors = prime_factorization(fn)
        print(f"n = {n}, F({n}) = {fn}")
        for p in sorted(factors.keys()):
            z = fib_entry_point(p)
            is_prim = all(fib(k) % p != 0 for k in range(1, n))
            status = "PRIMITIVE (z(p)=n)" if is_prim else f"non-primitive (z(p)={z})"
            print(f"  p = {p}: z(p) = {z}, {status}")
        print()


# ─── Main ───────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("=" * 70)
    print("  Fibonacci Entry Point Divisibility — Mathematical Demo")
    print("  Demonstrates formally verified results from Lean 4")
    print("=" * 70)
    print()

    demo_entry_point_table()
    demo_dvd_equivalence()
    demo_gcd_identity()
    demo_fibonacci_lte()
    demo_primitive_divisors()
    demo_bridge()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)
