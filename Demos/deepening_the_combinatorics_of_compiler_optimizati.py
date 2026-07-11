"""
demo.py -- Numerical demonstrations for
"Chordal Interference Graphs Are Perfect: Optimal Register Allocation for SSA Programs"

This self-contained script illustrates the paper's main results:

  * Greedy Coloring Lemma: a vertex order in which every vertex has < k earlier
    neighbours yields a proper k-colouring.
  * Chordal Graphs Are Perfect: for a graph with a perfect elimination ordering
    (PEO), the greedy colouring uses exactly omega(G) colours, so chi(G) = omega(G).
  * Interval graphs are chordal: sorting live ranges by start point produces a PEO,
    recovering classical linear-scan register allocation as a special case.

Every routine is inlined and uses only the Python standard library.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, List, Optional, Set, Tuple

# A graph is represented as (n, adjacency) where vertices are 0..n-1 and
# adjacency[v] is the set of neighbours of v.
Graph = Tuple[int, List[Set[int]]]


# ---------------------------------------------------------------------------
# Basic graph utilities
# ---------------------------------------------------------------------------
def make_graph(n: int, edges: List[Tuple[int, int]]) -> Graph:
    """Build an undirected simple graph on vertices 0..n-1 from an edge list."""
    adj: List[Set[int]] = [set() for _ in range(n)]
    for u, v in edges:
        if u != v:
            adj[u].add(v)
            adj[v].add(u)
    return n, adj


def earlier_neighbours(g: Graph, v: int) -> Set[int]:
    """N^-(v): neighbours of v with a strictly smaller index."""
    _, adj = g
    return {w for w in adj[v] if w < v}


def is_peo(g: Graph) -> bool:
    """Check whether the natural order 0,1,...,n-1 is a perfect elimination ordering:
    for every vertex v, its earlier neighbours form a clique."""
    _, adj = g
    n, _ = g
    for v in range(n):
        en = earlier_neighbours(g, v)
        for a, b in combinations(sorted(en), 2):
            if b not in adj[a]:
                return False
    return True


def clique_number(g: Graph) -> int:
    """Brute-force maximum clique size omega(G). Fine for the small demo graphs."""
    n, adj = g
    best = 0
    verts = list(range(n))
    # Check all subsets in decreasing size; simple and clear for small n.
    for size in range(n, 0, -1):
        for subset in combinations(verts, size):
            if all(b in adj[a] for a, b in combinations(subset, 2)):
                return size
    return best


def chromatic_number_bruteforce(g: Graph) -> int:
    """Exact chi(G) by trying k = 1,2,... with a backtracking k-colourer."""
    n, adj = g
    for k in range(1, n + 1):
        if _k_colourable(g, k):
            return k
    return n


def _k_colourable(g: Graph, k: int) -> bool:
    n, adj = g
    colour: List[int] = [-1] * n

    def backtrack(v: int) -> bool:
        if v == n:
            return True
        for c in range(k):
            if all(colour[w] != c for w in adj[v] if colour[w] != -1):
                colour[v] = c
                if backtrack(v + 1):
                    return True
                colour[v] = -1
        return False

    return backtrack(0)


# ---------------------------------------------------------------------------
# Greedy colouring along the elimination order (Lemma 3.1 / Theorem 5.1)
# ---------------------------------------------------------------------------
def greedy_peo_colouring(g: Graph) -> Dict[int, int]:
    """Colour vertices in forward order 0,1,...,n-1, assigning each the least colour
    not used by its EARLIER (already-coloured) neighbours. On a PEO graph this uses
    exactly omega(G) colours (equivalently: process largest-last, per the induction)."""
    n, adj = g
    colour: Dict[int, int] = {}
    for v in range(n):
        forbidden = {colour[w] for w in earlier_neighbours(g, v) if w in colour}
        c = 0
        while c in forbidden:
            c += 1
        colour[v] = c
    return colour


def is_proper(g: Graph, colour: Dict[int, int]) -> bool:
    _, adj = g
    return all(colour[u] != colour[v] for u in range(g[0]) for v in adj[u])


def max_earlier_degree(g: Graph) -> int:
    n, _ = g
    return max((len(earlier_neighbours(g, v)) for v in range(n)), default=0)


# ---------------------------------------------------------------------------
# Interval graphs (Section 6): live ranges -> interference graph
# ---------------------------------------------------------------------------
def interval_interference_graph(intervals: List[Tuple[int, int]]) -> Graph:
    """Given live ranges [lo, hi], build the interference graph (overlap = edge).
    Vertices are sorted by start point so the natural order is a PEO."""
    order = sorted(range(len(intervals)), key=lambda i: intervals[i][0])
    sorted_iv = [intervals[i] for i in order]
    n = len(sorted_iv)
    edges: List[Tuple[int, int]] = []
    for i in range(n):
        for j in range(i + 1, n):
            lo_i, hi_i = sorted_iv[i]
            lo_j, hi_j = sorted_iv[j]
            if lo_i <= hi_j and lo_j <= hi_i:  # closed intervals overlap
                edges.append((i, j))
    return make_graph(n, edges)


def max_overlap(intervals: List[Tuple[int, int]]) -> int:
    """Maximum number of intervals covering a single point == omega for interval graphs."""
    events: List[Tuple[int, int]] = []
    for lo, hi in intervals:
        events.append((lo, +1))
        events.append((hi + 1, -1))  # closed intervals: release after hi
    events.sort()
    cur = best = 0
    for _, delta in events:
        cur += delta
        best = max(best, cur)
    return best


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_chordal_example() -> None:
    print("=" * 68)
    print("DEMO 1: A chordal graph is perfect (chi = omega)")
    print("=" * 68)
    # A 4-cycle 0-1-2-3-0 WITH a chord 0-2 => chordal.
    g = make_graph(4, [(0, 1), (1, 2), (2, 3), (3, 0), (0, 2)])
    print("Edges: 0-1,1-2,2-3,3-0,0-2  (a 4-cycle plus chord 0-2)")
    print("Is the natural order a PEO? ", is_peo(g))
    omega = clique_number(g)
    chi = chromatic_number_bruteforce(g)
    colouring = greedy_peo_colouring(g)
    print(f"omega(G) = {omega}   chi(G) = {chi}")
    print("Greedy PEO colouring:", colouring,
          "-> uses", max(colouring.values()) + 1, "colours; proper:", is_proper(g, colouring))
    assert chi == omega == max(colouring.values()) + 1
    print("Confirmed: chi = omega and greedy attains it.\n")


def demo_nonchordal_gap() -> None:
    print("=" * 68)
    print("DEMO 2: A non-chordal graph where chi may exceed omega")
    print("=" * 68)
    # The 5-cycle C5: no chords, not chordal. omega = 2 but chi = 3.
    g = make_graph(5, [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)])
    print("Edges: the 5-cycle C5 (no chords)")
    print("Is the natural order a PEO? ", is_peo(g))
    print(f"omega(G) = {clique_number(g)}   chi(G) = {chromatic_number_bruteforce(g)}")
    print("Here chi = 3 > 2 = omega: without chordality perfection can fail.\n")


def demo_interval_linear_scan() -> None:
    print("=" * 68)
    print("DEMO 3: Interval graphs -> linear-scan register allocation")
    print("=" * 68)
    # Live ranges of 6 variables (lo, hi) on an instruction timeline.
    intervals = [(0, 4), (1, 2), (3, 6), (5, 8), (2, 7), (6, 9)]
    print("Live ranges:", intervals)
    g = interval_interference_graph(intervals)
    print("Built interference graph; natural (by-start) order is a PEO? ", is_peo(g))
    omega = clique_number(g)
    chi = chromatic_number_bruteforce(g)
    overlap = max_overlap(intervals)
    colouring = greedy_peo_colouring(g)
    regs = max(colouring.values()) + 1
    print(f"omega(G) = {omega}   chi(G) = {chi}   max simultaneous overlap = {overlap}")
    print(f"Registers used by greedy linear scan = {regs}")
    print("Register assignment (variable index by start -> register):", colouring)
    assert chi == omega == overlap == regs
    print("Confirmed: registers needed = peak register pressure = omega.\n")


def demo_peo_degree_bound() -> None:
    print("=" * 68)
    print("DEMO 4: Under a PEO, earlier-degree(v) + 1 <= omega for every v")
    print("=" * 68)
    intervals = [(0, 3), (1, 5), (2, 2), (4, 7), (6, 8), (3, 9)]
    g = interval_interference_graph(intervals)
    omega = clique_number(g)
    print("PEO holds:", is_peo(g), "  omega =", omega)
    for v in range(g[0]):
        d = len(earlier_neighbours(g, v))
        print(f"  vertex {v}: earlier-degree {d}, +1 = {d + 1} <= omega({omega}): {d + 1 <= omega}")
    print("Max earlier-degree =", max_earlier_degree(g),
          "= omega - 1 =", omega - 1, "\n")


if __name__ == "__main__":
    demo_chordal_example()
    demo_nonchordal_gap()
    demo_interval_linear_scan()
    demo_peo_degree_bound()
    print("All demonstrations completed and assertions passed.")
