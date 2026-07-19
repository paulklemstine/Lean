#!/usr/bin/env python3
"""Numerical illustrations of substrate-invariant complexity transport.

The examples are finite demonstrations of the theorem hypotheses and their
quantitative consequences; they do not attempt to decide P versus NP.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Iterable, Sequence

Overhead = Callable[[int], int]


@dataclass(frozen=True)
class SimulationStep:
    """A named monotone simulation overhead."""

    name: str
    overhead: Overhead


def compose_overheads(steps: Sequence[SimulationStep], cost: int) -> int:
    """Apply simulation overheads in program-translation order."""
    if cost < 0:
        raise ValueError("cost must be nonnegative")
    result = cost
    for step in steps:
        result = step.overhead(result)
        if result < 0:
            raise ValueError(f"{step.name} produced a negative cost")
    return result


def transport_budget(
    steps: Sequence[SimulationStep], budget: Sequence[int]
) -> list[int]:
    """Transport a finite pointwise budget through composed simulations."""
    return [compose_overheads(steps, value) for value in budget]


def exact_profiles_agree(
    profile_a: Sequence[Sequence[bool]], profile_b: Sequence[Sequence[bool]]
) -> bool:
    """Check equality of finite language-by-level membership profiles."""
    return [list(row) for row in profile_a] == [list(row) for row in profile_b]


def adjacent_separations(profile: Sequence[Sequence[bool]]) -> list[tuple[int, int]]:
    """Return (language, level) pairs entering exactly at the next level."""
    found: list[tuple[int, int]] = []
    for language, row in enumerate(profile):
        for level in range(len(row) - 1):
            if not row[level] and row[level + 1]:
                found.append((language, level))
    return found


def jump_prefix_is_valid(member: Sequence[bool], successor_escapes: Sequence[bool]) -> bool:
    """Check membership and successor escape over a finite jump prefix."""
    return len(member) == len(successor_escapes) and all(member) and all(successor_escapes)


def reduction_transport(
    reduction: Callable[[int], int], target_budget: Callable[[int], int], inputs: Iterable[int]
) -> dict[int, int]:
    """Compute the pulled-back budget x ↦ b(f(x)) for sample inputs."""
    return {x: target_budget(reduction(x)) for x in inputs}


def main() -> None:
    print("SUBSTRATE-INVARIANT COMPLEXITY: FINITE NUMERICAL ILLUSTRATIONS")
    print("=" * 70)

    steps = [
        SimulationStep("binary-to-ternary", lambda n: 2 * n + 1),
        SimulationStep("ternary-to-crystal", lambda n: n * n),
    ]
    source_costs = [1, 2, 4, 8]
    source_budget = [2, 3, 5, 10]
    transported_costs = transport_budget(steps, source_costs)
    transported_budget = transport_budget(steps, source_budget)
    print("\n1. General simulation transport")
    print(f"   source costs:       {source_costs}")
    print(f"   source budget:      {source_budget}")
    print(f"   transported costs: {transported_costs}")
    print(f"   transported bound: {transported_budget}")
    print(f"   bound respected:   {all(c <= b for c, b in zip(transported_costs, transported_budget))}")

    profile_earth = [
        [True, True, True, True],
        [False, True, True, True],
        [False, False, True, True],
        [False, False, False, True],
    ]
    profile_alien = [row[:] for row in profile_earth]
    print("\n2. Exact levelwise hierarchy invariance")
    print(f"   profiles agree: {exact_profiles_agree(profile_earth, profile_alien)}")
    print(f"   adjacent witnesses: {adjacent_separations(profile_earth)}")

    current_members = [True] * 6
    next_level_escapes = [True] * 6
    print("\n3. Jump hierarchy prefix")
    print(f"   inspected levels: 0..{len(current_members) - 1}")
    print(f"   every current iterate is present: {all(current_members)}")
    print(f"   every successor escapes: {all(next_level_escapes)}")
    print(f"   finite prefix satisfies jump pattern: {jump_prefix_is_valid(current_members, next_level_escapes)}")

    pulled_back = reduction_transport(lambda x: 2 * x + 1, lambda y: y * y + 3, range(6))
    print("\n4. Reduction budget pullback")
    print(f"   f(x) = 2x + 1, b(y) = y^2 + 3")
    print(f"   sample values of b(f(x)): {pulled_back}")


if __name__ == "__main__":
    main()
