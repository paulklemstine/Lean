"""
demo.py — Korselt's Criterion and Carmichael Numbers
====================================================

A self-contained, dependency-free demonstration of the mathematics formalized in
`Catalog/Novelty/KorseltCarmichael.lean`.

We illustrate, by direct computation:

  1. The Korselt identity:   n | a^n - a   for every integer a, when n is Korselt.
  2. The Carmichael property: n | b^(n-1) - 1 for every base b coprime to n.
  3. Korselt's criterion check (squarefree composite, (p-1) | (n-1) for all p | n).
  4. The structural theorems: every Carmichael number is odd, squarefree, with >= 3
     distinct prime factors.
  5. The canonical instance 561 = 3 * 11 * 17, the smallest Carmichael number.
  6. Why the naive Fermat test fails on Carmichael numbers (no witness exposes them).

Run:  python3 demo.py
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List


# --------------------------------------------------------------------------- #
# Elementary number theory utilities (all inlined, no imports beyond stdlib)   #
# --------------------------------------------------------------------------- #

def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def factorize(n: int) -> Dict[int, int]:
    """Return the prime factorization of n as {prime: exponent}."""
    factors: Dict[int, int] = {}
    m = n
    d = 2
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors


def distinct_prime_factors(n: int) -> List[int]:
    """Sorted list of distinct primes dividing n."""
    return sorted(factorize(n).keys())


def is_squarefree(n: int) -> bool:
    """True iff no prime appears with exponent >= 2 in n's factorization."""
    return all(e == 1 for e in factorize(n).values())


# --------------------------------------------------------------------------- #
# Korselt's criterion and the Carmichael property                              #
# --------------------------------------------------------------------------- #

def is_korselt(n: int) -> bool:
    """
    Korselt's criterion (sufficient form, matching `IsKorselt` in Lean):

        1 < n,  n composite,  n squarefree,  and  (p - 1) | (n - 1) for every prime p | n.
    """
    if n <= 1 or is_prime(n):
        return False
    if not is_squarefree(n):
        return False
    return all((n - 1) % (p - 1) == 0 for p in distinct_prime_factors(n))


def divides_pow_sub_self(n: int, a: int) -> bool:
    """Test the Korselt identity for a single integer a:  n | a^n - a."""
    return (pow(a, n, n) - (a % n)) % n == 0


def is_fermat_psp(n: int, b: int) -> bool:
    """n is a Fermat pseudoprime to base b: n composite and n | b^(n-1) - 1."""
    if n <= 1 or is_prime(n) or gcd(n, b) != 1:
        return False
    return pow(b, n - 1, n) == 1


def is_carmichael(n: int) -> bool:
    """
    Definitional test: n is composite and a Fermat pseudoprime to every base
    coprime to it.  (Equivalent to is_korselt(n) by the formalized theorem.)
    """
    if n <= 1 or is_prime(n):
        return False
    return all(pow(b, n - 1, n) == 1 for b in range(1, n) if gcd(n, b) == 1)


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #

def demo_korselt_identity(n: int = 561) -> None:
    """Verify  n | a^n - a  for a range of integers a (Theorem: dvd_pow_sub_self)."""
    print(f"[1] Korselt identity:  n | a^n - a  for n = {n}")
    ok = all(divides_pow_sub_self(n, a) for a in range(-20, 50))
    print(f"    n | a^n - a holds for every a in [-20, 49]: {ok}")
    print()


def demo_carmichael_property(n: int = 561) -> None:
    """Verify n is pseudoprime to EVERY coprime base (Theorem: fermatPsp_of_coprime)."""
    print(f"[2] Carmichael property:  n | b^(n-1) - 1  for every coprime base, n = {n}")
    coprime_bases = [b for b in range(1, n) if gcd(n, b) == 1]
    fooled = sum(1 for b in coprime_bases if pow(b, n - 1, n) == 1)
    print(f"    coprime bases tested : {len(coprime_bases)}")
    print(f"    bases that pass test : {fooled}")
    print(f"    every coprime base fooled: {fooled == len(coprime_bases)}")
    print()


def demo_korselt_check(n: int = 561) -> None:
    """Show the finite Korselt checklist for n."""
    print(f"[3] Korselt checklist for n = {n} = "
          f"{' * '.join(map(str, distinct_prime_factors(n)))}")
    print(f"    composite      : {not is_prime(n)}")
    print(f"    squarefree     : {is_squarefree(n)}")
    for p in distinct_prime_factors(n):
        print(f"    (p-1)|(n-1)?   : p={p:>3}  ({p-1}) | ({n-1})  -> "
              f"{(n - 1) % (p - 1) == 0}")
    print(f"    IsKorselt(n)   : {is_korselt(n)}")
    print()


def demo_structure(limit: int = 10000) -> None:
    """Confirm structural theorems: odd, squarefree, >= 3 prime factors."""
    print(f"[4] Structural theorems verified for all Carmichael numbers < {limit}")
    carms = [n for n in range(3, limit, 2) if is_korselt(n)]
    print(f"    Carmichael numbers found: {carms}")
    all_odd = all(n % 2 == 1 for n in carms)
    all_sf = all(is_squarefree(n) for n in carms)
    all_3 = all(len(distinct_prime_factors(n)) >= 3 for n in carms)
    print(f"    all odd                 : {all_odd}")
    print(f"    all squarefree          : {all_sf}")
    print(f"    all have >= 3 primes    : {all_3}")
    print()


def demo_smallest(limit: int = 600) -> None:
    """Confirm 561 is the smallest Carmichael number, by definition and by Korselt."""
    print(f"[5] Smallest Carmichael number (brute search up to {limit})")
    smallest_def = next(n for n in range(2, limit) if is_carmichael(n))
    smallest_kor = next(n for n in range(2, limit) if is_korselt(n))
    print(f"    by definition (all coprime bases): {smallest_def}")
    print(f"    by Korselt's criterion           : {smallest_kor}")
    print(f"    agreement                        : {smallest_def == smallest_kor}")
    print()


def demo_fermat_test_failure(n: int = 561) -> None:
    """Show that NO single Fermat witness exposes a Carmichael number."""
    print(f"[6] Why the Fermat test fails on n = {n}")
    coprime_bases = [b for b in range(2, n) if gcd(n, b) == 1]
    liars = [b for b in coprime_bases if pow(b, n - 1, n) == 1]
    print(f"    coprime 'witnesses' that LIE (say 'prime'): {len(liars)} of "
          f"{len(coprime_bases)}")
    print(f"    -> no coprime Fermat witness can ever expose {n}.")
    print("    Contrast: an ordinary composite is exposed by most witnesses, e.g. 15:")
    bad15 = [b for b in range(2, 15) if gcd(15, b) == 1 and pow(b, 14, 15) != 1]
    print(f"       witnesses exposing 15 as composite: {bad15}")
    print()


def main() -> None:
    print("=" * 70)
    print(" Korselt's Criterion and Carmichael Numbers — Numerical Demonstration")
    print("=" * 70)
    print()
    demo_korselt_identity(561)
    demo_carmichael_property(561)
    demo_korselt_check(561)
    demo_structure(10000)
    demo_smallest(600)
    demo_fermat_test_failure(561)
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
