#!/usr/bin/env python3
"""Numerical demonstrations of coordinate slicing for positive boxes.

For widths a_i, full volume is prod(a_i), while the coordinate section
perpendicular to i has volume prod(a_j for j != i).  The script checks the
identity S_i * a_i = V, normalizes examples to unit volume, and locates the
largest coordinate section using both direct and logarithmic calculations.
Only the Python standard library is required.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import exp, fsum, isclose, log, prod
from typing import Iterable, Sequence


@dataclass(frozen=True)
class BoxReport:
    """Computed geometric data for one positive axis-aligned box."""

    widths: tuple[float, ...]
    volume: float
    sections: tuple[float, ...]
    best_axis: int
    best_section: float
    log_volume: float


def validate_widths(widths: Sequence[float]) -> tuple[float, ...]:
    """Return widths as an immutable tuple after validating positivity."""
    values = tuple(float(x) for x in widths)
    if not values:
        raise ValueError("A box must have positive dimension.")
    if any(x <= 0.0 for x in values):
        raise ValueError("Every side length must be strictly positive.")
    return values


def normalize_to_unit_volume(widths: Sequence[float]) -> tuple[float, ...]:
    """Scale every width by a common factor so their product is one.

    Logarithms are used to avoid forming an unstable product during scaling.
    """
    values = validate_widths(widths)
    mean_log = fsum(log(x) for x in values) / len(values)
    scale = exp(-mean_log)
    return tuple(scale * x for x in values)


def coordinate_sections(widths: Sequence[float]) -> tuple[float, ...]:
    """Compute every complementary coordinate-section volume directly."""
    values = validate_widths(widths)
    return tuple(prod(values[j] for j in range(len(values)) if j != i)
                 for i in range(len(values)))


def analyze_box(widths: Sequence[float]) -> BoxReport:
    """Compute volume, sections, and the largest-section direction."""
    values = validate_widths(widths)
    volume = prod(values)
    sections = coordinate_sections(values)
    best_axis = min(range(len(values)), key=values.__getitem__)
    return BoxReport(
        widths=values,
        volume=volume,
        sections=sections,
        best_axis=best_axis,
        best_section=sections[best_axis],
        log_volume=fsum(log(x) for x in values),
    )


def stable_log_sections(widths: Sequence[float]) -> tuple[float, ...]:
    """Return logarithms of all section volumes without large products."""
    values = validate_widths(widths)
    log_volume = fsum(log(x) for x in values)
    return tuple(log_volume - log(x) for x in values)


def verify_identities(report: BoxReport, tolerance: float = 1e-10) -> None:
    """Raise AssertionError unless all section-width identities hold."""
    for width, section in zip(report.widths, report.sections):
        assert isclose(section * width, report.volume,
                       rel_tol=tolerance, abs_tol=tolerance)


def print_report(name: str, raw_widths: Iterable[float]) -> None:
    """Normalize an example, verify it, and print a readable table."""
    unit_widths = normalize_to_unit_volume(tuple(raw_widths))
    report = analyze_box(unit_widths)
    verify_identities(report)
    log_sections = stable_log_sections(unit_widths)

    print(f"\n{name}")
    print("=" * len(name))
    print(f"dimension: {len(report.widths)}")
    print(f"unit-normalized widths: {[round(x, 8) for x in report.widths]}")
    print(f"volume: {report.volume:.12g}")
    print("axis | width          | section volume | log(section)")
    print("-----+----------------+----------------+-------------")
    for i, (width, section, log_section) in enumerate(
        zip(report.widths, report.sections, log_sections), start=1
    ):
        marker = "  <-- selected" if i - 1 == report.best_axis else ""
        print(f"{i:4d} | {width:14.7g} | {section:14.7g} | "
              f"{log_section:11.5g}{marker}")

    assert report.best_section >= 1.0 - 1e-10
    print(f"Largest coordinate section: {report.best_section:.12g} "
          f"(perpendicular to axis {report.best_axis + 1})")
    print("Guaranteed lower bound 1 attained or exceeded: yes")


def main() -> None:
    """Run balanced, anisotropic, and higher-dimensional examples."""
    examples: tuple[tuple[str, tuple[float, ...]], ...] = (
        ("Balanced three-dimensional box", (2.0, 0.5, 1.0)),
        ("Strongly anisotropic four-dimensional box", (10.0, 10.0, 10.0, 0.001)),
        ("Several qualifying coordinate sections", (4.0, 0.5, 0.5, 1.0)),
        ("Non-normalized input rescaled automatically", (3.0, 7.0, 2.0, 5.0, 0.25)),
    )
    print("Coordinate slicing of unit-volume boxes")
    print("For every axis i: section_i * width_i = full volume.")
    for name, widths in examples:
        print_report(name, widths)


if __name__ == "__main__":
    main()
