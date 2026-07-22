from typing import List, Tuple

Partition = Tuple[int, ...]


def partitions(n: int, max_part: int | None = None) -> List[Partition]:
    """All partitions of n as weakly-decreasing tuples; |output| = p(n)."""
    if max_part is None:
        max_part = n
    if n == 0:
        return [()]
    result: List[Partition] = []
    for k in range(min(n, max_part), 0, -1):
        for rest in partitions(n - k, k):
            result.append((k,) + rest)
    return result


def partition_number(n: int) -> int:
    """p(n): the number of conjugacy classes / character-table rows of S_n."""
    return len(partitions(n))
