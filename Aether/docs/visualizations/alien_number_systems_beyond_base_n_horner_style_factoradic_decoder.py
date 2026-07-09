from typing import List


def decode_factoradic(c: List[int], k: int) -> int:
    """Decode a length-k factoradic digit vector c back to a natural number.

    Uses a Horner-style fold so that factorials are never materialized:
    value = c[0] + 1*(c[1] + 2*(c[2] + 3*(c[3] + ...))).
    Runs in O(k) multiply-add operations.
    """
    acc: int = 0
    for i in range(k - 1, 0, -1):
        acc = (acc + c[i]) * i
    return acc + (c[0] if k > 0 else 0)
