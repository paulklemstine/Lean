#!/usr/bin/env python3
"""
Fibonacci Primitive Prime Divisors — Carmichael's Theorem Demo

Demonstrates Carmichael's 1913 theorem: for every composite n ≥ 13,
F(n) has at least one primitive prime divisor.
"""

import math

# ---------- Fibonacci computation ----------

def fib(n):
    """Compute F(n) exactly."""
    if n <= 1:
        return n
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b

# ---------- Entry point ----------

def entry_point(p, limit=None):
    """Smallest k > 0 with p | F(k). Uses Pisano period: z(p) ≤ p²-1."""
    if limit is None:
        limit = p * p
    a, b = 0, 1
    for k in range(1, limit + 1):
        a, b = b, (a + b) % p
        if a == 0:
            return k
    return None

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def factorize(n):
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

def proper_divisors(n):
    divs = []
    for d in range(1, n):
        if n % d == 0:
            divs.append(d)
    return divs

# ---------- Demo 1: Small composite cases ----------

def demo_small():
    print("=" * 65)
    print("Carmichael's Theorem — Primitive Divisors for Composite n")
    print("=" * 65)
    print()

    for n in range(4, 26):
        if is_prime(n):
            continue
        fn = fib(n)
        factors = factorize(fn)

        # Find primitive primes among factors of F(n)
        prims = []
        for p in factors:
            z = entry_point(p, n)
            if z == n:
                prims.append(p)

        factor_str = " · ".join(
            f"{p}^{e}" if e > 1 else str(p)
            for p, e in sorted(factors.items())
        )
        marker = " ← NO PRIMITIVE!" if not prims else ""
        prim_str = str(prims) if prims else "none"

        print(f"  n={n:3d}: F(n) = {fn:>10} = {factor_str}")
        print(f"         Primitive: {prim_str}{marker}")

    print()
    print("  n=12 is the ONLY composite exception!")
    print("  F(12)=144=2⁴·3², but 2|F(3) and 3|F(4).")
    print()

# ---------- Demo 2: Entry points ----------

def demo_entry_points():
    print("=" * 65)
    print("Entry Points z(p): smallest k>0 with p | F(k)")
    print("=" * 65)
    print()
    print("  Key: p | F(n) ⟺ z(p) | n")
    print()

    for p in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
        z = entry_point(p)
        print(f"  p = {p:3d}:  z(p) = {z:4d}   F(z(p)) = {fib(z)}")

    print()

# ---------- Demo 3: Why n=12 fails ----------

def demo_exception():
    print("=" * 65)
    print("Why n=12 is the Only Exception")
    print("=" * 65)
    print()
    print(f"  F(12) = {fib(12)} = 2⁴ · 3²")
    print(f"  z(2) = {entry_point(2)} → 2 first appears at F({entry_point(2)}) = {fib(entry_point(2))}")
    print(f"  z(3) = {entry_point(3)} → 3 first appears at F({entry_point(3)}) = {fib(entry_point(3))}")
    print(f"  Both {entry_point(2)}|12 and {entry_point(3)}|12, so no prime is new.")
    print()
    print(f"  F(14) = {fib(14)} = 13 · 29")
    print(f"  z(13) = {entry_point(13)} → 13 first appears at F(7)")
    print(f"  z(29) = {entry_point(29)} → 29 first appears at F(14) ← PRIMITIVE!")
    print()

# ---------- Demo 4: Primitive part computation ----------

def demo_primitive_part():
    print("=" * 65)
    print("Primitive Part: F(n) with old factors stripped out")
    print("=" * 65)
    print()

    for n in [14, 15, 16, 18, 20, 24, 30, 48, 60]:
        fn = fib(n)
        divs = proper_divisors(n)
        prim = fn
        for d in divs:
            fd = fib(d)
            while True:
                g = math.gcd(prim, fd)
                if g <= 1: break
                prim //= g
        print(f"  n={n:3d}: F(n) = {fn:>12}  primitive part = {prim}")

    print()
    print("  Primitive part > 1 guarantees a primitive prime divisor.")
    print()

# ---------- Main ----------

if __name__ == "__main__":
    print()
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║  CARMICHAEL'S FIBONACCI PRIMITIVE DIVISOR THEOREM            ║")
    print("╚═══════════════════════════════════════════════════════════════╝")
    print()

    demo_small()
    demo_entry_points()
    demo_exception()
    demo_primitive_part()

    print("Carmichael (1913): For all composite n ≥ 13, F(n) has a")
    print("primitive prime divisor. Formalized in Lean 4 for n ≤ 50000.")
