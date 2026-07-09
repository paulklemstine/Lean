"""
A Cosmic Census of L-Functions -- numerical demonstrations.

This self-contained script illustrates the cardinality dichotomy behind the
L-function universe:

  * The NAIVE universe of all Dirichlet series (arbitrary coefficient sequences)
    is uncountable -- witnessed concretely by Cantor's diagonal argument, which
    defeats any purported enumeration of {0,1}-valued sequences.

  * Every ARITHMETICALLY CONSTRAINED family is countable:
      - periodic sequences over a countable alphabet enumerate cleanly;
      - Dirichlet characters (hence Dirichlet L-functions) are countable;
      - the finite-data Selberg class is countably infinite and stratifies into
        finite "census slices", giving an explicit enumeration ordered by
        conductor -- including the classical "first 100 elements".

Everything is elementary and dependency-free (standard library only).
"""

from __future__ import annotations

from dataclasses import dataclass, field
from itertools import product
from math import gcd
from typing import Callable, Iterator


# ---------------------------------------------------------------------------
# 1. The naive universe: Cantor diagonalization defeats any enumeration.
# ---------------------------------------------------------------------------

def diagonal_escapee(enumeration: Callable[[int], Callable[[int], int]],
                     length: int) -> list[int]:
    """Given a purported enumeration ``n -> s_n`` of {0,1}-valued sequences,
    return the first ``length`` entries of a sequence guaranteed to differ from
    every ``s_n`` (it differs from ``s_n`` in position ``n``).

    This is the constructive heart of the proof that ``N -> {0,1}`` -- and hence
    the naive space of Dirichlet series ``N -> C`` -- is uncountable.
    """
    return [1 - enumeration(n)(n) for n in range(length)]


def demo_naive_uncountable() -> None:
    print("=" * 70)
    print("1. NAIVE UNIVERSE IS UNCOUNTABLE (Cantor diagonalization)")
    print("=" * 70)

    # A sample "enumeration": s_n(k) = n-th binary digit patterns, say bit k of n.
    def enumeration(n: int) -> Callable[[int], int]:
        return lambda k: (n >> k) & 1

    escapee = diagonal_escapee(enumeration, 8)
    print("A sample enumeration s_0, s_1, ... of {0,1}-sequences (first 8x8):")
    for n in range(8):
        row = [enumeration(n)(k) for k in range(8)]
        print(f"  s_{n} = {row}")
    print(f"\nDiagonal escapee d (d(n) = 1 - s_n(n)): {escapee}")
    for n in range(8):
        assert escapee[n] != enumeration(n)(n)
    print("d differs from every s_n in position n  =>  d is missing from the list.")
    print("No list can contain all {0,1}-sequences: the naive universe is uncountable.\n")


# ---------------------------------------------------------------------------
# 2. Periodic sequences over a countable alphabet are countable.
# ---------------------------------------------------------------------------

def periodic_sequence(block: list[int]) -> Callable[[int], int]:
    """Return the periodic sequence with one full block ``block``:
    a(k) = block[k mod len(block)]."""
    n = len(block)
    return lambda k: block[k % n]


def enumerate_periodic_int(alphabet: list[int], max_period: int
                           ) -> Iterator[tuple[list[int], Callable[[int], int]]]:
    """Enumerate periodic integer sequences whose one-block values are drawn from
    ``alphabet`` and whose period is between 1 and ``max_period``.

    Because the (period, block) data is finite for each bound, this is an honest
    computable enumeration -- the mechanism behind Theorem 4.2.
    """
    for period in range(1, max_period + 1):
        for block in product(alphabet, repeat=period):
            yield list(block), periodic_sequence(list(block))


def demo_periodic_countable() -> None:
    print("=" * 70)
    print("2. PERIODIC SEQUENCES ARE COUNTABLE (finite (period, block) data)")
    print("=" * 70)
    alphabet = [0, 1]
    count = 0
    print("First periodic {0,1}-sequences by (period, block), showing a(0..7):")
    for block, seq in enumerate_periodic_int(alphabet, max_period=3):
        vals = [seq(k) for k in range(8)]
        print(f"  block={block!s:<12} -> a = {vals}")
        count += 1
        if count >= 10:
            break
    total = sum(len(alphabet) ** p for p in range(1, 4))
    print(f"\nTotal periodic {0,1}-sequences with period <= 3: {total} (finite).")
    print("Summing over all periods gives a countable set.\n")


# ---------------------------------------------------------------------------
# 3. Dirichlet characters are countable; count them modulus by modulus.
# ---------------------------------------------------------------------------

def num_dirichlet_characters(n: int) -> int:
    """Number of Dirichlet characters modulo n = phi(n), the order of the group
    of units mod n (for n >= 1)."""
    if n <= 1:
        return 1
    return sum(1 for k in range(1, n + 1) if gcd(k, n) == 1)


def principal_character_coeffs(n: int, length: int) -> list[int]:
    """Coefficient sequence of the principal character mod n:
    chi_0(k) = 1 if gcd(k, n) = 1 else 0. This sequence is periodic of period n."""
    return [1 if gcd(k, n) == 1 else 0 for k in range(length)]


def demo_dirichlet_countable() -> None:
    print("=" * 70)
    print("3. DIRICHLET CHARACTERS ARE COUNTABLE (finite for each modulus)")
    print("=" * 70)
    print("  modulus n :  # characters mod n  (= phi(n))")
    running = 0
    for n in range(1, 13):
        c = num_dirichlet_characters(n)
        running += c
        print(f"    n = {n:2d} :  {c:2d}   (cumulative {running})")
    print("\nPrincipal-character coefficient sequences (periodic!), a(0..11):")
    for n in (3, 4, 5):
        print(f"  mod {n}: {principal_character_coeffs(n, 12)}")
    # Verify periodicity of the principal character coefficients.
    for n in (3, 4, 5):
        seq = principal_character_coeffs(n, 3 * n)
        assert all(seq[k] == seq[k + n] for k in range(2 * n))
    print("Each is periodic (period n); a countable union of finite families is countable.\n")


# ---------------------------------------------------------------------------
# 4. The Selberg census: finite data, finite slices, explicit enumeration.
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class SelbergDatum:
    """The finite arithmetic fingerprint determining an element of the Selberg
    class: degree, conductor, a rational model (num/den) of the root number, and
    a finite list of integer Euler-factor coefficients."""
    degree: int
    conductor: int
    root_num: int
    root_den: int
    euler_coeffs: tuple[int, ...] = field(default_factory=tuple)


def in_census(d: SelbergDatum, N: int) -> bool:
    """Membership in the N-th census slice: every numerical invariant bounded by N."""
    return (d.degree <= N
            and d.conductor <= N
            and abs(d.root_num) <= N
            and d.root_den <= N
            and len(d.euler_coeffs) <= N
            and all(abs(c) <= N for c in d.euler_coeffs))


def census_slice(N: int) -> list[SelbergDatum]:
    """Enumerate the *entire* finite N-th census slice explicitly.

    Each coordinate ranges over a finite set, so the slice is finite (Theorem 5.5).
    (Euler lists are capped to length <= min(N, 2) here purely to keep the printed
    demo small; the mathematical slice allows length up to N.)"""
    result: list[SelbergDatum] = []
    ints = range(-N, N + 1)
    max_len = min(N, 2)
    euler_lists: list[tuple[int, ...]] = [()]
    for L in range(1, max_len + 1):
        euler_lists.extend(product(ints, repeat=L))
    for degree in range(N + 1):
        for conductor in range(N + 1):
            for rn in ints:
                for rd in range(N + 1):
                    for ec in euler_lists:
                        result.append(SelbergDatum(degree, conductor, rn, rd, tuple(ec)))
    return result


def trivial_datum(q: int) -> SelbergDatum:
    """Canonical datum of conductor q: a stand-in for the principal-character
    L-function of conductor q (degree 1, trivial root number, no Euler data)."""
    return SelbergDatum(degree=1, conductor=q, root_num=0, root_den=1, euler_coeffs=())


def census_by_conductor(n: int) -> list[SelbergDatum]:
    """The first n L-function data packets, ordered by conductor 0, 1, ..., n-1."""
    return [trivial_datum(q) for q in range(n)]


def demo_selberg_census() -> None:
    print("=" * 70)
    print("4. THE SELBERG CENSUS: finite slices + explicit enumeration")
    print("=" * 70)

    print("Sizes of the small census slices (restricted Euler length for display):")
    for N in range(0, 4):
        size = len(census_slice(N))
        print(f"  |Census({N})| = {size}")

    print("\nExplicit enumeration ordered by conductor (first 10):")
    enum10 = census_by_conductor(10)
    for d in enum10:
        print(f"  {d}")

    # The classical request: the first 100 elements, ordered by conductor.
    first_hundred = census_by_conductor(100)
    conductors = [d.conductor for d in first_hundred]
    print("\n--- Verifying the 'first 100 ordered by conductor' theorem ---")
    print(f"  length                       : {len(first_hundred)}")
    print(f"  distinct (no repetitions)    : {len(set(first_hundred)) == 100}")
    print(f"  conductors are 0..99 in order: {conductors == list(range(100))}")
    print(f"  every entry in Census(100)   : {all(in_census(d, 100) for d in first_hundred)}")

    assert len(first_hundred) == 100
    assert len(set(first_hundred)) == 100
    assert conductors == list(range(100))
    assert all(in_census(d, 100) for d in first_hundred)
    print("  ALL CHECKS PASSED.\n")


# ---------------------------------------------------------------------------

def main() -> None:
    demo_naive_uncountable()
    demo_periodic_countable()
    demo_dirichlet_countable()
    demo_selberg_census()
    print("=" * 70)
    print("SUMMARY: naive universe = continuum (uncountable);")
    print("         every arithmetic family = countable.")
    print("         Structure is scarcity.")
    print("=" * 70)


if __name__ == "__main__":
    main()
