#!/usr/bin/env python3
"""Numerical exploration of exact fibers of the parameter-4 logistic map.

The mathematical theorem concerns exact real arithmetic. This script uses ordinary
floating point numbers to enumerate branch-coded predecessors and report forward
residuals, separation, symmetry, and possible rounding collapse.
"""

from __future__ import annotations

import argparse
import math
from dataclasses import dataclass
from itertools import product
from typing import Iterable, Sequence

BitWord = tuple[int, ...]


@dataclass(frozen=True)
class FiberPoint:
    """A branch address, its decoded seed, and its forward error."""

    bits: BitWord
    seed: float
    residual: float


def logistic(x: float) -> float:
    """Return the full-strength logistic-map value 4*x*(1-x)."""

    return 4.0 * x * (1.0 - x)


def iterate_logistic(x: float, steps: int) -> float:
    """Apply the logistic map ``steps`` times."""

    if steps < 0:
        raise ValueError("steps must be nonnegative")
    for _ in range(steps):
        x = logistic(x)
    return x


def inverse_branch(y: float, upper: bool) -> float:
    """Evaluate the lower or upper real inverse branch at y in [0, 1]."""

    if not 0.0 <= y <= 1.0:
        raise ValueError("inverse branches require a target in [0, 1]")
    root = math.sqrt(max(0.0, 1.0 - y))
    return (1.0 + root) / 2.0 if upper else (1.0 - root) / 2.0


def decode_seed(bits: Sequence[int], target: float) -> float:
    """Decode a branch word into a predecessor of ``target``.

    The first bit specifies the outermost inverse branch, so evaluation proceeds
    from the final bit toward the first.
    """

    if not 0.0 < target < 1.0:
        raise ValueError("the exact interior-fiber theorem requires 0 < target < 1")
    value = target
    for bit in reversed(bits):
        if bit not in (0, 1):
            raise ValueError("branch words contain only 0 and 1")
        value = inverse_branch(value, upper=bool(bit))
    return value


def branch_words(depth: int) -> Iterable[BitWord]:
    """Generate all binary words of the requested length."""

    if depth < 0:
        raise ValueError("depth must be nonnegative")
    return product((0, 1), repeat=depth)


def enumerate_fiber(target: float, depth: int) -> list[FiberPoint]:
    """Enumerate all 2**depth branch-coded predecessors and their residuals."""

    points: list[FiberPoint] = []
    for raw_bits in branch_words(depth):
        bits = tuple(raw_bits)
        seed = decode_seed(bits, target)
        residual = abs(iterate_logistic(seed, depth) - target)
        points.append(FiberPoint(bits, seed, residual))
    return points


def breadth_first_fiber(target: float, depth: int) -> list[float]:
    """Enumerate the inverse tree one complete level at a time."""

    if not 0.0 < target < 1.0:
        raise ValueError("target must be strictly between 0 and 1")
    if depth < 0:
        raise ValueError("depth must be nonnegative")
    level = [target]
    for _ in range(depth):
        level = [branch(z, upper) for z in level for upper in (False, True)]
    return level


def branch(z: float, upper: bool) -> float:
    """Small named wrapper used by breadth-first enumeration."""

    return inverse_branch(z, upper)


def rounded_class_count(seeds: Sequence[float], precision_bits: int) -> int:
    """Count nearest-grid representatives k/2**p using half-up rounding."""

    if precision_bits < 0:
        raise ValueError("precision_bits must be nonnegative")
    scale = 1 << precision_bits
    representatives = {math.floor(seed * scale + 0.5) for seed in seeds}
    return len(representatives)


def format_bits(bits: Sequence[int]) -> str:
    """Format a branch address, including the empty address."""

    return "".join(map(str, bits)) if bits else "∅"


def summarize(target: float, depth: int, precision_bits: int, limit: int) -> None:
    """Print a concise numerical report for one target and depth."""

    points = enumerate_fiber(target, depth)
    sorted_points = sorted(points, key=lambda point: point.seed)
    seeds = [point.seed for point in sorted_points]
    distinct = len(set(seeds))
    expected = 1 << depth
    maximum_residual = max((point.residual for point in points), default=0.0)
    gaps = [b - a for a, b in zip(seeds, seeds[1:])]
    minimum_gap = min(gaps) if gaps else math.inf
    rounded = rounded_class_count(seeds, precision_bits)

    print("Exact interior-fiber experiment")
    print(f"target y                 : {target:.17g}")
    print(f"backward depth n         : {depth}")
    print(f"theoretical count 2^n    : {expected}")
    print(f"distinct float seeds     : {distinct}")
    print(f"maximum forward residual : {maximum_residual:.3e}")
    print(f"minimum float gap        : {minimum_gap:.3e}")
    print(f"distinct {precision_bits}-bit grid cells : {rounded}")
    print(f"grid-count upper bound   : {min(expected, (1 << precision_bits) + 1)}")
    print()
    print("address       decoded seed          L^n(seed)-target")
    print("------------- --------------------- ----------------")
    shown = sorted(points, key=lambda point: point.bits)[:limit]
    for point in shown:
        signed_error = iterate_logistic(point.seed, depth) - target
        print(f"{format_bits(point.bits):13s} {point.seed: .17f} {signed_error: .3e}")
    if len(points) > limit:
        print(f"... {len(points) - limit} additional seeds omitted")

    if depth >= 1:
        lower = inverse_branch(target, False)
        upper = inverse_branch(target, True)
        print()
        print("One-step branch checks")
        print(f"lower < 1/2 < upper      : {lower < 0.5 < upper}")
        print(f"reflection lower+upper   : {lower + upper:.17g}")


def parse_args() -> argparse.Namespace:
    """Parse command-line options."""

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--target", type=float, default=0.7, help="interior target y")
    parser.add_argument("--depth", type=int, default=6, help="number of backward steps")
    parser.add_argument(
        "--precision-bits",
        type=int,
        default=8,
        help="fixed-point denominator exponent used for rounding diagnostics",
    )
    parser.add_argument("--limit", type=int, default=16, help="maximum rows to print")
    return parser.parse_args()


def main() -> None:
    """Run the command-line demonstration."""

    args = parse_args()
    summarize(args.target, args.depth, args.precision_bits, args.limit)


if __name__ == "__main__":
    main()
