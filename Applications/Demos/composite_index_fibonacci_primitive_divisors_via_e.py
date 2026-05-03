#!/usr/bin/env python3
"""
Demonstration of Carmichael's Primitive Divisor Theorem for Fibonacci Numbers.

This script illustrates the theorem that for every composite n > 12,
the Fibonacci number F(n) has a primitive prime divisor: a prime p
that divides F(n) but does not divide F(k) for any 0 < k < n.

The theorem was proved by R. D. Carmichael in 1913.
"""

import math
from functools import lru_cache
from collections import defaultdict

# ─── Fibonacci and factoring utilities ───────────────────────────────

@lru_cache(maxsize=None)
def fib(n):
    """Compute the n-th Fibonacci number."""
    if n <= 1:
        return n
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b

def prime_factors(n):
    """Return the set of prime factors of n."""
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors

def factorize(n):
    """Return prime factorization as dict {prime: exponent}."""
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
    """Return the sorted list of divisors of n."""
    divs = []
    for d in range(1, int(math.isqrt(n)) + 1):
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
    return sorted(divs)

def proper_divisors(n):
    """Return proper divisors d with 0 < d < n and d | n."""
    return [d for d in divisors(n) if 0 < d < n]

def is_prime(n):
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    d = 5
    while d * d <= n:
        if n % d == 0 or n % (d + 2) == 0:
            return False
        d += 6
    return True

# ─── Entry point (rank of apparition) ───────────────────────────────

def entry_point(p):
    """
    Compute the entry point (rank of apparition) of prime p in the
    Fibonacci sequence: the smallest positive k such that p | F(k).
    """
    if p <= 1:
        return None
    a, b = 0, 1
    for k in range(1, p * p + 2):  # Entry point is at most p+1 for prime p
        a, b = b, (a + b) % p
        if a == 0:
            return k
    return None

# ─── Primitive part computation ──────────────────────────────────────

def strip_all(r, m):
    """Remove all prime factors shared between r and m from r."""
    while True:
        g = math.gcd(r, m)
        if g <= 1:
            return r
        r //= g

def prim_part(n):
    """
    Compute the primitive part of F(n): the largest divisor of F(n)
    that is coprime to F(d) for every proper divisor d of n.
    """
    fn = fib(n)
    for d in proper_divisors(n):
        fn = strip_all(fn, fib(d))
    return fn

def find_primitive_primes(n):
    """
    Find all primitive prime divisors of F(n): primes p such that
    p | F(n) but p does not divide F(k) for any 0 < k < n.
    """
    fn = fib(n)
    if fn <= 1:
        return []
    primes = prime_factors(fn)
    primitive = []
    for p in sorted(primes):
        ep = entry_point(p)
        if ep == n:
            primitive.append(p)
    return primitive

# ─── Demonstrations ─────────────────────────────────────────────────

def demo_entry_points():
    """Show entry points for small primes."""
    print("=" * 60)
    print("ENTRY POINTS (RANK OF APPARITION) OF PRIMES")
    print("=" * 60)
    print(f"{'Prime p':>10} {'Entry point z(p)':>20} {'F(z(p))':>15}")
    print("-" * 50)
    for p in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
        if is_prime(p):
            ep = entry_point(p)
            print(f"{p:>10} {ep:>20} {fib(ep):>15}")
    print()
    print("Key property: p | F(k) if and only if z(p) | k")
    print()

def demo_primitive_divisors():
    """Show primitive prime divisors for various n."""
    print("=" * 60)
    print("PRIMITIVE PRIME DIVISORS OF FIBONACCI NUMBERS")
    print("=" * 60)
    print(f"{'n':>5} {'F(n)':>15} {'Type':>10} {'Primitive primes':>30}")
    print("-" * 65)

    for n in range(1, 31):
        fn = fib(n)
        ntype = "prime" if is_prime(n) else "comp" if n > 1 and not is_prime(n) else ""
        prims = find_primitive_primes(n)
        prims_str = ", ".join(str(p) for p in prims) if prims else "none"
        fn_str = str(fn) if fn < 10**12 else f"{fn:.3e}"
        print(f"{n:>5} {fn_str:>15} {ntype:>10} {prims_str:>30}")
    print()

def demo_carmichael_exceptions():
    """Show the exceptional cases n = 1, 2, 6, 12."""
    print("=" * 60)
    print("CARMICHAEL'S THEOREM: EXCEPTIONAL CASES")
    print("=" * 60)
    print()
    print("Carmichael (1913): F(n) has a primitive prime divisor for")
    print("every n > 12. The only exceptions are n = 1, 2, 6, 12:")
    print()

    exceptions = [1, 2, 6, 12]
    for n in exceptions:
        fn = fib(n)
        prims = find_primitive_primes(n)
        pp = prim_part(n)
        print(f"  n = {n}: F({n}) = {fn}")
        if fn <= 1:
            print(f"    F({n}) = {fn} has no prime factors at all.")
        else:
            pf = prime_factors(fn)
            print(f"    Prime factors: {pf}")
            for p in sorted(pf):
                ep = entry_point(p)
                print(f"    z({p}) = {ep} (proper divisor of {n})")
            print(f"    Primitive part = {pp}")
            print(f"    No primitive prime divisors!")
        print()

def demo_composite_case():
    """Demonstrate the composite case of Carmichael's theorem."""
    print("=" * 60)
    print("COMPOSITE CASE: EVERY COMPOSITE n > 12 HAS A PRIMITIVE PRIME")
    print("=" * 60)
    print()
    print("For composite n, the entry point z(p) = n ensures primitivity:")
    print("  p | F(k) ↔ z(p) | k, so z(p) = n means p ∤ F(k) for 0 < k < n")
    print()

    composite_examples = [14, 15, 16, 18, 20, 21, 22, 24, 25, 26, 27, 28, 30]
    for n in composite_examples:
        fn = fib(n)
        prims = find_primitive_primes(n)
        pp = prim_part(n)
        pd = proper_divisors(n)
        print(f"  n = {n} (divisors: {pd})")
        print(f"    F({n}) = {fn}")
        print(f"    Primitive part = {pp}")
        print(f"    Primitive primes: {prims}")
        for p in prims:
            print(f"      z({p}) = {entry_point(p)} = {n} ✓")
        print()

def demo_gcd_identity():
    """Demonstrate the key identity gcd(F(a), F(b)) = F(gcd(a,b))."""
    print("=" * 60)
    print("FIBONACCI GCD IDENTITY: gcd(F(a), F(b)) = F(gcd(a,b))")
    print("=" * 60)
    print()
    print("This identity is the foundation of the entry point theory.")
    print()
    examples = [(6, 9), (10, 15), (12, 8), (14, 21), (20, 30)]
    for a, b in examples:
        g = math.gcd(a, b)
        lhs = math.gcd(fib(a), fib(b))
        rhs = fib(g)
        print(f"  gcd(F({a}), F({b})) = gcd({fib(a)}, {fib(b)}) = {lhs}")
        print(f"  F(gcd({a},{b})) = F({g}) = {rhs}")
        assert lhs == rhs, f"Identity failed for a={a}, b={b}!"
        print(f"  ✓ Equal!")
        print()

def demo_lucas_numbers():
    """Show the Lucas number connection for even indices."""
    print("=" * 60)
    print("LUCAS NUMBERS AND THE EVEN INDEX CASE")
    print("=" * 60)
    print()
    print("For n = 2m: F(2m) = F(m) · L(m) where L(m) = F(m-1) + F(m+1)")
    print("is the m-th Lucas number. Key: gcd(L(m), F(m)) | 2.")
    print()
    print(f"{'m':>5} {'F(m)':>10} {'L(m)':>10} {'F(2m)':>12} {'gcd(L,F)':>10} {'L odd?':>8}")
    print("-" * 60)
    for m in range(2, 16):
        fm = fib(m)
        lm = fib(m - 1) + fib(m + 1)
        f2m = fib(2 * m)
        g = math.gcd(lm, fm)
        assert f2m == fm * lm, f"Identity failed for m={m}"
        assert g <= 2, f"gcd > 2 for m={m}"
        print(f"{m:>5} {fm:>10} {lm:>10} {f2m:>12} {g:>10} {'yes' if lm % 2 == 1 else 'no':>8}")
    print()
    print("For m prime ≥ 7 (not div by 3): F(m) is odd, so gcd(L(m), F(m)) = 1.")
    print("Thus L(m) is entirely 'new' prime content → primitive prime exists.")
    print()

def demo_verification_stats():
    """Verify Carmichael's theorem computationally for a range."""
    print("=" * 60)
    print("COMPUTATIONAL VERIFICATION OF CARMICHAEL'S THEOREM")
    print("=" * 60)
    print()

    max_n = 200
    exceptions = []
    stats = {"prime": 0, "composite_with_prim": 0, "composite_no_prim": 0}

    for n in range(13, max_n + 1):
        pp = prim_part(n)
        if is_prime(n):
            stats["prime"] += 1
        elif pp > 1:
            stats["composite_with_prim"] += 1
        else:
            stats["composite_no_prim"] += 1
            exceptions.append(n)

    print(f"  Range: n ∈ [13, {max_n}]")
    print(f"  Prime n: {stats['prime']}")
    print(f"  Composite n with primitive prime: {stats['composite_with_prim']}")
    print(f"  Composite n WITHOUT primitive prime: {stats['composite_no_prim']}")
    if exceptions:
        print(f"  Exceptions: {exceptions}")
    else:
        print(f"  No exceptions found! Carmichael's theorem holds. ✓")
    print()

    # Show primitive part growth
    print("Primitive part size for composite n:")
    print(f"{'n':>5} {'digits of primPart':>20} {'# primitive primes':>20}")
    print("-" * 50)
    for n in [14, 20, 30, 50, 100, 150, 200]:
        if not is_prime(n):
            pp = prim_part(n)
            digits = len(str(pp))
            prims = find_primitive_primes(n)
            print(f"{n:>5} {digits:>20} {len(prims):>20}")
    print()

# ─── Main ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  CARMICHAEL'S PRIMITIVE DIVISOR THEOREM FOR FIBONACCI   ║")
    print("║  Demonstration and Verification                        ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_entry_points()
    demo_gcd_identity()
    demo_lucas_numbers()
    demo_carmichael_exceptions()
    demo_primitive_divisors()
    demo_composite_case()
    demo_verification_stats()

    print("Done! All demonstrations completed successfully.")
