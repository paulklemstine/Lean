#!/usr/bin/env python3
"""Numerical demonstrations for tropical social aggregation.

The script uses only the Python standard library.  It checks the algebraic laws
on finite test grids, exhibits profiles separating binary minimum from every
coordinate projection, verifies the concavity inequality numerically, and
illustrates how decisive dependence distinguishes projections from multi-voter
minimum rules.
"""

from __future__ import annotations

from itertools import product
from math import isclose
from typing import Callable, Iterable, Sequence

Profile = tuple[float, ...]
Aggregator = Callable[[Profile], float]


def coordinatewise_min(x: Profile, y: Profile) -> Profile:
    """Return the coordinatewise minimum of equally sized profiles."""
    if len(x) != len(y):
        raise ValueError("profiles must have equal length")
    return tuple(min(a, b) for a, b in zip(x, y))


def projection(index: int) -> Aggregator:
    """Return the dictatorship/projection selecting one coordinate."""
    return lambda x: x[index]


def minimum_aggregator(x: Profile) -> float:
    """Return the minimum score in a nonempty profile."""
    if not x:
        raise ValueError("a social profile must contain at least one voter")
    return min(x)


def translate(x: Profile, constant: float) -> Profile:
    """Add a common tropical scalar to all coordinates."""
    return tuple(value + constant for value in x)


def convex_mix(x: Profile, y: Profile, t: float) -> Profile:
    """Form the pointwise affine interpolation (1-t)x+ty."""
    if len(x) != len(y):
        raise ValueError("profiles must have equal length")
    return tuple((1.0 - t) * a + t * b for a, b in zip(x, y))


def check_tropical_laws(
    aggregator: Aggregator,
    profiles: Sequence[Profile],
    constants: Iterable[float],
    tolerance: float = 1e-10,
) -> tuple[bool, bool]:
    """Check min preservation and translation equivariance on supplied data."""
    min_preserving = all(
        isclose(
            aggregator(coordinatewise_min(x, y)),
            min(aggregator(x), aggregator(y)),
            abs_tol=tolerance,
        )
        for x in profiles
        for y in profiles
    )
    translation_equivariant = all(
        isclose(
            aggregator(translate(x, c)),
            aggregator(x) + c,
            abs_tol=tolerance,
        )
        for x in profiles
        for c in constants
    )
    return min_preserving, translation_equivariant


def depends_only_on_test_grid(
    aggregator: Aggregator,
    coalition: frozenset[int],
    profiles: Sequence[Profile],
    tolerance: float = 1e-10,
) -> bool:
    """Test dependence on a coalition over a finite profile grid."""
    for x in profiles:
        for y in profiles:
            if all(isclose(x[i], y[i], abs_tol=tolerance) for i in coalition):
                if not isclose(aggregator(x), aggregator(y), abs_tol=tolerance):
                    return False
    return True


def check_concavity(
    aggregator: Aggregator,
    profiles: Sequence[Profile],
    parameters: Iterable[float],
    tolerance: float = 1e-10,
) -> bool:
    """Check f((1-t)x+ty) >= (1-t)f(x)+t f(y) on finite samples."""
    return all(
        aggregator(convex_mix(x, y, t)) + tolerance
        >= (1.0 - t) * aggregator(x) + t * aggregator(y)
        for x in profiles
        for y in profiles
        for t in parameters
    )


def run_demo() -> None:
    """Print a reproducible numerical tour of the principal results."""
    values = (-1.0, 0.0, 1.0, 2.0)
    profiles = [tuple(p) for p in product(values, repeat=2)]
    constants = (-2.5, 0.0, 3.25)

    print("TROPICAL SOCIAL AGGREGATION DEMONSTRATION")
    print("=" * 49)
    laws = check_tropical_laws(minimum_aggregator, profiles, constants)
    print(f"Binary minimum preserves coordinatewise minima: {laws[0]}")
    print(f"Binary minimum commutes with common translations: {laws[1]}")
    print(f"Binary minimum is normalized: {minimum_aggregator((0.0, 0.0)) == 0.0}")

    witnesses = ((0.0, 1.0), (1.0, 0.0))
    print("\nWitnesses of non-dictatorship:")
    for x in witnesses:
        print(
            f"  profile {x}: minimum={minimum_aggregator(x):.1f}, "
            f"first projection={x[0]:.1f}, second projection={x[1]:.1f}"
        )
    for d in range(2):
        differs = any(
            not isclose(minimum_aggregator(x), projection(d)(x)) for x in witnesses
        )
        print(f"  differs from projection onto voter {d + 1}: {differs}")

    print("\nDependence sets on the test grid:")
    coalitions = [frozenset(), frozenset({0}), frozenset({1}), frozenset({0, 1})]
    for name, rule in (
        ("first projection", projection(0)),
        ("binary minimum", minimum_aggregator),
    ):
        valid = [
            "{" + ",".join(str(i + 1) for i in sorted(s)) + "}"
            for s in coalitions
            if depends_only_on_test_grid(rule, s, profiles)
        ]
        print(f"  {name}: {', '.join(valid)}")

    parameters = (0.0, 0.2, 0.5, 0.8, 1.0)
    print(
        "\nBinary minimum satisfies the concavity inequality on the grid: "
        f"{check_concavity(minimum_aggregator, profiles, parameters)}"
    )
    x, y, t = (0.0, 4.0), (3.0, 1.0), 0.5
    mixed = convex_mix(x, y, t)
    lhs = minimum_aggregator(mixed)
    rhs = (1.0 - t) * minimum_aggregator(x) + t * minimum_aggregator(y)
    print(f"  example: x={x}, y={y}, t={t}")
    print(f"  minimum of mixture={lhs:.2f}, mixture of minima={rhs:.2f}")
    print(f"  concavity gap={lhs - rhs:.2f}")


if __name__ == "__main__":
    run_demo()
