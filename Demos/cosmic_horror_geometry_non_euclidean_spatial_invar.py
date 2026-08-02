#!/usr/bin/env python3
"""Numerical demonstrations of angular defect and hyperbolic triangle area.

All angles are in radians. The governing relation for curvature -kappa is
    area = (pi - (alpha + beta + gamma)) / kappa.
Only Python's standard library is required.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import isclose, pi
from typing import Iterable, Sequence


@dataclass(frozen=True)
class TriangleReport:
    """Computed invariants and classification for one angle triple."""

    kappa: float
    angles: tuple[float, float, float]
    angle_sum: float
    defect: float
    area: float
    maximum_area: float
    admissible: bool
    classification: str


def hyperbolic_area(kappa: float, alpha: float, beta: float, gamma: float) -> float:
    """Return Gauss--Bonnet area for constant curvature ``-kappa``."""
    if kappa <= 0.0:
        raise ValueError("kappa must be positive")
    return (pi - (alpha + beta + gamma)) / kappa


def analyze_triangle(
    kappa: float,
    alpha: float,
    beta: float,
    gamma: float,
    *,
    tolerance: float = 1e-12,
) -> TriangleReport:
    """Validate, evaluate, and classify an angle triple."""
    if kappa <= 0.0:
        raise ValueError("kappa must be positive")
    if tolerance < 0.0:
        raise ValueError("tolerance must be nonnegative")

    angles = (alpha, beta, gamma)
    angle_sum = sum(angles)
    defect = pi - angle_sum
    area = defect / kappa
    maximum = pi / kappa
    nonnegative = all(angle >= -tolerance for angle in angles)
    admissible = nonnegative and angle_sum <= pi + tolerance

    if not nonnegative:
        classification = "outside the nonnegative interior-angle domain"
    elif angle_sum > pi + tolerance:
        classification = "inadmissible: angle sum exceeds pi"
    elif isclose(angle_sum, 0.0, abs_tol=tolerance):
        classification = "ideal and maximal: all nonnegative angles vanish"
    elif isclose(angle_sum, pi, abs_tol=tolerance):
        classification = "zero-area boundary: Euclidean angle sum"
    else:
        classification = "positive, submaximal hyperbolic area"

    return TriangleReport(
        kappa=kappa,
        angles=angles,
        angle_sum=angle_sum,
        defect=defect,
        area=area,
        maximum_area=maximum,
        admissible=admissible,
        classification=classification,
    )


def area_profile(kappa: float, sums: Iterable[float]) -> list[tuple[float, float]]:
    """Return ``(total angle, area)`` pairs for prescribed angle sums."""
    return [(total, hyperbolic_area(kappa, total, 0.0, 0.0)) for total in sums]


def verify_identities(tolerance: float = 1e-12) -> None:
    """Numerically check maximality, completeness, difference, and scaling."""
    kappa = 2.5
    first = (pi / 6.0, pi / 8.0, pi / 12.0)
    second = (pi / 4.0, pi / 12.0, pi / 24.0)
    area_first = hyperbolic_area(kappa, *first)
    area_second = hyperbolic_area(kappa, *second)
    difference_formula = (sum(second) - sum(first)) / kappa
    assert isclose(area_first - area_second, difference_formula, abs_tol=tolerance)

    same_sum_a = (pi / 2.0, 0.0, 0.0)
    same_sum_b = (pi / 6.0, pi / 6.0, pi / 6.0)
    assert isclose(
        hyperbolic_area(kappa, *same_sum_a),
        hyperbolic_area(kappa, *same_sum_b),
        abs_tol=tolerance,
    )

    ideal_area = hyperbolic_area(kappa, 0.0, 0.0, 0.0)
    assert isclose(ideal_area, pi / kappa, abs_tol=tolerance)
    assert hyperbolic_area(kappa, 0.1, 0.0, 0.0) < ideal_area

    scale = 4.0
    assert isclose(
        hyperbolic_area(scale * kappa, *first),
        area_first / scale,
        abs_tol=tolerance,
    )


def print_report(report: TriangleReport) -> None:
    """Print one compact human-readable report."""
    a, b, c = report.angles
    print(f"angles = ({a:.6f}, {b:.6f}, {c:.6f}) radians")
    print(f"sum = {report.angle_sum:.6f}, defect = {report.defect:.6f}")
    print(f"area = {report.area:.6f}, maximum = {report.maximum_area:.6f}")
    print(f"admissible = {report.admissible}; {report.classification}\n")


def main() -> None:
    """Run exact-pattern examples and a degeneration toward ideal area."""
    print("HYPERBOLIC TRIANGLE AREA DEMONSTRATION\n")
    examples: Sequence[tuple[str, TriangleReport]] = (
        ("Standard ideal triangle", analyze_triangle(1.0, 0.0, 0.0, 0.0)),
        ("Half-defect sample", analyze_triangle(1.0, pi / 2.0, 0.0, 0.0)),
        ("Same sum, redistributed", analyze_triangle(1.0, pi / 6.0, pi / 6.0, pi / 6.0)),
        ("Euclidean-sum boundary", analyze_triangle(1.0, pi / 3.0, pi / 3.0, pi / 3.0)),
        ("Ideal triangle at curvature -4", analyze_triangle(4.0, 0.0, 0.0, 0.0)),
    )
    for title, report in examples:
        print(title)
        print("-" * len(title))
        print_report(report)

    print("Approach to the ideal triangle at curvature -1")
    print("total angle      area           gap from pi")
    for total, area in area_profile(1.0, [pi / 2, pi / 4, pi / 8, pi / 16, 0.0]):
        print(f"{total:11.8f}  {area:11.8f}  {pi - area:11.8f}")

    verify_identities()
    print("\nAll numerical identity checks passed.")


if __name__ == "__main__":
    main()
