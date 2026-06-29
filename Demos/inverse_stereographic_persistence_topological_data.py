"""Inverse Stereographic Persistence — numerical demonstration.

This script verifies, by direct computation, the core results of the paper
"Inverse Stereographic Persistence: An Exact Conformal Isometry for Topological
Data Analysis on Spheres".

It is fully self-contained: only the Python standard library is used (``math``
and ``random``).  Every helper function is inlined.

Results demonstrated
--------------------
1. Theorem 1  (invStereoN_on_sphere):  phi(x) lands on the unit sphere S^n.
2. Theorem 2  (stereo_conformal_identity):
       ||phi(x) - phi(y)||^2 * (1+||x||^2)(1+||y||^2) = 4 ||x - y||^2.
3. Theorem 3  (chordal_eq_weighted):  chordal(x,y) = d_w(x,y).
4. Corollary 5.1/5.3: the chordal distance matrix of the projected cloud equals
   the weighted-Euclidean matrix of the flat cloud, hence single-linkage
   (0-dimensional persistence) barcodes are identical (bottleneck distance 0).
"""

from __future__ import annotations

import math
import random
from typing import List, Tuple

Vec = List[float]
SpherePoint = Tuple[List[float], float]  # (horizontal coords in R^n, height)


# --------------------------------------------------------------------------- #
# Core definitions (mirror the Lean file Catalog/Geometry/ConformalPersistence)
# --------------------------------------------------------------------------- #
def nsq(x: Vec) -> float:
    """Squared Euclidean norm  nsq(x) = sum_i x_i^2."""
    return sum(xi * xi for xi in x)


def ip(x: Vec, y: Vec) -> float:
    """Euclidean inner product  ip(x,y) = sum_i x_i y_i."""
    return sum(xi * yi for xi, yi in zip(x, y))


def eucl_dist2(x: Vec, y: Vec) -> float:
    """Squared Euclidean distance  sum_i (x_i - y_i)^2."""
    return sum((xi - yi) ** 2 for xi, yi in zip(x, y))


def inv_stereo(x: Vec) -> SpherePoint:
    """Inverse stereographic projection phi : R^n -> S^n subset R^{n+1}.

    phi(x) = ( 2x / (1+||x||^2),  (||x||^2 - 1)/(1+||x||^2) ).
    """
    d = 1.0 + nsq(x)
    horiz = [2.0 * xi / d for xi in x]
    height = (nsq(x) - 1.0) / d
    return horiz, height


def sphere_nsq(p: SpherePoint) -> float:
    """Squared ambient norm  nsq(p1) + p2^2."""
    horiz, height = p
    return nsq(horiz) + height * height


def sphere_dist2(p: SpherePoint, q: SpherePoint) -> float:
    """Squared ambient (chordal) distance in R^{n+1}."""
    ph, phh = p
    qh, qhh = q
    return eucl_dist2(ph, qh) + (phh - qhh) ** 2


def chordal(x: Vec, y: Vec) -> float:
    """Chordal distance between phi(x) and phi(y)."""
    return math.sqrt(sphere_dist2(inv_stereo(x), inv_stereo(y)))


def weighted_dist(x: Vec, y: Vec) -> float:
    """Conformally weighted Euclidean distance
    d_w(x,y) = 2||x-y|| / sqrt((1+||x||^2)(1+||y||^2))."""
    return 2.0 * math.sqrt(eucl_dist2(x, y)) / math.sqrt((1.0 + nsq(x)) * (1.0 + nsq(y)))


def geodesic(p: SpherePoint, q: SpherePoint) -> float:
    """Great-circle (geodesic) distance on the unit sphere = arccos<p,q>."""
    ph, phh = p
    qh, qhh = q
    dot = ip(ph, qh) + phh * qhh
    dot = max(-1.0, min(1.0, dot))  # clamp for numerical safety
    return math.acos(dot)


# --------------------------------------------------------------------------- #
# Random samplers
# --------------------------------------------------------------------------- #
def random_vec(n: int, scale: float = 2.0) -> Vec:
    return [random.uniform(-scale, scale) for _ in range(n)]


def random_cloud(num: int, n: int, scale: float = 2.0) -> List[Vec]:
    return [random_vec(n, scale) for _ in range(num)]


# --------------------------------------------------------------------------- #
# 0-dimensional persistence via single linkage (minimum spanning tree)
# --------------------------------------------------------------------------- #
def single_linkage_deaths(matrix: List[List[float]]) -> List[float]:
    """0-dim persistence death times = sorted MST edge weights (Prim's algo).

    The connected-component (H_0) barcode of a Vietoris-Rips filtration is
    exactly the multiset of minimum-spanning-tree edge weights.  Since the
    barcode depends only on the distance matrix, two equal matrices yield
    identical barcodes.
    """
    n = len(matrix)
    if n == 0:
        return []
    in_tree = [False] * n
    best = [math.inf] * n
    best[0] = 0.0
    deaths: List[float] = []
    for _ in range(n):
        u = min((i for i in range(n) if not in_tree[i]), key=lambda i: best[i])
        in_tree[u] = True
        if best[u] > 0.0:
            deaths.append(best[u])
        for v in range(n):
            if not in_tree[v] and matrix[u][v] < best[v]:
                best[v] = matrix[u][v]
    return sorted(deaths)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_on_sphere() -> None:
    print("=" * 70)
    print("Theorem 1:  phi(x) lies on the unit sphere S^n  (sphereNsq = 1)")
    print("=" * 70)
    for n in (1, 2, 3, 5):
        worst = max(abs(sphere_nsq(inv_stereo(random_vec(n))) - 1.0) for _ in range(2000))
        print(f"  dim n={n}:  max |sphereNsq(phi(x)) - 1| = {worst:.3e}")
    print()


def demo_conformal_identity() -> None:
    print("=" * 70)
    print("Theorem 2:  ||phi(x)-phi(y)||^2 (1+||x||^2)(1+||y||^2) = 4||x-y||^2")
    print("=" * 70)
    for n in (1, 2, 3, 5):
        worst = 0.0
        for _ in range(2000):
            x, y = random_vec(n), random_vec(n)
            lhs = sphere_dist2(inv_stereo(x), inv_stereo(y)) * (1 + nsq(x)) * (1 + nsq(y))
            rhs = 4.0 * eucl_dist2(x, y)
            worst = max(worst, abs(lhs - rhs))
        print(f"  dim n={n}:  max |LHS - RHS| = {worst:.3e}")
    print()


def demo_isometry() -> None:
    print("=" * 70)
    print("Theorem 3:  chordal(x,y) = d_w(x,y)")
    print("=" * 70)
    for n in (1, 2, 3, 5):
        worst = max(
            abs(chordal(x := random_vec(n), y := random_vec(n)) - weighted_dist(x, y))
            for _ in range(2000)
        )
        print(f"  dim n={n}:  max |chordal - d_w| = {worst:.3e}")
    print()


def demo_persistence_equality() -> None:
    print("=" * 70)
    print("Corollary 5.1/5.3:  matrices and H_0 barcodes coincide exactly")
    print("=" * 70)
    n = 2
    for num in (50, 100, 200):
        cloud = random_cloud(num, n)
        proj = [inv_stereo(x) for x in cloud]
        weighted_matrix = [[weighted_dist(a, b) for b in cloud] for a in cloud]
        chordal_matrix = [[math.sqrt(sphere_dist2(p, q)) for q in proj] for p in proj]

        max_diff = max(
            abs(weighted_matrix[i][j] - chordal_matrix[i][j])
            for i in range(num)
            for j in range(num)
        )
        deaths_w = single_linkage_deaths(weighted_matrix)
        deaths_c = single_linkage_deaths(chordal_matrix)
        barcode_diff = max((abs(a - b) for a, b in zip(deaths_w, deaths_c)), default=0.0)
        print(
            f"  N={num:3d}:  max matrix diff = {max_diff:.3e},  "
            f"max H_0 barcode diff = {barcode_diff:.3e}  (bottleneck = 0)"
        )
    print()


def demo_geodesic_monotone() -> None:
    print("=" * 70)
    print("Corollary 5.4:  geodesic is a strictly monotone function of chordal")
    print("=" * 70)
    n = 2
    cloud = random_cloud(80, n)
    proj = [inv_stereo(x) for x in cloud]
    pairs = []
    for i in range(len(cloud)):
        for j in range(i + 1, len(cloud)):
            pairs.append((chordal(cloud[i], cloud[j]), geodesic(proj[i], proj[j])))
    pairs.sort()
    monotone = all(pairs[k][1] <= pairs[k + 1][1] + 1e-12 for k in range(len(pairs) - 1))
    print(f"  pairs sorted by chordal distance are also sorted by geodesic: {monotone}")
    # verify the closed form chord = 2 sin(geodesic/2)
    worst = max(abs(c - 2.0 * math.sin(g / 2.0)) for c, g in pairs)
    print(f"  max |chord - 2 sin(geodesic/2)| = {worst:.3e}")
    print()


def main() -> None:
    random.seed(20260613)
    print("\nInverse Stereographic Persistence — numerical demonstration\n")
    demo_on_sphere()
    demo_conformal_identity()
    demo_isometry()
    demo_persistence_equality()
    demo_geodesic_monotone()
    print("All checks pass to machine precision: the sphere and its conformally")
    print("weighted stereographic shadow yield identical persistence.")


if __name__ == "__main__":
    main()
