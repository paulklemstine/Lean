"""
The Barrier Witness Search algorithm.

Given a decidable property P that is delta-large and a generator G that is
delta-pseudorandom against P, the natural proofs barrier guarantees the
existence of a seed s with P(G(s)) -- an "easy" function that the property
nonetheless accepts, certifying that P is useless as a hardness criterion.

This algorithm constructively produces such a witness, and verifies the two
governing inequalities (largeness and pseudorandomness) along the way using
exact rational arithmetic.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Callable, List, Optional, Sequence, Tuple

TruthTable = Tuple[bool, ...]
Property = Callable[[TruthTable], bool]
Generator = Callable[[int], TruthTable]


def acc_random(P: Property, m: int) -> Fraction:
    """Density of P over all 2**m truth tables (exact rational)."""
    total = 0
    count = 0
    for bits in product([False, True], repeat=m):
        total += 1
        if P(tuple(bits)):
            count += 1
    return Fraction(count, total)


def acc_gen(G: Generator, P: Property, seeds: Sequence[int]) -> Fraction:
    """Generator acceptance of P over the seed set (exact rational)."""
    count = sum(1 for s in seeds if P(G(s)))
    return Fraction(count, len(seeds))


def barrier_witness_search(
    G: Generator,
    P: Property,
    seeds: Sequence[int],
    m: int,
    delta: Fraction,
) -> Optional[int]:
    """
    Return a seed s with P(G(s)) when the barrier hypotheses hold, else None.

    Preconditions checked:
      * delta-largeness:        delta <= accRandom(P)
      * delta-pseudorandomness: accRandom(P) - accGen(G, P) < delta

    Complexity: O(2**m) to compute the density (the dominant term), plus O(|S|)
    to scan the seeds. The search itself is O(|S|) evaluations of P o G.
    """
    density = acc_random(P, m)
    if not (delta <= density):
        raise ValueError("hypothesis failed: P is not delta-large")
    advantage = density - acc_gen(G, P, seeds)
    if not (advantage < delta):
        raise ValueError("hypothesis failed: G is not delta-pseudorandom against P")

    # Guaranteed to succeed by the barrier theorem.
    for s in seeds:
        if P(G(s)):
            return s
    return None  # unreachable when the hypotheses hold


def demo() -> None:
    m = 3
    seeds = list(range(8))
    tables = [tuple(b) for b in product([False, True], repeat=m)]

    G: Generator = lambda s: tables[s]          # image = entire space
    P: Property = lambda T: any(T)              # "not all-false", density 7/8
    delta = Fraction(1, 2)

    witness = barrier_witness_search(G, P, seeds, m, delta)
    print(f"density            = {acc_random(P, m)}")
    print(f"advantage          = {acc_random(P, m) - acc_gen(G, P, seeds)}")
    print(f"barrier witness s  = {witness}, G(s) = {G(witness)}, "
          f"P(G(s)) = {P(G(witness))}")


if __name__ == "__main__":
    demo()
