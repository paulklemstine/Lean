from math import isqrt
from typing import List

def isqrt_test(n: int) -> bool:
    """Exact perfect-square test using the integer square root."""
    r: int = isqrt(n)
    return r * r == n

def brown_census(bound: int) -> List[int]:
    """Return all n in [0, bound) with n! + 1 a perfect square.
    n! is maintained incrementally; each test costs O(log) big-mults."""
    result: List[int] = []
    fact: int = 1
    for n in range(bound):
        if n > 0:
            fact *= n
        if isqrt_test(fact + 1):
            result.append(n)
    return result

if __name__ == "__main__":
    print(brown_census(1000))  # -> [4, 5, 7]
