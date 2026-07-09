from __future__ import annotations
from typing import Dict, List, Set, Tuple

Graph = Dict[int, Set[int]]


def color_class_independent_set(
    graph: Graph, coloring: Dict[int, int]
) -> Tuple[List[int], int]:
    """Given a proper coloring, return a largest color class (an independent set)
    together with the number of colors used. The class has size >= n / k and is
    guaranteed independent because the coloring is proper.
    """
    k = max(coloring.values()) + 1 if coloring else 0
    classes: Dict[int, List[int]] = {}
    for v, c in coloring.items():
        classes.setdefault(c, []).append(v)
    largest = max(classes.values(), key=len) if classes else []
    return largest, k
