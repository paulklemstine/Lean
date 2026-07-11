"""
demo.py -- Numerical demonstrations for the chromatic sum of finite graphs.

The chromatic sum Sigma(G) of a finite simple graph G is the minimum, over all
proper colorings using positive integer colors {1,2,3,...}, of the total sum of
colors assigned to the vertices:

    Sigma(G) = min over proper c of  sum_v c(v).

This script computes Sigma(G) by exhaustive search over bounded colorings and
verifies, on concrete examples, every headline result:

    * Sigma(edgeless_n) = n
    * Sigma(K_n)        = n(n+1)/2  = |V| + |E|
    * Sigma(P_3)        = 4         (not |V| + |E| = 5)
    * Sigma(K_{1,n})    = n + 2
    * A chi-optimal 2-coloring of P_3 has sum 5 > 4 = Sigma(P_3)

A graph is represented as (num_vertices, edges), where edges is a set of
frozensets {u, v} of distinct vertices in range(num_vertices).

The script is fully self-contained: run `python demo.py`.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, FrozenSet, Iterable, List, Optional, Set, Tuple

Graph = Tuple[int, Set[FrozenSet[int]]]


# --------------------------------------------------------------------------- #
# Graph constructors                                                          #
# --------------------------------------------------------------------------- #
def edgeless(n: int) -> Graph:
    """The edgeless graph on n vertices (no edges)."""
    return n, set()


def complete(n: int) -> Graph:
    """The complete graph K_n: every pair of vertices adjacent."""
    edges: Set[FrozenSet[int]] = {
        frozenset((u, v)) for u in range(n) for v in range(u + 1, n)
    }
    return n, edges


def path(n: int) -> Graph:
    """The path P_n on vertices 0-1-...-(n-1)."""
    edges: Set[FrozenSet[int]] = {frozenset((i, i + 1)) for i in range(n - 1)}
    return n, edges


def star(n: int) -> Graph:
    """The star K_{1,n}: center 0 adjacent to leaves 1..n (n+1 vertices)."""
    edges: Set[FrozenSet[int]] = {frozenset((0, leaf)) for leaf in range(1, n + 1)}
    return n + 1, edges


# --------------------------------------------------------------------------- #
# Core combinatorics                                                          #
# --------------------------------------------------------------------------- #
def is_proper(graph: Graph, coloring: Tuple[int, ...]) -> bool:
    """Check that `coloring` (colors >= 1) properly colors `graph`."""
    _, edges = graph
    if any(color < 1 for color in coloring):
        return False
    return all(coloring[min(e)] != coloring[max(e)] for e in edges)


def color_sum(coloring: Iterable[int]) -> int:
    """The color sum sum_v c(v)."""
    return sum(coloring)


def chromatic_sum(graph: Graph, max_color: Optional[int] = None
                  ) -> Tuple[int, Tuple[int, ...]]:
    """
    Compute Sigma(G) by exhaustive search and return (Sigma, optimal coloring).

    An optimal coloring never needs a color larger than the number of vertices
    (a greedy first-fit argument), so `max_color = n` is a safe, sufficient
    search bound.
    """
    n, _ = graph
    if max_color is None:
        max_color = max(n, 1)
    best_sum: Optional[int] = None
    best_coloring: Tuple[int, ...] = tuple()
    for coloring in product(range(1, max_color + 1), repeat=n):
        if is_proper(graph, coloring):
            s = color_sum(coloring)
            if best_sum is None or s < best_sum:
                best_sum, best_coloring = s, coloring
    assert best_sum is not None, "every finite graph has a proper coloring"
    return best_sum, best_coloring


def chromatic_number(graph: Graph, max_color: Optional[int] = None) -> int:
    """The ordinary chromatic number chi(G) by exhaustive search."""
    n, _ = graph
    if max_color is None:
        max_color = max(n, 1)
    best: Optional[int] = None
    for coloring in product(range(1, max_color + 1), repeat=n):
        if is_proper(graph, coloring):
            used = len(set(coloring))
            if best is None or used < best:
                best = used
    assert best is not None
    return best


def num_edges(graph: Graph) -> int:
    """Number of edges |E|."""
    return len(graph[1])


def triangular(n: int) -> int:
    """The n-th triangular number 1 + 2 + ... + n = n(n+1)/2."""
    return n * (n + 1) // 2


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_edgeless() -> None:
    print("=" * 68)
    print("Edgeless graph:  Sigma(edgeless_n) = n")
    print("=" * 68)
    for n in range(1, 7):
        sigma, coloring = chromatic_sum(edgeless(n))
        assert sigma == n, (n, sigma)
        print(f"  n={n}:  Sigma = {sigma:2d}  (= n = {n})   optimal {coloring}")
    print()


def demo_complete() -> None:
    print("=" * 68)
    print("Complete graph:  Sigma(K_n) = n(n+1)/2 = |V| + |E|")
    print("=" * 68)
    for n in range(1, 7):
        g = complete(n)
        sigma, coloring = chromatic_sum(g)
        tri = triangular(n)
        v_plus_e = n + num_edges(g)
        assert sigma == tri == v_plus_e, (n, sigma, tri, v_plus_e)
        print(f"  n={n}:  Sigma = {sigma:2d}  triangular = {tri:2d}  "
              f"|V|+|E| = {v_plus_e:2d}   optimal {coloring}")
    print()


def demo_path3() -> None:
    print("=" * 68)
    print("Path P_3:  Sigma = 4, but |V| + |E| = 5  (naive formula FAILS)")
    print("=" * 68)
    g = path(3)
    sigma, coloring = chromatic_sum(g)
    v_plus_e = 3 + num_edges(g)
    print(f"  Sigma(P_3)  = {sigma}   optimal coloring {coloring} "
          f"(ends=1, center=2)")
    print(f"  |V| + |E|   = {v_plus_e}")
    assert sigma == 4 and v_plus_e == 5
    print("  => Sigma(P_3) = 4 != 5 = |V| + |E| : the closed form is refuted.")
    print()


def demo_star() -> None:
    print("=" * 68)
    print("Star K_{1,n}:  Sigma = n + 2  (center=2, leaves=1)")
    print("=" * 68)
    for n in range(1, 7):
        g = star(n)
        sigma, coloring = chromatic_sum(g)
        naive = 1 + 2 * n  # center=1, leaves=2 : the worse strategy
        assert sigma == n + 2, (n, sigma)
        print(f"  n={n}:  Sigma = {sigma:2d}  (= n+2 = {n + 2:2d})   "
              f"worse 'center=1' strategy costs {naive:2d}   optimal {coloring}")
    print()


def demo_chi_vs_sigma() -> None:
    print("=" * 68)
    print("chi-optimal need NOT be sum-optimal (witnessed by P_3)")
    print("=" * 68)
    g = path(3)
    sigma, opt = chromatic_sum(g)
    chi = chromatic_number(g)
    # A proper 2-coloring using exactly chi colors but with a larger sum:
    bad: Tuple[int, ...] = (2, 1, 2)  # endpoints 2, center 1
    assert is_proper(g, bad) and len(set(bad)) == chi
    print(f"  chi(P_3)              = {chi}")
    print(f"  Sigma(P_3)            = {sigma}   via {opt}")
    print(f"  2-coloring {bad} sum  = {color_sum(bad)}  "
          f"(uses exactly chi={chi} colors, yet sum {color_sum(bad)} > {sigma})")
    assert color_sum(bad) == 5 > sigma
    print("  => minimizing #colors does not minimize the color sum.")
    print()


def demo_monotonicity() -> None:
    print("=" * 68)
    print("Monotonicity:  H subgraph of G  =>  Sigma(H) <= Sigma(G)")
    print("=" * 68)
    # Build a chain: edgeless_4 <= P_4 <= C_4-ish <= K_4 (add edges).
    n = 4
    layers: List[Tuple[str, Graph]] = [
        ("edgeless", edgeless(n)),
        ("path P_4", path(n)),
        ("complete K_4", complete(n)),
    ]
    prev_sigma: Optional[int] = None
    prev_edges: Set[FrozenSet[int]] = set()
    for name, g in layers:
        assert prev_edges <= g[1], "each layer should contain the previous edges"
        sigma, _ = chromatic_sum(g)
        rel = "" if prev_sigma is None else f"  (>= previous {prev_sigma})"
        if prev_sigma is not None:
            assert sigma >= prev_sigma
        print(f"  {name:14s}: |E| = {num_edges(g)}   Sigma = {sigma}{rel}")
        prev_sigma, prev_edges = sigma, g[1]
    print()


def main() -> None:
    print()
    print("CHROMATIC SUM -- NUMERICAL DEMONSTRATIONS")
    print()
    demo_edgeless()
    demo_complete()
    demo_path3()
    demo_star()
    demo_chi_vs_sigma()
    demo_monotonicity()
    print("All assertions passed: every headline result verified numerically.")


if __name__ == "__main__":
    main()
