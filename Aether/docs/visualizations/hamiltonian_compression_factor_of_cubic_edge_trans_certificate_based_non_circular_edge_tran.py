from __future__ import annotations
from itertools import combinations
from typing import FrozenSet, List, Tuple

Perm = Tuple[int, ...]
Edge = FrozenSet[int]
N = 6


def adj3(i: int, j: int) -> bool:
    """Adjacency of the Mobius ladder M_3 over Z/6Z."""
    return (j == (i + 1) % N) or (i == (j + 1) % N) or (j == (i + 3) % N)


def is_sym(p: Perm) -> bool:
    """IsSym: p preserves adjacency in both directions (graph automorphism)."""
    return all(adj3(p[i], p[j]) == adj3(i, j) for i in range(N) for j in range(N))


def act_edge(p: Perm, e: Edge) -> Edge:
    return frozenset(p[v] for v in e)


def edges() -> List[Edge]:
    return [frozenset((i, j)) for i, j in combinations(range(N), 2) if adj3(i, j)]


def certificate_edge_transitivity(cert: List[Perm], base: Edge) -> Perm:
    """
    Given a verified certificate (list of automorphisms whose images of `base`
    cover every edge), return a function building a symmetry e1 -> e2 for any
    pair, exactly mirroring the Lean proof `edge_transitive`.
    """
    # Legality check (cert_isSym) and covering check (cert_covers).
    assert all(is_sym(s) for s in cert), "certificate legality failed"
    cover = {act_edge(s, base): s for s in cert}
    assert set(cover) == set(edges()), "certificate covering failed"

    def inverse(p: Perm) -> Perm:
        inv = [0] * N
        for x in range(N):
            inv[p[x]] = x
        return tuple(inv)

    def compose(p: Perm, q: Perm) -> Perm:
        return tuple(p[q[x]] for x in range(N))

    def transport(e1: Edge, e2: Edge) -> Perm:
        s1, s2 = cover[e1], cover[e2]
        sigma = compose(s2, inverse(s1))      # s2 . s1^{-1}
        assert is_sym(sigma) and act_edge(sigma, e1) == e2
        return sigma

    return transport
