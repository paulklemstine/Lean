from __future__ import annotations
from itertools import permutations
from typing import Iterator


def slab_scds(n: int) -> Iterator[list[tuple[tuple[int, int], tuple[int, int]]]]:
    """Enumerate every symmetric chain decomposition of the two-level slab CB(n).

    Each SCD is a perfect matching bottom->top, i.e. a permutation sigma; it is
    rendered as the list of two-element symmetric chains {(0,i),(1,sigma[i])}.
    Yields exactly numSCD(n) = n! decompositions (proved lower bound n!<=numSCD).
    """
    for sigma in permutations(range(n)):
        yield [((0, i), (1, j)) for i, j in enumerate(sigma)]


def num_scd(n: int) -> int:
    return sum(1 for _ in slab_scds(n))
