"""
Numerical demonstrations for:

    A 4k+4 order bound for connectivity-preserving
    Hamiltonian prescribed-end paths.

This script is fully self-contained (standard library only) and exercises the
verified mathematical results:

  * IsKConnected            -- cut-based vertex k-connectivity (Definition 2.1)
  * Whitney's easy bound    -- kappa(G) <= delta(G)            (Theorem 2.3)
  * Paths are thin          -- path-neighbours of a vertex <= 2 (Theorem 3.1)
  * Degree drops by <= 2    -- deg_G(w) <= deg_{G-E(P)}(w) + 2  (Theorem 3.3)
  * Degree survival >= 2k+1 -- under the 4k+4 hypotheses        (Theorem 3.4)
  * Conjecture_4k4          -- prescribed-end connectivity-preserving search

All graphs are simple and represented as `dict[int, set[int]]` adjacency maps.
"""

from __future__ import annotations

from itertools import combinations, permutations
from math import ceil
from typing import Dict, FrozenSet, Iterable, List, Optional, Set, Tuple

Graph = Dict[int, Set[int]]
Edge = FrozenSet[int]


# --------------------------------------------------------------------------- #
# Basic graph utilities
# --------------------------------------------------------------------------- #
def vertices(g: Graph) -> List[int]:
    """Sorted list of vertices."""
    return sorted(g.keys())


def neighbour_set(g: Graph, w: int) -> Set[int]:
    """Open neighbour set N_G(w)."""
    return set(g.get(w, set()))


def degree(g: Graph, w: int) -> int:
    """deg_G(w) = |N_G(w)|."""
    return len(neighbour_set(g, w))


def min_degree(g: Graph) -> int:
    """delta(G), the minimum degree (0 for the empty graph)."""
    return min((degree(g, w) for w in g), default=0)


def induced_subgraph(g: Graph, keep: Set[int]) -> Graph:
    """Induced subgraph G[keep]."""
    return {v: {u for u in g[v] if u in keep} for v in g if v in keep}


def is_connected(g: Graph) -> bool:
    """True iff G is connected (the empty graph is treated as connected)."""
    verts = vertices(g)
    if not verts:
        return True
    start = verts[0]
    seen: Set[int] = {start}
    stack = [start]
    while stack:
        x = stack.pop()
        for y in g[x]:
            if y not in seen:
                seen.add(y)
                stack.append(y)
    return len(seen) == len(verts)


def is_k_connected(g: Graph, k: int) -> bool:
    """
    Cut-based vertex k-connectivity (Definition 2.1):

        k < |V|  and  for every S with |S| < k, G[V \\ S] is connected.
    """
    verts = vertices(g)
    n = len(verts)
    if not k < n:
        return False
    for size in range(0, k):  # |S| in {0, ..., k-1}
        for s in combinations(verts, size):
            keep = set(verts) - set(s)
            if not is_connected(induced_subgraph(g, keep)):
                return False
    return True


def connectivity(g: Graph) -> int:
    """The largest k for which G is k-connected (vertex connectivity kappa(G))."""
    k = 0
    while is_k_connected(g, k + 1):
        k += 1
    return k


# --------------------------------------------------------------------------- #
# Paths and edge deletion
# --------------------------------------------------------------------------- #
def path_edges(path: List[int]) -> Set[Edge]:
    """Edge set E(P) of a path given as a vertex sequence."""
    return {frozenset((path[i], path[i + 1])) for i in range(len(path) - 1)}


def path_neighbour_set(path: List[int], w: int) -> Set[int]:
    """N_P(w): neighbours of w in the subgraph spanned by the path."""
    nbrs: Set[int] = set()
    for e in path_edges(path):
        if w in e:
            nbrs |= (e - {w})
    return nbrs


def delete_edges(g: Graph, edges: Set[Edge]) -> Graph:
    """G - edges: delete the given edges from G."""
    h: Graph = {v: set(g[v]) for v in g}
    for e in edges:
        a, b = tuple(e)
        h[a].discard(b)
        h[b].discard(a)
    return h


def is_hamiltonian_path(g: Graph, path: List[int]) -> bool:
    """True iff `path` is a Hamiltonian path of G (visits all vertices once)."""
    if sorted(path) != vertices(g):
        return False
    return all(b in g[a] for a, b in zip(path, path[1:]))


def hamiltonian_paths(g: Graph, u: int, v: int) -> Iterable[List[int]]:
    """Yield all Hamiltonian u--v paths (brute force; small graphs only)."""
    others = [w for w in vertices(g) if w not in (u, v)]
    for mid in permutations(others):
        path = [u, *mid, v]
        if is_hamiltonian_path(g, path):
            yield path


# --------------------------------------------------------------------------- #
# Sample graphs
# --------------------------------------------------------------------------- #
def complete_graph(n: int) -> Graph:
    """K_n."""
    return {i: {j for j in range(n) if j != i} for i in range(n)}


def cycle_graph(n: int) -> Graph:
    """C_n."""
    return {i: {(i - 1) % n, (i + 1) % n} for i in range(n)}


def complete_bipartite(a: int, b: int) -> Graph:
    """K_{a,b} with parts {0..a-1} and {a..a+b-1}."""
    left, right = range(a), range(a, a + b)
    g: Graph = {i: set() for i in range(a + b)}
    for i in left:
        for j in right:
            g[i].add(j)
            g[j].add(i)
    return g


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_whitney_bound() -> None:
    """Theorem 2.3: in a k-connected graph every vertex has degree >= k."""
    print("=" * 70)
    print("Theorem 2.3  --  Whitney's easy bound  kappa(G) <= delta(G)")
    print("=" * 70)
    for name, g in [("K_6", complete_graph(6)),
                    ("C_7", cycle_graph(7)),
                    ("K_{3,4}", complete_bipartite(3, 4))]:
        kappa = connectivity(g)
        delta = min_degree(g)
        ok = all(degree(g, w) >= kappa for w in g)
        print(f"  {name:10s}  kappa={kappa}  delta={delta}  "
              f"every deg >= kappa? {ok}  (kappa <= delta: {kappa <= delta})")
    print()


def demo_path_is_thin() -> None:
    """Theorem 3.1: a vertex has at most two neighbours inside a path."""
    print("=" * 70)
    print("Theorem 3.1  --  Paths are thin:  |N_P(w)| <= 2")
    print("=" * 70)
    g = complete_graph(6)
    path = [0, 2, 4, 1, 5, 3]
    print(f"  path P = {path}")
    for w in vertices(g):
        npw = path_neighbour_set(path, w)
        role = ("endpoint" if w in (path[0], path[-1]) else "interior")
        print(f"    vertex {w} ({role:8s}): N_P = {sorted(npw)}  "
              f"|N_P| = {len(npw)} <= 2  -> {len(npw) <= 2}")
    print()


def demo_degree_drops_by_two() -> None:
    """Theorem 3.3: deg_G(w) <= deg_{G-E(P)}(w) + 2, tight at interior vertices."""
    print("=" * 70)
    print("Theorem 3.3  --  Degree drops by at most 2 under path deletion")
    print("=" * 70)
    g = complete_graph(7)
    path = [0, 3, 6, 1, 4, 2, 5]
    h = delete_edges(g, path_edges(path))
    print(f"  G = K_7,  Hamiltonian path P = {path}")
    for w in vertices(g):
        before, after = degree(g, w), degree(h, w)
        drop = before - after
        print(f"    vertex {w}: deg_G={before}  deg_(G-E(P))={after}  "
              f"drop={drop}  (<=2: {drop <= 2})")
    print()


def demo_degree_survival_4k4() -> None:
    """
    Theorem 3.4 / Corollary 3.5: under k>=2, n>=4k+4, delta>=ceil((n+1)/2),
    deleting any path's edges leaves minimum degree >= 2k+1 (surplus k+1 over k).
    """
    print("=" * 70)
    print("Theorem 3.4 / Cor 3.5  --  Degree survival >= 2k+1 (surplus k+1)")
    print("=" * 70)
    for k, n in [(2, 12), (3, 16), (4, 20)]:
        g = complete_graph(n)  # K_n satisfies all hypotheses generously
        thr = ceil((n + 1) / 2)
        assert n >= 4 * k + 4 and min_degree(g) >= thr and is_k_connected(g, k)
        # delete a Hamiltonian path 0,1,...,n-1
        path = list(range(n))
        h = delete_edges(g, path_edges(path))
        delta_after = min_degree(h)
        print(f"  k={k}, n={n}:  ceil((n+1)/2)={thr}  delta(G)={min_degree(g)}  "
              f"|  delta(G-E(P))={delta_after}  >= 2k+1={2*k+1}? "
              f"{delta_after >= 2*k+1}  surplus over k = {delta_after - k}")
    print()


def find_preserving_hamiltonian_path(
    g: Graph, u: int, v: int, k: int
) -> Optional[List[int]]:
    """
    Search for a Hamiltonian u--v path P with G - E(P) still k-connected
    (the conclusion of Conjecture_4k4).  Returns such a path or None.
    """
    for path in hamiltonian_paths(g, u, v):
        if is_k_connected(delete_edges(g, path_edges(path)), k):
            return path
    return None


def demo_conjecture_4k4_search() -> None:
    """
    Conjecture 4.1 (Conjecture_4k4): for k=2, n=4k+4=12, every K_n satisfies the
    hypotheses; we exhibit, for several ordered endpoint pairs, a Hamiltonian
    u--v path whose edge-deletion is still 2-connected.
    """
    print("=" * 70)
    print("Conjecture 4.1 (Conjecture_4k4)  --  prescribed-end search on K_12")
    print("=" * 70)
    k, n = 2, 12
    g = complete_graph(n)
    thr = ceil((n + 1) / 2)
    print(f"  k={k}, n={n}=4k+4  hypotheses: n>=4k+4 OK, "
          f"delta(G)={min_degree(g)}>=ceil((n+1)/2)={thr} OK, "
          f"k-connected={is_k_connected(g, k)}")
    for (u, v) in [(0, 1), (0, 6), (3, 9)]:
        path = find_preserving_hamiltonian_path(g, u, v, k)
        if path is None:
            print(f"    pair (u={u}, v={v}):  NO preserving path found (!)")
        else:
            h = delete_edges(g, path_edges(path))
            print(f"    pair (u={u}, v={v}):  P={path}  "
                  f"->  G-E(P) is {k}-connected "
                  f"(kappa={connectivity(h)}, delta={min_degree(h)})")
    print()


def demo_tightness_probe_4k3() -> None:
    """
    Future direction 6.3 (tightness probe): the same construction at n=4k+3 sits
    one vertex below the threshold; we report the surplus collapsing toward the
    boundary.  (Illustrative, not a counterexample search.)
    """
    print("=" * 70)
    print("Future direction 6.3  --  surplus near the 4k+4 boundary")
    print("=" * 70)
    for k in (2, 3, 4):
        for n in (4 * k + 3, 4 * k + 4):
            g = complete_graph(n)
            path = list(range(n))
            h = delete_edges(g, path_edges(path))
            surplus = min_degree(h) - k
            tag = "threshold" if n == 4 * k + 4 else "below    "
            print(f"  k={k}, n={n} ({tag}):  delta(G-E(P))={min_degree(h)}  "
                  f"surplus over k = {surplus}")
    print()


def main() -> None:
    demo_whitney_bound()
    demo_path_is_thin()
    demo_degree_drops_by_two()
    demo_degree_survival_4k4()
    demo_conjecture_4k4_search()
    demo_tightness_probe_4k3()


if __name__ == "__main__":
    main()
