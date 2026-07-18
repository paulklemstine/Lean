#!/usr/bin/env python3
"""Numerical demonstrations for elementary cellular automata over GF(2)."""

from __future__ import annotations

from typing import Callable, Iterable, Sequence

Bits = tuple[int, ...]
NeighborMap = Callable[[int, int], int]


def rule_table(rule_number: int) -> tuple[int, ...]:
    """Return outputs in neighborhood order 000, 001, ..., 111."""
    if not 0 <= rule_number <= 255:
        raise ValueError("an elementary rule number must lie between 0 and 255")
    return tuple((rule_number >> mask) & 1 for mask in range(8))


def local_output(table: Sequence[int], left: int, center: int, right: int) -> int:
    """Evaluate a decoded rule table on one neighborhood."""
    return table[(left << 2) | (center << 1) | right]


def cyclic_left(i: int, n: int) -> int:
    return (i - 1) % n


def cyclic_right(i: int, n: int) -> int:
    return (i + 1) % n


def update(
    state: Bits,
    rule_number: int,
    left_map: NeighborMap = cyclic_left,
    right_map: NeighborMap = cyclic_right,
) -> Bits:
    """Apply one synchronous update with configurable neighbor maps."""
    n = len(state)
    if n == 0:
        return ()
    table = rule_table(rule_number)
    return tuple(
        local_output(table, state[left_map(i, n)], state[i], state[right_map(i, n)])
        for i in range(n)
    )


def configurations(n: int) -> Iterable[Bits]:
    """Generate all n-cell states in increasing binary order."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    for value in range(1 << n):
        yield tuple((value >> i) & 1 for i in range(n))


def fixed_points(rule_number: int, n: int) -> list[Bits]:
    """Enumerate fixed configurations on an n-cell cyclic array."""
    return [state for state in configurations(n) if update(state, rule_number) == state]


def anf_coefficients(rule_number: int) -> tuple[int, ...]:
    """Compute algebraic-normal-form coefficients by a GF(2) Möbius transform."""
    coefficients = list(rule_table(rule_number))
    for bit in range(3):
        for mask in range(8):
            if mask & (1 << bit):
                coefficients[mask] ^= coefficients[mask ^ (1 << bit)]
    return tuple(coefficients)


def eval_anf(coefficients: Sequence[int], left: int, center: int, right: int) -> int:
    """Evaluate a ternary algebraic normal form over GF(2)."""
    variables = (right, center, left)  # mask order matches binary neighborhood index
    result = 0
    for mask, coefficient in enumerate(coefficients):
        term = coefficient
        for bit, value in enumerate(variables):
            if mask & (1 << bit):
                term &= value
        result ^= term
    return result


def verify_anf(rule_number: int) -> bool:
    """Check the polynomial representation on all eight inputs."""
    table = rule_table(rule_number)
    coefficients = anf_coefficients(rule_number)
    return all(
        eval_anf(coefficients, left, center, right)
        == local_output(table, left, center, right)
        for left in (0, 1)
        for center in (0, 1)
        for right in (0, 1)
    )


def demonstrate(max_n: int = 10) -> None:
    """Print the principal fixed-point and polynomial demonstrations."""
    print("Cyclic fixed-point counts")
    print(" n | Rule 0 | Rule 110 | Rule 204 | all states")
    print("---+--------+----------+----------+-----------")
    for n in range(1, max_n + 1):
        counts = [len(fixed_points(rule, n)) for rule in (0, 110, 204)]
        print(f"{n:2d} | {counts[0]:6d} | {counts[1]:8d} | {counts[2]:8d} | {1 << n:9d}")
        assert counts == [1, 1, 1 << n]

    print("\nAlgebraic-normal-form checks")
    for rule in (0, 30, 90, 110, 204, 255):
        coefficients = anf_coefficients(rule)
        print(f"Rule {rule:3d}: coefficients={coefficients}, verified={verify_anf(rule)}")
        assert verify_anf(rule)

    assert all(verify_anf(rule) for rule in range(256))
    print("\nAll 256 local rules agree with their degree-at-most-three polynomial forms.")


if __name__ == "__main__":
    demonstrate()
