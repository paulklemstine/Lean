from typing import List, Tuple

Vertex = Tuple[int, int]
Edge = Tuple[Vertex, Vertex]

def greedy_reach_regime(t: int, k: int) -> Tuple[List[Edge], int]:
    """
    Greedily delete edges of K_{t,t} to reach the bounded-component-cover
    regime with budget k by retaining disjoint K_{k,k} blocks. Returns the
    retained edge list and the number of deletions performed.
    """
    full: int = t * t
    kept: List[Edge] = []
    r: int = 0
    while (r + 1) * k <= t:
        a_block = [(0, i) for i in range(r * k, (r + 1) * k)]
        b_block = [(1, j) for j in range(r * k, (r + 1) * k)]
        kept.extend((a, b) for a in a_block for b in b_block)
        r += 1
    return kept, full - len(kept)
