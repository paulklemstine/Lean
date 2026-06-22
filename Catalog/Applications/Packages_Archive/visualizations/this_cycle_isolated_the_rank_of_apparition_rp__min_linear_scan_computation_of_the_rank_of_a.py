from typing import Callable, Optional

def seq_rank(u: Callable[[int], int], m: int, bound: int = 5000) -> Optional[int]:
    """Least k > 0 with m | u(k), searched up to `bound`; None if none found."""
    if m == 0:
        return None
    for k in range(1, bound + 1):
        if u(k) % m == 0:
            return k
    return None
