from math import comb
from typing import FrozenSet, Sequence, Set, Tuple


def shadow(family: Sequence[FrozenSet[int]]) -> Set[FrozenSet[int]]:
    out: Set[FrozenSet[int]] = set()
    for s in family:
        for x in s:
            out.add(s - {x})
    return out


def largest_k_with_binom_le(m: int, r: int) -> int:
    k = r
    while comb(k + 1, r) <= m:
        k += 1
    return k


def verify_kruskal_katona(
    family: Sequence[FrozenSet[int]], r: int
) -> Tuple[int, int, int]:
    m = len(family)
    k = largest_k_with_binom_le(m, r)
    sh = shadow(family)
    bound = comb(k, r - 1)
    assert len(sh) >= bound
    return m, len(sh), bound
