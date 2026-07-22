from __future__ import annotations
from typing import Callable, List, Tuple

def enumerate_admissible_prefixes(
        admits: Callable[[str], bool], n: int) -> List[str]:
    """Depth-first enumeration of admissible length-n prefixes with pruning:
    a prefix is extended only if it is itself admissible."""
    frontier: List[str] = [""]
    for _ in range(n):
        nxt: List[str] = []
        for s in frontier:
            for b in ("0", "1"):
                t = s + b
                if admits(t):
                    nxt.append(t)
        frontier = nxt
    return frontier

def covering_number(admits: Callable[[str], bool], n: int) -> int:
    """N_n = number of admissible length-n prefixes = covering number at 2^-n."""
    return len(enumerate_admissible_prefixes(admits, n))
