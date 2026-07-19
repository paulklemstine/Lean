#!/usr/bin/env python3
"""Exact finite demonstrations inspired by the topology of surreal numbers.

The full surreal line is not a finite numerical object.  These examples use
Fractions to demonstrate three proof patterns exactly:
(1) diagonalizing below a finite positive family,
(2) defeating a finite proposal of neighborhoods of zero, and
(3) escaping every finite selection from an unbounded lower-ray cover.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Iterable, Sequence


@dataclass(frozen=True)
class DiagonalCertificate:
    """A positive number certified to lie below every listed positive value."""

    inputs: tuple[Fraction, ...]
    bound: Fraction

    def verify(self) -> bool:
        return self.bound > 0 and all(self.bound < value for value in self.inputs)


@dataclass(frozen=True)
class NeighborhoodCertificate:
    """Witnesses that no listed symmetric neighborhood fits in (-infinity, d)."""

    radii: tuple[Fraction, ...]
    selected_points: tuple[Fraction, ...]
    cutoff: Fraction

    def verify(self) -> bool:
        return (
            len(self.radii) == len(self.selected_points)
            and self.cutoff > 0
            and all(radius > 0 for radius in self.radii)
            and all(
                0 < point < radius and point > self.cutoff
                for radius, point in zip(self.radii, self.selected_points)
            )
        )


@dataclass(frozen=True)
class CoverEscapeCertificate:
    """A point lying beyond every endpoint of finitely many lower rays."""

    endpoints: tuple[Fraction, ...]
    escape_point: Fraction

    def verify(self) -> bool:
        return bool(self.endpoints) and all(
            self.escape_point >= endpoint for endpoint in self.endpoints
        )


def as_positive_tuple(values: Iterable[Fraction]) -> tuple[Fraction, ...]:
    """Validate and freeze a nonempty family of positive rational values."""

    frozen = tuple(values)
    if not frozen:
        raise ValueError("at least one value is required")
    if any(value <= 0 for value in frozen):
        raise ValueError("all values must be strictly positive")
    return frozen


def finite_diagonal_bound(values: Iterable[Fraction]) -> DiagonalCertificate:
    """Return half the minimum of a finite positive rational family.

    Time complexity is O(n); auxiliary space is O(n) because the iterable is
    frozen for certificate reporting (the minimum itself needs only O(1)).
    """

    frozen = as_positive_tuple(values)
    certificate = DiagonalCertificate(frozen, min(frozen) / 2)
    assert certificate.verify()
    return certificate


def stress_test_neighborhoods(
    radii: Iterable[Fraction],
) -> NeighborhoodCertificate:
    """Defeat finitely many symmetric neighborhoods (-r_i, r_i).

    Select u_i = r_i/2 in each neighborhood, then choose a positive cutoff d
    below every u_i.  Since u_i > d, no neighborhood is contained in the lower
    ray (-infinity, d).  The computation takes O(n) time.
    """

    frozen = as_positive_tuple(radii)
    selected = tuple(radius / 2 for radius in frozen)
    cutoff = min(selected) / 2
    certificate = NeighborhoodCertificate(frozen, selected, cutoff)
    assert certificate.verify()
    return certificate


def escape_finite_lower_rays(
    endpoints: Sequence[Fraction],
) -> CoverEscapeCertificate:
    """Find a point omitted by every lower ray (-infinity, endpoint).

    The maximum endpoint itself is outside every listed strict lower ray; we
    output one unit beyond it to make the separation visually clear.  Running
    time is O(n) and auxiliary space is O(n) in the reporting certificate.
    """

    frozen = tuple(endpoints)
    if not frozen:
        raise ValueError("at least one endpoint is required")
    certificate = CoverEscapeCertificate(frozen, max(frozen) + 1)
    assert certificate.verify()
    return certificate


def format_fraction(value: Fraction) -> str:
    """Render a rational number without floating-point approximation."""

    return str(value.numerator) if value.denominator == 1 else str(value)


def run_demonstrations() -> None:
    """Run three exact, reproducible demonstrations and print certificates."""

    print("DEMO 1 — Finite diagonal lower bounds")
    families = [
        [Fraction(1, n) for n in range(1, 9)],
        [Fraction(1, 2 ** n) for n in range(1, 11)],
        [Fraction(7, 3), Fraction(2, 101), Fraction(11, 17), Fraction(1, 10_000)],
    ]
    for family in families:
        result = finite_diagonal_bound(family)
        print(
            f"  below {len(result.inputs):2d} values: "
            f"d = {format_fraction(result.bound)}, verified = {result.verify()}"
        )

    print("\nDEMO 2 — A lower ray defeats finite neighborhood proposals")
    radii = [Fraction(1, n * n) for n in range(1, 9)]
    neighborhood = stress_test_neighborhoods(radii)
    print(f"  proposed symmetric neighborhoods: {len(neighborhood.radii)}")
    print(f"  cutoff d = {format_fraction(neighborhood.cutoff)}")
    print(
        "  each neighborhood contains a selected point above d: "
        f"{neighborhood.verify()}"
    )

    print("\nDEMO 3 — Escape from finitely many lower rays")
    endpoint_sets = [
        [Fraction(-2), Fraction(0), Fraction(5, 2)],
        [Fraction(n) for n in range(12)],
        [Fraction(10 ** n) for n in range(6)],
    ]
    for endpoints in endpoint_sets:
        escape = escape_finite_lower_rays(endpoints)
        print(
            f"  {len(endpoints):2d} endpoints, escape point = "
            f"{format_fraction(escape.escape_point)}, verified = {escape.verify()}"
        )

    print(
        "\nInterpretation: these exact rational calculations model finite proof "
        "patterns. They do not numerically construct the full surreal number line."
    )


if __name__ == "__main__":
    run_demonstrations()
