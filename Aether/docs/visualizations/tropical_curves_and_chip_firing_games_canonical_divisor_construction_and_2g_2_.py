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


def vertex_degree(graph: Graph, v: int) -> int:
    return len(neighbors(graph, v))


def canonical_divisor(graph: Graph) -> Dict[int, int]:
    """K(v) = deg(v) - 2."""
    n, _ = graph
    return {v: vertex_degree(graph, v) - 2 for v in range(n)}


def genus(graph: Graph) -> int:
    """g = |E| - |V| + 1."""
    n, edges = graph
    return len(edges) - n + 1


def canonical_genus_check(graph: Graph) -> Tuple[int, int, bool]:
    """Return (sum_v K(v), 2g - 2, equal?).

    By Theorem 3.3 (deg_canonicalDivisor_eq_two_genus_sub_two) they are equal.
    """
    sum_k = sum(canonical_divisor(graph).values())
    target = 2 * genus(graph) - 2
    return sum_k, target, sum_k == target
