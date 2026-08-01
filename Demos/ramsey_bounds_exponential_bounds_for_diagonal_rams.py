#!/usr/bin/env python3
"""Numerical demonstrations for sub-four exponential normalization.

The calculations use logarithms when powers would be large.  No third-party
packages are required.
"""

from __future__ import annotations

import argparse
import math
from dataclasses import dataclass
from typing import Iterable


@dataclass(frozen=True)
class NormalizedSaving:
    """Equivalent proportional and additive descriptions of a base below four."""

    q: float
    epsilon: float
    base: float


def normalize_q(q: float) -> NormalizedSaving:
    """Convert 0 < q < 1 into epsilon = 4(1-q) and the common base."""
    if not 0.0 < q < 1.0:
        raise ValueError("q must satisfy 0 < q < 1")
    epsilon = 4.0 * (1.0 - q)
    return NormalizedSaving(q=q, epsilon=epsilon, base=4.0 * q)


def normalize_delta(delta: float) -> NormalizedSaving:
    """Convert exponential damping exp(-delta), delta > 0, to a sub-four gap."""
    if delta <= 0.0:
        raise ValueError("delta must be positive")
    return normalize_q(math.exp(-delta))


def log_absorption_margin(k: int, degree: int, q: float, q_prime: float) -> float:
    """Return log((q'/q)^k / k^degree); nonnegative means absorption holds."""
    if k < 1 or degree < 0:
        raise ValueError("require k >= 1 and degree >= 0")
    if not 0.0 < q < q_prime < 1.0:
        raise ValueError("require 0 < q < q_prime < 1")
    return k * math.log(q_prime / q) - degree * math.log(k)


def absorption_threshold(degree: int, q: float, q_prime: float | None = None) -> int:
    """Find a certified threshold N with k^d <= (q'/q)^k for every k >= N.

    Certification uses that f(x)=x log(q'/q)-d log x is increasing for
    x >= d/log(q'/q).  Exponential bracketing and binary search then locate
    the first nonnegative integer value in that monotone region.
    """
    if degree < 0:
        raise ValueError("degree must be nonnegative")
    if not 0.0 < q < 1.0:
        raise ValueError("q must satisfy 0 < q < 1")
    qp = (q + 1.0) / 2.0 if q_prime is None else q_prime
    if not q < qp < 1.0:
        raise ValueError("q_prime must satisfy q < q_prime < 1")
    if degree == 0:
        return 1

    rate = math.log(qp / q)
    monotone_start = max(1, math.ceil(degree / rate))
    low = monotone_start
    if log_absorption_margin(low, degree, q, qp) >= 0.0:
        return low

    high = low
    while log_absorption_margin(high, degree, q, qp) < 0.0:
        high *= 2

    while low + 1 < high:
        mid = (low + high) // 2
        if log_absorption_margin(mid, degree, q, qp) >= 0.0:
            high = mid
        else:
            low = mid
    return high


def comparison_rows(q: float, degree: int, ks: Iterable[int]) -> list[tuple[int, float, float]]:
    """Return log10 values of k^d(4q)^k and the midpoint pure exponential."""
    qp = (q + 1.0) / 2.0
    rows: list[tuple[int, float, float]] = []
    for k in ks:
        if k < 1:
            raise ValueError("comparison indices must be positive")
        decorated = degree * math.log10(k) + k * math.log10(4.0 * q)
        pure = k * math.log10(4.0 * qp)
        rows.append((k, decorated, pure))
    return rows


def run_demo(q: float, delta: float, degree: int) -> None:
    """Print exact transformations and a stable polynomial-absorption example."""
    direct = normalize_q(q)
    damped = normalize_delta(delta)
    qp = (q + 1.0) / 2.0
    threshold = absorption_threshold(degree, q, qp)

    print("SUB-FOUR NORMALIZATION")
    print(f"q = {direct.q:.8f}")
    print(f"epsilon = 4(1-q) = {direct.epsilon:.8f}")
    print(f"4q = {4*q:.8f}; 4-epsilon = {4-direct.epsilon:.8f}")
    print()
    print("EXPONENTIAL DAMPING")
    print(f"delta = {delta:.8f}; exp(-delta) = {damped.q:.8f}")
    print(f"epsilon = 4(1-exp(-delta)) = {damped.epsilon:.8f}")
    print(f"common base = {damped.base:.8f}")
    print()
    print("POLYNOMIAL ABSORPTION")
    print(f"degree d = {degree}; q = {q:.8f}; midpoint q' = {qp:.8f}")
    print(f"certified threshold N = {threshold}")
    print(f"final epsilon = 4(1-q') = {4*(1-qp):.8f}")
    print("The table compares base-10 logarithms; decorated <= pure is success.")
    sample = sorted({max(1, threshold // 2), threshold, threshold + 100})
    print("{:>10} {:>24} {:>22} {:>10}".format(
        "k", "log10[k^d(4q)^k]", "log10[(4q')^k]", "absorbed"
    ))
    for k, decorated, pure in comparison_rows(q, degree, sample):
        print(f"{k:10d} {decorated:24.6f} {pure:22.6f} {str(decorated <= pure):>10}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--q", type=float, default=0.9, help="proportional factor in (0,1)")
    parser.add_argument("--delta", type=float, default=0.05, help="positive damping exponent")
    parser.add_argument("--degree", type=int, default=3, help="nonnegative polynomial degree")
    args = parser.parse_args()
    run_demo(args.q, args.delta, args.degree)


if __name__ == "__main__":
    main()
