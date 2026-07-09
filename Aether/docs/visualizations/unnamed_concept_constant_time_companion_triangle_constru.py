from typing import Tuple

def leg_witness(n: int) -> Tuple[int, int]:
    """O(1) construction of a companion triangle for any leg n >= 3."""
    if n < 3:
        raise ValueError("legs are exactly the integers >= 3")
    if n % 2 == 0:
        k = n // 2
        return (k * k - 1, k * k + 1)       # c - b = 2
    k = (n - 1) // 2
    b = 2 * k * k + 2 * k
    return (b, b + 1)                        # c - b = 1
