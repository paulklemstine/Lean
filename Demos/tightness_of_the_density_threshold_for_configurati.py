"""
Numerical demonstrations for:

    Exact Characterization of Tight Configurations in Linear r-Uniform Hypergraphs

A hypergraph is LINEAR when any two distinct edges share at most one vertex.
For a linear r-uniform hypergraph on n vertices with m edges, the packing bound is

        m * C(r, 2) <= C(n, 2).

Main results demonstrated here:
  * Theorem 1 (global tightness): equality  m*C(r,2) = C(n,2)  holds  <=>  every
    pair of vertices is covered, i.e. the hypergraph is a Steiner system S(2,r,n).
  * Theorem 2 (local bound): for every vertex v,  deg(v)*(r-1) <= n-1.
  * Theorem 3 (local tightness): equality  deg(v)*(r-1) = n-1  <=>  the edges
    through v cover every other vertex.
  * Theorem 4 (regularity): a covering (Steiner) linear hypergraph has every
    vertex of equal degree  deg(v) = (n-1)/(r-1).

The script is fully self-contained: run `python demo.py`.
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import FrozenSet, Iterable, List, Set, Tuple

Vertex = int
Edge = FrozenSet[Vertex]


# --------------------------------------------------------------------------- #
# Core combinatorial primitives                                               #
# --------------------------------------------------------------------------- #
def is_uniform(edges: Iterable[Edge], r: int) -> bool:
    """Return True iff every edge has exactly r vertices (r-uniformity)."""
    return all(len(e) == r for e in edges)


def is_linear(edges: List[Edge]) -> bool:
    """Return True iff any two distinct edges meet in at most one vertex."""
    for e1, e2 in combinations(edges, 2):
        if len(e1 & e2) > 1:
            return False
    return True


def covered_pairs(edges: Iterable[Edge]) -> Set[Tuple[Vertex, Vertex]]:
    """The set of unordered vertex pairs covered by at least one edge."""
    pairs: Set[Tuple[Vertex, Vertex]] = set()
    for e in edges:
        for a, b in combinations(sorted(e), 2):
            pairs.add((a, b))
    return pairs


def all_pairs(vertices: Iterable[Vertex]) -> Set[Tuple[Vertex, Vertex]]:
    """All C(n,2) unordered pairs of the vertex set."""
    return set(combinations(sorted(vertices), 2))


def degree(edges: Iterable[Edge], v: Vertex) -> int:
    """Number of edges through vertex v (the size of its link)."""
    return sum(1 for e in edges if v in e)


def covers_all_pairs(vertices: Iterable[Vertex], edges: List[Edge]) -> bool:
    """Whether the family covers every pair of the vertex set (Steiner condition)."""
    return covered_pairs(edges) == all_pairs(vertices)


# --------------------------------------------------------------------------- #
# Theorem checks                                                              #
# --------------------------------------------------------------------------- #
def packing_status(n: int, r: int, edges: List[Edge]) -> Tuple[int, int, bool]:
    """Return (m*C(r,2), C(n,2), is_equality) -- the global packing bound."""
    m = len(edges)
    lhs = m * comb(r, 2)
    rhs = comb(n, 2)
    return lhs, rhs, lhs == rhs


def link_covers(vertices: Iterable[Vertex], edges: List[Edge], v: Vertex) -> bool:
    """Whether the edges through v reach every other vertex u != v."""
    reached: Set[Vertex] = set()
    for e in edges:
        if v in e:
            reached |= set(e)
    reached.discard(v)
    return reached == (set(vertices) - {v})


def verify_global_tightness(n: int, r: int, edges: List[Edge]) -> None:
    """Theorem 1: m*C(r,2) = C(n,2)  <=>  covers all pairs."""
    lhs, rhs, eq = packing_status(n, r, edges)
    cov = covers_all_pairs(range(n), edges)
    print(f"  Theorem 1 (global): m*C(r,2) = {lhs}, C(n,2) = {rhs}, "
          f"equality = {eq}, covers-all-pairs = {cov}  ->  match = {eq == cov}")
    assert eq == cov, "Theorem 1 violated!"


def verify_local_bound_and_tightness(n: int, r: int, edges: List[Edge]) -> None:
    """Theorems 2 & 3: deg(v)*(r-1) <= n-1, with equality <=> link covers."""
    all_ok_bound = True
    all_ok_tight = True
    degrees: List[int] = []
    for v in range(n):
        d = degree(edges, v)
        degrees.append(d)
        bound_ok = d * (r - 1) <= n - 1
        eq = d * (r - 1) == n - 1
        cov = link_covers(range(n), edges, v)
        all_ok_bound &= bound_ok
        all_ok_tight &= (eq == cov)
    print(f"  Theorem 2 (local bound deg*(r-1)<=n-1): all hold = {all_ok_bound}")
    print(f"  Theorem 3 (local tightness <=> link covers): all match = {all_ok_tight}")
    print(f"  degrees = {degrees}")
    assert all_ok_bound and all_ok_tight


def verify_regularity(n: int, r: int, edges: List[Edge]) -> None:
    """Theorem 4: a covering linear hypergraph is regular with deg=(n-1)/(r-1)."""
    if not covers_all_pairs(range(n), edges):
        print("  Theorem 4: (not a covering system; regularity not asserted)")
        return
    degrees = [degree(edges, v) for v in range(n)]
    expected = (n - 1) // (r - 1)
    regular = all(d == expected for d in degrees)
    print(f"  Theorem 4 (regularity): every deg = (n-1)/(r-1) = {expected}  ->  {regular}")
    assert regular


# --------------------------------------------------------------------------- #
# Example hypergraphs                                                         #
# --------------------------------------------------------------------------- #
def fano_plane() -> Tuple[int, int, List[Edge]]:
    """The Fano plane S(2,3,7): the smallest nontrivial Steiner system."""
    blocks = [
        {0, 1, 2}, {0, 3, 4}, {0, 5, 6},
        {1, 3, 5}, {1, 4, 6}, {2, 3, 6}, {2, 4, 5},
    ]
    return 7, 3, [frozenset(b) for b in blocks]


def affine_plane_order_3() -> Tuple[int, int, List[Edge]]:
    """The Steiner triple system S(2,3,9) = AG(2,3): 9 points, 12 lines."""
    pts = [(x, y) for x in range(3) for y in range(3)]
    idx = {p: i for i, p in enumerate(pts)}
    lines: List[Edge] = []
    # Lines y = a*x + b  and vertical lines x = c, over GF(3).
    for a in range(3):
        for b in range(3):
            lines.append(frozenset(idx[(x, (a * x + b) % 3)] for x in range(3)))
    for c in range(3):
        lines.append(frozenset(idx[(c, y)] for y in range(3)))
    return 9, 3, lines


def non_steiner_linear() -> Tuple[int, int, List[Edge]]:
    """A linear, r-uniform, but NOT covering family: strictly below threshold."""
    # Two disjoint triples on 7 vertices: linear, 3-uniform, far from tight.
    return 7, 3, [frozenset({0, 1, 2}), frozenset({3, 4, 5})]


# --------------------------------------------------------------------------- #
# Main driver                                                                 #
# --------------------------------------------------------------------------- #
def report(name: str, n: int, r: int, edges: List[Edge]) -> None:
    print(f"\n=== {name}  (n={n}, r={r}, m={len(edges)}) ===")
    print(f"  uniform = {is_uniform(edges, r)}, linear = {is_linear(edges)}")
    verify_global_tightness(n, r, edges)
    verify_local_bound_and_tightness(n, r, edges)
    verify_regularity(n, r, edges)


def main() -> None:
    print("Tightness of the density threshold for linear r-uniform hypergraphs")
    print("=" * 70)

    n, r, edges = fano_plane()
    report("Fano plane S(2,3,7)  [Steiner: tight global+local]", n, r, edges)

    n, r, edges = affine_plane_order_3()
    report("Affine plane AG(2,3) = S(2,3,9)  [Steiner: tight]", n, r, edges)

    n, r, edges = non_steiner_linear()
    report("Two disjoint triples  [linear, NOT covering: not tight]", n, r, edges)

    print("\nAll theorem checks passed.")


if __name__ == "__main__":
    main()


"""
Visualization: the Fano plane S(2,3,7) and the pair-packing equality.

Renders the Fano plane (7 points, 7 lines, the seventh "line" drawn as the
incircle) and a bar chart contrasting m*C(r,2) with C(n,2) for several linear
hypergraphs, illustrating Theorem 1 (global tightness: equality <=> Steiner).

Requires matplotlib. Run:  python visualize_packing.py
"""

from __future__ import annotations

from math import comb, cos, pi, sin
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt


def fano_coordinates() -> Dict[int, Tuple[float, float]]:
    """Standard triangle layout: 3 corners, 3 edge-midpoints, 1 center."""
    corners = [(cos(pi / 2 + 2 * pi * k / 3), sin(pi / 2 + 2 * pi * k / 3))
               for k in range(3)]
    mids = [((corners[i][0] + corners[(i + 1) % 3][0]) / 2,
             (corners[i][1] + corners[(i + 1) % 3][1]) / 2) for i in range(3)]
    center = (0.0, 0.0)
    pts = corners + mids + [center]
    return {i: pts[i] for i in range(7)}


def draw_fano(ax: plt.Axes) -> None:
    coords = fano_coordinates()
    # Lines as point triples; the central circle is the "curved" line.
    lines = [(0, 3, 1), (1, 4, 2), (2, 5, 0), (0, 6, 4), (1, 6, 5), (2, 6, 3)]
    circle = (3, 4, 5)
    for a, b, c in lines:
        xs = [coords[a][0], coords[b][0], coords[c][0]]
        ys = [coords[a][1], coords[b][1], coords[c][1]]
        ax.plot(xs, ys, color="#3366cc", lw=2, zorder=1)
    cx = sum(coords[p][0] for p in circle) / 3
    cy = sum(coords[p][1] for p in circle) / 3
    rad = ((coords[3][0] - cx) ** 2 + (coords[3][1] - cy) ** 2) ** 0.5
    ax.add_patch(plt.Circle((cx, cy), rad, fill=False, color="#3366cc", lw=2))
    for i, (x, y) in coords.items():
        ax.scatter([x], [y], s=240, color="#cc3333", zorder=2)
        ax.annotate(str(i), (x, y), color="white", ha="center", va="center",
                    fontweight="bold", zorder=3)
    ax.set_title("Fano plane S(2,3,7): 7 points, 7 lines\n"
                 "every pair on exactly one line (tight)")
    ax.set_aspect("equal")
    ax.axis("off")


def draw_packing_bars(ax: plt.Axes) -> None:
    examples: List[Tuple[str, int, int, int]] = [
        ("Fano\nS(2,3,7)", 7, 3, 7),
        ("AG(2,3)\nS(2,3,9)", 9, 3, 12),
        ("two\ntriples", 7, 3, 2),
        ("S(2,3,13)", 13, 3, 26),
    ]
    labels = [e[0] for e in examples]
    used = [e[3] * comb(e[2], 2) for e in examples]
    avail = [comb(e[1], 2) for e in examples]
    x = range(len(examples))
    ax.bar([i - 0.2 for i in x], used, width=0.4, label="m*C(r,2) (pairs used)",
           color="#3366cc")
    ax.bar([i + 0.2 for i in x], avail, width=0.4, label="C(n,2) (pairs available)",
           color="#cc8833")
    ax.set_xticks(list(x))
    ax.set_xticklabels(labels)
    ax.set_ylabel("number of pairs")
    ax.set_title("Theorem 1: equality (bars match) <=> Steiner system")
    ax.legend()


def main() -> None:
    fig, axes = plt.subplots(1, 2, figsize=(13, 6))
    draw_fano(axes[0])
    draw_packing_bars(axes[1])
    fig.tight_layout()
    fig.savefig("packing_visualization.png", dpi=150)
    print("Saved packing_visualization.png")


if __name__ == "__main__":
    main()
