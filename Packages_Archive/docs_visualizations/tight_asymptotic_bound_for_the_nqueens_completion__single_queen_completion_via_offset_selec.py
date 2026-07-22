from math import gcd
from typing import List, Tuple

def complete_single_queen(n: int, r: int, c: int) -> List[Tuple[int, int]]:
    """Full solution through queen (r, c); choose offset b = c - 2r."""
    assert gcd(n, 6) == 1
    b = (c - 2 * r) % n
    return [(x, (2 * x + b) % n) for x in range(n)]
