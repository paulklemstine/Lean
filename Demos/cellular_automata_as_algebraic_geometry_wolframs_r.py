#!/usr/bin/env python3
"""Numerical demonstrations for elementary cellular automata over GF(2).

The program verifies the Rule 110 algebraic normal form, illustrates the
extremal fixed-point behavior of Rules 0 and 204, and enumerates fixed points
on small periodic rings.  It uses only the Python standard library.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, Sequence

Bit = int
State = tuple[Bit, ...]


def local_rule(rule: int, left: Bit, center: Bit, right: Bit) -> Bit:
    """Evaluate a Wolfram elementary rule on one binary neighborhood."""
    if not 0 <= rule <= 255:
        raise ValueError("rule must lie between 0 and 255")
    if (left, center, right) not in {
        (a, b, c) for a in (0, 1) for b in (0, 1) for c in (0, 1)
    }:
        raise ValueError("neighborhood entries must be 0 or 1")
    index = 4 * left + 2 * center + right
    return (rule >> index) & 1


def rule110_polynomial(left: Bit, center: Bit, right: Bit) -> Bit:
    """Evaluate r + c + cr + lcr in GF(2)."""
    return (right + center + center * right + left * center * right) % 2


def update_periodic(rule: int, state: Sequence[Bit]) -> State:
    """Perform one synchronous update with periodic boundary conditions."""
    n = len(state)
    if n == 0:
        raise ValueError("state must be nonempty")
    if any(bit not in (0, 1) for bit in state):
        raise ValueError("state entries must be 0 or 1")
    return tuple(
        local_rule(rule, state[(i - 1) % n], state[i], state[(i + 1) % n])
        for i in range(n)
    )


def decode_state(encoded: int, width: int) -> State:
    """Decode an integer into a low-index-first binary state."""
    return tuple((encoded >> i) & 1 for i in range(width))


def fixed_points(rule: int, width: int) -> list[State]:
    """Enumerate fixed states of a rule on a periodic ring."""
    if width <= 0:
        raise ValueError("width must be positive")
    return [
        state
        for encoded in range(1 << width)
        if update_periodic(rule, state := decode_state(encoded, width)) == state
    ]


def algebraic_normal_form(rule: int) -> tuple[Bit, ...]:
    """Return coefficients indexed by variable masks r=1, c=2, l=4."""
    if not 0 <= rule <= 255:
        raise ValueError("rule must lie between 0 and 255")
    coefficients = [(rule >> mask) & 1 for mask in range(8)]
    for variable_bit in (1, 2, 4):
        for mask in range(8):
            if mask & variable_bit:
                coefficients[mask] ^= coefficients[mask ^ variable_bit]
    return tuple(coefficients)


def polynomial_label(coefficients: Sequence[Bit]) -> str:
    """Render three-variable algebraic-normal-form coefficients."""
    labels = ("1", "r", "c", "cr", "l", "lr", "lc", "lcr")
    terms = [label for bit, label in zip(coefficients, labels) if bit]
    return " + ".join(terms) if terms else "0"


@dataclass(frozen=True)
class FixedPointSummary:
    """A compact fixed-point count for one rule and one ring size."""

    rule: int
    width: int
    count: int
    total_states: int


def summarize(rule: int, width: int) -> FixedPointSummary:
    """Count fixed points and package the result."""
    return FixedPointSummary(rule, width, len(fixed_points(rule, width)), 1 << width)


def verify_rule110_table() -> None:
    """Assert equality of Rule 110's lookup table and cubic polynomial."""
    for left in (0, 1):
        for center in (0, 1):
            for right in (0, 1):
                table = local_rule(110, left, center, right)
                polynomial = rule110_polynomial(left, center, right)
                assert table == polynomial
                print(f"  {left}{center}{right} -> {table} (polynomial {polynomial})")


def print_fixed_point_census(widths: Iterable[int]) -> None:
    """Print fixed-point counts for Rules 0, 110, and 204."""
    print("\nFixed-point census on periodic rings")
    print("width | Rule 0 | Rule 110 | Rule 204 | total")
    print("------|--------|----------|----------|------")
    for width in widths:
        counts = [len(fixed_points(rule, width)) for rule in (0, 110, 204)]
        print(
            f"{width:5d} | {counts[0]:6d} | {counts[1]:8d} | "
            f"{counts[2]:8d} | {1 << width:5d}"
        )
        assert counts[0] == 1
        assert counts[2] == 1 << width
        assert 1 <= counts[1] < 1 << width


def main() -> None:
    """Run all demonstrations and exact consistency checks."""
    print("Rule 110 truth table versus r + c + cr + lcr over GF(2)")
    verify_rule110_table()

    coefficients = algebraic_normal_form(110)
    print(f"\nExtracted Rule 110 polynomial: {polynomial_label(coefficients)}")
    assert polynomial_label(coefficients) == "r + c + cr + lcr"

    ones: State = (1,) * 8
    zeros: State = (0,) * 8
    print(f"Rule 110 maps 11111111 to {''.join(map(str, update_periodic(110, ones)))}")
    print(f"Rule 110 maps 00000000 to {''.join(map(str, update_periodic(110, zeros)))}")
    assert update_periodic(110, ones) == zeros
    assert update_periodic(110, zeros) == zeros

    sample: State = (1, 0, 1, 1, 0, 0, 1, 0)
    assert update_periodic(0, sample) == zeros
    assert update_periodic(204, sample) == sample
    print("Rule 0 erases the sample state; Rule 204 preserves it exactly.")

    print_fixed_point_census(range(1, 11))


if __name__ == "__main__":
    main()
