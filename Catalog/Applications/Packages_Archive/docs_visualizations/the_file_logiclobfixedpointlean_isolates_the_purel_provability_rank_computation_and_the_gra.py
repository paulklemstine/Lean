from typing import FrozenSet, List, Tuple

Prop = FrozenSet[int]


def box(s: Prop, n: int) -> Prop:
    return frozenset(k for k in range(n) if all(m in s for m in range(k)))


def provability_rank_spectrum(n: int, kmax: int) -> List[Tuple[int, Prop]]:
    """
    Return the consistency-strength chain box^k(BOT) for k = 0..kmax.

    By the rank theorem box^k(BOT) = {0, ..., k-1}, a strictly increasing
    chain of unprovable consistency statements (graded Godel II).
    """
    spectrum: List[Tuple[int, Prop]] = []
    cur: Prop = frozenset()                # BOT = empty set
    for k in range(kmax + 1):
        spectrum.append((k, cur))
        cur = box(cur, n)
    return spectrum
