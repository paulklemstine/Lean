#!/usr/bin/env python3
"""Numerical demonstrations for the thermodynamics of finite proof search.

The model treats depth-n candidate derivations as n-bit words.  It illustrates
exact multiplicity, an explicitly assumed independent-record Landauer cost,
finite incompressibility, and adversarial query coverage.
"""

from __future__ import annotations

import argparse
import math
from dataclasses import dataclass
from itertools import product
from typing import Iterable, Iterator, Sequence

BOLTZMANN_CONSTANT = 1.380_649e-23  # joules per kelvin, exact SI value


@dataclass(frozen=True)
class DepthStatistics:
    """Exact combinatorial statistics and modeled work at one depth."""

    depth: int
    candidates: int
    erased_alternatives: int
    created_choices: int
    dominates_creation: bool
    more_than_double_creation: bool
    work_joules: float


def binary_words(length: int) -> Iterator[str]:
    """Generate all binary words of a given nonnegative length."""
    if length < 0:
        raise ValueError("length must be nonnegative")
    for bits in product("01", repeat=length):
        yield "".join(bits)


def erased_alternatives(depth: int) -> int:
    """Return E(n) = 2**n - 1."""
    if depth < 0:
        raise ValueError("depth must be nonnegative")
    return (1 << depth) - 1


def erasure_work(
    depth: int,
    temperature_kelvin: float,
    boltzmann_scale: float = BOLTZMANN_CONSTANT,
) -> float:
    """Compute k*T*ln(2)*(2**depth - 1) joules.

    This is the work assigned by the independent-record model: one unbiased,
    reset bit is charged for every discarded candidate.  It is not a universal
    energy estimate for every proof-search implementation.
    """
    if temperature_kelvin < 0:
        raise ValueError("absolute temperature must be nonnegative")
    if boltzmann_scale < 0:
        raise ValueError("Boltzmann scale must be nonnegative")
    return (
        boltzmann_scale
        * temperature_kelvin
        * math.log(2.0)
        * erased_alternatives(depth)
    )


def depth_statistics(depth: int, temperature_kelvin: float) -> DepthStatistics:
    """Assemble exact counts and modeled thermodynamic work."""
    erased = erased_alternatives(depth)
    return DepthStatistics(
        depth=depth,
        candidates=1 << depth,
        erased_alternatives=erased,
        created_choices=depth,
        dominates_creation=depth <= erased,
        more_than_double_creation=2 * depth < erased,
        work_joules=erasure_work(depth, temperature_kelvin),
    )


def short_binary_descriptions(depth: int) -> list[str]:
    """List all binary strings having length strictly below depth."""
    if depth < 0:
        raise ValueError("depth must be nonnegative")
    return [word for length in range(depth) for word in binary_words(length)]


def forced_compression_collision(depth: int) -> tuple[str, str, str]:
    """Exhibit a collision when 2**n words use only 2**n-1 short labels.

    The cyclic assignment is merely illustrative; cardinality guarantees that
    every total assignment into the short-description set has a collision.
    """
    if depth <= 0:
        raise ValueError("depth must be positive for this explicit demo")
    words = list(binary_words(depth))
    descriptions = short_binary_descriptions(depth)
    first_for_code: dict[str, str] = {}
    for index, word in enumerate(words):
        code = descriptions[index % len(descriptions)]
        if code in first_for_code:
            return first_for_code[code], word, code
        first_for_code[code] = word
    raise RuntimeError("pigeonhole collision was unexpectedly absent")


def first_unqueried(depth: int, queried: Iterable[str]) -> str:
    """Return a candidate omitted by a sub-exhaustive query transcript."""
    queried_set = set(queried)
    universe_size = 1 << depth
    if len(queried_set) >= universe_size:
        raise ValueError("a witness is guaranteed only for sub-exhaustive queries")
    for word in binary_words(depth):
        if word not in queried_set:
            return word
    raise RuntimeError("cardinality precondition was violated")


def print_table(max_depth: int, temperature_kelvin: float) -> None:
    """Print exact depth statistics from zero through max_depth."""
    print(f"Independent-record model at T = {temperature_kelvin:g} K")
    print(" n | candidates | erased | erased>=n | erased>2n | work (J)")
    print("---+------------+--------+-----------+-----------+-------------")
    for depth in range(max_depth + 1):
        s = depth_statistics(depth, temperature_kelvin)
        print(
            f"{s.depth:2d} | {s.candidates:10d} | {s.erased_alternatives:6d} | "
            f"{str(s.dominates_creation):>9s} | "
            f"{str(s.more_than_double_creation):>9s} | {s.work_joules:.6e}"
        )


def demonstrate_recurrence(max_depth: int) -> None:
    """Check E(n+1) = 2E(n)+1 over a displayed finite range."""
    checks = [
        erased_alternatives(n + 1) == 2 * erased_alternatives(n) + 1
        for n in range(max_depth)
    ]
    print(f"Recurrence verified numerically for n=0,...,{max_depth - 1}: {all(checks)}")


def demonstrate_incompressibility(depth: int) -> None:
    """Display the cardinality deficit and one forced encoding collision."""
    long_count = 1 << depth
    short_count = erased_alternatives(depth)
    first, second, code = forced_compression_collision(depth)
    printable_code = code if code else "<empty>"
    print(
        f"Depth {depth}: {long_count} derivations but only {short_count} "
        "strictly shorter descriptions."
    )
    print(
        f"Illustrative cyclic encoding collision: {first} and {second} "
        f"both receive {printable_code!r}."
    )


def demonstrate_adversary(depth: int, queried_count: int) -> None:
    """Construct a hidden unique-success witness outside a query prefix."""
    if queried_count < 0 or queried_count >= (1 << depth):
        raise ValueError("queried_count must lie between 0 and 2**depth - 1")
    queried: Sequence[str] = list(binary_words(depth))[:queried_count]
    witness = first_unqueried(depth, queried)
    print(
        f"After {queried_count} of {1 << depth} candidates are queried, "
        f"the unique successful proof may still be {witness}."
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--max-depth", type=int, default=12)
    parser.add_argument("--temperature", type=float, default=300.0)
    parser.add_argument("--demo-depth", type=int, default=6)
    parser.add_argument("--queries", type=int, default=20)
    args = parser.parse_args()

    if args.max_depth < 0:
        parser.error("--max-depth must be nonnegative")
    if args.demo_depth <= 0:
        parser.error("--demo-depth must be positive")
    if not 0 <= args.queries < (1 << args.demo_depth):
        parser.error("--queries must satisfy 0 <= queries < 2**demo-depth")

    print_table(args.max_depth, args.temperature)
    print()
    demonstrate_recurrence(args.max_depth)
    print()
    demonstrate_incompressibility(args.demo_depth)
    print()
    demonstrate_adversary(args.demo_depth, args.queries)


if __name__ == "__main__":
    main()
