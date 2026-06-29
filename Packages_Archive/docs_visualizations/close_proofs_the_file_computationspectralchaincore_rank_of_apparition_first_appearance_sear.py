from math import gcd
from typing import Callable, Optional

def apparition_rank(u: Callable[[int], int], p: int, search: int = 10000) -> Optional[int]:
    """Return the rank of apparition of p in the strong divisibility sequence u:
    the least n > 0 with p | u(n). Returns None if none is found below `search`.

    By the uniqueness theorem this n is unique, and by the law of apparition the
    full divisibility set {m : p | u(m)} equals the multiples of n."""
    if p == 0:
        return None
    for n in range(1, search + 1):
        if u(n) % p == 0:
            return n
    return None
