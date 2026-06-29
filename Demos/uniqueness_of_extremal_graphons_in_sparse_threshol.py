"""
demo.py -- Numerical demonstrations for

    "The Fractional Independence Number and Its Sparse-Threshold Sandwich"

This script computes the fractional independence number

    alpha*(G) = max { sum_v x_v : 0 <= x_v <= 1, x_u + x_v <= 1 for every edge uv }

for finite simple graphs and verifies, on concrete instances, the four main
theorems of the paper:

    * alphaStar_le_card                 : alpha*(G) <= n
    * half_card_le_alphaStar            : n/2 <= alpha*(G)        (all-half certificate)
    * alphaStar_le_card_sub_one_of_edge : one edge => alpha*(G) <= n - 1
    * alphaStar_completeGraph           : alpha*(K_n) = n/2  for n >= 2

The LP relaxation of independent set is half-integral (Nemhauser-Trotter, 1975):
some optimal vertex has every coordinate in {0, 1/2, 1}. We exploit this by
maximizing over the finite grid {0, 1/2, 1}^n, which yields the *exact* LP optimum
for the small graphs used here -- no external solver required.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Iterable

# A graph is given by its number of vertices n and its set of (undirected) edges.
Edge = tuple[int, int]
Graph = tuple[int, frozenset[Edge]]


def make_graph(n: int, edges: Iterable[Edge]) -> Graph:
    """Build a simple graph on vertices {0,...,n-1} from an edge list."""
    norm: set[Edge] = set()
    for u, v in edges:
        if u == v:
            raise ValueError("simple graphs have no self-loops")
        norm.add((min(u, v), max(u, v)))
    return n, frozenset(norm)


def complete_graph(n: int) -> Graph:
    """The complete graph K_n: every pair of distinct vertices is adjacent."""
    return make_graph(n, ((u, v) for u in range(n) for v in range(u + 1, n)))


def cycle_graph(n: int) -> Graph:
    """The cycle C_n on n >= 3 vertices."""
    return make_graph(n, ((i, (i + 1) % n) for i in range(n)))


def path_graph(n: int) -> Graph:
    """The path P_n on n vertices."""
    return make_graph(n, ((i, i + 1) for i in range(n - 1)))


def is_feasible(x: tuple[float, ...], graph: Graph) -> bool:
    """Check Definition 2.1: 0 <= x_v <= 1 and x_u + x_v <= 1 on every edge."""
    _, edges = graph
    if any(not (0.0 <= xi <= 1.0 + 1e-12) for xi in x):
        return False
    return all(x[u] + x[v] <= 1.0 + 1e-12 for (u, v) in edges)


def frac_indep_value(x: tuple[float, ...]) -> float:
    """Definition 2.2: val(x) = sum_v x_v."""
    return float(sum(x))


def alpha_star(graph: Graph) -> float:
    """
    Definition 2.4: alpha*(G) = sup over the feasible polytope of val(x).

    Computed exactly via the half-integral grid {0, 1/2, 1}^n (Nemhauser-Trotter).
    """
    n, _ = graph
    grid = (0.0, 0.5, 1.0)
    best = 0.0  # x == 0 is always feasible (Lemma 3.1)
    for x in product(grid, repeat=n):
        if is_feasible(x, graph):
            best = max(best, frac_indep_value(x))
    return best


def edge_count(graph: Graph) -> int:
    _, edges = graph
    return len(edges)


def report(name: str, graph: Graph) -> None:
    """Compute alpha* and check every theorem's prediction for one graph."""
    n, _ = graph
    a = alpha_star(graph)
    lower = n / 2.0                       # Theorem 3.6
    ceiling = float(n)                    # Theorem 3.4
    edge_ceiling = (n - 1.0) if edge_count(graph) > 0 else float(n)  # Theorem 3.7

    print(f"  {name:<14} n={n}  edges={edge_count(graph):>2}  alpha* = {a:g}")
    assert lower - 1e-9 <= a <= ceiling + 1e-9, "sandwich violated"
    assert a <= edge_ceiling + 1e-9, "single-edge ceiling violated"
    print(f"      sandwich      :  {lower:g} <= {a:g} <= {ceiling:g}      [OK]")
    if edge_count(graph) > 0:
        print(f"      one-edge cap  :  {a:g} <= n-1 = {n-1:g}            [OK]")


def main() -> None:
    print("=" * 64)
    print("Theorem 3.6 / 3.4 -- the universal sandwich  n/2 <= alpha* <= n")
    print("=" * 64)
    report("empty K0bar^5", make_graph(5, []))   # edgeless: alpha* = n = 5
    report("path P3", path_graph(3))
    report("cycle C4", cycle_graph(4))
    report("cycle C5", cycle_graph(5))
    report("Petersen-ish", make_graph(6, [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5)]))

    print()
    print("=" * 64)
    print("Theorem 3.8 -- complete graphs sit exactly on the floor: a*(K_n)=n/2")
    print("=" * 64)
    for n in range(2, 9):
        a = alpha_star(complete_graph(n))
        predicted = n / 2.0
        status = "OK" if abs(a - predicted) < 1e-9 else "MISMATCH"
        print(f"  K_{n:<2}  alpha* = {a:g}   predicted n/2 = {predicted:g}   [{status}]")
        assert abs(a - predicted) < 1e-9

    print()
    print("=" * 64)
    print("Integrality gap: alpha*(K_n) / alpha(K_n) = (n/2) / 1 = n/2")
    print("=" * 64)
    for n in range(2, 7):
        a_frac = alpha_star(complete_graph(n))
        a_int = 1  # the integral independence number of K_n is 1
        print(f"  K_{n:<2}  alpha* = {a_frac:g}   alpha = {a_int}   gap = {a_frac / a_int:g}")

    print()
    print("All theorem predictions verified on every test instance.")


if __name__ == "__main__":
    main()
