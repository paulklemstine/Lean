from __future__ import annotations
from typing import Callable, List


def mixed_radix_decode(base: Callable[[int], int], digits: List[int], k: int) -> int:
    """Compute value(b, c, k) = sum_{i<k} c_i * P_i.

    Inverse of mixed_radix_encode on the range {0, ..., P_k - 1}. Maintains the
    running product P_i incrementally so the whole pass is O(k) big-integer ops.
    """
    total: int = 0
    running_product: int = 1
    for i in range(k):
        total += digits[i] * running_product
        running_product *= base(i)
    return total
