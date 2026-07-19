#!/usr/bin/env python3
"""Finite demonstrations for self-modifying computation and monitoring limits.

The examples do not attempt to decide unbounded halting. They show (1) exact
trace equivalence when mutable code is stored as ordinary state, (2) truthful
bounded monitoring, and (3) how any finite observation horizon can be defeated
by delaying a halt beyond it.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Iterable, Optional, TypeAlias


@dataclass(frozen=True)
class Program:
    """Mutable instruction parameters for the Fibonacci-rewrite example."""

    addend: int
    next_addend: int


@dataclass(frozen=True)
class Configuration:
    """A current program together with its ordinary integer state."""

    program: Program
    value: int


Transition: TypeAlias = Callable[[Configuration], Optional[Configuration]]


def rewriting_step(limit: int) -> Transition:
    """Return a transition that adds and then rewrites Fibonacci parameters."""

    def step(config: Configuration) -> Optional[Configuration]:
        if config.value >= limit:
            return None
        a, b = config.program.addend, config.program.next_addend
        return Configuration(Program(b, a + b), config.value + a)

    return step


def self_modifying_trace(
    initial: Configuration, transition: Transition, max_steps: int
) -> list[Configuration]:
    """Execute the mutable-program presentation for at most ``max_steps``."""

    trace = [initial]
    current = initial
    for _ in range(max_steps):
        successor = transition(current)
        if successor is None:
            break
        trace.append(successor)
        current = successor
    return trace


def fixed_interpreter_trace(
    encoded_state: tuple[int, int, int], limit: int, max_steps: int
) -> list[tuple[int, int, int]]:
    """Execute a fixed interpreter storing ``(addend, next_addend, value)``."""

    trace = [encoded_state]
    a, b, value = encoded_state
    for _ in range(max_steps):
        if value >= limit:
            break
        a, b, value = b, a + b, value + a
        trace.append((a, b, value))
    return trace


def encode_trace(trace: Iterable[Configuration]) -> list[tuple[int, int, int]]:
    """Encode mutable configurations as fixed-interpreter states."""

    return [
        (item.program.addend, item.program.next_addend, item.value)
        for item in trace
    ]


def bounded_monitor(
    initial: Configuration, transition: Transition, horizon: int
) -> tuple[str, int]:
    """Report a halt within the horizon or finite survival through the horizon."""

    current = initial
    for step_number in range(horizon + 1):
        successor = transition(current)
        if successor is None:
            return ("halt observed", step_number)
        if step_number == horizon:
            break
        current = successor
    return ("survived finite horizon", horizon)


def delayed_halt_step(delay: int) -> Callable[[int], Optional[int]]:
    """Return a machine on counters that halts exactly upon reaching ``delay``."""

    def step(counter: int) -> Optional[int]:
        return None if counter >= delay else counter + 1

    return step


def finite_horizon_indistinguishability(horizon: int) -> dict[str, object]:
    """Compare a perpetual counter with one halting just beyond the horizon."""

    delayed = delayed_halt_step(horizon + 1)
    delayed_prefix = [0]
    current = 0
    for _ in range(horizon):
        successor = delayed(current)
        assert successor is not None
        current = successor
        delayed_prefix.append(current)
    perpetual_prefix = list(range(horizon + 1))
    return {
        "horizon": horizon,
        "prefixes_equal": delayed_prefix == perpetual_prefix,
        "delayed_halt_time": horizon + 1,
        "shared_prefix": delayed_prefix,
    }


def main() -> None:
    """Run three deterministic demonstrations and print their conclusions."""

    limit = 50
    steps = 20
    initial = Configuration(Program(1, 1), 0)
    transition = rewriting_step(limit)

    mutable = self_modifying_trace(initial, transition, steps)
    fixed = fixed_interpreter_trace((1, 1, 0), limit, steps)
    encoded = encode_trace(mutable)

    print("DEMO 1 — Exact fixed-interpreter simulation")
    print("mutable trace:", encoded)
    print("fixed trace:  ", fixed)
    print("traces equal: ", encoded == fixed)
    assert encoded == fixed

    print("\nDEMO 2 — Bounded monitoring")
    for horizon in (3, 7, 20):
        verdict, stage = bounded_monitor(initial, transition, horizon)
        print(f"horizon={horizon:2d}: {verdict} at/through stage {stage}")

    print("\nDEMO 3 — Every finite horizon admits a delayed halt")
    for horizon in (5, 10, 25):
        result = finite_horizon_indistinguishability(horizon)
        print(
            f"horizon={horizon:2d}: prefixes equal={result['prefixes_equal']}, "
            f"but delayed machine halts at {result['delayed_halt_time']}"
        )
        assert result["prefixes_equal"] is True


if __name__ == "__main__":
    main()
