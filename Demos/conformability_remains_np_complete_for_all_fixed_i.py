"""Numerical demonstrations for the odd-clique obstruction to conformability of
odd-order regular graphs.

This self-contained script illustrates, with concrete computations:

  * ``odd_cap``               -- the largest odd number not exceeding ``a``;
  * the odd-clique counting bound  n <= (d + 1) * oddCap(alpha)   (Theorem 5.1);
  * the strict improvement of oddCap(alpha) over the naive cap alpha when alpha
    is even;
  * the degree-parity obstruction: conformable odd-order regular graphs force d
    even (Theorem 5.2);
  * the contrapositive infeasibility certificate (Theorem 5.4);
  * the K_3 tightness witness (Theorem 5.5);
  * the complement-clique view: a conformable coloring is a partition into odd
    cliques of the complement.

No external dependencies are required (standard library only).
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, List, Optional, Sequence, Set, Tuple


# ---------------------------------------------------------------------------
# Core arithmetic quantity: oddCap
# ---------------------------------------------------------------------------
def odd_cap(a: int) -> int:
    """Largest odd integer <= a, with odd_cap(0) = 0.

    Mirrors the Lean definition ``oddCap a := if Odd a then a else a - 1``.
    """
    if a <= 0:
        return 0
    return a if a % 2 == 1 else a - 1


def odd_le_odd_cap(x: int, a: int) -> bool:
    """Lemma 3.1: if x is odd and x <= a then x <= oddCap(a)."""
    if x % 2 == 1 and x <= a:
        return x <= odd_cap(a)
    return True  # hypothesis not met -> statement vacuously holds


# ---------------------------------------------------------------------------
# The two parity obstructions as polynomial-time certificates
# ---------------------------------------------------------------------------
def conformable_upper_bound(d: int, alpha: int) -> int:
    """Right-hand side (d + 1) * oddCap(alpha) of the counting obstruction."""
    return (d + 1) * odd_cap(alpha)


def naive_upper_bound(d: int, alpha: int) -> int:
    """The weaker bound (d + 1) * alpha that ignores the parity constraint."""
    return (d + 1) * alpha


def parity_feasibility_certificate(n: int, d: int, alpha: int) -> str:
    """Constant-time necessary-condition check for odd-order d-regular graphs.

    Returns one of 'INFEASIBLE (odd degree)', 'INFEASIBLE (size exceeds bound)',
    or 'PARITY-FEASIBLE'.
    """
    if n % 2 == 0:
        return "N/A (theory addresses odd order only)"
    if d % 2 == 1:  # Theorem 5.2
        return "INFEASIBLE (odd degree)"
    if conformable_upper_bound(d, alpha) < n:  # Theorem 5.4
        return "INFEASIBLE (size exceeds bound)"
    return "PARITY-FEASIBLE"


# ---------------------------------------------------------------------------
# Graph utilities (adjacency as a dict of vertex -> set of neighbours)
# ---------------------------------------------------------------------------
Graph = Dict[int, Set[int]]


def complete_graph(n: int) -> Graph:
    """The complete graph K_n on vertices 0..n-1 (every pair adjacent)."""
    return {v: {u for u in range(n) if u != v} for v in range(n)}


def complement(g: Graph) -> Graph:
    """Complement graph: u ~ v in the complement iff u != v and not adjacent in g."""
    verts = list(g)
    return {v: {u for u in verts if u != v and u not in g[v]} for v in verts}


def is_independent_set(g: Graph, s: Sequence[int]) -> bool:
    """True iff no two vertices of s are adjacent in g."""
    return all(v not in g[u] for u, v in combinations(s, 2))


def is_clique(g: Graph, s: Sequence[int]) -> bool:
    """True iff every two distinct vertices of s are adjacent in g."""
    return all(v in g[u] for u, v in combinations(s, 2))


def independence_number(g: Graph) -> int:
    """Brute-force independence number (small graphs only)."""
    verts = list(g)
    best = 0
    for k in range(len(verts), 0, -1):
        for s in combinations(verts, k):
            if is_independent_set(g, s):
                return k
    return best


def color_classes(coloring: Dict[int, int]) -> Dict[int, List[int]]:
    """Group vertices by their assigned color."""
    classes: Dict[int, List[int]] = {}
    for v, c in coloring.items():
        classes.setdefault(c, []).append(v)
    return classes


def is_proper(g: Graph, coloring: Dict[int, int]) -> bool:
    """A coloring is proper iff adjacent vertices differ in color."""
    return all(coloring[u] != coloring[v] for u in g for v in g[u] if u < v)


def is_conformable_regular(g: Graph, coloring: Dict[int, int], n: int) -> bool:
    """For a regular graph (deficiency 0): every color class matches n's parity."""
    if not is_proper(g, coloring):
        return False
    return all(len(cls) % 2 == n % 2 for cls in color_classes(coloring).values())


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_odd_cap() -> None:
    print("=" * 68)
    print("1.  oddCap(a) = largest odd number <= a")
    print("=" * 68)
    for a in range(0, 11):
        print(f"    oddCap({a:2d}) = {odd_cap(a)}")
    print()


def demo_strict_improvement() -> None:
    print("=" * 68)
    print("2.  oddCap bound vs naive bound  (improvement when alpha is even)")
    print("=" * 68)
    print(f"    {'d':>2} {'alpha':>6} {'naive (d+1)a':>14} {'sharp (d+1)oddCap':>18} {'gain':>6}")
    for d, alpha in [(4, 4), (4, 3), (6, 6), (2, 1), (4, 8), (8, 5)]:
        naive = naive_upper_bound(d, alpha)
        sharp = conformable_upper_bound(d, alpha)
        print(f"    {d:>2} {alpha:>6} {naive:>14} {sharp:>18} {naive - sharp:>6}")
    print()


def demo_degree_parity() -> None:
    print("=" * 68)
    print("3.  Degree-parity obstruction (Theorem 5.2): odd order => d even")
    print("=" * 68)
    for n, d, alpha in [(15, 4, 4), (15, 5, 4), (9, 2, 1), (21, 7, 3)]:
        verdict = parity_feasibility_certificate(n, d, alpha)
        print(f"    n={n:>2}, d={d}, alpha={alpha}:  {verdict}")
    print()


def demo_contrapositive() -> None:
    print("=" * 68)
    print("4.  Contrapositive certificate (Theorem 5.4)")
    print("=" * 68)
    for n, d, alpha in [(16, 4, 4), (15, 4, 4), (20, 4, 4), (3, 2, 1)]:
        bound = conformable_upper_bound(d, alpha)
        verdict = parity_feasibility_certificate(n, d, alpha)
        print(f"    n={n:>2}, d={d}, alpha={alpha}:  (d+1)oddCap(alpha)={bound:>3}  ->  {verdict}")
    print()


def demo_triangle_witness() -> None:
    print("=" * 68)
    print("5.  K_3 tightness witness (Theorem 5.5)")
    print("=" * 68)
    g = complete_graph(3)
    n = 3
    d = 2  # 2-regular
    alpha = independence_number(g)
    coloring = {0: 0, 1: 1, 2: 2}  # d + 1 = 3 colors, one vertex each
    proper = is_proper(g, coloring)
    conf = is_conformable_regular(g, coloring, n)
    bound = conformable_upper_bound(d, alpha)
    print(f"    K_3: n={n}, d={d} (even: {d % 2 == 0}), alpha={alpha}")
    print(f"    coloring {coloring}: proper={proper}, conformable={conf}")
    print(f"    bound (d+1)oddCap(alpha) = {bound}  ==  n = {n}  -> equality (tight)")
    print()


def find_odd_clique_partition(
    gc: Graph, num_classes: int, max_size: int
) -> Optional[List[Tuple[int, ...]]]:
    """Partition the complement gc into exactly num_classes cliques, each of odd
    size at most max_size (the complement view of a conformable coloring).

    Backtracking exact-cover search; intended for small graphs.
    """
    verts = sorted(gc)
    odd_sizes = [s for s in range(1, max_size + 1) if s % 2 == 1]

    def backtrack(remaining: FrozenSet[int], parts: List[Tuple[int, ...]]) -> Optional[List[Tuple[int, ...]]]:
        if not remaining:
            return parts if len(parts) == num_classes else None
        if len(parts) >= num_classes:
            return None
        pivot = min(remaining)
        for size in odd_sizes:
            if size > len(remaining):
                continue
            others = [u for u in remaining if u != pivot]
            for combo in combinations(others, size - 1):
                clique = (pivot,) + combo
                if is_clique(gc, clique):
                    res = backtrack(remaining - set(clique), parts + [clique])
                    if res is not None:
                        return res
        return None

    return backtrack(frozenset(verts), [])


def demo_complement_partition() -> None:
    print("=" * 68)
    print("6.  Complement odd-clique partition view (Lemma 4.2 / Algorithm 7.2)")
    print("=" * 68)
    # Two disjoint triangles: G^c is K_{3,3}-like... use G = 2 triangles (6-cycle complement)
    # Take G = K_3 + K_3 (disjoint union); its complement is K_{3,3} plus... use simplest:
    g = complete_graph(3)
    gc = complement(g)
    # For K_3, complement is empty: each class is a singleton clique (odd size 1).
    n, d, alpha = 3, 2, 1
    partition = find_odd_clique_partition(gc, num_classes=d + 1, max_size=alpha)
    print(f"    G = K_3, complement edges: {{v: sorted(nb) for ...}} = "
          f"{ {v: sorted(gc[v]) for v in gc} }")
    print(f"    odd-clique partition of complement into d+1={d+1} parts, sizes<= {alpha}:")
    print(f"        {partition}")
    print("    -> each part is an odd clique of the complement = a conformable color class")
    print()


def main() -> None:
    demo_odd_cap()
    demo_strict_improvement()
    demo_degree_parity()
    demo_contrapositive()
    demo_triangle_witness()
    demo_complement_partition()


if __name__ == "__main__":
    main()
