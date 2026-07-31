#!/usr/bin/env python3
"""Numerical demonstrations for the inverse stereographic tropical lift.

The program evaluates the basic map and its finite-pole family, checks the
identity on deterministic sample grids, and prints a branch audit showing how
the two maxima change regime together.  It uses only the Python standard
library.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import isclose
from typing import Iterable, Sequence


@dataclass(frozen=True)
class BranchAudit:
    """The two max-plus components and their active affine branches."""

    pole: float
    x: float
    numerator: float
    denominator: float
    value: float
    numerator_branch: str
    denominator_branch: str


def tropical_stereo(x: float) -> float:
    """Evaluate S(x) = max(2x, x) - max(x, 0)."""

    return max(2.0 * x, x) - max(x, 0.0)


def tropical_stereo_at(pole: float, x: float) -> float:
    """Evaluate S_p(x) = max(2x, x+p) - max(x, p)."""

    return max(2.0 * x, x + pole) - max(x, pole)


def audit_branches(pole: float, x: float) -> BranchAudit:
    """Report the active terms in the pole-family expression."""

    first = 2.0 * x
    second = x + pole
    numerator = max(first, second)
    denominator = max(x, pole)
    numerator_branch = "2x" if first >= second else "x+p"
    denominator_branch = "x" if x >= pole else "p"
    return BranchAudit(
        pole=pole,
        x=x,
        numerator=numerator,
        denominator=denominator,
        value=numerator - denominator,
        numerator_branch=numerator_branch,
        denominator_branch=denominator_branch,
    )


def verify_basic_identity(values: Iterable[float], tolerance: float = 1e-12) -> None:
    """Raise AssertionError unless S(x) equals x on every supplied sample."""

    for x in values:
        actual = tropical_stereo(x)
        assert isclose(actual, x, rel_tol=tolerance, abs_tol=tolerance), (x, actual)


def verify_pole_independence(
    poles: Iterable[float], values: Iterable[float], tolerance: float = 1e-12
) -> None:
    """Raise AssertionError unless every sampled finite pole gives the identity."""

    cached_values = tuple(values)
    for pole in poles:
        for x in cached_values:
            actual = tropical_stereo_at(pole, x)
            assert isclose(actual, x, rel_tol=tolerance, abs_tol=tolerance), (
                pole,
                x,
                actual,
            )


def print_sample_table(values: Sequence[float]) -> None:
    """Print the exact-pattern sample table for the basic map."""

    print("Basic map: S(x) = max(2x, x) - max(x, 0)")
    print(f"{'x':>9} {'max(2x,x)':>13} {'max(x,0)':>12} {'S(x)':>9}")
    for x in values:
        numerator = max(2.0 * x, x)
        denominator = max(x, 0.0)
        print(f"{x:9.3f} {numerator:13.3f} {denominator:12.3f} {tropical_stereo(x):9.3f}")


def print_pole_audit(pole: float, values: Sequence[float]) -> None:
    """Print branch choices on both sides of a selected pole."""

    print(f"\nPole audit for p = {pole:g}")
    print(f"{'x':>8} {'num branch':>12} {'den branch':>12} {'numerator':>12} "
          f"{'denominator':>12} {'S_p(x)':>10}")
    for x in values:
        row = audit_branches(pole, x)
        print(
            f"{row.x:8.3f} {row.numerator_branch:>12} {row.denominator_branch:>12} "
            f"{row.numerator:12.3f} {row.denominator:12.3f} {row.value:10.3f}"
        )


def main() -> None:
    """Run deterministic examples and identity checks."""

    sample_values = (-3.0, -1.0, 0.0, 2.0, 5.0)
    poles = (-4.0, -0.5, 0.0, 1.5, 6.0)
    dense_grid = tuple(k / 4.0 for k in range(-40, 41))

    verify_basic_identity(dense_grid)
    verify_pole_independence(poles, dense_grid)
    print_sample_table(sample_values)
    print_pole_audit(1.5, (-2.0, 0.0, 1.5, 3.0, 7.0))
    print("\nAll sampled identities passed.")
    print("For every tested p and x, max(2x, x+p) - max(x, p) = x.")
    print("The compactified obstruction is topological, not numerical: a compact")
    print("extended line cannot be homeomorphic to the noncompact real line.")


if __name__ == "__main__":
    main()
