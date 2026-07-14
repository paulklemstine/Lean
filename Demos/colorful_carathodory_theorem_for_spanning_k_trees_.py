"""
Numerical demonstrations for:

    Polynomial-Size Witnesses for the Colorful Caratheodory Theorem
    over Spanning k-Trees

This self-contained script exercises the paper's main results:

  1. Exact face count of a width-m skeleton:  sum_{i<=m} C(n, i).
  2. Polynomial witness bound for a spanning k-tree:  (k+2) * (n+1)^(k+1).
  3. Linear collapse for spanning trees (k = 1):  exactly 2n faces.
  4. Colorful Caratheodory on the line: extracting a rainbow edge {x, y}
     with 0 in conv{x, y} from two color classes each capturing 0.
  5. Synthesis: exponential join size vs. polynomial / linear witness size.

Run with:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import List, Optional, Sequence, Tuple


# ---------------------------------------------------------------------------
# Part I -- Face counts of bounded-width complexes
# ---------------------------------------------------------------------------

def skeleton_face_count(n: int, m: int) -> int:
    """Exact number of faces of the width-m skeleton on n vertices.

    Equals sum_{i=0}^{m} C(n, i), a polynomial in n of degree m
    (Theorem: Exact face count of the m-skeleton).
    """
    return sum(comb(n, i) for i in range(m + 1))


def skeleton_face_count_bruteforce(n: int, m: int) -> int:
    """Brute-force count of subsets of {0,...,n-1} with at most m elements."""
    ground = range(n)
    total = 0
    for size in range(m + 1):
        total += sum(1 for _ in combinations(ground, size))
    return total


def polynomial_witness_bound(n: int, k: int) -> int:
    """Explicit degree-(k+1) upper bound (k+2) * (n+1)^(k+1) on the face
    count of any width-(k+1) complex on n vertices (spanning k-tree)."""
    return (k + 2) * (n + 1) ** (k + 1)


# ---------------------------------------------------------------------------
# Part II -- The k = 1 collapse: spanning trees have linear face counts
# ---------------------------------------------------------------------------

def spanning_tree_face_count(n: int) -> int:
    """Exact face count of the clique complex of a spanning tree on n
    vertices: 1 (empty) + n (vertices) + (n-1) (edges) = 2n."""
    if n == 0:
        return 1  # only the empty face
    empty = 1
    vertices = n
    edges = n - 1
    return empty + vertices + edges  # == 2 * n


def spanning_tree_face_count_from_edges(edges: Sequence[Tuple[int, int]],
                                        n: int) -> int:
    """Count faces of the clique complex of a graph given as an edge list,
    assuming (as for a tree) it is triangle-free."""
    return 1 + n + len(edges)


# ---------------------------------------------------------------------------
# Part III -- Colorful Caratheodory on the line
# ---------------------------------------------------------------------------

def captures_origin(color_class: Sequence[float]) -> bool:
    """True iff 0 lies in the convex hull of a finite subset of R, i.e. the
    set straddles 0 in sign (min <= 0 <= max)."""
    if not color_class:
        return False
    return min(color_class) <= 0.0 <= max(color_class)


def extract_signed(color_class: Sequence[float], nonpositive: bool
                   ) -> Optional[float]:
    """Sign extraction (Theorem: Sign extraction).

    If nonpositive is True, return an element <= 0; otherwise an element >= 0.
    Returns None if none exists.
    """
    candidates = [v for v in color_class
                  if (v <= 0.0 if nonpositive else v >= 0.0)]
    if not candidates:
        return None
    # Choose the extreme point, mirroring the min'/max' selection.
    return max(candidates) if nonpositive else min(candidates)


def rainbow_edge_on_line(v1: Sequence[float], v2: Sequence[float]
                         ) -> Optional[Tuple[float, float]]:
    """Colorful Caratheodory in dimension one (Theorem: CC on the line).

    Given two color classes each capturing 0, return a rainbow edge (x, y)
    with x in v1, y in v2, and 0 in conv{x, y}.  Returns None if a hypothesis
    fails.
    """
    if not captures_origin(v1) or not captures_origin(v2):
        return None
    x = extract_signed(v1, nonpositive=True)
    y = extract_signed(v2, nonpositive=False)
    if x is None or y is None:
        return None
    return (x, y)


def zero_convex_coefficients(x: float, y: float
                             ) -> Optional[Tuple[float, float]]:
    """Return (lambda, mu) with lambda, mu >= 0, lambda + mu = 1, and
    lambda*x + mu*y = 0, certifying 0 in [x, y].  Requires x <= 0 <= y."""
    if not (x <= 0.0 <= y):
        return None
    if x == 0.0 and y == 0.0:
        return (1.0, 0.0)
    lam = y / (y - x)
    mu = -x / (y - x)
    return (lam, mu)


# ---------------------------------------------------------------------------
# Part IV -- Join size vs. witness size
# ---------------------------------------------------------------------------

def join_top_face_count(color_sizes: Sequence[int]) -> int:
    """Number of top-dimensional (rainbow) faces of the join of color
    classes with the given sizes: the exponential product prod_i |V_i|."""
    prod = 1
    for s in color_sizes:
        prod *= s
    return prod


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_skeleton_counts() -> None:
    print("=" * 70)
    print("Part I: Exact face count of width-m skeletons  (sum_{i<=m} C(n,i))")
    print("=" * 70)
    for n in [4, 6, 8]:
        for m in [1, 2, 3]:
            exact = skeleton_face_count(n, m)
            brute = skeleton_face_count_bruteforce(n, m)
            bound = polynomial_witness_bound(n, m - 1)  # width m = (k+1)
            assert exact == brute, "closed form must match brute force"
            assert exact <= bound, "exact count must satisfy poly bound"
            print(f"  n={n:2d}, m={m}:  exact={exact:5d}  "
                  f"brute={brute:5d}  poly-bound (k+2)(n+1)^(k+1)={bound:6d}")
    print()


def demo_tree_collapse() -> None:
    print("=" * 70)
    print("Part II: k=1 collapse -- spanning trees have exactly 2n faces")
    print("=" * 70)
    for n in [1, 2, 5, 10, 50]:
        tree = spanning_tree_face_count(n)
        generic = skeleton_face_count(n, 2)  # width-2 generic bound
        print(f"  n={n:3d}:  tree faces = {tree:4d} (= 2n)   "
              f"generic width-2 skeleton = {generic:5d}")
    # Verify on an explicit path graph (a tree): 0-1-2-3-4
    n = 5
    path_edges = [(0, 1), (1, 2), (2, 3), (3, 4)]
    faces = spanning_tree_face_count_from_edges(path_edges, n)
    assert faces == 2 * n
    print(f"  explicit path on {n} vertices: {faces} faces  (matches 2n = {2*n})")
    print()


def demo_colorful_line() -> None:
    print("=" * 70)
    print("Part III: Colorful Caratheodory on the line -- rainbow edges")
    print("=" * 70)
    examples: List[Tuple[List[float], List[float]]] = [
        ([-3.0, -1.0, 2.0], [-0.5, 1.0, 4.0]),
        ([-2.0, 5.0], [-1.0, 0.5, 3.0]),
        ([0.0, 7.0], [-4.0, -1.0, 6.0]),
    ]
    for v1, v2 in examples:
        edge = rainbow_edge_on_line(v1, v2)
        assert edge is not None, "both classes capture 0, edge must exist"
        x, y = edge
        coeffs = zero_convex_coefficients(x, y)
        assert coeffs is not None
        lam, mu = coeffs
        combo = lam * x + mu * y
        assert abs(combo) < 1e-12, "convex combination must equal 0"
        print(f"  V1={v1}, V2={v2}")
        print(f"    rainbow edge (x,y) = ({x}, {y})")
        print(f"    0 = {lam:.4f}*({x}) + {mu:.4f}*({y}) = {combo:.1e}")
    # A non-example: a class that does not capture 0.
    v1_bad = [1.0, 2.0, 3.0]
    v2_ok = [-1.0, 1.0]
    assert rainbow_edge_on_line(v1_bad, v2_ok) is None
    print(f"  V1={v1_bad} does NOT capture 0  ->  no rainbow edge (correct)")
    print()


def demo_join_vs_witness() -> None:
    print("=" * 70)
    print("Part IV: Exponential join vs. polynomial / linear witness")
    print("=" * 70)
    print(f"  {'d+1 colors':>10} {'|V_i|':>6} {'join top faces':>16} "
          f"{'poly witness':>14} {'tree witness':>14}")
    for colors, size in [(2, 10), (3, 10), (4, 10), (5, 10)]:
        color_sizes = [size] * colors
        join = join_top_face_count(color_sizes)
        n = colors * size            # ground-set size
        k = colors - 1               # width d+1 = k+1  => k = colors-1
        poly = polynomial_witness_bound(n, k)
        tree = spanning_tree_face_count(n) if k == 1 else None
        tree_str = f"{tree}" if tree is not None else "n/a (k>1)"
        print(f"  {colors:>10} {size:>6} {join:>16} {poly:>14} {tree_str:>14}")
    print()


def main() -> None:
    demo_skeleton_counts()
    demo_tree_collapse()
    demo_colorful_line()
    demo_join_vs_witness()
    print("All demonstrations completed and internal assertions passed.")


if __name__ == "__main__":
    main()
