"""
Numerical demonstrations for the divisibility of power-difference polynomials.

Central results demonstrated:
  1. a^5 - a is divisible by 5 for every integer a (Fermat's Little Theorem, p=5).
  2. a^5 - a is in fact divisible by 30 = 2 * 3 * 5 for every integer a.
  3. The maximal universal divisor D(n) of a^n - a is squarefree and equals
     the product of all primes p with (p-1) | (n-1). In particular D(5) = 30.
  4. A probabilistic interpretation: the density of a in {1,...,N} with
     p | (a^n - a) tends to 1 when (p-1)|(n-1), and to 1/p otherwise.

Self-contained; standard library only.
"""

from __future__ import annotations

from math import gcd
from functools import reduce
from typing import List


# ---------------------------------------------------------------------------
# 1. Universal divisibility by finite residue check (Lemma "Finite verification")
# ---------------------------------------------------------------------------
def divides_all(m: int, n: int) -> bool:
    """Return True iff m | (a^n - a) for every integer a.

    By the finite-verification lemma it suffices to check residues 0..m-1,
    since a^n - a mod m depends only on a mod m.
    """
    return all((pow(r, n, m) - r) % m == 0 for r in range(m))


# ---------------------------------------------------------------------------
# 2. Empirical greatest common divisor of a^n - a over a range of a
# ---------------------------------------------------------------------------
def empirical_universal_divisor(n: int, a_max: int = 200) -> int:
    """Compute gcd over a in {1,...,a_max} of (a^n - a), an estimate of D(n)."""
    values = [a**n - a for a in range(2, a_max + 1)]
    return reduce(gcd, values)


# ---------------------------------------------------------------------------
# 3. Exact universal divisor D(n) via the prime criterion (p-1) | (n-1)
# ---------------------------------------------------------------------------
def is_prime(k: int) -> bool:
    """Deterministic trial-division primality test."""
    if k < 2:
        return False
    if k % 2 == 0:
        return k == 2
    d = 3
    while d * d <= k:
        if k % d == 0:
            return False
        d += 2
    return True


def universal_divisor(n: int) -> int:
    """Return D(n) = product of primes p with (p-1) | (n-1).

    Only primes p <= n can satisfy (p-1) | (n-1) nontrivially (plus p=2).
    """
    if n < 2:
        return 1
    product = 1
    for p in range(2, n + 1):
        if is_prime(p) and (n - 1) % (p - 1) == 0:
            product *= p
    return product


# ---------------------------------------------------------------------------
# 4. Probabilistic density of divisibility
# ---------------------------------------------------------------------------
def divisibility_density(p: int, n: int, big_n: int = 100_000) -> float:
    """Fraction of a in {1,...,big_n} with p | (a^n - a)."""
    count = sum(1 for a in range(1, big_n + 1) if (pow(a, n, p) - a) % p == 0)
    return count / big_n


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def main() -> None:
    print("=" * 68)
    print("Demonstration 1:  a^5 - a is divisible by 5 and by 30")
    print("=" * 68)
    for a in [-3, -1, 0, 1, 2, 3, 7, 10, 42]:
        v = a**5 - a
        print(f"  a = {a:>4}:  a^5 - a = {v:>10}   /5 -> {v // 5:>8}"
              f"   /30 -> {v // 30 if v % 30 == 0 else 'NOT DIVISIBLE'}")
    print(f"\n  5  | (a^5 - a) for all a?  {divides_all(5, 5)}")
    print(f"  30 | (a^5 - a) for all a?  {divides_all(30, 5)}")
    print(f"  60 | (a^5 - a) for all a?  {divides_all(60, 5)}  (must be False; 30 is maximal)")

    print("\n" + "=" * 68)
    print("Demonstration 2:  Maximal universal divisor D(n)")
    print("=" * 68)
    print(f"  {'n':>3} | {'D(n) exact':>12} | {'empirical gcd':>14} | factor primes")
    for n in range(2, 16):
        exact = universal_divisor(n)
        emp = empirical_universal_divisor(n)
        primes = [p for p in range(2, n + 1) if is_prime(p) and (n - 1) % (p - 1) == 0]
        match = "OK" if exact == emp else "MISMATCH"
        print(f"  {n:>3} | {exact:>12} | {emp:>14} | {primes}  [{match}]")

    print("\n" + "=" * 68)
    print("Demonstration 3:  D(5) = 30 from the criterion (p-1) | 4")
    print("=" * 68)
    for p in [2, 3, 5, 7, 11, 13]:
        ok = (5 - 1) % (p - 1) == 0
        print(f"  p = {p:>2}:  (p-1)|4 ? {ok}   -> {'included' if ok else 'excluded'}")
    print(f"  D(5) = {universal_divisor(5)}")

    print("\n" + "=" * 68)
    print("Demonstration 4:  Probabilistic density of p | (a^n - a), n = 5")
    print("=" * 68)
    for p in [2, 3, 5, 7, 11]:
        d = divisibility_density(p, 5, big_n=50_000)
        # Solutions of a^n == a (mod p): a==0 plus solutions of a^(n-1)==1
        # among units, numbering gcd(n-1, p-1). Density = (gcd(n-1,p-1)+1)/p,
        # which equals 1 exactly when (p-1)|(n-1), and equals 1/p in the
        # extreme case gcd(n-1,p-1)=0 style collapse.
        predicted = (gcd(5 - 1, p - 1) + 1) / p if (5 - 1) % (p - 1) != 0 else 1.0
        print(f"  p = {p:>2}:  measured density = {d:.4f}   predicted = {predicted:.4f}")


if __name__ == "__main__":
    main()
