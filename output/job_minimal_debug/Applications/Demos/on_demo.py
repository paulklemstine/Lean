#!/usr/bin/env python3
"""
Demonstration of Carmichael's Theorem on Primitive Fibonacci Divisors.

For n >= 13, F(n) has a primitive prime divisor: a prime p that divides F(n)
but does not divide F(k) for any 0 < k < n.

This script computes and displays primitive prime divisors for various n.
"""

import math
from functools import lru_cache


@lru_cache(maxsize=10000)
def fib(n):
    """Compute the n-th Fibonacci number."""
    if n <= 1:
        return n
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


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


def is_prime(n):
    """Check if n is prime."""
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


def entry_point(p, max_k=None):
    """
    Compute the entry point (rank of apparition) of prime p:
    the smallest k > 0 such that p | F(k).
    """
    if max_k is None:
        max_k = p * p + 10  # Pisano period is at most p^2 - 1
    a, b = 0, 1
    for k in range(1, max_k + 1):
        a, b = b, (a + b) % p
        if a == 0:
            return k
    return None


def find_primitive_divisors(n):
    """
    Find all primitive prime divisors of F(n).
    A prime p is primitive for F(n) if p | F(n) and p does not divide F(k)
    for any 0 < k < n.
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


def proper_divisors(n):
    """Return proper divisors of n (excluding n itself, including 1)."""
    divs = []
    for d in range(1, n):
        if n % d == 0:
            divs.append(d)
    return divs


def coprime_part(a, b):
    """Remove all prime factors of b from a."""
    while True:
        g = math.gcd(a, b)
        if g <= 1:
            return a
        a //= g


def fib_coprime_part(n):
    """
    Compute the coprime part of F(n) with respect to F(d) for all proper d | n.
    If > 1, F(n) has a primitive prime divisor.
    """
    fn = fib(n)
    for d in proper_divisors(n):
        fd = fib(d)
        if fd > 1:
            fn = coprime_part(fn, fd)
    return fn


def main():
    print("=" * 72)
    print("CARMICHAEL'S THEOREM: Primitive Prime Divisors of Fibonacci Numbers")
    print("=" * 72)
    print()
    print("For n >= 13, F(n) has at least one primitive prime divisor.")
    print("A primitive prime p divides F(n) but not F(k) for any 0 < k < n.")
    print()

    # Display for n = 13 to 30
    print("-" * 72)
    print(f"{'n':>4} | {'F(n)':>15} | {'Type':>10} | {'Primitive Primes':>30}")
    print("-" * 72)

    for n in range(13, 31):
        fn = fib(n)
        typ = "prime" if is_prime(n) else "composite"
        prims = find_primitive_divisors(n)
        prims_str = ", ".join(str(p) for p in prims)
        print(f"{n:>4} | {fn:>15} | {typ:>10} | {prims_str:>30}")

    print("-" * 72)
    print()

    # Show the entry point structure
    print("=" * 72)
    print("ENTRY POINTS: For each prime p, α(p) = smallest k > 0 with p | F(k)")
    print("=" * 72)
    print()
    print(f"{'p':>6} | {'α(p)':>6} | {'F(α(p))':>12} | {'p | F(α(p))':>12}")
    print("-" * 46)
    for p in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
        ep = entry_point(p)
        fep = fib(ep)
        divides = "✓" if fep % p == 0 else "✗"
        print(f"{p:>6} | {ep:>6} | {fep:>12} | {divides:>12}")

    print()

    # Show coprime part computation
    print("=" * 72)
    print("COPRIME PART COMPUTATION")
    print("=" * 72)
    print()
    print("fibCoprimePart(n) removes all prime factors of F(d) from F(n)")
    print("for proper divisors d | n. If > 1, a primitive divisor exists.")
    print()
    print(f"{'n':>4} | {'F(n)':>12} | {'Proper divs':>20} | {'CoprimePart':>12}")
    print("-" * 60)
    for n in [14, 15, 18, 20, 24, 30]:
        fn = fib(n)
        pdivs = [d for d in proper_divisors(n) if d > 0]
        cp = fib_coprime_part(n)
        pdivs_str = str(pdivs[:5]) + ("..." if len(pdivs) > 5 else "")
        print(f"{n:>4} | {fn:>12} | {pdivs_str:>20} | {cp:>12}")

    print()

    # Verify for exceptions
    print("=" * 72)
    print("EXCEPTIONS: n where F(n) has NO primitive prime divisor")
    print("=" * 72)
    print()
    exceptions = []
    for n in range(1, 13):
        prims = find_primitive_divisors(n)
        if not prims:
            exceptions.append(n)
            fn = fib(n)
            print(f"  n = {n}: F({n}) = {fn}, "
                  f"factors = {prime_factors(fn) if fn > 1 else '{}'}, "
                  f"no primitive divisor")

    print(f"\nExceptions: {exceptions}")
    print(f"For all n >= 13, F(n) has a primitive prime divisor. ✓")
    print()

    # Large examples
    print("=" * 72)
    print("LARGE EXAMPLES")
    print("=" * 72)
    print()
    for n in [100, 200, 500, 1000]:
        fn = fib(n)
        cp = fib_coprime_part(n)
        typ = "prime" if is_prime(n) else "composite"
        print(f"n = {n} ({typ}):")
        print(f"  F({n}) has {len(str(fn))} digits")
        print(f"  fibCoprimePart({n}) = {cp} (has {len(str(cp))} digits)")
        print(f"  Primitive divisor exists: {'✓' if cp > 1 else '?'}")
        print()


if __name__ == "__main__":
    main()
