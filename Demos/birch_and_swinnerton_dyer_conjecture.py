"""
Numerical demonstrations of the Turán / Caro–Wei lower bound on the
independence number of a finite simple graph.

Main result:
    Every graph with n vertices and m edges has an independent set of size at
    least  n^2 / (2m + n).

This file is fully self-contained (standard library only). It

  * implements graphs, degrees, and the handshake identity;
  * implements the minimum-degree greedy algorithm that realizes the
    Caro–Wei weighted bound  sum_v 1/(deg v + 1) <= |S|;
  * verifies the chain  n^2/(2m+n) <= sum_v 1/(deg v + 1) <= |greedy set|
    on a battery of graphs;
  * exhibits the failure of the folklore bound  n^2/(4m);
  * confirms tightness on disjoint unions of equal cliques.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Dict, List, Set, Tuple

Vertex = int
Edge = Tuple[Vertex, Vertex]


# --------------------------------------------------------------------------- #
# Graph primitives
# --------------------------------------------------------------------------- #
class Graph:
    """A finite simple graph on vertices 0..n-1 stored as adjacency sets."""

    def __init__(self, n: int, edges: List[Edge]) -> None:
        self.n: int = n
        self.adj: List[Set[Vertex]] = [set() for _ in range(n)]
        for u, v in edges:
            if u == v:
                continue  # simple graph: no loops
            self.adj[u].add(v)
            self.adj[v].add(u)

    @property
    def m(self) -> int:
        """Number of edges (size)."""
        return sum(len(nbrs) for nbrs in self.adj) // 2

    def degree(self, v: Vertex) -> int:
        return len(self.adj[v])

    def is_independent(self, s: Set[Vertex]) -> bool:
        return all(v not in self.adj[u] for u, v in itertools.combinations(s, 2))


# --------------------------------------------------------------------------- #
# The three ingredients of the proof
# --------------------------------------------------------------------------- #
def handshake_check(g: Graph) -> bool:
    """Handshake identity: sum_v (deg v + 1) = 2m + n."""
    lhs = sum(g.degree(v) + 1 for v in range(g.n))
    rhs = 2 * g.m + g.n
    return lhs == rhs


def caro_wei_weight(g: Graph) -> float:
    """The Caro–Wei weighted lower bound  sum_v 1/(deg v + 1)."""
    return sum(1.0 / (g.degree(v) + 1) for v in range(g.n))


def turan_bound(g: Graph) -> float:
    """The clean lower bound  n^2 / (2m + n)."""
    return g.n ** 2 / (2 * g.m + g.n)


def folklore_bound(g: Graph) -> float:
    """The (generally FALSE) folklore bound  n^2 / (4m).  Returns inf if m=0."""
    return math.inf if g.m == 0 else g.n ** 2 / (4 * g.m)


# --------------------------------------------------------------------------- #
# Algorithm: minimum-degree greedy independent set
# --------------------------------------------------------------------------- #
def min_degree_greedy(g: Graph) -> Set[Vertex]:
    """
    Repeatedly pick a vertex of minimum degree in the remaining graph, add it
    to the independent set, and delete it together with all its neighbors.
    Provably returns a set of size >= sum_v 1/(deg v + 1) >= n^2/(2m+n).
    """
    remaining: Set[Vertex] = set(range(g.n))
    result: Set[Vertex] = set()
    while remaining:
        # minimum degree within the induced subgraph on `remaining`
        v = min(remaining, key=lambda x: len(g.adj[x] & remaining))
        result.add(v)
        remaining.discard(v)
        remaining -= g.adj[v]
    return result


def random_permutation_independent_set(g: Graph, seed: int = 0) -> Set[Vertex]:
    """
    Keep each vertex that precedes all its neighbors in a random ordering.
    The expected size equals the Caro–Wei sum.
    """
    rng = random.Random(seed)
    order = list(range(g.n))
    rng.shuffle(order)
    rank: Dict[Vertex, int] = {v: i for i, v in enumerate(order)}
    return {v for v in range(g.n)
            if all(rank[v] < rank[u] for u in g.adj[v])}


# --------------------------------------------------------------------------- #
# Sample graph constructors
# --------------------------------------------------------------------------- #
def cycle(n: int) -> Graph:
    return Graph(n, [(i, (i + 1) % n) for i in range(n)])


def complete(n: int) -> Graph:
    return Graph(n, list(itertools.combinations(range(n), 2)))


def disjoint_cliques(k: int, r: int) -> Graph:
    """k disjoint cliques each of order r (Turán's extremal family)."""
    edges: List[Edge] = []
    for c in range(k):
        base = c * r
        edges.extend((base + i, base + j)
                     for i, j in itertools.combinations(range(r), 2))
    return Graph(k * r, edges)


def random_graph(n: int, p: float, seed: int = 0) -> Graph:
    rng = random.Random(seed)
    edges = [(i, j) for i, j in itertools.combinations(range(n), 2)
             if rng.random() < p]
    return Graph(n, edges)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_chain_of_inequalities() -> None:
    print("=" * 72)
    print("DEMO 1:  n^2/(2m+n)  <=  Caro–Wei sum  <=  |greedy set|  <= alpha(G)")
    print("=" * 72)
    graphs = {
        "C_5 (5-cycle)": cycle(5),
        "C_10 (10-cycle)": cycle(10),
        "K_6 (complete)": complete(6),
        "G(20, 0.3) random": random_graph(20, 0.3, seed=1),
        "G(40, 0.1) random": random_graph(40, 0.1, seed=2),
    }
    for name, g in graphs.items():
        assert handshake_check(g), "handshake identity failed!"
        tb = turan_bound(g)
        cw = caro_wei_weight(g)
        s = min_degree_greedy(g)
        assert g.is_independent(s), "greedy set not independent!"
        ok = tb <= cw + 1e-9 <= len(s) + 1e-9
        print(f"{name:24s}  n={g.n:3d} m={g.m:4d}  "
              f"turan={tb:7.3f}  caro_wei={cw:7.3f}  |greedy|={len(s):3d}  "
              f"{'OK' if ok else 'FAIL'}")
    print()


def demo_folklore_failure() -> None:
    print("=" * 72)
    print("DEMO 2:  the folklore bound n^2/(4m) is FALSE for sparse graphs")
    print("=" * 72)
    # 100 vertices, a single edge.
    g = Graph(100, [(0, 1)])
    print(f"Graph: n={g.n}, m={g.m} (one edge among 100 vertices)")
    print(f"  folklore  n^2/(4m)   = {folklore_bound(g):8.2f}   "
          f"(> n = {g.n}  --> IMPOSSIBLE)")
    print(f"  true      n^2/(2m+n) = {turan_bound(g):8.2f}   (<= n, sensible)")
    s = min_degree_greedy(g)
    print(f"  greedy independent set has size {len(s)} (true alpha = 99)")
    print()
    print("Comparison n^2/(2m+n) vs n^2/(4m): equal-numerator, so")
    print("  n^2/(2m+n) >= n^2/(4m)  iff  n <= 2m  (Proposition 8).")
    for n, m in [(10, 2), (10, 5), (10, 20), (100, 1), (100, 200)]:
        g2 = type("G", (), {"n": n, "m": m})()  # lightweight stand-in
        t = n ** 2 / (2 * m + n)
        f = n ** 2 / (4 * m)
        relation = "true >= folklore" if t >= f else "true <  folklore"
        feasible = "n<=2m" if n <= 2 * m else "n> 2m (folklore illegal)"
        print(f"  n={n:3d} m={m:3d}:  true={t:8.2f}  folklore={f:8.2f}  "
              f"[{relation}; {feasible}]")
    print()


def demo_tightness() -> None:
    print("=" * 72)
    print("DEMO 3:  tightness on disjoint unions of equal cliques")
    print("=" * 72)
    print("For k cliques of order r:  alpha = k  and  n^2/(2m+n) = k exactly.")
    for k, r in [(3, 4), (5, 3), (4, 5), (10, 2)]:
        g = disjoint_cliques(k, r)
        tb = turan_bound(g)
        s = min_degree_greedy(g)
        print(f"  k={k:2d} r={r:2d}  n={g.n:3d} m={g.m:4d}  "
              f"alpha=k={k:2d}  turan={tb:6.3f}  |greedy|={len(s):2d}")
    print()


def demo_random_permutation_expectation() -> None:
    print("=" * 72)
    print("DEMO 4:  random-permutation method achieves Caro–Wei in expectation")
    print("=" * 72)
    g = random_graph(30, 0.2, seed=7)
    cw = caro_wei_weight(g)
    trials = 20000
    total = sum(len(random_permutation_independent_set(g, seed=t))
                for t in range(trials))
    avg = total / trials
    print(f"Graph G(30, 0.2): n={g.n}, m={g.m}")
    print(f"  Caro–Wei sum           = {cw:8.4f}")
    print(f"  empirical mean (|S|)   = {avg:8.4f}  over {trials} permutations")
    print(f"  difference             = {abs(cw - avg):8.4f}")
    print()


if __name__ == "__main__":
    demo_chain_of_inequalities()
    demo_folklore_failure()
    demo_tightness()
    demo_random_permutation_expectation()
    print("All demonstrations complete.")
