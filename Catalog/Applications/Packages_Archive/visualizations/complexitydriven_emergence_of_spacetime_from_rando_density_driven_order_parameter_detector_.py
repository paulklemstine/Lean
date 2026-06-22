from typing import Optional, Sequence, FrozenSet, List, TypeVar

T = TypeVar("T")
Family = List[FrozenSet[T]]


def member_count(a: T, F: Family) -> int:
    return sum(1 for s in F if a in s)


def find_majority_element(ground: Sequence[T], F: Family) -> Optional[T]:
    """Theorem B as an algorithm: if mean configuration size >= |ground|/2,
    return a site occupied in at least half the configurations.

    Correctness is the contrapositive double-counting argument; the search is
    guaranteed to succeed under the density hypothesis.
    """
    if not F:
        return None
    if 2 * sum(len(s) for s in F) < len(F) * len(ground):
        return None  # density hypothesis fails; no guarantee
    for a in ground:
        if 2 * member_count(a, F) >= len(F):
            return a
    return None  # unreachable when the hypothesis holds
