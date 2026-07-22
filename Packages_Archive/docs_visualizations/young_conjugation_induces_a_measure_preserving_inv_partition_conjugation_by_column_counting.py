from typing import List, Tuple


def conjugate_partition(partition: List[int]) -> List[int]:
    """Return the conjugate (transpose) of a partition by column counting.

    Runs in O(width * height) time, i.e. O(n) where n is the number of cells.
    """
    if not partition:
        return []
    width = partition[0]
    return [sum(1 for row in partition if row > j) for j in range(width)]


def swap(cell: Tuple[int, int]) -> Tuple[int, int]:
    return (cell[1], cell[0])
