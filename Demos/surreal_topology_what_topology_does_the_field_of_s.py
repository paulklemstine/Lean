#!/usr/bin/env python3
"""Finite rational illustrations of infinitesimal-ladder and path-rigidity arguments.

These examples are finite shadows: rational arithmetic cannot represent a positive
number smaller than d/n for every natural n. Instead, a cutoff N is chosen and an
exact rational step is made small enough for the first N multiples.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Iterable, Sequence


@dataclass(frozen=True)
class LadderReport:
    """Exact data for a finite natural-step ladder below a prescribed width."""

    width: Fraction
    cutoff: int
    step: Fraction
    rungs: tuple[Fraction, ...]
    strictly_increasing: bool
    all_below_width: bool


def finite_ladder(width: Fraction, cutoff: int) -> LadderReport:
    """Construct 0, epsilon, ..., cutoff*epsilon strictly below ``width``.

    The choice epsilon = width/(cutoff+1) gives exact inequalities using
    ``fractions.Fraction``. Runtime and output size are O(cutoff).
    """
    if width <= 0:
        raise ValueError("width must be positive")
    if cutoff < 0:
        raise ValueError("cutoff must be nonnegative")
    step = width / (cutoff + 1)
    rungs = tuple(n * step for n in range(cutoff + 1))
    increasing = all(rungs[i] < rungs[i + 1] for i in range(len(rungs) - 1))
    below = all(rung < width for rung in rungs)
    return LadderReport(width, cutoff, step, rungs, increasing, below)


def translated_ladder(a: Fraction, x: Fraction, b: Fraction, cutoff: int) -> tuple[Fraction, ...]:
    """Place a finite ladder based at x inside the interval (a,b)."""
    if not a < x < b:
        raise ValueError("the basepoint must satisfy a < x < b")
    report = finite_ladder(b - x, cutoff)
    points = tuple(x + rung for rung in report.rungs)
    assert all(a < point < b for point in points)
    return points


def has_next_larger_rung(rungs: Sequence[Fraction], step: Fraction) -> bool:
    """Check that every displayed rung has a strictly larger successor."""
    if step <= 0:
        return False
    return all(rung + step > rung for rung in rungs)


def is_constant_discrete_path(values: Sequence[Fraction]) -> bool:
    """Test continuity in a finite totally separated path model.

    A connected chain mapped continuously to a discrete target must assign equal
    values to adjacent vertices, hence must be constant.
    """
    return all(values[i] == values[i + 1] for i in range(len(values) - 1))


def format_fraction(value: Fraction) -> str:
    """Format an exact rational compactly."""
    return str(value.numerator) if value.denominator == 1 else f"{value.numerator}/{value.denominator}"


def print_sequence(label: str, values: Iterable[Fraction]) -> None:
    """Print a labeled sequence of exact rationals."""
    print(f"{label}: " + ", ".join(format_fraction(v) for v in values))


def main() -> None:
    """Run three explanatory numerical demonstrations."""
    print("DEMO 1 — A finite shadow of an infinitesimal ladder")
    report = finite_ladder(Fraction(1), 12)
    print(f"width = {format_fraction(report.width)}, epsilon = {format_fraction(report.step)}")
    print_sequence("rungs", report.rungs)
    print(f"strictly increasing: {report.strictly_increasing}")
    print(f"all displayed rungs below width: {report.all_below_width}")
    print(f"every displayed rung admits a larger next rung: {has_next_larger_rung(report.rungs, report.step)}")

    print("\nDEMO 2 — Translating the ladder into an arbitrary neighborhood")
    a, x, b = Fraction(-2), Fraction(1, 3), Fraction(5, 4)
    points = translated_ladder(a, x, b, 10)
    print(f"interval = ({format_fraction(a)}, {format_fraction(b)}), basepoint = {format_fraction(x)}")
    print_sequence("translated points", points)
    print(f"all points lie in the interval: {all(a < p < b for p in points)}")

    print("\nDEMO 3 — Path rigidity in a finite totally separated model")
    constant_path = [Fraction(2, 3)] * 8
    attempted_motion = [Fraction(0), Fraction(0), Fraction(1, 10), Fraction(1, 10)]
    print(f"constant sample is continuous in the model: {is_constant_discrete_path(constant_path)}")
    print(f"attempted nonconstant motion is continuous in the model: {is_constant_discrete_path(attempted_motion)}")
    print("The full theorem is stronger: every continuous path in the surreal interval topology is constant.")


if __name__ == "__main__":
    main()
