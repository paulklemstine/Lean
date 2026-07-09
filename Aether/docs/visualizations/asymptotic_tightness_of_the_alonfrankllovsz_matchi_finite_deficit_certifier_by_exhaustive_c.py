from itertools import combinations, product
from typing import FrozenSet, List, Sequence

Edge = FrozenSet[int]
Hypergraph = List[Edge]

def max_matching_size(edges: Sequence[Edge]) -> int:
    edges = list(edges); best = 0
    def rec(idx: int, used: frozenset, count: int) -> None:
        nonlocal best
        best = max(best, count)
        for k in range(idx, len(edges)):
            if not (used & edges[k]):
                rec(k + 1, used | edges[k], count + 1)
    rec(0, frozenset(), 0)
    return best

def worst_case_mono_matching(h: Hypergraph, r: int) -> int:
    """min over r-colorings of (max monochromatic matching size); brute force."""
    best = None
    for assignment in product(range(r), repeat=len(h)):
        coloring = {h[i]: assignment[i] for i in range(len(h))}
        mono = 0
        for color in range(r):
            cls = [e for e in h if coloring[e] == color]
            mono = max(mono, max_matching_size(cls))
        best = mono if best is None else min(best, mono)
    return best or 0

def complete_t_graph(n: int, t: int) -> Hypergraph:
    return [frozenset(c) for c in combinations(range(n), t)]
