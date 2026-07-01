"""Numerical demonstrations for the Coloring-Independence Bound and the
independence ratio of unit-distance graphs.

This self-contained script illustrates, with concrete computations:

  1. The pigeonhole engine: a proper k-coloring always has a color class of
     size at least n/k (Lemma "Large color class").
  2. The Coloring-Independence Bound: rho(G) >= 1/k for every k-colorable graph.
  3. Sharpness: the complete graph K_k attains rho(K_k) = 1/k exactly.
  4. The explicit planar witness: the unit equilateral triangle is K_3 with
     independence ratio exactly 1/3 > 1/4.
  5. The theorem-versus-conjecture boundary: a five-chromatic-flavored dense
     graph where the coloring engine only certifies 1/5.

Run:  python demo.py
"""

from __future__ import annotations

import itertools
import math
from fractions import Fraction
from typing import Dict, List, Sequence, Set, Tuple

Point = Tuple[float, float]
Graph = Dict[int, Set[int]]  # adjacency sets, vertices 0..n-1


# --------------------------------------------------------------------------- #
# Core graph utilities
# --------------------------------------------------------------------------- #
def complete_graph(k: int) -> Graph:
    """Return the complete graph K_k as an adjacency-set map."""
    return {i: {j for j in range(k) if j != i} for i in range(k)}


def unit_distance_graph(points: Sequence[Point], tol: float = 1e-9) -> Graph:
    """Build the unit-distance graph of a family of planar points.

    Vertices i and j are adjacent iff i != j and the Euclidean distance between
    points[i] and points[j] is within `tol` of 1.
    """
    n = len(points)
    adj: Graph = {i: set() for i in range(n)}
    for i, j in itertools.combinations(range(n), 2):
        d = math.dist(points[i], points[j])
        if abs(d - 1.0) <= tol:
            adj[i].add(j)
            adj[j].add(i)
    return adj


def is_independent(graph: Graph, subset: Sequence[int]) -> bool:
    """True iff no two distinct vertices in `subset` are adjacent."""
    s = set(subset)
    return all(not (graph[u] & s - {u}) for u in s)


def independence_number(graph: Graph) -> int:
    """Exact independence number by brute-force enumeration (small graphs)."""
    vertices = list(graph.keys())
    best = 0
    for r in range(len(vertices), -1, -1):
        for subset in itertools.combinations(vertices, r):
            if is_independent(graph, subset):
                return r  # first (largest) independent set found
    return best


def independence_ratio(graph: Graph) -> Fraction:
    """Exact independence ratio alpha(G)/n as a Fraction."""
    n = len(graph)
    if n == 0:
        return Fraction(0)
    return Fraction(independence_number(graph), n)


# --------------------------------------------------------------------------- #
# Coloring engine
# --------------------------------------------------------------------------- #
def greedy_coloring(graph: Graph) -> Dict[int, int]:
    """A proper coloring via greedy first-fit (colors 0,1,2,...)."""
    color: Dict[int, int] = {}
    for v in sorted(graph):
        used = {color[u] for u in graph[v] if u in color}
        c = 0
        while c in used:
            c += 1
        color[v] = c
    return color


def largest_color_class(graph: Graph) -> Tuple[int, List[int]]:
    """Return (number_of_colors_used, a largest color class) for a greedy coloring.

    The returned class is independent and has size at least n / k, illustrating
    the pigeonhole engine.
    """
    color = greedy_coloring(graph)
    k = max(color.values()) + 1 if color else 0
    classes: Dict[int, List[int]] = {}
    for v, c in color.items():
        classes.setdefault(c, []).append(v)
    largest = max(classes.values(), key=len)
    return k, largest


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_pigeonhole_and_bound() -> None:
    print("=" * 70)
    print("1-2. Pigeonhole engine and the Coloring-Independence Bound")
    print("=" * 70)
    for k in (2, 3, 4, 5):
        G = complete_graph(k)
        n = len(G)
        num_colors, cls = largest_color_class(G)
        assert is_independent(G, cls)
        assert n <= num_colors * len(cls)  # n <= k * |S|
        print(
            f"K_{k}: n={n}, colors used={num_colors}, "
            f"largest color class size={len(cls)}, "
            f"n <= k*|S| holds ({n} <= {num_colors * len(cls)})"
        )


def demo_sharpness() -> None:
    print("\n" + "=" * 70)
    print("3. Sharpness: rho(K_k) = 1/k exactly")
    print("=" * 70)
    for k in (1, 2, 3, 4, 5, 6):
        G = complete_graph(k)
        rho = independence_ratio(G)
        assert rho == Fraction(1, k)
        print(f"K_{k}: independence ratio = {rho} (= 1/{k})")


def demo_equilateral_triangle() -> None:
    print("\n" + "=" * 70)
    print("4. Planar witness: unit equilateral triangle")
    print("=" * 70)
    pts: List[Point] = [(0.0, 0.0), (1.0, 0.0), (0.5, math.sqrt(3) / 2)]
    for i, j in itertools.combinations(range(3), 2):
        d = math.dist(pts[i], pts[j])
        print(f"  dist(p{i}, p{j}) = {d:.15f}")
        assert abs(d - 1.0) < 1e-12
    G = unit_distance_graph(pts)
    # It is exactly K_3: every distinct pair adjacent.
    assert all(G[i] == {0, 1, 2} - {i} for i in range(3))
    rho = independence_ratio(G)
    print(f"  Unit-distance graph is K_3; independence ratio = {rho}")
    print(f"  1/3 = {float(rho):.4f} > 1/4 = 0.2500  -> clears the quarter bound")
    assert rho == Fraction(1, 3)
    assert rho > Fraction(1, 4)


def demo_theorem_vs_conjecture() -> None:
    print("\n" + "=" * 70)
    print("5. Theorem vs. conjecture: a K_5 needs 5 colors")
    print("=" * 70)
    G = complete_graph(5)
    num_colors, cls = largest_color_class(G)
    print(
        f"  K_5 requires {num_colors} colors; coloring engine certifies only "
        f"rho >= 1/{num_colors} = {Fraction(1, num_colors)}"
    )
    print("  A 4-coloring would give 1/4 -- but no 4-coloring of K_5 exists.")
    print("  This mirrors why the *unconditional* planar quarter claim does not")
    print("  follow from colorability: five-chromatic planar unit-distance graphs")
    print("  exist (de Grey, 2018), and the plane's best lower bounds are < 1/4.")


def main() -> None:
    demo_pigeonhole_and_bound()
    demo_sharpness()
    demo_equilateral_triangle()
    demo_theorem_vs_conjecture()
    print("\nAll demonstrations completed and assertions verified.")


if __name__ == "__main__":
    main()
