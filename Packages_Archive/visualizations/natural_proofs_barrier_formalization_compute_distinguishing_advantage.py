from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Callable, List, Sequence, Tuple

TruthTable = Tuple[int, ...]
Property = Callable[[TruthTable], bool]


def all_truth_tables(n: int) -> List[TruthTable]:
    """Enumerate every Boolean function on n inputs as a 2**n-bit tuple."""
    return [bits for bits in product((0, 1), repeat=2 ** n)]


def random_prob(universe: Sequence[TruthTable], p: Property) -> Fraction:
    """Uniform acceptance probability |{f : P f}| / |F|."""
    return Fraction(sum(1 for f in universe if p(f)), len(universe))


def pseudo_prob(seeds: Sequence[int], g: Callable[[int], TruthTable],
                p: Property) -> Fraction:
    """Pseudorandom acceptance probability |{s : P(g s)}| / |S|."""
    return Fraction(sum(1 for s in seeds if p(g(s))), len(seeds))


def advantage(universe: Sequence[TruthTable], seeds: Sequence[int],
              g: Callable[[int], TruthTable], p: Property) -> Fraction:
    """Distinguishing advantage |randomProb - pseudoProb|."""
    return abs(random_prob(universe, p) - pseudo_prob(seeds, g, p))


def certified_lower_bound(universe: Sequence[TruthTable], seeds: Sequence[int],
                          g: Callable[[int], TruthTable], p: Property
                          ) -> Tuple[Fraction, Fraction, bool]:
    """Return (delta, eps, ok) where ok asserts advantage >= delta - eps.

    delta = randomProb(P) is the largeness parameter and eps = pseudoProb(P, g)
    is the realized leak; the natural-proofs theorem guarantees ok is True.
    """
    delta: Fraction = random_prob(universe, p)
    eps: Fraction = pseudo_prob(seeds, g, p)
    adv: Fraction = advantage(universe, seeds, g, p)
    return delta, eps, adv >= delta - eps
