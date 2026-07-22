from __future__ import annotations
from typing import Callable, List


def mixed_radix_encode(base: Callable[[int], int], n: int, k: int) -> List[int]:
    """Extract the length-k mixed-radix digits of n under a base sequence.

    Implements digit(b, n, i) = floor(n / P_i) mod b_i, where the running
    product P_i = b_0 * ... * b_{i-1} is maintained incrementally.
    """
    digits: List[int] = []
    running_product: int = 1
    for i in range(k):
        b_i = base(i)
        digits.append((n // running_product) % b_i)
        running_product *= b_i
    return digits
