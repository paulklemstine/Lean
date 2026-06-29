"""
Categorical Tropicalization of Interleaving Distance and Vietoris-Rips Stability
================================================================================

Self-contained numerical demonstrations of the verified results:

  * PersMod          -- a persistence module as a monotone edge-set valued map of scale t
  * Interleaved      -- the epsilon-interleaving relation (a pair of shifted dominations)
  * composition law  -- shifts ADD under composition (Interleaved.trans)
  * interleavingDist -- the optimal (infimum) shift; an extended pseudometric
  * tropical view    -- triangle inequality == min-plus submultiplicativity
  * Rips stability   -- sup-close dissimilarities give interleaved Rips modules

Everything is inlined and uses only the Python standard library.
Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, FrozenSet, List, Tuple

Point = int
Edge = Tuple[Point, Point]
Dissimilarity = Dict[Edge, float]


# ---------------------------------------------------------------------------
# 1. Vietoris-Rips module: the edge set present at scale t.
# ---------------------------------------------------------------------------

def rips_edges(d: Dissimilarity, points: List[Point], t: float) -> FrozenSet[Edge]:
    """Edge set { (x, y) : d(x, y) <= t } of the Rips module at scale t.

    This is (RipsMod d).obj t in the lattice Set(X x X). It is MONOTONE in t:
    increasing t only adds edges.
    """
    return frozenset(
        (x, y)
        for x, y in product(points, points)
        if d.get((x, y), float("inf")) <= t
    )


def is_monotone(d: Dissimilarity, points: List[Point], scales: List[float]) -> bool:
    """Verify (RipsMod d) is a persistence module: obj is monotone in scale."""
    scales = sorted(scales)
    for s, t in zip(scales, scales[1:]):
        if not rips_edges(d, points, s) <= rips_edges(d, points, t):
            return False
    return True


# ---------------------------------------------------------------------------
# 2. The epsilon-interleaving relation.
# ---------------------------------------------------------------------------

def is_interleaved(
    obj_M: Callable[[float], FrozenSet[Edge]],
    obj_N: Callable[[float], FrozenSet[Edge]],
    eps: float,
    scales: List[float],
) -> bool:
    """Check Interleaved eps M N on a finite sample of scales:

        for all t:  M(t) <= N(t + eps)  and  N(t) <= M(t + eps).
    """
    for t in scales:
        if not obj_M(t) <= obj_N(t + eps):
            return False
        if not obj_N(t) <= obj_M(t + eps):
            return False
    return True


# ---------------------------------------------------------------------------
# 3. Interleaving distance (optimal shift) for two Rips modules.
# ---------------------------------------------------------------------------

def sup_distance(d: Dissimilarity, d2: Dissimilarity, points: List[Point]) -> float:
    """The sup-distance  ||d - d'||_inf = max_{x,y} |d(x,y) - d'(x,y)|."""
    best = 0.0
    for x, y in product(points, points):
        a = d.get((x, y), float("inf"))
        b = d2.get((x, y), float("inf"))
        if a == float("inf") and b == float("inf"):
            continue
        best = max(best, abs(a - b))
    return best


def interleaving_distance_numeric(
    d: Dissimilarity,
    d2: Dissimilarity,
    points: List[Point],
    eps_grid: List[float],
    scales: List[float],
) -> float:
    """Numerically search for the smallest eps on a grid at which the two Rips
    modules are interleaved.  This approximates interleavingDist (an infimum).
    """
    M = lambda t: rips_edges(d, points, t)
    N = lambda t: rips_edges(d2, points, t)
    for eps in sorted(eps_grid):
        if is_interleaved(M, N, eps, scales):
            return eps
    return float("inf")


# ---------------------------------------------------------------------------
# 4. Tropical (min-plus) semiring view.
# ---------------------------------------------------------------------------

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication = ordinary addition."""
    return a + b


def trop_add(a: float, b: float) -> float:
    """Tropical addition = minimum."""
    return min(a, b)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def symmetric(pairs: Dict[Edge, float], points: List[Point]) -> Dissimilarity:
    """Build a symmetric dissimilarity with zero diagonal from upper-triangle data."""
    d: Dissimilarity = {}
    for x in points:
        d[(x, x)] = 0.0
    for (x, y), v in pairs.items():
        d[(x, y)] = v
        d[(y, x)] = v
    return d


def demo_monotone_and_interleaving() -> None:
    print("=" * 72)
    print("DEMO 1: Rips module is monotone; composition law adds shifts")
    print("=" * 72)
    pts = [0, 1, 2]
    d = symmetric({(0, 1): 1.0, (1, 2): 1.0, (0, 2): 2.0}, pts)
    scales = [x * 0.25 for x in range(0, 13)]
    print(f"points = {pts}")
    print(f"dissimilarity d = {{(0,1):1, (1,2):1, (0,2):2}}")
    print(f"is_monotone(RipsMod d) = {is_monotone(d, pts, scales)}")

    # Three modules from three dissimilarities; compose interleavings.
    d_M = d
    d_N = symmetric({(0, 1): 1.3, (1, 2): 1.0, (0, 2): 2.2}, pts)  # within 0.3 of d
    d_L = symmetric({(0, 1): 1.3, (1, 2): 1.4, (0, 2): 2.6}, pts)  # within 0.4 of d_N

    M = lambda t: rips_edges(d_M, pts, t)
    N = lambda t: rips_edges(d_N, pts, t)
    L = lambda t: rips_edges(d_L, pts, t)

    eps = sup_distance(d_M, d_N, pts)
    delta = sup_distance(d_N, d_L, pts)
    print(f"\n||d_M - d_N||_inf = {eps:.2f}  -> Interleaved(eps) M N = "
          f"{is_interleaved(M, N, eps, scales)}")
    print(f"||d_N - d_L||_inf = {delta:.2f}  -> Interleaved(delta) N L = "
          f"{is_interleaved(N, L, delta, scales)}")
    composed = trop_mul(eps, delta)
    print(f"composition law: shift(M,L) <= eps (+)_trop delta = {eps:.2f} + "
          f"{delta:.2f} = {composed:.2f}")
    print(f"check Interleaved({composed:.2f}) M L = "
          f"{is_interleaved(M, L, composed, scales)}")


def demo_stability() -> None:
    print()
    print("=" * 72)
    print("DEMO 2: Rips stability -- interleavingDist <= sup-distance")
    print("=" * 72)
    pts = [0, 1, 2, 3]
    base = symmetric(
        {(0, 1): 1.0, (1, 2): 1.0, (2, 3): 1.0, (0, 3): 2.0,
         (0, 2): 1.5, (1, 3): 1.5},
        pts,
    )
    perturbed = symmetric(
        {(0, 1): 1.2, (1, 2): 0.8, (2, 3): 1.3, (0, 3): 2.1,
         (0, 2): 1.4, (1, 3): 1.6},
        pts,
    )
    scales = [x * 0.1 for x in range(0, 31)]
    eps_grid = [x * 0.05 for x in range(0, 21)]

    sup = sup_distance(base, perturbed, pts)
    idist = interleaving_distance_numeric(base, perturbed, pts, eps_grid, scales)
    print(f"||d - d'||_inf (theoretical upper bound) = {sup:.3f}")
    print(f"numerically optimal interleaving shift    = {idist:.3f}")
    print(f"STABILITY  interleavingDist <= sup-dist :  {idist:.3f} <= {sup:.3f}  "
          f"-> {idist <= sup + 1e-9}")


def demo_triangle_is_tropical() -> None:
    print()
    print("=" * 72)
    print("DEMO 3: Triangle inequality == tropical submultiplicativity")
    print("=" * 72)
    pts = [0, 1, 2]
    d_M = symmetric({(0, 1): 1.0, (1, 2): 1.0, (0, 2): 2.0}, pts)
    d_N = symmetric({(0, 1): 1.5, (1, 2): 1.2, (0, 2): 2.4}, pts)
    d_L = symmetric({(0, 1): 0.6, (1, 2): 1.4, (0, 2): 1.9}, pts)
    scales = [x * 0.1 for x in range(0, 31)]
    eps_grid = [x * 0.05 for x in range(0, 41)]

    d_ML = interleaving_distance_numeric(d_M, d_L, pts, eps_grid, scales)
    d_MN = interleaving_distance_numeric(d_M, d_N, pts, eps_grid, scales)
    d_NL = interleaving_distance_numeric(d_N, d_L, pts, eps_grid, scales)
    rhs = trop_mul(d_MN, d_NL)
    print(f"d(M,L) = {d_ML:.3f}")
    print(f"d(M,N) = {d_MN:.3f},  d(N,L) = {d_NL:.3f}")
    print(f"trop:  d(M,L) <= d(M,N) (*)_trop d(N,L) = {d_MN:.3f} + {d_NL:.3f} "
          f"= {rhs:.3f}")
    print(f"triangle inequality holds: {d_ML <= rhs + 1e-9}")


if __name__ == "__main__":
    demo_monotone_and_interleaving()
    demo_stability()
    demo_triangle_is_tropical()
    print()
    print("All demonstrations completed.")
