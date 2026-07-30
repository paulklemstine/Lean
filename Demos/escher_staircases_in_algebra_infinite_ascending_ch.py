#!/usr/bin/env python3
"""Numerical demonstrations of powers-of-two divisibility filtrations."""
from __future__ import annotations

from dataclasses import dataclass
from math import inf
from typing import Callable, Iterable, Sequence


def v2(x: int) -> int | float:
    """Return the exponent of 2 in x, with v2(0) = infinity."""
    if x == 0:
        return inf
    x = abs(x)
    exponent = 0
    while x % 2 == 0:
        exponent += 1
        x //= 2
    return exponent


def all_divisible_at_level(values: Iterable[int], level: int) -> bool:
    """Test whether every value is divisible by 2**level."""
    if level < 0:
        raise ValueError("level must be nonnegative")
    modulus = 1 << level
    return all(value % modulus == 0 for value in values)


def sampled_depth(values: Sequence[int]) -> int | float:
    """Return the largest sampled filtration level; all-zero data has depth infinity."""
    if not values:
        raise ValueError("at least one sample is required")
    return min(v2(value) for value in values)


def strictness_witness(level: int) -> int:
    """Return 2**level, which lies at level but not at level + 1."""
    if level < 0:
        raise ValueError("level must be nonnegative")
    return 1 << level


def binomial_two(x: int) -> int:
    """Evaluate the integer-valued polynomial x(x-1)/2."""
    return x * (x - 1) // 2


def scaled_binomial_two(scale_level: int) -> Callable[[int], int]:
    """Return x -> 2**scale_level * binomial(x, 2)."""
    scale = strictness_witness(scale_level)
    return lambda x: scale * binomial_two(x)


@dataclass(frozen=True)
class LayerCertificate:
    level: int
    witness: int
    in_level: bool
    in_next_level: bool


def certify_constant_layers(max_level: int) -> list[LayerCertificate]:
    """Construct exact strictness certificates for levels 0 through max_level."""
    if max_level < 0:
        raise ValueError("max_level must be nonnegative")
    certificates: list[LayerCertificate] = []
    for level in range(max_level + 1):
        witness = strictness_witness(level)
        certificates.append(
            LayerCertificate(
                level=level,
                witness=witness,
                in_level=all_divisible_at_level([witness], level),
                in_next_level=all_divisible_at_level([witness], level + 1),
            )
        )
    return certificates


def evaluate_on_range(function: Callable[[int], int], start: int, stop: int) -> list[int]:
    """Evaluate an integer-valued function on the inclusive interval [start, stop]."""
    if start > stop:
        raise ValueError("start must not exceed stop")
    return [function(x) for x in range(start, stop + 1)]


def render_membership_table(values: Sequence[int], max_level: int) -> str:
    """Render a compact table of sampled membership across filtration levels."""
    rows = ["level | modulus | all sampled values divisible?", "------|---------|------------------------------"]
    for level in range(max_level + 1):
        rows.append(f"{level:>5} | {1 << level:>7} | {all_divisible_at_level(values, level)}")
    return "\n".join(rows)


def main() -> None:
    print("STRICT DESCENT CERTIFICATES")
    for item in certify_constant_layers(8):
        print(
            f"level {item.level}: witness {item.witness:>3} | "
            f"in J_{item.level}={item.in_level}, "
            f"in J_{item.level + 1}={item.in_next_level}"
        )

    print("\nINTEGER-VALUED POLYNOMIAL b(x)=x(x-1)/2")
    base_values = evaluate_on_range(binomial_two, -4, 8)
    print("values:", base_values)
    print(render_membership_table(base_values, 5))

    print("\nEXACT LAYER FOR 8*b(x)")
    polynomial = scaled_binomial_two(3)
    scaled_values = evaluate_on_range(polynomial, -4, 8)
    print("values:", scaled_values)
    print(render_membership_table(scaled_values, 6))
    print("sampled binary depth:", sampled_depth(scaled_values))

    print("\nZERO SAMPLE")
    zeros = [0] * 7
    print("sampled depth:", sampled_depth(zeros))
    print("The infinite value reflects that zero is divisible by every power of two.")


if __name__ == "__main__":
    main()
