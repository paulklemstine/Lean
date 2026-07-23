from __future__ import annotations
from itertools import combinations
from typing import FrozenSet, Iterable, Set, Tuple

Vertex = int
Edge = FrozenSet[Vertex]
Face = FrozenSet[Vertex]
Graph = Tuple[FrozenSet[Vertex], Set[Edge]]
Complex = Set[Face]


def adjacent(G: Graph, u: Vertex, v: Vertex) -> bool:
    """Adjacency test: u~v iff distinct and {u,v} is an edge."""
    return u != v and frozenset((u, v)) in G[1]


def is_clique(G: Graph, s: Iterable[Vertex]) -> bool:
    """A set is a clique iff every distinct pair is an edge (2-clique = edge)."""
    s = list(s)
    return all(adjacent(G, u, v) for u, v in combinations(s, 2))


def powerset(vs: Iterable[Vertex]) -> Iterable[Face]:
    vs = list(vs)
    return (frozenset(c) for r in range(len(vs) + 1) for c in combinations(vs, r))


def clique_complex(G: Graph) -> Complex:
    """
    Build Delta(G), the clique complex of G.

    Mathematical foundation: the faces of Delta(G) are exactly the finite cliques
    of G; downward closure holds because any subset of a clique is a clique.
    Complexity: O(2^n * n^2) for n = |V| in the worst case, since every subset is
    tested for the pairwise-adjacency (clique) condition. For sparse inputs the
    enumeration can be restricted to neighborhoods, but the maximal-clique problem
    is NP-hard in general, so exponential behavior is intrinsic.
    """
    V, _ = G
    return {s for s in powerset(V) if is_clique(G, s)}


def one_skeleton(V: FrozenSet[Vertex], K: Complex) -> Graph:
    """
    Build sk(K): keep vertices and the 1-faces (edges) of K.

    By the reconstruction theorem, sk(Delta(G)) = G, so this is a left inverse of
    the clique-complex functor. Complexity: O(n^2) pair lookups.
    """
    edges = {frozenset((u, v)) for u, v in combinations(sorted(V), 2)
             if frozenset((u, v)) in K}
    return (V, edges)
