#!/usr/bin/env python3
"""Numerical demonstrations for factorial information in sorting.

The program computes the exact comparison-tree lower bound, the information
lost by ordinary sorting, the ideal Landauer scale, reversible-history
capacity, and the effect of redundant comparison padding.  It uses only the
Python standard library.
"""

from __future__ import annotations

from dataclasses import dataclass
import argparse
import math
from typing import Iterable


@dataclass(frozen=True)
class SortingMetrics:
    """Information and capacity metrics for sorting n distinct objects."""

    n: int
    permutations: int
    erased_bits: float
    minimum_binary_depth: int
    dimensionless_work: float


def require_nonnegative(n: int) -> None:
    """Raise ValueError unless n is a nonnegative integer."""
    if n < 0:
        raise ValueError("n must be nonnegative")


def ceil_log2_integer(value: int) -> int:
    """Return the least h such that value <= 2**h, exactly for integers."""
    if value < 1:
        raise ValueError("value must be positive")
    return (value - 1).bit_length()


def factorial_information(n: int) -> SortingMetrics:
    """Compute exact state counts and stable logarithmic sorting metrics."""
    require_nonnegative(n)
    permutations = math.factorial(n)
    log_factorial = math.lgamma(n + 1.0)
    erased_bits = log_factorial / math.log(2.0)
    return SortingMetrics(
        n=n,
        permutations=permutations,
        erased_bits=erased_bits,
        minimum_binary_depth=ceil_log2_integer(permutations),
        dimensionless_work=log_factorial,
    )


def minimum_landauer_work(n: int, temperature: float, boltzmann: float = 1.380649e-23) -> float:
    """Return k*T*ln(n!) joules for the irreversible sorting map."""
    require_nonnegative(n)
    if temperature < 0.0:
        raise ValueError("temperature must be nonnegative")
    if boltzmann < 0.0:
        raise ValueError("Boltzmann's constant must be nonnegative")
    return boltzmann * temperature * math.lgamma(n + 1.0)


def history_capacity_audit(n: int, auxiliary_states: int) -> tuple[bool, int, float]:
    """Test the necessary n!-state condition for reversible sorting history.

    Returns (sufficient_state_count, missing_states, bit_deficit).  Passing is
    only a cardinality test; it does not construct a reversible sorter.
    """
    require_nonnegative(n)
    if auxiliary_states < 1:
        raise ValueError("auxiliary_states must be positive")
    required = math.factorial(n)
    missing = max(0, required - auxiliary_states)
    bit_deficit = max(0.0, math.lgamma(n + 1.0) / math.log(2.0) - math.log2(auxiliary_states))
    return auxiliary_states >= required, missing, bit_deficit


def padded_depths(base_height: int, padding_levels: Iterable[int]) -> list[int]:
    """Return h+r, the exact heights after redundant tree padding."""
    if base_height < 0:
        raise ValueError("base_height must be nonnegative")
    levels = list(padding_levels)
    if any(r < 0 for r in levels):
        raise ValueError("padding levels must be nonnegative")
    return [base_height + r for r in levels]


def print_metrics_table(max_n: int) -> None:
    """Print factorial entropy and comparison lower bounds for 0 through max_n."""
    require_nonnegative(max_n)
    print("n | n! | log2(n!) bits | minimum binary depth | ln(n!)")
    print("--+----+---------------+----------------------+-------")
    for n in range(max_n + 1):
        m = factorial_information(n)
        print(
            f"{n:2d} | {m.permutations:>10d} | {m.erased_bits:13.6f} | "
            f"{m.minimum_binary_depth:20d} | {m.dimensionless_work:9.6f}"
        )


def demonstrate_padding(n: int, extra_levels: int) -> None:
    """Show that redundant depth changes while map-level erasure stays fixed."""
    require_nonnegative(extra_levels)
    m = factorial_information(n)
    levels = list(range(extra_levels + 1))
    depths = padded_depths(m.minimum_binary_depth, levels)
    print(f"\nPadding experiment for n={n}")
    print(f"Fixed erased information: {m.erased_bits:.6f} bits")
    print(f"Fixed ideal W/(kT):       {m.dimensionless_work:.6f}")
    print("padding r -> tree height")
    for r, depth in zip(levels, depths):
        print(f"{r:9d} -> {depth}")


def main() -> None:
    """Run the command-line demonstration."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--max-n", type=int, default=10, help="largest table value (default: 10)")
    parser.add_argument("--temperature", type=float, default=300.0, help="temperature in kelvin")
    parser.add_argument("--padding", type=int, default=5, help="maximum redundant padding")
    args = parser.parse_args()

    print_metrics_table(args.max_n)
    m = factorial_information(args.max_n)
    joules = minimum_landauer_work(args.max_n, args.temperature)
    print(
        f"\nAt T={args.temperature:g} K, the ideal erasure baseline for n={args.max_n} "
        f"is {joules:.6e} J."
    )

    exact_ok = history_capacity_audit(args.max_n, m.permutations)
    short_ok = history_capacity_audit(args.max_n, max(1, m.permutations // 2))
    print(f"History audit with n! states:       {exact_ok}")
    print(f"History audit with floor(n!/2):    {short_ok}")
    demonstrate_padding(args.max_n, args.padding)


if __name__ == "__main__":
    main()
