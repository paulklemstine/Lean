from __future__ import annotations
from itertools import combinations
from typing import FrozenSet, List

Set = FrozenSet[int]


def is_sunflower(a: Set, b: Set, c: Set) -> bool:
    """Three distinct sets form a sunflower iff pairwise intersections are equal."""
    if a == b or a == c or b == c:
        return False
    return (a & b) == (a & c) == (b & c)


def creates_sunflower(family: List[Set], new: Set) -> bool:
    """Does adding `new` to `family` create a 3-sunflower?"""
    for a, b in combinations(family, 2):
        if is_sunflower(a, b, new):
            return True
    return False


def greedy_uniform_family(n: int, k: int) -> List[Set]:
    """
    Greedily construct a maximal (by inclusion) uniform sunflower-free family of
    k-subsets of [n], scanning subsets in lexicographic order.
    """
    family: List[Set] = []
    for combo in combinations(range(n), k):
        s = frozenset(combo)
        if not creates_sunflower(family, s):
            family.append(s)
    return family


def largest_middle_layer_family(n: int) -> List[Set]:
    """
    Build a greedy sunflower-free family on the middle-third layer k = round(n/3),
    where the exponential base 3/2^(2/3) = 2^H(1/3) is attained.
    """
    k = max(0, round(n / 3))
    return greedy_uniform_family(n, k)
