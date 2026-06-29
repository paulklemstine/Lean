"""
Numerical demonstrations for:

    "A Dimension-Free Spectral Bound for the Signless Laplacian
     of Pure Simplicial Complexes"

We model the facet-ridge incidence of a pure r-dimensional simplicial complex
abstractly: a facet is a set of ridges, and a complex is a list of facets.
The signless Laplacian is Q = B B^T on the ridges, whose quadratic form is the
manifest sum of squares

    slQuad(x) = sum_f ( sum_{rho in facet f} x_rho )^2.

This script verifies, on concrete examples, the results of the paper:

  * slQuad_nonneg     : the form is positive semidefinite,
  * slQuad_eq_matrix  : slQuad(x) = x^T Q x,
  * slQuad_le         : slQuad(x) <= (facet size)*(max degree)*||x||^2,
  * specRad_le        : q_{r-1} <= (r+1)*Delta,
  * simplex_specRad   : a single r-simplex attains q_{r-1} = r+1,
  * graph_specRad_le  : the r=1 case recovers q(G) <= 2*Delta(G),
                        including the boundary example q(K_3) = 4.

Only the Python standard library plus numpy are used.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, FrozenSet, List, Sequence, Tuple

import numpy as np

Ridge = int
Facet = FrozenSet[Ridge]
Complex = List[Facet]


# ---------------------------------------------------------------------------
# Core incidence quantities
# ---------------------------------------------------------------------------
def ridges_of(complex_: Sequence[Facet]) -> List[Ridge]:
    """Sorted list of all ridges appearing in any facet."""
    seen: set[Ridge] = set()
    for f in complex_:
        seen.update(f)
    return sorted(seen)


def incidence_matrix(complex_: Sequence[Facet]) -> Tuple[np.ndarray, List[Ridge]]:
    """Unsigned ridge-facet incidence matrix B (|R| x |F|) and the ridge order."""
    ridges = ridges_of(complex_)
    index: Dict[Ridge, int] = {r: i for i, r in enumerate(ridges)}
    B = np.zeros((len(ridges), len(complex_)), dtype=float)
    for j, f in enumerate(complex_):
        for r in f:
            B[index[r], j] = 1.0
    return B, ridges


def signless_laplacian(complex_: Sequence[Facet]) -> Tuple[np.ndarray, List[Ridge]]:
    """The signless Laplacian Q = B B^T and the ridge order."""
    B, ridges = incidence_matrix(complex_)
    return B @ B.T, ridges


def sl_quad(complex_: Sequence[Facet], x: Dict[Ridge, float]) -> float:
    """slQuad(x) = sum_f ( sum_{rho in facet f} x_rho )^2."""
    total = 0.0
    for f in complex_:
        s = sum(x.get(r, 0.0) for r in f)
        total += s * s
    return total


def ridge_degree(complex_: Sequence[Facet], r: Ridge) -> int:
    """Number of facets containing ridge r."""
    return sum(1 for f in complex_ if r in f)


def max_degree(complex_: Sequence[Facet]) -> int:
    return max((ridge_degree(complex_, r) for r in ridges_of(complex_)), default=0)


def facet_size(complex_: Sequence[Facet]) -> int:
    return max((len(f) for f in complex_), default=0)


def spectral_radius(complex_: Sequence[Facet]) -> float:
    """Largest eigenvalue q_{r-1} of the symmetric PSD signless Laplacian."""
    Q, _ = signless_laplacian(complex_)
    if Q.size == 0:
        return 0.0
    return float(np.max(np.linalg.eigvalsh(Q)))


def certified_bound(complex_: Sequence[Facet]) -> int:
    """The certified ceiling (facet size)*(max degree) from specRad_le."""
    return facet_size(complex_) * max_degree(complex_)


# ---------------------------------------------------------------------------
# Builders for canonical complexes
# ---------------------------------------------------------------------------
def simplex(r: int) -> Complex:
    """The single r-simplex: one facet whose r+1 ridges are its (r-1)-faces."""
    return [frozenset(range(r + 1))]


def complete_graph_as_complex(n: int) -> Complex:
    """K_n as a 1-complex: ridges = vertices, facets = edges (2-element sets)."""
    return [frozenset(e) for e in combinations(range(n), 2)]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_matrix_identity(complex_: Sequence[Facet], trials: int = 5) -> None:
    """slQuad_eq_matrix: slQuad(x) == x^T Q x on random vectors."""
    Q, ridges = signless_laplacian(complex_)
    rng = np.random.default_rng(0)
    print("  slQuad(x) vs x^T Q x:")
    for _ in range(trials):
        vec = rng.standard_normal(len(ridges))
        x = {r: float(vec[i]) for i, r in enumerate(ridges)}
        lhs = sl_quad(complex_, x)
        rhs = float(vec @ Q @ vec)
        ok = abs(lhs - rhs) < 1e-9
        print(f"    slQuad={lhs:12.6f}  xtQx={rhs:12.6f}  match={ok}")


def demo_nonneg_and_bound(complex_: Sequence[Facet], trials: int = 6) -> None:
    """slQuad_nonneg and slQuad_le on random vectors."""
    s, D = facet_size(complex_), max_degree(complex_)
    ridges = ridges_of(complex_)
    rng = np.random.default_rng(1)
    print(f"  facet size s={s}, max degree D={D}, ceiling s*D={s*D}")
    for _ in range(trials):
        vec = rng.standard_normal(len(ridges))
        x = {r: float(vec[i]) for i, r in enumerate(ridges)}
        q = sl_quad(complex_, x)
        norm2 = float(vec @ vec)
        rayleigh = q / norm2 if norm2 else 0.0
        print(
            f"    slQuad={q:10.5f} >= 0 : {q >= -1e-12}   "
            f"Rayleigh={rayleigh:8.5f} <= {s*D} : {rayleigh <= s*D + 1e-9}"
        )


def demo_spectral_bound(complex_: Sequence[Facet], label: str) -> None:
    """specRad_le: q_{r-1} <= certified ceiling, with tightness reported."""
    q = spectral_radius(complex_)
    ceiling = certified_bound(complex_)
    gap = ceiling - q
    print(f"  [{label}] q_(r-1) = {q:.6f}   ceiling (r+1)*Delta = {ceiling}   "
          f"gap = {gap:.6f}   bound holds = {q <= ceiling + 1e-9}")


def demo_simplex_sharpness(max_r: int = 5) -> None:
    """simplex_specRad: q_{r-1}(simplex) = r+1, attained by all-ones."""
    print("  r : q_(r-1)(simplex)  expected r+1")
    for r in range(1, max_r + 1):
        K = simplex(r)
        q = spectral_radius(K)
        # All-ones Rayleigh quotient:
        ridges = ridges_of(K)
        ones = {ridge: 1.0 for ridge in ridges}
        rq = sl_quad(K, ones) / len(ridges)
        print(f"  {r} :     {q:8.5f}        {r+1}   (all-ones Rayleigh={rq:.5f})")


def demo_graph_case() -> None:
    """graph_specRad_le and the boundary example q(K_3) = 4 = 2*Delta."""
    print("  Complete graphs K_n as 1-complexes (q(G) <= 2*Delta):")
    for n in range(2, 7):
        K = complete_graph_as_complex(n)
        q = spectral_radius(K)
        Delta = max_degree(K)  # vertex degree = n-1
        print(f"    K_{n}: q={q:8.5f}   2*Delta={2*Delta}   "
              f"tight={abs(q - 2*Delta) < 1e-9}")
    print("  Note: q(K_3) = 4 = 2*Delta is the boundary example "
          "(unfilled triangle has H_1 != 0).")


def main() -> None:
    print("=" * 70)
    print("Signless Laplacian spectral bounds for pure simplicial complexes")
    print("=" * 70)

    tri = simplex(2)          # a single filled triangle (r = 2)
    tet = simplex(3)          # a single tetrahedron (r = 3)

    print("\n[1] Matrix identity slQuad(x) = x^T Q x  (filled triangle, r=2)")
    demo_matrix_identity(tri)

    print("\n[2] Positive semidefiniteness and Cauchy-Schwarz bound (tetrahedron, r=3)")
    demo_nonneg_and_bound(tet)

    print("\n[3] Spectral bound q_(r-1) <= (r+1)*Delta")
    demo_spectral_bound(tri, "filled triangle r=2")
    demo_spectral_bound(tet, "tetrahedron r=3")
    demo_spectral_bound(complete_graph_as_complex(3), "K_3 graph r=1")

    print("\n[4] Sharpness on the simplex: q_(r-1) = r+1")
    demo_simplex_sharpness()

    print("\n[5] Graph case r=1 recovers q(G) <= 2*Delta(G)")
    demo_graph_case()

    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
