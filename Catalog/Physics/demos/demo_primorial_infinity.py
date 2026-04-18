#!/usr/bin/env python3
"""
Primorial Analysis and Infinitude of Primes Demo

Explores primorials p# = product of all primes ≤ p, and their role
in proving the infinitude of primes via the elegant argument that
every prime factor of p# + 1 must exceed p.
"""

from sympy import isprime, primerange, factorint
from functools import reduce
from operator import mul


def compute_primorial(n):
    """Compute n# = product of all primes ≤ n."""
    return reduce(mul, primerange(2, n + 1), 1)


def primorial_table(limit=23):
    """Display primorial values and their factorizations of p# + 1."""
    print("=== Primorial Table ===")
    print(f"{'p':>4} {'p#':>15} {'p# + 1':>15} {'Prime?':>7} {'Factors of p#+1':>25} {'Min factor > p?':>16}")
    print("-" * 90)

    for p in primerange(2, limit + 1):
        prim = compute_primorial(p)
        prim_plus1 = prim + 1
        is_p = isprime(prim_plus1)

        if is_p:
            factor_str = f"{prim_plus1} (prime)"
            min_factor = prim_plus1
        else:
            factors = factorint(prim_plus1)
            factor_str = " × ".join(
                f"{b}^{e}" if e > 1 else str(b)
                for b, e in sorted(factors.items())
            )
            min_factor = min(factors.keys())

        exceeds = "✓" if min_factor > p else "✗"
        print(f"{p:>4} {prim:>15} {prim_plus1:>15} {'Yes' if is_p else 'No':>7} "
              f"{factor_str:>25} {exceeds:>16}")

    print()
    print("Key insight: every prime factor of p# + 1 must exceed p,")
    print("because p# is divisible by every prime ≤ p, so p# + 1 ≡ 1 (mod q)")
    print("for every prime q ≤ p. This means p# + 1 has a prime factor > p,")
    print("proving that there are always primes larger than any given prime.")
    print()


def euclid_proof_trace():
    """Trace Euclid's proof of the infinitude of primes."""
    print("=== Euclid's Proof via Primorials ===")
    print()

    primes_found = []
    for step in range(1, 8):
        if not primes_found:
            # Start: assume we know prime 2
            primes_found = [2]
            product = 2
            new = product + 1  # = 3
            new_prime = min(factorint(new).keys())
            primes_found.append(new_prime)
            print(f"  Step {step}: Know primes {primes_found[:-1]}")
            print(f"    Product + 1 = {product} + 1 = {new}")
            print(f"    New prime found: {new_prime}")
            print(f"    Primes so far: {primes_found}")
        else:
            product = reduce(mul, primes_found)
            new = product + 1
            factors = factorint(new)
            new_prime = min(factors.keys())
            if new_prime not in primes_found:
                primes_found.append(new_prime)
                primes_found.sort()
            else:
                # Find a factor not in our list
                for f in sorted(factors.keys()):
                    if f not in primes_found:
                        new_prime = f
                        primes_found.append(f)
                        primes_found.sort()
                        break
            print(f"  Step {step}: Know primes {primes_found[:-1]}")
            print(f"    Product + 1 = {product} + 1 = {new}")
            if isprime(new):
                print(f"    {new} is prime!")
            else:
                print(f"    {new} = {' × '.join(str(f) for f in sorted(factors.keys()))}")
            print(f"    New prime found: {new_prime}")
            print(f"    Primes so far: {primes_found}")
        print()


def primorial_growth():
    """Analyze the growth of primorials and their relationship to prime gaps."""
    print("=== Primorial Growth Analysis ===")
    print(f"{'p':>4} {'p#':>20} {'log₂(p#)':>10} {'p#+1 prime?':>12}")
    print("-" * 50)

    import math
    for p in primerange(2, 40):
        prim = compute_primorial(p)
        log2 = math.log2(prim) if prim > 0 else 0
        is_p = isprime(prim + 1)
        print(f"{p:>4} {prim:>20} {log2:>10.2f} {'Yes ✓' if is_p else 'No':>12}")

    print()
    print("Primorial primes (p# + 1 is prime): p = 2, 3, 5, 7, 11, 31, 379, ...")
    print("Primorial primes (p# - 1 is prime): p = 3, 5, 11, 13, 41, 89, ...")
    print()


if __name__ == "__main__":
    primorial_table()
    euclid_proof_trace()
    primorial_growth()
