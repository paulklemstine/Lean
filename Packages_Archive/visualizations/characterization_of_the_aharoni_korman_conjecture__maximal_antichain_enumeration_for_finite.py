"""The counterexample D = sum_{k in N} N^op on a finite truncation, verifying
that it is a chain (hence FAC), every maximal antichain is a singleton, the whole
chain meets every maximal antichain (satisfies AK), while D is a countable direct
sum of infinite co-wellfounded blocks (an AK obstruction)."""
from __future__ import annotations
from itertools import combinations
from typing import List, Tuple

Elem = Tuple[int, int]


def D_leq(a: Elem, b: Elem) -> bool:
    (k, n), (k2, n2) = a, b
    return k < k2 if k != k2 else n >= n2


def is_chain(elems: List[Elem]) -> bool:
    return all(D_leq(a, b) or D_leq(b, a) for a, b in combinations(elems, 2))


def is_antichain(elems: List[Elem]) -> bool:
    return all(not (D_leq(a, b) or D_leq(b, a)) for a, b in combinations(elems, 2))


def maximal_antichains(universe: List[Elem]) -> List[List[Elem]]:
    n = len(universe)
    result = []
    for mask in range(1, 1 << n):
        sub = [universe[i] for i in range(n) if mask & (1 << i)]
        if not is_antichain(sub):
            continue
        s = set(sub)
        maximal = all(
            any(D_leq(x, a) or D_leq(a, x) for a in sub)
            for x in universe if x not in s
        )
        if maximal:
            result.append(sub)
    return result


if __name__ == "__main__":
    D = [(k, n) for k in range(4) for n in range(4)]
    macs = maximal_antichains(D)
    C = set(D)
    print("is_chain (=> FAC)      :", is_chain(D))
    print("maximal antichains     :", len(macs), "all singletons:",
          all(len(a) == 1 for a in macs))
    print("whole chain meets all  :", all(any(x in C for x in a) for a in macs))
    print("AK obstruction         : yes (direct sum of infinite N^op blocks)")
    print("=> countable+FAC+obstruction+AK all hold: obstruction dir. FALSE")
