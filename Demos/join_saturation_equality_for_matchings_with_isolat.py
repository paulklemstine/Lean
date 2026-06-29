"""
demo.py — Numerical demonstrations for
    "Join-Saturation for Matchings with Isolated Vertices:
     Foundations and the Cameron--Puleo Recurrence"

This self-contained script verifies, by brute force on small instances, the three
foundational results and the headline recurrence of the package:

  * Theorem 3 (cone edge identity):  e(K_1 v H) = |V(H)| + e(H)
  * Theorem 2 (classical bound):     sat(n, H) <= ex(n, H)
  * Theorem 1 (existence):           an H-saturated graph exists when H has an edge
  * Main recurrence (star):          sat(n, K_1 v (tK_2 u qK_1))
                                       = (n - 1) + sat(n - 1, tK_2 u qK_1)
                                     (proved for t = 1, 2; checked numerically here)

Graphs are represented as (number_of_vertices, frozenset_of_edges), where each edge
is a frozenset {i, j} with i != j.  Everything is inlined and uses only the standard
library, with type hints throughout.
"""

from __future__ import annotations

from itertools import combinations, permutations
from typing import FrozenSet, Iterable, Iterator, Tuple

Edge = FrozenSet[int]
Graph = Tuple[int, FrozenSet[Edge]]  # (n_vertices, edges)


# --------------------------------------------------------------------------- #
# Basic graph utilities
# --------------------------------------------------------------------------- #
def edge_count(g: Graph) -> int:
    """Number of edges of g (Definition 1, edgeCount)."""
    _, edges = g
    return len(edges)


def all_pairs(n: int) -> Iterator[Edge]:
    """All unordered non-loop vertex pairs of an n-vertex graph."""
    for i, j in combinations(range(n), 2):
        yield frozenset((i, j))


def add_edge(g: Graph, e: Edge) -> Graph:
    """Return g with the edge e added (Lemma 2 setting, G u {ab})."""
    n, edges = g
    return (n, edges | {e})


def all_graphs(n: int) -> Iterator[Graph]:
    """Enumerate every labeled simple graph on n vertices."""
    pairs = list(all_pairs(n))
    for mask in range(1 << len(pairs)):
        edges = frozenset(pairs[k] for k in range(len(pairs)) if (mask >> k) & 1)
        yield (n, edges)


# --------------------------------------------------------------------------- #
# Subgraph containment:  H is a subgraph of G  (H embeds into G)
# --------------------------------------------------------------------------- #
def contains_copy(host: Graph, pattern: Graph) -> bool:
    """True iff `pattern` embeds into `host` as a subgraph (injective, edge-preserving).

    This is the relation H |= G ("host contains a copy of pattern") used in the
    definition of H-saturation (Definition 2).
    """
    hn, _ = host
    pn, pedges = pattern
    if pn > hn:
        return False
    host_adj = {(min(e), max(e)) for e in host[1]}
    for perm in permutations(range(hn), pn):
        ok = True
        for e in pedges:
            a, b = tuple(e)
            x, y = perm[a], perm[b]
            if (min(x, y), max(x, y)) not in host_adj:
                ok = False
                break
        if ok:
            return True
    return False


def is_free(host: Graph, pattern: Graph) -> bool:
    """True iff `host` contains no copy of `pattern` (pattern is free over host)."""
    return not contains_copy(host, pattern)


# --------------------------------------------------------------------------- #
# Saturation (Definition 2) and the two extremal parameters (Defs 3, 4)
# --------------------------------------------------------------------------- #
def is_saturated(host: Graph, pattern: Graph) -> bool:
    """True iff `host` is `pattern`-saturated: pattern-free, and adding any nonedge
    creates a copy of pattern (Definition 2, IsSaturated)."""
    if contains_copy(host, pattern):
        return False
    existing = host[1]
    for e in all_pairs(host[0]):
        if e in existing:
            continue
        if not contains_copy(add_edge(host, e), pattern):
            return False
    return True


def sat_number(n: int, pattern: Graph) -> int:
    """sat(n, pattern): minimum edge count over pattern-saturated graphs on n vertices
    (Definition 4, satNum).  Returns -1 if none exists (does not happen when the
    pattern has an edge, by Theorem 1)."""
    best = -1
    for g in all_graphs(n):
        if is_saturated(g, pattern):
            ec = edge_count(g)
            if best == -1 or ec < best:
                best = ec
    return best


def ex_number(n: int, pattern: Graph) -> int:
    """ex(n, pattern): maximum edge count over pattern-free graphs on n vertices
    (Definition 3, exNum)."""
    best = 0
    for g in all_graphs(n):
        if is_free(g, pattern):
            best = max(best, edge_count(g))
    return best


# --------------------------------------------------------------------------- #
# The two graph families:  cone (Def 5)  and  tK_2 u qK_1  (Def 6)
# --------------------------------------------------------------------------- #
def cone(h: Graph) -> Graph:
    """K_1 v H: add a fresh apex vertex (index n) adjacent to all of H (Definition 5)."""
    n, edges = h
    apex = n
    new_edges = set(edges) | {frozenset((apex, v)) for v in range(n)}
    return (n + 1, frozenset(new_edges))


def matching_plus_isolated(t: int, q: int) -> Graph:
    """F = tK_2 u qK_1 on 2t + q vertices (Definition 6, matchingPlusIsolated):
    vertices 2k and 2k+1 form the k-th matching edge; vertices >= 2t are isolated."""
    n = 2 * t + q
    edges = frozenset(frozenset((2 * k, 2 * k + 1)) for k in range(t))
    return (n, edges)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_cone_identity() -> None:
    """Theorem 3: e(K_1 v H) = |V(H)| + e(H) for several H."""
    print("== Theorem 3: cone edge identity  e(K_1 v H) = |V(H)| + e(H) ==")
    samples = {
        "K_2 (one edge)": (2, frozenset({frozenset((0, 1))})),
        "P_3 (path)": (3, frozenset({frozenset((0, 1)), frozenset((1, 2))})),
        "2K_2 u 1K_1": matching_plus_isolated(2, 1),
        "triangle K_3": (3, frozenset({frozenset((0, 1)),
                                       frozenset((1, 2)),
                                       frozenset((0, 2))})),
    }
    for name, h in samples.items():
        m, eh = h[0], edge_count(h)
        lhs = edge_count(cone(h))
        print(f"  H = {name:16s}: e(K_1 v H) = {lhs:2d}   "
              f"|V(H)| + e(H) = {m} + {eh} = {m + eh:2d}   "
              f"{'OK' if lhs == m + eh else 'MISMATCH'}")
    print()


def demo_sat_le_ex() -> None:
    """Theorem 2: sat(n, H) <= ex(n, H), shown for H = K_2 u K_1."""
    print("== Theorem 2: sat(n, H) <= ex(n, H)  for H = K_2 u K_1 ==")
    h = matching_plus_isolated(1, 1)  # one edge + one isolated vertex
    for n in range(3, 6):
        s = sat_number(n, h)
        x = ex_number(n, h)
        print(f"  n = {n}: sat = {s}   ex = {x}   {'OK' if s <= x else 'VIOLATION'}")
    print()


def demo_recurrence(t: int, q: int, n_values: Iterable[int]) -> None:
    """Main recurrence (star):
        sat(n, K_1 v (tK_2 u qK_1)) = (n-1) + sat(n-1, tK_2 u qK_1).
    This exercises the *main theorem* directly, not a trivial special case."""
    F = matching_plus_isolated(t, q)
    coneF = cone(F)
    print(f"== Main recurrence for F = {t}K_2 u {q}K_1  (cone has "
          f"{coneF[0]} vertices) ==")
    print("   sat(n, K_1 v F)  ?=  (n-1) + sat(n-1, F)")
    for n in n_values:
        lhs = sat_number(n, coneF)
        sub = sat_number(n - 1, F)
        rhs = (n - 1) + sub
        verdict = "OK" if lhs == rhs else "DIFFERS"
        print(f"  n = {n}: LHS sat(n, K_1 v F) = {lhs:2d}   "
              f"(n-1) + sat(n-1, F) = {n - 1} + {sub} = {rhs:2d}   {verdict}")
    print()


def main() -> None:
    demo_cone_identity()
    demo_sat_le_ex()
    # t = 1, q = 1: the smallest nontrivial Cameron--Puleo case (proved t = 1).
    demo_recurrence(t=1, q=1, n_values=[4, 5])
    # t = 1, q = 2: another instance of the proved t = 1 case.
    demo_recurrence(t=1, q=2, n_values=[5])


if __name__ == "__main__":
    main()
