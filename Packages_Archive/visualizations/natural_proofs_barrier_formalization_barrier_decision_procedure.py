from __future__ import annotations

from fractions import Fraction
from typing import Callable, List, Sequence, Tuple

TruthTable = Tuple[int, ...]
Property = Callable[[TruthTable], bool]


def useful_against(seeds: Sequence[int], g: Callable[[int], TruthTable],
                   p: Property) -> bool:
    """UsefulAgainst(P, g): P rejects every output of the family g."""
    return all(not p(g(s)) for s in seeds)


def useful_against_class(universe: Sequence[TruthTable], p: Property,
                         c: Property) -> bool:
    """UsefulAgainstClass(P, C): no function passing P lies in class C."""
    return all((not c(f)) for f in universe if p(f))


def bridge_useful(universe: Sequence[TruthTable], seeds: Sequence[int],
                  g: Callable[[int], TruthTable], p: Property,
                  c: Property) -> bool:
    """Class-to-family bridge: range(g) in C and useful-vs-C => useful-vs-g."""
    range_in_class: bool = all(c(g(s)) for s in seeds)
    if range_in_class and useful_against_class(universe, p, c):
        return useful_against(seeds, g, p)
    return useful_against(seeds, g, p)


def barrier_holds(universe: Sequence[TruthTable], seeds: Sequence[int],
                  g: Callable[[int], TruthTable], p: Property,
                  delta: Fraction) -> bool:
    """Return True iff a delta-secure family is IMPOSSIBLE given a large,
    useful property P. Concretely: if P is large (randomProb >= delta) and
    useful against g, then advantage >= delta, so g is NOT delta-secure.
    """
    from fractions import Fraction as _F
    rp = _F(sum(1 for f in universe if p(f)), len(universe))
    pp = _F(sum(1 for s in seeds if p(g(s))), len(seeds))
    adv = abs(rp - pp)
    large = rp >= delta
    useful = useful_against(seeds, g, p)
    if large and useful:
        return adv >= delta  # distinguisher exists -> no delta-security
    return True
