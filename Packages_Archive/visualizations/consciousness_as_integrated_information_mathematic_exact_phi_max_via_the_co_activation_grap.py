from itertools import combinations
from typing import Dict, FrozenSet, List, Tuple

Config = Tuple[bool, ...]
System = Dict[Config, float]


def coactivation_graph(p: System, n: int) -> Dict[int, set]:
    """Build the co-activation graph G_P: an edge {u,v} whenever some
    positive-probability configuration activates both u and v."""
    supp = [x for x, w in p.items() if w > 0.0]
    adj: Dict[int, set] = {u: set() for u in range(n)}
    for u in range(n):
        for v in range(u + 1, n):
            if any(x[u] and x[v] for x in supp):
                adj[u].add(v)
                adj[v].add(u)
    return adj


def max_clique(adj: Dict[int, set]) -> FrozenSet[int]:
    """Bron-Kerbosch with pivoting: returns a maximum clique of G_P."""
    best: List[int] = []

    def bk(r: List[int], p: set, x: set) -> None:
        nonlocal best
        if not p and not x:
            if len(r) > len(best):
                best = list(r)
            return
        if len(r) + len(p) <= len(best):
            return
        pivot = max(p | x, key=lambda v: len(adj[v] & p)) if (p | x) else None
        ext = list(p - adj[pivot]) if pivot is not None else list(p)
        for v in ext:
            bk(r + [v], p & adj[v], x & adj[v])
            p = p - {v}
            x = x | {v}

    bk([], set(adj.keys()), set())
    return frozenset(best)


def phi_max_exact(p: System, n: int) -> int:
    """Phi_max(P) computed via the collapse theorem (phiMax_eq_global):
    Phi_max equals the size of the maximum clique of the co-activation graph,
    provided it has at least two vertices (else 0)."""
    adj = coactivation_graph(p, n)
    clique = max_clique(adj)
    return len(clique) if len(clique) >= 2 else 0
