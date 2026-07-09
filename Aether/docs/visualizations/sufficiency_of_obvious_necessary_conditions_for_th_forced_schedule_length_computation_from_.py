from typing import List, Optional

def schedule_length(m: List[int], s: int) -> Optional[int]:
    """Forced number of nights N = 2n(n-1)/sum(m) if the obvious conditions
    hold, else None."""
    n = s + sum(m)
    total = 2 * n * (n - 1)
    if any(mi < 2 or total % mi != 0 for mi in m):
        return None
    denom = sum(m)
    return total // denom if denom and total % denom == 0 else None
