#!/usr/bin/env python3
"""Numerical illustrations for exponential-field approximation.

The script uses only the Python standard library.  It evaluates the shallow
one-exponential approximation to x^2, checks sampled errors against the proven
uniform upper bound, and demonstrates point separation by exponential
coordinates.  Grid sampling illustrates the theorem but is not a proof of a
continuum supremum.
"""

from __future__ import annotations

import argparse
import math
from dataclasses import dataclass
from typing import Iterable, Sequence


@dataclass(frozen=True)
class ErrorReport:
    """Summary of a sampled uniform-error experiment."""

    n: int
    h: float
    grid_size: int
    sampled_max_error: float
    maximizer: float
    certified_bound: float


def shallow_square_approx(h: float, x: float) -> float:
    """Evaluate S_h(x) = 2(exp(hx)-1-hx)/h^2 stably.

    ``math.expm1`` avoids cancellation in exp(hx)-1 when hx is small.
    """
    if not (0.0 < h <= 1.0):
        raise ValueError("h must satisfy 0 < h <= 1")
    u = h * x
    return 2.0 * (math.expm1(u) - u) / (h * h)


def certified_error_bound(h: float) -> float:
    """Return the uniform upper bound 4h/9 on [0,1]."""
    if not (0.0 < h <= 1.0):
        raise ValueError("h must satisfy 0 < h <= 1")
    return 4.0 * h / 9.0


def sampled_error_report(n: int, grid_size: int = 20_001) -> ErrorReport:
    """Sample the error at scale h=1/n on an equally spaced grid."""
    if n < 1:
        raise ValueError("n must be a positive integer")
    if grid_size < 2:
        raise ValueError("grid_size must be at least 2")
    h = 1.0 / n
    max_error = -1.0
    maximizer = 0.0
    for j in range(grid_size):
        x = j / (grid_size - 1)
        error = abs(shallow_square_approx(h, x) - x * x)
        if error > max_error:
            max_error = error
            maximizer = x
    return ErrorReport(
        n=n,
        h=h,
        grid_size=grid_size,
        sampled_max_error=max_error,
        maximizer=maximizer,
        certified_bound=4.0 / (9.0 * n),
    )


def separating_coordinate(x: Sequence[float], y: Sequence[float]) -> int | None:
    """Return a coordinate whose exponentials distinguish unequal vectors."""
    if len(x) != len(y):
        raise ValueError("vectors must have the same dimension")
    for i, (xi, yi) in enumerate(zip(x, y)):
        if xi != yi:
            # Injectivity of exp guarantees exp(xi) != exp(yi) mathematically.
            return i
    return None


def print_error_table(ns: Iterable[int], grid_size: int) -> None:
    """Print sampled errors and the corresponding certified bounds."""
    header = (
        f"{'N':>6} {'h':>12} {'sample max':>16} "
        f"{'4/(9N) bound':>16} {'error/bound':>14} {'argmax':>10}"
    )
    print(header)
    print("-" * len(header))
    for n in ns:
        report = sampled_error_report(n, grid_size)
        ratio = report.sampled_max_error / report.certified_bound
        print(
            f"{report.n:6d} {report.h:12.6g} "
            f"{report.sampled_max_error:16.9g} "
            f"{report.certified_bound:16.9g} {ratio:14.6g} "
            f"{report.maximizer:10.6f}"
        )


def demonstrate_separation() -> None:
    """Display one concrete exponential-coordinate separation example."""
    x = (0.2, 0.7, 0.4)
    y = (0.2, 0.7, 0.9)
    index = separating_coordinate(x, y)
    assert index is not None
    print("\nPoint-separation example")
    print(f"x = {x}")
    print(f"y = {y}")
    print(
        f"Coordinate {index + 1} differs, and its exponential values are "
        f"{math.exp(x[index]):.9f} and {math.exp(y[index]):.9f}."
    )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Illustrate density ingredients and the shallow square rate."
    )
    parser.add_argument(
        "--grid-size", type=int, default=20_001,
        help="number of points sampled from [0,1] (default: 20001)",
    )
    parser.add_argument(
        "--n", type=int, nargs="*", default=[1, 2, 5, 10, 50, 100],
        help="positive integer scales N (default: 1 2 5 10 50 100)",
    )
    args = parser.parse_args()
    print("Shallow approximation S_(1/N)(x) to x^2 on [0,1]")
    print_error_table(args.n, args.grid_size)
    print("\nThe bound is uniform; the sampled maximum is illustrative only.")
    demonstrate_separation()


if __name__ == "__main__":
    main()
