from typing import List, Tuple

Partition = Tuple[int, ...]
Permutation = List[int]


def perm_of_partition(part: Partition, n: int) -> Permutation:
    """Forward map permOfPartition: realize a partition as a permutation of
    {0,..,n-1} by turning consecutive blocks into cycles. The resulting cycle
    type (parts >= 2) is exactly the prescribed partition's large parts; parts
    equal to 1 are fixed points."""
    perm: List[int] = list(range(n))
    start = 0
    for block in part:
        for i in range(block):
            perm[start + i] = start + (i + 1) % block
        start += block
    return perm
