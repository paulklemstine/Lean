"""
demo.py -- Numerical demonstrations of the clique-to-clique count bound and the
antitonicity of normalized clique densities.

Main mathematical facts demonstrated (all for a finite simple graph G on n
vertices, writing k_r(G) for the number of r-cliques):

  1. Clique-to-clique count bound:
         C(t,s) * k_t(G)  <=  C(n-s, t-s) * k_s(G)          for all s, t.
  2. Tightness: equality holds for the complete graph K_n (s <= t <= n).
  3. Antitonicity of normalized density d_r(G) = k_r(G) / C(n, r):
         d_t(G) <= d_s(G)                                   for s <= t <= n.

Everything is self-contained: no third-party dependencies.
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import Dict, FrozenSet, Iterable, List, Set, Tuple

# A graph is represented as (n, adjacency), where vertices are 0..n-1 and
# adjacency is a symmetric set of frozenset pairs {u, v}.
Graph = Tuple[int, Set[FrozenSet[int]]]


def make_graph(n: int, edges: Iterable[Tuple[int, int]]) -> Graph:
    """Build a simple graph on vertices 0..n-1 from an iterable of edges."""
    adj: Set[FrozenSet[int]] = set()
    for u, v in edges:
        if u == v:
            raise ValueError("simple graphs have no self-loops")
        adj.add(frozenset((u, v)))
    return n, adj


def complete_graph(n: int) -> Graph:
    """The complete graph K_n on vertices 0..n-1."""
    return make_graph(n, combinations(range(n), 2))

def complete_bipartite(a: int, b: int) -> Graph:
    """The complete bipartite graph K_{a,b} (triangle-free, many edges)."""
    left = range(a)
    right = range(a, a + b)
    return make_graph(a + b, ((u, v) for u in left for v in right))


def cycle_graph(n: int) -> Graph:
    """The cycle C_n."""
    return make_graph(n, ((i, (i + 1) % n) for i in range(n)))


def is_clique(adj: Set[FrozenSet[int]], vertices: Tuple[int, ...]) -> bool:
    """True iff every pair among `vertices` is an edge."""
    return all(frozenset((u, v)) in adj for u, v in combinations(vertices, 2))


def clique_count(graph: Graph, r: int) -> int:
    """k_r(G): number of r-cliques (r-subsets of vertices that are complete)."""
    n, adj = graph
    if r < 0 or r > n:
        return 0
    if r == 0:
        return 1
    if r == 1:
        return n
    return sum(1 for combo in combinations(range(n), r) if is_clique(adj, combo))


def normalized_density(graph: Graph, r: int) -> float:
    """d_r(G) = k_r(G) / C(n, r), the realized fraction of potential r-cliques."""
    n, _ = graph
    denom = comb(n, r)
    return clique_count(graph, r) / denom if denom else 0.0


def check_count_bound(graph: Graph, s: int, t: int) -> Tuple[int, int, bool]:
    """Return (lhs, rhs, holds) for C(t,s)*k_t <= C(n-s,t-s)*k_s."""
    n, _ = graph
    lhs = comb(t, s) * clique_count(graph, t)
    rhs = comb(n - s, t - s) * clique_count(graph, s)
    return lhs, rhs, lhs <= rhs


def check_antitone(graph: Graph, s: int, t: int) -> Tuple[float, float, bool]:
    """Return (d_t, d_s, holds) for the normalized-density antitonicity d_t <= d_s."""
    dt = normalized_density(graph, t)
    ds = normalized_density(graph, s)
    return dt, ds, dt <= ds + 1e-12


def demo_count_bound() -> None:
    print("=" * 70)
    print("1. Clique-to-clique count bound:  C(t,s)*k_t  <=  C(n-s,t-s)*k_s")
    print("=" * 70)
    graphs: Dict[str, Graph] = {
        "K_6 (complete)": complete_graph(6),
        "K_{3,3} (bipartite)": complete_bipartite(3, 3),
        "C_6 (cycle)": cycle_graph(6),
    }
    for name, g in graphs.items():
        print(f"\nGraph: {name},  n = {g[0]}")
        for s in range(2, 5):
            for t in range(s, 6):
                lhs, rhs, ok = check_count_bound(g, s, t)
                tag = "=" if lhs == rhs else "<"
                print(f"  s={s}, t={t}:  {lhs:5d} {tag}= {rhs:5d}   [{'OK' if ok else 'FAIL'}]")


def demo_tightness() -> None:
    print("\n" + "=" * 70)
    print("2. Tightness: equality for the complete graph K_n (s <= t <= n)")
    print("=" * 70)
    for n in range(3, 8):
        g = complete_graph(n)
        all_eq = True
        for s in range(2, n + 1):
            for t in range(s, n + 1):
                lhs, rhs, _ = check_count_bound(g, s, t)
                if lhs != rhs:
                    all_eq = False
        print(f"  K_{n}: all (s,t) pairs give equality?  {all_eq}")


def demo_antitone() -> None:
    print("\n" + "=" * 70)
    print("3. Antitonicity of normalized density d_r = k_r / C(n, r)")
    print("=" * 70)
    graphs: Dict[str, Graph] = {
        "K_7 (complete)": complete_graph(7),
        "K_{4,3} (bipartite)": complete_bipartite(4, 3),
        "C_7 (cycle)": cycle_graph(7),
    }
    for name, g in graphs.items():
        n = g[0]
        densities = [normalized_density(g, r) for r in range(1, n + 1)]
        print(f"\nGraph: {name},  n = {n}")
        print("  r :  " + "  ".join(f"{r:>6d}" for r in range(1, n + 1)))
        print("  d_r: " + "  ".join(f"{d:6.3f}" for d in densities))
        nonincreasing = all(densities[i] >= densities[i + 1] - 1e-12
                            for i in range(len(densities) - 1))
        print(f"  Non-increasing in r?  {nonincreasing}")


def main() -> None:
    demo_count_bound()
    demo_tightness()
    demo_antitone()
    print("\nAll demonstrated relations hold as predicted by the theory.")


if __name__ == "__main__":
    main()
