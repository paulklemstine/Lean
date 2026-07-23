from math import isqrt
from typing import List, Set


def representation_set_upto(m: int, upper: int) -> List[int]:
    """Return the sorted list of n in [0, upper] that are sums of m squares.

    Uses the saturation shortcut for m >= 4 and bounded dynamic programming
    otherwise.  Complexity O(upper * sqrt(upper) * m) in the sparse regime.
    """
    if m >= 4:
        return list(range(upper + 1))
    result: List[int] = []
    for n in range(upper + 1):
        squares: List[int] = [s * s for s in range(isqrt(n) + 1)]
        reachable: Set[int] = {0}
        for _ in range(m):
            nxt: Set[int] = set()
            for v in reachable:
                for sq in squares:
                    if v + sq <= n:
                        nxt.add(v + sq)
            reachable = nxt
        if n in reachable:
            result.append(n)
    return result
