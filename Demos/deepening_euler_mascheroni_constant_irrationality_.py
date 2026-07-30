#!/usr/bin/env python3
"""Numerical demonstrations for the accumulated-information formula for gamma.

Only the Python standard library is required.  The program compares the
termwise KL-divergence sum with the telescoped harmonic-logarithm expression,
checks rigorous term envelopes numerically, demonstrates scale invariance and
symmetrization, and optionally writes CSV data for plotting.
"""

from __future__ import annotations

import argparse
import csv
import math
from pathlib import Path
from typing import Iterable, Iterator, NamedTuple


class TermRecord(NamedTuple):
    """One consecutive-rate divergence and its two rational majorants."""

    k: int
    divergence: float
    rational_bound: float
    inverse_square_bound: float


def exponential_kl(rate_from: float, rate_to: float) -> float:
    """Return D_KL(Exp(rate_from) || Exp(rate_to)) for positive rates."""
    if rate_from <= 0.0 or rate_to <= 0.0:
        raise ValueError("Exponential rates must be positive")
    ratio_increment = (rate_to - rate_from) / rate_from
    # log1p is accurate when the two rates are close.
    return -math.log1p(ratio_increment) + ratio_increment


def gamma_term(k: int) -> float:
    """Return 1/(k+1) - log((k+2)/(k+1)) stably."""
    if k < 0:
        raise ValueError("k must be nonnegative")
    x = 1.0 / (k + 1.0)
    return x - math.log1p(x)


def harmonic_number(n: int) -> float:
    """Compute H_n with accurate standard-library summation."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return math.fsum(1.0 / j for j in range(1, n + 1))


def accumulated_divergence(n: int) -> float:
    """Compute sum_{k=0}^{n-1} D(Exp(k+1) || Exp(k+2))."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return math.fsum(gamma_term(k) for k in range(n))


def harmonic_log_approximation(n: int) -> float:
    """Compute the identical telescoped quantity H_n - log(n+1)."""
    return harmonic_number(n) - math.log(n + 1.0)


def term_records(count: int) -> Iterator[TermRecord]:
    """Yield divergences and proven bounds for k=0,...,count-1."""
    if count < 0:
        raise ValueError("count must be nonnegative")
    for k in range(count):
        yield TermRecord(
            k=k,
            divergence=gamma_term(k),
            rational_bound=1.0 / ((k + 1.0) * (2.0 * k + 3.0)),
            inverse_square_bound=1.0 / (2.0 * (k + 1.0) ** 2),
        )


def check_term_bounds(count: int) -> bool:
    """Numerically check 0 < g_k <= rational bound <= square bound."""
    return all(
        0.0 < row.divergence <= row.rational_bound <= row.inverse_square_bound
        for row in term_records(count)
    )


def symmetrized_closed_form(rate_a: float, rate_b: float) -> float:
    """Return (rate_a-rate_b)^2/(rate_a*rate_b)."""
    if rate_a <= 0.0 or rate_b <= 0.0:
        raise ValueError("Exponential rates must be positive")
    return (rate_a - rate_b) ** 2 / (rate_a * rate_b)


def write_csv(path: Path, rows: Iterable[TermRecord]) -> None:
    """Write term and bound data to a CSV file."""
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(
            ["k", "divergence", "rational_bound", "inverse_square_bound"]
        )
        writer.writerows(rows)


def run_demo(n: int, table_size: int, csv_path: Path | None) -> None:
    """Print all numerical demonstrations."""
    direct = accumulated_divergence(n)
    telescoped = harmonic_log_approximation(n)

    print("Euler–Mascheroni constant as accumulated information divergence")
    print("=" * 70)
    print(f"Number of rate transitions: {n:,}")
    print(f"Sum of adjacent KL divergences : {direct:.15f}")
    print(f"H_n - log(n+1)                : {telescoped:.15f}")
    print(f"Floating-point discrepancy    : {abs(direct - telescoped):.3e}")
    print(f"Reference gamma               : {0.5772156649015329:.15f}")
    print(f"Current positive tail         : {0.5772156649015329 - direct:.3e}")

    print("\nFirst terms and proven majorants")
    print("k      KL divergence       rational bound     inverse-square bound")
    rows = list(term_records(table_size))
    for row in rows:
        print(
            f"{row.k:<3d}  {row.divergence: .12e}  "
            f"{row.rational_bound: .12e}  {row.inverse_square_bound: .12e}"
        )
    print(f"Bounds hold for k < {max(n, table_size):,}: "
          f"{check_term_bounds(max(n, table_size))}")

    rate_a, rate_b, scale = 3.0, 7.0, 11.0
    forward = exponential_kl(rate_a, rate_b)
    reverse = exponential_kl(rate_b, rate_a)
    scaled = exponential_kl(scale * rate_a, scale * rate_b)
    square = symmetrized_closed_form(rate_a, rate_b)
    print("\nGeneral exponential-rate identities")
    print(f"D({rate_a:g} || {rate_b:g})                   = {forward:.15f}")
    print(f"D({rate_b:g} || {rate_a:g})                   = {reverse:.15f}")
    print(f"D({scale*rate_a:g} || {scale*rate_b:g}) (scaled)       = {scaled:.15f}")
    print(f"Forward + reverse             = {forward + reverse:.15f}")
    print(f"Squared-rate formula          = {square:.15f}")

    if csv_path is not None:
        write_csv(csv_path, term_records(n))
        print(f"\nWrote visualization data to {csv_path}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("-n", type=int, default=10_000, help="number of terms")
    parser.add_argument(
        "--table-size", type=int, default=8, help="number of displayed terms"
    )
    parser.add_argument(
        "--csv", type=Path, default=None, help="optional output CSV path"
    )
    return parser.parse_args()


if __name__ == "__main__":
    arguments = parse_args()
    run_demo(arguments.n, arguments.table_size, arguments.csv)
