#!/usr/bin/env python3
"""Numerical demonstrations of deterministic causal loops and branching histories.

The program uses finite update tables.  It audits closed orbits, fixed points,
idempotence, the Boolean grandfather intervention, and append-only branches.
No third-party packages are required.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Generic, Hashable, Iterable, Sequence, TypeVar

State = TypeVar("State", bound=Hashable)
Event = TypeVar("Event", bound=Hashable)


@dataclass(frozen=True)
class OrbitAudit(Generic[State]):
    """Summary of a proposed finite orbit."""

    visited: tuple[State, ...]
    endpoint: State
    closed: bool
    fixed_indices: tuple[int, ...]
    novikov_consistent: bool


def iterate(step: Callable[[State], State], start: State, count: int) -> State:
    """Return the state obtained after ``count`` causal updates."""
    if count < 0:
        raise ValueError("count must be nonnegative")
    state = start
    for _ in range(count):
        state = step(state)
    return state


def audit_orbit(
    step: Callable[[State], State], start: State, period: int
) -> OrbitAudit[State]:
    """Audit closure, visited fixed points, and pointwise consistency."""
    if period <= 0:
        raise ValueError("period must be positive")
    states: list[State] = []
    state = start
    fixed_indices: list[int] = []
    for index in range(period):
        states.append(state)
        next_state = step(state)
        if next_state == state:
            fixed_indices.append(index)
        state = next_state
    return OrbitAudit(
        visited=tuple(states),
        endpoint=state,
        closed=(state == start),
        fixed_indices=tuple(fixed_indices),
        novikov_consistent=(len(fixed_indices) == period),
    )


def is_idempotent(
    step: Callable[[State], State], states: Iterable[State]
) -> bool:
    """Test ``step(step(x)) == step(x)`` on an explicit finite state space."""
    return all(step(step(state)) == step(state) for state in states)


def grandfather_step(alive: bool) -> bool:
    """Flip the ancestor-survival state."""
    return not alive


def project_to_even(value: int) -> int:
    """An idempotent projection sending an integer to the even integer below it."""
    return value - value % 2


def travel(source: Sequence[Event], intervention: Event) -> tuple[Event, ...]:
    """Create a child timeline without changing the source history."""
    return tuple(source) + (intervention,)


def is_ancestor(ancestor: Sequence[Event], descendant: Sequence[Event]) -> bool:
    """Return whether ``ancestor`` is a prefix of ``descendant``."""
    return len(ancestor) <= len(descendant) and tuple(descendant[: len(ancestor)]) == tuple(ancestor)


def is_strict_descendant(child: Sequence[Event], parent: Sequence[Event]) -> bool:
    """Test strict prefix descent."""
    return is_ancestor(parent, child) and tuple(parent) != tuple(child)


def format_audit(label: str, audit: OrbitAudit[State]) -> str:
    """Format an orbit audit for terminal output."""
    fixed = list(audit.fixed_indices) if audit.fixed_indices else "none"
    return (
        f"{label}\n"
        f"  visited states: {list(audit.visited)}\n"
        f"  endpoint: {audit.endpoint!r}\n"
        f"  closed: {audit.closed}\n"
        f"  fixed-point indices: {fixed}\n"
        f"  pointwise consistent: {audit.novikov_consistent}"
    )


def demonstrate_grandfather_parity() -> None:
    """Show that precisely the even proposed periods close, but none is consistent."""
    print("GRANDFATHER INTERVENTION: BOOLEAN NEGATION")
    for period in range(1, 7):
        audit = audit_orbit(grandfather_step, True, period)
        print(
            f"  period {period}: endpoint={audit.endpoint}, "
            f"closed={audit.closed}, consistent={audit.novikov_consistent}"
        )
    assert all(
        audit_orbit(grandfather_step, True, p).closed == (p % 2 == 0)
        for p in range(1, 13)
    )
    assert not any(grandfather_step(state) == state for state in (False, True))
    print("  confirmed: even periods close, odd periods do not, and no fixed state exists.\n")


def demonstrate_idempotent_collapse() -> None:
    """Show stabilization after one step for a finite idempotent projection."""
    domain = range(-4, 7)
    print("IDEMPOTENT PROJECTION")
    print(f"  idempotent on sampled domain: {is_idempotent(project_to_even, domain)}")
    for start in (5, 4, -3):
        trajectory = [iterate(project_to_even, start, n) for n in range(5)]
        print(f"  start {start:>2}: {trajectory}")
    closed = audit_orbit(project_to_even, 4, 5)
    assert closed.closed and closed.novikov_consistent
    nonclosed = audit_orbit(project_to_even, 5, 5)
    assert not nonclosed.closed
    print("  confirmed: a positive closed orbit begins at a fixed state.\n")


def demonstrate_branching() -> None:
    """Construct distinct, incomparable sibling branches and a descendant chain."""
    source = ("launch", "arrival")
    rescue = travel(source, "rescue ancestor")
    abstain = travel(source, "do not intervene")
    grandchild = travel(rescue, "return home")

    print("APPEND-ONLY BRANCHING")
    print(f"  source:     {source}")
    print(f"  rescue:     {rescue}")
    print(f"  abstain:    {abstain}")
    print(f"  grandchild: {grandchild}")
    print(f"  rescue descends from source: {is_strict_descendant(rescue, source)}")
    print(f"  grandchild descends from source: {is_strict_descendant(grandchild, source)}")
    print(f"  rescue ancestor of abstain: {is_ancestor(rescue, abstain)}")
    print(f"  abstain ancestor of rescue: {is_ancestor(abstain, rescue)}")

    assert rescue != abstain
    assert is_strict_descendant(rescue, source)
    assert is_strict_descendant(grandchild, rescue)
    assert is_strict_descendant(grandchild, source)
    assert not is_strict_descendant(source, source)
    assert not is_ancestor(rescue, abstain)
    assert not is_ancestor(abstain, rescue)
    print("  confirmed: extension is acyclic and distinct siblings are incomparable.\n")


def main() -> None:
    """Run all demonstrations."""
    demonstrate_grandfather_parity()
    demonstrate_idempotent_collapse()
    demonstrate_branching()
    print(format_audit("TWO-STEP GRANDFATHER AUDIT", audit_orbit(grandfather_step, True, 2)))


if __name__ == "__main__":
    main()
