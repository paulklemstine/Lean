from functools import lru_cache
from typing import List

def box_partition_row(n: int, k: int) -> List[int]:
    """Coefficient row of [n choose k]_q as counts of partitions in a k x (n-k) box.

    classSize(n,k,i) is conjectured (C3) to equal the number of integer partitions
    of i into at most k parts, each at most n-k. We count those partitions with a
    memoized recursion: count(s, max_parts, max_part) either omits the value
    `max_part` as a part, or uses one such part and recurses. Returns the vector
    indexed by i = 0..k(n-k), which matches the Gaussian coefficient row.
    """
    width: int = n - k      # maximum part size
    height: int = k         # maximum number of parts
    max_i: int = width * height

    @lru_cache(maxsize=None)
    def count(s: int, max_parts: int, max_part: int) -> int:
        if s == 0:
            return 1
        if max_parts == 0 or max_part == 0:
            return 0
        with_part = count(s - max_part, max_parts - 1, max_part) if s >= max_part else 0
        return count(s, max_parts, max_part - 1) + with_part

    return [count(i, height, width) for i in range(max_i + 1)]
