"""
demo.py -- Numerical demonstration of the Maximum-Overlap Law for register allocation.

For programs whose variables occupy contiguous live ranges, the interference graph is an
interval graph and satisfies

        chi(G) = omega(G) = D

where D is the maximum overlap: the largest number of variables simultaneously live at any
single program point. This script:

  1. Models live ranges as closed integer intervals [lo_i, hi_i].
  2. Builds the interference graph.
  3. Computes the maximum overlap D by a single left-to-right scan.
  4. Computes the clique number omega(G) (via the deepest program point) and the chromatic
     number chi(G) (via the latest-start-first greedy coloring, which is optimal here).
  5. Verifies chi(G) = omega(G) = D on random and hand-built instances.
  6. Confirms the sharpening D <= Delta + 1 of the greedy degree bound.
  7. Shows the general formula chi = max(Delta+1, omega) FAILS on the Petersen graph, which is
     not an interval graph.

Self-contained: standard library only.
"""

from __future__ import annotations

import random
from itertools import combinations
from typing import Dict, List, Set, Tuple

Interval = Tuple[int, int]  # (lo, hi), a closed live range [lo, hi]


# --------------------------------------------------------------------------------------------
# Core model
# --------------------------------------------------------------------------------------------

def interfere(a: Interval, b: Interval) -> bool:
    """Two distinct live ranges interfere iff their closed intervals overlap."""
    (lo_a, hi_a), (lo_b, hi_b) = a, b
    return lo_a <= hi_b and lo_b <= hi_a


def interference_edges(ranges: List[Interval]) -> Set[Tuple[int, int]]:
    """Return the edge set (i < j) of the interference graph."""
    n = len(ranges)
    edges: Set[Tuple[int, int]] = set()
    for i, j in combinations(range(n), 2):
        if interfere(ranges[i], ranges[j]):
            edges.add((i, j))
    return edges


def depth_at(ranges: List[Interval], t: int) -> int:
    """Number of variables live at program point t."""
    return sum(1 for (lo, hi) in ranges if lo <= t <= hi)


def max_overlap(ranges: List[Interval]) -> int:
    """Maximum overlap D, computed by scanning the start points (where depth can only rise)."""
    if not ranges:
        return 0
    return max(depth_at(ranges, lo) for (lo, _hi) in ranges)


def deepest_point(ranges: List[Interval]) -> int:
    """A start point achieving the maximum overlap; its live set is a maximum clique."""
    return max((lo for (lo, _hi) in ranges), key=lambda t: depth_at(ranges, t))


# --------------------------------------------------------------------------------------------
# Graph invariants
# --------------------------------------------------------------------------------------------

def clique_number_via_overlap(ranges: List[Interval]) -> int:
    """omega(G) = D for interval graphs: the deepest program point carries a maximum clique."""
    return max_overlap(ranges)


def brute_force_clique_number(ranges: List[Interval]) -> int:
    """Independent (exponential) check of omega(G) by scanning all vertex subsets sizes."""
    n = len(ranges)
    best = 0
    for r in range(n, 0, -1):
        for subset in combinations(range(n), r):
            if all(interfere(ranges[i], ranges[j]) for i, j in combinations(subset, 2)):
                return r
        # if no clique of size r, continue downward
    return best


def greedy_latest_start_coloring(ranges: List[Interval]) -> Dict[int, int]:
    """
    Optimal coloring for interval graphs. The latest-start-first elimination order is a perfect
    elimination ordering; coloring proceeds in the reverse (earliest-start-first) direction, so
    that when a vertex m is colored its already-colored interfering neighbors all have smaller
    start points and are therefore live at m's own start point. Fewer than D such neighbors
    exist, so a color among D is always free.
    """
    order = sorted(range(len(ranges)), key=lambda i: ranges[i][0])
    color: Dict[int, int] = {}
    for v in order:
        forbidden = {color[u] for u in color if interfere(ranges[v], ranges[u])}
        c = 0
        while c in forbidden:
            c += 1
        color[v] = c
    return color


def chromatic_number(ranges: List[Interval]) -> int:
    """chi(G) = number of colors used by the optimal latest-start-first coloring."""
    coloring = greedy_latest_start_coloring(ranges)
    return (max(coloring.values()) + 1) if coloring else 0


def is_proper(ranges: List[Interval], coloring: Dict[int, int]) -> bool:
    """Verify the coloring assigns distinct colors to interfering variables."""
    for i, j in interference_edges(ranges):
        if coloring[i] == coloring[j]:
            return False
    return True


def max_degree(ranges: List[Interval]) -> int:
    """Delta(G): maximum number of neighbors of any vertex."""
    n = len(ranges)
    if n == 0:
        return 0
    deg = [0] * n
    for i, j in interference_edges(ranges):
        deg[i] += 1
        deg[j] += 1
    return max(deg)


# --------------------------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------------------------

def demo_hand_built() -> None:
    print("=" * 78)
    print("DEMO 1: A hand-built program with three peak-overlapping variables")
    print("=" * 78)
    # Variables a,b,c,d,e with contiguous live ranges on a timeline 0..10.
    ranges = [(0, 3), (1, 5), (2, 6), (4, 8), (7, 10)]
    names = ["a", "b", "c", "d", "e"]
    for name, (lo, hi) in zip(names, ranges):
        print(f"  {name}: live over [{lo}, {hi}]")
    D = max_overlap(ranges)
    t = deepest_point(ranges)
    print(f"\n  Deepest program point t = {t}, with depth {depth_at(ranges, t)}")
    print(f"  Maximum overlap        D = {D}")
    print(f"  Clique number      omega = {clique_number_via_overlap(ranges)}"
          f"  (brute force: {brute_force_clique_number(ranges)})")
    coloring = greedy_latest_start_coloring(ranges)
    print(f"  Chromatic number     chi = {chromatic_number(ranges)}")
    print(f"  Register assignment      = "
          f"{ {names[i]: coloring[i] for i in range(len(names))} }")
    print(f"  Coloring is proper       : {is_proper(ranges, coloring)}")
    print(f"  Law chi = omega = D      : {chromatic_number(ranges) == D == clique_number_via_overlap(ranges)}")
    print(f"  Sharpening D <= Delta+1  : {D} <= {max_degree(ranges) + 1}  "
          f"({D <= max_degree(ranges) + 1})")


def demo_random(trials: int = 2000, seed: int = 2026) -> None:
    print("\n" + "=" * 78)
    print(f"DEMO 2: Randomized verification of chi = omega = D over {trials} programs")
    print("=" * 78)
    rng = random.Random(seed)
    failures = 0
    delta_fail = 0
    for _ in range(trials):
        n = rng.randint(0, 9)
        ranges: List[Interval] = []
        for _ in range(n):
            lo = rng.randint(0, 12)
            hi = lo + rng.randint(0, 8)
            ranges.append((lo, hi))
        D = max_overlap(ranges)
        chi = chromatic_number(ranges)
        omega = brute_force_clique_number(ranges)
        coloring = greedy_latest_start_coloring(ranges)
        if not (chi == omega == D and is_proper(ranges, coloring)):
            failures += 1
        if D > max_degree(ranges) + 1:
            delta_fail += 1
    print(f"  Instances violating chi = omega = D : {failures}")
    print(f"  Instances violating D <= Delta + 1  : {delta_fail}")
    print(f"  All {trials} random programs satisfy the Maximum-Overlap Law: "
          f"{failures == 0 and delta_fail == 0}")


def demo_petersen() -> None:
    print("\n" + "=" * 78)
    print("DEMO 3: The general formula chi = max(Delta+1, omega) FAILS off interval graphs")
    print("=" * 78)
    # Petersen graph: 3-regular, triangle-free, but 3-chromatic. NOT an interval graph.
    outer = [(i, (i + 1) % 5) for i in range(5)]
    spokes = [(i, i + 5) for i in range(5)]
    inner = [(i + 5, ((i + 2) % 5) + 5) for i in range(5)]
    edges = set(outer + spokes + inner)
    n = 10
    adj = {v: set() for v in range(n)}
    for a, b in edges:
        adj[a].add(b)
        adj[b].add(a)
    delta = max(len(adj[v]) for v in range(n))
    # omega: triangle-free => 2.
    omega = 2
    for i, j, k in combinations(range(n), 3):
        if j in adj[i] and k in adj[i] and k in adj[j]:
            omega = 3
            break
    # A valid 3-coloring of the Petersen graph.
    coloring = {0: 0, 1: 1, 2: 0, 3: 1, 4: 2, 5: 1, 6: 0, 7: 2, 8: 2, 9: 1}
    proper = all(coloring[a] != coloring[b] for a, b in edges)
    chi = max(coloring.values()) + 1 if proper else None
    print(f"  Delta + 1                         = {delta + 1}")
    print(f"  Clique number omega               = {omega}")
    print(f"  Conjectured max(Delta+1, omega)   = {max(delta + 1, omega)}")
    print(f"  Actual chromatic number chi       = {chi}  (explicit proper 3-coloring)")
    print(f"  Formula predicts {max(delta + 1, omega)} but chi = {chi}: "
          f"formula FAILS -> {max(delta + 1, omega) != chi}")
    print("  Lesson: the exact law needs interval structure; Petersen is not an interval graph.")


def main() -> None:
    demo_hand_built()
    demo_random()
    demo_petersen()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
