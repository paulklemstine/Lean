#!/usr/bin/env python3
"""Numerical demonstrations for Rips persistence of ordered prime clouds.

Only the Python standard library is required.  The script computes primes, consecutive
spacings, exact zero-dimensional Rips death times, connectivity thresholds, component
partitions, and a descriptive comparison with the unit exponential distribution.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import exp, isqrt, log
from typing import Iterable, Sequence


@dataclass(frozen=True)
class BarcodeSummary:
    """Finite H0 death times and the count of infinite bars."""

    finite_deaths: tuple[int, ...]
    infinite_bars: int = 1


def primes_up_to(limit: int) -> list[int]:
    """Return all primes at most ``limit`` by the sieve of Eratosthenes."""
    if limit < 2:
        return []
    sieve = bytearray(b"\x01") * (limit + 1)
    sieve[0:2] = b"\x00\x00"
    for p in range(2, isqrt(limit) + 1):
        if sieve[p]:
            start = p * p
            sieve[start : limit + 1 : p] = b"\x00" * (((limit - start) // p) + 1)
    return [n for n, flag in enumerate(sieve) if flag]


def consecutive_gaps(points: Sequence[int]) -> list[int]:
    """Compute consecutive gaps after validating strict increase."""
    if any(a >= b for a, b in zip(points, points[1:])):
        raise ValueError("points must be strictly increasing")
    return [b - a for a, b in zip(points, points[1:])]


def h0_barcode(points: Sequence[int]) -> BarcodeSummary:
    """Return the exact H0 barcode: sorted gaps and one infinite bar."""
    if not points:
        return BarcodeSummary((), 0)
    return BarcodeSummary(tuple(sorted(consecutive_gaps(points))), 1)


def connection_threshold(points: Sequence[int], i: int, j: int) -> int:
    """Return the first Rips scale at which indexed endpoints are connected."""
    if not 0 <= i < len(points) or not 0 <= j < len(points):
        raise IndexError("endpoint index out of range")
    if i > j:
        i, j = j, i
    if i == j:
        return 0
    return max(consecutive_gaps(points[i : j + 1]))


def components_at_scale(points: Sequence[int], epsilon: float) -> list[list[int]]:
    """Partition ordered points at each consecutive gap larger than ``epsilon``."""
    if epsilon < 0:
        raise ValueError("epsilon must be nonnegative")
    if not points:
        return []
    consecutive_gaps(points)  # validation
    components: list[list[int]] = [[points[0]]]
    for left, right in zip(points, points[1:]):
        if right - left <= epsilon:
            components[-1].append(right)
        else:
            components.append([right])
    return components


def empirical_exponential_ks(samples: Iterable[float]) -> float:
    """Return the descriptive KS distance to the unit exponential CDF."""
    values = sorted(samples)
    if not values:
        raise ValueError("at least one sample is required")
    if values[0] < 0:
        raise ValueError("samples must be nonnegative")
    n = len(values)
    distance = 0.0
    for rank, value in enumerate(values, start=1):
        target = 1.0 - exp(-value)
        distance = max(distance, abs(rank / n - target), abs((rank - 1) / n - target))
    return distance


def normalized_prime_gaps(limit: int, window_start: int) -> list[float]:
    """Normalize prime gaps in ``[window_start, limit]`` by ``log(window_start)``."""
    if window_start <= 1 or limit <= window_start:
        raise ValueError("require 1 < window_start < limit")
    local = [p for p in primes_up_to(limit) if p >= window_start]
    return [gap / log(window_start) for gap in consecutive_gaps(local)]


def main() -> None:
    first_six = [2, 3, 5, 7, 11, 13]
    print("First-six-prime cloud:", first_six)
    print("Consecutive gaps:", consecutive_gaps(first_six))
    print("Finite H0 death times:", h0_barcode(first_six).finite_deaths)
    print("Connection threshold from 2 to 13:", connection_threshold(first_six, 0, 5))
    for epsilon in (0, 1, 2, 3, 4):
        print(f"Components at epsilon={epsilon}: {components_at_scale(first_six, epsilon)}")

    limit, start = 100_000, 50_000
    primes = primes_up_to(limit)
    local = [p for p in primes if p >= start]
    normalized = normalized_prime_gaps(limit, start)
    print(f"\nPrimes up to {limit}: {len(primes)}")
    print(f"Local window [{start}, {limit}] contains {len(local)} primes and {len(normalized)} gaps")
    print(f"Mean local gap: {sum(consecutive_gaps(local)) / len(normalized):.4f}")
    print(f"Reference log({start}): {log(start):.4f}")
    print(f"Mean normalized gap: {sum(normalized) / len(normalized):.4f}")
    print(f"Descriptive KS distance to Exp(1): {empirical_exponential_ks(normalized):.4f}")
    print("Note: this is a descriptive comparison, not an independence-based hypothesis test.")


if __name__ == "__main__":
    main()
