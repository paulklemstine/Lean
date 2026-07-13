"""Numerical demonstrations for the sqrt(2)-threshold Vietoris-Rips lower bound.

This self-contained script illustrates the three bridges of the accompanying
paper on the equidistant configuration (the n standard basis vectors of R^n,
pairwise at distance sqrt(2)):

  1. Geometry <-> graph theory: the Vietoris-Rips complex equals the clique
     complex of the proximity graph.
  2. Extremal graph theory: a graph on n vertices has at most 2^n cliques,
     with equality for the complete graph.
  3. Information theory: a level with 2^n simplices needs exactly n bits.

All functions are inlined and type-hinted; the script has no dependencies beyond
the Python standard library.
"""

from __future__ import annotations

import math
from itertools import combinations
from typing import Dict, FrozenSet, List, Set, Tuple

Point = int
Subset = FrozenSet[Point]
Edge = FrozenSet[Point]


# --------------------------------------------------------------------------
# Core constructions
# --------------------------------------------------------------------------
def equidistant_dissimilarity(n: int, d: float) -> Dict[Tuple[int, int], float]:
    """Equidistant dissimilarity on {0,...,n-1}: 0 on the diagonal, d off it."""
    return {(i, j): (0.0 if i == j else d) for i in range(n) for j in range(n)}


def all_subsets(n: int) -> List[Subset]:
    """Every subset of {0,...,n-1}; there are 2^n of them."""
    out: List[Subset] = []
    for k in range(n + 1):
        for combo in combinations(range(n), k):
            out.append(frozenset(combo))
    return out


def is_vr_simplex(D: Dict[Tuple[int, int], float], r: float, S: Subset) -> bool:
    """A subset is a VR simplex at scale r iff every pair is within r."""
    return all(D[(i, j)] <= r for i in S for j in S)


def vr_complex(D: Dict[Tuple[int, int], float], r: float, n: int) -> List[Subset]:
    """The Vietoris-Rips complex at scale r: all simplices."""
    return [S for S in all_subsets(n) if is_vr_simplex(D, r, S)]


def proximity_edges(D: Dict[Tuple[int, int], float], r: float, n: int) -> Set[Edge]:
    """Edges of the proximity graph: distinct points mutually within r."""
    return {
        frozenset((i, j))
        for i in range(n)
        for j in range(n)
        if i != j and D[(i, j)] <= r and D[(j, i)] <= r
    }


def is_clique(edges: Set[Edge], S: Subset) -> bool:
    """A subset is a clique iff all its distinct pairs are edges."""
    return all(frozenset((i, j)) in edges for i, j in combinations(sorted(S), 2))


def clique_complex(edges: Set[Edge], n: int) -> List[Subset]:
    """All cliques of the graph given by its edge set."""
    return [S for S in all_subsets(n) if is_clique(edges, S)]


def bit_complexity(family_size: int) -> int:
    """Number of bits to address family_size objects: ceil(log2(size))."""
    if family_size <= 1:
        return 0
    return math.ceil(math.log2(family_size))


def gamma(c: float) -> float:
    """The sharp exponent gamma(c) = 1/2 - log2(c)."""
    return 0.5 - math.log2(c)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_clique_dictionary(n: int = 5) -> None:
    """Verify VR complex == clique complex of the proximity graph."""
    print("=== Bridge 1: geometry <-> graph theory (clique dictionary) ===")
    d = math.sqrt(2)
    D = equidistant_dissimilarity(n, d)
    r = math.sqrt(2)
    vr = set(vr_complex(D, r, n))
    cl = set(clique_complex(proximity_edges(D, r, n), n))
    print(f"n = {n}, scale r = sqrt(2) ~ {r:.6f}")
    print(f"|VR complex|      = {len(vr)}")
    print(f"|clique complex|  = {len(cl)}")
    print(f"VR == clique?      {vr == cl}")
    print(f"both equal 2^n?    {len(vr) == 2 ** n}\n")


def demo_extremal_bound(n_max: int = 6) -> None:
    """Show the complete graph attains the 2^n clique ceiling."""
    print("=== Bridge 2: extremal graph theory (clique ceiling 2^n) ===")
    print(f"{'n':>3} | {'complete-graph cliques':>22} | {'2^n':>8} | equal?")
    for n in range(1, n_max + 1):
        d = math.sqrt(2)
        D = equidistant_dissimilarity(n, d)
        count = len(clique_complex(proximity_edges(D, math.sqrt(2), n), n))
        print(f"{n:>3} | {count:>22} | {2 ** n:>8} | {count == 2 ** n}")
    print()


def demo_information_floor(n_max: int = 12) -> None:
    """Show a level of 2^n simplices needs exactly n bits."""
    print("=== Bridge 3: information theory (bit complexity == n) ===")
    print(f"{'n':>3} | {'#simplices = 2^n':>18} | {'bits':>5} | matches n?")
    for n in range(1, n_max + 1):
        size = 2 ** n
        bits = bit_complexity(size)
        print(f"{n:>3} | {size:>18} | {bits:>5} | {bits == n}")
    print()


def demo_gamma_threshold() -> None:
    """Show gamma(c) = 1/2 - log2(c) is positive iff c < sqrt(2)."""
    print("=== Sharp exponent gamma(c) = 1/2 - log2(c) ===")
    print(f"{'c':>8} | {'gamma(c)':>10} | positive?")
    for c in [1.0, 1.1, 1.2, 1.3, 1.4, math.sqrt(2), 1.45]:
        g = gamma(c)
        print(f"{c:>8.5f} | {g:>10.6f} | {g > 1e-12}")
    print(f"\nThreshold: gamma(sqrt(2)) = {gamma(math.sqrt(2)):.2e} (crosses 0 at sqrt(2)).\n")


def demo_basis_vectors(n: int = 4) -> None:
    """Confirm the standard basis vectors are pairwise at distance sqrt(2)."""
    print("=== Geometric realization: standard basis vectors ===")

    def basis(i: int, dim: int) -> List[float]:
        return [1.0 if k == i else 0.0 for k in range(dim)]

    def dist(u: List[float], v: List[float]) -> float:
        return math.sqrt(sum((a - b) ** 2 for a, b in zip(u, v)))

    ok = True
    for i, j in combinations(range(n), 2):
        dij = dist(basis(i, n), basis(j, n))
        ok = ok and abs(dij - math.sqrt(2)) < 1e-12
    print(f"n = {n}: all pairwise distances equal sqrt(2)? {ok}\n")


if __name__ == "__main__":
    demo_basis_vectors()
    demo_clique_dictionary()
    demo_extremal_bound()
    demo_information_floor()
    demo_gamma_threshold()
    print("All demonstrations complete.")
