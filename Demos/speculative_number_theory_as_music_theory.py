#!/usr/bin/env python3
"""Numerical demonstrations for finite reciprocal-zero harmonics.

Only the Python standard library is required. Approximate zeta-zero ordinates are
used as sample data, not as a certificate that the list is complete.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import isclose
from typing import Iterable, Sequence


@dataclass(frozen=True)
class HarmonicReport:
    """Diagnostics for a finite nonzero complex spectral window."""

    count: int
    harmonic: complex
    minimum_modulus: float | None
    triangle_bound: float
    conjugation_closed: bool


def reciprocal_harmonic(points: Iterable[complex]) -> complex:
    """Return the sum of reciprocal points, rejecting zero."""
    total = 0j
    for point in points:
        if point == 0:
            raise ValueError("The reciprocal harmonic is undefined at zero.")
        total += 1 / point
    return total


def cutoff_window(points: Iterable[complex], cutoff: float) -> list[complex]:
    """Select points whose imaginary parts have absolute value at most cutoff."""
    if cutoff < 0:
        raise ValueError("The cutoff must be nonnegative.")
    return [point for point in points if abs(point.imag) <= cutoff]


def is_conjugation_closed(points: Sequence[complex], tolerance: float = 1e-12) -> bool:
    """Check conjugation closure of a finite numerical list, including multiplicity."""
    unused = list(points)
    while unused:
        point = unused.pop()
        target = point.conjugate()
        for index, candidate in enumerate(unused):
            if abs(candidate - target) <= tolerance:
                unused.pop(index)
                break
        else:
            if abs(point - target) > tolerance:
                return False
    return True


def analyze_window(points: Sequence[complex]) -> HarmonicReport:
    """Compute the harmonic, sharp data-derived bound, and symmetry diagnostic."""
    if any(point == 0 for point in points):
        raise ValueError("All spectral points must be nonzero.")
    harmonic = reciprocal_harmonic(points)
    if not points:
        return HarmonicReport(0, harmonic, None, 0.0, True)
    delta = min(abs(point) for point in points)
    return HarmonicReport(
        count=len(points),
        harmonic=harmonic,
        minimum_modulus=delta,
        triangle_bound=len(points) / delta,
        conjugation_closed=is_conjugation_closed(points),
    )


def quadratic_harmonic(linear_coefficient: Fraction, quadratic_coefficient: Fraction) -> Fraction:
    """Return l/q for the factor 1 - l*u + q*u^2, exactly."""
    if quadratic_coefficient == 0:
        raise ValueError("The quadratic coefficient q must be nonzero.")
    return linear_coefficient / quadratic_coefficient


def print_report(title: str, report: HarmonicReport) -> None:
    """Print a readable diagnostic report."""
    print(f"\n{title}")
    print("-" * len(title))
    print(f"point count:          {report.count}")
    print(f"harmonic:             {report.harmonic}")
    print(f"minimum modulus:      {report.minimum_modulus}")
    print(f"cardinality bound:    {report.triangle_bound}")
    print(f"conjugation-closed:   {report.conjugation_closed}")
    assert abs(report.harmonic) <= report.triangle_bound + 1e-12
    if report.conjugation_closed:
        assert isclose(report.harmonic.imag, 0.0, abs_tol=1e-12)


def demonstrate_empty_small_cutoffs() -> None:
    """Show that supplied zeta samples select empty windows at cutoffs 2 and 3."""
    ordinates = [14.134725141734693, 21.022039638771556, 25.01085758014569]
    samples = [0.5 + ordinate * 1j for ordinate in ordinates]
    samples += [point.conjugate() for point in samples]
    for cutoff in (2.0, 3.0):
        selected = cutoff_window(samples, cutoff)
        report = analyze_window(selected)
        print_report(f"Sample-data window at cutoff {cutoff:g}", report)
        assert report.harmonic == 0j
    print("These finite-data calculations illustrate emptiness; they do not certify list completeness.")


def demonstrate_conjugate_reality() -> None:
    """Show exact cancellation of imaginary parts for a conjugate-symmetric window."""
    points = [1 + 2j, 1 - 2j, 3 + 0j]
    report = analyze_window(points)
    print_report("Conjugation-symmetric window", report)
    assert isclose(report.harmonic.real, 11 / 15, rel_tol=1e-12)


def demonstrate_quadratic_identity() -> None:
    """Compare direct root summation with the exact Vieta coefficient ratio."""
    alpha, beta = 2 + 0j, 3 + 0j
    direct = reciprocal_harmonic([alpha, beta])
    exact = quadratic_harmonic(Fraction(5), Fraction(6))
    print("\nQuadratic reciprocal-harmonic identity")
    print("--------------------------------------")
    print(f"roots:                {alpha}, {beta}")
    print(f"direct reciprocal sum: {direct}")
    print(f"exact coefficient l/q: {exact}")
    assert isclose(direct.real, float(exact), rel_tol=1e-12)
    assert isclose(direct.imag, 0.0, abs_tol=1e-12)


def main() -> None:
    demonstrate_empty_small_cutoffs()
    demonstrate_conjugate_reality()
    demonstrate_quadratic_identity()


if __name__ == "__main__":
    main()
