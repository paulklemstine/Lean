#!/usr/bin/env python3
"""Exact numerical demonstrations for sharp Euler prime runs and 163."""

from __future__ import annotations

from dataclasses import dataclass
from math import isqrt
from typing import Iterable


@dataclass(frozen=True)
class RunReport:
    """Summary of a candidate sharp Euler prime run."""

    p: int
    discriminant: int
    values: tuple[int, ...]
    boundary: int
    all_prime: bool
    distinct: bool
    in_interval: bool


def euler_polynomial(p: int, n: int) -> int:
    """Return n^2 + n + p using exact integer arithmetic."""
    if p < 0 or n < 0:
        raise ValueError("p and n must be nonnegative")
    return n * n + n + p


def is_prime(value: int) -> bool:
    """Deterministically test primality by trial division."""
    if value < 2:
        return False
    if value % 2 == 0:
        return value == 2
    divisor = 3
    while divisor <= isqrt(value):
        if value % divisor == 0:
            return False
        divisor += 2
    return True


def analyze_run(p: int) -> RunReport:
    """Compute all proper run values and check the packing conclusions."""
    if p < 2:
        raise ValueError("p must be at least 2")
    values = tuple(euler_polynomial(p, n) for n in range(p - 1))
    boundary = euler_polynomial(p, p - 1)
    return RunReport(
        p=p,
        discriminant=4 * p - 1,
        values=values,
        boundary=boundary,
        all_prime=all(is_prime(value) for value in values),
        distinct=len(values) == len(set(values)),
        in_interval=all(p <= value < p * p for value in values),
    )


def verify_cube_signatures() -> list[tuple[int, int, int, bool]]:
    """Return base, target, remainder, and exact-identity status."""
    data = (
        (960, 884_736_744),
        (5_280, 147_197_952_744),
        (640_320, 262_537_412_640_768_744),
    )
    return [
        (base, target, target % (base**3), base**3 + 744 == target)
        for base, target in data
    ]


def print_table(rows: Iterable[tuple[str, str]]) -> None:
    """Print aligned label/value rows."""
    materialized = list(rows)
    width = max(len(label) for label, _ in materialized)
    for label, value in materialized:
        print(f"{label:<{width}} : {value}")


def main() -> None:
    """Run all exact demonstrations and assert every claimed invariant."""
    for p in (11, 17, 41):
        report = analyze_run(p)
        assert report.all_prime
        assert report.distinct
        assert report.in_interval
        assert report.boundary == p * p
        assert not is_prime(report.boundary)
        assert is_prime(p) and is_prime(p + 2)
        print(f"\nSharp run for p={p}")
        print_table(
            (
                ("discriminant magnitude", str(report.discriminant)),
                ("number of proper values", str(len(report.values))),
                ("first two values", str(report.values[:2])),
                ("last proper value", str(report.values[-1])),
                ("square boundary", str(report.boundary)),
                ("all values prime", str(report.all_prime)),
                ("distinct and in [p,p^2)", str(report.distinct and report.in_interval)),
            )
        )

    print("\nExact cube-plus-744 signatures")
    for base, target, remainder, exact in verify_cube_signatures():
        assert exact and remainder == 744
        print(f"{base}^3 + 744 = {target}; remainder modulo {base}^3 is {remainder}")

    heegner_list = (1, 2, 3, 7, 11, 19, 43, 67, 163)
    assert max(heegner_list) == 163
    print(f"\nMaximum of the explicit list {heegner_list} is {max(heegner_list)}.")


if __name__ == "__main__":
    main()
