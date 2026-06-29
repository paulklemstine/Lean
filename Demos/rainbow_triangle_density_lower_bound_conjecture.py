"""
Numerical demonstrations for the Rainbow Triangle Density bound.

This self-contained script illustrates the formally verified results about
rainbow triangles in edge-colored graphs and the extremal bound

    rtBound(n) = ceil( (n-1)(n-3) / 8 ),

modeled over the natural numbers as ((n-1)(n-3) + 7) // 8 with truncated
subtraction.

Verified facts demonstrated here (mirroring the Lean theorems):
  * rtBound_ceil      : (n-1)(n-3) <= 8*rtBound(n) < (n-1)(n-3) + 8
  * rtBound_zero_iff  : rtBound(n) == 0  iff  n <= 3
  * rtBound_mono      : rtBound is non-decreasing in n
  * rtBound_le_choose : rtBound(n) <= C(n,3)
  * proper colorings make every triangle rainbow, so a properly colored
    complete graph K_n has rt = C(n,3) and minimum color degree n-1.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import Dict, List, Tuple

Vertex = int
Color = int
Edge = Tuple[Vertex, Vertex]


# ---------------------------------------------------------------------------
# The bound function
# ---------------------------------------------------------------------------

def truncated_sub(a: int, b: int) -> int:
    """Natural-number (truncated) subtraction: max(a - b, 0)."""
    return a - b if a > b else 0


def rt_bound(n: int) -> int:
    """The conjectured extremal lower bound ceil((n-1)(n-3)/8), encoded over N.

    Uses truncated subtraction so that (n-1)(n-3) = 0 for n <= 3, exactly as
    the ceiling does.
    """
    prod: int = truncated_sub(n, 1) * truncated_sub(n, 3)
    return (prod + 7) // 8


# ---------------------------------------------------------------------------
# Verification of the arithmetic theorems
# ---------------------------------------------------------------------------

def check_ceil(n: int) -> bool:
    """rtBound_ceil: (n-1)(n-3) <= 8*rtBound(n) < (n-1)(n-3) + 8."""
    prod: int = truncated_sub(n, 1) * truncated_sub(n, 3)
    lhs: int = 8 * rt_bound(n)
    return prod <= lhs < prod + 8


def check_zero_iff(n: int) -> bool:
    """rtBound_zero_iff: rtBound(n) == 0 iff n <= 3."""
    return (rt_bound(n) == 0) == (n <= 3)


def check_mono(n: int) -> bool:
    """rtBound_mono: rtBound(n) <= rtBound(n+1)."""
    return rt_bound(n) <= rt_bound(n + 1)


def check_le_choose(n: int) -> bool:
    """rtBound_le_choose: rtBound(n) <= C(n,3)."""
    return rt_bound(n) <= comb(n, 3)


# ---------------------------------------------------------------------------
# Edge-colored graphs and rainbow triangles
# ---------------------------------------------------------------------------

def color_degree(adj: Dict[Vertex, Dict[Vertex, Color]], v: Vertex) -> int:
    """Color degree d_c(v): number of distinct colors on edges incident to v."""
    return len(set(adj[v].values()))


def min_color_degree(adj: Dict[Vertex, Dict[Vertex, Color]]) -> int:
    """Minimum color degree delta_c(G) over all vertices."""
    return min(color_degree(adj, v) for v in adj)


def is_rainbow_triangle(adj: Dict[Vertex, Dict[Vertex, Color]],
                        a: Vertex, b: Vertex, c: Vertex) -> bool:
    """True if a,b,c are pairwise adjacent with three pairwise-distinct colors."""
    if b not in adj[a] or c not in adj[b] or c not in adj[a]:
        return False
    c_ab: Color = adj[a][b]
    c_bc: Color = adj[b][c]
    c_ca: Color = adj[c][a]
    return c_ab != c_bc and c_bc != c_ca and c_ab != c_ca


def count_rainbow_triangles(adj: Dict[Vertex, Dict[Vertex, Color]]) -> int:
    """rt(G): number of rainbow triangles, by brute-force enumeration."""
    verts: List[Vertex] = sorted(adj.keys())
    return sum(
        1
        for a, b, c in combinations(verts, 3)
        if is_rainbow_triangle(adj, a, b, c)
    )


# ---------------------------------------------------------------------------
# The extremal construction: properly edge-colored complete graph K_n (n odd)
# ---------------------------------------------------------------------------

def proper_complete_coloring(n: int) -> Dict[Vertex, Dict[Vertex, Color]]:
    """Build a proper edge-coloring of K_n via the round-robin (circle) method.

    For odd n this uses exactly n-1 colors and is a genuine proper coloring;
    by the structural theorem, every triangle of the result is rainbow.
    """
    adj: Dict[Vertex, Dict[Vertex, Color]] = {v: {} for v in range(n)}
    for i in range(n):
        for j in range(i + 1, n):
            # Round-robin color: standard circle-method assignment.
            color: Color = (i + j) % n
            adj[i][j] = color
            adj[j][i] = color
    return adj


def is_proper(adj: Dict[Vertex, Dict[Vertex, Color]]) -> bool:
    """Check the proper-coloring property: edges sharing a vertex differ in color."""
    for v in adj:
        colors = list(adj[v].values())
        if len(colors) != len(set(colors)):
            return False
    return True


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 68)
    print("Rainbow Triangle Density bound  rtBound(n) = ceil((n-1)(n-3)/8)")
    print("=" * 68)

    print("\n n | (n-1)(n-3) | rtBound(n) | C(n,3) | ceil/choose checks")
    print("-" * 60)
    for n in range(3, 16):
        prod = truncated_sub(n, 1) * truncated_sub(n, 3)
        ok = all([check_ceil(n), check_zero_iff(n),
                  check_mono(n), check_le_choose(n)])
        print(f"{n:2d} | {prod:10d} | {rt_bound(n):10d} | "
              f"{comb(n, 3):6d} | {'OK' if ok else 'FAIL'}")

    print("\nGlobal verification over n = 0..500:")
    all_ok = all(
        check_ceil(n) and check_zero_iff(n) and check_mono(n) and check_le_choose(n)
        for n in range(0, 501)
    )
    print(f"  all four theorems hold for every n in [0,500]: {all_ok}")

    print("\n" + "=" * 68)
    print("Extremal witness: properly edge-colored complete graph K_n (n odd)")
    print("=" * 68)
    print("\n n | proper? | delta_c | (n+1)/2 | rt(G) | C(n,3) | rt >= rtBound")
    print("-" * 66)
    for n in (3, 5, 7, 9, 11):
        adj = proper_complete_coloring(n)
        proper = is_proper(adj)
        dc = min_color_degree(adj)
        rt = count_rainbow_triangles(adj)
        bound = rt_bound(n)
        threshold = (n + 1) // 2
        meets = "yes" if rt >= bound else "NO"
        print(f"{n:2d} | {str(proper):7s} | {dc:7d} | {threshold:7d} | "
              f"{rt:5d} | {comb(n, 3):6d} | {meets}")

    print("\nInterpretation:")
    print("  * Every triangle of a properly colored K_n is rainbow, so")
    print("    rt(G) = C(n,3), vastly exceeding the floor rtBound(n).")
    print("  * delta_c = n-1 >= (n+1)/2, so K_n sits inside the conjecture's")
    print("    hypothesis regime.")


if __name__ == "__main__":
    main()
