from __future__ import annotations
from itertools import product
from typing import Callable, FrozenSet, List, Sequence, Tuple

Partition = Tuple[FrozenSet[int], ...]


def set_partitions(items: List[int]) -> List[Partition]:
    """All set partitions of `items` (recursive restricted-growth construction)."""
    if not items:
        return [tuple()]
    first, rest = items[0], items[1:]
    out: List[Partition] = []
    for part in set_partitions(rest):
        out.append((frozenset([first]),) + part)            # new singleton block
        for i in range(len(part)):                           # or extend a block
            merged = list(part)
            merged[i] = part[i] | {first}
            out.append(tuple(merged))
    return out


def enumerate_congruences(
    carrier: Sequence[int],
    add: Callable[[int, int], int],
    mul: Callable[[int, int], int],
) -> List[Partition]:
    """Algorithm A: retain partitions whose induced relation respects + and *."""
    result: List[Partition] = []
    for part in set_partitions(list(carrier)):
        rep = {x: block for block in part for x in block}
        rel = lambda a, b: rep[a] is rep[b]
        compatible = all(
            (not (rel(a, b) and rel(c, d)))
            or (rel(add(a, c), add(b, d)) and rel(mul(a, c), mul(b, d)))
            for a, b, c, d in product(carrier, repeat=4)
        )
        if compatible:
            result.append(part)
    return result
