from math import comb
from typing import List

def turan_graph_edges(n: int, r: int) -> int:
    """Edge count of the balanced complete r-partite Turan graph."""
    sizes: List[int] = [n // r + (1 if i < n % r else 0)
                        for i in range(r)]
    within_parts: int = sum(comb(s, 2) for s in sizes)
    return comb(n, 2) - within_parts
