#!/usr/bin/env python3
"""Numerical exploration of logarithmic prime coordinates.

The script uses only the Python standard library.  It demonstrates:
1. exact finite-sample interval covering numbers;
2. the eventual zero box-counting slope of every fixed finite sample;
3. geometric covering costs that witness vanishing positive-dimensional
   Hausdorff measure for an enumerated set; and
4. transformed gaps, including twin-prime pairs.
"""

from __future__ import annotations

import argparse
import math
from dataclasses import dataclass
from typing import Iterable, Sequence


@dataclass(frozen=True)
class GapRecord:
    """A pair of consecutive primes and their logarithmic-coordinate gap."""

    lower_prime: int
    upper_prime: int
    ordinary_gap: int
    coordinate_gap: float


def primes_up_to(limit: int) -> list[int]:
    """Return all primes at most ``limit`` by the sieve of Eratosthenes."""
    if limit < 2:
        return []
    sieve = bytearray(b"\x01") * (limit + 1)
    sieve[0:2] = b"\x00\x00"
    for p in range(2, math.isqrt(limit) + 1):
        if sieve[p]:
            start = p * p
            sieve[start : limit + 1 : p] = b"\x00" * (
                ((limit - start) // p) + 1
            )
    return [n for n, is_prime in enumerate(sieve) if is_prime]


def logarithmic_prime_coordinates(limit: int) -> list[float]:
    """Return ``1/log(p)`` for primes ``p <= limit``, sorted increasingly."""
    return sorted(1.0 / math.log(p) for p in primes_up_to(limit))


def greedy_cover_count(points: Sequence[float], epsilon: float) -> int:
    """Find the minimum number of closed intervals of length epsilon.

    For points on a line, starting each interval at the leftmost uncovered
    point is optimal.  The input need not already be sorted.
    """
    if epsilon <= 0.0:
        raise ValueError("epsilon must be positive")
    ordered = sorted(points)
    count = 0
    index = 0
    while index < len(ordered):
        right_endpoint = ordered[index] + epsilon
        count += 1
        index += 1
        while index < len(ordered) and ordered[index] <= right_endpoint:
            index += 1
    return count


def covering_curve(points: Sequence[float], scales: Iterable[float]) -> list[tuple[float, int]]:
    """Return exact finite covering numbers at the requested scales."""
    return [(eps, greedy_cover_count(points, eps)) for eps in scales]


def local_box_slopes(curve: Sequence[tuple[float, int]]) -> list[float]:
    """Compute adjacent secant slopes on a log N versus log(1/epsilon) plot."""
    slopes: list[float] = []
    for (e1, n1), (e2, n2) in zip(curve, curve[1:]):
        denominator = math.log(1.0 / e2) - math.log(1.0 / e1)
        slopes.append((math.log(n2) - math.log(n1)) / denominator)
    return slopes


def transformed_gaps(limit: int) -> list[GapRecord]:
    """Return ordinary and transformed gaps between consecutive primes."""
    primes = primes_up_to(limit)
    records: list[GapRecord] = []
    for p, q in zip(primes, primes[1:]):
        records.append(
            GapRecord(p, q, q - p, abs(1.0 / math.log(p) - 1.0 / math.log(q)))
        )
    return records


def geometric_hausdorff_cost(
    number_of_points: int, dimension: float, delta: float, shrink: float = 0.5
) -> tuple[list[float], float]:
    """Construct pointwise diameters and their finite s-dimensional cost.

    Diameter n is ``delta * shrink**((n+1)/dimension)``.  Its ``dimension``
    power is geometric, illustrating why countable sets have arbitrarily
    small positive-dimensional Hausdorff cost after scaling ``delta``.
    """
    if number_of_points < 0:
        raise ValueError("number_of_points must be nonnegative")
    if dimension <= 0.0 or delta <= 0.0 or not 0.0 < shrink < 1.0:
        raise ValueError("require dimension, delta > 0 and 0 < shrink < 1")
    diameters = [delta * shrink ** ((n + 1) / dimension) for n in range(number_of_points)]
    return diameters, sum(length**dimension for length in diameters)


def run_demo(limit: int) -> None:
    """Print a reproducible report for primes up to ``limit``."""
    primes = primes_up_to(limit)
    points = logarithmic_prime_coordinates(limit)
    if len(points) < 2:
        raise ValueError("choose a limit containing at least two primes")

    minimum_gap = min(b - a for a, b in zip(points, points[1:]))
    scales = [10.0 ** exponent for exponent in range(-1, -9, -1)]
    scales.extend([minimum_gap / 2.0, minimum_gap / 10.0])
    scales = sorted(set(scales), reverse=True)
    curve = covering_curve(points, scales)
    slopes = local_box_slopes(curve)

    print("LOGARITHMIC PRIME COORDINATES")
    print(f"prime bound: {limit:,}")
    print(f"number of points: {len(points):,}")
    print(f"coordinate range: [{points[0]:.12g}, {points[-1]:.12g}]")
    print(f"minimum finite-sample separation: {minimum_gap:.6e}\n")

    print("epsilon          exact N(epsilon)   next local slope")
    for index, (epsilon, count) in enumerate(curve):
        slope_text = f"{slopes[index]: .6f}" if index < len(slopes) else "--"
        print(f"{epsilon:12.5e}  {count:16d}   {slope_text}")
    print("\nAt scales below the minimum separation, N equals the fixed sample size;")
    print("therefore log(N)/log(1/epsilon) tends to zero.")

    _, cost = geometric_hausdorff_cost(len(points), dimension=1.0, delta=1e-3)
    _, smaller_cost = geometric_hausdorff_cost(len(points), dimension=1.0, delta=1e-6)
    print("\nGEOMETRIC COVER CERTIFICATE (s = 1)")
    print(f"cost with delta=1e-3: {cost:.6e}")
    print(f"cost with delta=1e-6: {smaller_cost:.6e}")

    gaps = transformed_gaps(limit)
    twins = [record for record in gaps if record.ordinary_gap == 2]
    print("\nLAST FIVE TWIN-PRIME GAPS IN THE SAMPLE")
    for record in twins[-5:]:
        approximation = 2.0 / (record.lower_prime * math.log(record.lower_prime) ** 2)
        print(
            f"({record.lower_prime}, {record.upper_prime}): "
            f"exact={record.coordinate_gap:.6e}, approximation={approximation:.6e}"
        )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--limit", type=int, default=100_000, help="prime truncation bound")
    args = parser.parse_args()
    run_demo(args.limit)


if __name__ == "__main__":
    main()
