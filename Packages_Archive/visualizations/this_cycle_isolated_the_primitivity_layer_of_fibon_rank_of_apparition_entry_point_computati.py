from typing import Callable, Optional

Seq = Callable[[int], int]

def entry_point(u: Seq, p: int, search_bound: int) -> Optional[int]:
    """Least positive n <= search_bound with p | u(n); None if none found."""
    for n in range(1, search_bound + 1):
        v = u(n)
        if v != 0 and v % p == 0:
            return n
    return None
