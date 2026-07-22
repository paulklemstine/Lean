from itertools import combinations
from math import comb
from typing import FrozenSet, List


def _comparable(s: FrozenSet[int], t: FrozenSet[int]) -> bool:
    return s <= t or t <= s


def is_chain(family: List[FrozenSet[int]]) -> bool:
    return all(_comparable(a, b) for a, b in combinations(family, 2))


def verify_cover(n: int, chains: List[List[FrozenSet[int]]]) -> bool:
    """Check each family member is a chain, the union is all of 2^[n],
    and the number of chains meets the lower bound C(n, floor(n/2))."""
    if not all(is_chain(c) for c in chains):
        return False
    covered = {s for c in chains for s in c}
    if len(covered) != 2 ** n:
        return False
    return len(chains) >= comb(n, n // 2)
