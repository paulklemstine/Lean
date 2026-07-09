from typing import Dict, FrozenSet, List, Sequence, Tuple

Edge = FrozenSet[int]
Hypergraph = List[Edge]

def heaviest_color_class(matching: Sequence[Edge], coloring: Dict[Edge, int],
                         r: int) -> Tuple[int, Hypergraph]:
    """Pigeonhole on a matching: return the largest color class (r*|class|>=|M|)."""
    best_color, best_class = 0, []  # type: Tuple[int, Hypergraph]
    for i in range(r):
        cls = [e for e in matching if coloring[e] == i]
        if len(cls) > len(best_class):
            best_color, best_class = i, cls
    return best_color, best_class

def guaranteed_mono_matching(h: Hypergraph, coloring: Dict[Edge, int],
                             r: int) -> Hypergraph:
    """Greedy maximal matching + heaviest color class -> size >= |H|/(r t Delta)."""
    used: set[int] = set()
    m: Hypergraph = []
    for e in h:
        if not (used & e):
            m.append(e); used |= e
    _, mono = heaviest_color_class(m, coloring, r)
    return mono
