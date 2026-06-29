"""Numerical demonstrations of chip-firing divisor foundations.

This script reproduces, on concrete finite simple graphs, the two main
theorems of the accompanying paper:

  * Theorem 3.2 (`deg_lap_eq_zero`):  sum_v lap(f)(v) = 0  for every integer
    vertex labelling f.  Equivalently, firing preserves the degree of a divisor.

  * Theorem 3.3 (`deg_canonicalDivisor_eq_two_genus_sub_two`):
    sum_v K(v) = 2g - 2, where K(v) = deg(v) - 2 and g = |E| - |V| + 1.

Every graph is encoded as a finite simple graph (symmetric, irreflexive
adjacency).  All functions are self-contained and type-hinted.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, List, Set, Tuple
import random

# A finite simple graph: vertices are ints 0..n-1; edges are a set of
# unordered pairs (i, j) with i < j.
Graph = Tuple[int, Set[Tuple[int, int]]]


def neighbors(graph: Graph, v: int) -> List[int]:
    """Return the list of neighbors of vertex v (adjacency is symmetric)."""
    _, edges = graph
    result: List[int] = []
    for a, b in edges:
        if a == v:
            result.append(b)
        elif b == v:
            result.append(a)
    return result


def vertex_degree(graph: Graph, v: int) -> int:
    """Number of edges incident to v."""
    return len(neighbors(graph, v))


def divisor_degree(divisor: Dict[int, int]) -> int:
    """deg D = sum_v D(v)."""
    return sum(divisor.values())


def laplacian(graph: Graph, f: Dict[int, int]) -> Dict[int, int]:
    """lap f (v) = sum_{w ~ v} (f(v) - f(w))."""
    n, _ = graph
    return {v: sum(f[v] - f[w] for w in neighbors(graph, v)) for v in range(n)}


def canonical_divisor(graph: Graph) -> Dict[int, int]:
    """K(v) = deg(v) - 2."""
    n, _ = graph
    return {v: vertex_degree(graph, v) - 2 for v in range(n)}


def genus(graph: Graph) -> int:
    """g = |E| - |V| + 1."""
    n, edges = graph
    return len(edges) - n + 1


def fire(graph: Graph, divisor: Dict[int, int], f: Dict[int, int]) -> Dict[int, int]:
    """Apply the firing pattern f to a divisor: D' = D + lap f."""
    lap = laplacian(graph, f)
    return {v: divisor[v] + lap[v] for v in divisor}


# ---- Graph constructors -----------------------------------------------------

def complete_graph(n: int) -> Graph:
    """K_n: every pair of distinct vertices adjacent."""
    return n, {(i, j) for i, j in combinations(range(n), 2)}


def cycle_graph(n: int) -> Graph:
    """C_n: a single n-cycle (n >= 3)."""
    edges = {(min(i, (i + 1) % n), max(i, (i + 1) % n)) for i in range(n)}
    return n, edges


def path_graph(n: int) -> Graph:
    """P_n: a path on n vertices."""
    return n, {(i, i + 1) for i in range(n - 1)}


def random_connected_graph(n: int, extra_edges: int, seed: int) -> Graph:
    """A random connected simple graph: a random spanning tree plus extra edges."""
    rng = random.Random(seed)
    verts = list(range(n))
    rng.shuffle(verts)
    edges: Set[Tuple[int, int]] = set()
    for k in range(1, n):  # random tree
        j = verts[k]
        i = verts[rng.randrange(k)]
        edges.add((min(i, j), max(i, j)))
    all_pairs = [(i, j) for i, j in combinations(range(n), 2)]
    rng.shuffle(all_pairs)
    for pair in all_pairs:
        if len(edges) >= (n - 1) + extra_edges:
            break
        edges.add(pair)
    return n, edges


# ---- Theorem checks ---------------------------------------------------------

def check_laplacian_degree_zero(graph: Graph, f: Dict[int, int]) -> int:
    """Return sum_v lap f(v); Theorem 3.2 says it is 0."""
    return divisor_degree(laplacian(graph, f))


def check_canonical_genus(graph: Graph) -> Tuple[int, int]:
    """Return (sum_v K(v), 2g - 2); Theorem 3.3 says they are equal."""
    return divisor_degree(canonical_divisor(graph)), 2 * genus(graph) - 2


def random_labelling(n: int, seed: int, lo: int = -5, hi: int = 5) -> Dict[int, int]:
    rng = random.Random(seed)
    return {v: rng.randint(lo, hi) for v in range(n)}


# ---- Demonstration ----------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("Chip-Firing Divisor Theory: numerical verification of the two laws")
    print("=" * 70)

    named: List[Tuple[str, Graph]] = [
        ("Triangle  C_3", cycle_graph(3)),
        ("Path      P_3", path_graph(3)),
        ("Cycle     C_5", cycle_graph(5)),
        ("Complete  K_4", complete_graph(4)),
        ("Complete  K_5", complete_graph(5)),
        ("Petersen-ish random", random_connected_graph(10, 5, seed=7)),
    ]

    print("\n--- Theorem 3.3:  sum_v K(v) = 2g - 2 ---")
    print(f"{'graph':22} {'|V|':>4} {'|E|':>4} {'g':>4} {'deg K':>7} {'2g-2':>7}  ok")
    for name, g in named:
        n, edges = g
        sumK, target = check_canonical_genus(g)
        ok = (sumK == target)
        print(f"{name:22} {n:>4} {len(edges):>4} {genus(g):>4} "
              f"{sumK:>7} {target:>7}  {ok}")
        assert ok, f"canonical genus law failed on {name}"

    print("\n--- Theorem 3.2:  sum_v lap f(v) = 0  (firing conserves degree) ---")
    print(f"{'graph':22} {'seed':>5} {'deg(lap f)':>11} {'deg D : deg D-fired':>20}  ok")
    for name, g in named:
        n, edges = g
        for seed in (1, 2, 3):
            f = random_labelling(n, seed)
            lap_deg = check_laplacian_degree_zero(g, f)
            # also confirm a concrete divisor keeps its degree after firing
            d = random_labelling(n, seed + 100)
            d_fired = fire(g, d, f)
            same_deg = (divisor_degree(d) == divisor_degree(d_fired))
            ok = (lap_deg == 0) and same_deg
            print(f"{name:22} {seed:>5} {lap_deg:>11} "
                  f"{str(divisor_degree(d)) + ' = ' + str(divisor_degree(d_fired)):>15}  {ok}")
            assert ok, f"degree conservation failed on {name}"

    print("\n--- Detailed example: firing one vertex of the triangle ---")
    tri = cycle_graph(3)
    f = {0: 1, 1: 0, 2: 0}
    print(f"firing pattern f = {f}")
    print(f"lap f          = {laplacian(tri, f)}   (sum = {check_laplacian_degree_zero(tri, f)})")
    K = canonical_divisor(tri)
    print(f"canonical K    = {K}   (sum = {divisor_degree(K)},  2g-2 = {2*genus(tri)-2})")

    print("\nAll assertions passed: both foundational laws hold on every example.")


if __name__ == "__main__":
    main()


"""Visualization of chip-firing: a divisor before and after a firing move,
with degree conservation displayed.

Generates a matplotlib figure showing a small graph, the chip values at each
vertex before and after firing a chosen vertex, and confirms the total chip
count (degree) is unchanged --- a picture of Theorem 3.2 (deg_lap_eq_zero).

Run:  python visualization.py   (writes chipfiring_demo.png)
"""

from __future__ import annotations

from typing import Dict, List, Tuple
import math

import matplotlib.pyplot as plt


def cycle_positions(n: int) -> Dict[int, Tuple[float, float]]:
    """Place n vertices evenly on a circle."""
    return {
        v: (math.cos(2 * math.pi * v / n), math.sin(2 * math.pi * v / n))
        for v in range(n)
    }


def laplacian(adj: Dict[int, List[int]], f: Dict[int, int]) -> Dict[int, int]:
    """lap f (v) = sum_{w ~ v} (f(v) - f(w))."""
    return {v: sum(f[v] - f[w] for w in adj[v]) for v in adj}


def draw(ax, pos, adj, divisor, title: str) -> None:
    for v, nbrs in adj.items():
        for w in nbrs:
            if v < w:
                x = [pos[v][0], pos[w][0]]
                y = [pos[v][1], pos[w][1]]
                ax.plot(x, y, color="#888", zorder=1, linewidth=1.5)
    for v, (x, y) in pos.items():
        val = divisor[v]
        color = "#2a9d8f" if val >= 0 else "#e76f51"
        ax.scatter([x], [y], s=1400, color=color, zorder=2, edgecolors="black")
        ax.text(x, y, f"{val:+d}", ha="center", va="center",
                color="white", fontsize=14, fontweight="bold", zorder=3)
    ax.set_title(f"{title}\ndegree = {sum(divisor.values())}", fontsize=12)
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_xlim(-1.4, 1.4)
    ax.set_ylim(-1.4, 1.4)


def main() -> None:
    n = 5
    adj: Dict[int, List[int]] = {v: [(v - 1) % n, (v + 1) % n] for v in range(n)}
    pos = cycle_positions(n)

    divisor: Dict[int, int] = {0: 3, 1: -1, 2: 0, 3: 1, 4: -1}
    fire_vertex = 0
    f = {v: (1 if v == fire_vertex else 0) for v in range(n)}
    lap = laplacian(adj, f)
    fired = {v: divisor[v] + lap[v] for v in range(n)}

    fig, axes = plt.subplots(1, 2, figsize=(11, 5.5))
    draw(axes[0], pos, adj, divisor, "Before firing vertex 0")
    draw(axes[1], pos, adj, fired, "After firing vertex 0")
    fig.suptitle("Chip-Firing on the 5-cycle: degree is conserved (Theorem 3.2)",
                 fontsize=14, fontweight="bold")
    fig.tight_layout()
    fig.savefig("chipfiring_demo.png", dpi=140)
    print("wrote chipfiring_demo.png")
    print(f"degree before = {sum(divisor.values())}, "
          f"degree after = {sum(fired.values())}")


if __name__ == "__main__":
    main()
