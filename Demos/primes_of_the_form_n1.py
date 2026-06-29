"""Numerical demonstrations of the local arithmetic of the sequence n^2 + 1.

This script empirically exercises the formally verified theorems on primes of the
form n^2 + 1:

  * solvability criterion:  x^2 + 1 = 0 (mod p) is solvable  <=>  p % 4 != 3
  * exact solution counts:  2 solutions if p % 4 != 3 (odd p), 0 if p % 4 == 3
  * Legendre symbol form:   (-1 / p) = 1 <=> p % 4 == 1,  = -1 <=> p % 4 == 3
  * the Great Filter:       no prime p % 4 == 3 ever divides n^2 + 1
  * zero count:             #{ n < X : some prime p%4==3 divides n^2+1 } == 0
  * local density factor:   nu_p(n) <= 2 at odd primes, nu_p(n) = 0 if p%4==3

Everything is self-contained: no external dependencies beyond the standard
library. Run with:  python demo.py
"""

from __future__ import annotations

from math import gcd, isqrt
from typing import List


# --------------------------------------------------------------------------- #
# Elementary number-theory helpers (all inlined, no dependencies)
# --------------------------------------------------------------------------- #
def is_prime(p: int) -> bool:
    """Deterministic trial-division primality test for modest integers."""
    if p < 2:
        return False
    if p % 2 == 0:
        return p == 2
    for d in range(3, isqrt(p) + 1, 2):
        if p % d == 0:
            return False
    return True


def primes_up_to(limit: int) -> List[int]:
    """All primes p with p <= limit, via the sieve of Eratosthenes."""
    if limit < 2:
        return []
    sieve = bytearray([1]) * (limit + 1)
    sieve[0] = sieve[1] = 0
    for i in range(2, isqrt(limit) + 1):
        if sieve[i]:
            sieve[i * i : limit + 1 : i] = bytearray(len(range(i * i, limit + 1, i)))
    return [i for i in range(2, limit + 1) if sieve[i]]


def sol_set(p: int) -> List[int]:
    """Solutions x in {0,...,p-1} of x^2 + 1 == 0 (mod p)  (mirrors `solSet`)."""
    return [x for x in range(p) if (x * x + 1) % p == 0]


def legendre_symbol(a: int, p: int) -> int:
    """Legendre symbol (a / p) for odd prime p, via Euler's criterion."""
    a %= p
    if a == 0:
        return 0
    ls = pow(a, (p - 1) // 2, p)
    return -1 if ls == p - 1 else ls  # ls is 1 or p-1


def nu(p: int, n: int) -> int:
    """Local density factor nu_p(n): roots of x^2+1=0 (mod p) coprime to n."""
    return sum(1 for x in sol_set(p) if gcd(x, n) == 1)


# --------------------------------------------------------------------------- #
# Demonstration 1: solvability criterion and exact solution counts
# --------------------------------------------------------------------------- #
def demo_solvability_and_counts(limit: int = 100) -> None:
    print("=" * 70)
    print("DEMO 1: solvability criterion + exact solution counts")
    print("  Theorem: x^2+1=0 (mod p) solvable  <=>  p % 4 != 3")
    print("  Theorem: #solutions = 2 if p%4!=3 (odd p), 0 if p%4==3")
    print("=" * 70)
    print(f"{'p':>4} | {'p%4':>3} | {'#sols':>5} | {'roots':>14} | predicted")
    print("-" * 60)
    for p in primes_up_to(limit):
        roots = sol_set(p)
        if p == 2:
            predicted = 1
        elif p % 4 == 3:
            predicted = 0
        else:
            predicted = 2
        ok = "OK" if len(roots) == predicted else "*** MISMATCH ***"
        rs = ",".join(map(str, roots)) if roots else "-"
        print(f"{p:>4} | {p % 4:>3} | {len(roots):>5} | {rs:>14} | {predicted} {ok}")
        assert len(roots) == predicted, (p, roots, predicted)
    print("All solution counts match the theorem.\n")


# --------------------------------------------------------------------------- #
# Demonstration 2: Legendre symbol formulation
# --------------------------------------------------------------------------- #
def demo_legendre(limit: int = 100) -> None:
    print("=" * 70)
    print("DEMO 2: Legendre symbol (-1 / p)")
    print("  Theorem: (-1/p)=1 <=> p%4==1 ;  (-1/p)=-1 <=> p%4==3")
    print("=" * 70)
    print(f"{'p':>4} | {'p%4':>3} | {'(-1/p)':>7} | predicted")
    print("-" * 40)
    for p in primes_up_to(limit):
        if p == 2:
            continue
        ls = legendre_symbol(-1, p)
        predicted = 1 if p % 4 == 1 else -1
        ok = "OK" if ls == predicted else "*** MISMATCH ***"
        print(f"{p:>4} | {p % 4:>3} | {ls:>7} | {predicted:>+2} {ok}")
        assert ls == predicted, (p, ls, predicted)
    print("All Legendre symbols match the theorem.\n")


# --------------------------------------------------------------------------- #
# Demonstration 3: the Great Filter and the exact zero count
# --------------------------------------------------------------------------- #
def demo_great_filter(X: int = 2000) -> None:
    print("=" * 70)
    print("DEMO 3: the Great Filter + exact zero count")
    print("  Theorem: no prime p%4==3 ever divides n^2+1")
    print("  Theorem: #{ n < X : some prime p%4==3 divides n^2+1 } == 0")
    print("=" * 70)
    bad_primes = [p for p in primes_up_to(200) if p % 4 == 3]
    print(f"banned primes (p%4==3) up to 200: {bad_primes[:12]} ...")
    bad_count = 0
    for n in range(X):
        v = n * n + 1
        for p in bad_primes:
            if v % p == 0:
                bad_count += 1
                print(f"  *** COUNTEREXAMPLE: {p} | {n}^2+1 ***")
                break
    print(f"n ranged over 0..{X-1}; values n^2+1 with a banned prime factor: {bad_count}")
    assert bad_count == 0
    print("Exactly zero, as the theorem predicts.\n")


# --------------------------------------------------------------------------- #
# Demonstration 4: factorizations live only on 2 and primes p%4==1
# --------------------------------------------------------------------------- #
def demo_factor_structure(samples: int = 16) -> None:
    print("=" * 70)
    print("DEMO 4: prime factors of n^2+1 are only 2 and primes p%4==1")
    print("=" * 70)

    def factorize(m: int) -> List[int]:
        facs: List[int] = []
        d = 2
        while d * d <= m:
            while m % d == 0:
                facs.append(d)
                m //= d
            d += 1
        if m > 1:
            facs.append(m)
        return facs

    print(f"{'n':>3} | {'n^2+1':>8} | factorization | all factors 2 or 1 mod 4?")
    print("-" * 60)
    for n in range(1, samples + 1):
        v = n * n + 1
        facs = factorize(v)
        good = all(p == 2 or p % 4 == 1 for p in facs)
        fstr = " * ".join(map(str, facs))
        print(f"{n:>3} | {v:>8} | {fstr:<20} | {'yes' if good else 'NO'}")
        assert good, (n, facs)
    print("Every factor is 2 or congruent to 1 mod 4.\n")


# --------------------------------------------------------------------------- #
# Demonstration 5: local density factor nu_p(n)
# --------------------------------------------------------------------------- #
def demo_nu(limit: int = 60) -> None:
    print("=" * 70)
    print("DEMO 5: local density factor nu_p(n)")
    print("  Theorem: nu_p(n) <= 2 at odd primes ;  nu_p(n) = 0 if p%4==3")
    print("=" * 70)
    test_ns = [1, 6, 15, 35, 210]
    header = f"{'p':>4} | {'p%4':>3} | " + " | ".join(f"nu(.,{n})" for n in test_ns)
    print(header)
    print("-" * len(header))
    for p in primes_up_to(limit):
        if p == 2:
            continue
        vals = [nu(p, n) for n in test_ns]
        for n, v in zip(test_ns, vals):
            assert v <= 2
            if p % 4 == 3:
                assert v == 0
        cells = " | ".join(f"{v:>7}" for v in vals)
        print(f"{p:>4} | {p % 4:>3} | {cells}")
    print("All nu values satisfy nu_p(n) <= 2, and vanish when p%4==3.\n")


# --------------------------------------------------------------------------- #
# Demonstration 6: Landau primes and the Friedlander-Iwaniec nesting
# --------------------------------------------------------------------------- #
def demo_landau_and_fi(limit: int = 60) -> None:
    print("=" * 70)
    print("DEMO 6: Landau primes n^2+1, and the slice b=1 of a^2+b^4")
    print("=" * 70)
    landau = [(n, n * n + 1) for n in range(1, limit + 1) if is_prime(n * n + 1)]
    print("Primes of the form n^2+1 (Landau primes):")
    print("  " + ", ".join(f"{n}^2+1={v}" for n, v in landau))
    # b = 1 collapses a^2 + b^4 to a^2 + 1, so every Landau prime is an a^2+b^4 prime.
    for n, v in landau:
        assert v == n * n + 1 ** 4  # (a,b) = (n,1)
    print("\nEach Landau prime n^2+1 equals a^2+b^4 with (a,b)=(n,1):")
    print("  {p = n^2+1} is a subset of {p = a^2+b^4}.")
    # A genuine a^2+b^4 prime with b>=2 that is not a Landau prime:
    examples = []
    for a in range(1, 40):
        for b in range(2, 6):
            v = a * a + b ** 4
            if is_prime(v) and not (isqrt(v - 1) ** 2 == v - 1):
                examples.append((a, b, v))
    print("\nSome a^2+b^4 primes with b>=2 that are NOT of the form n^2+1:")
    for a, b, v in examples[:6]:
        print(f"  {a}^2+{b}^4 = {v}  (prime, and {v}-1={v-1} is not a perfect square)")
    print()


def main() -> None:
    demo_solvability_and_counts()
    demo_legendre()
    demo_great_filter()
    demo_factor_structure()
    demo_nu()
    demo_landau_and_fi()
    print("All demonstrations completed; every theorem held on all tested inputs.")


if __name__ == "__main__":
    main()
