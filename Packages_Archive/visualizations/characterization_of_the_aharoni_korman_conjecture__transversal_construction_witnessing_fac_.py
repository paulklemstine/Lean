"""The Width Threshold: a disjoint sum of many nonempty posets has a
transversal antichain whose size equals the number of blocks, so infinitely many
blocks force an infinite antichain and destroy the finite antichain condition."""
from __future__ import annotations
from itertools import combinations
from typing import List, Tuple

Elem = Tuple[int, int]


def disjoint_leq(a: Elem, b: Elem) -> bool:
    if a[0] != b[0]:
        return False  # different summands are incomparable
    return a[1] <= b[1]


def is_antichain(elems: List[Elem]) -> bool:
    return all(
        not (disjoint_leq(a, b) or disjoint_leq(b, a))
        for a, b in combinations(elems, 2)
    )


if __name__ == "__main__":
    for blocks in (1, 2, 4, 8, 16):
        transversal = [(k, 0) for k in range(blocks)]
        print(f"{blocks:>2} blocks -> transversal size {len(transversal):>2}, "
              f"antichain = {is_antichain(transversal)}")
    print("Size grows without bound: infinitely many blocks => infinite "
          "antichain => not FAC.")
