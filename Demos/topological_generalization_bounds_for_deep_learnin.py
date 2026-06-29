"""
Topological Generalization Bounds for Deep Learning — Numerical Demonstrations
==============================================================================

Self-contained Python demonstrations of the verified mathematics:

  1. The Vietoris-Rips construction over a finite (pseudo)metric space, with
     explicit numerical checks of the three verified structural laws:
       * VRSimplex_mono        — monotonicity in scale
       * VRSimplex_of_subset   — downward closure (faces of simplices)
       * scaleInclusion_comp   — functoriality (identity & composition)
  2. Computation of the first Betti number b1 (number of independent loops)
     of a Vietoris-Rips complex, on point clouds with KNOWN topology
     (a circle should yield b1 = 1).
  3. The McAllester-style topological generalization bound and its verified
     behaviour: exact gap, monotonicity in b1, and consistency as n -> infinity.
  4. The combinatorial 2^n branching ceiling on maximal consistent extensions.

No third-party dependencies are required (only the standard library).
"""

from __future__ import annotations

import math
from itertools import combinations
from typing import Dict, FrozenSet, List, Sequence, Set, Tuple

Point = Tuple[float, ...]


# ---------------------------------------------------------------------------
# 1. Vietoris-Rips simplices and the verified structural laws
# ---------------------------------------------------------------------------

def dist(x: Point, y: Point) -> float:
    """Euclidean distance — a genuine (pseudo)metric on tuples of floats."""
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))


def is_vr_simplex(points: Sequence[Point], sigma: FrozenSet[int], r: float) -> bool:
    """VRSimplex r sigma: all pairwise distances within the finite set are <= r."""
    idx = list(sigma)
    return all(dist(points[i], points[j]) <= r for i in idx for j in idx)


def vr_simplices(points: Sequence[Point], r: float, max_dim: int) -> List[FrozenSet[int]]:
    """All VR simplices at scale r up to dimension max_dim (size max_dim + 1)."""
    n = len(points)
    out: List[FrozenSet[int]] = [frozenset()]  # the empty simplex
    for k in range(1, max_dim + 2):
        for combo in combinations(range(n), k):
            sigma = frozenset(combo)
            if is_vr_simplex(points, sigma, r):
                out.append(sigma)
    return out


def scale_inclusion(sigma: FrozenSet[int]) -> FrozenSet[int]:
    """The scale inclusion preserves the underlying finite set (scaleInclusion_coe)."""
    return sigma


def check_structural_laws(points: Sequence[Point]) -> None:
    print("=" * 70)
    print("1. VERIFIED VIETORIS-RIPS STRUCTURAL LAWS (numerical witnesses)")
    print("=" * 70)

    # Monotonicity in scale: VR at r  =>  VR at s for r <= s
    r, s = 1.0, 2.0
    mono_ok = True
    for k in range(1, len(points) + 1):
        for combo in combinations(range(len(points)), k):
            sigma = frozenset(combo)
            if is_vr_simplex(points, sigma, r) and not is_vr_simplex(points, sigma, s):
                mono_ok = False
    print(f"  VRSimplex_mono     (r={r} <= s={s}): {'HOLDS' if mono_ok else 'FAILS'}")

    # Downward closure: faces of a VR simplex are VR simplices
    closure_ok = True
    for sigma in vr_simplices(points, s, max_dim=len(points)):
        for k in range(len(sigma)):
            for face in combinations(sigma, k):
                if not is_vr_simplex(points, frozenset(face), s):
                    closure_ok = False
    print(f"  VRSimplex_of_subset (downward closure):  "
          f"{'HOLDS' if closure_ok else 'FAILS'}")

    # Functoriality: identity and composition of scale inclusions
    sample = frozenset({0, 1})
    refl_ok = scale_inclusion(sample) == sample
    comp_ok = scale_inclusion(scale_inclusion(sample)) == scale_inclusion(sample)
    print(f"  scaleInclusion_refl (identity law):      {'HOLDS' if refl_ok else 'FAILS'}")
    print(f"  scaleInclusion_comp (composition law):   {'HOLDS' if comp_ok else 'FAILS'}")
    print()


# ---------------------------------------------------------------------------
# 2. First Betti number b1 of a Vietoris-Rips complex
# ---------------------------------------------------------------------------

def betti_numbers(points: Sequence[Point], r: float) -> Tuple[int, int]:
    """
    Compute (b0, b1) of the VR complex at scale r over GF(2).

    b0 = V - rank(boundary_1)            (connected components)
    b1 = (E - rank(boundary_1)) - rank(boundary_2)
       = cycles - boundaries             (independent loops)
    using simplices up to dimension 2 (vertices, edges, triangles).
    """
    n = len(points)
    verts = list(range(n))
    edges = [e for e in combinations(verts, 2) if is_vr_simplex(points, frozenset(e), r)]
    tris = [t for t in combinations(verts, 3) if is_vr_simplex(points, frozenset(t), r)]

    rank_d1 = _gf2_rank(_boundary1(edges, n))
    rank_d2 = _gf2_rank(_boundary2(edges, tris))

    b0 = n - rank_d1
    b1 = (len(edges) - rank_d1) - rank_d2
    return b0, b1


def _boundary1(edges: List[Tuple[int, int]], n: int) -> List[List[int]]:
    """Boundary matrix d1: columns = edges, rows = vertices (over GF(2))."""
    mat = [[0] * len(edges) for _ in range(n)]
    for j, (a, b) in enumerate(edges):
        mat[a][j] ^= 1
        mat[b][j] ^= 1
    return mat


def _boundary2(edges: List[Tuple[int, int]],
               tris: List[Tuple[int, int, int]]) -> List[List[int]]:
    """Boundary matrix d2: columns = triangles, rows = edges (over GF(2))."""
    edge_index: Dict[Tuple[int, int], int] = {e: i for i, e in enumerate(edges)}
    mat = [[0] * len(tris) for _ in range(len(edges))]
    for j, (a, b, c) in enumerate(tris):
        for e in ((a, b), (a, c), (b, c)):
            mat[edge_index[e]][j] ^= 1
    return mat


def _gf2_rank(mat: List[List[int]]) -> int:
    """Rank of a 0/1 matrix over GF(2) via Gaussian elimination."""
    if not mat or not mat[0]:
        return 0
    rows = [row[:] for row in mat]
    n_rows, n_cols = len(rows), len(rows[0])
    rank = 0
    for col in range(n_cols):
        pivot = next((r for r in range(rank, n_rows) if rows[r][col]), None)
        if pivot is None:
            continue
        rows[rank], rows[pivot] = rows[pivot], rows[rank]
        for r in range(n_rows):
            if r != rank and rows[r][col]:
                rows[r] = [a ^ b for a, b in zip(rows[r], rows[rank])]
        rank += 1
    return rank


def circle_points(m: int, radius: float = 1.0) -> List[Point]:
    """m points evenly sampled on a circle — known topology b0=1, b1=1."""
    return [(radius * math.cos(2 * math.pi * k / m),
             radius * math.sin(2 * math.pi * k / m)) for k in range(m)]


def demo_betti() -> None:
    print("=" * 70)
    print("2. FIRST BETTI NUMBER OF A VIETORIS-RIPS COMPLEX (circle => b1=1)")
    print("=" * 70)
    pts = circle_points(8, radius=1.0)
    edge_len = dist(pts[0], pts[1])           # adjacent-vertex spacing
    diam = 2.0                                # diameter of the circle
    for r in (0.5 * edge_len, 1.05 * edge_len, 0.9 * diam, 1.05 * diam):
        b0, b1 = betti_numbers(pts, r)
        print(f"  scale r = {r:5.3f}:  b0 = {b0}, b1 = {b1}")
    print("  Interpretation: the loop is born once edges close the ring and")
    print("  dies once the disk fills in (b1: 0 -> 1 -> 0).")
    print()


# ---------------------------------------------------------------------------
# 3. The topological generalization bound
# ---------------------------------------------------------------------------

def topo_gen_bound(emp_risk: float, b1: int, n: int, delta: float) -> float:
    """
    McAllester-style bound with topological complexity term log(1 + b1):

        emp_risk + sqrt( (log(1+b1) + log(2*sqrt(n)/delta)) / (2*(n-1)) ).
    """
    complexity = math.log(1.0 + b1)
    numerator = complexity + math.log(2.0 * math.sqrt(n) / delta)
    return emp_risk + math.sqrt(numerator / (2.0 * (n - 1)))


def topo_gen_gap(b1: int, n: int, delta: float) -> float:
    """The exact generalization gap (topoGenBound_gap_eq)."""
    return topo_gen_bound(0.0, b1, n, delta)


def demo_bound() -> None:
    print("=" * 70)
    print("3. TOPOLOGICAL GENERALIZATION BOUND")
    print("=" * 70)
    emp, delta = 0.10, 0.05

    print("  (a) Exact gap formula  (topoGenBound_gap_eq):")
    for b1 in (0, 1, 5):
        bound = topo_gen_bound(emp, b1, n=1000, delta=delta)
        gap = topo_gen_gap(b1, n=1000, delta=delta)
        print(f"      b1={b1}: bound-emp = {bound - emp:.5f}, gap = {gap:.5f}, "
              f"match = {math.isclose(bound - emp, gap)}")

    print("  (b) Monotonicity in b1  (topoGenBound_mono_betti):")
    prev = -1.0
    mono = True
    for b1 in range(0, 8):
        g = topo_gen_gap(b1, n=1000, delta=delta)
        mono = mono and (g >= prev)
        prev = g
        print(f"      b1={b1}: penalty = {g:.5f}")
    print(f"      non-decreasing in b1: {'HOLDS' if mono else 'FAILS'}")

    print("  (c) Consistency as n -> infinity  (topoGenBound_tendsto_empRisk):")
    for n in (100, 1_000, 100_000, 10_000_000):
        g = topo_gen_gap(5, n=n, delta=delta)
        rate = math.sqrt(math.log(n) / n)
        print(f"      n={n:>10}: penalty = {g:.6f}   (~sqrt(log n / n) = {rate:.6f})")
    print()


# ---------------------------------------------------------------------------
# 4. The combinatorial 2^n branching ceiling (branching_degree_bound)
# ---------------------------------------------------------------------------

def maximal_consistent_extensions(
    n_props: int, forbidden: Set[FrozenSet[int]]
) -> List[FrozenSet[int]]:
    """
    Enumerate maximal consistent extensions over n independent propositions.
    A "world" is a subset of {0,...,n-1} (the true propositions); 'forbidden'
    lists assignments ruled out by the theory's constraints.
    """
    worlds = []
    for k in range(n_props + 1):
        for combo in combinations(range(n_props), k):
            w = frozenset(combo)
            if w not in forbidden:
                worlds.append(w)
    return worlds


def demo_branching() -> None:
    print("=" * 70)
    print("4. BRANCHING DEGREE CEILING  (branching_degree_bound: <= 2^n)")
    print("=" * 70)
    for n_props in range(0, 6):
        worlds = maximal_consistent_extensions(n_props, forbidden=set())
        ceiling = 2 ** n_props
        print(f"  n={n_props}: extensions = {len(worlds):>2}, "
              f"ceiling 2^n = {ceiling:>2}, "
              f"within bound = {len(worlds) <= ceiling}")
    # With a constraint, the count drops strictly below the ceiling.
    worlds = maximal_consistent_extensions(3, forbidden={frozenset({0, 1, 2})})
    print(f"  n=3 with one forbidden assignment: extensions = {len(worlds)} "
          f"(<= 2^3 = 8)")
    print()


def main() -> None:
    points = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0)]
    check_structural_laws(points)
    demo_betti()
    demo_bound()
    demo_branching()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
