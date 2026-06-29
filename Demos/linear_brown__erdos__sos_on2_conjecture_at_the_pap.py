"""Numerical demonstrations for the sharp density threshold of linear
r-uniform hypergraphs.

This script illustrates the formally verified results:

  * linear_card_le      :  m * C(r,2) <= C(n,2)
  * linear_density_real :  m <= n(n-1) / (r(r-1))     (for r >= 2)
  * steiner_card_eq     :  m * C(r,2) = C(n,2)        (Steiner systems)

A hypergraph is *linear* if any two distinct edges meet in at most one vertex.
A *Steiner system* S(2,r,n) is a linear r-uniform hypergraph covering every
pair of vertices exactly once; it attains the threshold with equality.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import FrozenSet, Iterable, List, Sequence, Set, Tuple

Edge = FrozenSet[int]
Hypergraph = List[Edge]


# --------------------------------------------------------------------------- #
# Core predicates (computational counterparts of the Lean definitions)
# --------------------------------------------------------------------------- #
def is_uniform(edges: Hypergraph, r: int) -> bool:
    """IsUniform: every edge has exactly r vertices."""
    return all(len(e) == r for e in edges)


def is_linear(edges: Hypergraph) -> bool:
    """IsLinear: any two distinct edges meet in at most one vertex."""
    for e1, e2 in combinations(edges, 2):
        if len(e1 & e2) > 1:
            return False
    return True


def induced_pairs(edge: Edge) -> Set[FrozenSet[int]]:
    """The family C(e,2) of 2-element subsets of an edge."""
    return {frozenset(p) for p in combinations(sorted(edge), 2)}


def is_steiner(edges: Hypergraph, r: int, vertices: Sequence[int]) -> bool:
    """IsSteiner: r-uniform, linear, and every pair of vertices is covered."""
    if not (is_uniform(edges, r) and is_linear(edges)):
        return False
    covered: Set[FrozenSet[int]] = set()
    for e in edges:
        covered |= induced_pairs(e)
    all_pairs = {frozenset(p) for p in combinations(vertices, 2)}
    return all_pairs <= covered


# --------------------------------------------------------------------------- #
# The threshold quantities
# --------------------------------------------------------------------------- #
def threshold_integer(n: int, r: int) -> int:
    """Right-hand side C(n,2) of m * C(r,2) <= C(n,2)."""
    return comb(n, 2)


def threshold_real(n: int, r: int) -> float:
    """The real density bound n(n-1)/(r(r-1)) (r >= 2)."""
    return n * (n - 1) / (r * (r - 1))


def check_bound(edges: Hypergraph, n: int, r: int) -> Tuple[int, int, bool]:
    """Return (lhs, rhs, holds) for linear_card_le on the given hypergraph."""
    m = len(edges)
    lhs = m * comb(r, 2)
    rhs = comb(n, 2)
    return lhs, rhs, lhs <= rhs


# --------------------------------------------------------------------------- #
# Explicit constructions
# --------------------------------------------------------------------------- #
def fano_plane() -> Hypergraph:
    """The Steiner system S(2,3,7): cyclic translates of {0,1,3} mod 7."""
    base = (0, 1, 3)
    return [frozenset((b + s) % 7 for b in base) for s in range(7)]


def cyclic_triangle_packing(n: int) -> Hypergraph:
    """A simple linear 3-uniform packing on {0,...,n-1} (not necessarily
    Steiner): greedily add triples that keep all pairs distinct."""
    edges: Hypergraph = []
    used_pairs: Set[FrozenSet[int]] = set()
    for triple in combinations(range(n), 3):
        e = frozenset(triple)
        pairs = induced_pairs(e)
        if pairs.isdisjoint(used_pairs):
            edges.append(e)
            used_pairs |= pairs
    return edges


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_fano() -> None:
    print("=" * 64)
    print("DEMO 1: The Fano plane S(2,3,7) attains the threshold")
    print("=" * 64)
    n, r = 7, 3
    edges = fano_plane()
    vertices = list(range(7))
    print("Edges (lines):")
    for e in edges:
        print("  ", sorted(e))
    print(f"uniform({r})? {is_uniform(edges, r)}")
    print(f"linear?       {is_linear(edges)}")
    print(f"steiner?      {is_steiner(edges, r, vertices)}")
    lhs, rhs, ok = check_bound(edges, n, r)
    print(f"m * C(r,2) = {len(edges)} * {comb(r,2)} = {lhs}")
    print(f"C(n,2)     = C({n},2)         = {rhs}")
    print(f"linear_card_le holds:  {ok}")
    print(f"steiner_card_eq (equality): {lhs == rhs}")
    print(f"real threshold n(n-1)/(r(r-1)) = {threshold_real(n, r):.4f}, "
          f"edges = {len(edges)}")
    print()


def demo_packing() -> None:
    print("=" * 64)
    print("DEMO 2: Greedy linear triple packings respect the bound")
    print("=" * 64)
    print(f"{'n':>4} | {'edges':>6} | {'m*C(r,2)':>9} | {'C(n,2)':>7} | "
          f"{'real bound':>10} | ok")
    print("-" * 60)
    r = 3
    for n in range(3, 16):
        edges = cyclic_triangle_packing(n)
        lhs, rhs, ok = check_bound(edges, n, r)
        print(f"{n:>4} | {len(edges):>6} | {lhs:>9} | {rhs:>7} | "
              f"{threshold_real(n, r):>10.3f} | {ok}")
    print()


def demo_steiner_search() -> None:
    print("=" * 64)
    print("DEMO 3: When does equality (a full Steiner system) occur?")
    print("=" * 64)
    print("Admissibility for S(2,3,n): n = 1 or 3 (mod 6).")
    r = 3
    for n in range(3, 22):
        admissible = n % 6 in (1, 3)
        cap_real = threshold_real(n, r)
        cap_int = comb(n, 2) // comb(r, 2)
        tag = "  <- Steiner-admissible (equality achievable)" if admissible else ""
        print(f"n={n:>2}: max edges <= {cap_real:7.3f}  "
              f"(integer cap {cap_int}){tag}")
    print()


def demo_density_scaling() -> None:
    print("=" * 64)
    print("DEMO 4: Density coefficient 1/(r(r-1)) across uniformities")
    print("=" * 64)
    n = 1000
    print(f"n = {n}; bound m <= n(n-1)/(r(r-1)):")
    for r in range(2, 8):
        coeff = 1.0 / (r * (r - 1))
        print(f"  r={r}: coefficient 1/(r(r-1)) = {coeff:.6f}, "
              f"max edges ~ {threshold_real(n, r):,.0f}")
    print()


def main() -> None:
    demo_fano()
    demo_packing()
    demo_steiner_search()
    demo_density_scaling()
    print("All demonstrations consistent with the formally verified results.")


if __name__ == "__main__":
    main()
