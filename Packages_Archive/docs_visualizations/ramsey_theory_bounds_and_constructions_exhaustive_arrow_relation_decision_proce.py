from itertools import combinations
from typing import FrozenSet, Iterable, List, Optional, Tuple

Edge = FrozenSet[int]
Coloring = FrozenSet[Edge]

def is_red(coloring: Coloring, u: int, v: int) -> bool:
    return frozenset((u, v)) in coloring

def has_mono_clique(coloring: Coloring, vertices: Iterable[int],
                    size: int, red: bool) -> Optional[Tuple[int, ...]]:
    verts: List[int] = sorted(vertices)
    for cand in combinations(verts, size):
        if all(is_red(coloring, u, v) == red
               for u, v in combinations(cand, 2)):
            return cand
    return None

def arrows(n: int, s: int, t: int) -> bool:
    verts: List[int] = list(range(n))
    all_edges: List[Edge] = [frozenset(e) for e in combinations(verts, 2)]
    m: int = len(all_edges)
    for mask in range(1 << m):
        coloring: Coloring = frozenset(
            all_edges[i] for i in range(m) if (mask >> i) & 1)
        red_ok = has_mono_clique(coloring, verts, s, True) is not None
        blue_ok = has_mono_clique(coloring, verts, t, False) is not None
        if not (red_ok or blue_ok):
            return False
    return True
