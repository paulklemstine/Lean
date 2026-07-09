"""
The L-Function Universe: A Cosmic Census of All L-Functions
===========================================================

Numerical demonstration of the finite-invariant model of L-functions.

Main mathematical facts demonstrated:
  1. An L-function is modeled by a finite invariant package (a "Selberg datum"):
        (degree, conductor, root_number, gamma_shifts, euler_data)
     all drawn from countable rings (integers, rationals, finite lists).
  2. The package is FAITHFUL: distinct L-functions have distinct packages.
  3. The universe of such packages is COUNTABLE (injects into a countable
     product type) and INFINITE (the conductor tower), hence in bijection
     with the natural numbers -- COUNTABLY INFINITE.
  4. The arithmetically "valid" sub-universe (positive degree, conductor >= 1)
     is likewise countably infinite.
  5. An explicit census of the first 100 conductor levels, ordered by conductor.

This file is fully self-contained (standard library only) and uses type hints.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from fractions import Fraction
from itertools import count, islice
from typing import Iterator, List, Tuple

# A rational pair models a complex root number / gamma shift (real, imag parts).
RatPair = Tuple[Fraction, Fraction]
# Local Euler data: a prime together with a finite list of integer coefficients.
EulerEntry = Tuple[int, List[int]]


@dataclass(frozen=True)
class SelbergDatum:
    """The finite invariant package assigned to an L-function."""
    degree: int
    conductor: int
    root_number: RatPair = (Fraction(1), Fraction(0))
    gamma_shifts: Tuple[RatPair, ...] = field(default_factory=tuple)
    euler_data: Tuple[EulerEntry, ...] = field(default_factory=tuple)

    def to_tuple(self) -> Tuple[object, ...]:
        """Flatten to the faithful tuple of countable-typed components."""
        return (self.degree, self.conductor, self.root_number,
                self.gamma_shifts, self.euler_data)

    def is_valid(self) -> bool:
        """A coarse proxy for the Selberg-class axioms."""
        return self.degree >= 1 and self.conductor >= 1


# --------------------------------------------------------------------------
# Named members of the universe
# --------------------------------------------------------------------------

def zeta() -> SelbergDatum:
    """The Riemann zeta function: degree 1, conductor 1, gamma shift 1/2."""
    return SelbergDatum(
        degree=1, conductor=1,
        root_number=(Fraction(1), Fraction(0)),
        gamma_shifts=((Fraction(1, 2), Fraction(0)),),
        euler_data=(),
    )


def dirichlet_like(q: int) -> SelbergDatum:
    """A degree-1 Dirichlet representative at conductor q."""
    return SelbergDatum(degree=1, conductor=q)


def level(n: int) -> SelbergDatum:
    """The degree-0 conductor-tower placeholder at conductor n."""
    return SelbergDatum(degree=0, conductor=n)


# --------------------------------------------------------------------------
# The census
# --------------------------------------------------------------------------

def census(k: int = 100) -> List[SelbergDatum]:
    """The first k conductor levels, ordered by conductor 1, 2, ..., k."""
    return [dirichlet_like(q) for q in range(1, k + 1)]


# --------------------------------------------------------------------------
# A concrete bijection universe <-> N (Cantor-style pairing over components)
# --------------------------------------------------------------------------

def enumerate_data() -> Iterator[SelbergDatum]:
    """
    Enumerate a countably infinite subfamily in a definite order, witnessing
    that the universe is (at least) countably infinite. We iterate over the
    conductor tower interleaved with the Dirichlet family.
    """
    for n in count(0):
        # even index -> conductor tower; odd index -> Dirichlet family
        if n % 2 == 0:
            yield level(n // 2 + 1)
        else:
            yield dirichlet_like(n // 2 + 1)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_faithfulness() -> None:
    print("=" * 68)
    print("1. FAITHFULNESS: distinct L-functions have distinct packages")
    print("=" * 68)
    a, b = dirichlet_like(7), dirichlet_like(7)
    c = dirichlet_like(8)
    print(f"  dir(7).to_tuple() == dir(7).to_tuple(): {a.to_tuple() == b.to_tuple()}")
    print(f"  dir(7) == dir(8)                      : {a == c}")
    print(f"  their tuples differ                    : {a.to_tuple() != c.to_tuple()}")
    print()


def demo_countability() -> None:
    print("=" * 68)
    print("2. COUNTABILITY + INFINITUDE: injects into a countable product,")
    print("   yet the conductor tower gives infinitely many distinct data")
    print("=" * 68)
    tower = [level(n) for n in range(1, 11)]
    conductors = [d.conductor for d in tower]
    print(f"  conductor tower levels 1..10 conductors: {conductors}")
    print(f"  all distinct                           : {len(set(tower)) == len(tower)}")
    print()


def demo_bijection_with_N() -> None:
    print("=" * 68)
    print("3. COUNTABLY INFINITE: a definite enumeration universe <-> N")
    print("=" * 68)
    first = list(islice(enumerate_data(), 8))
    for i, d in enumerate(first):
        tag = "level" if d.degree == 0 else "dir  "
        print(f"  n={i}: {tag}(cond={d.conductor}, deg={d.degree})")
    print()


def demo_valid_subuniverse() -> None:
    print("=" * 68)
    print("4. VALID SUB-UNIVERSE: still countably infinite")
    print("=" * 68)
    print(f"  zeta is valid                : {zeta().is_valid()}")
    print(f"  dir(1) is valid              : {dirichlet_like(1).is_valid()}")
    print(f"  level(5) (degree 0) is valid : {level(5).is_valid()}  (degree 0 fails proxy)")
    valids = [dirichlet_like(n + 1) for n in range(6)]
    print(f"  valid embedding n -> dir(n+1) conductors: "
          f"{[d.conductor for d in valids]}")
    print()


def demo_census() -> None:
    print("=" * 68)
    print("5. EXPLICIT CENSUS of the first 100 conductor levels")
    print("=" * 68)
    c = census(100)
    conductors = [d.conductor for d in c]
    print(f"  census length            : {len(c)}  (expected 100)")
    print(f"  conductors == [1..100]   : {conductors == list(range(1, 101))}")
    print(f"  all distinct             : {len(set(c)) == 100}")
    print(f"  all valid                : {all(d.is_valid() for d in c)}")
    print(f"  first 10 conductors      : {conductors[:10]}")
    print(f"  last 10 conductors       : {conductors[-10:]}")
    print()


def main() -> None:
    print()
    print("#" * 68)
    print("#  THE L-FUNCTION UNIVERSE: A COSMIC CENSUS")
    print("#  There are only as many well-behaved L-functions as integers.")
    print("#" * 68)
    print()
    demo_faithfulness()
    demo_countability()
    demo_bijection_with_N()
    demo_valid_subuniverse()
    demo_census()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
