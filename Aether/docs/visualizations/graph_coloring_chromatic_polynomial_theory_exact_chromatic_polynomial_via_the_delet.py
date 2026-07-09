from typing import Dict, FrozenSet, List, Set, Tuple

Edge = FrozenSet[int]
Graph = Tuple[int, FrozenSet[Edge]]


def remove_edge(graph: Graph, u: int, v: int) -> Graph:
    n, edges = graph
    return (n, edges - {frozenset({u, v})})


def contract(graph: Graph, u: int, v: int) -> Graph:
    """Contract edge uv: identify v with u, drop loops, relabel to 0..n-2."""
    n, edges = graph
    merged: Set[Edge] = set()
    for e in edges:
        a, b = tuple(e)
        a = u if a == v else a
        b = u if b == v else b
        if a != b:
            merged.add(frozenset({a, b}))
    remaining = sorted(set(range(n)) - {v})
    relabel = {old: i for i, old in enumerate(remaining)}
    return (n - 1, frozenset(frozenset({relabel[a], relabel[b]})
                            for e in merged for a, b in [tuple(e)]))


def chromatic_polynomial(graph: Graph) -> List[int]:
    """Coefficients [c0, c1, ...] of P(G, x) via deletion-contraction.

    Base case (chromCount_bot): edgeless graph on n vertices has P = x^n.
    Recursion (chromCount_deletion_contraction, subtractive form):
        P(G, x) = P(G - uv, x) - P(G / uv, x).
    """
    n, edges = graph
    if not edges:
        coeffs = [0] * (n + 1)
        coeffs[n] = 1
        return coeffs
    u, v = tuple(next(iter(edges)))
    p_del = chromatic_polynomial(remove_edge(graph, u, v))
    p_con = chromatic_polynomial(contract(graph, u, v))
    length = max(len(p_del), len(p_con))
    p_del += [0] * (length - len(p_del))
    p_con += [0] * (length - len(p_con))
    return [p_del[i] - p_con[i] for i in range(length)]
