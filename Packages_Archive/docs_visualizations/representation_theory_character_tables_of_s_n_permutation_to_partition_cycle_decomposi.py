from typing import List, Tuple

Permutation = List[int]
Partition = Tuple[int, ...]


def perm_partition(perm: Permutation) -> Partition:
    """Backward map permPartition: recover the partition of a permutation by
    orbit-tracing its disjoint cycles (fixed points contribute parts equal to
    1). This value is constant on conjugacy classes, so it descends to the
    quotient and inverts perm_of_partition."""
    n = len(perm)
    seen = [False] * n
    lengths: List[int] = []
    for i in range(n):
        if seen[i]:
            continue
        length, j = 0, i
        while not seen[j]:
            seen[j] = True
            j = perm[j]
            length += 1
        lengths.append(length)
    return tuple(sorted(lengths, reverse=True))
