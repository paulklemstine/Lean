#!/usr/bin/env python3
"""Numerical demonstrations for the thermodynamics of sorting.

The program compares three factorial-controlled resources:
1. the minimum worst-case height of a binary comparison tree;
2. the information erased by the many-to-one visible sorting map;
3. the history capacity required by a reversible realization.

It also demonstrates that adding redundant comparison levels changes tree height
without changing the logical Landauer work of the visible map.
"""

from __future__ import annotations

import argparse
import math
from dataclasses import dataclass
from typing import Iterable

BOLTZMANN_CONSTANT: float = 1.380649e-23  # joules per kelvin


@dataclass(frozen=True)
class SortingResources:
    """Factorial resource values for sorting n distinct objects."""

    n: int
    permutations: int
    erased_bits: float
    comparison_lower_bound: int
    reversible_history_states: int
    irreversible_work_joules: float


def validate_n(n: int) -> None:
    """Reject values outside the nonnegative sorting model."""
    if n < 0:
        raise ValueError("n must be nonnegative")


def factorial_state_count(n: int) -> int:
    """Return the number n! of possible input permutations."""
    validate_n(n)
    return math.factorial(n)


def log_factorial(n: int) -> float:
    """Return ln(n!) by a stable logarithmic sum."""
    validate_n(n)
    return math.fsum(math.log(j) for j in range(1, n + 1))


def erased_information_bits(n: int) -> float:
    """Return log_2(n!), the information erased by visible sorting."""
    return log_factorial(n) / math.log(2.0)


def ceil_log2_integer(value: int) -> int:
    """Return the least h such that value <= 2**h for positive value."""
    if value < 1:
        raise ValueError("value must be positive")
    return 0 if value == 1 else (value - 1).bit_length()


def comparison_height_lower_bound(n: int) -> int:
    """Return the exact decision-tree lower bound ceil(log_2(n!))."""
    return ceil_log2_integer(factorial_state_count(n))


def landauer_work(n: int, temperature_kelvin: float) -> float:
    """Return k*T*ln(n!) joules for irreversible visible sorting."""
    validate_n(n)
    if temperature_kelvin < 0.0:
        raise ValueError("temperature must be nonnegative")
    return BOLTZMANN_CONSTANT * temperature_kelvin * log_factorial(n)


def sorting_resources(n: int, temperature_kelvin: float = 300.0) -> SortingResources:
    """Calculate the comparison, erasure, history, and work quantities."""
    states = factorial_state_count(n)
    return SortingResources(
        n=n,
        permutations=states,
        erased_bits=erased_information_bits(n),
        comparison_lower_bound=ceil_log2_integer(states),
        reversible_history_states=states,
        irreversible_work_joules=landauer_work(n, temperature_kelvin),
    )


def padding_experiment(n: int, base_height: int, redundant_levels: int,
                       temperature_kelvin: float = 300.0) -> tuple[int, int, float, float]:
    """Show that padding changes height but not logical Landauer work."""
    validate_n(n)
    if base_height < comparison_height_lower_bound(n):
        raise ValueError("base_height is below the transcript-capacity lower bound")
    if redundant_levels < 0:
        raise ValueError("redundant_levels must be nonnegative")
    work = landauer_work(n, temperature_kelvin)
    return base_height, base_height + redundant_levels, work, work


def format_table(rows: Iterable[SortingResources], temperature_kelvin: float) -> str:
    """Format resource values as a readable fixed-width table."""
    header = (
        f"Sorting resources at T = {temperature_kelvin:g} K\n"
        f"{'n':>3} {'n!':>24} {'log2(n!) bits':>15} "
        f"{'ceil log2':>10} {'history states':>24} {'work (J)':>14}"
    )
    lines = [header, "-" * 98]
    for row in rows:
        lines.append(
            f"{row.n:3d} {row.permutations:24d} {row.erased_bits:15.6f} "
            f"{row.comparison_lower_bound:10d} {row.reversible_history_states:24d} "
            f"{row.irreversible_work_joules:14.6e}"
        )
    return "\n".join(lines)


def run_demo(values: Iterable[int], temperature_kelvin: float, padding: int) -> None:
    """Print the factorial resource table and one padding demonstration."""
    ns = list(values)
    if not ns:
        raise ValueError("at least one n value is required")
    rows = [sorting_resources(n, temperature_kelvin) for n in ns]
    print(format_table(rows, temperature_kelvin))

    n = ns[-1]
    minimum = comparison_height_lower_bound(n)
    old_h, new_h, old_w, new_w = padding_experiment(
        n, minimum, padding, temperature_kelvin
    )
    print("\nRedundant-comparison experiment")
    print(f"  n = {n}; inserted levels = {padding}")
    print(f"  tree height: {old_h} -> {new_h}")
    print(f"  logical Landauer work: {old_w:.6e} J -> {new_w:.6e} J")
    print("  Reversible realization: zero logical gap, "
          f"at least {factorial_state_count(n)} history states.")


def parse_args() -> argparse.Namespace:
    """Parse command-line options."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("n", nargs="*", type=int, default=[0, 3, 5, 10, 20],
                        help="nonnegative item counts")
    parser.add_argument("--temperature", type=float, default=300.0,
                        help="temperature in kelvin (default: 300)")
    parser.add_argument("--padding", type=int, default=10,
                        help="redundant comparison levels (default: 10)")
    return parser.parse_args()


def main() -> None:
    """Command-line entry point."""
    args = parse_args()
    run_demo(args.n, args.temperature, args.padding)


if __name__ == "__main__":
    main()
