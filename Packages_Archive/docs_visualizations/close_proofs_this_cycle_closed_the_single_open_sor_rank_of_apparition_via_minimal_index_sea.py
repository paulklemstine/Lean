from math import gcd
from typing import Callable, Optional

def rank_of_apparition(u: Callable[[int], int], p: int, search: int = 100000) -> Optional[int]:
    """Least n > 0 with p | u(n): the rank of apparition (primitive index).

    By the uniqueness theorem this index, if it exists, is unique; by the pinning
    law it determines the entire divisibility pattern. Linear scan in the rank;
    each test is one modular reduction. Returns None if not found within `search`.
    """
    for n in range(1, search + 1):
        if u(n) % p == 0:
            return n
    return None
