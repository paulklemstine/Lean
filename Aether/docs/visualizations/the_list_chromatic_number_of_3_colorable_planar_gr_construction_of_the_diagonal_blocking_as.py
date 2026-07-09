from itertools import product
from typing import Dict, List, Set, Tuple

Vertex = Tuple[str, int]

def blocking_assignment(k: int) -> Tuple[Dict[Vertex, Set[int]],
                                         List[Tuple[Vertex, Vertex]]]:
    """Construct K_{k,k^k} together with the diagonal k-list assignment that
    admits no proper list coloring (generalizing the K_{2,4} witness)."""
    small: List[List[int]] = [list(range(i * k, i * k + k)) for i in range(k)]
    systems = list(product(*small))            # all k^k systems of representatives
    lists: Dict[Vertex, Set[int]] = {("A", i): set(small[i]) for i in range(k)}
    for j, s in enumerate(systems):
        lists[("B", j)] = set(s)
    left = [("A", i) for i in range(k)]
    right = [("B", j) for j in range(len(systems))]
    edges = [(a, b) for a in left for b in right]
    return lists, edges
