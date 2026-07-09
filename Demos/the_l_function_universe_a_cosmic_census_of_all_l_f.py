"""
A Census of the Selberg Class: The L-Function Universe is Countable
===================================================================

This self-contained script demonstrates, numerically and constructively, the
central results of the census of "natural" L-functions:

  1. Each L-function is pinned down by a FINITE arithmetic signature
     (degree, conductor, gamma-factor shifts, and local Euler data at finitely
     many primes).
  2. The space of signatures is COUNTABLE -- indeed countably infinite -- so it
     is in bijection with the natural numbers. We realize this bijection with an
     explicit Goedel-style encoding.
  3. Concrete families embed into the census: the Riemann zeta function, the
     Dirichlet L-functions (finitely many characters per modulus), and the
     elliptic curves over the rationals (five rational Weierstrass coefficients).
  4. Boundaries: relaxing finiteness (a free binary choice at every prime, or a
     continuum of real j-invariants) escapes countability. We illustrate the
     Cantor obstruction numerically.

Everything runs with the Python standard library only.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from fractions import Fraction
from itertools import count, islice
from math import gcd
from typing import Iterable, Iterator


# ---------------------------------------------------------------------------
# 1. The arithmetic signature
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class SelbergSignature:
    """The finite data determining a Selberg-class L-function.

    Attributes:
        degree:        dimension of the associated representation.
        conductor:     arithmetic modulus of the functional equation.
        gamma_shifts:  rational model of the gamma-factor shifts (finite tuple).
        euler_factors: local Euler data as a finite tuple of
                       (prime, coefficient-tuple) pairs.
    """
    degree: int
    conductor: int
    gamma_shifts: tuple[Fraction, ...] = ()
    euler_factors: tuple[tuple[int, tuple[Fraction, ...]], ...] = ()


def zeta_signature() -> SelbergSignature:
    """Signature of the Riemann zeta function: degree 1, conductor 1."""
    return SelbergSignature(degree=1, conductor=1, gamma_shifts=(Fraction(0),))


def principal_signature(conductor: int) -> SelbergSignature:
    """The principal L-function of a given conductor (the census enumeration)."""
    return SelbergSignature(degree=1, conductor=conductor,
                            gamma_shifts=(Fraction(0),))


# ---------------------------------------------------------------------------
# 2. Countability: an explicit bijection signatures <-> natural numbers
# ---------------------------------------------------------------------------

def cantor_pair(a: int, b: int) -> int:
    """Bijection N x N -> N (Cantor pairing)."""
    s = a + b
    return s * (s + 1) // 2 + b


def encode_nat(n: int) -> int:
    """Identity encoding of a natural number (kept for symmetry)."""
    return n


def encode_int(z: int) -> int:
    """Bijection Z -> N: 0,-1,1,-2,2,... <-> 0,1,2,3,4,..."""
    return 2 * z if z >= 0 else -2 * z - 1


def encode_fraction(q: Fraction) -> int:
    """Bijection Q -> N via (sign-encoded numerator, denominator)."""
    return cantor_pair(encode_int(q.numerator), q.denominator)


def encode_list(items: Iterable[int]) -> int:
    """Bijection (finite lists over N) -> N via iterated pairing.

    An empty list maps to 0; a nonempty list [x, *rest] maps to
    1 + pair(x, encode_list(rest)), guaranteeing injectivity.
    """
    acc = 0
    for x in reversed(list(items)):
        acc = 1 + cantor_pair(x, acc)
    return acc


def encode_signature(sig: SelbergSignature) -> int:
    """A concrete injection SelbergSignature -> N.

    This *witnesses* the countability theorem: distinct signatures receive
    distinct natural numbers, so the whole space injects into N.
    """
    g = encode_list(encode_fraction(x) for x in sig.gamma_shifts)
    e = encode_list(
        cantor_pair(p, encode_list(encode_fraction(c) for c in coeffs))
        for (p, coeffs) in sig.euler_factors
    )
    return cantor_pair(
        cantor_pair(encode_nat(sig.degree), encode_nat(sig.conductor)),
        cantor_pair(g, e),
    )


# ---------------------------------------------------------------------------
# 3. Populating the census
# ---------------------------------------------------------------------------

def census_by_conductor(limit: int) -> list[SelbergSignature]:
    """The first `limit` principal L-functions ordered by conductor 1..limit."""
    return [principal_signature(n) for n in range(1, limit + 1)]


def euler_totient(n: int) -> int:
    """Euler's totient phi(n): counts the Dirichlet characters modulo n."""
    result, m, p = n, n, 2
    while p * p <= m:
        if m % p == 0:
            while m % p == 0:
                m //= p
            result -= result // p
        p += 1
    if m > 1:
        result -= result // m
    return result


def dirichlet_character_count(max_modulus: int) -> int:
    """Total number of Dirichlet characters over all moduli 1..max_modulus.

    Each count phi(N) is finite, so the sum -- a partial census of the Dirichlet
    family -- is finite for every bound, confirming countability of the union.
    """
    return sum(euler_totient(n) for n in range(1, max_modulus + 1))


@dataclass(frozen=True)
class WeierstrassCurve:
    """An elliptic curve over Q given by five rational coefficients."""
    a1: Fraction
    a2: Fraction
    a3: Fraction
    a4: Fraction
    a6: Fraction


def enumerate_rational_curves(bound: int) -> Iterator[WeierstrassCurve]:
    """Enumerate rational Weierstrass curves with small integer coefficients.

    Demonstrates the injection into Q^5: the family is a subset of a countable
    set, hence countable. (We use integer coefficients for a finite illustration.)
    """
    rng = range(-bound, bound + 1)
    for a1 in rng:
        for a2 in rng:
            for a3 in rng:
                for a4 in rng:
                    for a6 in rng:
                        yield WeierstrassCurve(
                            Fraction(a1), Fraction(a2), Fraction(a3),
                            Fraction(a4), Fraction(a6))


# ---------------------------------------------------------------------------
# 4. The boundary: Cantor's diagonal (uncountability obstruction)
# ---------------------------------------------------------------------------

def cantor_diagonal(sequences: list[list[int]]) -> list[int]:
    """Given a finite list of binary sequences, produce one not in the list.

    A miniature of the argument that {primes} -> {0,1} (or N -> {0,1}) is
    uncountable: no enumeration can capture every binary sequence.
    """
    n = len(sequences)
    return [1 - sequences[i][i] for i in range(n)]


# ---------------------------------------------------------------------------
# 5. Driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 68)
    print("  A CENSUS OF THE SELBERG CLASS -- NUMERICAL DEMONSTRATION")
    print("=" * 68)

    print("\n[1] The Riemann zeta function's signature")
    z = zeta_signature()
    print(f"    degree={z.degree}, conductor={z.conductor}, "
          f"gamma_shifts={tuple(str(x) for x in z.gamma_shifts)}")
    print(f"    Goedel code in N: {encode_signature(z)}")

    print("\n[2] The census ordered by conductor (first 20 addresses)")
    first20 = census_by_conductor(20)
    print("    conductors:", [s.conductor for s in first20])
    print("    length of first-100 census:", len(census_by_conductor(100)))

    print("\n[3] Countability witness: distinct signatures -> distinct codes")
    sample = census_by_conductor(10)
    codes = [encode_signature(s) for s in sample]
    print("    codes:", codes)
    print("    all distinct:", len(set(codes)) == len(codes))

    print("\n[4] Dirichlet family: finitely many characters per modulus")
    for N in (1, 2, 3, 5, 12, 100):
        print(f"    #characters mod {N:>3} = phi({N}) = {euler_totient(N)}")
    print(f"    total #characters for moduli 1..100 = "
          f"{dirichlet_character_count(100)}  (finite => countable union)")

    print("\n[5] Rational elliptic curves inject into Q^5 (countable)")
    curves = list(islice(enumerate_rational_curves(1), 5))
    for c in curves:
        print(f"    E: (a1,a2,a3,a4,a6) = "
              f"({c.a1},{c.a2},{c.a3},{c.a4},{c.a6})")
    total = sum(1 for _ in enumerate_rational_curves(1))
    print(f"    #curves with coeffs in [-1,1] = {total} = 3^5 (finite slice)")

    print("\n[6] Boundary (Cantor): no finite list captures all binary seqs")
    listing = [[(i >> k) & 1 for k in range(4)] for i in range(4)]
    missing = cantor_diagonal(listing)
    print("    enumerated:", listing)
    print("    diagonal (not in list):", missing)
    print("    => {primes} -> {0,1} is uncountable: finiteness is essential")

    print("\n" + "=" * 68)
    print("  CONCLUSION: the census has size aleph_0 -- countably infinite.")
    print("=" * 68)


if __name__ == "__main__":
    main()
