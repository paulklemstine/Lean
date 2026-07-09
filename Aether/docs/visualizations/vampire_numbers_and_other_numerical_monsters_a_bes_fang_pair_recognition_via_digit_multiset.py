from collections import Counter
from typing import List


def digits(b: int, n: int) -> List[int]:
    out: List[int] = []
    while n > 0:
        out.append(n % b)
        n //= b
    return out


def is_fang_pair(b: int, x: int, y: int) -> bool:
    """O(log(xy)) multiset test of the digit-permutation condition."""
    return Counter(digits(b, x * y)) == Counter(digits(b, x)) + Counter(digits(b, y))
