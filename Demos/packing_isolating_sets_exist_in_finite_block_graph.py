"""
Packing-Isolating Sets in Block Graphs — Numerical Demonstrations
=================================================================

A *packing-isolating set* of a finite simple graph G is a vertex set S that is
simultaneously:

  * a 2-PACKING  — the closed neighborhoods N[u], N[v] of distinct u, v in S are
    pairwise disjoint (equivalently every two chosen vertices are at distance >= 3);
  * an ISOLATING set — every edge of G has at least one endpoint inside the
    combined closed neighborhood N[S] = union over v in S of N[v].

This script reproduces, by direct computation, the three main results:

  1. completeGraph_packingIsolating : any single vertex is packing-isolating in K_{n+1}.
  2. pathG_packingIsolating        : S = {i : i % 3 == 1} is packing-isolating in P_n.
  3. C5_no_packingIsolating        : the 5-cycle C5 has NO packing-isolating set
                                     (exhaustive search over all 2^5 subsets),
                                     while C4 (the square) does.

Everything is self-contained: graphs are plain adjacency dictionaries and all
helper functions are inlined with type hints.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, List, Set, Tuple

# A graph is represented as a dict mapping each vertex to the set of its neighbors.
Graph = Dict[int, Set[int]]


# --------------------------------------------------------------------------- #
#  Core combinatorial primitives                                              #
# --------------------------------------------------------------------------- #
def closed_neighborhood(g: Graph, v: int) -> Set[int]:
    """N[v] = {v} together with all neighbors of v."""
    return {v} | set(g[v])


def neighborhood_of_set(g: Graph, s: Set[int]) -> Set[int]:
    """N[S] = union of closed neighborhoods over all vertices of S."""
    result: Set[int] = set()
    for v in s:
        result |= closed_neighborhood(g, v)
    return result


def edges(g: Graph) -> List[Tuple[int, int]]:
    """All undirected edges {u, v} with u < v."""
    out: List[Tuple[int, int]] = []
    for u in g:
        for w in g[u]:
            if u < w:
                out.append((u, w))
    return out


def is_two_packing(g: Graph, s: Set[int]) -> bool:
    """Closed neighborhoods of distinct vertices of S are pairwise disjoint."""
    members = sorted(s)
    for u, v in combinations(members, 2):
        if closed_neighborhood(g, u) & closed_neighborhood(g, v):
            return False
    return True


def is_isolating(g: Graph, s: Set[int]) -> bool:
    """Every edge has at least one endpoint in N[S]."""
    cover = neighborhood_of_set(g, s)
    return all((u in cover) or (w in cover) for u, w in edges(g))


def is_packing_isolating(g: Graph, s: Set[int]) -> bool:
    """Both a 2-packing and an isolating set."""
    return is_two_packing(g, s) and is_isolating(g, s)


def find_any_packing_isolating(g: Graph) -> FrozenSet[int] | None:
    """Exhaustive search: return some packing-isolating set, or None if none exists."""
    verts = list(g)
    for r in range(len(verts) + 1):
        for combo in combinations(verts, r):
            s = set(combo)
            if is_packing_isolating(g, s):
                return frozenset(s)
    return None


# --------------------------------------------------------------------------- #
#  Graph constructors                                                          #
# --------------------------------------------------------------------------- #
def complete_graph(m: int) -> Graph:
    """K_m on vertices 0..m-1 (every pair adjacent)."""
    return {i: {j for j in range(m) if j != i} for i in range(m)}


def path_graph(n: int) -> Graph:
    """P_n on vertices 0..n-1 with consecutive vertices adjacent."""
    g: Graph = {i: set() for i in range(n)}
    for i in range(n - 1):
        g[i].add(i + 1)
        g[i + 1].add(i)
    return g


def cycle_graph(n: int) -> Graph:
    """C_n on vertices 0..n-1, a single ring."""
    g: Graph = {i: set() for i in range(n)}
    for i in range(n):
        j = (i + 1) % n
        g[i].add(j)
        g[j].add(i)
    return g


def path_packing(n: int) -> Set[int]:
    """The aligned period-three residue set {i : i % 3 == 1}."""
    return {i for i in range(n) if i % 3 == 1}


# --------------------------------------------------------------------------- #
#  Demonstrations                                                             #
# --------------------------------------------------------------------------- #
def demo_complete_graphs() -> None:
    print("=" * 68)
    print("1.  Complete graphs K_{n+1}:  a single vertex is packing-isolating")
    print("=" * 68)
    for m in range(1, 8):
        g = complete_graph(m)
        s = {0}
        ok = is_packing_isolating(g, s)
        dominates = neighborhood_of_set(g, s) == set(g)
        print(f"  K_{m:<2d}: S={{0}}  packing-isolating={ok}  "
              f"dominates_all_vertices={dominates}")
    print()


def demo_paths() -> None:
    print("=" * 68)
    print("2.  Path graphs P_n:  S = {i : i % 3 == 1} is packing-isolating")
    print("=" * 68)
    for n in range(2, 16):
        g = path_graph(n)
        s = path_packing(n)
        pack = is_two_packing(g, s)
        iso = is_isolating(g, s)
        print(f"  P_{n:<2d}: S={sorted(s)!s:<22} 2-packing={pack}  "
              f"isolating={iso}  |S|={len(s)}  ceil(n/3)={-(-n // 3)}")
    print()

    print("  Cautionary example — a MAXIMAL packing need not be isolating:")
    g6 = path_graph(6)
    endpoints = {0, 5}
    print(f"    P_6, S={{0,5}}: 2-packing={is_two_packing(g6, endpoints)}  "
          f"isolating={is_isolating(g6, endpoints)}  "
          f"(edge {{2,3}} is uncovered)")
    aligned = path_packing(6)
    print(f"    P_6, S={sorted(aligned)}: 2-packing={is_two_packing(g6, aligned)}  "
          f"isolating={is_isolating(g6, aligned)}  (aligned set works)")
    print()


def demo_cycles() -> None:
    print("=" * 68)
    print("3.  Cycles:  C5 has NO packing-isolating set, but C4 does")
    print("=" * 68)
    for n in range(3, 9):
        g = cycle_graph(n)
        found = find_any_packing_isolating(g)
        if found is None:
            print(f"  C_{n}: NO packing-isolating set exists "
                  f"(exhaustive search over 2^{n} subsets)")
        else:
            print(f"  C_{n}: packing-isolating set found -> {sorted(found)}")
    print()
    print("  The diameter-2 / no-dominating-vertex deadlock for C5:")
    c5 = cycle_graph(5)
    print(f"    Any single vertex covers only {len(closed_neighborhood(c5, 0))} "
          f"of 5 vertices -> not isolating.")
    print(f"    Any two vertices are at distance <= 2 -> never a 2-packing of size 2.")
    print()


def main() -> None:
    demo_complete_graphs()
    demo_paths()
    demo_cycles()
    print("All demonstrations reproduce the formally verified results.")


if __name__ == "__main__":
    main()
