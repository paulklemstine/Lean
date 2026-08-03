#!/usr/bin/env python3
"""Exact numerical demonstrations for normalized mixed area of degree triangles.

The standard lattice triangle dilated by degree d has normalized area d^2.
For degrees d and e, this script compares the raw area polarization with the
corrected mixed area and the plane Bezout product.
"""

from dataclasses import dataclass
from typing import Iterable


@dataclass(frozen=True)
class MixedAreaAudit:
    """Exact quantities associated with a pair of nonnegative degrees."""

    degree_d: int
    degree_e: int
    area_d: int
    area_e: int
    area_sum: int
    raw_polarization: int
    corrected_mixed_area: int
    bezout_product: int


def _require_nonnegative(*values: int) -> None:
    """Raise ValueError unless every supplied integer is nonnegative."""
    if any(value < 0 for value in values):
        raise ValueError("degrees must be nonnegative integers")


def normalized_triangle_area(degree: int) -> int:
    """Return normalized lattice area of the standard degree triangle."""
    _require_nonnegative(degree)
    return degree * degree


def raw_mixed_area_difference(degree_d: int, degree_e: int) -> int:
    """Return A((d+e)Delta) - A(dDelta) - A(eDelta)."""
    _require_nonnegative(degree_d, degree_e)
    return (
        normalized_triangle_area(degree_d + degree_e)
        - normalized_triangle_area(degree_d)
        - normalized_triangle_area(degree_e)
    )


def corrected_mixed_area(degree_d: int, degree_e: int) -> int:
    """Return half the raw normalized-area polarization, exactly."""
    raw = raw_mixed_area_difference(degree_d, degree_e)
    if raw % 2 != 0:
        raise ArithmeticError("normalized polarization unexpectedly has odd parity")
    return raw // 2


def audit_degrees(degree_d: int, degree_e: int) -> MixedAreaAudit:
    """Compute every quantity needed to audit the normalization convention."""
    _require_nonnegative(degree_d, degree_e)
    area_d = normalized_triangle_area(degree_d)
    area_e = normalized_triangle_area(degree_e)
    area_sum = normalized_triangle_area(degree_d + degree_e)
    raw = area_sum - area_d - area_e
    corrected = raw // 2
    bezout = degree_d * degree_e
    assert raw == 2 * bezout
    assert corrected == bezout
    return MixedAreaAudit(
        degree_d=degree_d,
        degree_e=degree_e,
        area_d=area_d,
        area_e=area_e,
        area_sum=area_sum,
        raw_polarization=raw,
        corrected_mixed_area=corrected,
        bezout_product=bezout,
    )


def verify_symmetry_and_additivity(a: int, b: int, e: int) -> None:
    """Check symmetry and additivity of raw and corrected polarizations."""
    _require_nonnegative(a, b, e)
    assert raw_mixed_area_difference(a, e) == raw_mixed_area_difference(e, a)
    assert corrected_mixed_area(a, e) == corrected_mixed_area(e, a)
    assert raw_mixed_area_difference(a + b, e) == (
        raw_mixed_area_difference(a, e) + raw_mixed_area_difference(b, e)
    )
    assert corrected_mixed_area(a + b, e) == (
        corrected_mixed_area(a, e) + corrected_mixed_area(b, e)
    )


def print_table(pairs: Iterable[tuple[int, int]]) -> None:
    """Print a compact comparison table for the supplied degree pairs."""
    header = (
        " d   e | A(dΔ) A(eΔ) A((d+e)Δ) | raw | corrected | d·e | raw=d·e?"
    )
    print(header)
    print("-" * len(header))
    for degree_d, degree_e in pairs:
        row = audit_degrees(degree_d, degree_e)
        print(
            f"{row.degree_d:2d}  {row.degree_e:2d} |"
            f" {row.area_d:5d} {row.area_e:5d} {row.area_sum:10d} |"
            f" {row.raw_polarization:3d} | {row.corrected_mixed_area:9d} |"
            f" {row.bezout_product:3d} |"
            f" {str(row.raw_polarization == row.bezout_product):>8s}"
        )


def main() -> None:
    """Run exact examples, including the decisive two-line case."""
    examples = [(0, 5), (1, 1), (1, 4), (2, 3), (5, 7), (12, 9)]
    print("Normalized mixed-area audit for standard Newton triangles\n")
    print_table(examples)

    line_case = audit_degrees(1, 1)
    print("\nTwo tropical lines:")
    print(
        "  raw normalized-area difference = "
        f"{line_case.raw_polarization}, while the corrected count = "
        f"{line_case.corrected_mixed_area}."
    )

    for a, b, e in [(1, 2, 3), (4, 5, 2), (0, 7, 6)]:
        verify_symmetry_and_additivity(a, b, e)
    print("\nSymmetry and additivity checks passed exactly.")


if __name__ == "__main__":
    main()
