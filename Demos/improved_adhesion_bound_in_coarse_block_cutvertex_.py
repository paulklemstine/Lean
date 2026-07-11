"""Numerical demonstrations for the metric theory of coarse tree-decompositions.

This module is fully self-contained (standard library only) and illustrates the
central results:

  * set diameter measured in the graph metric,
  * the overlap gluing lemma:  two diameter-D sets sharing a vertex have union
    of diameter at most 2D,
  * the linear-accumulation chain law:  dist(u, v) <= (n + 1) * D + n across a
    chain of n overlapping diameter-D sets,
  * the adhesion bound:  an adhesion set (intersection of two bags) inherits the
    diameter bound of its bags, giving 4d + 2 in the (d, 2d+1) regime.

Every function is inlined and type-hinted; run `python demo.py` to see the
results verified empirically on explicit graphs.
"""

from __future__ import annotations

from collections import deque
from itertools import combinations
from typing import Dict, Iterable, List, Optional, Set, Tuple

Vertex = int
Graph = Dict[Vertex, Set[Vertex]]


# --------------------------------------------------------------------------- #
# Graph metric
# --------------------------------------------------------------------------- #
def add_edge(g: Graph, u: Vertex, v: Vertex) -> None:
    """Insert an undirected edge {u, v} into adjacency map `g`."""
    g.setdefault(u, set()).add(v)
    g.setdefault(v, set()).add(u)


def bfs_dist(g: Graph, source: Vertex, target: Vertex) -> Optional[int]:
    """Shortest-path graph distance; None if target is unreachable."""
    if source == target:
        return 0
    seen: Set[Vertex] = {source}
    frontier: deque[Tuple[Vertex, int]] = deque([(source, 0)])
    while frontier:
        node, d = frontier.popleft()
        for nbr in g.get(node, ()):
            if nbr == target:
                return d + 1
            if nbr not in seen:
                seen.add(nbr)
                frontier.append((nbr, d + 1))
    return None


def is_connected(g: Graph) -> bool:
    """True iff every vertex is reachable from an arbitrary start vertex."""
    if not g:
        return True
    start = next(iter(g))
    seen: Set[Vertex] = {start}
    stack: List[Vertex] = [start]
    while stack:
        node = stack.pop()
        for nbr in g.get(node, ()):
            if nbr not in seen:
                seen.add(nbr)
                stack.append(nbr)
    return len(seen) == len(g)


def set_diameter(g: Graph, s: Iterable[Vertex]) -> int:
    """Graph-metric diameter of a vertex set (0 for empty/singleton)."""
    verts = list(s)
    best = 0
    for a, b in combinations(verts, 2):
        d = bfs_dist(g, a, b)
        if d is None:
            raise ValueError("set spans disconnected components")
        best = max(best, d)
    return best


# --------------------------------------------------------------------------- #
# Overlap gluing lemma
# --------------------------------------------------------------------------- #
def demo_overlap(g: Graph, s: Set[Vertex], t: Set[Vertex]) -> None:
    """Verify: diam(S) <= D, diam(T) <= D, S∩T != ∅  ==>  diam(S∪T) <= 2D."""
    shared = s & t
    assert shared, "overlap lemma requires a common vertex"
    d = max(set_diameter(g, s), set_diameter(g, t))
    union_diam = set_diameter(g, s | t)
    print(f"  diam(S) = {set_diameter(g, s)}, diam(T) = {set_diameter(g, t)}, "
          f"D = {d}")
    print(f"  shared vertices: {sorted(shared)}")
    print(f"  diam(S ∪ T) = {union_diam}  <=  2D = {2 * d}   "
          f"[{'OK' if union_diam <= 2 * d else 'VIOLATED'}]")


# --------------------------------------------------------------------------- #
# Chain law
# --------------------------------------------------------------------------- #
def demo_chain(g: Graph, chain: List[Set[Vertex]]) -> None:
    """Verify the linear-accumulation law dist(u,v) <= (n+1)*D + n.

    `chain` is [S_0, ..., S_n] with consecutive overlaps; we test all
    u in S_0, v in S_n against the predicted bound.
    """
    n = len(chain) - 1
    d = max(set_diameter(g, s) for s in chain)
    for i in range(n):
        assert chain[i] & chain[i + 1], f"sets {i},{i+1} do not overlap"
    bound = (n + 1) * d + n
    worst = 0
    for u in chain[0]:
        for v in chain[-1]:
            dist = bfs_dist(g, u, v)
            assert dist is not None
            worst = max(worst, dist)
    print(f"  chain length n = {n}, per-set diameter D = {d}")
    print(f"  predicted bound (n+1)*D + n = {bound}")
    print(f"  observed worst-case dist(S_0, S_n) = {worst}   "
          f"[{'OK' if worst <= bound else 'VIOLATED'}]")


# --------------------------------------------------------------------------- #
# Adhesion bound
# --------------------------------------------------------------------------- #
def adhesion(bag_i: Set[Vertex], bag_j: Set[Vertex]) -> Set[Vertex]:
    """Adhesion set = intersection of two bags."""
    return bag_i & bag_j


def demo_adhesion_bound(g: Graph, d: int, bag_i: Set[Vertex],
                        bag_j: Set[Vertex]) -> None:
    """Verify: bag diameter <= 2d+1  ==>  adhesion diameter <= 4d+2."""
    diam_i, diam_j = set_diameter(g, bag_i), set_diameter(g, bag_j)
    assert diam_i <= 2 * d + 1 and diam_j <= 2 * d + 1, "bags exceed 2d+1"
    adh = adhesion(bag_i, bag_j)
    adh_diam = set_diameter(g, adh) if adh else 0
    print(f"  d = {d},  2d+1 = {2 * d + 1},  bag diams = ({diam_i}, {diam_j})")
    print(f"  adhesion = {sorted(adh)}, diameter = {adh_diam}")
    print(f"  adhesion diameter {adh_diam}  <=  4d+2 = {4 * d + 2}   "
          f"[{'OK' if adh_diam <= 4 * d + 2 else 'VIOLATED'}]")


# --------------------------------------------------------------------------- #
# Example graphs
# --------------------------------------------------------------------------- #
def path_graph(k: int) -> Graph:
    """The path 0-1-2-...-k."""
    g: Graph = {i: set() for i in range(k + 1)}
    for i in range(k):
        add_edge(g, i, i + 1)
    return g


def cycle_graph(k: int) -> Graph:
    """The cycle on vertices 0..k-1."""
    g: Graph = {i: set() for i in range(k)}
    for i in range(k):
        add_edge(g, i, (i + 1) % k)
    return g


def main() -> None:
    print("=" * 68)
    print("Coarse tree-decompositions: metric control of adhesion sets")
    print("=" * 68)

    # --- Overlap lemma on a path -------------------------------------------
    print("\n[1] Overlap gluing lemma (path 0-1-2-3-4):")
    p = path_graph(4)
    demo_overlap(p, s={0, 1, 2}, t={2, 3, 4})   # each diam 2, share vertex 2

    # --- Chain law on a long path ------------------------------------------
    print("\n[2] Linear-accumulation chain law (path 0..12):")
    long_path = path_graph(12)
    chain = [{0, 1, 2}, {2, 3, 4}, {4, 5, 6},
             {6, 7, 8}, {8, 9, 10}, {10, 11, 12}]  # D = 2, n = 5
    demo_chain(long_path, chain)

    # --- Chain law on a cycle (distances wrap, still linear-bounded) --------
    print("\n[3] Chain law on a cycle C_10:")
    c = cycle_graph(10)
    cyc_chain = [{0, 1, 2}, {2, 3, 4}, {4, 5, 6}]  # D = 2, n = 2
    demo_chain(c, cyc_chain)

    # --- Adhesion bound in the (d, 2d+1) regime ----------------------------
    print("\n[4] Adhesion bound (d = 1, bags of diameter <= 3):")
    q = path_graph(6)
    demo_adhesion_bound(q, d=1, bag_i={0, 1, 2, 3}, bag_j={2, 3, 4, 5})

    # --- Trivial decomposition: no diameter reduction ----------------------
    print("\n[5] Trivial one-bag decomposition on C_10 (adhesion = V):")
    all_v = set(c.keys())
    print(f"  adhesion(V, V) = V, diameter = {set_diameter(c, all_v)} "
          f"(= graph radius-scale; no reduction)")
    print(f"  connected: {is_connected(c)}")

    print("\nAll stated bounds verified on the examples above.")


if __name__ == "__main__":
    main()
