#!/usr/bin/env python3
"""Numerical demonstrations of finite H0 Vietoris--Rips stability.

The script uses only the Python standard library. It computes uniform distortion,
Rips connected-component counts, tree-encoded H0 diagrams, and matching costs.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import permutations
from math import inf
from typing import Iterable, Sequence

Matrix = list[list[float]]
Point = tuple[float, float]


@dataclass(frozen=True)
class StabilityReport:
    distortion: float
    radius_shift: float
    identity_matching_cost: float
    finite_bottleneck: float


def validate_square(matrix: Sequence[Sequence[float]]) -> None:
    """Raise ValueError unless matrix is nonempty and square."""
    n = len(matrix)
    if n == 0 or any(len(row) != n for row in matrix):
        raise ValueError("distance tables must be nonempty and square")


def uniform_distortion(d: Sequence[Sequence[float]], e: Sequence[Sequence[float]]) -> float:
    """Return max_ij |d_ij-e_ij| for common-label distance tables."""
    validate_square(d)
    validate_square(e)
    if len(d) != len(e):
        raise ValueError("distance tables must have the same size")
    return max(abs(d[i][j] - e[i][j]) for i in range(len(d)) for j in range(len(d)))


def rips_edges(d: Sequence[Sequence[float]], radius: float) -> set[tuple[int, int]]:
    """Return unordered Rips edges satisfying d_ij <= 2*radius."""
    validate_square(d)
    return {
        (i, j)
        for i in range(len(d))
        for j in range(i + 1, len(d))
        if d[i][j] <= 2.0 * radius
    }


def component_count(d: Sequence[Sequence[float]], radius: float) -> int:
    """Count connected components in the radius-parametrized Rips graph."""
    validate_square(d)
    parent = list(range(len(d)))
    rank = [0] * len(d)

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> None:
        x_root, y_root = find(x), find(y)
        if x_root == y_root:
            return
        if rank[x_root] < rank[y_root]:
            x_root, y_root = y_root, x_root
        parent[y_root] = x_root
        if rank[x_root] == rank[y_root]:
            rank[x_root] += 1

    for i, j in rips_edges(d, radius):
        union(i, j)
    return len({find(i) for i in range(len(d))})


def tree_h0_diagram(weights: Iterable[float]) -> list[Point]:
    """Map each certified edge weight w to its H0 point (0,w/2)."""
    return [(0.0, float(weight) / 2.0) for weight in weights]


def point_distance(p: Point, q: Point) -> float:
    """L-infinity distance between birth--death points."""
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


def matching_cost(d: Sequence[Point], e: Sequence[Point], permutation: Sequence[int]) -> float:
    """Return the largest cost under a specified bijective matching."""
    if len(d) != len(e) or len(permutation) != len(d):
        raise ValueError("matching dimensions disagree")
    if sorted(permutation) != list(range(len(d))):
        raise ValueError("permutation must be a bijection")
    return max((point_distance(d[i], e[permutation[i]]) for i in range(len(d))), default=0.0)


def exact_finite_bottleneck(d: Sequence[Point], e: Sequence[Point]) -> float:
    """Compute equal-cardinality bottleneck distance by exhaustive matching.

    This reference implementation costs O(m! * m), so it is intended for small
    examples. Polynomial bipartite matching should be used for large diagrams.
    """
    if len(d) != len(e):
        raise ValueError("finite diagrams must have equal cardinality")
    if not d:
        return 0.0
    return min(matching_cost(d, e, permutation) for permutation in permutations(range(len(d))))


def two_point_distance(separation: float) -> Matrix:
    """Return the distance table for two points separated by the given value."""
    return [[0.0, separation], [separation, 0.0]]


def tree_stability_report(weights: Sequence[float], perturbed: Sequence[float]) -> StabilityReport:
    """Calculate the identity certificate and exact small-diagram bottleneck."""
    if len(weights) != len(perturbed) or not weights:
        raise ValueError("weight arrays must be nonempty and equally sized")
    distortion = max(abs(a - b) for a, b in zip(weights, perturbed))
    d = tree_h0_diagram(weights)
    e = tree_h0_diagram(perturbed)
    identity = matching_cost(d, e, list(range(len(d))))
    return StabilityReport(distortion, distortion / 2.0, identity, exact_finite_bottleneck(d, e))


def demonstrate_two_point_sharpness() -> None:
    """Show equality for separations 2 and 3."""
    d, e = two_point_distance(2.0), two_point_distance(3.0)
    delta = uniform_distortion(d, e)
    report = tree_stability_report([2.0], [3.0])
    print("Two-point sharpness example")
    print(f"  distortion: {delta:.3f}")
    print(f"  certified shift delta/2: {delta / 2.0:.3f}")
    print(f"  diagrams: {tree_h0_diagram([2.0])} and {tree_h0_diagram([3.0])}")
    print(f"  exact finite bottleneck: {report.finite_bottleneck:.3f}")
    assert delta == 1.0 and report.finite_bottleneck == 0.5


def demonstrate_interleaving() -> None:
    """Check both component-count inequalities across sample radii."""
    d = [[0.0, 2.0, 4.0], [2.0, 0.0, 3.0], [4.0, 3.0, 0.0]]
    e = [[0.0, 2.4, 3.6], [2.4, 0.0, 3.2], [3.6, 3.2, 0.0]]
    delta = uniform_distortion(d, e)
    shift = delta / 2.0
    print("\nThree-point Rips interleaving")
    print(f"  distortion: {delta:.3f}; radius shift: {shift:.3f}")
    for radius in (0.0, 0.8, 1.0, 1.3, 1.5, 2.0):
        bd = component_count(d, radius)
        be_shift = component_count(e, radius + shift)
        be = component_count(e, radius)
        bd_shift = component_count(d, radius + shift)
        print(f"  r={radius:>3.1f}: beta0(d,r)={bd}, beta0(e,r+shift)={be_shift}; "
              f"beta0(e,r)={be}, beta0(d,r+shift)={bd_shift}")
        assert be_shift <= bd and bd_shift <= be


def demonstrate_tree_matching() -> None:
    """Compare identity certificate with exact bottleneck for three edges."""
    weights = [1.2, 2.8, 5.0]
    perturbed = [1.5, 2.4, 5.6]
    report = tree_stability_report(weights, perturbed)
    print("\nCertified tree-diagram stability")
    print(f"  original diagram:  {tree_h0_diagram(weights)}")
    print(f"  perturbed diagram: {tree_h0_diagram(perturbed)}")
    print(f"  max edge perturbation: {report.distortion:.3f}")
    print(f"  theorem bound: {report.radius_shift:.3f}")
    print(f"  identity matching cost: {report.identity_matching_cost:.3f}")
    print(f"  exact finite bottleneck: {report.finite_bottleneck:.3f}")
    assert report.identity_matching_cost <= report.radius_shift + 1e-12
    assert report.finite_bottleneck <= report.identity_matching_cost + 1e-12


def main() -> None:
    demonstrate_two_point_sharpness()
    demonstrate_interleaving()
    demonstrate_tree_matching()


if __name__ == "__main__":
    main()
