#!/usr/bin/env python3
"""
Wilson's Theorem and Wilson Primes Demo

Explores Wilson's theorem: (p-1)! ≡ -1 (mod p) for prime p,
and its converse. Identifies Wilson primes where p² | (p-1)! + 1.
"""

import math
from sympy import isprime


def verify_wilson_theorem(limit=50):
    """Verify Wilson's theorem for primes up to limit."""
    print(f"=== Wilson's Theorem Verification (primes ≤ {limit}) ===")
    print(f"{'p':>5} {'(p-1)!':>15} {'(p-1)! mod p':>14} {'p-1':>5} {'OK':>4}")
    print("-" * 50)

    for p in range(2, limit + 1):
        if isprime(p):
            fact = math.factorial(p - 1)
            remainder = fact % p
            ok = "✓" if remainder == p - 1 else "✗"
            fact_str = str(fact) if fact < 10**12 else f"~10^{len(str(fact))-1}"
            print(f"{p:>5} {fact_str:>15} {remainder:>14} {p-1:>5} {ok:>4}")
    print()


def wilson_converse(limit=30):
    """Verify Wilson's converse: n composite → (n-1)! ≢ -1 (mod n)."""
    print(f"=== Wilson's Converse (composites ≤ {limit}) ===")
    print(f"{'n':>5} {'Prime?':>7} {'(n-1)! mod n':>14} {'= n-1?':>7} {'Consistent':>11}")
    print("-" * 50)

    for n in range(2, limit + 1):
        fact = math.factorial(n - 1)
        remainder = fact % n
        is_p = isprime(n)
        equals_nm1 = remainder == n - 1
        consistent = (is_p == equals_nm1)
        print(f"{n:>5} {'Yes' if is_p else 'No':>7} {remainder:>14} "
              f"{'Yes' if equals_nm1 else 'No':>7} {'✓' if consistent else '✗':>11}")
    print()


def wilson_quotients(limit=100):
    """Compute Wilson quotients W(p) = ((p-1)! + 1) / p."""
    print(f"=== Wilson Quotients (primes ≤ {limit}) ===")
    print(f"{'p':>5} {'W(p)':>20} {'W(p) mod p':>12} {'Wilson prime?':>14}")
    print("-" * 55)

    wilson_primes = []
    for p in range(2, limit + 1):
        if isprime(p):
            fact = math.factorial(p - 1)
            wq = (fact + 1) // p
            wq_mod_p = wq % p
            is_wilson = wq_mod_p == 0
            if is_wilson:
                wilson_primes.append(p)
            wq_str = str(wq) if wq < 10**15 else f"~10^{len(str(wq))-1}"
            print(f"{p:>5} {wq_str:>20} {wq_mod_p:>12} "
                  f"{'★ YES ★' if is_wilson else '':>14}")

    print()
    print(f"Wilson primes found below {limit}: {wilson_primes}")
    print()


def search_wilson_primes(limit=1000):
    """Search for Wilson primes up to limit."""
    print(f"=== Wilson Prime Search (up to {limit}) ===")
    wilson_primes = []

    for p in range(2, limit + 1):
        if isprime(p):
            fact = math.factorial(p - 1)
            if (fact + 1) % (p * p) == 0:
                wq = (fact + 1) // p
                wilson_primes.append((p, wq % p))
                print(f"  Found Wilson prime: p = {p}")
                print(f"    (p-1)! + 1 = {fact + 1}")
                print(f"    p² = {p*p}")
                print(f"    (p-1)! + 1 divided by p² = {(fact + 1) // (p*p)}")

    print()
    if wilson_primes:
        print(f"Wilson primes below {limit}: {[wp[0] for wp in wilson_primes]}")
    else:
        print(f"No Wilson primes found below {limit}")

    print()
    print("Known Wilson primes: 5, 13, 563")
    print("It is an open problem whether there are infinitely many Wilson primes.")
    print("The next Wilson prime (if it exists) is > 5 × 10⁸.")
    print()


def wilson_vs_wieferich():
    """Compare Wilson primes with Wieferich primes."""
    print("=== Wilson Primes vs Wieferich Primes ===")
    print()
    print("Wilson prime p:    p² | (p-1)! + 1")
    print("Wieferich prime p: p² | 2^(p-1) - 1")
    print()
    print("Known Wilson primes:    5, 13, 563")
    print("Known Wieferich primes: 1093, 3511")
    print()
    print("Both are extremely rare. Heuristically, the probability that a prime p")
    print("is Wilson/Wieferich is ~1/p, so we expect ~ln(ln(N)) of each below N.")
    print("This gives ~3-4 below 10⁹, consistent with observations.")
    print()


if __name__ == "__main__":
    verify_wilson_theorem(30)
    wilson_converse(20)
    wilson_quotients(50)
    search_wilson_primes(600)
    wilson_vs_wieferich()
