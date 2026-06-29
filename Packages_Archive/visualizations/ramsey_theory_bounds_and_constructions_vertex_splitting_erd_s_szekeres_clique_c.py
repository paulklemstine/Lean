from itertools import combinations
from math import comb
from typing import FrozenSet, List, Tuple

Edge = FrozenSet[int]
Coloring = FrozenSet[Edge]

def is_red(coloring: Coloring, u: int, v: int) -> bool:
    return frozenset((u, v)) in coloring

def es_construct_clique(coloring: Coloring, vertices: List[int],
                        s: int, t: int) -> Tuple[bool, Tuple[int, ...]]:
    if s == 1:
        return True, (vertices[0],)
    if t == 1:
        return False, (vertices[0],)
    v: int = vertices[0]
    rest: List[int] = vertices[1:]
    red_nb: List[int] = [u for u in rest if is_red(coloring, v, u)]
    blue_nb: List[int] = [u for u in rest if not is_red(coloring, v, u)]
    m: int = comb((s - 1) + (t - 1) - 1, (s - 1) - 1)
    if len(red_nb) >= m:
        is_red_clique, cl = es_construct_clique(coloring, red_nb, s - 1, t)
        if is_red_clique:
            return True, (v,) + cl
        return False, cl
    is_red_clique, cl = es_construct_clique(coloring, blue_nb, s, t - 1)
    if not is_red_clique:
        return False, (v,) + cl
    return True, cl
