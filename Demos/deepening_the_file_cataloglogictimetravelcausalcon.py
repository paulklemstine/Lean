#!/usr/bin/env python3
"""Numerical demonstrations of recurrence and symmetry in finite causal loops."""

from __future__ import annotations

from math import gcd
from typing import Iterable, Sequence

Permutation = tuple[int, ...]


def validate_permutation(mapping: Sequence[int]) -> None:
    """Raise ValueError unless mapping encodes a permutation of range(len(mapping))."""
    n = len(mapping)
    if sorted(mapping) != list(range(n)):
        raise ValueError("mapping must contain every state 0,...,n-1 exactly once")


def fixed_points(mapping: Sequence[int]) -> list[int]:
    """Return all states fixed by one traversal."""
    return [state for state, image in enumerate(mapping) if state == image]


def compose(left: Sequence[int], right: Sequence[int]) -> Permutation:
    """Return left after right: state -> left[right[state]]."""
    if len(left) != len(right):
        raise ValueError("permutations must act on sets of the same size")
    return tuple(left[right[state]] for state in range(len(left)))


def iterate_permutation(mapping: Sequence[int], exponent: int) -> Permutation:
    """Compute a nonnegative iterate by binary exponentiation."""
    validate_permutation(mapping)
    if exponent < 0:
        raise ValueError("exponent must be nonnegative")
    result: Permutation = tuple(range(len(mapping)))
    power: Permutation = tuple(mapping)
    k = exponent
    while k:
        if k & 1:
            result = compose(power, result)
        power = compose(power, power)
        k >>= 1
    return result


def cycle_decomposition(mapping: Sequence[int]) -> list[list[int]]:
    """Return the disjoint cycles of a finite permutation."""
    validate_permutation(mapping)
    visited = [False] * len(mapping)
    cycles: list[list[int]] = []
    for start in range(len(mapping)):
        if visited[start]:
            continue
        cycle: list[int] = []
        state = start
        while not visited[state]:
            visited[state] = True
            cycle.append(state)
            state = mapping[state]
        cycles.append(cycle)
    return cycles


def lcm(a: int, b: int) -> int:
    """Return the nonnegative least common multiple of two integers."""
    return 0 if a == 0 or b == 0 else abs(a // gcd(a, b) * b)


def universal_return_time(mapping: Sequence[int]) -> int:
    """Return the least positive N for which the permutation's Nth iterate is identity."""
    if not mapping:
        raise ValueError("the phase space must be nonempty")
    period = 1
    for cycle in cycle_decomposition(mapping):
        period = lcm(period, len(cycle))
    return period


def is_involution(mapping: Sequence[int]) -> bool:
    """Test whether applying the map twice restores every state."""
    validate_permutation(mapping)
    return all(mapping[mapping[state]] == state for state in range(len(mapping)))


def conjugate(mapping: Sequence[int], relabeling: Sequence[int]) -> Permutation:
    """Transport a permutation through a bijective relabeling e as e f e^{-1}."""
    validate_permutation(mapping)
    validate_permutation(relabeling)
    if len(mapping) != len(relabeling):
        raise ValueError("map and relabeling must have equal sizes")
    inverse = [0] * len(relabeling)
    for old, new in enumerate(relabeling):
        inverse[new] = old
    return tuple(relabeling[mapping[inverse[new]]] for new in range(len(mapping)))


def product_fixed_points(first: Sequence[int], second: Sequence[int]) -> list[tuple[int, int]]:
    """Enumerate fixed states of the independent product without building its full map."""
    return [(a, b) for a in fixed_points(first) for b in fixed_points(second)]


def describe(name: str, mapping: Sequence[int]) -> None:
    """Print the cycle, fixed-point, parity, and recurrence data of a permutation."""
    cycles = cycle_decomposition(mapping)
    points = fixed_points(mapping)
    period = universal_return_time(mapping)
    identity = tuple(range(len(mapping)))
    print(f"\n{name}")
    print(f"  mapping: {tuple(mapping)}")
    print(f"  cycles: {cycles}")
    print(f"  one-step fixed points: {points}")
    print(f"  minimal universal return time: {period}")
    print(f"  iterate at that time: {iterate_permutation(mapping, period)}")
    assert iterate_permutation(mapping, period) == identity
    if is_involution(mapping):
        print(f"  involution parity: {len(points) % 2} = {len(mapping) % 2} (mod 2)")
        assert len(points) % 2 == len(mapping) % 2


def main() -> None:
    """Run four reproducible demonstrations of the main results."""
    grandfather: Permutation = (1, 0)
    mixed: Permutation = (1, 2, 0, 4, 3, 5, 6)
    odd_involution: Permutation = (1, 0, 3, 2, 4)

    describe("Two-state switching loop", grandfather)
    describe("Mixed cycles of lengths 3, 2, 1, and 1", mixed)
    describe("Odd five-state involution", odd_involution)

    relabeling: Permutation = (3, 0, 6, 2, 5, 1, 4)
    transported = conjugate(mixed, relabeling)
    expected_fixed = sorted(relabeling[state] for state in fixed_points(mixed))
    actual_fixed = sorted(fixed_points(transported))
    print("\nCoordinate invariance")
    print(f"  original fixed points: {fixed_points(mixed)}")
    print(f"  relabeled fixed points: {actual_fixed}")
    assert expected_fixed == actual_fixed

    second: Permutation = (0, 2, 1, 3)
    pairs = product_fixed_points(odd_involution, second)
    print("\nProduct consistency")
    print(f"  fixed pairs: {pairs}")
    assert len(pairs) == len(fixed_points(odd_involution)) * len(fixed_points(second))


if __name__ == "__main__":
    main()
