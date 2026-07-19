#!/usr/bin/env python3
"""Numerical demonstrations for metric stability and Rips thresholds.

The script uses only the Python standard library. It demonstrates:
1. the exact diameter/full-simplex threshold;
2. the 2δ interleaving for matched perturbations;
3. sphere sampling, greedy packing-covers, and spacing-versus-coverage scales.
"""

from __future__ import annotations

from itertools import combinations
from math import cos, dist, log, pi, sin, sqrt
from random import Random
from typing import Iterable, Sequence

Point = tuple[float, ...]
Edge = tuple[int, int]


def euclidean(a: Point, b: Point) -> float:
    """Return Euclidean distance between equally dimensional points."""
    return dist(a, b)


def pairwise_distances(points: Sequence[Point]) -> list[float]:
    """Return all unordered pairwise distances."""
    return [euclidean(points[i], points[j]) for i, j in combinations(range(len(points)), 2)]


def cloud_diameter(points: Sequence[Point]) -> float:
    """Return the exact full-simplex threshold of a nonempty finite cloud."""
    if not points:
        return 0.0
    return max(pairwise_distances(points), default=0.0)


def rips_edges(points: Sequence[Point], epsilon: float, tol: float = 1e-12) -> set[Edge]:
    """Build the edge set of the Rips graph at scale epsilon."""
    return {
        (i, j)
        for i, j in combinations(range(len(points)), 2)
        if euclidean(points[i], points[j]) <= epsilon + tol
    }


def is_full_simplex(points: Sequence[Point], epsilon: float) -> bool:
    """Test fullness using the equivalent all-pairs distance criterion."""
    n = len(points)
    return len(rips_edges(points, epsilon)) == n * (n - 1) // 2


def edge_count_profile(points: Sequence[Point], scales: Iterable[float]) -> list[tuple[float, int]]:
    """Compute monotone Rips edge counts over the requested scales."""
    return [(epsilon, len(rips_edges(points, epsilon))) for epsilon in scales]


def perturbation_radius(x: Sequence[Point], y: Sequence[Point]) -> float:
    """Return max_i d(x_i,y_i) for matched point clouds."""
    if len(x) != len(y):
        raise ValueError("matched clouds must have the same size")
    return max((euclidean(a, b) for a, b in zip(x, y)), default=0.0)


def verify_two_delta_interleaving(
    x: Sequence[Point], y: Sequence[Point], scales: Iterable[float]
) -> list[tuple[float, bool, bool]]:
    """Check both graph inclusions at every scale after a 2δ shift."""
    delta = perturbation_radius(x, y)
    checks: list[tuple[float, bool, bool]] = []
    for epsilon in scales:
        xy = rips_edges(x, epsilon) <= rips_edges(y, epsilon + 2.0 * delta)
        yx = rips_edges(y, epsilon) <= rips_edges(x, epsilon + 2.0 * delta)
        checks.append((epsilon, xy, yx))
    return checks


def sample_unit_circle(n: int, rng: Random, random_angles: bool = True) -> list[Point]:
    """Sample n points on the unit circle."""
    if random_angles:
        angles = sorted(2.0 * pi * rng.random() for _ in range(n))
    else:
        angles = [2.0 * pi * k / n for k in range(n)]
    return [(cos(theta), sin(theta)) for theta in angles]


def radial_residual(points: Sequence[Point], center: Point, radius: float) -> float:
    """Return max_i |d(x_i,center)-radius|."""
    return max((abs(euclidean(p, center) - radius) for p in points), default=0.0)


def greedy_packing_cover(points: Sequence[Point], epsilon: float) -> list[int]:
    """Construct a maximal epsilon-packing, hence an epsilon-cover of the sample."""
    if epsilon < 0.0:
        raise ValueError("epsilon must be nonnegative")
    centers: list[int] = []
    for i, point in enumerate(points):
        if all(euclidean(point, points[j]) > epsilon for j in centers):
            centers.append(i)
    return centers


def packing_and_cover_checks(
    points: Sequence[Point], centers: Sequence[int], epsilon: float
) -> tuple[bool, bool]:
    """Check pairwise separation and coverage for selected center indices."""
    packing = all(
        euclidean(points[i], points[j]) > epsilon
        for i, j in combinations(centers, 2)
    )
    cover = all(
        any(euclidean(point, points[j]) <= epsilon + 1e-12 for j in centers)
        for point in points
    )
    return packing, cover


def circle_geodesic_coverage_radius(points: Sequence[Point]) -> float:
    """Return half the largest angular gap for points on the unit circle."""
    if not points:
        return pi
    angles = sorted((__import__("math").atan2(y, x) % (2.0 * pi)) for x, y in points)
    gaps = [angles[i + 1] - angles[i] for i in range(len(angles) - 1)]
    gaps.append(angles[0] + 2.0 * pi - angles[-1])
    return 0.5 * max(gaps)


def demo_exact_threshold() -> None:
    """Print the exact two-point and finite-cloud completion transitions."""
    points: list[Point] = [(0.0,), (2.0,)]
    print("\nDEMO 1 — Exact diameter/full-simplex threshold")
    print(f"cloud={points}, diameter={cloud_diameter(points):.3f}")
    for epsilon in (0.0, 1.0, 2.0, 2.5):
        edges = len(rips_edges(points, epsilon))
        print(f"scale={epsilon:>4.1f}: edges={edges}, full={is_full_simplex(points, epsilon)}")
    assert not is_full_simplex(points, 1.0)
    assert is_full_simplex(points, 2.0)


def demo_perturbation() -> None:
    """Print and verify the sharp 2δ matched-noise shift."""
    x: list[Point] = [(0.0,), (1.0,), (2.0,), (3.0,)]
    y: list[Point] = [(-0.15,), (1.10,), (1.90,), (3.15,)]
    delta = perturbation_radius(x, y)
    scales = [0.5, 1.0, 1.5, 2.0]
    print("\nDEMO 2 — Matched perturbation interleaving")
    print(f"maximum matched displacement δ={delta:.3f}; required shift 2δ={2*delta:.3f}")
    for epsilon, xy, yx in verify_two_delta_interleaving(x, y, scales):
        print(f"scale={epsilon:.2f}: X→Y inclusion={xy}, Y→X inclusion={yx}")
        assert xy and yx


def demo_sphere_and_coverage() -> None:
    """Compare spherical completion, maximal packing-covers, and random coverage."""
    rng = Random(20260719)
    points = sample_unit_circle(32, rng, random_angles=True)
    diameter = cloud_diameter(points)
    residual = radial_residual(points, (0.0, 0.0), 1.0)
    epsilon = 0.45
    centers = greedy_packing_cover(points, epsilon)
    packing, cover = packing_and_cover_checks(points, centers, epsilon)
    print("\nDEMO 3 — Sphere bounds and coverage")
    print(f"unit-circle sample size={len(points)}")
    print(f"radial residual={residual:.3e}")
    print(f"sample diameter={diameter:.6f} ≤ spherical bound 2.0")
    print(f"full at diameter={is_full_simplex(points, diameter)}; full at scale 2={is_full_simplex(points, 2.0)}")
    print(f"greedy ε-packing size={len(centers)} at ε={epsilon}; packing={packing}, cover={cover}")
    assert diameter <= 2.0 + 1e-12 and is_full_simplex(points, 2.0)
    assert packing and cover

    print("\nRandom circle coverage: empirical largest-gap radius versus candidate scales")
    print(" n    mean coverage radius    n^-1       log(n)/n")
    for n in (32, 64, 128, 256):
        trials = [circle_geodesic_coverage_radius(sample_unit_circle(n, rng)) for _ in range(100)]
        mean_radius = sum(trials) / len(trials)
        print(f"{n:3d}       {mean_radius:10.6f}      {1/n:8.6f}    {log(n)/n:10.6f}")


def main() -> None:
    demo_exact_threshold()
    demo_perturbation()
    demo_sphere_and_coverage()
    print("\nAll numerical theorem checks passed.")


if __name__ == "__main__":
    main()
