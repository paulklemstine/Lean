#!/usr/bin/env python3
"""Numerical demonstrations of least invariant regions and fixed-point semantics."""

from __future__ import annotations

from collections import deque
from typing import Callable, FrozenSet, Iterable, TypeVar

T = TypeVar("T")


def image(step: Callable[[T], T], region: Iterable[T]) -> set[T]:
    """Return the direct image of a region under a deterministic transition."""
    return {step(x) for x in region}


def saturation_trace(
    states: Iterable[T], initial: Iterable[T], step: Callable[[T], T]
) -> list[FrozenSet[T]]:
    """Iterate R ↦ I ∪ step[R] from the empty set through stabilization."""
    universe = set(states)
    seeds = set(initial)
    if not seeds <= universe:
        raise ValueError("Every initial state must belong to the state space")
    trace: list[FrozenSet[T]] = [frozenset()]
    while True:
        current = set(trace[-1])
        following = seeds | image(step, current)
        if not following <= universe:
            raise ValueError("The transition must map the state space into itself")
        if following == current:
            return trace
        trace.append(frozenset(following))


def reachable_region(initial: Iterable[T], step: Callable[[T], T]) -> FrozenSet[T]:
    """Compute finite deterministic reachability using a frontier queue."""
    reached = set(initial)
    frontier = deque(reached)
    while frontier:
        successor = step(frontier.popleft())
        if successor not in reached:
            reached.add(successor)
            frontier.append(successor)
    return frozenset(reached)


def is_admissible(
    initial: Iterable[T], step: Callable[[T], T], candidate: Iterable[T]
) -> bool:
    """Test whether a candidate contains the seeds and is forward invariant."""
    seeds, region = set(initial), set(candidate)
    return seeds <= region and all(step(x) in region for x in region)


def least_diagonal_fixed_point(
    size: int, simulator: Callable[[int, int], int]
) -> int:
    """Find the least diagonal fixed point in the finite chain 0,…,size-1."""
    fixed = [a for a in range(size) if simulator(a, a) == a]
    if not fixed:
        raise ValueError("No diagonal fixed point was found")
    return min(fixed)


def least_section_fixed_point(
    size: int, simulator: Callable[[int, int], int], parameter: int
) -> int:
    """Find the least fixed point of b ↦ simulator(parameter, b)."""
    fixed = [b for b in range(size) if simulator(parameter, b) == b]
    if not fixed:
        raise ValueError("The selected section has no fixed point")
    return min(fixed)


def nested_least_fixed_point(
    size: int, simulator: Callable[[int, int], int]
) -> int:
    """Compute μa. μb. U(a,b) by finite exhaustive search."""
    inner = [least_section_fixed_point(size, simulator, a) for a in range(size)]
    fixed = [a for a in range(size) if inner[a] == a]
    if not fixed:
        raise ValueError("The outer map has no fixed point")
    return min(fixed)


def demo_reachability() -> None:
    """Display equality of saturation and finite reachability."""
    states = range(8)
    step = lambda x: (2 * x + 1) % 8
    trace = saturation_trace(states, {0}, step)
    reached = reachable_region({0}, step)
    print("Demo 1 — least invariant region")
    for index, region in enumerate(trace):
        print(f"  R_{index} = {sorted(region)}")
    print(f"  Reachable region = {sorted(reached)}")
    assert trace[-1] == reached == frozenset({0, 1, 3, 7})


def demo_minimality() -> None:
    """Enumerate all admissible regions and verify the least one."""
    states = set(range(4))
    step = lambda x: (x + 1) % 4
    initial = {0}
    candidates: list[FrozenSet[int]] = []
    for mask in range(1 << len(states)):
        region = frozenset(x for x in states if mask & (1 << x))
        if is_admissible(initial, step, region):
            candidates.append(region)
    least = reachable_region(initial, step)
    print("\nDemo 2 — minimality among invariant regions")
    print(f"  Admissible regions = {[sorted(r) for r in candidates]}")
    print(f"  Least region = {sorted(least)}")
    assert all(least <= region for region in candidates)


def demo_diagonal_rule() -> None:
    """Compare nested and diagonal semantics on a finite complete chain."""
    size = 7
    simulator = lambda a, b: min(max(a, b), 4)
    nested = nested_least_fixed_point(size, simulator)
    diagonal = least_diagonal_fixed_point(size, simulator)
    diagonal_points = [a for a in range(size) if simulator(a, a) == a]
    print("\nDemo 3 — fixed-point diagonal rule")
    print(f"  Diagonal fixed points = {diagonal_points}")
    print(f"  Nested least fixed point = {nested}")
    print(f"  Diagonal least fixed point = {diagonal}")
    assert nested == diagonal == 0
    assert len(diagonal_points) > 1  # leastness does not imply sole fixed point


def main() -> None:
    demo_reachability()
    demo_minimality()
    demo_diagonal_rule()


if __name__ == "__main__":
    main()
