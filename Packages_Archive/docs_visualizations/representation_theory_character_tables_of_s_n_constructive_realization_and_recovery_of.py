from __future__ import annotations
from typing import List, Tuple

Partition = Tuple[int, ...]
Perm = Tuple[int, ...]


def perm_of_partition(p: Partition, n: int) -> Perm:
    """Realize a partition p of n as a standard permutation of {0,...,n-1}.

    Lay the points out in consecutive blocks whose sizes are the parts of p,
    and cyclically shift each block.  Blocks of size 1 become fixed points.
    The full cycle-length partition of the result (fixed points restored) is
    exactly p -- this is the constructive content of `permOfPartition` and
    Lemma `permOfPartition_partition_parts`.
    """
    image: List[int] = list(range(n))
    offset = 0
    for part in p:
        for k in range(part):
            image[offset + k] = offset + ((k + 1) % part)
        offset += part
    return tuple(image)


def perm_partition(perm: Perm) -> Partition:
    """Inverse direction `permPartition`: read every cycle length (including
    length-1 fixed points) and return them sorted descending."""
    n = len(perm)
    seen = [False] * n
    lengths: List[int] = []
    for start in range(n):
        if seen[start]:
            continue
        length, j = 0, start
        while not seen[j]:
            seen[j] = True
            j = perm[j]
            length += 1
        lengths.append(length)
    return tuple(sorted(lengths, reverse=True))
