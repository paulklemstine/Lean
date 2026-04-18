#!/usr/bin/env python3
"""
Carmichael Numbers and Korselt's Criterion Demo

Explores Carmichael numbers — composite numbers that pass Fermat's
primality test for all bases coprime to n. Verifies Korselt's criterion.
"""

from math import gcd
from sympy import isprime, factorint


def is_carmichael(n):
    """Check if n is a Carmichael number."""
    if n < 4 or isprime(n):
        return False
    for a in range(2, n):
        if gcd(a, n) == 1:
            if pow(a, n - 1, n) != 1:
                return False
    return True


def korselt_check(n):
    """Check Korselt's criterion for n."""
    if isprime(n):
        return False, "prime"
    factors = factorint(n)

    # Check squarefree
    for p, e in factors.items():
        if e > 1:
            return False, f"not squarefree ({p}^{e})"

    # Check (p-1) | (n-1) for each prime factor
    for p in factors:
        if (n - 1) % (p - 1) != 0:
            return False, f"(n-1) = {n-1} not divisible by (p-1) = {p-1} for p = {p}"

    return True, "passes Korselt"


def find_carmichael_numbers(limit=10000):
    """Find all Carmichael numbers below limit."""
    print(f"=== Carmichael Numbers below {limit} ===")
    carmichaels = []

    for n in range(4, limit + 1):
        if is_carmichael(n):
            factors = factorint(n)
            factor_str = " × ".join(str(p) for p in sorted(factors.keys()))
            korselt, reason = korselt_check(n)

            carmichaels.append(n)
            print(f"  {n} = {factor_str}")
            print(f"    Korselt: {reason}")

            # Show (p-1) | (n-1) for each factor
            for p in sorted(factors.keys()):
                print(f"    (n-1)/(p-1) = {n-1}/{p-1} = {(n-1)//(p-1)}")

    print(f"\n  Found {len(carmichaels)} Carmichael numbers: {carmichaels}")
    print()


def fermat_witness_analysis(n):
    """For a composite n, find Fermat witnesses and liars."""
    if isprime(n):
        print(f"{n} is prime, skipping.")
        return

    witnesses = []
    liars = []

    for a in range(2, n):
        if gcd(a, n) == 1:
            if pow(a, n - 1, n) == 1:
                liars.append(a)
            else:
                witnesses.append(a)

    print(f"=== Fermat Analysis for n = {n} ===")
    factors = factorint(n)
    factor_str = " × ".join(f"{p}^{e}" if e > 1 else str(p) for p, e in factors.items())
    print(f"  Factorization: {n} = {factor_str}")
    print(f"  Coprime bases: {len(witnesses) + len(liars)}")
    print(f"  Fermat witnesses (detect composite): {len(witnesses)}")
    print(f"  Fermat liars (fool the test):        {len(liars)}")

    if len(witnesses) == 0:
        print(f"  ★ {n} is a CARMICHAEL NUMBER (all coprime bases are liars)")
    else:
        liar_ratio = len(liars) / (len(liars) + len(witnesses))
        print(f"  Liar ratio: {liar_ratio:.4f}")
        print(f"  First few witnesses: {witnesses[:10]}")

    print()


def carmichael_density():
    """Analyze the density of Carmichael numbers."""
    print("=== Carmichael Number Density ===")
    print()

    thresholds = [100, 500, 1000, 2500, 5000, 10000]
    counts = []

    for limit in thresholds:
        count = sum(1 for n in range(4, limit + 1) if is_carmichael(n))
        counts.append(count)
        print(f"  C({limit:>6}) = {count:>3}")

    print()
    print("  Alford-Granville-Pomerance (1994): infinitely many Carmichael numbers exist.")
    print("  Asymptotic: C(x) > x^(2/7) for large x.")
    print()


if __name__ == "__main__":
    find_carmichael_numbers(10000)

    print()
    fermat_witness_analysis(561)
    fermat_witness_analysis(1729)
    fermat_witness_analysis(341)  # Not Carmichael: 341 = 11 × 31

    carmichael_density()
