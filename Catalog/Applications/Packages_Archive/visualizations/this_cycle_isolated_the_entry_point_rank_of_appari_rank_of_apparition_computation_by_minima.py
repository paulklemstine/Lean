from typing import Callable, Optional

def entry_point(a: Callable[[int], int], p: int, limit: int = 10**6) -> Optional[int]:
    """Least k > 0 with p | a(k); None if not found below `limit`.
    For a strong divisibility sequence this single number determines the entire
    divisibility set {n : p | a(n)} = multiples of the return value."""
    for k in range(1, limit + 1):
        if a(k) % p == 0:
            return k
    return None
