from itertools import combinations
from typing import Dict, List, Set, Tuple

Graph = Tuple[int, Set[Tuple[int, int]]]


def neighbors(graph: Graph, v: int) -> List[int]:
    _, edges = graph
    out: List[int] = []
    for a, b in edges:
        if a == v:
            out.append(b)
        elif b == v:
            out.append(a)
    return out


def laplacian(graph: Graph, f: Dict[int, int]) -> Dict[int, int]:
    """lap f (v) = sum_{w ~ v} (f(v) - f(w))."""
    n, _ = graph
    return {v: sum(f[v] - f[w] for w in neighbors(graph, v)) for v in range(n)}


def divisor_degree(divisor: Dict[int, int]) -> int:
    return sum(divisor.values())


def fire_and_check(graph: Graph, divisor: Dict[int, int],
                   f: Dict[int, int]) -> Tuple[Dict[int, int], bool]:
    """Apply firing pattern f, return (new divisor, degree-preserved?).

    By Theorem 3.2 (deg_lap_eq_zero) the boolean is always True.
    """
    lap = laplacian(graph, f)
    fired = {v: divisor[v] + lap[v] for v in divisor}
    return fired, divisor_degree(fired) == divisor_degree(divisor)
