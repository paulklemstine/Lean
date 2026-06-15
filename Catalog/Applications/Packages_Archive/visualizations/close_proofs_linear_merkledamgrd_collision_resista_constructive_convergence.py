from typing import Callable, List, Optional, Tuple

Compress = Callable[[int, int], int]

def constructive_convergence(
    f: Compress, a1: int, a2: int, msg: List[int]
) -> Optional[Tuple[int, int, int]]:
    """Locate a same-block compression collision from converging states."""
    s1: int = a1
    s2: int = a2
    for b in msg:
        if s1 != s2 and f(s1, b) == f(s2, b):
            return s1, s2, b
        s1, s2 = f(s1, b), f(s2, b)
    return None
