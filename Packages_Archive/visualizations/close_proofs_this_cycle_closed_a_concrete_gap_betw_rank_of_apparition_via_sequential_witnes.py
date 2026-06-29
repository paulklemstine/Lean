from typing import Callable, Optional

def rank(u: Callable[[int], int], m: int, limit: int = 100_000) -> Optional[int]:
    """Least k>0 with m | u(k); None if not found below `limit`."""
    if m == 0:
        return None
    for k in range(1, limit + 1):
        if u(k) % m == 0:
            return k
    return None