from typing import Optional

def separating_point(a: int, b: int, n: int) -> Optional[int]:
    c = (a ^ b) & ((1 << n) - 1)        # symmetric difference
    if c == 0:
        return None                     # a == b: nothing to separate
    for i in range(n):                  # first point in D(c)
        if (c >> i) & 1:
            return i
    return None
