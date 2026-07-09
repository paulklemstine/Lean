from itertools import combinations
from typing import Callable, Iterable, List

def has_mono_clique(
    vertices: Iterable[int],
    red_adj: Callable[[int, int], bool],
    size: int,
    red: bool,
) -> bool:
    verts: List[int] = list(vertices)
    for subset in combinations(verts, size):
        ok = True
        for a, b in combinations(subset, 2):
            edge_is_red = red_adj(a, b)
            if red and not edge_is_red:
                ok = False; break
            if (not red) and edge_is_red:
                ok = False; break
        if ok:
            return True
    return False