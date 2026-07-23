from typing import Optional

def tower(h: int, N: int, cap: int = 64) -> Optional[int]:
    """Iterated exponential tower(h,N); returns None once it exceeds `cap` (too big)."""
    v: int = N
    for _ in range(h):
        if v > cap:
            return None
        v = 2 ** v
    return v