#!/usr/bin/env python3
"""Numerical demonstrations of bounded reflective dynamics.

The examples model a cycle by a quality rank and a protocol label.  Outcomes
are state-dependent proposed gains.  Any genuine protocol change accompanies a
strict rank increase; a zero gain leaves the entire cycle unchanged.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Iterable, Sequence


@dataclass(frozen=True)
class Cycle:
    """A research cycle with bounded quality and a descriptive protocol."""

    quality: int
    protocol: str


@dataclass(frozen=True)
class TraceRow:
    """One transition and the size of its state-dependent outcome space."""

    step: int
    before: Cycle
    outcome: int
    admissible_count: int
    after: Cycle


def admissible_outcomes(cycle: Cycle, capacity: int) -> range:
    """Return gains meaningful at this cycle: 0 through remaining capacity."""
    if not 0 <= cycle.quality <= capacity:
        raise ValueError("cycle quality must lie between zero and capacity")
    return range(capacity - cycle.quality + 1)


def revise(cycle: Cycle, gain: int, capacity: int) -> Cycle:
    """Apply an admissible gain, changing protocol only on strict improvement."""
    if gain not in admissible_outcomes(cycle, capacity):
        raise ValueError(f"gain {gain} is inadmissible at quality {cycle.quality}")
    if gain == 0:
        return cycle
    new_quality = cycle.quality + gain
    return Cycle(new_quality, f"protocol-q{new_quality}")


def simulate(
    initial: Cycle, gains: Iterable[int], capacity: int
) -> tuple[list[Cycle], list[TraceRow]]:
    """Generate a dependent run and record its changing outcome-space sizes."""
    cycles = [initial]
    rows: list[TraceRow] = []
    current = initial
    for step, gain in enumerate(gains):
        choices = admissible_outcomes(current, capacity)
        nxt = revise(current, gain, capacity)
        rows.append(TraceRow(step, current, gain, len(choices), nxt))
        cycles.append(nxt)
        current = nxt
    return cycles, rows


def verify_trace(cycles: Sequence[Cycle], capacity: int) -> None:
    """Check boundedness, monotonicity, and plateau stability on a finite trace."""
    if not cycles:
        raise ValueError("a trace must contain at least one cycle")
    for cycle in cycles:
        assert 0 <= cycle.quality <= capacity
    for before, after in zip(cycles, cycles[1:]):
        assert before.quality <= after.quality
        if before.quality == after.quality:
            assert before == after


def stabilization_index(cycles: Sequence[Cycle]) -> int:
    """Find the earliest index after which the supplied finite trace is constant."""
    if not cycles:
        raise ValueError("a trace must contain at least one cycle")
    final = cycles[-1]
    index = len(cycles) - 1
    while index > 0 and cycles[index - 1] == final:
        index -= 1
    return index


def strict_revision_bound(initial: Cycle, capacity: int) -> int:
    """Return K-q(c_0), the theorem's bound on genuine state changes."""
    if not 0 <= initial.quality <= capacity:
        raise ValueError("initial quality must lie between zero and capacity")
    return capacity - initial.quality


def greedy_gain(cycle: Cycle, capacity: int) -> int:
    """Choose the largest admissible gain."""
    return capacity - cycle.quality


def cautious_gain(cycle: Cycle, capacity: int) -> int:
    """Choose a unit gain until capacity, then choose the fixing outcome zero."""
    return 1 if cycle.quality < capacity else 0


def run_policy(
    initial: Cycle,
    capacity: int,
    policy: Callable[[Cycle, int], int],
    steps: int,
) -> list[Cycle]:
    """Run a state-dependent policy for a fixed reporting horizon."""
    current = initial
    result = [current]
    for _ in range(steps):
        current = revise(current, policy(current, capacity), capacity)
        result.append(current)
    return result


def demo_dependent_outcomes() -> None:
    """Display contraction of admissible outcomes along an improving run."""
    capacity = 8
    initial = Cycle(1, "protocol-q1")
    cycles, rows = simulate(initial, [2, 1, 3, 1, 0, 0], capacity)
    verify_trace(cycles, capacity)
    print("\nDEMO 1 — Dependent outcome spaces")
    print("step | quality before | chosen gain | admissible gains | quality after")
    for row in rows:
        allowed = f"0..{row.admissible_count - 1}"
        print(
            f"{row.step:>4} | {row.before.quality:>14} | {row.outcome:>11} | "
            f"{allowed:>16} | {row.after.quality:>13}"
        )
    print("trajectory:", [cycle.quality for cycle in cycles])
    print("stabilization index in this prefix:", stabilization_index(cycles))


def demo_revision_bound() -> None:
    """Compare observed strict changes with the finite-capacity bound."""
    capacity = 10
    initial = Cycle(3, "protocol-q3")
    cycles, _ = simulate(initial, [1, 0, 2, 1, 0, 3, 0, 0], capacity)
    verify_trace(cycles, capacity)
    strict_changes = sum(a != b for a, b in zip(cycles, cycles[1:]))
    bound = strict_revision_bound(initial, capacity)
    print("\nDEMO 2 — Strict-revision budget")
    print("qualities:", [cycle.quality for cycle in cycles])
    print(f"observed genuine changes: {strict_changes}; theorem bound: {bound}")
    assert strict_changes <= bound


def demo_policy_comparison() -> None:
    """Show distinct transient paths with the same eventual fixed cycle."""
    capacity = 6
    initial = Cycle(0, "protocol-q0")
    greedy = run_policy(initial, capacity, greedy_gain, 8)
    cautious = run_policy(initial, capacity, cautious_gain, 10)
    verify_trace(greedy, capacity)
    verify_trace(cautious, capacity)
    print("\nDEMO 3 — Policy comparison")
    print("greedy qualities: ", [cycle.quality for cycle in greedy])
    print("cautious qualities:", [cycle.quality for cycle in cautious])
    print("both tails are fixed at capacity:", greedy[-1] == cautious[-1])


def main() -> None:
    """Run all three demonstrations."""
    demo_dependent_outcomes()
    demo_revision_bound()
    demo_policy_comparison()


if __name__ == "__main__":
    main()
