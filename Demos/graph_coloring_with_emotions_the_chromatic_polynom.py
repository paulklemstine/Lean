"""
Emotional Chromatic Number of Social Networks — numerical demonstrations.

A social network is a finite simple graph whose vertices are people and whose
edges are friendships. A proper k-coloring assigns one of k emotions to each
person so that no two friends share an emotion. The chromatic polynomial
chi_G(k) counts proper k-colorings. The emotional chromatic number is

    emoChrom(G) = min { k >= 3 : chi_G(k) > 0 } = max(chromatic_number(G), 3),

with a floor of three because emotional life needs at least three categories.

This script is fully self-contained (standard library only) and demonstrates:
  * the clique law     emoChrom(K_n) = max(n, 3)
  * the cycle law      emoChrom(C_n) = 3 for n >= 3
  * the six-emotion window   3 <= emoChrom(G) <= 6 when chi_G(6) > 0
  * the bipartite folklore correction: two emotions succeed iff G is bipartite,
    and the universal root is at k = 1, not k = 2.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Set, Tuple

Graph = Dict[int, Set[int]]  # adjacency: vertex -> set of neighbors


# --------------------------------------------------------------------------- #
# Graph constructors
# --------------------------------------------------------------------------- #
def complete_graph(n: int) -> Graph:
    """K_n: every pair of the n vertices is adjacent."""
    return {v: {u for u in range(n) if u != v} for v in range(n)}


def cycle_graph(n: int) -> Graph:
    """C_n: vertices 0..n-1 arranged in a ring (n >= 3)."""
    if n < 3:
        raise ValueError("cycle needs n >= 3")
    return {v: {(v - 1) % n, (v + 1) % n} for v in range(n)}


def path_graph(n: int) -> Graph:
    """P_n: a path on n vertices (bipartite)."""
    g: Graph = {v: set() for v in range(n)}
    for v in range(n - 1):
        g[v].add(v + 1)
        g[v + 1].add(v)
    return g


def edges_of(g: Graph) -> List[Tuple[int, int]]:
    """Unordered edges of g, each listed once."""
    return [(u, v) for u in g for v in g[u] if u < v]


# --------------------------------------------------------------------------- #
# Core invariants
# --------------------------------------------------------------------------- #
def count_proper_colorings(g: Graph, k: int) -> int:
    """chi_G(k): brute-force count of proper k-colorings (small graphs)."""
    if k <= 0:
        return 0
    verts = sorted(g)
    edges = edges_of(g)
    total = 0
    for coloring in product(range(k), repeat=len(verts)):
        assign = dict(zip(verts, coloring))
        if all(assign[u] != assign[v] for u, v in edges):
            total += 1
    return total


def is_k_colorable(g: Graph, k: int) -> bool:
    """Whether a proper k-coloring exists (backtracking search)."""
    verts = sorted(g)
    color: Dict[int, int] = {}

    def backtrack(i: int) -> bool:
        if i == len(verts):
            return True
        v = verts[i]
        used = {color[u] for u in g[v] if u in color}
        for c in range(k):
            if c not in used:
                color[v] = c
                if backtrack(i + 1):
                    return True
                del color[v]
        return False

    return backtrack(0)


def chromatic_number(g: Graph) -> int:
    """Least k >= 0 admitting a proper k-coloring."""
    n = len(g)
    for k in range(n + 1):
        if is_k_colorable(g, k):
            return k
    return n


def emotional_chromatic_number(g: Graph) -> int:
    """emoChrom(G) = max(chromatic_number(G), 3)."""
    return max(chromatic_number(g), 3)


def is_bipartite(g: Graph) -> bool:
    """Two-color the graph via BFS; bipartite iff it succeeds."""
    color: Dict[int, int] = {}
    for start in g:
        if start in color:
            continue
        color[start] = 0
        stack = [start]
        while stack:
            v = stack.pop()
            for u in g[v]:
                if u not in color:
                    color[u] = 1 - color[v]
                    stack.append(u)
                elif color[u] == color[v]:
                    return False
    return True


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_clique_law() -> None:
    print("== Clique law:  emoChrom(K_n) = max(n, 3) ==")
    for n in range(1, 8):
        g = complete_graph(n)
        e = emotional_chromatic_number(g)
        assert e == max(n, 3), (n, e)
        print(f"  K_{n}: chi(6)={count_proper_colorings(g, 6):>5}  "
              f"emoChrom={e}  (expected {max(n, 3)})")
    print()


def demo_cycle_law() -> None:
    print("== Cycle law:  emoChrom(C_n) = 3 for n >= 3 ==")
    for n in range(3, 10):
        g = cycle_graph(n)
        e = emotional_chromatic_number(g)
        chi2 = count_proper_colorings(g, 2)
        assert e == 3, (n, e)
        parity = "even" if n % 2 == 0 else "odd"
        print(f"  C_{n} ({parity}): chi(2)={chi2:>3}  chi_number={chromatic_number(g)}  "
              f"emoChrom={e}")
    print()


def demo_six_emotion_window() -> None:
    print("== Six-emotion window:  chi_G(6) > 0  =>  3 <= emoChrom(G) <= 6 ==")
    samples = {
        "K_4 (clique of 4)": complete_graph(4),
        "C_5 (odd ring)": cycle_graph(5),
        "C_6 (even ring)": cycle_graph(6),
        "P_5 (path)": path_graph(5),
    }
    for name, g in samples.items():
        if count_proper_colorings(g, 6) > 0:
            e = emotional_chromatic_number(g)
            assert 3 <= e <= 6, (name, e)
            print(f"  {name:<20}: emoChrom={e}  in [3, 6]  OK")
    print()


def demo_bipartite_correction() -> None:
    print("== Bipartite folklore correction ==")
    print("  Two emotions succeed iff bipartite; universal root is at k = 1.")
    samples = {
        "C_4 (even, bipartite)": cycle_graph(4),
        "C_5 (odd, not bipartite)": cycle_graph(5),
        "P_4 (path, bipartite)": path_graph(4),
        "K_3 (triangle)": complete_graph(3),
    }
    for name, g in samples.items():
        chi1 = count_proper_colorings(g, 1)
        chi2 = count_proper_colorings(g, 2)
        bip = is_bipartite(g)
        assert (chi2 > 0) == bip
        assert chi1 == 0  # any edge kills one-coloring
        print(f"  {name:<26}: chi(1)={chi1}  chi(2)={chi2:>3}  "
              f"bipartite={bip}  emoChrom={emotional_chromatic_number(g)}")
    print()


if __name__ == "__main__":
    demo_clique_law()
    demo_cycle_law()
    demo_six_emotion_window()
    demo_bipartite_correction()
    print("All demonstrations agree with the theory.")
