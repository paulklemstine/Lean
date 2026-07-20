#!/usr/bin/env python3
"""Numerical demonstrations for description complexity and thermodynamic cost.

The program uses only Python's standard library. Temperature is expressed in
energy units, so one erased bit has ideal Landauer scale T * ln(2).
"""

from __future__ import annotations

import argparse
import math
from dataclasses import dataclass
from typing import Iterable


@dataclass(frozen=True)
class SortingProfile:
    """Information-theoretic quantities associated with sorting n objects."""

    n: int
    permutations: int
    information_bits: float
    comparison_lower_bound: int
    landauer_scale: float
    reversible_history_states: int


def proof_cost(complexity_bits: int, temperature: float) -> float:
    """Return T ln(2) K for a K-bit shortest description."""
    if complexity_bits < 0:
        raise ValueError("complexity_bits must be nonnegative")
    if temperature < 0:
        raise ValueError("temperature must be nonnegative")
    return temperature * math.log(2.0) * complexity_bits


def sorting_profile(n: int, temperature: float = 1.0) -> SortingProfile:
    """Compute comparison, erasure, and reversible-history bounds for sorting."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    if temperature < 0:
        raise ValueError("temperature must be nonnegative")
    permutations = math.factorial(n)
    log_factorial = math.lgamma(n + 1.0)
    information_bits = log_factorial / math.log(2.0)
    # A small tolerance protects exact powers of two from floating-point noise.
    comparison_lower_bound = math.ceil(information_bits - 1e-12)
    return SortingProfile(
        n=n,
        permutations=permutations,
        information_bits=information_bits,
        comparison_lower_bound=comparison_lower_bound,
        landauer_scale=temperature * log_factorial,
        reversible_history_states=permutations,
    )


def incompressibility_bound(n: int, deficiency: int) -> tuple[float, float]:
    """Return guaranteed hard fraction and mean-complexity lower bound.

    In an ensemble of 2**n distinct objects, more than fraction 1-2**(-c)
    have complexity at least n-c. The second output is the resulting lower
    bound on the uniform mean complexity.
    """
    if n < 0:
        raise ValueError("n must be nonnegative")
    if not 1 <= deficiency <= n:
        raise ValueError("deficiency must satisfy 1 <= deficiency <= n")
    fraction = 1.0 - 2.0 ** (-deficiency)
    mean_lower_bound = fraction * (n - deficiency)
    return fraction, mean_lower_bound


def exhaustive_candidate_count(max_length: int) -> int:
    """Count all binary strings of lengths 0 through max_length."""
    if max_length < 0:
        raise ValueError("max_length must be nonnegative")
    return (1 << (max_length + 1)) - 1


def monotonicity_demo(complexities: Iterable[int], temperature: float) -> list[float]:
    """Compute costs and check that sorted complexities give sorted costs."""
    ordered = sorted(complexities)
    costs = [proof_cost(k, temperature) for k in ordered]
    if any(a > b for a, b in zip(costs, costs[1:])):
        raise AssertionError("monotonicity failed")
    return costs


def run_demo(max_n: int, temperature: float, deficiency: int) -> None:
    """Print three numerical demonstrations of the principal results."""
    if max_n < max(2, deficiency):
        raise ValueError("max_n must be at least max(2, deficiency)")

    print("DESCRIPTION-ERASURE MONOTONICITY")
    complexities = [8, 16, 32, 64]
    costs = monotonicity_demo(complexities, temperature)
    for bits, cost in zip(complexities, costs):
        print(f"  K = {bits:3d} bits -> C_T = {cost:.6g}")

    print("\nSORTING: ONE FACTORIAL, THREE LOWER BOUNDS")
    print("  n      n!       log2(n!)  min comparisons  history states  T ln(n!)")
    for n in range(2, max_n + 1):
        p = sorting_profile(n, temperature)
        print(
            f"  {n:2d} {p.permutations:9d} {p.information_bits:10.4f}"
            f" {p.comparison_lower_bound:16d} {p.reversible_history_states:15d}"
            f" {p.landauer_scale:10.4f}"
        )

    print("\nFINITE INCOMPRESSIBILITY AND SEARCH SEPARATION")
    print("  n  hard fraction  mean K lower bound  candidates through n  ratio")
    for n in range(max(deficiency, 4), max_n * 4 + 1, max_n):
        fraction, mean_lb = incompressibility_bound(n, deficiency)
        candidates = exhaustive_candidate_count(n)
        ratio = candidates / max(mean_lb, 1.0)
        print(
            f"  {n:2d} {fraction:13.6f} {mean_lb:19.4f}"
            f" {candidates:21d} {ratio:10.3e}"
        )

    print("\nInterpretation:")
    print("  Typical description complexity is linear in n under uniform binary sampling,")
    print("  while exhaustive search through descriptions has exponentially many candidates.")
    print("  Sorting erases log2(n!) bits, but redundant comparisons can increase operation")
    print("  count without changing that logical-erasure quantity.")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--max-n", type=int, default=10, help="largest sorting instance")
    parser.add_argument(
        "--temperature", type=float, default=1.0,
        help="temperature in energy units (default: 1)",
    )
    parser.add_argument(
        "--deficiency", type=int, default=4,
        help="incompressibility deficiency c (default: 4)",
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    run_demo(args.max_n, args.temperature, args.deficiency)
