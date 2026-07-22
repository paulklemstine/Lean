from itertools import product
from typing import Sequence
Edge = tuple[int, int]

def chromatic_evaluation(n: int, edges: Sequence[Edge], k: int) -> int:
    """Return P_G(k) by explicit finite enumeration."""
    return sum(all(colors[u] != colors[v] for u, v in edges)
               for colors in product(range(k), repeat=n))
