#!/usr/bin/env python3
"""Numerical demonstrations of the binary inverse tree of f(x)=4x(1-x)."""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from math import sqrt
from typing import Iterable, Sequence

BitWord = tuple[int, ...]


def logistic(x: float) -> float:
    """Return one parameter-four logistic-map update."""
    return 4.0 * x * (1.0 - x)


def iterate(x: float, steps: int) -> float:
    """Apply the logistic map ``steps`` times."""
    if steps < 0:
        raise ValueError("steps must be nonnegative")
    for _ in range(steps):
        x = logistic(x)
    return x


def inverse_branch(y: float, bit: int) -> float:
    """Return the lower branch for bit 0 or upper branch for bit 1."""
    if not 0.0 <= y <= 1.0:
        raise ValueError("inverse branches require a target in [0, 1]")
    if bit not in (0, 1):
        raise ValueError("bits must be 0 or 1")
    root = sqrt(max(0.0, 1.0 - y))
    return (1.0 + (1.0 if bit else -1.0) * root) / 2.0


def decode_seed(target: float, bits: Sequence[int]) -> float:
    """Decode bits b_0...b_(n-1) as B_b0(...B_b(n-1)(target))."""
    if not 0.0 < target < 1.0:
        raise ValueError("the binary-tree theorem requires 0 < target < 1")
    value = target
    for bit in reversed(bits):
        value = inverse_branch(value, bit)
    return value


def all_bit_words(depth: int) -> Iterable[BitWord]:
    """Generate all binary words of a fixed nonnegative length."""
    if depth < 0:
        raise ValueError("depth must be nonnegative")
    return product((0, 1), repeat=depth)


@dataclass(frozen=True)
class SeedRecord:
    """A decoded word, its seed, recovery error, and sampled common suffix."""

    bits: BitWord
    seed: float
    recovery_error: float
    suffix: tuple[float, ...]


def build_records(target: float, depth: int, suffix_length: int = 5) -> list[SeedRecord]:
    """Decode all words and measure recovery and future-suffix agreement."""
    if suffix_length < 1:
        raise ValueError("suffix_length must be positive")
    records: list[SeedRecord] = []
    for bits in all_bit_words(depth):
        seed = decode_seed(target, bits)
        recovered = iterate(seed, depth)
        suffix = tuple(iterate(seed, depth + k) for k in range(suffix_length))
        records.append(SeedRecord(bits, seed, abs(recovered - target), suffix))
    return records


def print_binary_tree_demo(target: float = 0.37, depth: int = 4) -> None:
    """Print all 2^depth seeds and verify their common target numerically."""
    records = build_records(target, depth)
    print(f"Target y={target:.16f}; depth n={depth}; indexed seeds={len(records)}")
    print("word       seed                  |f^n(seed)-y|")
    for record in records:
        word = "".join(map(str, record.bits)) or "empty"
        print(f"{word:<10} {record.seed:.16f}    {record.recovery_error:.3e}")
    distinct = len({record.seed for record in records}) == 2**depth
    print(f"Distinct in binary64 at this depth: {distinct}")
    print(f"Maximum recovery error: {max(r.recovery_error for r in records):.3e}")


def print_branch_geometry_demo(target: float = 0.73) -> None:
    """Show the two one-step predecessors on opposite sides of 1/2."""
    lower = inverse_branch(target, 0)
    upper = inverse_branch(target, 1)
    print("\nOne-step branch geometry")
    print(f"L(y)={lower:.16f} < 1/2 < U(y)={upper:.16f}")
    print(f"L(y)+U(y)={lower + upper:.16f}")
    print(f"f(L(y))={logistic(lower):.16f}, f(U(y))={logistic(upper):.16f}")


def print_suffix_collision_demo(target: float = 0.37, depth: int = 4) -> None:
    """Compare future suffixes from two distinct decoded histories."""
    left_bits = (0,) * depth
    right_bits = (1,) * depth
    left = decode_seed(target, left_bits)
    right = decode_seed(target, right_bits)
    print("\nCommon orbit suffix from distinct seeds")
    print(f"seed({left_bits})  = {left:.16f}")
    print(f"seed({right_bits}) = {right:.16f}")
    print(" k       left at n+k         right at n+k        target at k")
    for k in range(6):
        a = iterate(left, depth + k)
        b = iterate(right, depth + k)
        c = iterate(target, k)
        print(f"{k:2d}   {a:.16f}   {b:.16f}   {c:.16f}")
    print("Small discrepancies are floating-point rounding, not exact-real failures.")


def main() -> None:
    print_binary_tree_demo()
    print_branch_geometry_demo()
    print_suffix_collision_demo()


if __name__ == "__main__":
    main()
